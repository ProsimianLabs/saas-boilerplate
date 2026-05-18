# Cal.com

## What it is

Cal.com is an open-source scheduling and booking platform. It lets you embed a booking widget in your product or marketing site so users can book time without leaving your app. Webhooks notify your API when bookings are created, rescheduled, cancelled, or no-showed.

## Why it's not bundled

Account-specific — each team's availability, event types, and branding differ. Some users prefer Calendly, SavvyCal, or Tidycal. Self-hosting Cal.com is its own separate infrastructure concern (RDS-backed Next.js app on ECS).

## Cost

Hosted Cal.com has a free tier (unlimited bookings, 1 user) and paid teams plans from ~$12/user/month. Self-hosted is free (MIT licensed) but requires your own infrastructure.

## Step-by-step setup

1. Create an account at cal.com (hosted) or deploy your own instance.
2. In Cal.com Settings → Developer → API Keys, create an API key.
3. In Cal.com Settings → Developer → Webhooks, add a webhook pointing to `https://<your-api>/webhooks/cal`. Select events: `BOOKING_CREATED`, `BOOKING_RESCHEDULED`, `BOOKING_CANCELLED`, `NO_SHOW_UPDATED`.
4. Copy the webhook secret into `CAL_WEBHOOK_SECRET`.
5. Add the embed snippet to `apps/web` or `apps/marketing` (see Cal.com Embed docs — a single `<script>` tag plus `Cal("init")` call).
6. Verify: book a test appointment and confirm the webhook fires to your API.

## Env vars

```bash
CAL_API_KEY=cal_...
CAL_WEBHOOK_SECRET=...
```

## Where it plugs in

- `apps/api/src/routes/webhooks-cal.ts` — webhook handler for booking lifecycle events
- `apps/marketing/src/` — embed snippet for anon booking (e.g., a "Book a demo" page)
- `apps/web/src/` — embed snippet for authenticated users (e.g., "Schedule a call")

## Common gotchas

- The hosted embed requires `@calcom/embed-react` or a plain `<script>` tag; the React package is the cleaner path for `apps/web`.
- Webhook payloads are not signed by default on all Cal.com versions — verify the `CAL_WEBHOOK_SECRET` header if your instance supports it.
- Self-hosted Cal.com requires its own database and does not share the boilerplate's Neon instance.
- Time zone handling: Cal.com sends UTC timestamps; always store and compare in UTC.

## Phase 1 status

Setup guidance documented. Phase 2+ adds `apps/api/src/routes/webhooks-cal.ts` stub with Zod payload schemas for booking events.
