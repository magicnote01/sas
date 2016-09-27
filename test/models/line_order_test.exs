defmodule Sas.LineOrderTest do
  use Sas.ModelCase

  alias Sas.LineOrder

  @valid_attrs %{quantity: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = LineOrder.changeset(%LineOrder{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = LineOrder.changeset(%LineOrder{}, @invalid_attrs)
    refute changeset.valid?
  end
end
