defmodule Sas.DistributorTest do
  use Sas.ModelCase

  alias Sas.Distributor

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Distributor.changeset(%Distributor{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Distributor.changeset(%Distributor{}, @invalid_attrs)
    refute changeset.valid?
  end
end
