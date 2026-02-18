defmodule Dashboard.Workspace do
  def config do
    Application.get_env(:dashboard, __MODULE__, %{})
  end

  def workspace_root do
    config()[:workspace_root]
  end

  def data_analysis_root do
    config()[:data_analysis_root]
  end

  def plots_root do
    config()[:plots_root]
  end
end
