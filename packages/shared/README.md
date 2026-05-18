# @saas/shared

Code shared between `apps/api`, `apps/workers`, and `apps/web`. Single source of truth for API contracts, env validation, error types, email templates, and the small handful of helpers that exist in multiple apps.

## Subpath exports

| Export | Purpose |
|---|---|
| `@saas/shared/zod` | API contract Zod schemas — single source of truth for backend validation, OpenAPI spec, frontend forms, worker payloads |
| `@saas/shared/errors` | Domain error classes — mapped to RFC 9457 problem documents by the API error middleware |
| `@saas/shared/env` | Zod-validated env loader; throws on missing/invalid envs at process boot |
| `@saas/shared/define-endpoint` | Typed Express helper (~80 lines) — input/output Zod, auto OpenAPI registration, response validation |
| `@saas/shared/slack` | Block Kit helpers + fire-and-forget poster; matches the proven callsaver pattern |
| `@saas/shared/email` | `sendTransactional()` and `sendMarketing()` — the latter enforces `user.marketingEmailConsent` |
| `@saas/shared/db` | RLS-scoped Prisma client + `runInOrgContext()` |
| `@saas/shared/consent` | vanilla-cookieconsent (orestbida) config shared by web app + marketing site |
| `@saas/shared/email-templates/*` | React Email components — Welcome, PasswordReset, MagicLink, OrgInvitation, EmailVerification |

## Phase 1 status

Subdirectories ship as scaffolded folders with READMEs explaining what each will contain. Actual implementations land in Phase 2.
