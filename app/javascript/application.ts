// Modern TypeScript Entry Point for ADNEXUS DSP
// No jQuery - Pure TypeScript with Hotwire

import "@hotwired/turbo-rails"
import "./controllers/index"

// Modern vanilla TypeScript - no dependencies
console.log("ADNEXUS DSP - Modern TypeScript Stack Loaded")

// Dark mode handling
document.addEventListener("turbo:load", () => {
  initializeDarkMode()
  initializeSidebar()
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
