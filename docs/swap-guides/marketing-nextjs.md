# Swap: marketing — Astro → Next.js

## Why swap

Your marketing site needs SSR/ISR or your team already deeply knows Next.js. Tradeoff: heavier framework, more JS shipped per page, Vercel framework gravity (see design spec §1 discussion).

## What changes

| Aspect | Default (Astro) | After swap (Next.js) |
|---|---|---|
| Framework | Astro 5 | Next.js 16 |
| Output | Static (`output: 'static'`) | Static export (`output: 'export'`) — or SSR on Vercel |
| React islands | `client:visible` directives | Server Components + Client Components |
| Content collections | Astro's native | MDX + `next/dynamic` |

## Steps (high level)

1. Replace `apps/marketing/` package.json deps with Next.js 16 + `@next/mdx`
2. Migrate `src/pages/*.astro` → `src/app/**/page.tsx`
3. Update `tailwind.config.ts` content globs
4. If keeping static output: `next.config.js` `output: 'export'` → still deploys via the `marketing` Tofu module (S3 + CloudFront)
5. If switching to SSR: redirect marketing deploy to Vercel; remove the `marketing` Tofu module

## Files touched

- `apps/marketing/package.json` — swap deps
- `apps/marketing/astro.config.mjs` → `apps/marketing/next.config.js`
- `apps/marketing/src/pages/` → `apps/marketing/src/app/`
- `infra/tofu/main.tf` — if going to Vercel, remove `module "marketing"`

## Env vars

- Same as Astro (`PUBLIC_*` → `NEXT_PUBLIC_*` for client-exposed)

## Phase 1 status

Stub; full walkthrough in Phase 2 after Astro default code exists.
