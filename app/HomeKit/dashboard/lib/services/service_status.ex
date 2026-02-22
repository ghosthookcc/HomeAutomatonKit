defmodule Dashboard.Services.ServiceStatus do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "service_status" do
    field :status, Ecto.Enum,
      values: [:unknown,
               :alive, :dead,
               :connecting, :disconnecting, :reconnecting, 
               :error],
      default: :unknown
    field :last_updated, :utc_datetime
    belongs_to :service, Dashboard.Services.Service,
                foreign_key: :service_id,
                type: :binary_id
    timestamps()
  end

  def changeset(status, attrs) do
    status
    |> cast(attrs, [:service_id, :status, :last_updated])
    |> validate_required([:service_id, :status, :last_updated])
    |> unique_constraint(:service_id)
  end
end
