defmodule Sas.Repo.Migrations.CreateCashier do
  use Ecto.Migration

  def change do
    create table(:cashiers) do
      add :user_id, references(:users, on_delete: :nothing)
      add :order_id, references(:orders, on_delete: :nothing)
    end
    create index(:cashiers, [:user_id])
    create index(:cashiers, [:order_id])

  end
end
