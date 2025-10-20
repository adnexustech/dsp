import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="select2"
export default class extends Controller {
  static values = {
    tags: { type: Boolean, default: false },
    allowClear: { type: Boolean, default: true },
    multiple: { type: Boolean, default: false },
    placeholder: { type: String, default: "Select..." },
    noSearch: { type: Boolean, default: false },
    ajax: { type: String, default: "" }
  }

  connect() {
    const config = {
      width: '100%',
      tags: this.tagsValue,
      allowClear: this.allowClearValue,
      multiple: this.multipleValue,
      placeholder: this.placeholderValue
    }

    // Disable search for simple selects
    if (this.noSearchValue) {
      config.minimumResultsForSearch = Infinity
    }

    // AJAX configuration if provided
    if (this.ajaxValue) {
      config.ajax = {
        url: this.ajaxValue,
        dataType: 'json',
        delay: 250,
        data: (params) => ({
          q: params.term,
          page: params.page || 1
        }),
        processResults: (data, params) => {
          params.page = params.page || 1
          return {
            results: data.results,
            pagination: {
              more: (params.page * 30) < data.total_count
            }
          }
        },
        cache: true
      }
    }

    $(this.element).select2(config)
  }

  disconnect() {
    if ($(this.element).data('select2')) {
      $(this.element).select2('destroy')
    }
  }
}
