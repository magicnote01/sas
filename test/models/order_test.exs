defmodule Sas.OrderTest do
  use Sas.ModelCase

  alias Sas.Order

  @valid_attrs %{change: 42, payment_method: "some content", service_charge: 42, total: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Order.changeset(%Order{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Order.changeset(%Order{}, @invalid_attrs)
    refute changeset.valid?
  end
end
