defmodule Sas.OrderMasterSessionTest do
  use Sas.ModelCase

  alias Sas.OrderMasterSession

  @valid_attrs %{total_money: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = OrderMasterSession.changeset(%OrderMasterSession{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = OrderMasterSession.changeset(%OrderMasterSession{}, @invalid_attrs)
    refute changeset.valid?
  end
end
