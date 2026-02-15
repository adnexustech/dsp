# frozen_string_literal: true

# Hanzo IAM OAuth configuration
# Mirrors the Go pkg/auth setup for consistent behavior across services.
#
# Env vars (same as Go DSP/SSP):
#   AUTH_ENABLED       - Enable IAM auth (default: false)
#   AUTH_IAM_DOMAIN    - IAM domain for login + token exchange (default: id.ad.nexus)
#   AUTH_CLIENT_ID     - OAuth client ID
#   AUTH_CLIENT_SECRET - OAuth client secret
#   AUTH_JWT_SECRET    - HMAC-SHA256 shared secret for JWT validation

Rails.application.config.hanzo_auth = ActiveSupport::OrderedOptions.new.tap do |auth|
  auth.enabled       = ENV.fetch("AUTH_ENABLED", "false").downcase == "true"
  auth.iam_domain    = ENV.fetch("AUTH_IAM_DOMAIN", "id.ad.nexus")
  auth.client_id     = ENV.fetch("AUTH_CLIENT_ID", "adnexus-app")
  auth.client_secret = ENV.fetch("AUTH_CLIENT_SECRET", "")
  auth.jwt_secret    = ENV.fetch("AUTH_JWT_SECRET", "")
  auth.cookie_name   = ENV.fetch("AUTH_COOKIE_NAME", "adnexus_session")
end
