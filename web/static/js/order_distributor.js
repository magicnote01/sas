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
    let orderChannel = socket.channel("delivery_orders:" + mode);
    orderChannel.join()

    orderChannel.on("new", (resp) => {
      this.makeNewOrderRow(resp.order, socket, mode, element)
    });
  },

  onReadyWithOrderId(element, socket, mode, orderId){
    let orderChannel = socket.channel("delivery_orders:" + orderId)
    orderChannel.join()

    orderChannel.on("update", (resp) => {
      this.updateOrderRow(resp.order, orderChannel, element.parentNode.parentNode)
    });
  },

  makeNewOrderRow(order, socket, mode, element){
    let template = element.insertRow(-1)

    template.id = order.id
    template.class = "distributor_row"
    template.innerHTML = `
      <td id="${order.id}_billNo" >${order.billNo}</td>
      <td id="${order.id}_type" >${order.type}</td>
      <td id="${order.id}_createAt" >${order.insertedAt}</td>
      <td id="${order.id}_tableName" >${(order.table ? order.table.name : "")}</td>
      <td id="${order.id}_status" >${order.status}</td>
      <td id="${order.id}_distributorName" >${(order.distributor ? order.distributor.name : "")}</td>
      <td id="${order.id}_waiterName" >${(order.waiter ? order.waiter.name : "")}</td>

      <td id="${order.id}_link" class="text-right">
      <a class="btn btn-default btn-xs" href="/staff/distributor/orders/take/${order.id}">Take Order</a></td>
    `
    this.onReadyWithOrderId(template, socket, mode, order.id)

  },

  updateOrderRow(order, orderChannel, element){
    let orderElement = document.getElementById(order.id)
    if(order.status === "Delivering" || order.status == "In Process"){
      let row = orderElement.rowIndex
      element.deleteRow(row)
      orderChannel.leave()
    }
  }

}

export default Order
