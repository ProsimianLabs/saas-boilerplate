# Intercom

## What it is

Intercom is a customer messaging platform providing live chat, in-app support, automated bots, and product tours. It appears as a chat widget in the corner of your app. Authenticated users can be identified so support agents see account details; anonymous visitors get a lighter-weight experience.

## Why it's not bundled

Vendor lock-in and cost — Intercom pricing starts at ~$74/month and scales steeply. Many teams prefer Crisp (cheaper), Chatwoot (open-source), Plain (developer-focused), or Zendesk (enterprise).

## Cost

Starter plan ~$74/month (2 seats). Pro plans scale with seat count and features. Free trial available.

## Step-by-step setup

1. Create an account at intercom.com and set up a workspace.
2. In Intercom Settings → Workspace → Installation, find your **App ID** (looks like `abc1def2`).
3. Set `VITE_PUBLIC_INTERCOM_APP_ID` (and the Astro public equivalent).
4. Add the Intercom boot snippet to your app layout. For authenticated users, pass `user_id`, `email`, `name`, and `created_at` to `window.Intercom('boot', {...})`. For anonymous visitors, boot without identity.
5. For identity verification (recommended — prevents user impersonation in chat), generate an HMAC on the server using `INTERCOM_SECRET_KEY` and pass it as `user_hash`.
6. Verify: open your app and confirm the Intercom widget appears. Send a test message.

## Env vars

```bash
# Client-side
VITE_PUBLIC_INTERCOM_APP_ID=abc1def2

# Server-side (for identity verification HMAC)
INTERCOM_SECRET_KEY=...
```

## Where it plugs in

- `apps/web/src/` — authenticated user boot (with identity verification HMAC)
- `apps/marketing/src/layouts/BaseLayout.astro` — anonymous visitor boot (functional consent category)
- `apps/api/src/routes/intercom-identity.ts` — server endpoint to generate identity verification hash

## Common gotchas

- Boot Intercom **after** cookie consent for the `functional` category (the boilerplate's `cookieconsent` setup includes a `functional` category for this purpose).
- Identity verification (HMAC) is strongly recommended in production to prevent users from impersonating other users in chat. Never skip this in production.
- The Intercom JS snippet must be loaded once; avoid double-booting on SPA route changes (call `Intercom('update')` instead on navigation).
- GDPR data residency: Intercom stores chat data in the US by default; EU data residency is available on higher plans.

## Phase 1 status

Setup guidance documented. Phase 2+ adds the identity verification endpoint and consent-gated boot snippet in the web app layout.
