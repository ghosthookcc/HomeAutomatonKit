defmodule DashboardWeb.DashboardLive do
  use DashboardWeb, :live_view

  alias Dashboard.InternalApi.DataAnalysis
  alias Dashboard.PluginRegistry
  alias Dashboard.Services

  import DashboardWeb.DataAnalysisComponents

  def mount(_params, _session, socket) do
    if connected?(socket), do: :timer.send_interval(5000, self(), :refresh)

    {:ok, assign(socket,
                        plugin_stats: PluginRegistry.summary(),
                        service_stats: Services.summary())}
  end

  def handle_info(:refresh, socket) do
    {:noreply, assign(socket,
                             plugin_stats: PluginRegistry.summary(),
                             service_stats: Services.summary())}
  end
end
