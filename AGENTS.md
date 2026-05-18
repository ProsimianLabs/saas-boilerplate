# AGENTS.md

> Agent-readable architecture summary. Optimized for ingestion by Claude / Cursor / Aider / etc. Sister doc to `README.md`. Canonical reference is `docs/superpowers/specs/2026-05-17-saas-boilerplate-design.md` — read that for full rationale.

## What this repo is

A 2026 opinionated SaaS boilerplate. Express + Prisma 7 + Vite/React + Astro in a Turborepo + pnpm monorepo. Deploys to AWS via OpenTofu. Managed-everywhere defaults: Neon (Postgres), Upstash (Redis), Resend (email). Phase 1 ships docs + structure + pinned dependencies; Phase 2 will ship the working skeleton.

## Top-level layout

```
saas-boilerplate/
├── apps/
│   ├── api/          Express 5 + Prisma 7 + BetterAuth + Zod 4
│   ├── workers/      BullMQ workers (separate process from api)
│   ├── web/          Vite 8 + React 19 + TanStack Router + Query
│   └── marketing/    Astro 5 static site
├── packages/
│   ├── shared/       Zod schemas, errors, env, define-endpoint, slack, email, db, consent
│   ├── config/       ESLint, Prettier, TypeScript, Tailwind presets
│   ├── ui/           shadcn + Magic UI vendored components + logo SVGs
│   └── api-client/   hey-api generated typed client + React Query hooks
├── infra/tofu/       OpenTofu modules (12 modules, two workspaces: staging + production)
├── docker/           Local dev compose (postgres, redis, otel-collector, mailhog)
├── docs/             Spec, plans, operations, swap-guides, integrations
└── .github/          Workflows, settings, composite actions
```

## Critical conventions

### Express, not framework-on-Express
`apps/api/src/app.ts` exports the Express `app`. `apps/api/src/server.ts` imports it and binds the port. Use the `defineEndpoint()` helper from `@saas/shared/define-endpoint` for typed input/output + auto OpenAPI registration. DO NOT introduce express-zod-api or similar wrappers — they're framework lock-in.

### Zod is the source of truth for API contracts
Schemas live in `packages/shared/src/zod/`. The same schema is used by:
1. API request/response validation
2. OpenAPI spec generation (via samchungy/zod-openapi `.meta()`)
3. Frontend form validation (react-hook-form + Zod resolvers)
4. Worker payload validation

Use Zod 4's native `.meta()` — no global Zod extension.

### Prisma is the source of truth for DB types
Use Prisma's `Prisma.UserGetPayload<...>` and `Prisma.UserCreateInput` for DB-internal types. DO NOT add prisma-zod-generator — see spec §4 for why (the wrong abstraction; you'll override 80% of generated schemas).

### Multi-tenancy: Postgres RLS
Two DB roles: `app_user` (RLS active) and `app_admin` (BYPASSRLS, migrations + admin endpoints only). The scoped `prisma` client in `packages/shared/src/db.ts` auto-injects `SET LOCAL app.current_org` per request via AsyncLocalStorage. `prismaAdmin` exists for explicit admin use only.

Every domain table needs:
1. `organizationId String` field (indexed)
2. A custom-SQL migration enabling RLS + creating the `org_isolation` policy
3. The model added to `SCOPED_MODELS` set

CI's `lint:rls` step fails the build if any domain table lacks an RLS policy.

### Auth: BetterAuth direct
Not wrapped by Neon Auth. Organization plugin enabled by default. Sessions carry `activeOrganizationId`.

### Workers in a separate process
`apps/workers/` is its own ECS service, its own container. Job payloads include `organizationId` (Zod-validated). Worker bootstrap wraps each job in `runInOrgContext(payload.organizationId, () => handler(payload))` so the same RLS-scoped Prisma client works.

### Marketing on Astro, not Next.js
Static output. React islands for interactive bits (Magic UI, forms). Avoids Next.js → Vercel framework gravity. Marketing site is decoupled from the React SPA.

### Logo: SVG only
`packages/ui/src/assets/logo.svg` + `logo-mark.svg` + `logo-mono.svg`. Imported via `vite-plugin-svgr` (web app) and Astro's native SVG (marketing).

### Cookie consent: bundled
`vanilla-cookieconsent` (orestbida) wired in `packages/shared/src/consent/`. Shared config consumed by both apps/web and apps/marketing. Categories tied to actual loaders (deny analytics → GA never initializes).

### Email: React Email + Resend
Templates in `packages/shared/src/email-templates/`. Resend renders React Email natively. Use `sendTransactional()` always-allowed; `sendMarketing()` enforces `user.marketingEmailConsent` gate.

### File uploads: presigned URLs, never proxy bytes
S3 bucket path includes `organizationId` prefix for IAM-level scoping. Phase 2 ships the endpoint pair + hook.

## Deployment model

Two Tofu workspaces: `staging`, `production`. Same modules, different `.tfvars`. Hostnames constructed via `var.env_prefix` (`""` for prod, `"staging."` for staging).

| Hostname | Resource |
|---|---|
| `<domain>` | Marketing (Astro/CloudFront) |
| `app.<domain>` | Web app SPA (Vite/CloudFront) |
| `api.<domain>` | API (Express/ALB) |
| `staging.app.<domain>` | Staging web app |
| `staging.api.<domain>` | Staging API |

Single AWS region via `var.aws_region` (default `us-east-1`). CloudFront cert MUST be in us-east-1 (CloudFront constraint) — Tofu uses a second provider alias `aws.us_east_1` for that one cert.

**No** RDS (use Neon), **no** ElastiCache (use Upstash), **no** NAT Gateway (public subnets + tight SGs).

## CI/CD shape

- `ci.yml` runs on PR: install, typecheck, lint, test (Vitest + Testcontainers), build
- `build-images.yml` runs on merge to main: builds + pushes Docker images to ECR tagged with git SHA
- `deploy-staging.yml` auto-promotes the SHA to staging: migrate (as `app_admin`) → update ECS → health check loop → smoke tests → Slack notify; auto-rollback on smoke fail
- `deploy-production.yml` is manual (`workflow_dispatch`) with required reviewer. Gates: SHA must have been deployed to staging, soaked ≥ N hours, CI green at the SHA, reviewer approved. Same pipeline as staging.
- `rollback.yml` reverts to the SSM-stored previous SHA
- **Build-once-promote-many**: production deploys reuse the SAME image SHA staging tested. No rebuild drift.

## Recommended companion tooling (NOT bundled — see DEFERRED.md + docs/integrations/)

Stripe (billing), Cal.com (scheduling), Google Analytics, Google Search Console, Intercom (support), Sentry (error monitoring), Docuseal (e-signature).

## When making changes

| If you're adding... | Then you must... |
|---|---|
| A new domain model | Add `organizationId` + RLS policy SQL migration; add to `SCOPED_MODELS`; add per-model RLS canary test |
| A new API endpoint | Define Zod schemas in `packages/shared/src/zod/`; use `defineEndpoint()`; register problem-types for errors; regenerate `@saas/api-client` |
| A new env var | Add to `apps/<app>/.env.example`; add to `packages/shared/src/env.ts` Zod schema; add to the relevant SSM Parameter Store path in launch.md |
| A new third-party integration | Decide: bundle (only if universal) or document (`docs/integrations/<tool>.md`); add to design spec §16 if companion tooling |
| A new Tofu module | Module directory with `main.tf`, `variables.tf`, `outputs.tf`, `README.md`; wire from `infra/tofu/main.tf`; document in `docs/operations/launch.md` |
| A new email | React Email component in `packages/shared/src/email-templates/`; transactional via `sendTransactional()`, marketing via `sendMarketing()` (consent-gated) |
| A new Slack notification | Helper in `apps/api/src/notifications/` using `packages/shared/src/slack.ts`; fire-and-forget; webhook URL via env var |

## When making changes, DO NOT

- Introduce a framework on top of Express (express-zod-api, NestJS, etc.)
- Add a Prisma-to-Zod codegen (prisma-zod-generator)
- Pre-check the marketing email consent checkbox
- Use `prismaAdmin` outside admin endpoints
- Add a NAT Gateway, RDS, or ElastiCache (we use Neon/Upstash; swap guides exist if user explicitly wants AWS-native)
- Ship live Stripe keys to staging (sandbox only)
- Use Secrets Manager when SSM works (cost reasons; see secrets.md)
- Use MJML for new email templates (callsaver does; this boilerplate doesn't — React Email is the default)

## File-level index for fast lookup

- Design spec: `docs/superpowers/specs/2026-05-17-saas-boilerplate-design.md`
- Phase 1 implementation plan: `docs/superpowers/plans/2026-05-17-saas-boilerplate-phase-1.md`
- Deferred items: `DEFERRED.md`
- Launch workflow: `docs/operations/launch.md`
- Swap guides index: `docs/swap-guides/README.md`
- Integration guides index: `docs/integrations/README.md`
