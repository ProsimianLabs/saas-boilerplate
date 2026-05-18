# Swap: database — Neon → Supabase

## Why swap

You want a fully managed Postgres backend that also bundles storage, auth (optional), and a real-time layer under one dashboard. Tradeoff: Supabase's Postgres version lags slightly behind cutting edge; branching is less mature than Neon's.

## What changes

| Aspect | Default (Neon) | After swap (Supabase) |
|---|---|---|
| Postgres host | Neon serverless | Supabase project Postgres |
| Connection pooling | Neon Pooler | Supavisor (Supabase pooler) |
| Branching | Neon branches | Supabase branching (preview) |
| Extra services | None | Storage, Realtime, Edge Functions (optional) |

## Steps (high level)

1. Create a Supabase project; copy the `DATABASE_URL` (Supavisor pooler URL)
2. Update `DATABASE_URL` in `.env.local` and SSM
3. Run `pnpm db:migrate` against the Supabase project
4. (Optional) Enable Supabase RLS policies to mirror existing Neon RLS setup
5. Remove `NEON_*` specific env vars

## Files touched

- `.env.example` — update `DATABASE_URL`
- `packages/db/drizzle.config.ts` — no code change if using standard `DATABASE_URL`
- `infra/tofu/modules/ssm/main.tf` — update secret value reference

## Env vars

- Rename: `NEON_DATABASE_URL` → `DATABASE_URL` (Supabase Supavisor URL)

## Phase 1 status

This guide is a stub until Phase 2 adds the default code it's replacing. The structural choices documented here will hold; specific code diffs will be filled in later.
