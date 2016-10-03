// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"
import socket from "./socket"
import orderDistributor from "./order_distributor"
import orderWaiter from "./order_waiter"
import orderCashier from "./order_cashier"
import buttonIncDec from "./button_inc_dec"
import changeMoney from "./calculate_change"

// orderDistributor.init(socket, document.getElementById("socket_distributor"), "distributor")
// let distributorOrders = document.getElementsByClassName("distributor_row");
// Array.prototype.map.call(distributorOrders, (element) => {
//   orderDistributor.init(socket, element, "distributor", element.id)
// })
//
// orderWaiter.init(socket, document.getElementById("socket_waiter"), "waiter")
//
// orderCashier.init(socket, document.getElementById("socket_cashier"), "waiter")
// let cashierOrders = document.getElementsByClassName("cashier_row");
// Array.prototype.map.call(cashierOrders, (element) => {
//   orderCashier.init(socket, element, "cashier", element.id)
// })

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

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
