import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sidebar"
export default class extends Controller {
  static targets = ["menu", "toggle"]

  connect() {
    // Create overlay for mobile
    this.createOverlay()
    
    // Desktop: sidebar always visible
    // Mobile: sidebar hidden by default
    if (window.innerWidth <= 768) {
      this.closeMobile()
    }
    
    // Handle window resize
    window.addEventListener('resize', () => {
      if (window.innerWidth > 768) {
        this.closeMobile()
      }
    })
  }

  disconnect() {
    if (this.overlay) {
      this.overlay.remove()
    }
  }

  createOverlay() {
    if (!this.overlay) {
      this.overlay = document.createElement('div')
      this.overlay.className = 'sidebar-overlay'
      this.overlay.addEventListener('click', () => this.closeMobile())
      document.body.appendChild(this.overlay)
    }
  }

  toggleMobile() {
    if (document.body.classList.contains('sidebar-open')) {
      this.closeMobile()
    } else {
      this.openMobile()
    }
  }

  openMobile() {
    document.body.classList.add('sidebar-open')
  }

  closeMobile() {
    document.body.classList.remove('sidebar-open')
  }

  // Legacy methods for backward compatibility
  toggle() {
    this.toggleMobile()
  }

  collapse() {
    this.closeMobile()
  }

  expand() {
    this.openMobile()
  }
}
