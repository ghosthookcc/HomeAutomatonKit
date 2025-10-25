defmodule DashboardWeb.Index do
  use DashboardWeb, :live_view

  def render(assigns) do
    ~H"""
      <h1>Welcome to the Dashboard</h1>
      <p>This app runs entirely in LiveView 🚀</p>
    """
  end
end
