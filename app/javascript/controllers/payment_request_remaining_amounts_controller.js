import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="payment-request-remaining-amounts"
export default class extends Controller {
  static targets = ['remainingAmount']

  connect() {
  }

  updateRemainingAmount(event) {
    const selectField = event.target

    if(selectField.value === '') {
      this.remainingAmountTarget.innerHTML = '-'
      return false
    }

    const selectedOption = selectField.selectedOptions[0]
    const remainingAmount = selectedOption.dataset.remainingAmountThatNeedsToBePaid
    this.remainingAmountTarget.innerHTML = remainingAmount
  }
}
