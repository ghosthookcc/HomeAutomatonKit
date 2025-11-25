defmodule Dashboard.InternalApi.DataAnalysis do 
  use DashboardWeb, :html
  use Phoenix.LiveComponent

  @refresh_rate :timer.seconds(10)

  def generateDataPlot() do
    # Implement later
  end

  def mount(_params, _session, socket) do
    if connected?(socket) do
      schedule_plot_update()
    end

    {:ok, assign(socket, time: DateTime.utc_now())}
  end

  def handle_plot_update(:tick, socket) do
    schedule_plot_update()
    {:noreply, assign(socket, time: DateTime.utc_now())}
  end

  defp schedule_plot_update() do
    Process.send_after(self(), :tick, @refresh_rate)
  end

  def plot(assigns) do
    ~H"""
    <img src="#"/>
    """
  end
end
