defmodule DashboardWeb.Index do
  use DashboardWeb, :live_view

  alias DashboardWeb.{DashboardLive, ServiceManagerLive, UsersLive, PluginsLive, TemplatesLive, SettingsLive}

  def mount(_params, _session, socket) do

    {:ok, assign(socket, page: "dashboard", disabled: false)}
  end

  def handle_params(%{"page" => page}, _uri, socket) do
    {:noreply,
     assign(socket,
       page: page,
       plugin_key: nil,
       plugin: nil
     )}
  end

  def handle_params(_, _uri, socket) do
    {:noreply,
     assign(socket,
       page: "index",
       plugin_key: nil,
       plugin: nil
     )}
  end

  defp sidebar_link_class(current, target) do
    base = "flex items-center p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700"
    if current == target do
      base <> " bg-gray-200 dark:bg-gray-700"
    else
      base
    end
  end
end
