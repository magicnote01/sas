defmodule Sas.TableAuth do
  import Plug.Conn
  import Phoenix.Controller
  alias Sas.Router.Helpers

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    table_id = get_session(conn, :table_id)

    cond do
      table = conn.assigns[:current_table] ->
        put_current_table(conn,table)
      table = table_id && repo.get(Sas.Table, table_id) ->
        put_current_table(conn,table)
      true ->
        assign(conn, :current_table, nil)
    end
  end

  defp login(conn, table) do
    conn
    |> assign(:current_table, table)
    |> put_session(:table_id, table.id)
    |> configure_session(renew: true)
  end

  defp put_current_table(conn, table) do
    conn
    |> assign(:current_table, table)
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end


  def table_login_by_name_and_pass(conn, name, pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    table = repo.get_by(Sas.Table, name: name)

    cond do
      table && table.password == pass ->
        {:ok, login(conn, table)}
      table ->
        {:error, :unauthorized, conn}
      true ->
        {:error, :not_found, conn}
    end
  end

  def authenticate_table(conn, _opts) do
    if conn.assigns.current_table do
      conn
    else
      conn
      |> redirect(to: Helpers.table_session_path(conn, :new))
      |> halt()
    end
  end
end
