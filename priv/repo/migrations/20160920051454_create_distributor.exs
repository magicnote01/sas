defmodule Sas.Repo.Migrations.CreateDistributor do
  use Ecto.Migration

  def change do
    create table(:distributors) do
      add :user_id, references(:users, on_delete: :nothing)
      add :order_id, references(:orders, on_delete: :nothing)
    end
    create index(:distributors, [:user_id])
    create index(:distributors, [:order_id])

  end
end
