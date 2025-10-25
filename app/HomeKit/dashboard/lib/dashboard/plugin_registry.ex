defmodule Dashboard.PluginRegistry do 
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def add(name, module, path, pid \\ nil) do
    Agent.update(__MODULE__, &Map.put(&1, name, %{module: module, path: path, pid: pid}))
  end

  def remove(name) do
    Agent.update(__MODULE__, &Map.delete(&1, name))
  end 

  def get(name), do: Agent.get(__MODULE__, &Map.get(&1, name))
  def list(), do: Agent.get(__MODULE__, & &1)
end


