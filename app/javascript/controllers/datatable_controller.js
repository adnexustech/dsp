import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="datatable"
export default class extends Controller {
  static values = {
    order: { type: Array, default: [[0, 'asc']] },
    pageLength: { type: Number, default: 25 },
    searching: { type: Boolean, default: true },
    paging: { type: Boolean, default: true },
    info: { type: Boolean, default: true },
    responsive: { type: Boolean, default: true }
  }

  connect() {
    const config = {
      order: this.orderValue,
      pageLength: this.pageLengthValue,
      searching: this.searchingValue,
      paging: this.pagingValue,
      info: this.infoValue,
      responsive: this.responsiveValue,
      language: {
        search: "_INPUT_",
        searchPlaceholder: "Search records..."
      }
    }

    this.dataTable = $(this.element).DataTable(config)
  }

  disconnect() {
    if (this.dataTable) {
      this.dataTable.destroy()
    }
  }

  refresh() {
    if (this.dataTable) {
      this.dataTable.ajax.reload()
    }
  }
}
