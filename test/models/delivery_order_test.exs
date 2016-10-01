defmodule Sas.DeliveryOrderTest do
  use Sas.ModelCase

  alias Sas.DeliveryOrder

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = DeliveryOrder.changeset(%DeliveryOrder{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = DeliveryOrder.changeset(%DeliveryOrder{}, @invalid_attrs)
    refute changeset.valid?
  end
end
