defmodule Sas.DeliveryOrderChannel do
  use Sas.Web, :channel
  alias Sas.OrderView

  def join("delivery_orders:distributor_bar", _params, socket) do
    {:ok, socket}
  end

  def join("delivery_orders:distributor_non-bar", _params, socket) do
    {:ok, socket}
  end

  def join("delivery_orders:" <> delivery_order_id, _params, socket) do
    {:ok, socket}
  end

  def broadcast_new_delivery_order_bar(delivery_order_id) do
    delivery_order =
      Repo.get!(Sas.DeliveryOrder, delivery_order_id)
      |> Repo.preload(:table)
      |> Repo.preload(:order)
      |> Repo.preload(:distributor)
      |> Repo.preload(:waiter)

    delivery_order_json = Phoenix.View.render(OrderView, "delivery_order.json", %{delivery_order: delivery_order})

    Sas.Endpoint.broadcast("delivery_orders:distributor_bar", "new", %{order: delivery_order_json})
  end

  def broadcast_new_delivery_order_non_bar(delivery_order_id) do
    delivery_order =
      Repo.get!(Sas.DeliveryOrder, delivery_order_id)
      |> Repo.preload(:table)
      |> Repo.preload(:order)
      |> Repo.preload(:distributor)
      |> Repo.preload(:waiter)

    delivery_order_json = Phoenix.View.render(OrderView, "delivery_order.json", %{delivery_order: delivery_order})

    Sas.Endpoint.broadcast("delivery_orders:distributor_non-bar", "new", %{order: delivery_order_json})
  end

  def broadcast_update_delivery_order(delivery_order_id) do
    delivery_order =
      Repo.get!(Sas.DeliveryOrder, delivery_order_id)
      |> Repo.preload(:table)
      |> Repo.preload(:order)
      |> Repo.preload(:distributor)
      |> Repo.preload(:waiter)

    delivery_order_json = Phoenix.View.render(OrderView, "delivery_order.json", %{delivery_order: delivery_order})

    Sas.Endpoint.broadcast("delivery_orders:#{delivery_order.id}", "update", %{order: delivery_order_json})
  end
end
