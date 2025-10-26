defmodule Dashboard.PluginLoader do
  alias Dashboard.{PluginRegistry, PluginSupervisor, PluginConfig}

  @plugins_dir Path.join(File.cwd!, "../plugins")
  def plugins_dir, do: @plugins_dir

  def load_plugin(name) do
    plugin_folder = Path.join(@plugins_dir, name)
    Mix.Task.run("compile", ["--force", "--quiet", "--elixirc-paths", plugin_folder <> "/lib"])

    plugin_eban_folder = Path.join([plugin_folder, "_build/dev/lib", name, "ebin"])
    :code.add_patha(String.to_charlist(plugin_eban_folder))

    {:ok, configs} = PluginConfig.load_configs()
    config = Enum.find(configs, &(&1["name"] == name))

    PluginConfig.update_config(config["atom"], true)

    type = config["type"]
    case type do
      "Process" ->
        IO.inspect("PROCESS")
        supervisor_module = Module.concat([config["module"], Supervisor])
        if Code.ensure_loaded?(supervisor_module) do
          pid = case PluginSupervisor.start_plugin({supervisor_module, []}) do
            {:ok, pid} ->
              pid
            {:error, {:already_started, pid}} ->
              pid
            {:error, reason} ->
              {:error, reason}
          end

          liveview = 
            if config["liveView"] do
              config["liveView"]
              |> String.split(".")
              |> Enum.map(&String.to_atom/1)
              |> Module.concat()
            else
              nil
            end

          PluginRegistry.register(String.to_atom(config["atom"]), liveview || supervisor_module, plugin_folder, pid)
          {:ok, pid}
        else
          {:error, :missing_supervisor}
        end
      "UI" -> 
        liveview =
          config["liveView"]
          |> String.split(".")
          |> Enum.map(&String.to_atom/1)
          |> Module.concat()
        PluginRegistry.register(String.to_atom(config["atom"]), liveview, plugin_folder, nil)
        {:ok, :ui_only}
      _ ->
        {:error, :unknown_type}
    end
  end

  def unload_plugin(atomName) do
    atom = String.to_atom(atomName)
    case PluginRegistry.get(atom) do
      nil -> {:error, :not_found}
      plugin ->
        if plugin.pid, do: PluginSupervisor.stop_plugin(plugin.pid)
        PluginRegistry.unregister(atom)
        PluginConfig.update_config(atomName, false)
        :ok
    end
  end
end
