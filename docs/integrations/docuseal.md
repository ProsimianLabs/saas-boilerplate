# Docuseal

## What it is

Docuseal is an open-source e-signature platform. You upload document templates, send them to signers via API, and receive webhook events when documents are completed or declined. An embed option lets signers sign without leaving your app.

## Why it's not bundled

Account-specific — each product has different document templates, branding, and signer workflows. Some teams prefer DocuSign or HelloSign/Dropbox Sign; others want to self-host Docuseal on their own infrastructure.

## Cost

Hosted Docuseal (docuseal.com): free tier (100 submissions/month), paid from $30/month. Self-hosted: free (AGPL licensed for self-hosted, commercial license available).

## Step-by-step setup

1. Create an account at docuseal.com (hosted) or deploy your own instance.
2. In Docuseal Settings → API, generate an **API token**.
3. Set `DOCUSEAL_API_KEY` and `DOCUSEAL_BASE_URL` (defaults to `https://api.docuseal.com`; override for self-hosted).
4. In Docuseal Settings → Webhooks, add a webhook pointing to `https://<your-api>/webhooks/docuseal`. Select events: `submission.created`, `submission.completed`, `submission.declined`.
5. Copy the webhook secret into `DOCUSEAL_WEBHOOK_SECRET`.
6. Upload your document templates in the Docuseal dashboard and note the **template IDs** for use in your API calls.
7. Verify: use the Docuseal API to create a test submission and confirm the webhook fires.

## Env vars

```bash
DOCUSEAL_API_KEY=...
DOCUSEAL_BASE_URL=https://api.docuseal.com
DOCUSEAL_WEBHOOK_SECRET=...
```

## Where it plugs in

- `apps/api/src/routes/webhooks-docuseal.ts` — webhook handler for `submission.*` events
- `apps/api/src/services/docuseal.ts` — API client wrapper (send template, fetch submission status)
- `apps/web/src/` — optional embed for in-app signing (`<iframe>` or Docuseal React embed)

## Common gotchas

- Webhooks fire multiple times for the same event on retry — use the shared idempotency table (`WebhookEvent`) to deduplicate, same as Stripe webhooks.
- Self-hosting Docuseal requires its own PostgreSQL database and storage (S3 or local disk). It is a separate Rails application — do not attempt to share the boilerplate's Neon instance.
- Template IDs are environment-specific — staging templates differ from production templates. Store them as env vars, not hardcoded.
- The Docuseal embed requires allowing the Docuseal domain in your Content Security Policy (`frame-src`).

## Phase 1 status

Setup guidance documented. Phase 2+ adds `apps/api/src/routes/webhooks-docuseal.ts` stub with Zod schemas for `submission.*` event payloads in `packages/shared/src/zod/docuseal-events.ts`.
