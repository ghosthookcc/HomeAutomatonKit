defmodule Dashboard.Application do
  use Application

  alias Dashboard.{PluginLoader, PluginConfig}

  @impl true
  def start(_type, _args) do
    IO.puts("Workspace DEBUG:")
    IO.inspect(Dashboard.Workspace.config())

    children = [
      DashboardWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:dashboard, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Dashboard.PubSub},

      DashboardWeb.Endpoint,
      Dashboard.PluginRegistry,
      Dashboard.PluginSupervisor
    ]

    opts = [strategy: :one_for_one, name: Dashboard.Supervisor]
    {:ok, sup} = Supervisor.start_link(children, opts)

    {:ok, configs} = PluginConfig.load_configs()
    for %{"name" => name,
          "module" => _cmodule,
          "enabled" => enabled} <- configs do
      if enabled do
        case PluginLoader.load_plugin(name) do
          {:ok, pid, _atom} ->
            IO.inspect("[+] Loaded plugin #{name} with pid: #{inspect(pid)} . . .")
          {:error, reason} ->
            IO.inspect("[-] Failed to load plugin #{name}: #{reason} . . .")
        end
      end
    end

    {:ok, sup}
  end

  @impl true
  def config_change(changed, _new, removed) do
    DashboardWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
