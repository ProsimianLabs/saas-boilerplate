# Sentry

## What it is

Sentry is an error monitoring and performance tracing platform. It captures unhandled exceptions and performance issues from your Node.js API, background workers, and React frontend, then groups them by root cause and links stack frames to source code.

## Why it's not bundled

The server SDK is source-available (FSL license — not OSI-approved open source). Some teams prefer fully open-source alternatives (GlitchTip, self-hosted), or use Honeycomb or Datadog for observability.

## Cost

Free tier: 5k errors/month, 10k performance units/month, 1 member. Team plan: $26/month. Business plan: $80/month. Pay-as-you-go available.

## Step-by-step setup

1. Create a Sentry account at sentry.io and create a project for each app (Node.js for API/workers, React for web).
2. In each project's Settings → Client Keys (DSN), copy the **DSN**.
3. Set `SENTRY_DSN` in your environment and the per-app public variants (see env vars below).
4. Install the SDKs: `pnpm add @sentry/node @sentry/profiling-node` in `apps/api` and `apps/workers`; `pnpm add @sentry/react` in `apps/web`.
5. Initialize Sentry at the top of each app's entry point (before any other imports for Node). Use the OTel integration so Sentry spans flow alongside your existing collector without duplication.
6. For source maps: add `@sentry/cli` to your CI workflow. After the Vite/Astro build and before the Docker image push, run `sentry-cli releases upload-sourcemaps`. Set the release to the git SHA.
7. Verify: throw a test error (`throw new Error("sentry-test")`) and confirm it appears in the Sentry dashboard.

## Env vars

```bash
# Server (apps/api, apps/workers)
SENTRY_DSN=https://...@sentry.io/...
SENTRY_AUTH_TOKEN=sntrys_...   # for source map upload in CI

# Client (apps/web)
VITE_PUBLIC_SENTRY_DSN=https://...@sentry.io/...
```

## Where it plugs in

- `apps/api/src/instrument.ts` — Sentry + OTel init (imported before all other modules)
- `apps/workers/src/instrument.ts` — same pattern
- `apps/web/src/main.tsx` — `Sentry.init()` before React root render
- `.github/workflows/build-images.yml` — `sentry-cli releases upload-sourcemaps` step

## Common gotchas

- Import `instrument.ts` as the very first import in `apps/api/src/index.ts` — Sentry's Node SDK patches modules at load time, so late init misses many integrations.
- Use the git SHA as the Sentry release ID (`SENTRY_RELEASE=$(git rev-parse HEAD)`) so stack frames click through to exact source code at that commit.
- Source maps must be uploaded to Sentry **and** excluded from the production Docker image (avoid leaking source to clients).
- The OTel integration (`@sentry/opentelemetry`) means you do not add separate Sentry spans — let OTel instrument automatically and Sentry reads the spans.

## Phase 1 status

Setup guidance documented. Phase 2+ adds `instrument.ts` init files in `apps/api` and `apps/workers` and the source map upload step in `build-images.yml`.
