# Stripe Integration Setup Checklist

## ✅ Completed Steps

1. **API Keys Configured** - LIVE mode keys are in `.env`
2. **Products Created** - 3 subscription products created via `rails stripe:setup`
3. **Price IDs Set** - Environment variables updated with Stripe Price IDs
4. **dotenv-rails Installed** - `.env` file now loads automatically
5. **Subscribe Button Fixed** - Checkout sessions create properly

## 🔧 Required: Stripe Dashboard Configuration

### 1. Enable Customer Portal (REQUIRED for "Manage Payment Methods")

**Status:** ⚠️ NOT ENABLED - This is why "Manage Payment Methods" isn't working

**Steps:**
1. Go to https://dashboard.stripe.com/settings/billing/portal
2. Click **"Activate"** button
3. Configure Portal Settings:
   - ✅ **Allow customers to:** Update payment methods
   - ✅ **Allow customers to:** View invoice history
   - ✅ **Allow customers to:** Cancel subscriptions (optional)
   - ⚠️ **DO NOT allow:** Switching plans (handle via app UI)

**Testing:**
After activation, clicking "Manage Payment Methods" in the app will redirect users to Stripe's secure portal.

### 2. Configure Webhook Endpoint (REQUIRED for subscription updates)

**Status:** ⚠️ NOT CONFIGURED

**Steps:**
1. Go to https://dashboard.stripe.com/webhooks
2. Click **"Add endpoint"**
3. Enter URL: `https://yourdomain.com/webhooks/stripe` (or ngrok for testing)
4. Select events to listen for:
   - ✅ `customer.subscription.created`
   - ✅ `customer.subscription.updated`
   - ✅ `customer.subscription.deleted`
   - ✅ `invoice.payment_succeeded`
   - ✅ `invoice.payment_failed`
5. Copy the **Signing secret** (starts with `whsec_...`)
6. Update `.env`: `STRIPE_WEBHOOK_SECRET=whsec_...`

**Why it's needed:**
Without webhooks, the app won't know when:
- A subscription is canceled
- A payment fails
- A subscription renews

### 3. Test with Stripe Test Cards (OPTIONAL - already using LIVE mode)

If you want to test WITHOUT real charges:

**Steps:**
1. Switch to Stripe TEST API keys in `.env`
2. Use test card numbers:
   - Success: `4242 4242 4242 4242`
   - Decline: `4000 0000 0000 0002`
   - 3D Secure: `4000 0025 0000 3155`
3. Use any future expiry date (e.g., `12/34`)
4. Use any 3-digit CVC (e.g., `123`)

**Production Note:** You're already using LIVE keys, so real cards will be charged!

## 🧪 Testing Checklist

### Subscribe Flow Test
- [ ] Visit `/subscriptions/new`
- [ ] Click "Subscribe" on Starter plan
- [ ] Redirected to Stripe Checkout page
- [ ] Enter real payment card details
- [ ] Complete checkout
- [ ] Redirected back to `/subscriptions`
- [ ] Verify subscription shows as "Active"

### Customer Portal Test
- [ ] Visit `/subscriptions` (billing dashboard)
- [ ] Click "Manage Payment Methods"
- [ ] Redirected to Stripe Customer Portal
- [ ] Can update payment method
- [ ] Can view invoice history
- [ ] Redirected back to app after clicking "Return to..."

### Webhook Test
- [ ] Cancel subscription in Stripe Dashboard
- [ ] Verify user's `subscription_status` updates to "canceled" in database
- [ ] Verify user still has access until period end
- [ ] After period ends, verify access is removed

## 📝 Current Environment Variables

```bash
# Stripe API Keys (LIVE MODE)
STRIPE_PUBLISHABLE_KEY=pk_live_51S19nxAn5SgXrDal...
STRIPE_SECRET_KEY=sk_live_51S19nxAn5SgXrDal...

# Stripe Webhook Secret
STRIPE_WEBHOOK_SECRET=whsec_5r1bkM08S6wW11UpOtuXbcDTd7iLSdsU

# Stripe Price IDs (LIVE)
STRIPE_PRICE_BASIC=price_1SKujHAn5SgXrDalZOnWkUUk      # Starter $99/mo
STRIPE_PRICE_PRO=price_1SKujIAn5SgXrDal2wUXgT9m        # Growth $299/mo
STRIPE_PRICE_BUSINESS=price_1SKujIAn5SgXrDalJKdhPidf  # Business $499/mo
```

## 🚀 Production Deployment

### Before Going Live:
1. ✅ All Stripe Dashboard settings configured
2. ✅ Webhook endpoint created and working
3. ✅ Customer Portal enabled
4. ✅ Test complete subscribe flow
5. ⚠️ SSL certificate installed (HTTPS required by Stripe)
6. ⚠️ Domain verified and webhook URL accessible

### Security Checks:
1. ✅ API keys in environment variables (NOT committed to git)
2. ✅ `.env` file in `.gitignore`
3. ✅ Webhook signature verification enabled
4. ⚠️ Rate limiting on subscription endpoints
5. ⚠️ CSRF protection enabled (Rails default)

## 📞 Support

**Stripe Support:**
- Dashboard: https://dashboard.stripe.com
- Documentation: https://stripe.com/docs
- Support: https://support.stripe.com

**AdNexus DSP:**
- GitHub Issues: https://github.com/adnexustech/dsp/issues

## 🎯 Next Steps

1. **URGENT:** Enable Stripe Customer Portal
   - Go to https://dashboard.stripe.com/settings/billing/portal
   - Click "Activate"

2. **IMPORTANT:** Configure Webhooks
   - Set up webhook endpoint
   - Update STRIPE_WEBHOOK_SECRET
   - Test webhook deliveries

3. **TEST:** Complete subscribe flow end-to-end
   - Use a real card (you're in LIVE mode)
   - Verify everything works before launch

4. **OPTIONAL:** Set up test environment
   - Create separate test API keys
   - Test without real charges
   - Verify all flows work

---

**Status:** ⚠️ **Almost Ready** - Just need to enable Customer Portal and configure webhooks in Stripe Dashboard!
