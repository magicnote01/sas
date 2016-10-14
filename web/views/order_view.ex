defmodule Sas.OrderView do
  use Sas.Web, :view
  use Timex

  def show_datetime(datetime) do
    Timezone.convert(datetime, "Asia/Bangkok")
    |> Timex.format!("{YYYY}-{0M}-{0D} {h24}:{m}")
  end

  def bill_no(order) do
    prefix = order.billprefix || ""
    prefix <> String.pad_leading("#{order.id}",5,"0")
  end

  def render("order.json", %{order: order}) do
    link =
      bill_no(order)
      |> link(to: order_path(Sas.Endpoint, :order_master_show_order, order))
      |> safe_to_string

    %{id: order.id,
      billNo: bill_no(order),
      link: link,
      status: order.status,
      total: Money.to_string(order.total),
      table: render_one(order.table, Sas.TableView, "table.json"),
      insertedAt: show_datetime(order.inserted_at),
      paymentMethod: order.payment_method,
      serviceCharge: Money.to_string(order.service_charge)
      }
  end

  def render("delivery_order.json", %{delivery_order: delivery_order}) do
    %{id: delivery_order.id,
      billNo: bill_no(delivery_order.order),
      insertedAt: show_datetime(delivery_order.inserted_at),
      table: render_one(delivery_order.table, Sas.TableView, "table.json"),
      type: delivery_order.type,
      status: delivery_order.status,
      distributor: render_one(delivery_order.distributor, Sas.UserView, "user.json"),
      waiter: render_one(delivery_order.waiter, Sas.UserView, "user.json")
      }
  end

end
