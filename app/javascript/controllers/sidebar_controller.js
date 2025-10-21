import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sidebar"
export default class extends Controller {
  static targets = ["menu", "toggle"]

  connect() {
    // Create overlay for mobile
    this.createOverlay()

    // Restore pinned state from localStorage
    this.restorePinnedState()

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

  // Pin/unpin sidebar (desktop only)
  togglePin() {
    const sidebar = document.getElementById('sidebar')
    const isPinned = sidebar.classList.toggle('sidebar-pinned')
    document.body.classList.toggle('sidebar-pinned', isPinned)
    
    // Save state to localStorage
    localStorage.setItem('sidebarPinned', isPinned ? 'true' : 'false')
  }

  // Restore pinned state from localStorage
  restorePinnedState() {
    const isPinned = localStorage.getItem('sidebarPinned') === 'true'
    if (isPinned) {
      const sidebar = document.getElementById('sidebar')
      sidebar.classList.add('sidebar-pinned')
      document.body.classList.add('sidebar-pinned')
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
