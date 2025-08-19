import { Controller } from "@hotwired/stimulus"

import select2 from 'select2'
select2() // <- this is very important https://github.com/select2/select2/issues/6081

// Connects to data-controller="select2"
export default class extends Controller {
  connect() {
    $(this.element).select2()
  }

  disconnect() {
    $(this.element).select2('destroy')
  }
}
