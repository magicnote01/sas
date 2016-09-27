defmodule Sas.OrderChannel do
  use Sas.Web, :channel
  alias Sas.OrderView

  def join("orders:distributor", _params, socket) do
    {:ok, socket}
  end

  def join("orders:waiter", _params, socket) do
    {:ok, socket}
  end

  def join("orders:cashier", _params, socket) do
    {:ok, socket}
  end

  def join("orders:" <> order_id, _params, socket) do
    {:ok, socket}
  end

  def broadcast_new_order(order_id) do
    order =
      Repo.get!(Sas.Order, order_id)
      |> Repo.preload(:table)
      |> Repo.preload(:line_orders)
      |> Repo.preload(:distributor)
      |> Repo.preload(:cashier)
      |> Repo.preload(:waiter)
    order_json = Phoenix.View.render(OrderView, "order_detailed.json", %{order: order})

    Sas.Endpoint.broadcast("orders:distributor", "new", %{order: order_json})
    Sas.Endpoint.broadcast("orders:waiter", "new", %{order: order_json})
    Sas.Endpoint.broadcast("orders:cashier", "new", %{order: order_json})
  end

  def broadcast_update_order(order_id) do
    order =
      Repo.get!(Sas.Order, order_id)
      |> Repo.preload(:table)
      |> Repo.preload(:distributor)
      |> Repo.preload(:cashier)
      |> Repo.preload(:waiter)
    order_json = Phoenix.View.render(OrderView, "order.json", %{order: order})

    Sas.Endpoint.broadcast("orders:" <> "#{order_id}", "update", %{order: order_json})
    Sas.Endpoint.broadcast("orders:distributor", "update", %{order: order_json})
    Sas.Endpoint.broadcast("orders:cashier", "update", %{order: order_json})
  end
end
