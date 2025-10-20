import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="campaign-selector"
// Handles campaign selection and loading exchange attributes
export default class extends Controller {
  static targets = ["intervalStart", "intervalEnd", "exchangeAttributes"]
  static values = {
    url: String
  }

  change(event) {
    const campaignId = event.target.value

    if (!campaignId || !this.hasUrlValue) {
      return
    }

    fetch(this.urlValue, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      },
      body: JSON.stringify({ id: campaignId })
    })
    .then(response => response.json())
    .then(data => {
      // Update interval fields
      if (this.hasIntervalStartTarget && data.start) {
        this.intervalStartTarget.value = data.start
        this.intervalStartTarget.dispatchEvent(new Event('change'))
      }

      if (this.hasIntervalEndTarget && data.end) {
        this.intervalEndTarget.value = data.end
        this.intervalEndTarget.dispatchEvent(new Event('change'))
      }

      // Update exchange attributes
      if (this.hasExchangeAttributesTarget && data.html) {
        this.exchangeAttributesTarget.innerHTML = data.html

        // Re-initialize Select2 on new elements
        this.exchangeAttributesTarget.querySelectorAll('select.nosearch').forEach(select => {
          if (window.Stimulus) {
            select.setAttribute('data-controller', 'select2')
            select.setAttribute('data-select2-no-search-value', 'true')
          }
        })

        this.exchangeAttributesTarget.querySelectorAll('select.search_rules').forEach(select => {
          if (window.Stimulus) {
            select.setAttribute('data-controller', 'select2')
            select.setAttribute('data-select2-tags-value', 'false')
            select.setAttribute('data-select2-multiple-value', 'true')
            select.setAttribute('data-select2-placeholder-value', 'select multiple entries')
          }
        })
      }
    })
    .catch(error => {
      console.error('Error loading campaign data:', error)
    })
  }
}
