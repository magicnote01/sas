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
    let template = document.getElementById("socket_distributor").insertRow(-1)

    template.innerHTML = `
      <tr id="${order.id}" class="distributor_row" >
        <td id="${order.id}_billNo" >${order.billNo}</td>
        <td id="${order.id}_createAt" >${order.insertedAt}</td>
        <td id="${order.id}_tableName" >${(order.table ? order.table.name : "")}</td>
        <td id="${order.id}_status" >${order.status}</td>
        <td id="${order.id}_distributorName" >${(order.distributor ? order.distributor.name : "")}</td>
        <td id="${order.id}_waiterName" >${(order.waiter ? order.waiter.name : "")}</td>

        <td id="${order.id}_link" class="text-right">
      <a class="btn btn-default btn-xs" href="/staff/distributor/orders/take/${order.id}">Take Order</a>      </td>
        </tr>
    `
    this.onReadyWithOrderId(template, socket, mode, order.id)

  },

  updateOrderRow(order, orderChannel){
    console.log(order)
    let orderElement = document.getElementById(order.id)
    if(order.status === "Complete" ){
      orderElement.parentNode.removeChild(orderElement)
      orderChannel.leave()
      return;
    }
    document.getElementById(order.id + "_billNo").innerHTML = order.billNo
    document.getElementById(order.id + "_createAt").innerHTML = order.insertedAt
    document.getElementById(order.id + "_tableName").innerHTML = (order.table ? order.table.name : "")
    document.getElementById(order.id + "_status").innerHTML = order.status
    document.getElementById(order.id + "_distributorName").innerHTML = (order.distributor ? order.distributor.name : "")
    document.getElementById(order.id + "_waiterName").innerHTML = (order.waiter ? order.waiter.name : "")
    document.getElementById(order.id + "_link").innerHTML = ""
  }

}

export default Order
