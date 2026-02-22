defmodule Dashboard.Services.ServiceManager do
  use GenServer
  alias Dashboard.Services.{Service, ServiceStatus, ServiceRegistry}
  alias Dashboard.Repo

  @go_bin_dir Path.join(File.cwd!(), "../../ServiceManager/proto-stubs/impl/go/bin")

  defp exe_for(service_name) do
    Path.join(@go_bin_dir, "#{service_name}#{exe_suffix()}")
  end

  defp exe_suffix do
    case :os.type() do
      {:win32, _} -> ".exe"
      _ -> ""
    end
  end

  defp poll_services do
    Repo.all(Service) |> Enum.each(fn service ->
      port = ServiceRegistry.get(service.service_name)
      new_status = if port && Port.info(port) != nil, do: :alive, else: :dead

      update_status(service.id, new_status)
    end)
  end

  defp update_status(service_id, status) do
    Repo.insert!(
      %ServiceStatus{
        service_id: service_id,
        status: status,
        last_updated: DateTime.utc_now() |> DateTime.truncate(:second)
      },
      on_conflict: [set: [status: status,
                          last_updated: DateTime.utc_now() |> DateTime.truncate(:second)]],
      conflict_target: [:service_id]
    )
  end

  defp monitor(service_name, port) do
    spawn(fn ->
      receive do
        {^port, {:exit_status, _}} ->
          ServiceRegistry.unregister(service_name)

          service = Repo.get_by!(Service, service_name: service_name)
          update_status(service.id, :dead)
      end
    end)
  end

  defp poll_loop do
    poll_services()
    :timer.sleep(5000)
    poll_loop()
  end

  defp launch_service(service) do
    exe = exe_for(service.service_name)

    if File.exists?(exe) do
      {:ok, port} =
        Port.open({:spawn_executable, exe}, [
          :binary,
          :exit_status
        ])

      ServiceRegistry.register(service.service_name, port)

      update_status(service.id, :connecting)

      monitor(service.service_name, port)
    else
      update_status(service.id, :dead)
    end
  end

  def launch_all_services do
    Repo.all(Service)
    |> Enum.each(&launch_service/1)
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__) 
    Task.start(fn ->
      :timer.sleep(1000)
      poll_loop()
    end)
  end

  def init(_) do
    Task.start(fn -> __MODULE__.launch_all_services() end)
    {:ok, %{}}
  end
end
