defmodule Sas.LineOrder do
  use Sas.Web, :model

  alias Sas.Product

  schema "lineorders" do
    field :quantity, :integer, default: 0
    field :price, Money.Ecto.Type
    field :name, :string
    field :category, :string, virtual: true
    belongs_to :order, Sas.Order
    belongs_to :product, Sas.Product

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:product_id, :quantity])
    |> put_product_name_and_price
    |> prepare_changes(fn changeset ->
      case changeset do
        %Ecto.Changeset{valid?: true, changes: %{quantity: quantity, product_id: product_id} } ->
          assoc(%Sas.LineOrder{product_id: product_id}, :product)
          |> changeset.repo.update_all(inc: [quantity: (changeset.data.quantity - changeset.changes.quantity)])
          changeset
        %Ecto.Changeset{valid?: true } ->
          assoc(changeset.data, :product)
          |> changeset.repo.update_all(inc: [quantity: (changeset.data.quantity - changeset.changes.quantity)])
          changeset
      end
    end )
  end

  defp put_product_name_and_price(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{product_id: product_id} } ->
        product = Sas.Repo.get(Product,product_id)
        put_change(changeset, :price, product.price)
        |> put_change(:name, product.name)
      _ -> changeset
    end
  end

  def line_order_for_display(%Sas.LineOrder{name: name, price: price, quantity: quantity }) do
    {name, price, quantity}
  end

end
