# apps/api

Express 5 + Prisma 7 + BetterAuth + Zod. The HTTP API surface.

## Conventions

- **No `.listen()` in `src/app.ts`** — that file exports the Express `app` object. `src/server.ts` imports it and binds the port. This split lets Supertest run integration tests against the app in-process.
- **No framework-on-Express.** Express is Express. The `defineEndpoint()` helper in `@saas/shared` is the only abstraction; it's ~80 lines of code you own.
- **API contracts as Zod**, defined in `@saas/shared/zod`. Handlers validate input/output against those schemas.
- **Multi-tenancy enforced by Postgres RLS.** App code uses the scoped `prisma` client (auto-injects `SET LOCAL app.current_org`); admin code uses `prismaAdmin` explicitly.

## Layout (Phase 2)

```
src/
  app.ts              Express app builder (no listen)
  server.ts           Binds port, starts server
  routes/             One file per resource
  services/           Domain logic
  middleware/         Auth, RLS context, error handler, request-id
  notifications/      Slack notification helpers
  email/              Email sending (Resend) — templates in @saas/shared
  config/             Env loading + validation
prisma/
  schema.prisma       Database schema (BetterAuth tables + domain models)
  init.sql            One-time per-DB: creates app_user + app_admin roles
  migrations/         Prisma + custom SQL (RLS policies)
test/
  smoke/              Hit deployed env after deploy
```

## Env vars

See `.env.example`. Validated at startup via `@saas/shared/env`. Missing or invalid env vars fail fast.

## Build

```
pnpm build       # tsc
pnpm dev         # tsx watch
pnpm test        # vitest + Testcontainers
```
