// Modern JavaScript Entry Point for ADNEXUS DSP
// No jQuery - Pure JavaScript with Hotwire

import "@hotwired/turbo-rails"
import "./controllers/index"

// Modern vanilla JavaScript - no dependencies
console.log("ADNEXUS DSP - Modern JavaScript Stack Loaded")

// Dark mode handling
document.addEventListener("turbo:load", () => {
  initializeDarkMode()
  initializeSidebar()
  initializeDropdowns()
})

function initializeDarkMode() {
  const darkModeToggle = document.querySelector('[data-dark-mode-toggle]')
  if (!darkModeToggle) return

  const isDark = localStorage.getItem('darkMode') === 'true'
  document.documentElement.classList.toggle('dark', isDark)

  darkModeToggle.addEventListener('click', () => {
    const currentlyDark = document.documentElement.classList.contains('dark')
    document.documentElement.classList.toggle('dark', !currentlyDark)
    localStorage.setItem('darkMode', (!currentlyDark).toString())
  })
}

function initializeSidebar() {
  const sidebar = document.getElementById('sidebar')
  const menuToggle = document.getElementById('menu-toggle')

  if (!sidebar || !menuToggle) return

  menuToggle.addEventListener('click', () => {
    document.body.classList.toggle('left-side-collapsed')
  })

  // Responsive behavior
  const handleResize = () => {
    if (window.innerWidth < 768) {
      document.body.classList.add('left-side-collapsed')
    }
  }

  window.addEventListener('resize', handleResize)
  handleResize()
}

function initializeDropdowns() {
  // Handle user dropdown menu
  const dropdownToggles = document.querySelectorAll('[data-dropdown-toggle]')

  dropdownToggles.forEach(toggle => {
    const dropdownId = toggle.getAttribute('data-dropdown-toggle')
    const dropdown = document.getElementById(dropdownId)

    if (!dropdown) return

    let closeTimeout = null

    // Toggle on click
    toggle.addEventListener('click', (e) => {
      e.preventDefault()
      e.stopPropagation()

      if (closeTimeout) {
        clearTimeout(closeTimeout)
        closeTimeout = null
      }

      const isOpen = dropdown.classList.contains('show') || dropdown.style.display === 'block'

      // Close all other dropdowns first
      document.querySelectorAll('.dropdown-menu').forEach(menu => {
        menu.classList.remove('show')
        menu.style.display = 'none'
      })

      if (!isOpen) {
        dropdown.classList.add('show')
        dropdown.style.display = 'block'
      }
    })

    // Keep open on hover over dropdown or toggle
    const keepOpen = () => {
      if (closeTimeout) {
        clearTimeout(closeTimeout)
        closeTimeout = null
      }
    }

    const scheduleClose = () => {
      if (closeTimeout) clearTimeout(closeTimeout)
      closeTimeout = window.setTimeout(() => {
        dropdown.classList.remove('show')
        dropdown.style.display = 'none'
      }, 300) // 300ms delay before closing
    }

    toggle.addEventListener('mouseenter', keepOpen)
    toggle.addEventListener('mouseleave', scheduleClose)
    dropdown.addEventListener('mouseenter', keepOpen)
    dropdown.addEventListener('mouseleave', scheduleClose)
  })

  // Close dropdowns when clicking outside
  document.addEventListener('click', (e) => {
    const target = e.target
    if (!target.closest('.dropdown')) {
      document.querySelectorAll('.dropdown-menu').forEach(menu => {
        menu.classList.remove('show')
        menu.style.display = 'none'
      })
    }
  })
}
