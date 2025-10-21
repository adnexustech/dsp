# frozen_string_literal: true

module Components
  module UI
    class Badge < Base
      def initialize(variant: :default, size: :sm, **attributes)
        @variant = variant
        @size = size
        @attributes = attributes
      end

      def view_template(&block)
        span(class: badge_classes, **@attributes) do
          yield if block_given?
        end
      end

      private

      def badge_classes
        base = "inline-flex items-center font-medium rounded-full border"
        
        size_class = case @size
        when :xs then "px-2 py-0.5 text-xs"
        when :sm then "px-3 py-1 text-xs"
        when :md then "px-4 py-1.5 text-sm"
        end

        variant_class = case @variant
        when :default
          "bg-zinc-800 text-zinc-300 border-zinc-700"
        when :primary
          "bg-blue-500/10 text-blue-400 border-blue-500/20"
        when :success
          "bg-green-500/10 text-green-400 border-green-500/20"
        when :danger
          "bg-red-500/10 text-red-400 border-red-500/20"
        when :warning
          "bg-yellow-500/10 text-yellow-400 border-yellow-500/20"
        when :purple
          "bg-purple-500/10 text-purple-400 border-purple-500/20"
        end

        [base, size_class, variant_class].join(" ")
      end
    end
  end
end
