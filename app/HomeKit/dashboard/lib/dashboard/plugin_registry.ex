defmodule Dashboard.PluginRegistry do 
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def register(name, module, path, pid \\ nil) do
    static_path = Path.join(path, "priv/static/assets")
    Agent.update(__MODULE__, &Map.put(&1, name,
                              %{module: module,
                                path: path,
                                static_path: static_path,
                                pid: pid,
                                status: if(pid, do: :enabled, else: :disabled)}))
  end

  def update(name, fun) do
    Agent.update(__MODULE__, fn plugins ->
      Map.update!(plugins, name, fun)
    end)
  end

  def summary do
    {:ok, configs} = Dashboard.PluginConfig.load_configs()
    loaded_plugins = __MODULE__.list()

    Enum.reduce(configs, %{enabled: 0, disabled: 0, errors: 0}, fn config, acc ->
      atom = String.to_atom(config["atom"])
      case Map.get(loaded_plugins, atom) do
        nil ->
          if config["enabled"], do: %{acc | errors: acc.errors + 1}, else: %{acc | disabled: acc.disabled + 1}
        %{pid: pid} ->
          cond do
          pid == nil -> %{acc | disabled: acc.disabled + 1}
          Process.alive?(pid) -> %{acc | enabled: acc.enabled + 1}
          true -> %{acc | errors: acc.errors + 1}
        end
      end
    end)
  end

  def unregister(name) do
    Agent.update(__MODULE__, &Map.delete(&1, name))
  end

  def get(name), do: Agent.get(__MODULE__, &Map.get(&1, name))
  def list(), do: Agent.get(__MODULE__, & &1)
end


