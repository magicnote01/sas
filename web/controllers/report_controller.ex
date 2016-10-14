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
    orders_summary(conn, %{"page" => 1})
  end

  def orders_summary(conn, %{"page" => page}) do
    count = Repo.aggregate(Order, :count, :id)
    page = String.to_integer("#{page}") 
    orders = orders_summary_query_results(page)

    page_count =
      Float.ceil(count/20)
      |> trunc

    render(conn, "orders_summary.html", orders: orders, count: page_count, page: page)
  end

  def orders_summary_query_results(page \\ 0) do
    offset = (page - 1) * 20

    q = from o in Order,
        order_by: o.id,
        limit: 20,
        offset: ^offset,
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
