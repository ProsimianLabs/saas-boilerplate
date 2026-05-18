# SaaS Boilerplate

> Opinionated 2026 SaaS starter monorepo. Express + Prisma 7 + Vite/React + Astro, deploy to AWS or anywhere.

**Status:** Phase 1 — documentation + folder structure + pinned dependencies. `pnpm install` resolves; runnable skeleton lands in Phase 2.

## What's in here

| Area | Where |
|---|---|
| Canonical design | [`docs/superpowers/specs/2026-05-17-saas-boilerplate-design.md`](./docs/superpowers/specs/2026-05-17-saas-boilerplate-design.md) |
| Agent-readable summary | [`AGENTS.md`](./AGENTS.md) |
| Phase 1 implementation plan | [`docs/superpowers/plans/2026-05-17-saas-boilerplate-phase-1.md`](./docs/superpowers/plans/2026-05-17-saas-boilerplate-phase-1.md) |
| What's intentionally deferred | [`DEFERRED.md`](./DEFERRED.md) |
| Staging-first launch workflow | [`docs/operations/launch.md`](./docs/operations/launch.md) |
| Operational runbooks | [`docs/operations/`](./docs/operations/) |
| Alternative-choice swap guides | [`docs/swap-guides/`](./docs/swap-guides/) |
| Companion-tool integration guides | [`docs/integrations/`](./docs/integrations/) |

## Stack at a glance

**Backend** — Express 5 + Prisma 7 + BetterAuth + Zod 4 + samchungy/zod-openapi + Scalar
**Workers** — BullMQ + Upstash Redis
**Frontend** — Vite 8 + React 19 + TanStack Router/Query + shadcn/ui + Magic UI + Tailwind v4 + hey-api/openapi-ts
**Marketing** — Astro 5 + React islands + Magic UI
**Database** — Neon (Postgres 16) with two-role RLS multi-tenancy
**Email** — Resend + React Email
**Logging / tracing** — Pino + OpenTelemetry (instrumentation-pino + pino-opentelemetry-transport)
**Testing** — Vitest + Supertest + Testcontainers + Playwright
**IaC** — OpenTofu (AWS: ECS Fargate, ALB, Route53, ACM, ECR, SSM Parameter Store, CloudWatch, SNS, Lambda, S3, CloudFront)
**CI/CD** — GitHub Actions with build-once-promote-many pattern

## Cost target

~$60/mo staging + ~$140/mo production AWS infrastructure (before Neon/Upstash/Resend usage-based bills). See spec §12.

## License

MIT — see [LICENSE](./LICENSE).

## Recommended for development

Use the [Superpowers Claude Code plugin](https://github.com/obra/superpowers) — its brainstorming/writing-plans/TDD/verification skills pair naturally with this boilerplate's structure. Install: `/plugin install superpowers@claude-plugins-official`.
