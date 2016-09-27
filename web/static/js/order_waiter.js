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
      this.makeNewOrderRow(resp.order, socket, mode, element)
    });
  },

  makeNewOrderRow(order, socket, mode, element){
    let template = document.createElement("div")

    template.innerHTML = `
    <h2>Show order</h2>
    <table class="table">
    <tr>
      <td>Bill No.</td>
      <td>${order.billNo}</td>
    </tr>
    <tr>
      <td>Table</td>
      <td>${(order.table ? order.table.name : "")}</td>
    </tr>
    <tr>
      <td>Status</td>
      <td>${order.status}</td>
    </tr>
    <tr>
      <td>Payment method</td>
      <td>${order.paymentMethod}</td>
    </tr>
    </table>

    <table class="table">
    <thead>
      <tr>
        <th>Name</th>
        <th>Price</th>
        <th>Quantity</th>
      </tr>
    </thead>
    <tbody>
        ${order.lineOrders.map( lineOrder => this.makeLineOrderRowHTML(lineOrder) )}
    </tbody>
    </table>
    <table class="table">
    <tr>
      <td>Service Charge (10%)</td>
      <td>${order.serviceCharge}</td>
    </tr>
    <tr>
      <td>Total Cost</td>
      <td>${order.total}</td>
    </tr>
    </table>

    <p>
    Distributor: <span>${(order.distributor ? order.distributor.name : "")}</span>
    </p>
    <a class="btn btn-primary" href="/staff/waiter/orders/complete/${order.id}">Complete</a>
    `
    element.appendChild(template)
  },

  makeLineOrderRowHTML(lineOrder){
    let row = `<tr>
      <td>${lineOrder.name}</td>
      <td>${lineOrder.price}</td>
      <td>${lineOrder.quantity}</td>
    </tr>`
    return row
  }

}

export default Order
