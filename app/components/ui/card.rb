# frozen_string_literal: true

module Components
  module UI
    class Card < Base
      def initialize(padding: :default, hover: false, **attributes)
        @padding = padding
        @hover = hover
        @attributes = attributes
      end

      def view_template(&block)
        div(class: card_classes, **@attributes) do
          yield if block_given?
        end
      end

      private

      def card_classes
        base = "bg-zinc-900 border border-zinc-800 rounded-xl shadow-lg"
        
        padding_class = case @padding
        when :none then ""
        when :sm then "p-4"
        when :default then "p-6"
        when :lg then "p-8"
        end

        hover_class = @hover ? "hover:border-zinc-700 hover:shadow-xl transition-all" : ""

        [base, padding_class, hover_class].join(" ")
      end
    end
  end
end
