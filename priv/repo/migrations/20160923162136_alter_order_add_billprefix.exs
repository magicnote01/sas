defmodule Sas.Repo.Migrations.AlterOrderAddBillprefix do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :billprefix, :string
    end
  end
end
