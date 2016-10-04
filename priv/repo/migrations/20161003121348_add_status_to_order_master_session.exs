defmodule Sas.Repo.Migrations.AddStatusToOrderMasterSession do
  use Ecto.Migration

  def change do
    alter table(:order_master_sessions) do
      add :status, :string
    end
  end
end
