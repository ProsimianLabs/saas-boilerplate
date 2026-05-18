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
