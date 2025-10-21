# Stripe Billing Integration Setup Guide

This document explains how to set up and configure Stripe billing for the AdNexus DSP Campaign Manager.

## Overview

The application uses Stripe for:
- Subscription management (Free, Basic, Pro, Enterprise plans)
- Payment processing
- Invoice generation
- Customer portal for self-service billing management
- Webhook handling for real-time subscription updates

## Prerequisites

1. **Stripe Account**: Sign up at [https://stripe.com](https://stripe.com)
2. **Stripe Test Keys**: Available in your Stripe Dashboard under Developers > API Keys
3. **Rails Credentials**: Configured in your Rails application

## Step 1: Configure Stripe API Keys

### Option A: Using Rails Credentials (Recommended for Production)

```bash
# Edit encrypted credentials
EDITOR="nano" bin/rails credentials:edit

# Add the following to your credentials file:
stripe:
  publishable_key: pk_test_YOUR_KEY_HERE
  secret_key: sk_test_YOUR_KEY_HERE
  webhook_secret: whsec_YOUR_WEBHOOK_SECRET_HERE
```

### Option B: Using Environment Variables (Development)

```bash
# Add to .env file or export in your shell
export STRIPE_PUBLISHABLE_KEY="pk_test_YOUR_KEY_HERE"
export STRIPE_SECRET_KEY="sk_test_YOUR_KEY_HERE"
export STRIPE_WEBHOOK_SECRET="whsec_YOUR_WEBHOOK_SECRET_HERE"
```

## Step 2: Create Stripe Products and Prices

In your Stripe Dashboard:

1. Go to **Products** → **Add Product**
2. Create products for each plan tier:

### Basic Plan
- **Name**: AdNexus Basic
- **Pricing**: $49/month recurring
- **Price ID**: Copy this ID (e.g., `price_1234567890`)
- Set environment variable: `STRIPE_PRICE_BASIC=price_1234567890`

### Pro Plan
- **Name**: AdNexus Professional
- **Pricing**: $199/month recurring
- **Price ID**: Copy this ID
- Set environment variable: `STRIPE_PRICE_PRO=price_your_pro_id`

### Enterprise Plan (Optional)
- **Name**: AdNexus Enterprise
- **Pricing**: Custom
- **Price ID**: Copy this ID
- Set environment variable: `STRIPE_PRICE_ENTERPRISE=price_your_enterprise_id`

## Step 3: Configure Webhook Endpoints

1. Go to **Developers** → **Webhooks** in Stripe Dashboard
2. Click **Add Endpoint**
3. Enter your webhook URL:
   - **Development**: `http://localhost:4000/webhooks/stripe`
   - **Production**: `https://yourdomain.com/webhooks/stripe`

4. Select the following events to listen to:
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`

5. Copy the **Signing Secret** (starts with `whsec_`) and add it to your credentials/env vars

## Step 4: Update Price IDs in Configuration

Edit `config/initializers/stripe.rb` and update the `stripe_price_id` values:

```ruby
STRIPE_PLANS = {
  basic: {
    # ...
    stripe_price_id: ENV['STRIPE_PRICE_BASIC'] || 'price_YOUR_BASIC_PRICE_ID',
  },
  pro: {
    # ...
    stripe_price_id: ENV['STRIPE_PRICE_PRO'] || 'price_YOUR_PRO_PRICE_ID',
  },
  # ...
}
```

## Step 5: Test the Integration

### Local Testing with Stripe CLI

1. **Install Stripe CLI**:
   ```bash
   # macOS
   brew install stripe/stripe-cli/stripe

   # Or download from https://stripe.com/docs/stripe-cli
   ```

2. **Login to Stripe**:
   ```bash
   stripe login
   ```

3. **Forward Webhooks to Localhost**:
   ```bash
   stripe listen --forward-to localhost:4000/webhooks/stripe
   ```

   This command will output a webhook signing secret (whsec_...). Use this for local development.

4. **Trigger Test Events**:
   ```bash
   # Test subscription creation
   stripe trigger customer.subscription.created

   # Test payment success
   stripe trigger invoice.payment_succeeded
   ```

### Manual Testing Flow

1. Start your Rails server:
   ```bash
   bin/rails server -p 4000
   ```

2. Log in to your application

3. Navigate to **Billing & Plans** in the sidebar

4. Click **Change Plan** and select a paid plan

5. Use Stripe test card numbers:
   - **Success**: `4242 4242 4242 4242`
   - **Decline**: `4000 0000 0000 0002`
   - **Insufficient Funds**: `4000 0000 0000 9995`
   - **Expired Card**: Use any expiration date in the past

6. Verify subscription creation in:
   - Application (Billing & Plans page)
   - Stripe Dashboard (Customers section)

## Step 6: Enable Customer Portal

The application uses Stripe Customer Portal for self-service billing management.

1. Go to **Settings** → **Billing** → **Customer Portal** in Stripe Dashboard
2. Enable the portal and configure:
   - **Update payment method**: Enabled
   - **Cancel subscriptions**: Enabled (with cancellation feedback)
   - **Subscription pause**: Optional
3. Set the return URL to your subscriptions page

## Features Implemented

### User Model Enhancements
- Automatic Stripe customer creation
- Subscription management methods
- Plan feature enforcement (campaign/banner limits)
- Trial period handling

### Controllers
- **SubscriptionsController**: Plan selection, subscription creation, cancellation
- **WebhooksController**: Real-time Stripe event handling with signature verification

### Views
- `/subscriptions/new`: Plan selection page
- `/subscriptions`: Current subscription and billing details
- Navigation link in sidebar: "Billing & Plans"

### Subscription Plans

| Plan | Price | Campaigns | Banners | Videos | Support |
|------|-------|-----------|---------|--------|---------|
| Free | $0 | 3 | 10 | 5 | Community |
| Basic | $49/mo | 25 | 100 | 50 | Email |
| Pro | $199/mo | Unlimited | Unlimited | Unlimited | Priority |
| Enterprise | Custom | Unlimited | Unlimited | Unlimited | Dedicated |

All paid plans include a **14-day free trial**.

## Security Considerations

1. **Webhook Signature Verification**: Always enabled to prevent spoofed webhooks
2. **HTTPS Required**: Use SSL in production for secure payment data transmission
3. **PCI Compliance**: Stripe handles all payment data; never store card details
4. **API Key Security**: Never commit API keys to version control

## Troubleshooting

### Webhook Signature Verification Failed
- Ensure webhook secret matches the endpoint in Stripe Dashboard
- Check that you're using the correct environment (test vs production)

### Subscription Not Creating
- Verify Stripe Price IDs are correct
- Check Rails logs for Stripe API errors
- Ensure Stripe keys are properly configured

### Customer Portal Not Loading
- Confirm Customer Portal is enabled in Stripe Dashboard
- Verify user has a valid Stripe customer ID

## Production Deployment Checklist

- [ ] Replace test API keys with production keys
- [ ] Update webhook endpoint to production URL
- [ ] Verify SSL certificate is valid
- [ ] Test full subscription flow in production mode
- [ ] Set up monitoring for webhook failures
- [ ] Configure email notifications (payment failed, subscription canceled)
- [ ] Test subscription cancellation and refund policies

## Additional Resources

- [Stripe Ruby Documentation](https://stripe.com/docs/api/ruby)
- [Stripe Webhooks Guide](https://stripe.com/docs/webhooks)
- [Stripe Testing Cards](https://stripe.com/docs/testing#cards)
- [Stripe Customer Portal](https://stripe.com/docs/billing/subscriptions/customer-portal)

## Support

For issues with the billing integration:
1. Check application logs: `tail -f log/development.log`
2. Check Stripe Dashboard Events tab for API errors
3. Review Stripe CLI output if using local webhook forwarding

---

**Last Updated**: 2025-10-21
**Stripe API Version**: 2024-10-28.acacia
**Stripe Ruby Gem**: 12.6.0
