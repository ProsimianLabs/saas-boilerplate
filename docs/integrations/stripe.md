# Stripe

## What it is

Stripe is the industry-standard payment platform for SaaS. It handles subscriptions, one-time payments, invoicing, the customer portal, and webhook-driven billing events. The API is best-in-class and the Node SDK is actively maintained.

## Why it's not bundled

Billing models vary too widely — flat subscription, tiered subscription, usage-based metering, seat-based, hybrid, free tier + paid plans, one-time payments, and marketplaces each require materially different data models, webhook handlers, and reconciliation logic.

## Cost

Free to integrate; Stripe charges 2.9% + 30¢ per successful card charge (US). No monthly fee. Volume discounts negotiated after $1M ARR.

## Step-by-step setup

1. Create a Stripe account at stripe.com; verify your business and banking details for live mode.
2. In the Stripe Dashboard → Developers → API keys, copy your **Publishable key** and **Secret key**. Use the `pk_test_` / `sk_test_` pair for staging; `pk_live_` / `sk_live_` for production.
3. Set the env vars (see below) in your staging SSM path; live keys go only in the production SSM path.
4. In Stripe Dashboard → Developers → Webhooks, add an endpoint pointing to `https://<your-api>/webhooks/stripe`. Select all events you need (at minimum `invoice.payment_succeeded`, `customer.subscription.updated`, `customer.subscription.deleted`).
5. Copy the **Webhook signing secret** (`whsec_...`) into `STRIPE_WEBHOOK_SECRET`.
6. Verify: trigger a test event from the Stripe dashboard and confirm a 200 response in the webhook logs.

## Env vars

```bash
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

## Where it plugs in

- `apps/api/src/routes/webhooks-stripe.ts` — webhook handler (signature verification + idempotency dispatch)
- `apps/web/src/` — Stripe.js / React Stripe Elements for checkout
- `apps/api/src/routes/billing.ts` — customer portal session, checkout session creation

## Common gotchas

- Never log the raw webhook body after reading it; Stripe signature verification requires the raw bytes.
- Use the idempotency table (`WebhookEvent`) to deduplicate — Stripe retries on non-2xx for up to 72 hours.
- Staging must use `sk_test_` keys only; a CI check enforces this.
- Customer portal requires you to enable it in Stripe Dashboard → Settings → Billing → Customer portal.

## Phase 1 status

Setup guidance documented. Phase 2+ adds the webhook handler stub with signature verification, idempotency middleware, and a dispatch table skeleton in `apps/api/src/routes/webhooks-stripe.ts`.
