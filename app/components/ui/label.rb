# frozen_string_literal: true

module Components
  module UI
    class Label < Base
      def initialize(for_id: nil, required: false, **attributes)
        @for_id = for_id
        @required = required
        @attributes = attributes
      end

      def view_template(&block)
        label(
          for: @for_id,
          class: "block text-zinc-400 text-sm mb-2 font-medium",
          **@attributes
        ) do
          yield if block_given?
          span(class: "text-red-400 ml-1") { "*" } if @required
        end
      end
    end
  end
end
