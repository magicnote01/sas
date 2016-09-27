defmodule Sas.Repo.Migrations.AlterOrder do
  use Ecto.Migration

  def change do
    drop index(:orders, [:inserted_at])

    alter table(:orders) do
      remove :user_order_id
      remove :user_serve_id
      remove :user_money_id
    end
  end
end
