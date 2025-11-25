defmodule Dashboard.InternalApi.DataAnalysis do 
  def generateDataPlot() do
    now = DateTime.utc_now()
    %{ timestamp: now, url: "#" }
  end
end
