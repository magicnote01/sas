defmodule Sas.Repo.Migrations.AlterOrder do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :distributor_id, references(:users, on_delete: :nothing)
      add :waiter_id, references(:users, on_delete: :nothing)
      add :cashier_id, references(:users, on_delete: :nothing)
    end
  end
end
