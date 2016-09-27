defmodule Sas.Repo.Migrations.CreateWaiter do
  use Ecto.Migration

  def change do
    create table(:waiter) do
      add :user_id, references(:users, on_delete: :nothing)
      add :order_id, references(:orders, on_delete: :nothing)
    end
    create index(:waiter, [:user_id])
    create index(:waiter, [:order_id])

  end
end
