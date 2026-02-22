defmodule Dashboard.Services do
  import Ecto.Query
  alias Dashboard.Repo
  alias Dashboard.Services.{Service, ServiceStatus, ServiceRegistry}

  def summary do
    latest_status_query =
      from ss in ServiceStatus,
        group_by: ss.service_id,
        select: %{service_id: ss.service_id,
                  status: fragment("MAX(?) as status", ss.status),
                  last_updated: max(ss.last_updated)}

    statuses = Repo.all(latest_status_query)

    Enum.reduce(statuses, %{working: 0, idle: 0, disconnected: 0}, fn %{status: status}, acc ->
      status_atom = String.to_existing_atom(status)
      case status_atom do
        :alive -> %{acc | working: acc.working + 1}
        :unknown -> %{acc | idle: acc.idle + 1}
        :dead -> %{acc | disconnected: acc.disconnected + 1}
        :error -> %{acc | disconnected: acc.disconnected + 1}
        :connecting -> %{acc | idle: acc.idle + 1}
        :disconnecting -> %{acc | disconnected: acc.disconnected + 1}
        :reconnecting -> %{acc | working: acc.working + 1}
      end
    end)
  end
end
