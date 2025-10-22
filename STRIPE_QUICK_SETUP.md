# Stripe Quick Setup Guide

## Issue: Subscribe & Manage Payment Methods Not Working

**Problem:** Placeholder Price IDs like 'price_basic', 'price_pro' don't exist in Stripe.

## Quick Fix (5 minutes)

### 1. Create Products in Stripe Dashboard

1. Go to https://dashboard.stripe.com/test/products
2. Click **+ Add product** for each plan:

**Starter Plan:**
- Name: `Starter Plan`
- Price: `$99.00 USD` / month
- Copy the Price ID (starts with `price_...`)

**Growth Plan:**
- Name: `Growth Plan`
- Price: `$299.00 USD` / month
- Copy the Price ID

**Business Plan:**
- Name: `Business Plan`
- Price: `$499.00 USD` / month
- Copy the Price ID

### 2. Set Environment Variables

Add to your `.env` file or environment:

```bash
# Stripe API Keys
STRIPE_PUBLISHABLE_KEY=pk_test_your_key_here
STRIPE_SECRET_KEY=sk_test_your_key_here

# Stripe Price IDs (from step 1)
STRIPE_PRICE_BASIC=price_1ABC123xyz
STRIPE_PRICE_PRO=price_1DEF456xyz
STRIPE_PRICE_BUSINESS=price_1GHI789xyz
```

### 3. Enable Customer Portal (for "Manage Payment Methods")

1. Go to https://dashboard.stripe.com/test/settings/billing/portal
2. Click **Activate test link**
3. Under "Functionality":
   - ✅ Enable "Update payment method"
   - ✅ Enable "View invoice history"
4. Click **Save**

### 4. Restart Rails Server

```bash
# Kill current server
pkill -f "rails server"

# Start with new environment variables
rails server -p 4000
```

## Testing Subscribe Flow

1. Go to http://localhost:4000/subscriptions/new
2. Click **Subscribe** on any paid plan
3. You should be redirected to Stripe Checkout
4. Use test card: `4242 4242 4242 4242` (any future expiry, any CVV)
5. Complete payment
6. You'll be redirected back to your app

## Testing Manage Payment Methods

1. Go to http://localhost:4000/subscriptions
2. Click **Manage Payment Methods**
3. You should be redirected to Stripe Customer Portal
4. You can update cards, view invoices, etc.

## Common Errors

**"No such price: 'price_basic'"**
- Solution: Set real Price IDs from Stripe Dashboard

**"No API key provided"**
- Solution: Set STRIPE_SECRET_KEY environment variable

**"Billing portal not enabled"**
- Solution: Activate Customer Portal in Stripe Dashboard (step 3)

## Production Setup

For production, repeat the same steps but:
1. Use **Live mode** in Stripe Dashboard (toggle in top-right)
2. Use live API keys (`pk_live_...` and `sk_live_...`)
3. Create products with live Price IDs
4. Enable production Customer Portal

---

**Need help?** Check the full guide in `STRIPE_SETUP.md`
