defmodule Sas.LayoutView do
  use Sas.Web, :view

  @home "Home"

  def staff_header(conn) do
    if Map.get(conn.assigns, :current_user) do
      render(__MODULE__ , "staff_header.html", current_user: conn.assigns.current_user, conn: conn)
    else
      ""
    end
  end

  def home_page_on_role(conn, role) do
    admin = Sas.User.admin
    distributor = Sas.User.distributor
    waiter = Sas.User.waiter
    cashier = Sas.User.cashier
    order_master = Sas.User.order_master

    cond do
      role == admin -> link @home, to: page_path(conn, :admin_index)
      String.starts_with?(role, distributor) -> link @home, to: order_path(conn, :distributor)
      role == waiter -> link @home, to: order_path(conn, :waiter)
      role == cashier -> link @home, to: order_master_session_path(conn, :index)
      role == order_master -> link @home, to: order_path(conn, :order_master)
      true -> ""
    end

  end
end
