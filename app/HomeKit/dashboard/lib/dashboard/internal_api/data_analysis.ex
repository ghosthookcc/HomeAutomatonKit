defmodule Dashboard.InternalApi.DataAnalysis do 
  alias Dashboard.Workspace

  def generateDataPlot() do
    jit_runner      = Path.join(Workspace.data_analysis_root(), "JIT.R")
    plotting_script = Path.join(Workspace.data_analysis_root(), "plot.R")
    plot_path       = Path.join(Workspace.plots_root(), "plot.png")

    {output, status} = 
      System.cmd("Rscript", [jit_runner, plotting_script, plot_path],  
                 stderr_to_stdout: true,
                 cd: Workspace.data_analysis_root())
    
    now = DateTime.utc_now()

    %{ timestamp: now, url: "/plots/plot.png" }
  end
end
