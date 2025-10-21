// Load all Stimulus controllers
import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false

// Make Stimulus globally available
declare global {
  interface Window {
    Stimulus: Application
  }
}
window.Stimulus = application

export { application }
