defmodule Sas.Repo.Migrations.AlterOrderAddType do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :type, :string
    end
  end
end
