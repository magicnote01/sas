defmodule Sas.Auth do
  import Plug.Conn
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  import Phoenix.Controller
  import Ecto.Query
  alias Sas.Router.Helpers

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    user_id = get_session(conn, :user_id)

    cond do
      user = conn.assigns[:current_user] ->
        put_current_user(conn,user)
      user = user_id && repo.get(Sas.User, user_id) ->
        put_current_user(conn,user)
      true ->
        assign(conn, :current_user, nil)
    end
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  defp put_current_user(conn, user) do
    token = Phoenix.Token.sign(conn, "user socket", user.id)

    conn
    |> assign(:current_user, user)
    |> assign(:user_token, token)
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end

  def login_by_name_and_pass(conn, name, given_pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(Sas.User, name: name)

    cond do
      user && checkpw(given_pass, user.password_hash) ->
        {:ok, login(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        dummy_checkpw()
        {:error, :not_found, conn}
    end
  end

  def authenticate_user(conn, opts) do
    role = Keyword.fetch!(opts, :role)
    user = conn.assigns.current_user
    if user && String.starts_with?(user.role, role) do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Helpers.session_path(conn, :new))
      |> halt()
    end
  end

  def confirm_order_master_session(conn, _opts) do
    user = conn.assigns.current_user
    order_master_sessions = Sas.OrderMasterSessionController.get_latest_order_master_session(user)

    case Enum.fetch(order_master_sessions,0) do
      {:ok, order_master_session} ->
        conn
        |> assign(:current_order_master_session, order_master_session)
      :error ->
        conn
        |> put_flash(:error, "Please wait for cashier to create session for you")
        |> redirect(to: Helpers.order_path(conn, :order_master))
        |> halt()
    end
  end
end
