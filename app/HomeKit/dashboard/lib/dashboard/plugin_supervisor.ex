defmodule Dashboard.PluginSupervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok), do: DynamicSupervisor.init(strategy: :one_for_one)

  def start_plugin(child_spec), do: DynamicSupervisor.start_child(__MODULE__, child_spec)
  def stop_plugin(pid), do: DynamicSupervisor.terminate_child(__MODULE__, pid)
end
