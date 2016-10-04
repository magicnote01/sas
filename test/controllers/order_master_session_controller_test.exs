defmodule Sas.OrderMasterSessionControllerTest do
  use Sas.ConnCase

  alias Sas.OrderMasterSession
  @valid_attrs %{total_money: 42}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, order_master_session_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing order master sessions"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, order_master_session_path(conn, :new)
    assert html_response(conn, 200) =~ "New order master session"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, order_master_session_path(conn, :create), order_master_session: @valid_attrs
    assert redirected_to(conn) == order_master_session_path(conn, :index)
    assert Repo.get_by(OrderMasterSession, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, order_master_session_path(conn, :create), order_master_session: @invalid_attrs
    assert html_response(conn, 200) =~ "New order master session"
  end

  test "shows chosen resource", %{conn: conn} do
    order_master_session = Repo.insert! %OrderMasterSession{}
    conn = get conn, order_master_session_path(conn, :show, order_master_session)
    assert html_response(conn, 200) =~ "Show order master session"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, order_master_session_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    order_master_session = Repo.insert! %OrderMasterSession{}
    conn = get conn, order_master_session_path(conn, :edit, order_master_session)
    assert html_response(conn, 200) =~ "Edit order master session"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    order_master_session = Repo.insert! %OrderMasterSession{}
    conn = put conn, order_master_session_path(conn, :update, order_master_session), order_master_session: @valid_attrs
    assert redirected_to(conn) == order_master_session_path(conn, :show, order_master_session)
    assert Repo.get_by(OrderMasterSession, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    order_master_session = Repo.insert! %OrderMasterSession{}
    conn = put conn, order_master_session_path(conn, :update, order_master_session), order_master_session: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit order master session"
  end

  test "deletes chosen resource", %{conn: conn} do
    order_master_session = Repo.insert! %OrderMasterSession{}
    conn = delete conn, order_master_session_path(conn, :delete, order_master_session)
    assert redirected_to(conn) == order_master_session_path(conn, :index)
    refute Repo.get(OrderMasterSession, order_master_session.id)
  end
end
