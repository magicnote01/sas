defmodule Sas.TableSessionController do
  use Sas.Web, :controller

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, params) when params == %{} do
    conn
    |> render("new.html")
  end

  def create(conn, %{"name" => name, "password" => pass}) do
    case Sas.TableAuth.table_login_by_name_and_pass(conn, name, pass, repo: Repo) do
      {:ok, conn} ->
        conn
        |> redirect(to: order_path(conn, :table_index))
      {:error, _reason, conn} ->
        conn
        |> render("new.html")
    end
  end

  def create(conn, %{"table_session" => map}) do
    create(conn, map)
  end
end
