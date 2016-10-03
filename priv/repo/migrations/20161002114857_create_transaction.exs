defmodule Sas.Repo.Migrations.CreateTransaction do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :total, :integer
      add :received_money, :integer
      add :change, :integer
      add :order_id, references(:orders, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:transactions, [:order_id])
    create index(:transactions, [:user_id])

  end
end
