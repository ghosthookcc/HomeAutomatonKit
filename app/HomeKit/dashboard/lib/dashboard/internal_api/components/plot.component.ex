defmodule DashboardWeb.DataAnalysisComponents do
  use Phoenix.Component

  alias Dashboard.InternalApi.DataAnalysis
  import Phoenix.Component

  def plot(assigns) do
    ~H"""
    <div class="relative">
      <img src={@plot.url}
           class="block shadow" />
      <p class="absolute
                top-0 left-0
                w-full bg-black/80 text-white
                px-3 py-1 text-sm">
        Updated: <%= @plot.timestamp %>
      </p>
    </div>
    """
  end
end
