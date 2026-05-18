# Swap: marketing — Astro → Vite SPA

## Why swap

You want the simplest possible marketing front-end — a single-page React app with no build-time rendering — and you're comfortable sacrificing SEO-by-default for ease of iteration. Tradeoff: SEO requires a separate prerendering step or a CDN-level solution.

## What changes

| Aspect | Default (Astro) | After swap (Vite SPA) |
|---|---|---|
| Framework | Astro 5 | Vite 6 + React |
| Rendering | Static HTML per page | Single HTML shell, client-side routing |
| Content collections | Astro's native | Hand-rolled MDX or CMS-driven |
| Deploy artifact | Static files per route | Single `dist/` bundle |

## Steps (high level)

1. Replace `apps/marketing/` deps with `vite`, `@vitejs/plugin-react`, and `react-router-dom`
2. Delete `astro.config.mjs`; add `vite.config.ts`
3. Convert `.astro` pages to `.tsx` route components
4. Update `tailwind.config.ts` content globs
5. S3 + CloudFront deploy still works; add a CloudFront error-page rule to serve `index.html` for all 404s

## Files touched

- `apps/marketing/package.json` — swap deps
- `apps/marketing/astro.config.mjs` → removed
- `apps/marketing/vite.config.ts` — new
- `apps/marketing/src/pages/` → `apps/marketing/src/routes/`
- `infra/tofu/modules/marketing/main.tf` — add CloudFront custom error response

## Env vars

- `PUBLIC_*` → `VITE_*` for client-exposed variables

## Phase 1 status

This guide is a stub until Phase 2 adds the default code it's replacing. The structural choices documented here will hold; specific code diffs will be filled in later.
