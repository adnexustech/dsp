# frozen_string_literal: true

# Configure Zeitwerk autoloading for Phlex components.
# Files in app/components/ define constants under the Components:: namespace
# (e.g., app/components/account_overview.rb -> Components::AccountOverview)
module ::Components; end unless defined?(::Components)

Rails.autoloaders.main.inflector.inflect("ui" => "UI")
Rails.autoloaders.main.push_dir(
  Rails.root.join("app/components"),
  namespace: ::Components
)
