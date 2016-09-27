defmodule Sas.WaiterTest do
  use Sas.ModelCase

  alias Sas.Waiter

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Waiter.changeset(%Waiter{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Waiter.changeset(%Waiter{}, @invalid_attrs)
    refute changeset.valid?
  end
end
