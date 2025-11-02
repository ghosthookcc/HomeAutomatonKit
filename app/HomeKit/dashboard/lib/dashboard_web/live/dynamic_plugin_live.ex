defmodule DashboardWeb.DynamicPluginLive do
  use DashboardWeb, :live_view

  alias Dashboard.PluginRegistry

  def mount(%{"plugin" => plugin_key, "plugin_name" => plugin_name}, _session, socket) do
    plugin = PluginRegistry.get(String.to_atom(plugin_key))
    case plugin do
      nil ->
        {:ok,
          socket
          |> put_flash(:info, "⚠️ Plugin not found or not available.")
          |> push_navigate(to: "/")}
      module ->
        {:ok, assign(socket,
                     plugin_module: module,
                     plugin: plugin,
                     plugin_name: plugin_name,
                     plugin_key: plugin_key)}
    end
  end

  def mount(:not_mounted_at_router, session, socket) do
    plugin_name = session["plugin_name"]
    plugin_key = session["plugin"]
    plugin = PluginRegistry.get(String.to_atom(plugin_key))
    case plugin do
      nil ->
        {:ok,
          socket
          |> put_flash(:info, "⚠️ Plugin not found or not available.")
          |> push_navigate(to: "/")}
      module ->
        {:ok, assign(socket,
                     plugin_module: module,
                     plugin: plugin,
                     plugin_name: plugin_name,
                     plugin_key: plugin_key)}
    end
  end

  def render(assigns) do
    ~H"""
    <!-- Dynamically load plugin CSS -->
    <link rel="stylesheet" href={~p"/plugins/#{@plugin_name}/css/app.css"} />

    <!-- Render the plugin's LiveView & JS-->
    <div id={"plugin-container-#{@plugin_key}"} 
         class="p-4">
      <%= live_render(@socket, @plugin_module.module, id: "plugin-view-#{@plugin_key}") %>
    </div>
    """
  end
end
