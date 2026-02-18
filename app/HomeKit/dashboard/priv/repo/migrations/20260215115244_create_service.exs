defmodule Dashboard.Repo.Migrations.CreateService do
  use Ecto.Migration

  def change do
    create table(:service, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :service_name, :string, null: false
      add :timeout_ms, :integer, null: false
      timestamps()
    end

    create unique_index(:service, [:service_name])
  end
end
