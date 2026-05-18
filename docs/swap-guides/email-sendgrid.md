# Swap: email sending — Resend → SendGrid

## Why swap

Your organisation already has a SendGrid contract, existing IP reputation, or needs SendGrid's advanced analytics and suppression list management. Tradeoff: SendGrid's API is more verbose; its Node.js SDK is heavier than Resend's minimal client.

## What changes

| Aspect | Default (Resend) | After swap (SendGrid) |
|---|---|---|
| SDK | `resend` | `@sendgrid/mail` |
| Auth | `RESEND_API_KEY` | `SENDGRID_API_KEY` |
| From address | Resend-verified domain | SendGrid Sender Authentication |
| HTML render | React Email → `resend.emails.send` | React Email HTML → `sgMail.send` |

## Steps (high level)

1. Verify your domain in SendGrid's Sender Authentication
2. Replace `resend` with `@sendgrid/mail` in `apps/api/package.json`
3. Update `apps/api/src/services/email.ts`: replace `Resend` client with `sgMail`
4. Update `.env.example` and SSM parameter for the new key name
5. Test with SendGrid's sandbox mode before going live

## Files touched

- `apps/api/package.json` — swap deps
- `apps/api/src/services/email.ts` — replace client and send call
- `.env.example` — rename key
- `infra/tofu/modules/ssm/main.tf` — rename SSM parameter

## Env vars

- Add: `SENDGRID_API_KEY`
- Remove: `RESEND_API_KEY`

## Phase 1 status

This guide is a stub until Phase 2 adds the default code it's replacing. The structural choices documented here will hold; specific code diffs will be filled in later.
