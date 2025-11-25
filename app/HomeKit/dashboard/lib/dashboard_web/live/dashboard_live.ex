defmodule DashboardWeb.DashboardLive do
  use DashboardWeb, :live_view

  alias Dashboard.InternalApi.DataAnalysis

  import Dashboard.InternalApi.DataAnalysis
  import DashboardWeb.DataAnalysisComponents
end
