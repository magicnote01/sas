defmodule Sas.Repo.Migrations.CreateDeliveryOrder do
  use Ecto.Migration

  def change do
    create table(:delivery_orders) do
      add :status, :string
      add :table_id, references(:tables, on_delete: :nothing)
      add :distributor_id, references(:users, on_delete: :nothing)
      add :waiter_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    alter table(:lineorders) do
      add :delivery_order_id, references(:delivery_orders, on_delete: :nothing)
    end

    create index(:delivery_orders, [:status])
    create index(:delivery_orders, [:table_id])
    create index(:delivery_orders, [:distributor_id])
    create index(:delivery_orders, [:waiter_id])
    create index(:lineorders, [:delivery_order_id])

  end
end
