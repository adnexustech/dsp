# Stripe Configuration
#
# To set up Stripe API keys, run:
#   EDITOR="nano" bin/rails credentials:edit
#
# Add the following to credentials:
#   stripe:
#     publishable_key: pk_test_...
#     secret_key: sk_test_...
#     webhook_secret: whsec_...
#

Rails.configuration.stripe = {
  publishable_key: ENV['STRIPE_PUBLISHABLE_KEY'] || Rails.application.credentials.dig(:stripe, :publishable_key),
  secret_key: ENV['STRIPE_SECRET_KEY'] || Rails.application.credentials.dig(:stripe, :secret_key),
  webhook_secret: ENV['STRIPE_WEBHOOK_SECRET'] || Rails.application.credentials.dig(:stripe, :webhook_secret)
}

# Initialize Stripe with secret key
Stripe.api_key = Rails.configuration.stripe[:secret_key]

# Subscription plan configuration
# These should match your Stripe Price IDs from the Stripe Dashboard
STRIPE_PLANS = {
  free: {
    name: 'Free',
    price: 0,
    stripe_price_id: nil,
    features: {
      campaigns_limit: 3,
      banners_limit: 10,
      videos_limit: 5,
      support: 'Community'
    }
  },
  basic: {
    name: 'Basic',
    price: 49_00, # $49.00 in cents
    stripe_price_id: ENV['STRIPE_PRICE_BASIC'] || 'price_basic',
    features: {
      campaigns_limit: 25,
      banners_limit: 100,
      videos_limit: 50,
      support: 'Email'
    }
  },
  pro: {
    name: 'Professional',
    price: 199_00, # $199.00 in cents
    stripe_price_id: ENV['STRIPE_PRICE_PRO'] || 'price_pro',
    features: {
      campaigns_limit: nil, # Unlimited
      banners_limit: nil,   # Unlimited
      videos_limit: nil,    # Unlimited
      support: 'Priority Email & Phone'
    }
  },
  enterprise: {
    name: 'Enterprise',
    price: nil, # Custom pricing
    stripe_price_id: ENV['STRIPE_PRICE_ENTERPRISE'] || 'price_enterprise',
    features: {
      campaigns_limit: nil,
      banners_limit: nil,
      videos_limit: nil,
      support: 'Dedicated Account Manager',
      whitelabel: true,
      custom_features: true
    }
  }
}.freeze
