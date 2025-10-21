# frozen_string_literal: true

module Components
  module UI
    class QuickLink < Base
      def initialize(url:, title:, icon: nil, badge: nil, badge_variant: :default)
        @url = url
        @title = title
        @icon = icon
        @badge = badge
        @badge_variant = badge_variant
      end

      def view_template
        a(
          href: @url,
          class: "flex items-center justify-between p-3 rounded-lg hover:bg-zinc-800 transition-colors group"
        ) do
          # Left side: icon and title
          div(class: "flex items-center gap-3") do
            i(class: "#{@icon} w-5 text-center") if @icon
            span { @title }
          end

          # Right side: badge and chevron
          div(class: "flex items-center gap-2") do
            if @badge
              render Badge.new(variant: @badge_variant, size: :sm) { @badge }
            end
            i(class: "fa-solid fa-chevron-right text-zinc-600 group-hover:text-zinc-400 transition-colors text-xs")
          end
        end
      end
    end
  end
end
