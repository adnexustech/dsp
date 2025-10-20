import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="darkmode"
export default class extends Controller {
  static targets = ["toggle"]

  connect() {
    // Check localStorage or system preference
    const isDark = localStorage.getItem('darkMode') === 'true' ||
                   (!localStorage.getItem('darkMode') &&
                    window.matchMedia('(prefers-color-scheme: dark)').matches)

    if (isDark) {
      this.enableDark()
    } else {
      this.enableLight()
    }
  }

  toggle() {
    if (document.documentElement.classList.contains('dark')) {
      this.enableLight()
    } else {
      this.enableDark()
    }
  }

  enableDark() {
    document.documentElement.classList.add('dark')
    localStorage.setItem('darkMode', 'true')
  }

  enableLight() {
    document.documentElement.classList.remove('dark')
    localStorage.setItem('darkMode', 'false')
  }
}
