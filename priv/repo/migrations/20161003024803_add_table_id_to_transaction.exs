defmodule Sas.Repo.Migrations.AddTableIdToTransaction do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add :table_id, references(:orders, on_delete: :nothing)
    end
    create index(:transactions, [:table_id])
  end
end
