defmodule Sas.OrderController do
  use Sas.Web, :controller

  alias Sas.Order
  alias Sas.LineOrder
  alias Sas.Category
  alias Sas.Product
  alias Sas.Table
  alias Sas.User
  alias Sas.OrderChannel

  def index(conn, _params) do
    orders = Repo.all(
      from o in Order,
        where: not is_nil(o.table_id),
        select: o
    )
    |> Repo.preload(:table)
    |> Enum.sort_by(&(&1.inserted_at), &>=/2)
    render(conn, "index.html", orders: orders)
  end

  def table_index(conn, _params) do
    table = conn.assigns.current_table
    orders = Repo.all(
      from o in Order,
        where: o.table_id == ^table.id,
        select: o
    )
    |> Repo.preload(:table)
    |> Enum.sort_by(&(&1.inserted_at), &>=/2)
    render(conn, "table_index.html", orders: orders, table: table)
  end

  def table_new(conn, _params) do
    products = load_line_order_list_from_product
    changeset = Order.changeset(
      %Order{line_orders: products} )
    render(conn, "table_new.html", changeset: changeset)
  end

  def table_create(conn, %{"order" => order_params}) do
    status = Order.status_submit
    table = conn.assigns.current_table
    payment_method = Map.get(order_params, "payment_method")
    changeset = create_order_changeset(order_params, table, status, Order.prefix_table)

    cond do
      is_nil(changeset) ->
        conn
        |> put_flash(:info, "Please enter an order")
        |> redirect(to: order_path(conn, :table_new))
      is_nil(payment_method) ->
        conn
        |> put_flash(:info, "Please confirm the order and choose a payment method")
        |> render("table_summary.html", changeset: changeset, payment_method: Order.payment_method)
      true ->
        case Repo.insert(changeset) do
          {:ok, order} ->
            IO.puts inspect(order.id)
            OrderChannel.broadcast_new_order(order.id)
             conn
             |> put_flash(:info, "Order created successfully.")
             |> redirect(to: order_path(conn, :table_index))
          {:error, changeset} ->
            render(conn, "table_new.html", changeset: changeset)
        end
    end
  end

  def new(conn, _params) do
    products = load_line_order_list_from_product
    changeset = Order.changeset(
      %Order{line_orders: products} )
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"order" => order_params}) do
    table = load_table_bar
    status = Order.status_close
    payment_method = Map.get(order_params, "payment_method")
    changeset = create_order_changeset(order_params, table, status, Order.prefix_cashier)

    cond do
      is_nil(changeset) ->
        conn
        |> put_flash(:info, "Please enter an order")
        |> redirect(to: order_path(conn, :new))
      is_nil(payment_method) ->
        conn
        |> put_flash(:info, "Please confirm the order and choose a payment method")
        |> render("summary.html", changeset: changeset, payment_method: Order.payment_method)
      true ->
        case Repo.insert(changeset) do
          {:ok, order} ->
             conn
             |> put_flash(:info, "Order created successfully.")
             |> redirect(to: order_path(conn, :show, order))
          {:error, changeset} ->
            render(conn, "new.html", changeset: changeset)
        end
    end
  end

  defp create_order_changeset(order_params, table, status, billprefix) do
    line_orders_params =
    Map.get(order_params, "line_orders")
    |> remove_blank_from_line_orders_params

    if line_orders_params == %{} do
      nil
    else
      order =
        table
        |> build_assoc(:orders)
        |> Map.put(:status, status)
        |> Map.put(:billprefix, billprefix)

      order_params = Map.put(order_params, "line_orders", line_orders_params)
      Order.changeset(order, order_params)
    end
  end

  def show(conn, %{"id" => id}) do
    order = Repo.get!(Order, id)
      |> Repo.preload(:table)
      |> Repo.preload(:line_orders)
      |> Repo.preload(:distributor)
      |> Repo.preload(:cashier)
      |> Repo.preload(:waiter)
    render(conn, "show.html", order: order)
  end

  def table_show(conn, %{"id" => id}) do
    order = Repo.get!(Order, id)
      |> Repo.preload(:line_orders)
      |> Repo.preload(:table)
    render(conn, "table_show.html", order: order)
  end

  def edit(conn, %{"id" => id}) do
    order = Repo.get!(Order, id)
      |> Repo.preload(:table)
      |> Repo.preload(:line_orders)
      |> Repo.preload(:distributor)
      |> Repo.preload(:cashier)
      |> Repo.preload(:waiter)

    products = load_line_order_for_edit(order.line_orders)
    order = Map.put(order, :line_orders, products)
    changeset = Order.changeset(order)

    render(conn, "edit.html", changeset: changeset, order: order)
  end

  def update(conn, %{"id" => id, "order" => order_params}) do
    order = Repo.get!(Order, id)
      |> Repo.preload(:table)
      |> Repo.preload(:line_orders)
      |> Repo.preload(:distributor)
      |> Repo.preload(:cashier)
      |> Repo.preload(:waiter)

    changeset = Order.changeset(order, order_params)

    case Repo.update(changeset) do
      {:ok, _order} ->
        conn
        |> put_flash(:info, "Order updated successfully.")
        |> redirect(to: order_path(conn, :cashier))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Something wrong!")
        |> render("edit.html", changeset: changeset, order: order)
    end
  end

  def distributor(conn, _) do
    orders = distributor_get_orders
    render(conn, "distributor_list_order.html", orders: orders)
  end

  defp distributor_get_orders(distributor_id \\ nil) do
    [Order.status_submit, Order.status_in_process, Order.status_delivering]
    |> Enum.map( fn status ->
      q = from o in Order,
          select: o, preload: [:table, :distributor, :waiter],
          order_by: o.id
      q = if distributor_id do
        q |> where(status: ^status, distributor_id: ^distributor_id)
      else
        q |> where(status: ^status)
      end
      if status == Order.status_delivering do
        order = Repo.all(q)
        |> Enum.sort(&(&1.waiter.name < &2.waiter.name))
      else
        Repo.all(q)
      end
    end )
    |> Enum.flat_map(&(&1))
  end

  def distributor_take_order(conn, %{"id" => id}) do
    order = Repo.get!(Order, id)
    distributor = conn.assigns.current_user
    change = %{distributor_id: distributor.id}
    changeset = Order.changeset_submit_to_in_process(order, change)

    case Repo.update(changeset) do
      {:ok, order} ->
        OrderChannel.broadcast_update_order(order.id)
        conn
        |> put_flash(:info, "Order updated successfully.")
        |> redirect(to: order_path(conn, :distributor_show_order, order))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something wrong!")
        |> redirect(to: order_path(conn, :distributor))
    end
  end

  def distributor_active_order(conn, _) do
    distributor = conn.assigns.current_user
    orders = distributor_get_orders(distributor.id) |> Repo.preload(:line_orders)
    changesets = Enum.map(orders, &Order.changeset_in_process_to_delivering/1)
    waiters = load_waiters

    render(conn, "distributor_show_active_orders.html", waiters: waiters, changesets: changesets)
  end

  def distributor_show_order(conn, %{"id" => id})  do
    order = Repo.get!(Order, id)
    |> Repo.preload(:table)
    |> Repo.preload(:line_orders)
    waiters = load_waiters
    changeset = Order.changeset_in_process_to_delivering(order)

    render(conn, "distributor_show_order.html", order: order, waiters: waiters, changeset: changeset, have_waiter: false)
  end

  def distributor_update_order(conn, %{"id" => id, "order" => order_params}) do
    order = Repo.get!(Order, id)
    changeset = Order.changeset_in_process_to_delivering(order, order_params)

    case Repo.update(changeset) do
      {:ok, order} ->
        OrderChannel.broadcast_new_order(order.id)
        conn
        |> put_flash(:info, "Order updated successfully.")
        |> redirect(to: order_path(conn, :distributor))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something wrong!")
        |> redirect(to: order_path(conn, :distributor_show_order, order))
    end
  end

  def waiter(conn, _) do
    waiter = conn.assigns.current_user

    q = from o in Order,
        where: o.status == ^Order.status_delivering and o.waiter_id == ^waiter.id,
        select: o, preload: [:table, :line_orders, :distributor, :waiter]
    orders = Repo.all q

    render(conn, "waiter_list_order.html", orders: orders)
  end

  def waiter_complete_order(conn, %{"id" => id}) do
    order = Repo.get!(Order, id)

    changeset = Order.changeset_delivering_to_complete(order)
    case Repo.update(changeset) do
      {:ok, order} ->
        OrderChannel.broadcast_new_order(order.id)
        conn
        |> put_flash(:info, "Order updated successfully.")
        |> redirect(to: order_path(conn, :waiter))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something wrong!")
        |> redirect(to: order_path(conn, :waiter))
    end
  end

  def cashier(conn, _) do
    q = from o in Order,
        where: o.status == "Complete",
        select: o, preload: [:table, :waiter]
    orders = Repo.all q
    render(conn, "cashier_list_order.html", orders: orders)
  end

  def cashier_close_order(conn, %{"id" => id}) do
    order = Repo.get!(Order, id)
    cashier = conn.assigns.current_user

    changeset = Order.changeset_complete_to_close(order, %{"cashier_id" => cashier.id})
    case Repo.update(changeset) do
      {:ok, order} ->
        OrderChannel.broadcast_update_order(order.id)
        conn
        |> put_flash(:info, "Order updated successfully.")
        |> redirect(to: order_path(conn, :cashier))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something wrong!")
        |> redirect(to: order_path(conn, :cashier))
    end
  end

  def delete(conn, %{"id" => id}) do
    order = Repo.get!(Order, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(order)

    conn
    |> put_flash(:info, "Order deleted successfully.")
    |> redirect(to: order_path(conn, :index))
  end

  defp load_line_order_list_from_product() do
    q = from p in Product,
          join: c in Category, on: p.category_id == c.id,
          where: p.quantity > 0,
          select: {c.name, p.name, p.price, p.id}
    q
    |> Repo.all
    |> Enum.sort_by( fn {category_name, name,_price,_id} -> {category_name, name} end)
    |> Sas.ListState.map_state(
      fn ( {category_name,name,price,id}, acc ) ->
        {acc, category_name} =
          case {acc, category_name} do
            {^category_name, _} -> {acc, ""}
            {_, _} -> {category_name, category_name}
          end
        {%LineOrder{category: category_name, name: name, price: price, product_id: id}, acc}
      end, ""
      )
  end

  defp load_line_order_for_edit(lineorders) do
    product_id = Enum.map(lineorders, &(&1.product_id))
    q = from p in Product,
          join: c in Category, on: p.category_id == c.id,
          where: p.id in ^product_id,
          select: {p.id, c.name, p.name}
    q
    |> Repo.all
    |> Enum.sort_by( fn {_product_id, category_name, name} -> {category_name, name} end)
    |> Sas.ListState.map_state(
      fn ( {product_id, category_name, _name}, acc ) ->
        {acc, category_name} =
          case {acc, category_name} do
            {^category_name, _} -> {acc, ""}
            {_, _} -> {category_name, category_name}
          end
        line_order = Enum.find(lineorders, &(&1.product_id == product_id))
        { Map.put(line_order, :category, category_name), acc}
      end, "" )
  end

  defp remove_blank_from_line_orders_params(line_orders_params) do
    line_orders_params
    |> Enum.to_list
    |> Enum.filter(
      fn {_index, map} ->
        {intVal, _} =
          Map.get(map, "quantity")
          |> Integer.parse
        intVal > 0
      end)
    |> Sas.ListState.map_state(
      fn ({_index, map},acc) -> { {acc,map} , acc + 1 } end , 0)
    |> Enum.reduce( %{},
      fn ( {index,map} , acc ) -> Map.put(acc, "#{index}", map) end )
  end

  defp load_table_bar() do
    Repo.get_by!(Table, name: "bar")
  end

  defp load_waiters() do
    q = from u in User,
      where: u.role == ^User.waiter,
      select: {u.name, u.id}
    Repo.all q
  end
end
