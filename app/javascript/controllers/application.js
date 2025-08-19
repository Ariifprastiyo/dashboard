import { Application } from "@hotwired/stimulus"
import Clipboard from 'stimulus-clipboard'
import NestedForm from 'stimulus-rails-nested-form'


const application = Application.start()
application.debug = true
application.register('clipboard', Clipboard)
application.register('nested-form', NestedForm)


// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
