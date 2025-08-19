import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="price-format"
export default class extends Controller {
  static targets = [ "input" ]

  formatCurrency(event) {
    event.target.value = event.target.value.replace(/\D/g,'').replace(/\B(?=(\d{3})+(?!\d))/g, ".")
  }

  submitForm(event) {
    event.preventDefault()
    const inputs = this.inputTargets
    inputs.forEach((input) => { input.value = input.value.replace(/\./g,'') })
    this.element.submit()
  }

  connect() {
    this.inputTargets.forEach((input) => {
      input.value = input.value.replace(/\D/g,'').replace(/\B(?=(\d{3})+(?!\d))/g, ".")
      input.addEventListener("keyup", this.formatCurrency)
    })
  }

  disconnect() {
    this.inputTargets.forEach((input) => {
      input.removeEventListener("keyup", this.formatCurrency)
    })
  }
}
