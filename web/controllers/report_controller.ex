defmodule Sas.ReportController do
  use Sas.Web, :controller

  alias Sas.DeliveryOrder
  alias Sas.Transaction
  alias Sas.LineOrder
  alias Sas.Product
  alias Sas.Table
  alias Sas.Order
  alias Sas.User

  #Orders Summary
  def orders_summary(conn, page) when page == %{} do
    orders_summary(conn, %{"page" => 0})
  end

  def orders_summary(conn, %{"page" => page}) do
    count = Repo.aggregate(Order, :count, :id)
    orders = orders_summary_query_results(page)

    render(conn, "orders_summary.html", orders: orders, count: count)
  end

  def orders_summary_query_results(page \\ 0) do
    q = from o in Order,
        order_by: o.id,
        limit: 20,
        offset: ^page,
        preload: [:order_master, :table]
    Repo.all(q)
  end

  #Orders by Table
  def orders_by_table(conn, _opts) do

  end

  def show_order(conn, %{"id" => id}) do

  end

  #Top Spenders
  def top_spenders(conn, _opts) do

  end

  #Product Sale
  def product_sale(conn, _opts) do

  end

  #Delivery Summary
  def delivery_summary(conn, _opts) do

  end

  #Search By Bill No.
  def search(conn, _opts) do
    # show search
  end
end
