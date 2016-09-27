defmodule Sas.Category do
  use Sas.Web, :model

  schema "categories" do
    field :name, :string
    has_many :products, Sas.Product

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
