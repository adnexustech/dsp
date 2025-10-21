# frozen_string_literal: true

module Components
  class QuickLink < Base
    def initialize(url:, title:, icon: nil, badge_text: nil, badge_color: "gray")
      @url = url
      @title = title
      @icon = icon
      @badge_text = badge_text
      @badge_color = badge_color
    end

    def view_template
      a(href: @url, class: "flex items-center justify-between p-3 rounded-lg hover:bg-gray-900 transition-colors") do
        div(class: "flex items-center") do
          i(class: "#{@icon} w-8") if @icon
          span { @title }
        end

        div(class: "flex items-center") do
          if @badge_text
            span(class: "rt-Badge rt-r-size-1 rt-variant-soft mr-2", data_accent_color: @badge_color) do
              @badge_text
            end
          end
          i(class: "fa fa-chevron-right text-gray-600")
        end
      end
    end
  end
end
