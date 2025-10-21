# frozen_string_literal: true

module Components
  module UI
    class StatCard < Base
      def initialize(title:, value:, icon: nil, link_text: nil, link_url: nil, value_color: "white")
        @title = title
        @value = value
        @icon = icon
        @link_text = link_text
        @link_url = link_url
        @value_color = value_color
      end

      def view_template
        div(class: "bg-zinc-900 border border-zinc-800 rounded-xl p-5 hover:border-zinc-700 hover:shadow-lg transition-all") do
          # Header with title and icon
          div(class: "flex items-center justify-between mb-2") do
            span(class: "text-zinc-400 text-sm font-medium") { @title }
            i(class: "#{@icon} text-lg") if @icon
          end

          # Value
          div(class: "text-3xl font-bold text-#{@value_color} my-2") { @value }

          # Link or status
          if @link_text && @link_url
            a(
              href: @link_url,
              class: "text-#{@value_color} hover:text-#{@value_color}/80 text-xs inline-block"
            ) do
              text "#{@link_text} →"
            end
          elsif @link_text
            span(class: "text-#{@value_color} text-xs inline-block") { "● #{@link_text}" }
          end
        end
      end
    end
  end
end
