defmodule Sas.SessionController do
  use Sas.Web, :controller

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"name" => name, "password" => pass}}) do
    case Sas.Auth.login_by_name_and_pass(conn, name, pass, repo: Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> redirect_on_role
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid name/password combination")
        |> render("new.html")
    end
  end

  defp redirect_on_role(conn) do
    user = conn.assigns[:current_user]
    role = user.role

    admin = Sas.User.admin
    distributor = Sas.User.distributor
    waiter = Sas.User.waiter
    cashier = Sas.User.cashier
    order_master = Sas.User.order_master

    cond do
      role == admin ->
        conn
        |> redirect(to: page_path(conn, :admin_index))
      String.starts_with?(role, distributor) ->
        conn
        |> redirect(to: order_path(conn, :distributor))
      role == waiter ->
        conn
        |> redirect(to: order_path(conn, :waiter))
      role == cashier ->
        conn
        |> redirect(to: order_master_session_path(conn, :index))
      role == order_master ->
        conn
        |> redirect(to: order_path(conn, :order_master))
      true ->
        conn
        |> redirect(to: session_path(conn, :new))
    end

  end

  def delete(conn, _) do
    conn
    |> Sas.Auth.logout()
    |> redirect(to: page_path(conn, :index))
  end
end
