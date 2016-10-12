defmodule Sas.OrderMasterSessionController do
  use Sas.Web, :controller

  alias Sas.OrderMasterSession

  def index(conn, _params) do
    order_master_sessions =
      Repo.all(OrderMasterSession)
      |> Repo.preload(:user)
    render(conn, "index.html", order_master_sessions: order_master_sessions)
  end

  def new(conn, _params) do
    changeset = OrderMasterSession.changeset(%OrderMasterSession{})
    order_masters = get_order_masters

    render(conn, "new.html", changeset: changeset, order_masters: get_order_masters)
  end

  def get_order_masters() do
    role_order_master = Sas.User.order_master
    q = from u in Sas.User,
    where: u.role == ^role_order_master,
    select: {u.name, u.id}
    Repo.all(q)
  end

  def get_latest_order_master_session(user) do
    q = from o in OrderMasterSession,
    where: o.user_id == ^user.id and o.status == ^"Open",
    select: o
    order_master_sessions = Repo.all(q)
    Enum.sort(order_master_sessions, &(Timex.diff(&1.inserted_at, &2.inserted_at) > 0 ) )
    |> Enum.take(1)
  end

  def create(conn, %{"order_master_session" => order_master_session_params}) do
    changeset = OrderMasterSession.changeset(%OrderMasterSession{}, order_master_session_params)

    case Repo.insert(changeset) do
      {:ok, _order_master_session} ->
        conn
        |> put_flash(:info, "Order master session created successfully.")
        |> redirect(to: order_master_session_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, order_masters: get_order_masters)
    end
  end

  def show(conn, %{"id" => id}) do
    order_master_session = Repo.get!(OrderMasterSession, id)
    |> Repo.preload(:user)
    |> Repo.preload([:transactions, transactions: [:table, :order]])

    render(conn, "show.html", order_master_session: order_master_session)
  end

  def close(conn, %{"id" => id}) do
    order_master_session = Repo.get!(OrderMasterSession, id)
    changeset = OrderMasterSession.changeset_close_session(order_master_session)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Session updated successfully.")
        |> redirect(to: order_master_session_path(conn, :index))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something wrong!")
        |> redirect(to: order_master_session_path(conn, :index))
    end
  end
end
