let Button = {
  init(inputElement, operation){
    if(!inputElement) {return;}
    let button = document.createElement("button")
    button.type = "button"
    button.class = "btn btn-primary btn-xs"
    if(operation === "+"){
      button.innerHTML = "+"
      button.addEventListener("click", e => {
        inputElement.value = parseInt(inputElement.value) + 1;
      })
      this.insertAfter(button, inputElement)
    } else if (operation === "-"){
      button.innerHTML = "-"
      button.addEventListener("click", e => {
        if(parseInt(inputElement.value) > 0){
          inputElement.value = parseInt(inputElement.value) - 1;
        }
      })
      inputElement.parentNode.insertBefore(button, inputElement)
    }
  },

  insertAfter(newNode, node){
    node.parentNode.insertBefore(newNode, node.nextSibling)
  }
}

export default Button
