defmodule Sas.OrderChannel do
  use Sas.Web, :channel
  alias Sas.OrderView

  def join("orders:order_master", _params, socket) do
    {:ok, socket}
  end

  def join("orders:" <> order_id, _params, socket) do
    {:ok, socket}
  end

  def broadcast_new_order(order_id) do
    order =
      Repo.get!(Sas.Order, order_id)
      |> Repo.preload(:table)

    order_json = Phoenix.View.render(OrderView, "order.json", %{order: order})

    Sas.Endpoint.broadcast("orders:order_master", "new", %{order: order_json})
  end

  def broadcast_update_order(order_id) do
    order =
      Repo.get!(Sas.Order, order_id)
      |> Repo.preload(:table)

    order_json = Phoenix.View.render(OrderView, "order.json", %{order: order})

    Sas.Endpoint.broadcast("orders:" <> "#{order_id}", "update", %{order: order_json})
  end
end
