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

# Subscription plan configuration - Pay As You Go CTV Advertising
# Performance Network only - $15 CPM minimum, $25/day minimum ad spend
# These should match your Stripe Price IDs from the Stripe Dashboard
STRIPE_PLANS = {
  free: {
    name: 'Pay As You Go',
    price: 0,
    stripe_price_id: nil,
    features: {
      cashback: 'No monthly commitment',
      ctv_views: '0', # Buy credits as needed
      campaigns_limit: 1,
      support: 'Email'
    }
  },
  basic: {
    name: 'Starter',
    price: 99_00, # $99.00/mo in cents
    stripe_price_id: ENV['STRIPE_PRICE_BASIC'] || 'price_basic',
    features: {
      cashback: '3% ad spend cashback',
      ctv_views: '6,600', # $99 / ($15/1000) = 6,600 views
      campaigns_limit: 1,
      support: 'Email',
      unskippable: '100 min/month unskippable'
    }
  },
  pro: {
    name: 'Growth',
    price: 299_00, # $299.00/mo in cents
    stripe_price_id: ENV['STRIPE_PRICE_PRO'] || 'price_pro',
    features: {
      cashback: '6% ad spend cashback',
      ctv_views: '19,933', # $299 / ($15/1000) = 19,933 views
      campaigns_limit: 5,
      support: 'Priority Email & Phone',
      unskippable: '300 min/month unskippable'
    }
  },
  business: {
    name: 'Business',
    price: 499_00, # $499.00/mo in cents
    stripe_price_id: ENV['STRIPE_PRICE_BUSINESS'] || 'price_business',
    features: {
      cashback: '9% ad spend cashback',
      ctv_views: '33,267', # $499 / ($15/1000) = 33,267 views
      campaigns_limit: 15,
      support: 'Priority Support + Account Manager',
      unskippable: '600 min/month unskippable'
    }
  },
  enterprise: {
    name: 'Enterprise',
    price: nil, # Custom pricing
    stripe_price_id: nil,
    features: {
      cashback: 'Custom enterprise pricing',
      ctv_views: 'Unlimited',
      campaigns_limit: nil,
      support: 'Dedicated Account Manager',
      premium: true,
      unskippable: 'Up to 1M min/month unskippable'
    }
  },
  agency: {
    name: 'Agency',
    price: nil, # Custom pricing
    stripe_price_id: nil,
    features: {
      cashback: 'Custom agency rates',
      ctv_views: 'Unlimited',
      campaigns_limit: nil,
      support: 'White-label & Reseller Support',
      whitelabel: true,
      reseller: true
    }
  }
}.freeze
