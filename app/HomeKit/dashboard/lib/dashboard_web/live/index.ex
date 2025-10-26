defmodule DashboardWeb.Index do
  use DashboardWeb, :live_view

  alias Dashboard.{PluginLoader, PluginRegistry, PluginConfig}

  def mount(_params, _session, socket) do
    {:ok, configs} = PluginConfig.load_configs()
    {:ok, plugins} = normalizeConfigs(configs)
    {:ok, assign(socket, plugins: plugins, disabled: false)}
  end

  def handle_event("load_plugin", params, socket) do
    plugin_name =
      cond do
        Map.has_key?(params, "name") -> params["name"]
        Map.has_key?(params, "value") and is_map(params["value"]) and Map.has_key?(params["value"], "name") ->
          params["value"]["name"]
        true -> nil
      end

    {:ok, configs} = PluginConfig.load_configs()
    config = Enum.find(configs, &(&1["name"] == plugin_name))

    if plugin_name not in [nil, ""] do
      IO.inspect("DOING THIS")
      case PluginLoader.load_plugin(plugin_name) do
        {:ok, _pid} -> 
          :ok
        {:error, reason} ->
          IO.inspect(reason, label: "[-] Failed to load plugin")
      end
    end

    plugins = Map.update!(socket.assigns.plugins, String.to_atom(config["atom"]), fn plugin ->
      Map.put(plugin, :enabled, true)
    end)

    {:noreply, assign(socket, plugins: plugins)}
  end

  def handle_event("unload_plugin", %{"name" => plugin_name} = _params, socket) do
    {:ok, configs} = PluginConfig.load_configs()
    config = Enum.find(configs, &(&1["name"] == plugin_name))

    case Dashboard.PluginLoader.unload_plugin(config["atom"]) do
      :ok -> :ok
      {:error, reason} -> IO.inspect(reason, label: "[-] Failed to unload plugin")
    end

    plugins = Map.update!(socket.assigns.plugins, String.to_atom(config["atom"]), fn plugin ->
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
