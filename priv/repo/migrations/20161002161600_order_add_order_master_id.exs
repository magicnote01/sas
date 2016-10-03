defmodule Sas.Repo.Migrations.OrderAddOrderMasterId do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :order_master_id, references(:users, on_delete: :nothing)
    end
  end
end
