defmodule Dashboard.Services.Service do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id

  schema "service" do
    field :service_name, :string
    field :timeout_ms, :integer
    has_many :statuses, Dashboard.Services.ServiceStatus, foreign_key: :service_id
    timestamps()
  end

  def changeset(service, attrs) do
    service
    |> cast(attrs, [:id, :service_name, :timeout_ms])
    |> validate_required([:id, :service_name, :timeout_ms])
    |> unique_constraint(:service_name)
  end
end
