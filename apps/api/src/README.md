# apps/api/src

Phase 2 will populate this with:

- `app.ts` — Express app builder (no `.listen()`)
- `server.ts` — Binds port
- `routes/` — One file per resource (e.g. `routes/users.ts`, `routes/uploads.ts`, `routes/webhooks-stripe.ts`)
- `services/` — Domain logic (`services/users.ts`)
- `middleware/` — `auth.ts`, `rls-context.ts`, `error-handler.ts`, `request-id.ts`
- `notifications/` — Slack notification helpers
- `email/` — Resend integration; templates in `@saas/shared/email-templates`
- `config/` — `env.ts` (Zod-validated env loading) using `@saas/shared/env`

See the design spec §4 for the full backend architecture.
