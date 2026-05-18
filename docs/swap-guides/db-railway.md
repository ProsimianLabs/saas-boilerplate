# Swap: database — Neon → Railway Postgres

## Why swap

Your entire stack is already on Railway and you want a single platform bill. Railway Postgres is a provisioned container, not serverless. Tradeoff: no branching support; cold-start cost is zero but you pay for the container 24/7.

## What changes

| Aspect | Default (Neon) | After swap (Railway Postgres) |
|---|---|---|
| Postgres host | Neon serverless | Railway Postgres plugin |
| Connection pooling | Neon Pooler | PgBouncer (manual) or direct |
| Branching | Neon branches | Not supported natively |
| Cost model | Per-compute-second | Monthly container flat rate |

## Steps (high level)

1. Add a Postgres plugin to your Railway project; copy `DATABASE_URL` from the dashboard
2. Update `DATABASE_URL` in `.env.local`
3. Run `pnpm db:migrate` against Railway Postgres
4. If using AWS for compute: ensure Railway Postgres is publicly accessible or use a tunnel
5. Remove `NEON_*` env vars

## Files touched

- `.env.example` — update `DATABASE_URL`
- `packages/db/drizzle.config.ts` — no code change if using `DATABASE_URL`
- `docs/operations/runbook-database.md` — update connection string guidance

## Env vars

- Rename: `NEON_DATABASE_URL` → `DATABASE_URL` (Railway-provided)

## Phase 1 status

This guide is a stub until Phase 2 adds the default code it's replacing. The structural choices documented here will hold; specific code diffs will be filled in later.
