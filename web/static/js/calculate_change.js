let ChangeMoney = {
  init(inputElement){
    if(!inputElement) {return;}
    let totalField = document.getElementById("order_master_total");
    let receivedMoneyField = document.getElementById("order_master_received_money");
    let changeField = document.getElementById("order_master_change");

    receivedMoneyField.addEventListener("change", e => {
      let total = parseFloat(totalField.value.substring(1).replace(",",""));
      let receivedMoney = parseFloat(receivedMoneyField.value);
      changeField.value = receivedMoney - total;
      if(isNaN(changeField.value)) {changeField.value = 0;}
    });
  },
}

export default ChangeMoney
