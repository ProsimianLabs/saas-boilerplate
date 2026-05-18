# Swap: auth provider — BetterAuth → Clerk

## Why swap

You want a hosted auth UI (pre-built sign-in/sign-up components, user management dashboard) with zero session-table maintenance. Clerk handles email verification, MFA, and social logins out of the box. Tradeoff: vendor lock-in, per-MAU pricing at scale.

## What changes

| Aspect | Default (BetterAuth) | After swap (Clerk) |
|---|---|---|
| Auth library | `better-auth` | `@clerk/nextjs` / `@clerk/express` |
| Session store | Postgres | Clerk-managed (JWT) |
| UI components | Custom or shadcn forms | `<SignIn />`, `<UserButton />` |
| User table | `users` in your DB | Clerk user record + webhook sync |

## Steps (high level)

1. Create a Clerk application; copy `CLERK_PUBLISHABLE_KEY` and `CLERK_SECRET_KEY`
2. Remove `better-auth`; add `@clerk/express` to `apps/api/` and `@clerk/react` to `apps/web/`
3. Wrap `apps/web/` root with `<ClerkProvider>`; replace auth forms with Clerk components
4. Replace BetterAuth middleware in `apps/api/src/middleware/auth.ts` with `clerkMiddleware`
5. Set up a Clerk webhook → `POST /webhooks/clerk` to sync users into your `users` table

## Files touched

- `apps/api/package.json` — swap deps
- `apps/web/package.json` — swap deps
- `apps/api/src/middleware/auth.ts` — replace with `clerkMiddleware`
- `apps/web/src/main.tsx` — add `ClerkProvider`
- `apps/api/src/routes/webhooks/clerk.ts` — new webhook handler

## Env vars

- Add: `CLERK_PUBLISHABLE_KEY`, `CLERK_SECRET_KEY`, `CLERK_WEBHOOK_SECRET`
- Remove: `BETTER_AUTH_SECRET`, `BETTER_AUTH_URL`

## Phase 1 status

This guide is a stub until Phase 2 adds the default code it's replacing. The structural choices documented here will hold; specific code diffs will be filled in later.
