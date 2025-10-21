# frozen_string_literal: true

module Components
  module UI
    class Button < Base
      def initialize(
        variant: :primary,
        size: :sm,
        type: :button,
        icon: nil,
        **attributes
      )
        @variant = variant
        @size = size
        @type = type
        @icon = icon
        @attributes = attributes
      end

      def view_template(&block)
        button(
          type: @type,
          class: button_classes,
          **@attributes
        ) do
          i(class: @icon) if @icon
          yield if block_given?
        end
      end

      private

      def button_classes
        base = "inline-flex items-center justify-center gap-2 font-medium transition-colors rounded-lg focus:outline-none focus:ring-2 focus:ring-offset-2"
        
        size_classes = case @size
        when :xs
          "px-2 py-1 text-xs"
        when :sm
          "px-3 py-1.5 text-sm"
        when :md
          "px-4 py-2 text-sm"
        when :lg
          "px-6 py-3 text-base"
        end

        variant_classes = case @variant
        when :primary
          "bg-blue-600 hover:bg-blue-700 text-white focus:ring-blue-500"
        when :secondary
          "bg-zinc-800 hover:bg-zinc-700 text-white focus:ring-zinc-500"
        when :ghost
          "bg-transparent hover:bg-zinc-800 text-zinc-300 focus:ring-zinc-500"
        when :danger
          "bg-red-600 hover:bg-red-700 text-white focus:ring-red-500"
        end

        [base, size_classes, variant_classes].join(" ")
      end
    end
  end
end
