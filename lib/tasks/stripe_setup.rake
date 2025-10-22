namespace :stripe do
  desc "Set up all Stripe products, prices, and configuration"
  task setup: :environment do
    puts "🎨 Setting up Stripe products and prices..."

    # Ensure Stripe is configured
    unless Stripe.api_key
      puts "❌ Error: STRIPE_SECRET_KEY not set"
      puts "Set it with: export STRIPE_SECRET_KEY=sk_test_..."
      exit 1
    end

    # Define all plans with pricing
    plans = {
      basic: {
        name: 'Starter Plan',
        description: '1 campaign, 6,600 CTV views/month, 3% cashback, 100 min unskippable',
        price: 9900, # $99.00 in cents
        interval: 'month'
      },
      pro: {
        name: 'Growth Plan',
        description: '5 campaigns, 19,933 CTV views/month, 6% cashback, 300 min unskippable',
        price: 29900, # $299.00 in cents
        interval: 'month'
      },
      business: {
        name: 'Business Plan',
        description: '15 campaigns, 33,267 CTV views/month, 9% cashback, 600 min unskippable',
        price: 49900, # $499.00 in cents
        interval: 'month'
      }
    }

    created_prices = {}

    plans.each do |plan_key, plan_data|
      puts "\n📦 Creating #{plan_data[:name]}..."

      begin
        # Create product
        product = Stripe::Product.create({
          name: plan_data[:name],
          description: plan_data[:description],
          metadata: {
            plan_key: plan_key.to_s,
            app: 'adnexus-dsp'
          }
        })

        puts "  ✓ Product created: #{product.id}"

        # Create price for this product
        price = Stripe::Price.create({
          product: product.id,
          unit_amount: plan_data[:price],
          currency: 'usd',
          recurring: {
            interval: plan_data[:interval]
          },
          metadata: {
            plan_key: plan_key.to_s
          }
        })

        puts "  ✓ Price created: #{price.id}"
        puts "  💰 Price: $#{plan_data[:price] / 100.0}/month"

        created_prices[plan_key] = price.id

      rescue Stripe::StripeError => e
        puts "  ❌ Error: #{e.message}"
      end
    end

    # Output configuration
    puts "\n" + "="*60
    puts "✅ Stripe setup complete!"
    puts "="*60
    puts "\nAdd these to your .env file or Rails credentials:\n\n"

    puts "STRIPE_PRICE_BASIC=#{created_prices[:basic]}"
    puts "STRIPE_PRICE_PRO=#{created_prices[:pro]}"
    puts "STRIPE_PRICE_BUSINESS=#{created_prices[:business]}"

    puts "\n" + "="*60
    puts "📋 Next steps:"
    puts "="*60
    puts "1. Add the Price IDs above to your .env file"
    puts "2. Enable Customer Portal: https://dashboard.stripe.com/test/settings/billing/portal"
    puts "3. Set up webhooks: https://dashboard.stripe.com/test/webhooks"
    puts "   Endpoint: https://yourdomain.com/webhooks/stripe"
    puts "   Events: subscription.*, invoice.*, payment_intent.*"
    puts "4. Restart your Rails server"
    puts "\nTest cards:"
    puts "  Success: 4242 4242 4242 4242"
    puts "  Decline: 4000 0000 0000 0002"
    puts "="*60
  end

  desc "Create webhook endpoint"
  task setup_webhook: :environment do
    puts "🔗 Creating webhook endpoint..."

    webhook_url = ENV['WEBHOOK_URL'] || 'https://yourdomain.com/webhooks/stripe'

    begin
      webhook = Stripe::WebhookEndpoint.create({
        url: webhook_url,
        enabled_events: [
          'customer.subscription.created',
          'customer.subscription.updated',
          'customer.subscription.deleted',
          'invoice.payment_succeeded',
          'invoice.payment_failed',
          'payment_intent.succeeded',
          'payment_intent.payment_failed'
        ],
        description: 'AdNexus DSP Webhook'
      })

      puts "✅ Webhook created!"
      puts "Secret: #{webhook.secret}"
      puts "\nAdd to your environment:"
      puts "STRIPE_WEBHOOK_SECRET=#{webhook.secret}"

    rescue Stripe::StripeError => e
      puts "❌ Error: #{e.message}"
    end
  end

  desc "Test Stripe connection"
  task test: :environment do
    puts "🧪 Testing Stripe connection..."

    begin
      # Try to retrieve account
      account = Stripe::Account.retrieve
      puts "✅ Connected to Stripe!"
      puts "Account ID: #{account.id}"
      puts "Account Name: #{account.business_profile.name || 'N/A'}"
      puts "Mode: #{Stripe.api_key.start_with?('sk_test') ? 'TEST' : 'LIVE'}"

      # List existing products
      products = Stripe::Product.list(limit: 10)
      puts "\n📦 Existing Products: #{products.data.length}"
      products.data.each do |product|
        puts "  - #{product.name} (#{product.id})"
      end

    rescue Stripe::StripeError => e
      puts "❌ Error: #{e.message}"
      puts "\nMake sure STRIPE_SECRET_KEY is set:"
      puts "export STRIPE_SECRET_KEY=sk_test_..."
    end
  end
end
