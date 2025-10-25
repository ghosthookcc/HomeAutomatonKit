defmodule BackupPlugin.Supervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      BackupPlugin.Worker
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
