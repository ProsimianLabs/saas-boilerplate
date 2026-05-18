# Deferred

Things this boilerplate intentionally does **not** ship yet, with notes on when/why they'll be added or why they're left to users.

## Stripe billing implementation

**Status:** Not bundled. Future addition: a minimal webhook-handler example.

**Why deferred:** Pricing models vary too widely for a single bundled implementation to be useful: flat subscription, tiered subscription, usage-based metering, seat-based, hybrid free + paid, one-time payment, marketplace pass-through. Each requires materially different data models, webhook handlers, reconciliation logic, and admin tooling.

**What ships now:**
- `.env.example` entries for `STRIPE_SECRET_KEY` and `STRIPE_WEBHOOK_SECRET` (commented), with a header comment reminding that **staging environments must use Stripe sandbox/test credentials (`sk_test_…`), never live keys (`sk_live_…`)**. Live keys belong only in `production.tfvars`. A misplaced live key will charge real cards during testing — and Stripe webhooks fired at staging with live secrets will move real money.
- `docs/integrations/stripe.md` — setup guide covering webhook signature verification, idempotency patterns, common pitfalls (including the live/test key separation), and links to Stripe's Node SDK reference.
- `packages/shared/zod/stripe-events.ts` — Zod stubs for common webhook event shapes (opt-in per event you handle).

**What will be added later:** a *minimal* example webhook handler that does signature verification, idempotent processing via a `processed_webhook_events` table, and a dispatch table — without committing to a specific billing model. That pattern is universal and useful regardless of how you price.

Until then: see `docs/integrations/stripe.md` and Stripe's official docs at https://stripe.com/docs.

## Marketing landing-page templates

**Status:** Astro framework wired up; no opinionated page templates ship yet.

**Why deferred:** Landing page design is product-specific. Hero copy, feature framing, social proof, pricing layout, CTAs — these belong to the product team, not a boilerplate. Shipping a "default landing page" tends to produce identikit SaaS pages that all look the same.

**What ships now:**
- `apps/marketing/` configured with Astro + React islands + Tailwind v4 + Magic UI vendored.
- A minimal placeholder page so the build works and routing demonstrates correctly.
- Working blog and changelog content collections.

**What will be added later:** a curated set of optional section templates (hero variants, feature grids, pricing tables, FAQ, footer, testimonials) using Magic UI components — copy-pasteable into the marketing app, not auto-installed. Plus a short copywriting guide.

Until then: start from the placeholder, see https://magicui.design for animated section ideas, and look at well-built SaaS landing pages (Linear, Resend, Vercel) for layout inspiration.

## Recommended tooling for development

We strongly recommend using the **[Superpowers Claude Code plugin](https://github.com/obra/superpowers)** when building on top of this boilerplate.

**What it is:** A Claude Code plugin that ships a complete software-development methodology as a set of composable agent skills. Triggered automatically based on context — no manual invocation needed for most tasks.

**Skills it includes that pair especially well with this boilerplate:**
- **brainstorming** — turns ideas into design specs through structured dialogue (this very spec was authored this way).
- **writing-plans** — converts design specs into phased implementation plans.
- **executing-plans / subagent-driven-development** — runs the plan with verification checkpoints.
- **test-driven-development** — pairs naturally with the Vitest + Supertest + Testcontainers stack.
- **systematic-debugging** — for the inevitable Prisma/RLS/BetterAuth issues.
- **verification-before-completion** — prevents "looks done but isn't" claims; pairs with `pnpm typecheck && pnpm test && pnpm test:e2e`.
- **requesting-code-review** — pre-merge sanity check.
- **dispatching-parallel-agents** — for the genuinely independent slices (e.g., implementing `apps/web` and `apps/api` features in parallel).

**Install:**
```
/plugin install superpowers@claude-plugins-official
```

**Why we recommend it:** This boilerplate has a lot of moving pieces (monorepo, RLS, codegen pipelines, multi-environment IaC). The kinds of mistakes that compound here — missing an RLS policy, forgetting to regenerate the API client, skipping a Tofu workspace — are exactly what Superpowers' verification and TDD workflows are designed to catch. Using it isn't required, but the boilerplate was designed expecting users will have something like it in their toolkit.

## Claude skill: legal-doc generator

**Status:** Planned. Will ship as a separate Claude Code skill, recommended (but not required) for boilerplate users.

**What it will do:** A skill that combines two inputs to produce jurisdiction-appropriate Privacy Policy and Terms of Service drafts:

1. **Codebase scan** — reads `prisma/schema.prisma`, `packages/shared/zod/`, integration env vars, and `apps/api/src/routes/` to infer what personal data the app collects, what third-party processors it uses (Stripe, Sentry, Intercom, GA, etc.), and what user rights need to be supported (export, delete, opt-out).
2. **Jurisdiction selection** — user states where they operate (US states, EU/UK, Canada, Australia, etc.) and the skill applies the right legal regime layering: GDPR + UK GDPR + CPRA + state-level US laws + PIPEDA + APP, etc.

**Output:**
- `apps/marketing/src/pages/privacy.astro` — Privacy Policy, populated with actual data inventory and processor list pulled from the codebase
- `apps/marketing/src/pages/terms.astro` — Terms of Service template, customized for SaaS context
- `apps/marketing/src/pages/do-not-sell-or-share.astro` — CPRA opt-out flow (if California is in scope)
- `docs/legal/data-inventory.md` — machine-readable summary of what data goes where (also useful for SOC 2 / GDPR DPIA)

**Hard caveat baked into the skill itself:** AI-generated legal documents are not a substitute for legal review. The skill emits a banner at the top of each page reminding the user to have a lawyer review before going live. For B2C apps, especially in regulated industries (health, finance, kids), professional review is non-negotiable.

**Why this lives in a skill, not the boilerplate:** legal docs change as data collection changes. A skill can re-run after every meaningful schema change and diff the output, keeping policies current. Static templates rot.

## Phase 1 known issues

Caveats observed during Phase 1 build. None block the boilerplate from being useful as a reference; all should be cleaned up before (or shortly after) tagging v0.2.

- **AGENTS.md uses present tense for Phase 2 files.** Convention bullets reference paths like `apps/api/src/app.ts`, `apps/api/src/server.ts`, `packages/shared/src/db.ts`, `packages/shared/src/env.ts`, `packages/shared/src/slack.ts` as if they exist today. They don't — they land in Phase 2. An agent that reads AGENTS.md and tries to locate those files will come up empty. Soften the phrasing to "Phase 2 will place this at…" in the next pass.
- **GitHub Actions YAML uses block scalars for echo statements.** Workflows under `.github/workflows/` that have placeholder steps like `run: echo "Phase 1: ..."` were written as block scalars (`run: |` then the command on a new line) instead of flow scalars, because an unquoted colon inside a double-quoted YAML value is a parse error under strict YAML 1.2. Functionally identical to a flow scalar; mention here so nobody "fixes" them back.
- **Peer-dependency warnings on first `pnpm install`.** Install resolves cleanly but emits three warnings worth knowing about:
  - `better-auth@1.2.0` bundles `zod@3.x` via its `better-call` sub-dependency, even though we depend on `zod@4.x` at the workspace level. Upstream issue; will clear when BetterAuth ships zod-4-compatible internals.
  - `@astrojs/tailwind@5.1.4` declares a peer on `tailwindcss@^3.0.24`; we ship Tailwind 4.1.4. Astro's Tailwind integration for v4 is a separate package — swap when stable.
  - `@vitejs/plugin-react@4.3.4` lists peers `vite@^4 || ^5 || ^6`; we ship Vite 8. Plugin works; peer list just hasn't been bumped upstream.
- **`pnpm install` skips build scripts for native/binary packages.** First install logs that build scripts were ignored for `@prisma/engines`, `cpu-features`, `esbuild`, `prisma`, `protobufjs`, `sharp`, `ssh2`. This is pnpm 10's default-deny posture for postinstall scripts. Phase 2 will add these to `pnpm.onlyBuiltDependencies` in the root `package.json` once we've confirmed each one is needed.

## Other future work (unscheduled)

- **Stripe webhook idempotency example** (see above).
- **Marketing section template pack** (see above).
- **Real-time** (WebSockets / SSE) patterns beyond basic examples.
- **Search** beyond Postgres `ILIKE` / FTS — Algolia, Meilisearch, Typesense swap guides.
- **Internationalization** baseline.
- **React Native / mobile** companion app starter.
- **Multi-region deploy** variant (Tofu workspaces + Aurora Global / Neon read replicas + CloudFront origin failover).
- **SOC 2 readiness pack** — audit-friendly defaults documentation, logging retention policies, access reviews.
- **CDK and Pulumi alternatives** to OpenTofu as maintained code paths.
