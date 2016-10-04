defmodule Sas.Repo.Migrations.CreateOrderMasterSession do
  use Ecto.Migration

  def change do
    create table(:order_master_sessions) do
      add :total_money, :integer
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    alter table(:transactions) do
      add :order_master_session_id, references(:order_master_sessions, on_delete: :nothing)
    end

    create index(:order_master_sessions, [:user_id])
    create index(:transactions, [:order_master_session_id])
  end
end
