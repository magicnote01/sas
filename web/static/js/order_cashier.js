let Order = {
  init(socket, element, mode, orderId = null) { if(!element) {return;}
    socket.connect();
    if (orderId){
      this.onReadyWithOrderId(element, socket, mode, orderId);
    } else {
      this.onReady(element, socket, mode);
    }
  },

  onReady(element, socket, mode){
    let orderChannel = socket.channel("orders:" + mode);
    orderChannel.join()

    orderChannel.on("new", (resp) => {
      this.makeNewOrderRow(resp.order, socket, mode)
    });
  },

  onReadyWithOrderId(element, socket, mode, orderId){
    let orderChannel = socket.channel("orders:" + orderId)
    orderChannel.join()

    orderChannel.on("update", (resp) => {
      console.log(resp);
      this.updateOrderRow(resp.order, orderChannel)
    });
  },

  makeNewOrderRow(order, socket, mode){
    let template = document.getElementById("socket_cashier").insertRow(-1)

    template.innerHTML = `
      <tr id="${order.id}" class="cashier_row" >
        <td id="${order.id}_billNo" >${order.billNo}</td>
        <td id="${order.id}_createAt" >${order.insertedAt}</td>
        <td id="${order.id}_tableName" >${(order.table ? order.table.name : "")}</td>
        <td id="${order.id}_status" >${order.status}</td>
        <td id="${order.id}_waiterName" >${(order.waiter ? order.waiter.name : "")}</td>
        <td id="${order.id}_paymentMethod" >${order.paymentMethod}</td>
        <td id="${order.id}_total" >${order.total}</td>

        <td id="${order.id}_link" class="text-right">
        <a class="btn btn-default btn-xs" href="/staff/cashier/r/orders/${order.id}/edit">Edit Order</a>        <a class="btn btn-default btn-xs" href="/staff/cashier/orders/close/${order.id}">Close Order</a>      </td>
      </tr>
    `
    this.onReadyWithOrderId(template, socket, mode, order.id)

  },

  updateOrderRow(order, orderChannel){
    console.log(order)
    let orderElement = document.getElementById(order.id)
    if(order.status === "Close" ){
      orderElement.parentNode.removeChild(orderElement)
      orderChannel.leave()
      return;
    }
    document.getElementById(order.id + "_billNo").innerHTML = order.billNo
    document.getElementById(order.id + "_createAt").innerHTML = order.insertedAt
    document.getElementById(order.id + "_tableName").innerHTML = (order.table ? order.table.name : "")
    document.getElementById(order.id + "_status").innerHTML = order.status
    document.getElementById(order.id + "_waiterName").innerHTML = (order.waiter ? order.waiter.name : "")
    document.getElementById(order.id + "_paymentMethod").innerHTML = order.paymentMethod
    document.getElementById(order.id + "_total").innerHTML = order.total
    document.getElementById(order.id + "_link").innerHTML = ""
  }

}

export default Order
