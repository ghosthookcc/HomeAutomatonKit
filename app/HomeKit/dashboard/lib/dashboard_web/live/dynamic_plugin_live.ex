defmodule DashboardWeb.DynamicPluginLive do
  use DashboardWeb, :live_view

  alias Dashboard.PluginRegistry

  def mount(%{"plugin" => plugin_name}, _session, socket) do
    plugin = PluginRegistry.get(String.to_atom(plugin_name))
    case plugin do
      nil ->
        {:ok,
          socket
          |> put_flash(:info, "⚠️ Plugin not found or not available.")
          |> push_navigate(to: "/")}
      module ->
        {:ok, assign(socket, plugin_module: module, plugin: plugin, plugin_name: plugin_name)}
    end
  end

  def render(assigns) do
    ~H"""
    <!-- Dynamically load plugin CSS -->
    <link rel="stylesheet" href={"/plugins/#{@plugin_name}/assets/css/app.css"} />

    <!-- Render the plugin's LiveView -->
    <div id="plugin-container" class="p-4">
      <%= live_render(@socket, @plugin_module.module, id: @plugin_name) %>
    </div>

    <!-- Dynamically load plugin JS -->
    <script defer type="text/javascript" src={"/plugins/#{@plugin_name}/assets/js/app.js"}></script>
    """
  end
end
