module Components
  class BannerForm < Phlex::HTML
      def initialize(banner:, campaigns:, rtb_standards:)
        @banner = banner
        @campaigns = campaigns
        @rtb_standards = rtb_standards
      end
  
      def view_template
        form_with(model: @banner, local: true, class: "space-y-6") do |f|
          render_errors(f) if @banner.errors.any?
          
          # Campaign Selection
          div(class: "form-group") do
            label(for: "banner_campaign_id", class: "block text-sm font-medium mb-2") { "Campaign" }
            f.collection_select(:campaign_id, @campaigns, :id, :name, 
              { prompt: true, include_blank: true }, 
              { class: "w-full bg-zinc-900 border border-zinc-800 rounded-lg px-4 py-2" })
          end
  
          # Banner ID (readonly)
          div(class: "form-group") do
            label(for: "banner_id", class: "block text-sm font-medium mb-2") { "Banner ID" }
            f.text_field(:id, readonly: true, 
              class: "w-full bg-zinc-800 border border-zinc-700 rounded-lg px-4 py-2 text-zinc-400")
          end
  
          # Banner Name
          div(class: "form-group") do
            label(for: "banner_name", class: "block text-sm font-medium mb-2") { "Banner Name" }
            f.text_field(:name, 
              class: "w-full bg-zinc-900 border border-zinc-800 rounded-lg px-4 py-2 focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20 focus:outline-none")
          end
  
          # Interval Start/End
          div(class: "form-group") do
            label(class: "block text-sm font-medium mb-2") { "Interval Start/End" }
            div(class: "flex gap-4") do
              input(type: "text", name: "interval_start", id: "interval_start",
                value: @banner.interval_start&.strftime('%m-%d-%Y %H%M'),
                class: "flex-1 bg-zinc-900 border border-zinc-800 rounded-lg px-4 py-2 datepicker")
              span(class: "text-zinc-400") { "to" }
              input(type: "text", name: "interval_end",
                value: @banner.interval_end&.strftime('%m-%d-%Y %H%M'),
                class: "flex-1 bg-zinc-900 border border-zinc-800 rounded-lg px-4 py-2 datepicker")
            end
          end
  
          # Creative Size Options
          render_size_options(f)
  
          # Bid ECPM
          div(class: "form-group") do
            label(for: "banner_bid_ecpm", class: "block text-sm font-medium mb-2") { "Bid ECPM" }
            div(class: "flex items-center gap-2") do
              span(class: "text-zinc-400") { "$" }
              f.number_field(:bid_ecpm, step: 0.01,
                class: "flex-1 bg-zinc-900 border border-zinc-800 rounded-lg px-4 py-2")
            end
          end
  
          # Deals
          render_deals_section(f)
  
          # Content Type
          div(class: "form-group") do
            label(for: "banner_contenttype", class: "block text-sm font-medium mb-2") { "Content Type" }
            f.select(:contenttype,
              [["iFrame", "iframe"], ["HTML", "html"], ["Javascript", "javascript"], ["Override", "override"]],
              { include_blank: true },
              { class: "w-full bg-zinc-900 border border-zinc-800 rounded-lg px-4 py-2" })
          end
  
          # Image URL
          div(class: "form-group") do
            label(for: "banner_iurl", class: "block text-sm font-medium mb-2") { "Image URL" }
            f.text_field(:iurl,
              class: "w-full bg-zinc-900 border border-zinc-800 rounded-lg px-4 py-2")
          end
  
          # HTML Template
          div(class: "form-group") do
            label(for: "editor", class: "block text-sm font-medium mb-2") { "HTML Template" }
            div(id: "editor_container", class: "border border-zinc-800 rounded-lg") do
              div(id: "editor", name: "editor", class: "w-full h-32")
            end
            f.text_area(:htmltemplate, style: "display:none")
          end
  
          # Budget Fields
          div(class: "grid grid-cols-3 gap-4") do
            div(class: "form-group") do
              label(for: "banner_hourly_budget", class: "block text-sm font-medium mb-2") { "Hourly Budget" }
              div(class: "flex items-center gap-2") do
                span(class: "text-zinc-400") { "$" }
                f.number_field(:hourly_budget, step: 0.01,
                  class: "flex-1 bg-zinc-900 border border-zinc-800 rounded-lg px-4 py-2")
              end
            end
  
            div(class: "form-group") do
              label(for: "banner_daily_budget", class: "block text-sm font-medium mb-2") { "Daily Budget" }
              div(class: "flex items-center gap-2") do
                span(class: "text-zinc-400") { "$" }
                f.number_field(:daily_budget, step: 0.01,
                  class: "flex-1 bg-zinc-900 border border-zinc-800 rounded-lg px-4 py-2")
              end
            end
  
            div(class: "form-group") do
              label(for: "banner_total_basket_value", class: "block text-sm font-medium mb-2") { "Total Basket Value" }
              div(class: "flex items-center gap-2") do
                span(class: "text-zinc-400") { "$" }
                f.number_field(:total_basket_value, step: 0.01,
                  class: "flex-1 bg-zinc-900 border border-zinc-800 rounded-lg px-4 py-2")
              end
            end
          end
  
          # Frequency Fields
          div(class: "grid grid-cols-3 gap-4") do
            div(class: "form-group") do
              label(for: "banner_frequency_spec", class: "block text-sm font-medium mb-2") { "Frequency Spec" }
              f.text_field(:frequency_spec,
                class: "w-full bg-zinc-900 border border-zinc-800 rounded-lg px-4 py-2")
            end
  
            div(class: "form-group") do
              label(for: "banner_frequency_expire", class: "block text-sm font-medium mb-2") { "Frequency Expire (minutes)" }
              f.number_field(:frequency_expire,
                class: "w-full bg-zinc-900 border border-zinc-800 rounded-lg px-4 py-2")
            end
  
            div(class: "form-group") do
              label(for: "banner_frequency_count", class: "block text-sm font-medium mb-2") { "Frequency Count" }
              f.number_field(:frequency_count,
                class: "w-full bg-zinc-900 border border-zinc-800 rounded-lg px-4 py-2")
            end
          end
  
          # RTB Standards (Rules)
          div(class: "form-group") do
            label(for: "banner_rtb_standard_ids", class: "block text-sm font-medium mb-2") { "Rules" }
            f.collection_select(:rtb_standard_ids, @rtb_standards, :id, :name, {},
              { multiple: true, class: "w-full bg-zinc-900 border border-zinc-800 rounded-lg px-4 py-2 search_rules" })
          end
  
          # Exchange Attributes
          div(id: "exchange_attributes_div")
  
          # Submit Button
          div(class: "flex justify-end gap-3 pt-6 border-t border-zinc-800") do
            a(href: banners_path, class: "px-4 py-2 bg-zinc-800 hover:bg-zinc-700 rounded-lg transition-colors") { "Cancel" }
            button(type: "submit", class: "px-4 py-2 bg-blue-600 hover:bg-blue-700 rounded-lg transition-colors") { "Update Banner" }
          end
        end
  
        # Add editor initialization script
        render_editor_script
      end
  
      private
  
      def render_errors(f)
        div(id: "error_explanation", class: "bg-red-500/10 border border-red-500/20 rounded-lg p-4 mb-6") do
          h2(class: "text-red-400 font-semibold mb-2") do
            text "#{@banner.errors.count} #{'error'.pluralize(@banner.errors.count)} prohibited this banner from being saved:"
          end
          ul(class: "list-disc list-inside text-red-300 text-sm") do
            @banner.errors.full_messages.each do |message|
              li { message }
            end
          end
        end
      end
  
      def render_size_options(f)
        div(class: "form-group") do
          label(class: "block text-sm font-medium mb-2") { "Creative Size Options" }
          
          size_match_type = determine_size_match_type
          
          div(class: "space-y-3") do
            # Radio options
            div(class: "flex flex-wrap gap-4") do
              ["none", "width_height_only", "width_height_range", "width_height_list"].each do |type|
                label(class: "flex items-center gap-2 cursor-pointer") do
                  input(type: "radio", name: "size_match_type", value: type, 
                    checked: (size_match_type == type),
                    class: "text-blue-600")
                  span(class: "text-sm") { size_match_label(type) }
                end
              end
            end
  
            # Conditional fields
            div(id: "width_height_only_div", style: "display: #{size_match_type == 'width_height_only' ? 'block' : 'none'}") do
              div(class: "grid grid-cols-2 gap-4") do
                div do
                  label(class: "block text-sm mb-1") { "Width (pixels)" }
                  f.number_field(:width, class: "w-full bg-zinc-900 border border-zinc-800 rounded-lg px-4 py-2")
                end
                div do
                  label(class: "block text-sm mb-1") { "Height (pixels)" }
                  f.number_field(:height, class: "w-full bg-zinc-900 border border-zinc-800 rounded-lg px-4 py-2")
                end
              end
            end
  
            div(id: "width_height_range_div", style: "display: #{size_match_type == 'width_height_range' ? 'block' : 'none'}") do
              div(class: "grid grid-cols-2 gap-4") do
                div do
                  label(class: "block text-sm mb-1") { "Width Range (e.g., 300-320)" }
                  f.text_field(:width_range, placeholder: "300-320", 
                    class: "w-full bg-zinc-900 border border-zinc-800 rounded-lg px-4 py-2")
                end
                div do
                  label(class: "block text-sm mb-1") { "Height Range (e.g., 480-600)" }
                  f.text_field(:height_range, placeholder: "480-600",
                    class: "w-full bg-zinc-900 border border-zinc-800 rounded-lg px-4 py-2")
                end
              end
            end
  
            div(id: "width_height_list_div", style: "display: #{size_match_type == 'width_height_list' ? 'block' : 'none'}") do
              label(class: "block text-sm mb-1") { "Width x Height List (e.g., 300x250,320x480)" }
              f.text_field(:width_height_list, placeholder: "300x250,320x480",
                class: "w-full bg-zinc-900 border border-zinc-800 rounded-lg px-4 py-2")
            end
          end
        end
      end
  
      def render_deals_section(f)
        div(class: "form-group") do
          label(class: "block text-sm font-medium mb-2") { "Deals" }
          
          dealtype = determine_deal_type
          
          div(class: "space-y-3") do
            # Radio options
            div(class: "flex gap-4") do
              ["none", "private_only", "private_preferred"].each do |type|
                label(class: "flex items-center gap-2 cursor-pointer") do
                  input(type: "radio", name: "deal_type", value: type,
                    checked: (dealtype == type),
                    class: "text-blue-600")
                  span(class: "text-sm") { deal_type_label(type) }
                end
              end
            end
  
            # Deals table (shown unless dealtype is "none")
            div(id: "deals_table_div", style: "display: #{dealtype == 'none' ? 'none' : 'block'}", class: "mt-4") do
              render_deals_table(dealtype)
            end
          end
        end
      end
  
      def render_deals_table(dealtype)
        table(class: "w-full border border-zinc-800 rounded-lg", id: "deals_table") do
          thead(class: "bg-zinc-900") do
            tr do
              th(class: "px-4 py-2 text-left") { "Deal ID" }
              th(class: "px-4 py-2 text-left") { "Deal Price (ECPM)" }
              th(class: "px-4 py-2 w-16")
            end
          end
          tbody do
            if dealtype == "none" || @banner.deals.nil? || @banner.deals.empty?
              render_deal_row("", "")
            else
              @banner.deals.split(",").each do |deal_str|
                id, price = deal_str.split(":")
                render_deal_row(id, price)
              end
            end
          end
        end
      end
  
      def render_deal_row(deal_id, deal_price)
        tr do
          td(class: "px-4 py-2") do
            input(type: "text", name: "deal_id[]", value: deal_id,
              class: "w-full bg-zinc-900 border border-zinc-800 rounded px-2 py-1")
          end
          td(class: "px-4 py-2") do
            div(class: "flex items-center gap-2") do
              span(class: "text-zinc-400") { "$" }
              input(type: "text", name: "deal_price[]", value: deal_price,
                class: "flex-1 bg-zinc-900 border border-zinc-800 rounded px-2 py-1")
            end
          end
          td(class: "px-4 py-2 text-center") do
            button(type: "button", class: "text-green-500 hover:text-green-400 tableRowAdd") { "+" }
            button(type: "button", class: "text-red-500 hover:text-red-400 tableRowMinus ml-2") { "−" }
          end
        end
      end
  
      def render_editor_script
        script do
          raw <<~JS
            // Size match type toggle
            document.querySelectorAll('[name="size_match_type"]').forEach(radio => {
              radio.addEventListener('change', (e) => {
                ['width_height_only_div', 'width_height_range_div', 'width_height_list_div'].forEach(id => {
                  document.getElementById(id).style.display = 'none';
                });
                if (e.target.value !== 'none') {
                  document.getElementById(e.target.value + '_div').style.display = 'block';
                }
              });
            });
  
            // Deal type toggle
            document.querySelectorAll('[name="deal_type"]').forEach(radio => {
              radio.addEventListener('change', (e) => {
                document.getElementById('deals_table_div').style.display = 
                  e.target.value === 'none' ? 'none' : 'block';
              });
            });
  
            // Deal row add/remove
            document.addEventListener('click', (e) => {
              if (e.target.classList.contains('tableRowAdd')) {
                const row = e.target.closest('tr').cloneNode(true);
                row.querySelectorAll('input').forEach(input => input.value = '');
                e.target.closest('tbody').appendChild(row);
              }
              if (e.target.classList.contains('tableRowMinus')) {
                const tbody = e.target.closest('tbody');
                if (tbody.querySelectorAll('tr').length > 1) {
                  e.target.closest('tr').remove();
                }
              }
            });
          JS
        end
      end
  
      def determine_size_match_type
        if @banner.width.present? || @banner.height.present?
          "width_height_only"
        elsif @banner.width_range.present? || @banner.height_range.present?
          "width_height_range"
        elsif @banner.width_height_list.present?
          "width_height_list"
        else
          "none"
        end
      end
  
      def determine_deal_type
        if @banner.deals.nil? || @banner.deals.empty?
          "none"
        elsif @banner.bid_ecpm.to_i == 0
          "private_only"
        else
          "private_preferred"
        end
      end
  
      def size_match_label(type)
        case type
        when "none" then "Match any width/height"
        when "width_height_only" then "Match specified width/height"
        when "width_height_range" then "Match width/height ranges"
        when "width_height_list" then "Match width/height list"
        end
      end
  
      def deal_type_label(type)
        case type
        when "none" then "No Deals"
        when "private_only" then "Private Only"
        when "private_preferred" then "Private Preferred"
        end
      end
  
      def banners_path
        "/banners"
      end
    end
end
