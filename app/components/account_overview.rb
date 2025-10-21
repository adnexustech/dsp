# frozen_string_literal: true

module Components
  class AccountOverview < Phlex::HTML
    include Phlex::Rails::Helpers::Routes
    include Phlex::Rails::Helpers::FormWith

    def initialize(user:)
      @user = user
    end

    def view_template
      div(class: "page-content") do
        render_stats_grid
        render_main_content_grid
        render_recent_activity
      end

      render_edit_profile_modal
    end

    private

    def render_stats_grid
      div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8") do
        # Credits Balance
        render UI::StatCard.new(
          title: "Credits Balance",
          value: "$#{'%.2f' % @user.credits_balance}",
          icon: "fa-solid fa-dollar-sign text-green-500",
          link_text: "Add Credits",
          link_url: new_credit_path,
          value_color: "green-500"
        )

        # Subscription
        subscription_link = @user.active_subscription? ? nil : new_subscription_path
        subscription_text = @user.active_subscription? ? "Active" : "Upgrade"
        
        render UI::StatCard.new(
          title: "Subscription",
          value: @user.subscription_plan&.titleize || 'Free',
          icon: "fa-regular fa-credit-card text-blue-500",
          link_text: subscription_text,
          link_url: subscription_link,
          value_color: @user.active_subscription? ? "green-500" : "blue-500"
        )

        # Active Campaigns
        render UI::StatCard.new(
          title: "Active Campaigns",
          value: Campaign.count.to_s,
          icon: "fa-solid fa-bullhorn text-purple-500",
          link_text: "View All",
          link_url: campaigns_path,
          value_color: "white"
        )

        # Member Since
        render UI::StatCard.new(
          title: "Member Since",
          value: @user.created_at.strftime('%b %Y'),
          icon: "fa-regular fa-calendar text-zinc-500",
          link_text: "Active account",
          value_color: "white"
        )
      end
    end

    def render_main_content_grid
      div(class: "grid grid-cols-1 lg:grid-cols-2 gap-4 mb-8") do
        render_profile_card
        render_quick_links_card
      end
    end

    def render_profile_card
      render UI::Card.new do
        # Header
        div(class: "flex items-center justify-between mb-6") do
          h2(class: "text-xl font-semibold flex items-center gap-3") do
            i(class: "fa-regular fa-user text-zinc-400 text-lg")
            text "Profile Information"
          end

          render UI::Button.new(
            variant: :secondary,
            size: :sm,
            onclick: "document.getElementById('editProfileModal').classList.remove('hidden')",
            icon: "fa-solid fa-pencil text-xs"
          ) { "Edit" }
        end

        # Profile data
        div(class: "space-y-4") do
          profile_row("Name", @user.name)
          profile_row("Email", @user.email)
          profile_row("Member Since", @user.created_at.strftime('%B %d, %Y'))
          
          # Account Type with badge
          div(class: "flex justify-between") do
            span(class: "text-zinc-400") { "Account Type" }
            if @user.admin
              render UI::Badge.new(variant: :danger, size: :sm) { "Administrator" }
            else
              render UI::Badge.new(variant: :primary, size: :sm) { "User" }
            end
          end
        end
      end
    end

    def render_quick_links_card
      render UI::Card.new do
        h2(class: "text-xl font-semibold mb-6 flex items-center gap-3") do
          i(class: "fa-solid fa-link text-zinc-400 text-lg")
          text "Quick Links"
        end

        div(class: "space-y-1") do
          render UI::QuickLink.new(
            url: credits_path,
            title: "Credits & Wallet",
            icon: "fa-solid fa-dollar-sign text-green-500",
            badge: "$#{'%.2f' % @user.credits_balance}",
            badge_variant: :success
          )

          render UI::QuickLink.new(
            url: subscriptions_path,
            title: "Subscription & Billing",
            icon: "fa-regular fa-credit-card text-blue-500",
            badge: @user.subscription_plan&.titleize || 'Free',
            badge_variant: :primary
          )

          render UI::QuickLink.new(
            url: invoices_path,
            title: "Invoices & Receipts",
            icon: "fa-regular fa-file-lines text-zinc-400"
          )

          render UI::QuickLink.new(
            url: campaigns_path,
            title: "My Campaigns",
            icon: "fa-solid fa-bullhorn text-red-500",
            badge: Campaign.count.to_s,
            badge_variant: :default
          )

          render UI::QuickLink.new(
            url: banners_path,
            title: "My Banners",
            icon: "fa-regular fa-image text-purple-500"
          )
        end
      end
    end

    def render_recent_activity
      render UI::Card.new do
        h2(class: "text-xl font-semibold mb-6 flex items-center gap-3") do
          i(class: "fa-solid fa-clock-rotate-left text-zinc-400 text-lg")
          text "Recent Activity"
        end

        recent_transactions = @user.credit_transactions.recent.limit(5)
        
        if recent_transactions.any?
          render_transactions_table(recent_transactions)
        else
          p(class: "text-zinc-500 text-center py-8") { "No recent activity" }
        end
      end
    end

    def render_transactions_table(transactions)
      div(class: "overflow-x-auto") do
        table(class: "w-full") do
          thead do
            tr(class: "border-b border-zinc-800") do
              th(class: "text-left text-zinc-400 font-medium text-sm pb-3 uppercase tracking-wide") { "Date" }
              th(class: "text-left text-zinc-400 font-medium text-sm pb-3 uppercase tracking-wide") { "Type" }
              th(class: "text-left text-zinc-400 font-medium text-sm pb-3 uppercase tracking-wide") { "Description" }
              th(class: "text-right text-zinc-400 font-medium text-sm pb-3 uppercase tracking-wide") { "Amount" }
            end
          end
          tbody do
            transactions.each do |tx|
              tr(class: "border-b border-zinc-800 hover:bg-zinc-800/50 transition-colors") do
                td(class: "py-4 text-zinc-300 text-sm") { tx.created_at.strftime('%b %d, %Y %I:%M %p') }
                td(class: "py-4") do
                  variant = tx.credit? ? :success : :danger
                  render UI::Badge.new(variant: variant, size: :sm) { tx.transaction_type.titleize }
                end
                td(class: "py-4 text-zinc-300 text-sm") { tx.description }
                td(class: "py-4 text-right font-semibold #{tx.credit? ? 'text-green-500' : 'text-red-500'}") do
                  text tx.signed_amount
                end
              end
            end
          end
        end
      end

      div(class: "mt-6") do
        a(
          href: credits_path,
          class: "inline-flex items-center gap-2 text-blue-500 hover:text-blue-400 text-sm font-medium transition-colors"
        ) do
          text "View All Transactions"
          i(class: "fa-solid fa-arrow-right text-xs")
        end
      end
    end

    def render_edit_profile_modal
      render UI::Modal.new(id: "editProfileModal", title: "Edit Profile") do
        form_with model: @user, url: myaccountUpdate_path, method: :patch, local: true, class: 'space-y-4' do |f|
          # Name field
          div do
            render UI::Label.new(for_id: "user_name", required: true) { "Name" }
            render UI::Input.new(
              name: "user[name]",
              value: @user.name,
              required: true,
              id: "user_name"
            )
          end

          # Email field
          div do
            render UI::Label.new(for_id: "user_email", required: true) { "Email" }
            render UI::Input.new(
              type: :email,
              name: "user[email]",
              value: @user.email,
              required: true,
              id: "user_email"
            )
          end

          # Password section
          div(class: "border-t border-zinc-800 pt-4") do
            p(class: "text-zinc-500 text-sm mb-4") { "Leave password fields blank to keep current password" }

            div(class: "mb-4") do
              render UI::Label.new(for_id: "user_password") { "New Password" }
              render UI::Input.new(
                type: :password,
                name: "user[password]",
                placeholder: "Leave blank to keep current",
                id: "user_password"
              )
            end

            div do
              render UI::Label.new(for_id: "user_password_confirmation") { "Password Confirmation" }
              render UI::Input.new(
                type: :password,
                name: "user[password_confirmation]",
                id: "user_password_confirmation"
              )
            end
          end

          # Actions
          div(class: "flex gap-3 pt-4") do
            render UI::Button.new(
              variant: :secondary,
              size: :md,
              type: :button,
              onclick: "document.getElementById('editProfileModal').classList.add('hidden')"
            ) { "Cancel" }

            render UI::Button.new(
              variant: :primary,
              size: :md,
              type: :submit
            ) { "Update Profile" }
          end
        end
      end
    end

    def profile_row(label, value)
      div(class: "flex justify-between border-b border-zinc-800 pb-3") do
        span(class: "text-zinc-400") { label }
        span(class: "font-medium") { value }
      end
    end
  end
end
