# SaaS Boilerplate 2026 — Design Spec

**Date:** 2026-05-17
**Status:** Approved design, ready for implementation planning
**Author:** Alex Sikand (with Claude)

## 1. Purpose & positioning

A public, open-source (MIT) SaaS starter monorepo for 2026. Opinionated single-happy-path per slot with documented escape hatches. Owns one technical choice in each category; users who want different fork or follow swap guides in `docs/swap-guides/`. Branded as **"Express + Prisma + Vite/React + Astro, deploy anywhere, AWS optional."**

Primary audience: solo founders, small teams, agencies starting new SaaS projects. Secondary audience: the author's own future projects. Multi-tenancy (organizations/teams) is built in via BetterAuth's organization plugin; enterprise concerns like multi-region deploy are future variant work.

## 2. Design principles

- **One default per slot.** Configurable variants live in docs, not code paths.
- **No framework-on-Express.** Express is Express; abstractions are thin helpers users own.
- **Schemas-first contracts.** Zod is the source of truth for API shape; OpenAPI and clients are derived.
- **Source-of-truth separation.** DB types come from Prisma; API contracts come from hand-written Zod. They map in the service layer.
- **Pin everything.** Exact versions; Renovate manages updates.
- **Boilerplate cost = $0–150/month per env**, not $500. Managed-everywhere defaults (Neon, Upstash, Resend).
- **Standard tools over clever ones.** Vitest, Playwright, OpenTofu, Pino. Reach for boring choices.

## 3. Repo layout (Turborepo + pnpm workspaces)

```
saas-boilerplate-2026/
├── apps/
│   ├── api/                    Express + Prisma + BetterAuth + Zod + Scalar
│   ├── workers/                BullMQ workers (shares api code via packages/*)
│   ├── web/                    Vite 8 + React 19 + shadcn + Tailwind 4 + hey-api client
│   └── marketing/              Astro static site + Magic UI islands
├── packages/
│   ├── shared/                 Zod schemas (API contracts), shared types/constants
│   ├── config/                 ESLint, Prettier, tsconfig, Tailwind presets
│   ├── ui/                     Shared React components (shadcn + Magic UI vendor)
│   └── api-client/             hey-api-generated TanStack Query client
├── infra/
│   └── tofu/                   OpenTofu modules + staging/production workspaces
├── docker/
│   └── compose.yaml            Local dev: Postgres, Redis, OTel collector, MailHog
├── docs/
│   ├── README.md
│   ├── operations/             Secrets, scaling, observability, on-call
│   ├── swap-guides/            Alternative IaC, Redis, auth, marketing framework, etc.
│   └── superpowers/specs/      Design docs (this file)
├── .github/workflows/          CI/CD pipelines
├── package.json                Workspace root
├── pnpm-workspace.yaml
├── turbo.json
├── renovate.json
└── README.md
```

## 4. Backend — `apps/api/`

### Stack
- **Express 5** (pinned). Standard Express idioms, no framework-on-Express.
- **Prisma 7** with Neon as the default DATABASE_URL provider. Works with any managed Postgres.
- **BetterAuth** with Prisma adapter. Email/password + OAuth (Google, GitHub by default; documented to add more).
- **Zod v4** for runtime validation. Schemas live in `packages/shared/zod/`.
- **samchungy/zod-openapi** converts Zod → OpenAPI 3.1 spec at build time. Uses native `.meta()` API (no global Zod extension).
- **Scalar Express middleware** serves the spec at `/docs`.

### Endpoint pattern: `defineEndpoint()` helper
Hand-rolled ~80-line helper in `packages/shared/define-endpoint.ts`. Provides typed handler input/output, automatic OpenAPI registration, request validation, optional response validation. Users own the code and can modify or remove it.

```ts
router.post('/users', defineEndpoint({
  method: 'post', path: '/users',
  body: CreateUserSchema,
  response: UserResponseSchema,
  handler: async ({ body }) => usersService.create(body),
}));
```

### Error handling: RFC 9457 problem-details
Hand-rolled ~50-line Express error middleware. Maps:
- Zod validation errors → `400 application/problem+json` with `errors[]` field
- Custom domain error classes → typed problem documents
- Unhandled errors → generic 500 problem (no stack traces in prod)

All problem-type schemas are themselves Zod schemas, registered with the OpenAPI generator so they appear in the spec.

### Standard middleware
- `helmet` (security headers)
- `cors` (configurable origins)
- `compression`
- `pino-http` (request logging with trace correlation)
- Request ID propagation (header → context → logs → traces)
- Graceful shutdown (SIGTERM handler that drains in-flight requests, closes DB pool)
- Health probe at `/healthz` (process up), readiness probe at `/readyz` (DB + Redis reachable)

### Auth
BetterAuth handles sessions, OAuth flows, email/password. Direct integration — **not** wrapped by Neon Auth (which is beta and adds vendor coupling). If a user wants Neon Auth specifically, swap guide in `docs/swap-guides/neon-auth.md`.

**Marketing email consent on user signup** (CAN-SPAM / CASL / GDPR compliance):

The `User` model extends BetterAuth's base user with three consent fields:

```prisma
model User {
  // ...BetterAuth fields...
  marketingEmailConsent           Boolean   @default(false)  // opt-in, NEVER pre-checked
  marketingEmailConsentedAt       DateTime?                  // when they consented
  marketingEmailConsentSource     String?                    // e.g. "signup_v2", "settings_2026-05-17" - proves what they agreed to
  ccpaOptOut                      Boolean   @default(false)  // CPRA: user opted out of sale/share
  ccpaOptOutAt                    DateTime?
  consentSnapshot                 Json?                      // cookie consent state at signup (audit trail)
}
```

**Signup form** ships with a marketing-consent checkbox, **unchecked by default** (the safer choice across jurisdictions — GDPR requires opt-in; CAN-SPAM allows opt-out but unchecked-by-default is fine; CASL requires opt-in). The label is a real sentence, not legalese: *"I'd like to receive product updates and occasional emails. You can unsubscribe anytime."*

**Email sending split**:
- **Transactional emails** (password reset, invoices, magic links, security alerts, invitations, billing failures) — ALWAYS allowed; no consent required by law because they're tied to active service.
- **Marketing emails** (newsletters, product announcements, feature emails, win-back, drip campaigns) — gated by `marketingEmailConsent === true`. A helper in `packages/shared/email.ts` enforces this — `sendMarketingEmail(userId, ...)` no-ops with a log warning if consent is false. Hard to get wrong.
- **Per-email-type granular preferences** (newsletter vs product updates vs marketing) — deferred; current model is binary opt-in. Easy to extend later by adding fields or a separate `EmailPreference` table.

Unsubscribe link in every marketing email points to `app.<domain>/settings/email-preferences`, which writes `marketingEmailConsent = false`. One-click unsubscribe (RFC 8058 `List-Unsubscribe` header) supported via Resend.

### Multi-tenancy

BetterAuth's [organization plugin](https://better-auth.com/docs/plugins/organization) enabled by default. Provides `organization`, `member`, `invitation`, `team`, `organizationRole` tables and roles (owner/admin/member, extensible). Session carries `activeOrganizationId` and `activeTeamId`.

**Enforcement mechanism: Postgres Row-Level Security (RLS).** The plugin manages membership and roles but does NOT auto-scope your application data. The boilerplate uses RLS — the DB itself rejects any query that would cross orgs, regardless of application code. This is the same model Supabase uses, and is the gold standard for multi-tenant SaaS data isolation.

#### Pieces

1. **`organizationId UUID NOT NULL` on every domain table.** Indexed. Migration template enforces this; an ESLint/SQL-lint check fails CI for any new migration that adds a domain table without `organization_id` + an index.

2. **RLS policies, defined in custom SQL migrations** (Prisma supports custom SQL alongside schema migrations):
   ```sql
   -- prisma/migrations/<ts>_enable_rls_invoice/migration.sql
   ALTER TABLE "Invoice" ENABLE ROW LEVEL SECURITY;
   CREATE POLICY org_isolation ON "Invoice"
     USING ("organizationId" = current_setting('app.current_org', true)::uuid)
     WITH CHECK ("organizationId" = current_setting('app.current_org', true)::uuid);
   ```
   A scaffolding script `pnpm db:add-rls <ModelName>` generates these migrations consistently. Missing RLS on a domain table = CI fails.

3. **Two database roles** provisioned at infrastructure level:
   - `app_user` — normal application role, RLS applies. Used by the API and workers.
   - `app_admin` — `BYPASSRLS` role. Used only by (a) Prisma migrations and (b) explicitly-scoped admin endpoints. Separate `DATABASE_URL_ADMIN` env var, never exposed to handler code outside admin context.

4. **Connection setup** — `apps/api/` uses two Prisma clients:
   - `prisma` (default) — connects as `app_user`, RLS active.
   - `prismaAdmin` — connects as `app_admin`, RLS bypassed. Use sparingly.

5. **Per-request session variable.** AsyncLocalStorage middleware reads `req.session.activeOrganizationId`. A `$extends` wrapper on `prisma` wraps each operation in a short transaction and runs `SET LOCAL app.current_org = '<uuid>'` first:
   ```ts
   // packages/shared/db.ts (~60 lines, users own it)
   const orgContext = new AsyncLocalStorage<string>();
   const _prisma = new PrismaClient();

   export const prisma = _prisma.$extends({
     query: {
       $allModels: {
         async $allOperations({ model, operation, args, query }) {
           const orgId = orgContext.getStore();
           if (!orgId) return query(args); // unscoped / bootstrap context
           return _prisma.$transaction(async (tx) => {
             await tx.$executeRawUnsafe(`SET LOCAL app.current_org = '${orgId}'`);
             return (tx as any)[model][operation](args);
           });
         },
       },
     },
   });

   export function runInOrgContext<T>(orgId: string, fn: () => Promise<T>) {
     return orgContext.run(orgId, fn);
   }
   ```
   The wrapper exists *only* to inject the session variable — Postgres does the actual filtering. If the wrapper is wrong, RLS still protects you (queries fail closed: `current_setting('app.current_org', true)` returns NULL → policy matches nothing → empty result).

6. **Workers** include `organizationId` in every job payload (Zod-validated). Worker bootstrap wraps the handler in `runInOrgContext(payload.organizationId, () => processor(payload))`.

7. **Frontend** (`apps/web/`) provides `useActiveOrg()` hook backed by BetterAuth session; org switcher in layout calls `organization.setActive(orgId)`.

8. **Tests.** Testcontainers Postgres bootstrap creates both roles. Test setup wraps each test in `runInOrgContext(testOrgId, ...)`. Cross-org leak detection: at least one canary test per scoped model asserts that querying with the wrong org returns empty.

9. **Invitation email** via Resend, template in `packages/shared/email-templates/`.

#### Trade-offs (documented honestly in README)
- **Every scoped query becomes a 1-statement transaction** to make `SET LOCAL` work with connection pooling. Overhead is small (single round-trip), but it's not free. For high-throughput read paths, batch into explicit `$transaction()` blocks.
- **Migrations run as `app_admin`** because they need to ALTER tables (which RLS would block). Prisma's `DATABASE_URL` for migrate commands uses the admin connection.
- **New models require both Prisma schema *and* RLS policy migration.** The `pnpm db:add-model` scaffolding script does both atomically; the CI lint enforces it.
- **BetterAuth's own tables** (`organization`, `member`, `invitation`, etc.) need RLS policies too — boilerplate ships these out of the box (e.g., a user can only see members of orgs they belong to).
- **Easier audit posture** — for SOC 2, the auditor evaluates DB-enforced isolation as substantially stronger than application-enforced. This pays for the small ergonomic cost.

#### Swap guide
`docs/swap-guides/multi-tenancy-app-layer.md` documents the alternative (application-layer wrapper that injects `where: { organizationId }` instead of using RLS) for teams who want simpler ops at the cost of weaker guarantees.

## 5. Workers — `apps/workers/`

### Stack
- **BullMQ** workers in a separate Node process (NOT inside the API process).
- **Upstash Redis** by default (serverless, free tier, no infra). `REDIS_URL` env. Swap docs for ElastiCache, self-hosted, Redis Cloud.
- Shared types/schemas from `packages/shared/` — queue message payloads are validated against Zod schemas at both enqueue and consume sites.
- Same Pino + OTel setup as API.

### Patterns provided
- One queue per logical job type.
- Job processors as plain async functions; bootstrap code wires them to Worker instances.
- Retry/backoff defaults; per-queue overrides.
- Graceful shutdown matching the API.
- BullMQ Board (UI) wired at `/admin/queues` in dev, behind auth in prod.

## 6. Frontend — `apps/web/`

### Stack
- **Vite 8 + React 19 + TypeScript** (all pinned).
- **shadcn/ui + Tailwind v4** for components and styling.
- **Magic UI** for animated marketing-style components (vendored alongside shadcn in `packages/ui/`).
- **TanStack Router** for file-based routing — chosen over React Router 7 for fully type-safe path *and* search params (Zod-validated per route), compile-time error on bad `<Link>` paths, and tighter integration with TanStack Query. React Router 7 swap guide for users migrating from existing RR apps.
- **TanStack Query** via the hey-api generated client.
- **react-hook-form + @hookform/resolvers/zod** for forms (Zod schemas reused from `packages/shared/`).
- **`@hey-api/openapi-ts`** (with TanStack Query plugin) consumes `packages/api-client/openapi.json` at build time and emits typed fetch client + React Query hooks.

### Generated client flow
1. `apps/api/` build emits `packages/api-client/openapi.json`.
2. `packages/api-client/` build runs `hey-api` to produce `client.gen.ts`, `types.gen.ts`, `@tanstack/react-query.gen.ts`.
3. `apps/web/` imports `useGetUsers()`, etc. — fully typed, no manual fetch code.

Turbo's dependency graph ensures the order is correct in `pnpm dev` and CI.

## 7. Marketing — `apps/marketing/`

### Stack
- **Astro** with content collections for blog and changelog.
- **React integration** (`@astrojs/react`) for interactive islands.
- **Magic UI** components used via `client:visible` hydration directives.
- **Tailwind v4** extending the shared preset from `packages/config/`.

### Build target
Static output (`output: 'static'`). Deployed to either:
- S3 + CloudFront via the OpenTofu `marketing` module (default in repo)
- Any static host (Cloudflare Pages, Netlify, GitHub Pages) — swap guide

### Why Astro over Next.js/Vite
- Static-first; no React runtime cost for static pages.
- Faster Lighthouse / Core Web Vitals out of the box.
- Islands let you keep dynamic React components (forms, animated heroes, Magic UI) where needed without the rest of the page paying for them.
- Decouples marketing from app; marketing changes don't touch the React SPA.
- Avoids Next.js → Vercel framework gravity.

### Cookie consent: `orestbida/cookieconsent` (bundled)

Production SaaS that loads GA/Intercom/anything-non-essential needs a consent banner for EU/UK traffic and an opt-out path for California (CPRA). The boilerplate bundles **[orestbida/cookieconsent](https://github.com/orestbida/cookieconsent)** — vanilla JS, MIT-licensed, 5.5k stars, actively maintained (v3.1.0 Feb 2025). Chosen over Osano (abandoned since 2019), Klaro (smaller community), and any paid SaaS (vendor lock-in, ongoing cost).

**How it's wired:**
- Configuration lives in `packages/shared/consent/` so the same banner config is consumed by `apps/marketing/` (via Astro `<script>`) and `apps/web/` (via React `useEffect` on mount).
- Categories: `necessary` (always on), `analytics` (GA), `functional` (Intercom session), `marketing` (Intercom outbound, ad pixels if added).
- Each integration's loader checks the relevant category before initializing. If the user denies `analytics`, GA never loads. No "load then disable" workarounds.
- Respects `Sec-GPC: 1` (Global Privacy Control) signal — auto-opt-out for users sending it, no banner shown beyond a brief notice.
- Cookie set client-side; consent state synced to the user record (`user.consentSnapshot`) on signup so you have a server-side audit trail for compliance.

### Legal pages on the marketing site (required, not optional)

The marketing site **must** host these pages before going live. The boilerplate ships placeholder content with `TODO` headers — the content itself is jurisdiction-specific and must be written by you (or a lawyer, or a generator — see DEFERRED.md for the planned Claude skill).

| Path | What it is | Why required |
|---|---|---|
| `/privacy` | Privacy Policy | GDPR (Art. 13/14), CCPA/CPRA, COPPA, PIPEDA, and basically every data-protection law on Earth. Without one, you're non-compliant the moment you collect an email address. |
| `/terms` | Terms of Service | Contractual basis for the user-product relationship. Limits liability, defines acceptable use, sets dispute resolution. No ToS = you have no enforceable agreement with users. |
| `/do-not-sell-or-share` | "Do Not Sell or Share My Personal Information" opt-out page | Required by CPRA (California, in effect since 2023). Must be a clearly-labeled link in the footer; opt-out form for anonymous users (cookie-based) and authenticated users (writes `user.ccpaOptOut = true`). |
| `/cookie-policy` (optional but common) | Cookie inventory + purposes | Required by ePrivacy in some EU member states; documents what each cookie category does. |

**Footer links** appear on every page of the marketing site and every page of the web app (signup, signin, settings, etc.). The web app links *back* to the marketing site URLs (`<domain>/privacy`, not `app.<domain>/privacy`) — single source of truth, no doc drift.

**This is not legal advice** — every SaaS founder should at minimum read a generated policy carefully or pay a lawyer. The placeholder pages flag this prominently.

### Logo guidance: use SVG

Place the company logo at `packages/ui/assets/logo.svg` (full color), with optional `logo-mark.svg` (icon only) and `logo-mono.svg` (monochrome). Reasons SVG matters:

- **Scales infinitely** — looks crisp on retina, 4K, print, favicon. PNG/JPG need multiple sizes.
- **Smaller** — typical logo is 2–8KB SVG vs. 20–100KB PNG with retina variants.
- **Themeable** — CSS `currentColor` and CSS variables let you swap colors per theme (dark mode, hero contrast) without exporting new files.
- **Crawlable** — search engines and accessibility tools read SVG paths better than rastered text.
- **One source** — marketing site, web app, favicons, OG images, emails all reference the same file.

Used by both `apps/marketing/` and `apps/web/` via the shared `packages/ui/` package. Tools like `vite-plugin-svgr` (web app) and Astro's native SVG support (marketing) import the SVG as a React component or inline element for theming.

## 8. Shared packages

### `packages/shared/`
- `zod/` — API contract schemas (single source of truth: backend validation, OpenAPI generation, worker payload validation, frontend form validation).
- `errors/` — custom error classes for domain errors.
- `define-endpoint.ts` — the typed Express helper.
- `constants/` — values shared across apps.
- `types/` — TypeScript types not derived from Zod.

### `packages/config/`
- `eslint.config.js` — ESLint flat config preset
- `prettier.config.js`
- `tsconfig/` — base, `node.json`, `react.json`, `library.json` presets
- `tailwind.preset.ts` — shared Tailwind v4 config

### `packages/ui/`
- shadcn components (vendored via `npx shadcn add`)
- Magic UI components (vendored alongside)
- Re-exports for consumption from `apps/web/` and `apps/marketing/`

### `packages/api-client/`
- `openapi.json` (committed; rebuilt by `apps/api/` build)
- hey-api-generated TypeScript client (committed for diff visibility, regenerated in CI)

## 9. Local development

### `docker compose up`
- **Postgres 16** on `5432`
- **Redis 7** on `6379`
- **OpenTelemetry Collector** (logs/traces/metrics → stdout in dev)
- **MailHog** for transactional email testing (SMTP stub for Resend dev mode)

### `pnpm dev`
Turbo runs:
- `apps/api/` with watch mode (tsx)
- `apps/workers/` with watch mode
- `apps/web/` Vite dev server
- `apps/marketing/` Astro dev server
- `packages/api-client/` rebuild on `openapi.json` change

### Scripts
- `pnpm db:reset` — drop, recreate, migrate, seed
- `pnpm db:migrate` — Prisma migrate dev
- `pnpm db:seed` — runs `prisma/seed.ts`
- `pnpm typecheck` — `tsc --noEmit` across workspaces
- `pnpm lint` — ESLint
- `pnpm test` — Vitest
- `pnpm test:e2e` — Playwright against `docker compose up`

### Env management
- `.env.example` per app, committed.
- Local `.env` files gitignored.
- Dotenv loaded at process start.
- `packages/shared/env.ts` validates env vars with Zod at startup; missing/invalid envs fail fast.

## 10. Testing strategy

### Layers

| Layer | Tooling | Container? |
|---|---|---|
| Unit (pure functions) | Vitest | None |
| API integration (HTTP + DB + Redis) | Vitest + Supertest + Prisma + ioredis + BullMQ | **Testcontainers (Postgres + Redis)** via `globalSetup` |
| Worker integration (BullMQ flow) | Vitest + BullMQ + ioredis | Same Testcontainers Redis |
| E2E (full stack) | Playwright | `docker compose up` |
| Contract | Vitest snapshot of `openapi.json` | None |
| Type | `tsc --noEmit` in turbo pipeline | None |

### Patterns
- **`apps/api/src/app.ts`** exports the Express app object (no `.listen()`).
- **`apps/api/src/server.ts`** imports app and binds the port.
- Tests import `app.ts` and use Supertest in-process.
- `vitest.config.ts` globalSetup spins up Postgres + Redis containers once per Vitest run; per-file setup truncates tables and flushes Redis between tests.
- BullMQ tests use real Redis (Testcontainers), never `ioredis-mock` — BullMQ's Lua scripts are not reliably supported by mocks.

## 11. Observability

### Logging
- **Pino** as the logger throughout.
- **`@opentelemetry/instrumentation-pino`** injects `trace_id`, `span_id`, `trace_flags` into every log record.
- **`pino-opentelemetry-transport`** ships log records as OTLP to the configured collector.
- Local dev: collector forwards to stdout (pino-pretty equivalent).
- Production: documented configs for Honeycomb, Grafana Cloud, Datadog, AWS X-Ray.

### Tracing
- Standard `@opentelemetry/auto-instrumentations-node` for Express, Prisma, BullMQ, ioredis, http, dns.
- Trace context propagated via W3C `traceparent` headers.

### Metrics
- OTel metrics pipeline ships to the same collector.
- Default service-level indicators: request rate, error rate, duration p50/p95/p99.

### Alerts (CloudWatch + Slack + AWS Budgets)

Architectural pattern (proven in production):

```
AWS source (CloudWatch alarm / AWS Budget) → SNS topic → Lambda forwarder → Slack webhook
                                                       ↘ Email (fallback subscriber)
```

The Lambda exists because SNS → Slack natively produces ugly text-only messages. The Lambda parses SNS payloads (different shape per source type), formats Block Kit messages with severity colors, and posts to the webhook URL stored in SSM SecureString.

**Slack channels** (configurable; defaults shown):
- `#deploys` — CI/CD events (success/failure/rollback)
- `#alerts` — CloudWatch alarms (API errors, latency, ECS task health, DLQ depth) + AWS Budget alerts
- `#app-events` — application-level notifications (new signups, churn risk, etc. — opt-in per event)

**Webhook URL storage**: each Slack webhook URL is an SSM SecureString parameter (`/<project>/<env>/slack/<channel>-webhook`). Lambda forwarder reads with KMS decryption. App code reads via the `apps/api/` config loader.

**Lambda forwarder** is a single `~150-line` Node.js Lambda included in `infra/tofu/alerts/lambda/slack-forwarder/`. Handles AWS Budgets, CloudWatch Alarms, and custom SNS payloads with the same code path. Pattern lifted from a production setup (callsaver). Source is in the repo, not a vendored package — users own it.

**CloudWatch alarms shipped by default** (per environment):
| Alarm | Threshold | Severity |
|---|---|---|
| API 5xx rate | > 1% over 5min | Critical |
| API p99 latency | > 2000ms over 5min | Warning |
| ECS task unhealthy | any service `runningCount < desiredCount` for 5min | Critical |
| ALB unhealthy targets | > 0 for 5min | Critical |
| BullMQ DLQ depth | > 100 jobs | Warning |
| Worker task crashes | > 3 in 10min | Warning |
| Log error rate | > 50/min sustained | Warning |

Each alarm publishes to the `#alerts` SNS topic.

**AWS Budgets** (per AWS account, not per env):
| Threshold | Type | Severity |
|---|---|---|
| 50% of monthly limit | ACTUAL | Info |
| 85% | ACTUAL | Warning |
| 100% | ACTUAL | Critical |
| 150% | ACTUAL | Critical |
| 200% | ACTUAL | Critical |
| 100% | FORECASTED | Warning |

Default monthly budget: `var.monthly_budget_usd = 300` (covers ~$200 infra + 3rd party cushion). Configurable. Email fallback subscribers ensure alerts arrive even if Slack pipeline breaks.

**Application-level Slack notifications** (`packages/shared/slack.ts`):
- Fire-and-forget pattern: never blocks the request path; failures logged but don't propagate.
- Block Kit formatting helpers: `header()`, `fields()`, `text()`, `context()`.
- Per-event functions live in `apps/api/src/services/notifications/` — keeps the channel config close to the call site.
- Webhook URL via env var (`SLACK_WEBHOOK_APP_EVENTS_URL`); skip if unset (works in dev without a webhook).
- Pattern lifted from a production setup (callsaver `slack-notifications.ts`).

**Why SNS in the middle** (not direct CloudWatch→Lambda or Budget→Lambda):
- AWS Budgets can ONLY publish to SNS or email — not Lambda directly.
- CloudWatch alarm targets are EventBridge or SNS — SNS is simpler.
- SNS gives you email fallback for free (subscribe an email + the Lambda to the same topic).
- One Lambda handles all alert sources via SNS, simplifies maintenance.

## 12. Deployment — AWS via OpenTofu

### Modules in `infra/tofu/`

| Module | Resources |
|---|---|
| `network` | VPC, public subnets only (no private; no NAT needed). Security groups. |
| `api` | ECS cluster, Fargate service, task definition for `apps/api/`. |
| `workers` | Fargate service for `apps/workers/` (no ALB; pull-based). |
| `loadbalancer` | ALB, target group for api, ACM cert. |
| `dns` | Route53 hosted zone records. |
| `registry` | ECR repository per app. |
| `secrets` | **SSM Parameter Store** SecureString parameters per env (NOT Secrets Manager — free for our scale, all secrets are static third-party keys, no rotation needed). |
| `logs` | CloudWatch log groups + retention + log-based metric filters. |
| `alerts` | SNS topic per env + Lambda Slack forwarder + CloudWatch alarms (5xx rate, p99 latency, ECS health, ALB unhealthy, DLQ depth, worker crashes) + AWS Budget with multi-threshold notifications. Slack webhooks read from SSM SecureString. |
| `marketing` | S3 bucket + CloudFront distribution + Route53 record for static Astro build (served at apex domain). |
| `web` | S3 bucket + CloudFront distribution + Route53 record for static Vite SPA build (served at `app.<domain>` / `staging.app.<domain>`). |
| `acm` | ACM certs: one in **`us-east-1`** for CloudFront (apex + `app.*` + `staging.app.*`) — this region is **required** by CloudFront, not configurable. Plus one in the user's chosen deploy region for ALB (`api.*` + `staging.api.*`). Default uses wildcard `*.<domain>` + `<domain>` to cover everything. Implemented via a second AWS provider alias `aws.us_east_1` in the Tofu root module. |

### What's NOT included
- **No RDS** (use Neon for managed Postgres)
- **No ElastiCache** (use Upstash for managed Redis)
- **No NAT Gateway**. Rationale: NAT exists to let *private-subnet* resources reach the internet. We use public subnets with tight security groups instead — ECS tasks only allow inbound from the ALB security group, outbound goes directly via IGW. Trade-off: less defense-in-depth than canonical AWS architecture (SG is the only barrier); cost of public IPv4 (~$3.65/mo per task, ~$14/mo total) versus ~$65/mo for HA NAT Gateways. Users who need stricter network isolation: see `docs/swap-guides/aws-with-nat-gateway.md`.
- **No CDK / Pulumi** (OpenTofu only; alternatives in swap guides as text only)
- **No Multi-AZ DB / cross-region replication** (managed by Neon/Upstash; users with those needs override `tofu` variables)

### Region selection

User-configurable via `var.aws_region` in `infra/tofu/<env>.tfvars`. Defaults to `us-east-1` for new projects (cheapest data egress to common destinations; lowest latency to US user base; most service availability). All region-aware resources (VPC, ECS, ALB, S3, Route53 records, ECR, SSM, CloudWatch, regional ACM cert) deploy to this region.

**One hardcoded exception**: the CloudFront ACM cert *must* be in `us-east-1` (CloudFront constraint). The Tofu root module declares a second AWS provider alias `aws.us_east_1` used only for that cert. Users who pick `var.aws_region = "us-east-1"` end up with one provider; users who pick anything else get two providers wired automatically. No user-visible config needed beyond setting `var.aws_region`.

S3 bucket names include the region in their suffix to avoid collisions if a user deploys the same boilerplate in multiple regions (`<project>-<env>-<region>-marketing`).

### Domain conventions

| URL | Resource | Workspace |
|---|---|---|
| `<YOUR-DOMAIN>` | Marketing site (Astro/CloudFront) | production only |
| `app.<YOUR-DOMAIN>` | Web app SPA (Vite/CloudFront) | production |
| `api.<YOUR-DOMAIN>` | API (Express/ALB) | production |
| `staging.app.<YOUR-DOMAIN>` | Staging web app | staging |
| `staging.api.<YOUR-DOMAIN>` | Staging API | staging |

(`staging.<YOUR-DOMAIN>` for marketing is intentionally not created — marketing changes ship to production via PR review, no staging variant needed. Override with a tfvar if you want one.)

**Tofu variable wiring**: `var.domain_name` (e.g. `"mysaas.com"`) and `var.env_prefix` (`""` for production, `"staging."` for staging). DNS module constructs hostnames as `"${var.env_prefix}app.${var.domain_name}"`.

### Workspaces
- `staging` and `production` workspaces, same modules, different `.tfvars`.
- Staging: 1 Fargate task per service, smaller compute.
- Production: 2+ Fargate tasks per service, larger compute, alarms wired.

### Deployment workflow (documented in `docs/operations/launch.md`)

The intended adoption arc for a boilerplate user:

1. Clone, run `pnpm dev` against `docker compose up`. Verify locally.
2. Buy domain. Create Route53 hosted zone. Point registrar nameservers at Route53.
3. Provision Neon (free tier), Upstash (free tier), Resend account. Capture connection strings + API keys. **Region**: pick Neon and Upstash regions that match your `var.aws_region` — every API request makes at least one DB round-trip, and a cross-region hop adds 60–100ms per query. Neon supports several AWS regions directly; Upstash similar. On Neon: run the bundled `prisma/init.sql` once per environment to create the two RLS roles (`app_user`, `app_admin`); set `DATABASE_URL` to the `app_user` connection string and `DATABASE_URL_ADMIN` to the `app_admin` one. **Credential discipline**: staging *must* use test/sandbox credentials for every third-party service that distinguishes them — Stripe sandbox keys, Resend sandbox/dev mode, OAuth provider dev apps, etc. Live credentials only ever appear in `production.tfvars`. The `.env.example` files document which keys have a test variant and where to obtain it.
4. Set values in `infra/tofu/staging.tfvars` (domain, secrets, AWS region, account id). Create Slack webhooks for the channels you want (`#deploys`, `#alerts`, `#app-events`) — three separate Incoming Webhook URLs — and put them in SSM SecureString parameters (`/<project>/staging/slack/deploys-webhook`, etc.). The Tofu `alerts` module will reference these. Same for the production env in step 8.
5. `tofu workspace select staging && tofu init && tofu apply` → staging stack stands up at `staging.app.*` and `staging.api.*`. ~10 minutes first time.
6. Build images via CI (or local `pnpm build:docker`), push to ECR, ECS pulls and rolls.
7. Smoke-test, run E2E, soak as long as you want.
8. **When ready to launch**: set `production.tfvars`, `tofu workspace select production && tofu apply`. Same modules, production hostnames + sizing. Apex marketing domain comes up at the same time.

Staging is meant to be persistent (not torn down between deploys) but can be destroyed for cost reasons during long quiet periods (`tofu destroy` then `tofu apply` later).

### Expected cost
- **Staging**: ~$60/month — ALB ~$20, Fargate ~$25, public IPv4 ~$7 (2 tasks), logs/SSM/ECR/S3/CF ~$10. SSM Parameter Store free at this scale.
- **Production**: ~$140/month — ALB ~$25, Fargate ~$60, public IPv4 ~$15 (4 tasks across api+workers), logs/SSM/ECR/S3/CF ~$25, data transfer ~$15.
- **Plus** Neon, Upstash, Resend bills (vary by usage; ~$0–50/month each for early-stage).
- **Combined**: ~$200/month total infrastructure (both envs) before usage-based managed-service bills.

### Swap guides for IaC
- `docs/swap-guides/aws-ecs-express-mode.md` — drop OpenTofu entirely, use ECS Express Mode CLI for cheaper getting-started.
- `docs/swap-guides/aws-with-rds.md` — add the RDS module if user prefers RDS over Neon.
- `docs/swap-guides/aws-with-nat-gateway.md` — proper private subnets + NAT for users with stricter networking requirements.

## 13. CI/CD — GitHub Actions

The boilerplate ships a complete CI/CD pipeline with the **same-artifact promotion** pattern (build once, promote the same image SHA from staging to production), automated staging deploys, manual production deploys with reviewer approval, and post-deploy verification with automatic rollback.

### Workflows in `.github/workflows/`

| Workflow | Trigger | Purpose |
|---|---|---|
| `ci.yml` | every PR + push to `main` | Validation only: install, generate Prisma client, generate OpenAPI spec, typecheck, lint, build, unit + integration tests (Vitest + Testcontainers), assert generated `api-client/` matches committed version. Required status check. |
| `build-images.yml` | push to `main` (after `ci.yml` succeeds) | Build Docker images for `apps/api/` and `apps/workers/`, push to ECR tagged with git SHA + `latest-main`. No deploy yet — just produce the artifact. |
| `deploy-staging.yml` | push to `main` (after `build-images.yml`), or `workflow_dispatch` | Promote the SHA to staging: Tofu apply → migrate DB (admin role) → update ECS task definition → wait for stable → health check loop → smoke tests → Slack notify. Auto on by default; toggle to manual via `var.staging_auto_deploy = false`. |
| `deploy-production.yml` | `workflow_dispatch` only | Promote the SHA to production. **Gates** (see below). Same pipeline as staging but production workspace. |
| `rollback.yml` | `workflow_dispatch` | Roll an environment back to the previously-deployed SHA (stored in SSM). One-step revert. |
| `e2e.yml` | nightly + on-demand | Playwright against staging. Failures Slack-notify and open a GitHub issue. |
| `renovate.yml` | hourly | Trigger Renovate self-hosted or webhook the Renovate app. |

### The promotion / same-artifact principle

Industry standard for preventing "tested one thing, deployed another":

```
PR merged to main
   ↓ ci.yml passes (typecheck, lint, test)
   ↓ build-images.yml: build image tagged with git SHA, push to ECR
   ↓ deploy-staging.yml: deploy that SHA to staging, smoke-test
   ↓ (manual review, soak time)
   ↓ deploy-production.yml: deploy THE SAME SHA to production
```

The production workflow does NOT rebuild the image. It pulls the same tag staging used. This guarantees the artifact running in prod is bit-for-bit identical to what was tested in staging — no rebuild drift, no "works on CI but not in prod."

### Production-deploy gates

`deploy-production.yml` refuses to run unless **all** of these are true:

1. **The SHA was successfully deployed to staging.** Each successful staging deploy writes the SHA to SSM Parameter `/<project>/staging/last-deployed-sha`. The production workflow's first step queries that parameter and refuses if the input SHA isn't there.
2. **The SHA has been in staging at least N hours** (configurable; default 1 hour soak). Same SSM lookup includes a deployed timestamp.
3. **All required status checks pass on the SHA.** `ci.yml` must be green at that commit.
4. **A reviewer has approved.** Uses GitHub Environments → "production" environment → required reviewers. Deploy is queued until reviewer approves in the GitHub UI.
5. **No production deploy is already in progress.** GitHub Actions `concurrency: { group: deploy-production, cancel-in-progress: false }`.
6. **Optional time-window restriction.** Default config allows production deploys Mon–Thu 09:00–16:00 local time (no Friday afternoons). Override via `--force-deploy` input.

If you really want auto-deploy to production (small team, fast iteration, you trust your tests): flip `var.production_auto_deploy = true` and `deploy-production.yml` triggers automatically on successful staging deploy with the same gates except the manual review. Default ships as **manual-only** because the wrong production deploy is the most expensive mistake a SaaS makes.

### Smoke tests + auto-rollback

After every deploy:

1. Wait for ECS service to stabilize (`aws ecs wait services-stable`).
2. Health check loop: poll `<env>.api.<domain>/healthz` until HTTP 200, max 10 attempts × 5s.
3. Run smoke test suite — a small set of critical endpoint hits stored in `apps/api/test/smoke/`. These run against the deployed env (not in-process).
4. On smoke test failure: workflow calls `rollback.yml` automatically, reverting to the SSM-stored previous SHA. Slack-notify the failure with the diff URL.

### Branch protection (configured per `.github/settings.yml` or manually)

- `main` requires: PR review, signed commits (optional), all required status checks green, branch up-to-date, linear history.
- Required checks: `ci.yml` complete success.
- No direct pushes to `main`. No force-pushes.
- Auto-delete merged branches.

### Image strategy

- **Multi-stage Dockerfile** per app (`apps/api/Dockerfile`, `apps/workers/Dockerfile`, etc.).
- Base: `node:22-alpine` (LTS).
- Final stage: **distroless** (`gcr.io/distroless/nodejs22-debian12`) for `apps/api/` and `apps/workers/`. Smaller attack surface, no shell, faster cold starts.
- **Tags**: git SHA (immutable, used for actual deploys) + `latest-main` (mutable, used as build cache source).
- BuildKit + registry layer caching via `--cache-from type=registry,ref=:latest-main`.
- ECR lifecycle policy: keep last 30 images per repo, untagged images expire in 7 days.

### Migrations in CI

Database migrations run as part of the deploy workflow, **before** the ECS service update:

1. Workflow assumes the `app_admin` IAM role (has BYPASSRLS DB credentials in SSM).
2. Fetches `DATABASE_URL_ADMIN` from SSM.
3. Runs `pnpm prisma migrate deploy`.
4. Runs `pnpm prisma migrate status` to verify no pending migrations.
5. Only after migration success does the ECS service get updated.

This means **app code never deploys against an un-migrated DB**. If migration fails, deploy halts; ECS keeps running the old image with the old schema (which is compatible). Migrations must be backwards-compatible with the previous app version (add columns nullable first, deprecate in a later release).

### Deploy notifications (Slack)

Every deploy workflow ends with a Slack notification to `#deploys` (channel name configurable via SSM):

- ✅ green = successful deploy with SHA, env, deployer, link to the workflow run, link to the diff since previous deploy
- ❌ red = failure with SHA, env, failure step, link to logs
- 🔄 yellow = automatic rollback triggered, with the cause

Implementation: a reusable `notify-slack` composite action in `.github/actions/notify-slack/` that posts a Block Kit message via webhook URL from a GitHub secret (`SLACK_WEBHOOK_DEPLOYS`).

### Secrets in GitHub Actions

- AWS access via **OIDC role assumption** (no long-lived `AWS_ACCESS_KEY_ID` in secrets). Each environment has its own IAM role; GitHub Actions assumes it via `aws-actions/configure-aws-credentials@v4` with `role-to-assume` from environment secrets.
- Slack webhooks, third-party API keys for smoke tests: GitHub Environment secrets (scoped per env).
- Production secrets are NEVER copied into staging or vice versa.

## 14. Documentation

- **`README.md`** — quickstart (clone → setup → `pnpm dev` in 5 minutes), architecture diagram, links into docs.
- **`docs/operations/`** — secrets management, scaling guidance, observability setup, on-call runbook template, **`launch.md`** (staging-first → production deployment workflow).
- **`docs/swap-guides/`** — alternatives for each opinionated choice:
  - `marketing-nextjs.md`, `marketing-vite.md`
  - `redis-elasticache.md`, `redis-self-hosted.md`
  - `auth-clerk.md`, `auth-neon-auth.md`
  - `iac-cdk.md`, `iac-pulumi.md`, `aws-ecs-express-mode.md`
  - `db-supabase.md`, `db-railway.md`
  - `email-sendgrid.md`, `email-postmark.md`
  - `host-fly.md`, `host-render.md`, `host-railway.md`, `host-cloud-run.md`
- **`/docs` endpoint in `apps/api/`** — Scalar UI against the generated OpenAPI spec.
- **`DEFERRED.md`** at repo root — documents what's intentionally not shipped (Stripe billing implementation, landing-page templates) and recommends the [Superpowers Claude Code plugin](https://github.com/obra/superpowers) for development workflows on top of this boilerplate.

## 15. Out of scope (intentionally)

- Internationalization (single-locale baseline; i18n is a future variant).
- Mobile apps (web-first; React Native is a future variant).
- Real-time (WebSockets / SSE) beyond basic patterns.
- **Payment integration**: Stripe is the recommended provider — battle-tested, best-in-class DX, supports every billing model users are likely to need. Boilerplate does **not** bundle a billing implementation because pricing strategies vary too widely (flat subscription, tiered subscription, usage-based metering, seat-based, hybrid, free tier + paid plans, one-time payments, marketplaces). Each requires materially different data models, webhook handlers, and reconciliation logic. The boilerplate ships:
  - `.env.example` entries for `STRIPE_SECRET_KEY` and `STRIPE_WEBHOOK_SECRET` (commented out)
  - `docs/integrations/stripe.md` — a guide covering webhook setup, idempotency patterns, common pitfalls, and links to Stripe's official Node SDK docs
  - A `packages/shared/zod/stripe-events.ts` stub of Zod schemas for common webhook event shapes (users opt in to what they need)
  - No actual subscription/usage/checkout code — users build the billing model that matches their product.
- Search beyond Postgres `ILIKE` / FTS (Algolia / Meilisearch are future swap guides).
- Feature flags (out of scope; recommend GrowthBook or Unleash via env config).
- Multi-region deploys.

## 16. Recommended companion tooling (not bundled)

These are third-party services we recommend wiring up to a production SaaS but **do not install or pre-configure** in the boilerplate. Each comes with opinionated trade-offs (vendor lock-in, pricing, account setup) that are better left to the user. `docs/integrations/` ships a short setup guide for each.

| Tool | Purpose | Where it plugs in | Why not bundled |
|---|---|---|---|
| **Stripe** | Billing | API webhook handler, frontend checkout, customer portal | Billing models vary too widely (see §15). |
| **Cal.com** | Scheduling / booking | Embed widget on marketing site or app; webhook to API for booking events | Account-specific; users may prefer Calendly, SavvyCal, hosted vs self-hosted Cal.com. |
| **Google Analytics** (GA4) | Web analytics | Script tag in `apps/marketing/` and `apps/web/`; env var `VITE_PUBLIC_GA_MEASUREMENT_ID` and Astro equivalent | Privacy stance varies (GDPR, cookie consent banner requirements); some users prefer Plausible, Fathom, Umami. |
| **Google Search Console** | SEO indexing + crawl monitoring | DNS TXT verification (via Tofu) or HTML meta tag; sitemap submission from `apps/marketing/` | Verification is per-domain, not portable; sitemap content depends on user's marketing site. |
| **Intercom** | Customer support chat | JS snippet in `apps/web/` (auth'd users) and `apps/marketing/` (anon); user identification via Intercom JS API with `apps/api/` providing the user attributes | Vendor lock-in + cost; many users prefer Crisp, Chatwoot, Plain, or Zendesk. |
| **Sentry** | Error monitoring / crash reporting | `@sentry/node` SDK in `apps/api/` + `apps/workers/`; `@sentry/react` in `apps/web/`; source map upload in CI | Source-available (FSL) for server, MIT for SDKs (see §15 license trade-offs). Some users prefer Honeycomb, Datadog, or self-hosted GlitchTip. |
| **Docuseal** | Document signing (e-signature) | API integration in `apps/api/` for template send + submission tracking; webhook handler for signed/declined events; optional embed in `apps/web/` | Account-specific (templates, branding, signers). Some users prefer DocuSign or HelloSign / Dropbox Sign; some self-host Docuseal (separate infra concern). |

### What ships now per tool
For each tool: a `docs/integrations/<tool>.md` setup guide describing:
- Where to obtain the credential (account creation steps)
- Exact env var name expected by the boilerplate code (commented in `.env.example`)
- Code snippet for where to add the script tag / SDK initialization / webhook handler
- Common gotchas (e.g., GA4 cookie consent requirements, Sentry source-map upload in CI)
- Cost shape and free tier limits

### Sentry-specific notes
The recommended pattern is:
- `@sentry/node` + `@sentry/profiling-node` for `apps/api/` and `apps/workers/`.
- Integrate with the existing OTel setup — Sentry's OTel integration means traces/spans flow to both Sentry (errors) and your existing collector (full observability) without duplication.
- Source maps uploaded in CI via `@sentry/cli` after the Vite/Astro build, before image push.
- DSN as env var; release ID as the git SHA (matches the deployed artifact, makes error tracebacks click through to source).

### Cal.com-specific notes
- For a hosted Cal.com setup, the embed snippet is a one-liner. For self-hosted Cal.com on your own infra, that's a separate Tofu story (RDS-backed, separate ECS service) — out of scope here.
- Webhook events (BOOKING_CREATED, RESCHEDULED, CANCELLED, NO_SHOW) flow into `apps/api/src/routes/webhooks-cal.ts` (stub provided); we ship Zod schemas for the payload shapes.

### Docuseal-specific notes
- Hosted Docuseal (docuseal.com) is the recommended path — bearer-token API + webhook for `submission.created`, `submission.completed`, `submission.declined`.
- Webhook handler stub in `apps/api/src/routes/webhooks-docuseal.ts`; Zod schemas for payloads in `packages/shared/zod/docuseal-events.ts`.
- Self-hosting Docuseal is supported but is its own Tofu workload (RDS-backed Rails app on ECS or a dedicated EC2). Documented at high level in `docs/integrations/docuseal.md` but not provided as a module.
- Common gotcha: webhooks fire multiple times for the same event; idempotency table (same one used for Stripe) handles dedup.

## 17. Open questions / future work

- Whether to ship a *minimal* Stripe webhook handler example (signature verification + idempotency + dispatch table) without any specific billing model — that's a useful pattern regardless of subscription/usage/etc. Leaning yes.
- Whether `packages/api-client/` checked-in generated files should also be checked in for non-`main` branches.
- Whether to provide a Docker-Compose-only "no AWS" path with documented Fly.io / Render alternatives as first-class.
- Renovate config: how aggressive on automerge for patch updates? (Default: patch automerges with CI pass; minor and major require human review.)

## 18. Concrete library/version pins

These are the pinned versions as of design date (Renovate will track updates):

| Package | Version |
|---|---|
| node | 22 LTS |
| pnpm | 10.x |
| turbo | 2.x |
| express | 5.x |
| prisma | 7.x |
| @prisma/client | 7.x |
| zod | 4.x |
| @hookform/resolvers | latest |
| react-hook-form | 7.x |
| samchungy/zod-openapi | 5.x |
| @hey-api/openapi-ts | latest |
| better-auth | latest |
| bullmq | 5.x |
| ioredis | 5.x |
| pino | 9.x |
| @opentelemetry/sdk-node | latest |
| @opentelemetry/instrumentation-pino | latest |
| pino-opentelemetry-transport | latest |
| @scalar/express-api-reference | latest |
| vite | 8.x |
| react | 19.x |
| @tanstack/router | latest |
| @tanstack/react-query | 5.x |
| tailwindcss | 4.x |
| shadcn/ui | latest |
| magicui | latest |
| astro | 5.x |
| @astrojs/react | latest |
| vitest | 3.x |
| @testcontainers/postgresql | latest |
| @testcontainers/redis | latest |
| supertest | latest |
| playwright | latest |
| resend | latest |

(Exact pins will be set at scaffolding time.)
