defmodule DashboardWeb.DataAnalysisComponents do
  use Phoenix.Component
  use Phoenix.LiveView

  alias Dashboard.InternalApi.DataAnalysis
  import Phoenix.LiveView
  import Phoenix.Component

  def plot(assigns) do
    ~H"""
    <div>
      <img src={@plot.url} />
      <p>Updated: <%= @plot.timestamp %></p>
    </div>
    """
  end

  defmodule AutoPlotLive do
    use Phoenix.LiveView

    @tick :timer.seconds(5)

    def mount(_params, _session, socket) do
      if connected?(socket), do: schedule_tick()

      plot = DataAnalysis.generateDataPlot()
      {:ok, assign(socket, :plot, plot)}
    end

    def handle_tick(:tick, socket) do
      schedule_tick()
      {:noreply, assign(socket, :plot, DataAnalysis.generateDataPlot())}
    end

    defp schedule_tick, do: Process.send_after(self(), :tick, @tick)

    def render(assigns) do
      ~H"""
      <DashboardWeb.DataAnalysisComponents.plot plot={@plot} />
      """
    end
  end
end
