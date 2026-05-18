# Google Analytics (GA4)

## What it is

Google Analytics 4 is the current Google web analytics platform. It tracks page views, user events, funnels, and audience segments. The Measurement Protocol lets you send server-side events from your API.

## Why it's not bundled

Privacy stance varies by team and market — GDPR and ePrivacy require cookie consent before loading GA4 in the EU/UK. Some products prefer privacy-first alternatives (Plausible, Fathom, Umami) that don't require cookie consent banners.

## Cost

Free with generous limits (10M events/month per property). GA4 360 (enterprise) starts at ~$50k/year.

## Step-by-step setup

1. Go to analytics.google.com → Admin → Create Property. Choose "Web" as the platform.
2. Under Data Streams, copy your **Measurement ID** (`G-XXXXXXXXXX`).
3. Set `VITE_PUBLIC_GA_MEASUREMENT_ID` (for `apps/web`) and the Astro equivalent public env var (for `apps/marketing`).
4. Add the GA4 gtag script to the `<head>` of your layout — load it only after cookie consent is granted (see cookie consent setup in `apps/marketing/src/components/CookieConsent`).
5. Verify: open Google Analytics → Real-time report and confirm events appear after loading your app.

## Env vars

```bash
# apps/web (.env)
VITE_PUBLIC_GA_MEASUREMENT_ID=G-XXXXXXXXXX

# apps/marketing (.env)
PUBLIC_GA_MEASUREMENT_ID=G-XXXXXXXXXX
```

## Where it plugs in

- `apps/marketing/src/layouts/BaseLayout.astro` — gtag script tag (consent-gated)
- `apps/web/src/main.tsx` or layout component — gtag initialization (consent-gated)

## Common gotchas

- In the EU/UK, GA4 must not load before the user grants analytics consent. The bundled `cookieconsent` library fires a `consent-change` event you can listen to before calling `gtag('consent', 'update', ...)`.
- GA4 uses a different data model than Universal Analytics (UA) — event-based, no sessions/hit types. Migrating UA custom dimensions to GA4 requires rethinking the event taxonomy.
- Cross-domain tracking (e.g., `marketing.example.com` → `app.example.com`) requires configuring linked domains in GA4 settings.
- Measurement Protocol (server-side events) requires `api_secret` in addition to the Measurement ID. Do not expose this on the client.

## Phase 1 status

Setup guidance documented. Phase 2+ adds consent-gated gtag initialization snippets in the marketing and web app layouts.
