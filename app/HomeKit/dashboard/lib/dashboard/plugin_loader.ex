defmodule Dashboard.PluginLoader do
  alias Dashboard.{PluginRegistry, PluginSupervisor}

  def load_plugin(name, plugin_module, path) do
    supervisor_module = Module.concat([plugin_module, Supervisor])
    {:ok, pid} = PluginSupervisor.start_plugin({supervisor_module, []})
    PluginRegistry.add(name, plugin_module_web_module(plugin_module), path, pid)
    {:ok, pid}
  end

  def unload_plugin(name) do
    if plugin = PluginRegistry.get(name) do
      if plugin.pid, do: PluginSupervisor.stop_plugin(plugin.pid)
      PluginRegistry.remove(name)
    end
  end

  defp plugin_module_web_module(plugin_module) do
    Module.concat([plugin_module, "Web", "Live", "Index"])
  end
end
