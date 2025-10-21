# frozen_string_literal: true

module Components
  class StatCard < Base
    def initialize(title:, value:, icon: nil, link_text: nil, link_url: nil, color: "gray")
      @title = title
      @value = value
      @icon = icon
      @link_text = link_text
      @link_url = link_url
      @color = color
    end

    def view_template
      div(class: "stat-card") do
        div(class: "flex items-center justify-between mb-2") do
          span(class: "text-sm font-medium") { @title }
          i(class: "#{@icon} text-xl") if @icon
        end

        div(class: "stat-value") { @value }

        if @link_text && @link_url
          a(href: @link_url, class: "text-xs mt-2 inline-block hover:underline") do
            text @link_text
            text " →"
          end
        end
      end
    end
  end
end
