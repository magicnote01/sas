defmodule Sas.Table do
  use Sas.Web, :model

  schema "tables" do
    field :name, :string
    field :password, :string
    has_many :orders, Sas.Order

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :password])
    |> validate_required([:name, :password])
  end
end
