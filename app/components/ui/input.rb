# frozen_string_literal: true

module Components
  module UI
    class Input < Base
      def initialize(
        type: :text,
        name: nil,
        value: nil,
        placeholder: nil,
        required: false,
        **attributes
      )
        @type = type
        @name = name
        @value = value
        @placeholder = placeholder
        @required = required
        @attributes = attributes
      end

      def view_template
        input(
          type: @type,
          name: @name,
          value: @value,
          placeholder: @placeholder,
          required: @required,
          class: input_classes,
          **@attributes
        )
      end

      private

      def input_classes
        "w-full bg-zinc-900 border border-zinc-800 rounded-xl px-4 py-3 " \
        "text-white placeholder-zinc-500 " \
        "focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20 focus:outline-none " \
        "transition-all"
      end
    end
  end
end
