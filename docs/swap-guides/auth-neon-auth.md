# Swap: auth provider — BetterAuth → Neon Auth wrapper

## Why swap

Your database is already on Neon and you want auth state stored in the same Postgres instance with Neon's built-in user management UI. Tradeoff: Neon Auth is newer and has a smaller community than BetterAuth; some OAuth providers may lag behind.

## What changes

| Aspect | Default (BetterAuth) | After swap (Neon Auth) |
|---|---|---|
| Auth library | `better-auth` | `@neondatabase/auth` |
| Session store | Postgres (BetterAuth schema) | Neon-managed tables |
| OAuth config | BetterAuth adapters | Neon Auth dashboard |
| JWT | BetterAuth-issued | Neon Auth JWTs |

## Steps (high level)

1. Enable Neon Auth in the Neon project dashboard; note the JWT public key
2. Remove `better-auth` from `apps/api/package.json`; add `@neondatabase/auth`
3. Replace BetterAuth session middleware in `apps/api/src/middleware/auth.ts`
4. Update all `session.user` references to match Neon Auth's user shape
5. Remove BetterAuth migration files; Neon Auth manages its own tables

## Files touched

- `apps/api/package.json` — swap deps
- `apps/api/src/middleware/auth.ts` — replace session logic
- `apps/api/src/routes/auth.ts` — update OAuth callback handlers
- `packages/db/migrations/` — remove BetterAuth migration; add Neon Auth seed if needed

## Env vars

- Add: `NEON_AUTH_PUBLIC_KEY`, `NEON_AUTH_SECRET`
- Remove: `BETTER_AUTH_SECRET`, `BETTER_AUTH_URL`

## Phase 1 status

This guide is a stub until Phase 2 adds the default code it's replacing. The structural choices documented here will hold; specific code diffs will be filled in later.
