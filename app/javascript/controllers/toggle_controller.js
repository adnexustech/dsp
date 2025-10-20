import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle"
// Toggles visibility of targets based on input value
export default class extends Controller {
  static targets = ["hideable"]
  static values = {
    showWhen: String,
    hideOthers: { type: Boolean, default: true }
  }

  connect() {
    this.toggle()
  }

  toggle(event) {
    const value = this.element.value || this.element.dataset.value

    this.hideableTargets.forEach(target => {
      const targetValue = target.dataset.toggleValue

      if (targetValue === value) {
        target.style.display = ''
      } else if (this.hideOthersValue) {
        target.style.display = 'none'
      }
    })
  }
}
