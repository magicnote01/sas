defmodule Sas.Repo.Migrations.CreateProduct do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :price, :integer
      add :quantity, :integer

      timestamps()
    end
    create unique_index(:products, [:name])
  end
end
