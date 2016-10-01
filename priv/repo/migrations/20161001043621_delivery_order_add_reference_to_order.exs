defmodule Sas.Repo.Migrations.DeliveryOrderAddReferenceToOrder do
  use Ecto.Migration

  def change do
    alter table(:delivery_orders) do
        add :order_id, references(:orders, on_delete: :nothing)
    end

    create index(:delivery_orders, [:order_id])
  end
end
