defmodule Sas.User do
  use Sas.Web, :model

  @admin "Admin"
  @distributor "Distributor"
  @waiter "Waiter"
  @cashier "Cashier"

  schema "users" do
    field :name, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :role, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :password, :role])
    |> validate_required([:name, :password, :role])
    |> validate_inclusion(:role, roles, [message: "Please choose a role"])
  end

  def registration_changeset(model, params) do
    model
    |> changeset(params)
    |> cast(params, [:password])
    |> put_pass_hash()
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} -> put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ -> changeset
    end
  end

  def admin, do: @admin
  def distributor, do: @distributor
  def waiter, do: @waiter
  def cashier, do: @cashier

  def roles do
     [@admin, @distributor, @waiter, @cashier]
  end
end
