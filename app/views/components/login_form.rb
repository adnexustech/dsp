# frozen_string_literal: true

module Components
  class LoginForm < Phlex::HTML
    def initialize(flash: nil)
      @flash = flash
    end

    def view_template
      form(action: "/login", method: "post", class: "space-y-6") do
        # CSRF token
        input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)

        # Flash message
        if @flash&.dig(:notice)
          div(class: "bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 text-red-800 dark:text-red-200 px-4 py-3 rounded-lg text-sm") do
            text @flash[:notice]
          end
        end

        # Email field
        div do
          label(for: "inputName", class: "block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2") do
            text "Email Address"
          end

          div(class: "relative") do
            div(class: "absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none") do
              i(class: "fa fa-envelope text-gray-400")
            end

            input(
              id: "inputName",
              name: "email",
              type: "email",
              autocomplete: "email",
              required: true,
              placeholder: "demo@ad.nexus",
              class: "pl-10 block w-full px-3 py-3 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
            )
          end
        end

        # Password field
        div do
          label(for: "inputPassword", class: "block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2") do
            text "Password"
          end

          div(class: "relative") do
            div(class: "absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none") do
              i(class: "fa fa-lock text-gray-400")
            end

            input(
              id: "inputPassword",
              name: "password",
              type: "password",
              autocomplete: "current-password",
              required: true,
              placeholder: "••••••••",
              class: "pl-10 block w-full px-3 py-3 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
            )
          end
        end

        # Submit button
        div do
          button(
            type: "submit",
            class: "w-full flex justify-center py-3 px-4 border border-transparent rounded-lg shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors duration-150"
          ) do
            i(class: "fa fa-sign-in mr-2")
            text "Sign In"
          end
        end
      end
    end
  end
end
