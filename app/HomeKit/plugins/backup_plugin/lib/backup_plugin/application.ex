defmodule BackupPlugin.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BackupPluginWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:backup_plugin, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: BackupPlugin.PubSub},

      BackupPluginWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: BackupPlugin.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    BackupPluginWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
