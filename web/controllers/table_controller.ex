defmodule Sas.TableController do
  use Sas.Web, :controller

  alias Sas.Table

  def index(conn, _params) do
    tables = Repo.all(Table)
    render(conn, "index.html", tables: tables)
  end

  def order_master_table(conn, _params) do
    tables =
      Repo.all(Table)
      |> Enum.sort_by(&(&1.name))
    first_tables = Enum.take_every(tables, 2)
    second_tables = Enum.drop_every(tables, 2)
    render(conn, "order_master_table.html", first_tables: first_tables, second_tables: second_tables)
  end

  def new(conn, _params) do
    changeset = Table.changeset(%Table{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"table" => table_params}) do
    changeset = Table.changeset(%Table{}, table_params)

    case Repo.insert(changeset) do
      {:ok, _table} ->
        conn
        |> put_flash(:info, "Table created successfully.")
        |> redirect(to: table_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    table = Repo.get!(Table, id)
    render(conn, "show.html", table: table)
  end

  def edit(conn, %{"id" => id}) do
    table = Repo.get!(Table, id)
    changeset = Table.changeset(table)
    render(conn, "edit.html", table: table, changeset: changeset)
  end

  def update(conn, %{"id" => id, "table" => table_params}) do
    table = Repo.get!(Table, id)
    changeset = Table.changeset(table, table_params)

    case Repo.update(changeset) do
      {:ok, table} ->
        conn
        |> put_flash(:info, "Table updated successfully.")
        |> redirect(to: table_path(conn, :show, table))
      {:error, changeset} ->
        render(conn, "edit.html", table: table, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    table = Repo.get!(Table, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(table)

    conn
    |> put_flash(:info, "Table deleted successfully.")
    |> redirect(to: table_path(conn, :index))
  end
end
