# frozen_string_literal: true

module Components
  class LoginLayout < Phlex::HTML
    include Phlex::Rails::Layout

    def initialize(title: "Adnexus - Login")
      @title = title
    end

    def view_template(&block)
      doctype

      html(lang: "en", class: "h-full") do
        head do
          title { @title }
          meta(charset: "utf-8")
          meta(http_equiv: "X-UA-Compatible", content: "IE=edge")
          meta(name: "viewport", content: "width=device-width, initial-scale=1.0")

          # Stylesheets
          unsafe_raw helpers.stylesheet_link_tag("tailwind", "data-turbo-track": "reload")
          unsafe_raw helpers.stylesheet_link_tag("font-awesome")
          unsafe_raw helpers.csrf_meta_tags
          unsafe_raw helpers.javascript_importmap_tags
        end

        body(class: "h-full bg-gradient-to-br from-gray-900 via-slate-800 to-gray-900", data_controller: "darkmode") do
          div(class: "min-h-full flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8") do
            div(class: "max-w-md w-full space-y-8") do
              # Logo
              div(class: "text-center mb-8") do
                unsafe_raw helpers.image_tag("logo.png", alt: "Adnexus", class: "h-16 mx-auto invert")
              end

              # Login Form Card
              div(class: "bg-white dark:bg-gray-800 rounded-2xl shadow-2xl p-8 space-y-6") do
                yield
              end

              # Footer
              div(class: "text-center") do
                p(class: "text-gray-400 text-sm") do
                  text "Copyright Adnexus Technology Inc"
                end
              end
            end
          end
        end
      end
    end
  end
end
