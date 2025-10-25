defmodule DashboardWeb.PluginRouter do
  use DashboardWeb, :live_view
  alias Dashboard.PluginRegistry

  def mount(%{"plugin" => plugin_name}, _session, socket) do
    plugin = PluginRegistry.get(String.to_atom(plugin_name))

    case plugin do
      %{module: _module} ->
        # Render the plugin LiveView directly
        {:ok, push_navigate(socket, to: "/plugins/#{plugin_name}/render")}
      _ ->
        {:ok, assign(socket, error: "Plugin '#{plugin_name}' not found")}
    end
  end

  def handle_params(%{"plugin" => plugin_name}, _uri, socket) do
    plugin = PluginRegistry.get(String.to_atom(plugin_name))

    case plugin do
      %{module: module} ->
        # Mount the plugin LiveView dynamically
        {:noreply, live_render(socket, module, id: plugin_name)}
      _ ->
        {:noreply, assign(socket, error: "Plugin '#{plugin_name}' not found")}
    end
  end

  def render(assigns) do
    ~H"""
    <%= if @error do %>
      <h2><%= @error %></h2>
    <% end %>
    """
  end
end
