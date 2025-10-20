import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dynamic-table"
// Handles adding and removing table rows dynamically
export default class extends Controller {
  static targets = ["template", "row"]
  static values = {
    template: String
  }

  addRow(event) {
    event.preventDefault()

    let template
    if (this.hasTemplateTarget) {
      template = this.templateTarget.innerHTML
    } else if (this.hasTemplateValue) {
      template = this.templateValue
    } else {
      console.error('No template found for dynamic table')
      return
    }

    // Replace timestamp placeholders with actual timestamp
    const timestamp = new Date().getTime()
    const newRow = template.replace(/NEW_RECORD/g, timestamp)

    // Insert after the clicked row
    const currentRow = event.target.closest('tr')
    if (currentRow) {
      currentRow.insertAdjacentHTML('afterend', newRow)
    } else {
      this.element.querySelector('tbody').insertAdjacentHTML('beforeend', newRow)
    }
  }

  removeRow(event) {
    event.preventDefault()

    const row = event.target.closest('tr')
    if (row) {
      // Check if there's a hidden input for _destroy
      const destroyInput = row.querySelector('input[name*="_destroy"]')
      if (destroyInput) {
        destroyInput.value = '1'
        row.style.display = 'none'
      } else {
        row.remove()
      }
    }
  }
}
