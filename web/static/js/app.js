import "phoenix_html"
import socket from "./socket"
import orderMaster from "./order_master"
import orderDistributor from "./order_distributor"
import buttonIncDec from "./button_inc_dec"
import changeMoney from "./calculate_change"

orderMaster.init(socket, document.getElementById("socket_order_master"), "order_master")
let orderMasterOrders = document.getElementsByClassName("order_master_row");
Array.prototype.map.call(orderMasterOrders, (element) => {
  orderMaster.init(socket, element, "order_master", element.id)
})

orderDistributor.init(socket, document.getElementById("socket_distributor_bar"), "distributor_bar")
orderDistributor.init(socket, document.getElementById("socket_distributor_non-bar"), "distributor_non-bar")

let distributorOrders = document.getElementsByClassName("distributor_row");
Array.prototype.map.call(distributorOrders, (element) => {
  orderDistributor.init(socket, element, "distributor", element.id)
})


let numberIncValueElements = document.getElementsByClassName("numberIncValue");
Array.prototype.map.call(numberIncValueElements, (element) => {
  buttonIncDec.init(element, "+")
})

let numberDecValueElements = document.getElementsByClassName("numberDecValue");
Array.prototype.map.call(numberIncValueElements, (element) => {
  buttonIncDec.init(element, "-")
})

let orderMasterChange = document.getElementById("order_master_change_table");
changeMoney.init(orderMasterChange)
