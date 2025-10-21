# frozen_string_literal: true

module Components
  class AdCard < Base
    def initialize(title: nil, subtitle: nil, icon: nil, &block)
      @title = title
      @subtitle = subtitle
      @icon = icon
      @block = block
    end

    def view_template
      div(class: "card") do
        if @title
          div(class: "flex items-center justify-between mb-6") do
            h2(class: "text-xl font-semibold flex items-center") do
              i(class: "#{@icon} mr-3") if @icon
              text @title
            end
            p(class: "text-sm") { @subtitle } if @subtitle
          end
        end

        @block.call(self) if @block
      end
    end
  end
end
