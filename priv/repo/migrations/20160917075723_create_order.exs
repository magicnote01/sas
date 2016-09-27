defmodule Sas.Repo.Migrations.CreateOrder do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :status, :string
      add :total, :integer
      add :service_charge, :integer
      add :change, :integer
      add :payment_method, :string
      add :table_id, references(:tables, on_delete: :nothing)
      add :user_order_id, references(:users, on_delete: :nothing)
      add :user_serve_id, references(:users, on_delete: :nothing)
      add :user_money_id, references(:users, on_delete: :nothing)
      add :note, :string

      timestamps()
    end
    create index(:orders, [:table_id])
    create index(:orders, [:status])
    create index(:orders, [:inserted_at])

  end
end
