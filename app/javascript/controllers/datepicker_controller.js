import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="datepicker"
export default class extends Controller {
  static values = {
    format: { type: String, default: "YYYY-MM-DD HH:mm" },
    minDate: String,
    maxDate: String,
    defaultDate: String
  }

  connect() {
    const config = {
      format: this.formatValue,
      showClose: true,
      showClear: true,
      showTodayButton: true,
      icons: {
        time: 'fa fa-clock-o',
        date: 'fa fa-calendar',
        up: 'fa fa-chevron-up',
        down: 'fa fa-chevron-down',
        previous: 'fa fa-chevron-left',
        next: 'fa fa-chevron-right',
        today: 'fa fa-calendar-check-o',
        clear: 'fa fa-trash',
        close: 'fa fa-times'
      }
    }

    if (this.hasMinDateValue) {
      config.minDate = this.minDateValue
    }

    if (this.hasMaxDateValue) {
      config.maxDate = this.maxDateValue
    }

    if (this.hasDefaultDateValue) {
      config.defaultDate = this.defaultDateValue
    }

    $(this.element).datetimepicker(config)
  }

  disconnect() {
    if ($(this.element).data('DateTimePicker')) {
      $(this.element).data('DateTimePicker').destroy()
    }
  }
}
