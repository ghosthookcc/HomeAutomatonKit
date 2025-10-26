defmodule DashboardWeb.RedirectController do
  use DashboardWeb, :controller

  alias Dashboard.PluginRegistry

  def show(_, %{"plugin" => plugin_name}) do
    case PluginRegistry.get(String.to_atom(plugin_name)) do
      nil ->
        :plugin_not_found
    end
  end

  def plugin_not_found(conn, _params) do
    conn
    |> put_flash(:info, "⚠️ Plugin not found or not available.")
    |> redirect(to: "/")
    |> halt()
  end
end
