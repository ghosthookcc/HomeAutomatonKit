defmodule Dashboard.Repo.Migrations.CreateServiceStatus do
  use Ecto.Migration

  def change do
    create table(:service_status, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :service_id, :binary_id, null: false
      add :status, :string, default: "unknown", null: false
      add :last_updated, :utc_datetime, null: true

      timestamps()
    end

    create unique_index(:service_status, [:service_id])
  end
end
