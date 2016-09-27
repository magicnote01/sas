defmodule Sas.Product do
  use Sas.Web, :model

  schema "products" do
    field :name, :string
    field :price, Money.Ecto.Type
    field :quantity, :integer
    belongs_to :category, Sas.Category

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :price, :quantity, :category_id])
    |> validate_required([:name, :price, :quantity, :category_id])
  end
end
