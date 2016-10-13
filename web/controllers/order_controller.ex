defmodule Sas.OrderController do
  use Sas.Web, :controller

  alias Sas.Order
  alias Sas.LineOrder
  alias Sas.Category
  alias Sas.Product
  alias Sas.Table
  alias Sas.User
  alias Sas.OrderChannel
  alias Sas.DeliveryOrder
  alias Sas.Transaction

  def index(conn, _params) do
    orders = Repo.all(
      from o in Order,
        where: not is_nil(o.table_id),
        select: o
    )
    |> Repo.preload(:table)
    |> Enum.sort_by(&(&1.id), &>=/2)
    render(conn, "index.html", orders: orders)
  end

  def table_index(conn, _params) do
    table = conn.assigns.current_table

    orders = Repo.all(
      from o in Order,
        where: o.table_id == ^table.id and o.status != ^Order.status_cancel,
        select: o
    )
    |> Enum.sort_by(&(&1.id), &>=/2)
    render(conn, "table_index.html", orders: orders, table: table)
  end

  def table_new(conn, _params) do
    products = load_line_order_list_from_product
    changeset = Order.changeset(
      %Order{line_orders: products} )
    render(conn, "table_new.html", changeset: changeset)
  end

  def table_create(conn, %{"order" => order_params}) do
    status = Order.status_waiting
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
        |> put_flash(:info, "Please confirm the order")
        |> render("table_summary.html", changeset: changeset, payment_method: Order.payment_method)
      true ->
        case Repo.insert(changeset) do
          {:ok, order} ->
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
        |> put_flash(:info, "Please confirm the order")
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

  defp create_delivery_order_changeset(line_orders, table, order, type) do
    if line_orders == [] do
      nil
    else
        %DeliveryOrder{}
        |> Map.put(:table_id, table.id)
        |> Map.put(:order_id, order.id)
        |> Map.put(:status, Order.status_submit)
        |> Map.put(:type, type)
        |> DeliveryOrder.changeset
        |> DeliveryOrder.changeset_put_line_order(line_orders)
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
    distributor = conn.assigns.current_user
    delivery_orders = distributor_get_orders(distributor)
    render(conn, "distributor_list_order.html", delivery_orders: delivery_orders)
  end

  defp distributor_get_orders(distributor) do
    distributor_bar = User.distributor_bar
    distributor_non_bar = User.distributor_non_bar

    order_type =
      case distributor.role do
        ^distributor_bar -> DeliveryOrder.type_bar()
        ^distributor_non_bar -> DeliveryOrder.type_non_bar()
        _ -> DeliveryOrder.type_non_bar()
      end

    [Order.status_submit, Order.status_in_process]
    |> Enum.map( fn status ->
      q = from o in DeliveryOrder,
          select: o, preload: [:table, :distributor, :waiter, :order],
          where: o.status == ^status and o.type == ^order_type,
          order_by: o.id
        Repo.all(q)
      end
      )
    |> Enum.flat_map(&(&1))
  end

  def distributor_take_order(conn, %{"id" => id}) do
    delivery_order = Repo.get!(DeliveryOrder, id)
    distributor = conn.assigns.current_user
    change = %{distributor_id: distributor.id}
    changeset = DeliveryOrder.changeset_add_distributor(delivery_order, change)

    case Repo.update(changeset) do
      {:ok, order} ->
        OrderChannel.broadcast_update_order(order.id)
        conn
        |> put_flash(:info, "Order updated successfully.")
        |> redirect(to: order_path(conn, :distributor_show_order, delivery_order))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something wrong!")
        |> redirect(to: order_path(conn, :distributor))
    end
  end

  def distributor_active_order(conn, _) do
    distributor = conn.assigns.current_user
    orders = distributor_get_orders(distributor) |> Repo.preload(:line_orders)
    changesets = Enum.map(orders, &DeliveryOrder.changeset_add_waiter/1)
    waiters = load_waiters

    render(conn, "distributor_show_active_orders.html", waiters: waiters, changesets: changesets)
  end

  def distributor_show_order(conn, %{"id" => id})  do
    delivery_order = Repo.get!(DeliveryOrder, id)
    |> Repo.preload(:table)
    |> Repo.preload(:line_orders)
    |> Repo.preload(:order)
    waiters = load_waiters
    changeset = DeliveryOrder.changeset_add_waiter(delivery_order)

    render(conn, "distributor_show_order.html", delivery_order: delivery_order, waiters: waiters, changeset: changeset, have_waiter: false)
  end

  def distributor_update_order(conn, %{"id" => id, "delivery_order" => delivery_order_params}) do
    delivery_order = Repo.get!(DeliveryOrder, id)
    changeset = DeliveryOrder.changeset_add_waiter(delivery_order, delivery_order_params)

    case Repo.update(changeset) do
      {:ok, order} ->
        OrderChannel.broadcast_new_order(order.id)
        conn
        |> put_flash(:info, "Order updated successfully.")
        |> redirect(to: order_path(conn, :distributor))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something wrong!")
        |> redirect(to: order_path(conn, :distributor_show_order, delivery_order))
    end
  end

  def distributor_recent_orders(conn, _) do
    distributor = conn.assigns.current_user

    distributor_bar = User.distributor_bar
    distributor_non_bar = User.distributor_non_bar

    order_type =
      case distributor.role do
        ^distributor_bar -> DeliveryOrder.type_bar()
        ^distributor_non_bar -> DeliveryOrder.type_non_bar()
        _ -> DeliveryOrder.type_non_bar()
      end

    q = from o in DeliveryOrder,
        where: o.status == ^Order.status_delivering and o.type == ^order_type,
        order_by: [desc: o.updated_at],
        limit: 20,
        select: o, preload: [:order, :table, :distributor, :waiter]
    delivery_orders = Repo.all q
    render(conn, "distributor_list_order.html", delivery_orders: delivery_orders)
  end

  def waiter(conn, _) do
    waiter = conn.assigns.current_user

    q = from o in DeliveryOrder,
        where: o.status == ^Order.status_delivering and o.waiter_id == ^waiter.id,
        order_by: [desc: o.updated_at],
        limit: 2,
        select: o, preload: [:order, :table, :line_orders, :distributor, :waiter]
    delivery_orders = Repo.all q

    render(conn, "waiter_list_order.html", delivery_orders: delivery_orders)
  end

  def waiter_all_order(conn, _) do
    waiter = conn.assigns.current_user

    q = from o in DeliveryOrder,
        where: o.status == ^Order.status_delivering and o.waiter_id == ^waiter.id,
        order_by: [desc: o.updated_at],
        select: o, preload: [:order, :table]
    delivery_order = Repo.all q

    render(conn, "waiter_all_order.html", delivery_orders: delivery_order)
  end

  def waiter_show_order(conn, %{"id" => id}) do
    delivery_order = Repo.get!(DeliveryOrder, id)
    |> Repo.preload(:table)
    |> Repo.preload(:line_orders)
    |> Repo.preload(:order)
    |> Repo.preload(:distributor)

    render(conn, "waiter_show_one_order.html", delivery_order: delivery_order)
  end

  def waiter_complete_order(conn, %{"id" => id}) do
    delivery_order = Repo.get!(DeliveryOrder, id)

    changeset = DeliveryOrder.changeset_complete_delivery_order(delivery_order)
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
    q = from t in Transaction,
        select: t, preload: [:order, :table, :user]
    transactions = Repo.all q
    transactions = Enum.sort_by(transactions, &(&1.user.name))
    render(conn, "cashier_list_order.html", transactions: transactions)
  end

  def order_master(conn, _) do
    q = from o in Order,
        where: o.status == "Waiting",
        select: o, preload: [:table]
    orders = Repo.all q
    orders = Enum.sort(orders, &(Timex.diff(&1.inserted_at, &2.inserted_at) < 0 ) )
    render(conn, "order_master_list_order.html", orders: orders)
  end
  def order_master_show_order(conn, %{"id" => id}) do
    order = Repo.get!(Order, id)
    |> Repo.preload(:line_orders)
    |> Repo.preload(:table)

    changeset = Transaction.changeset(%Transaction{total: order.total})

    render(conn, "order_master_show_order.html", order: order, changeset: changeset)
  end
  def order_master_close_order(conn, %{"id" => id, "transaction" => transaction_params}) do
    order = Repo.get!(Order, id)
    |> Repo.preload(:line_orders)
    |> Repo.preload(:table)
    order_master = conn.assigns.current_user
    order_master_session = conn.assigns.current_order_master_session

    transaction_changeset = Transaction.changeset(%Transaction{user_id: order_master.id, order_id: order.id, total: order.total, table_id: order.table.id, order_master_session_id: order_master_session.id}, transaction_params)
    {bar_line_orders, stock_line_orders} = split_line_orders(order.line_orders, "Cocktail")

    multi =
      Ecto.Multi.new
      |> Ecto.Multi.insert(:transaction, transaction_changeset)
      |> Ecto.Multi.update(:order, Order.changeset_close_order(order, %{"order_master_id" => order_master.id}))

    multi = if bar_line_orders != [], do: Ecto.Multi.insert(multi, :delivery_order_bar, create_delivery_order_changeset(bar_line_orders, order.table, order, DeliveryOrder.type_bar)), else: multi
    multi = if stock_line_orders != [], do: Ecto.Multi.insert(multi, :delivery_order_non_bar, create_delivery_order_changeset(stock_line_orders, order.table, order, DeliveryOrder.type_non_bar)), else: multi

    case Repo.transaction(multi) do
      {:ok, %{order: order, transaction: transaction, delivery_order_bar: delivery_order_bar, delivery_order_non_bar: delivery_order_non_bar}} ->
        conn
        |> put_flash(:info, "Order updated successfully.")
        |> redirect(to: order_path(conn, :order_master))
      {:error, _failed_operation, _failed_value, _changes_so_far} ->
        conn
        |> put_flash(:error, "Received Money must be greater than total money")
        |> render("order_master_show_order.html", order: order, changeset: transaction_changeset)
    end
  end
  def order_master_cancel_order(conn, %{"id" => id}) do
    order = Repo.get!(Order, id)
    |> Repo.preload(:line_orders)

    changeset = Order.changeset_cancel_order(order)
    case Repo.update(changeset) do
      {:ok, order} ->
        OrderChannel.broadcast_update_order(order.id)
        conn
        |> put_flash(:info, "Order canceled successfully.")
        |> redirect(to: order_path(conn, :order_master))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something wrong!")
        |> redirect(to: order_path(conn, :order_master))
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

  defp split_line_orders(line_orders, cocktail) do
    {bar_line_orders, stock_line_orders} =
      Enum.map(line_orders,
        fn map ->
          product = Repo.get!(Product, Map.get(map, :product_id))
                    |> Repo.preload(:category)
          Map.put(map, :category , product.category.name)
        end)
      |> Sas.ListState.split_list( fn map -> Map.get(map, :category) == cocktail end)

    {bar_line_orders, stock_line_orders}
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
