defmodule DashboardWeb.PluginsLive do
  use DashboardWeb, :live_view

  alias Dashboard.{PluginLoader, PluginRegistry, PluginConfig}

  alias DashboardWeb.DynamicPluginLive

  def mount(_params, _session, socket) do
    {:ok, configs} = PluginConfig.load_configs()
    {:ok, plugins} = normalizeConfigs(configs)
    {:ok,
     assign(socket,
       mode: :menu,       # :menu = show plugin list, :plugin = show selected plugin
       plugin_name: nil,
       plugin_key: nil,
       plugins: plugins
     )}
  end

  def handle_event("back_to_menu", _params, socket) do
    {:noreply, assign(socket, mode: :menu, plugin_name: nil, plugin_key: nil)}
  end

  def handle_event("load_plugin_ui", _, socket) do
     {:noreply,
      socket
      |> assign(mode: :plugin)}
  end

  def handle_event("load_plugin", params, socket) do
    plugin_name =
      cond do
        Map.has_key?(params, "name") -> params["name"]
        Map.has_key?(params, "value") and is_map(params["value"]) and Map.has_key?(params["value"], "name") ->
          params["value"]["name"]
        true -> nil
      end
    IO.inspect(plugin_name, label: "[/] Loading Plugin: ")

    {:ok, _pid, atom} = PluginLoader.load_plugin(plugin_name)
    plugins = Map.update!(socket.assigns.plugins, atom, fn plugin ->
      Map.put(plugin, :enabled, true)
    end)

    {:noreply,
      socket 
      |> push_event("load_plugin", %{plugin: plugin_name})
      |> assign(mode: :menu, plugins: plugins, plugin_name: plugin_name, plugin_key: Atom.to_string(atom))}
  end

  def handle_event("unload_plugin", %{"name" => plugin_name} = _params, socket) do
    {:ok, atom} = PluginLoader.unload_plugin(plugin_name)

    plugins = Map.update!(socket.assigns.plugins, atom, fn plugin ->
      Map.put(plugin, :enabled, false)
    end)

    {:noreply, assign(socket, plugins: plugins)}
  end

  def normalizeConfigs(configs) do
    plugins = Enum.reduce(configs, %{}, fn cfg, acc ->
                plugin_atom = String.to_atom(cfg["atom"])

                registry_plugin = PluginRegistry.get(plugin_atom) || %{}

                plugin_data = Map.merge(registry_plugin, %{
                                :enabled => cfg["enabled"],
                                "atom" => cfg["atom"],
                                "module" => cfg["module"],
                                "liveView" => cfg["liveView"],
                                "name" => cfg["name"],
                                "type" => cfg["type"]})
                Map.put(acc, plugin_atom, plugin_data)
              end)
    {:ok, plugins}
  end
end
