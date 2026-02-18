defmodule Dashboard.Services.ImportJSON do
  alias Dashboard.Repo
  alias Dashboard.Services.Service
  alias Dashboard.Services.ServiceStatus

  @services_config_file Path.join(File.cwd!, "priv/services/services.json")

  def import_services do
    json = File.read!(@services_config_file) |> Jason.decode!()

    for svc <- json do
      service_uuid = Map.get(svc, "id") || Ecto.UUID.generate()

      {:ok, service} =
        Dashboard.Repo.insert(%Dashboard.Services.Service{ id: service_uuid,
                                                           service_name: svc["service_name"],
                                                           timeout_ms: svc["timeout_ms"] },
        on_conflict: {:replace, [:timeout_ms]},
        conflict_target: :service_name,
        returning: true)
      
      status_id =
      case Repo.get_by(Dashboard.Services.ServiceStatus, service_id: service.id) do
        nil -> Ecto.UUID.generate()
        existing -> existing.id
      end

      Dashboard.Repo.insert!(%Dashboard.Services.ServiceStatus{ id: status_id,
                                                                service_id: service.id,
                                                                status: :unknown,
                                                                last_updated: DateTime.utc_now() |> DateTime.truncate(:second) },
      on_conflict: {:replace, [:status, :last_updated]},
      conflict_target: :id)
    end
  end
end
