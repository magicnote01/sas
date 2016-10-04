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

    case role do
      ^admin -> link @home, to: page_path(conn, :admin_index)
      ^distributor -> link @home, to: order_path(conn, :distributor)
      ^waiter -> link @home, to: order_path(conn, :waiter)
      ^cashier -> link @home, to: order_master_session_path(conn, :index)
      ^order_master -> link @home, to: order_path(conn, :order_master)
    end

  end
end
