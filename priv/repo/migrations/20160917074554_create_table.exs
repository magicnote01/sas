defmodule Sas.Repo.Migrations.CreateTable do
  use Ecto.Migration

  def change do
    create table(:tables) do
      add :name, :string
      add :password, :string

      timestamps()
    end
    create unique_index(:tables, [:name])
  end
end
