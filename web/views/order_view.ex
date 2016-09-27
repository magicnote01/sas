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
    %{id: order.id,
      billNo: bill_no(order),
      status: order.status,
      total: Money.to_string(order.total),
      table: render_one(order.table, Sas.TableView, "table.json"),
      insertedAt: show_datetime(order.inserted_at),
      paymentMethod: order.payment_method,
      serviceCharge: Money.to_string(order.service_charge),
      distributor: render_one(order.distributor, Sas.UserView, "user.json"),
      cashier: render_one(order.cashier, Sas.UserView, "user.json"),
      waiter: render_one(order.waiter, Sas.UserView, "user.json")
      }
  end

  def render("order_detailed.json", %{order: order}) do
    line_orders = render_many(order.line_orders, Sas.LineOrderView, "line_order.json")
    render("order.json", %{order: order})
    |> Map.put(:lineOrders, line_orders)
  end

end
