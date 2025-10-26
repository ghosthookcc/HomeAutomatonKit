defmodule Dashboard.PluginConfig do
  @plugins_config_file Path.join(File.cwd!, "priv/plugins/plugins.json")

  def load_configs do
    case File.read(@plugins_config_file) do
      {:ok, content} -> 
        {:ok, Jason.decode!(content)}
      {:error, _} -> 
        {:ok, []}
    end
  end

  def update_config(atomName, newEnabledState) do
    {:ok, configs} = load_configs()

    new_configs = 
      Enum.map(configs, fn cfg -> 
        if cfg["atom"] == atomName do
          Map.put(cfg, "enabled", newEnabledState)
        else
          cfg
        end
      end)
    save_configs(new_configs)
    {:ok, new_configs}
  end

  def save_configs(configs) when is_list(configs) do
    File.write!(@plugins_config_file, Jason.encode!(configs, pretty: true))
  end
end
