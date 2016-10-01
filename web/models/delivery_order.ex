defmodule Sas.DeliveryOrder do
  use Sas.Web, :model

  schema "delivery_orders" do
    field :status, :string
    belongs_to :table, Sas.Table
    belongs_to :distributor, Sas.User, foreign_key: :distributor_id
    belongs_to :waiter, Sas.User, foreign_key: :waiter_id
    has_many :line_orders, Sas.LineOrder

    timestamps()
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
