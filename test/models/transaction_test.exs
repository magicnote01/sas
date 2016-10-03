defmodule Sas.TransactionTest do
  use Sas.ModelCase

  alias Sas.Transaction

  @valid_attrs %{change: 42, received_money: 42, total: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Transaction.changeset(%Transaction{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Transaction.changeset(%Transaction{}, @invalid_attrs)
    refute changeset.valid?
  end
end
