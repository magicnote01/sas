defmodule Sas.LineOrderView do
  use Sas.Web, :view

  def render("line_order.json", %{line_order: line_order}) do
    %{name: line_order.name,
      quantity: line_order.quantity,
      price: Money.to_string(line_order.price)}
  end
end
