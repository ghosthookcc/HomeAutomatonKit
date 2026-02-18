defmodule Dashboard.Repo.Migrations.CreateServiceStatus do
  use Ecto.Migration

  def change do
    create table(:service_status, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :service_id, references(:service, type: :binary_id, on_delete: :delete_all), null: false
      add :status, :string, default: "unknown", null: false
      add :last_updated, :utc_datetime, null: true
      timestamps()
    end

    create unique_index(:service_status, [:service_id])
    create index(:service_status, [:status])
  end
end
