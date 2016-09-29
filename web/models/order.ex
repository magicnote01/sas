defmodule Sas.Order do
  use Sas.Web, :model

  @order_state %{
    new: "New",
    submit: "Submit",
    in_process: "In Process",
    delivering: "Delivering",
    complete: "Complete",
    close: "Close",
    cancel: "Cancel"
  }

  @prefix_table "T"
  @prefix_cashier "C"
  @prefix_manual "M"

  schema "orders" do
    field :billprefix, :string
    field :status, :string
    field :total, Money.Ecto.Type
    field :type, :string
    field :service_charge, Money.Ecto.Type
    field :change, Money.Ecto.Type
    field :payment_method, :string
    belongs_to :table, Sas.Table
    has_many :line_orders, Sas.LineOrder
    belongs_to :distributor, Sas.User, foreign_key: :distributor_id
    belongs_to :cashier, Sas.User, foreign_key: :cashier_id
    belongs_to :waiter, Sas.User, foreign_key: :waiter_id
    field :note, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:billprefix, :payment_method, :status, :table_id])
    |> validate_required([:payment_method])
    |> cast_assoc(:line_orders, required: true)
    |> validate_inclusion(:billprefix, [@prefix_table, @prefix_cashier, @prefix_manual])
    |> calculate_total_service_charge
  end

  def changeset_move_to_next_state(struct) do
    struct
    |> change
    |> move_to_next_state
  end

  def changeset_submit_to_in_process(struct, params) do
    struct
    |> cast(params, [:distributor_id])
    |> validate_required([:distributor_id])
    |> move_to_next_state
    |> validate_inclusion(:status, [@order_state.in_process])
  end

  def changeset_in_process_to_delivering(struct, params \\ %{}) do
    struct
    |> cast(params, [:waiter_id])
    |> validate_required([:waiter_id])
    |> move_to_next_state
    |> validate_inclusion(:status, [@order_state.delivering])
  end

  def changeset_delivering_to_complete(struct, params \\ %{}) do
    struct
    |> change
    |> move_to_next_state
    |> validate_inclusion(:status, [@order_state.complete])
  end

  def changeset_complete_to_close(struct, params) do
    struct
    |> cast(params, [:cashier_id, :change])
    |> validate_required([:cashier_id])
    |> move_to_next_state
    |> validate_inclusion(:status, [@order_state.close])
  end

  def changeset_cancel_order(struct) do
    struct
    |> change
  end

  def status_new() do
    @order_state.new
  end
  def status_submit() do
    @order_state.submit
  end
  def status_in_process() do
    @order_state.in_process
  end
  def status_delivering() do
    @order_state.delivering
  end
  def status_complete() do
    @order_state.complete
  end
  def status_close() do
    @order_state.close
  end
  def status_cancel() do
    @order_state.cancel
  end
  def prefix_table() do
    @prefix_table
  end
  def prefix_cashier() do
    @prefix_cashier
  end
  def prefix_manual() do
    @prefix_manual
  end

  def payment_method() do
    ["Cash", "Credit Card"]
  end

  def next_state(state) do
    state_transition = %{
      @order_state.new => @order_state.submit,
      @order_state.submit => @order_state.in_process,
      @order_state.in_process => @order_state.delivering,
      @order_state.delivering => @order_state.complete,
      @order_state.complete => @order_state.close,
      @order_state.close => @order_state.close,
      @order_state.cancel => @order_state.cancel
    }
    Map.get(state_transition,state)
  end

  defp calculate_total_service_charge(changeset) do
    case changeset do
      %Ecto.Changeset{changes: %{line_orders: line_orders}} ->
        total =
          line_orders
          |> Enum.reduce( Money.new(0),
            fn (changeset, total) ->
              case changeset do
                %Ecto.Changeset{valid?: true, changes: %{quantity: quantity, price: price} } ->
                  line_price = Money.multiply(price,quantity)
                  Money.add(total, line_price)
                %Ecto.Changeset{valid?: true, data: %{price: price}, changes: %{quantity: quantity,} } ->
                  line_price = Money.multiply(price,quantity)
                  Money.add(total, line_price)
                %Ecto.Changeset{valid?: true} -> Money.add(total, Money.new(0))
              end
            end
            )
        service_charge = Money.multiply(total,0.1)
        total = Money.add(total, service_charge)
        put_change(changeset, :total, total)
        |> put_change(:service_charge, service_charge)
      _ -> changeset
    end
  end

  defp move_to_next_state(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, data: %{status: status}} ->
        new_status = next_state(status)
        put_change(changeset, :status, new_status)
      _ -> changeset
    end
  end
end
