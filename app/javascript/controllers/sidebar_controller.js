import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sidebar"
export default class extends Controller {
  static targets = ["menu", "toggle"]

  connect() {
    // Check localStorage for saved state
    const isCollapsed = localStorage.getItem('sidebarCollapsed') === 'true'
    if (isCollapsed) {
      this.collapse()
    } else {
      this.expand()
    }
  }

  toggle() {
    if (document.body.classList.contains('sidebar-collapsed')) {
      this.expand()
    } else {
      this.collapse()
    }
  }

  collapse() {
    document.body.classList.add('sidebar-collapsed')
    localStorage.setItem('sidebarCollapsed', 'true')
  }

  expand() {
    document.body.classList.remove('sidebar-collapsed')
    localStorage.setItem('sidebarCollapsed', 'false')
  }
}
