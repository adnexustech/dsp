// Load all Stimulus controllers
import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false

// Make Stimulus globally available
window.Stimulus = application

export { application }
