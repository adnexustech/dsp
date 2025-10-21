# frozen_string_literal: true

module Components
  module UI
    class Modal < Base
      def initialize(id:, title:, size: :md)
        @id = id
        @title = title
        @size = size
      end

      def view_template(&block)
        div(
          id: @id,
          class: "hidden fixed inset-0 bg-black/80 backdrop-blur-sm flex items-center justify-center z-50"
        ) do
          div(class: modal_content_classes) do
            # Header
            div(class: "flex justify-between items-center mb-6") do
              h3(class: "text-xl font-semibold") { @title }
              button(
                onclick: "document.getElementById('#{@id}').classList.add('hidden')",
                class: "text-zinc-400 hover:text-white transition-colors"
              ) do
                i(class: "fa-solid fa-xmark text-xl")
              end
            end

            # Content
            yield if block_given?
          end
        end
      end

      private

      def modal_content_classes
        base = "bg-zinc-950 border border-zinc-800 rounded-2xl p-6 shadow-2xl mx-4"
        
        size_class = case @size
        when :sm then "w-full max-w-sm"
        when :md then "w-full max-w-md"
        when :lg then "w-full max-w-lg"
        when :xl then "w-full max-w-xl"
        end

        [base, size_class].join(" ")
      end
    end
  end
end
