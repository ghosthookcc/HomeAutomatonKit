defmodule Dashboard.Services.ImportOnStart do
  use GenServer
  alias Dashboard.Services.ImportJSON

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    Task.start(fn -> ImportJSON.import_services() end)
    {:ok, %{}}
  end
end
