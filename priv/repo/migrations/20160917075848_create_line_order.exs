defmodule Sas.Repo.Migrations.CreateLineOrder do
  use Ecto.Migration

  def change do
    create table(:lineorders) do
      add :quantity, :integer
      add :price, :integer
      add :product_id, references(:products, on_delete: :nothing)
      add :order_id, references(:orders, on_delete: :nothing)

      timestamps()
    end
    create index(:lineorders, [:product_id])
    create index(:lineorders, [:order_id])

  end
end
