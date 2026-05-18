# apps/marketing

Astro 5 static site for the public marketing pages. Uses React islands for interactive bits (Magic UI components, contact forms).

## Conventions

- Static output (`output: 'static'`). Deployed as S3 + CloudFront via the OpenTofu `marketing` module.
- React islands hydrate only when needed — use `client:visible` for below-the-fold animated components, `client:load` for immediately-interactive forms.
- Magic UI components live in `@saas/ui` and are imported via the React integration.
- Tailwind config extends the shared preset from `@saas/config/tailwind`.
- Cookie consent (vanilla-cookieconsent) wired in `src/layouts/BaseLayout.astro` via a script tag; config shared with `apps/web` via `@saas/shared/consent`.

## Required legal pages (Phase 2 fills with placeholder content)

- `/privacy` — Privacy Policy
- `/terms` — Terms of Service
- `/do-not-sell-or-share` — CCPA opt-out
- `/cookie-policy` — optional but recommended

See the design spec §7 for the full marketing architecture, and `DEFERRED.md` for the planned Claude legal-doc skill.

## Layout (Phase 2)

```
src/
  pages/                File-based routing
    index.astro
    privacy.astro
    terms.astro
    do-not-sell-or-share.astro
  layouts/              BaseLayout.astro + footer with required legal links
  components/           Reusable section components (Hero, FeatureGrid, FAQ, ...)
  content/              Astro content collections (blog, changelog)
```
