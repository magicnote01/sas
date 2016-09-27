defmodule Sas.Repo.Migrations.AddProductIdToLineorders do
  use Ecto.Migration

  def change do
    alter table(:lineorders) do
      add :product_id, references(:products, on_delete: :nothing)
    end

    create index(:lineorders, [:product_id])
  end
end
