defmodule Sas.Repo.Migrations.DeliveryOrderAddIndexUpdated do
  use Ecto.Migration

  def change do
    drop index(:delivery_orders, [:distributor_id])
    create index(:delivery_orders, [:updated_at]) 
  end
end
