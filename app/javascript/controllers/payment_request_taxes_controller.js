import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="payment-request-taxes"
export default class extends Controller {
  static targets = ["amount", "totalPayment", "totalPpn", "pphOption", "totalPph", "ppn", "taxInvoiceNumber", "taxInvoiceNumberInput"]

  connect() {
    this.updateTotalPpnAndTotalPayment()
    this.toggleTotalPph({target: {value: this.pphOptionTarget.value}})
  }

  updateTotalPpnAndTotalPayment(){
    if(this.hasTotalPpnTarget && this.hasTotalPaymentTarget){
      this.updateTotalPpn()
      this.updateTotalPayment()
    }
  }

  fetchAmount(){
    return parseInt(this.amountTarget.dataset.amount)
  }

  toggleTaxInvoiceNumber(event){
    const ppn = event.target.value

    if(ppn === 'true') {
      this.taxInvoiceNumberTarget.classList.remove('d-none')
      this.taxInvoiceNumberInputTarget.setAttribute('required', true)
      return 
    }
    this.taxInvoiceNumberTarget.classList.add('d-none')
    this.taxInvoiceNumberInputTarget.removeAttribute('required', true)
  }

  updateTotalPpn(){
    const totalPpnDOM = this.totalPpnTarget
    totalPpnDOM.innerText = this.formatToIdr(this.fetchTotalPpn())
  }

  fetchTotalPpn(){
    const ppn = this.ppnTarget.value
    if(ppn === 'false') {
      return 0
    }

    const amount = this.fetchAmount()
    return amount * 0.11
  }

  fetchTotalPph(){
    const pphOption = this.pphOptionTarget.value

    if(pphOption === 'gross_up'){
      return 0
    }

    const totalPpn = parseInt(this.totalPphTarget.value)
    if(isNaN(totalPpn)){
      return 0
    }

    return totalPpn
  }

  toggleTotalPph(event){
    const pphOption = event.target.value

    if(pphOption === 'gross_up'){
      // disable totalPph field
      this.totalPphTarget.setAttribute('disabled', true)
      this.totalPphTarget.value = 0
      return
    }

    this.totalPphTarget.removeAttribute('disabled')
  }

  updateTotalPayment(){
    const amount = this.fetchAmount()
    const totalPpn = this.fetchTotalPpn()
    const totalPph = this.fetchTotalPph()
    const totalPayment = amount + totalPpn - totalPph
    const totalPaymentDOM = this.totalPaymentTarget
    totalPaymentDOM.innerText = this.formatToIdr(totalPayment)
  }


  formatToIdr(number) {
    return "Rp " + number.toLocaleString("id-ID");
  }
}
