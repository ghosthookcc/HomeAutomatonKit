defmodule DashboardWeb.DataAnalysisComponents do
  use Phoenix.Component

  alias Dashboard.InternalApi.DataAnalysis
  import Phoenix.Component

  def plot(assigns) do
    ~H"""
    <div>
      <img src={@plot.url} />
      <p>Updated: <%= @plot.timestamp %></p>
    </div>
    """
  end
end
