defmodule Sas.Transaction do
  use Sas.Web, :model

  schema "transactions" do
    field :total, Money.Ecto.Type
    field :received_money, Money.Ecto.Type
    field :change, Money.Ecto.Type
    belongs_to :order, Sas.Order
    belongs_to :user, Sas.User
    belongs_to :table, Sas.Table
    belongs_to :order_master_session, Sas.OrderMasterSession

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:received_money])
    |> validate_required([:received_money])
    |> calculate_change
    |> prepare_changes(fn changeset ->
      assoc(%Sas.Transaction{order_master_session_id: changeset.data.order_master_session_id}, :order_master_session)
      |> changeset.repo.update_all(inc: [total_money: changeset.data.total ])
      changeset
    end)
  end

  defp calculate_change(changeset) do
    case changeset do
      %Ecto.Changeset{data: %{total: total}, changes: %{received_money: received_money}} ->
        change = Money.subtract(received_money, total)
        if Money.negative?(change) do
          add_error(changeset, :received_money, "Received money must be greater than total money")
        else
          put_change(changeset, :change, change)
        end
      _ -> changeset
    end
  end
end
