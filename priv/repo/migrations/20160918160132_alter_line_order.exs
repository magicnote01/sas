defmodule Sas.Repo.Migrations.AlterLineOrder do
  use Ecto.Migration

  def change do
    drop index(:lineorders, [:product_id] )
    alter table(:lineorders) do
      add :name, :string
      remove :product_id

    end
  end
end
