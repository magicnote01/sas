defmodule Sas.DeliveryOrder do
  use Sas.Web, :model

  schema "delivery_orders" do
    field :status, :string
    field :type, :string
    belongs_to :order, Sas.Order
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
    |> cast(params, [:table_id, :status])
    |> validate_required([:table_id, :status])
  end

  def changeset_put_line_order(changeset, line_order) do
    changeset
    |> put_assoc(:line_orders, line_order)
  end

  def changeset_submit_delivery_order(struct) do
    struct
    |> change
    |> put_change(:status, Sas.Order.status_submit)
  end

  def changeset_add_distributor(struct, params) do
    struct
    |> cast(params, [:distributor_id])
    |> validate_required([:distributor_id])
    |> put_change(:status, Sas.Order.status_in_process)
  end

  def changeset_add_waiter(struct, params \\ %{}) do
    struct
    |> cast(params, [:waiter_id])
    |> validate_required([:waiter_id])
    |> put_change(:status, Sas.Order.status_delivering)
  end

  def changeset_complete_delivery_order(struct) do
    struct
    |> change
    |> put_change(:status, Sas.Order.status_complete)
  end

  def type_bar() do
    "Bar"
  end
  def type_non_bar() do
    "Non-Bar"
  end
end
