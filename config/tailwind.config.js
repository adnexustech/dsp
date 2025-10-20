/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}',
    './app/assets/stylesheets/**/*.css'
  ],
  darkMode: 'class', // Enable dark mode with 'dark' class
  theme: {
    extend: {
      colors: {
        // Custom brand colors
        primary: {
          DEFAULT: '#3b82f6', // blue-500
          dark: '#1e40af',    // blue-800
        },
        sidebar: {
          light: '#f8fafc',   // slate-50
          DEFAULT: '#1e293b', // slate-800
          dark: '#0f172a',    // slate-900
        }
      }
    },
  },
  plugins: [],
}
