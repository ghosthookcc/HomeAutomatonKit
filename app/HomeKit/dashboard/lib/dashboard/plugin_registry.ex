defmodule Dashboard.PluginRegistry do 
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def register(name, module, path, pid \\ nil, opts \\ []) do
    endpoint = Keyword.get(opts, :endpoint)
    static_path = Path.join(path, "priv/static/assets")
    Agent.update(__MODULE__, &Map.put(&1, name,
                              %{module: module,
                                path: path,
                                static_path: static_path,
                                pid: pid,
                                endpoint: endpoint}))
  end

  def unregister(name) do
    Agent.update(__MODULE__, &Map.delete(&1, name))
  end

  def get(name), do: Agent.get(__MODULE__, &Map.get(&1, name))
  def list(), do: Agent.get(__MODULE__, & &1)
end


