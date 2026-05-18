# Swap: multi-tenancy enforcement — Postgres RLS → app-layer wrapper

## Why swap

You want full control over tenant isolation logic in TypeScript — easier to unit-test, easier to debug, and not dependent on Postgres session variables. Tradeoff: you must remember to call the wrapper everywhere; RLS is enforced by the database even if you forget, making it more secure by default.

## What changes

| Aspect | Default (Postgres RLS) | After swap (app-layer wrapper) |
|---|---|---|
| Enforcement point | Database (RLS policies) | Application code (`withTenant()` wrapper) |
| Bypass risk | Impossible without superuser | Possible if a call site is missed |
| Testing | Requires DB-level tests | Standard unit tests |
| Performance | Policy eval per query | No overhead (just a `WHERE` clause) |

## Steps (high level)

1. Remove or disable RLS policies from Drizzle migrations
2. Create a `withTenant(tenantId: string, db: DrizzleClient)` utility in `packages/db/src/tenant.ts` that wraps every query with a tenant filter
3. Update all repository functions to accept and use the wrapper
4. Add an ESLint rule (or TypeScript branded type) to make it a compile-time error to call repo functions without a tenant context
5. Add unit tests for the wrapper to cover cross-tenant access attempts

## Files touched

- `packages/db/src/tenant.ts` — new wrapper utility
- `packages/db/migrations/` — remove RLS policy migration
- `apps/api/src/repositories/**` — update all repo calls
- `packages/config/eslint/index.js` — optional: add tenant-context lint rule

## Env vars

- No changes to env vars

## Phase 1 status

This guide is a stub until Phase 2 adds the default code it's replacing. The structural choices documented here will hold; specific code diffs will be filled in later.
