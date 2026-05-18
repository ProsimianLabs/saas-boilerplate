# Swap: email sending — Resend → Postmark

## Why swap

Postmark is renowned for transactional deliverability and detailed bounce/open analytics. If your product depends on high inbox placement for auth emails, Postmark is a proven choice. Tradeoff: higher per-email cost at volume; separate streams for transactional vs. broadcast.

## What changes

| Aspect | Default (Resend) | After swap (Postmark) |
|---|---|---|
| SDK | `resend` | `postmark` |
| Auth | `RESEND_API_KEY` | `POSTMARK_SERVER_TOKEN` |
| From address | Resend-verified domain | Postmark Sender Signature |
| Streams | Single | Transactional + Broadcast streams |

## Steps (high level)

1. Create a Postmark server; copy the Server API Token
2. Replace `resend` with `postmark` in `apps/api/package.json`
3. Update `apps/api/src/services/email.ts`: create `ServerClient` and use `sendEmail`
4. Set `MessageStream` to `"outbound"` (transactional) or `"broadcast"` as appropriate
5. Update `.env.example` and SSM parameter

## Files touched

- `apps/api/package.json` — swap deps
- `apps/api/src/services/email.ts` — replace client and send call
- `.env.example` — rename key
- `infra/tofu/modules/ssm/main.tf` — rename SSM parameter

## Env vars

- Add: `POSTMARK_SERVER_TOKEN`
- Remove: `RESEND_API_KEY`

## Phase 1 status

This guide is a stub until Phase 2 adds the default code it's replacing. The structural choices documented here will hold; specific code diffs will be filled in later.
