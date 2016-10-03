defmodule Sas.Repo.Migrations.AlterDeliveryOrderAddType do
  use Ecto.Migration

  def change do
    alter table(:delivery_orders) do
        add :type, :string
    end
  end
end
