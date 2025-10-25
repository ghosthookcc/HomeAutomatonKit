defmodule BackupPlugin.Worker do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok), do: {:ok, %{}}

  def perform_backup do
    IO.puts("Backup running...")
    :timer.sleep(2000)
    IO.puts("Backup finished!")
  end
end
