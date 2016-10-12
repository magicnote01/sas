defmodule Sas.OrderMasterSession do
  use Sas.Web, :model

  schema "order_master_sessions" do
    field :total_money, Money.Ecto.Type
    field :status, :string
    belongs_to :user, Sas.User
    has_many :transactions, Sas.Transaction

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:total_money, :user_id])
    |> validate_required([:total_money, :user_id])
    #|> checkActiveSession
    |> put_change(:status, "Open")
  end

  def changeset_close_session(struct) do
    struct
    |> change
    |> put_change(:status, "Close")
  end

  def checkActiveSession(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{user_id: user_id}} ->
        q = from o in Sas.OrderMasterSession,
            where: o.user_id == ^user_id and o.status == ^"Open",
            select: o
        order_master_sessions = Sas.Repo.all(q)
        if order_master_sessions != [] do
          add_error(changeset, :user_id, "This user already has active Order Master Session" )
        else
          changeset
        end
      _ -> changeset
    end
  end
end
