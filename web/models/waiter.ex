defmodule Sas.Waiter do
  use Sas.Web, :model

  schema "waiter" do
    belongs_to :user, Sas.User
    belongs_to :order, Sas.Order
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> validate_required([])
  end
end
