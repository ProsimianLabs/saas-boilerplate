# @saas/shared/consent

Cookie consent configuration shared between `apps/web` and `apps/marketing`. Uses [orestbida/cookieconsent](https://github.com/orestbida/cookieconsent) v3.

## Phase 2 contents

- `config.ts` — single `CookieConsentConfig` object with category definitions (necessary / analytics / functional / marketing) and translations.
- `react.ts` — React `useEffect` initializer for `apps/web/`.
- `astro.ts` — script tag generator for `apps/marketing/` `BaseLayout.astro`.
- `gpc.ts` — Sec-GPC global privacy control signal detection.

The same config object is consumed in both shapes. Categories are tied to actual loaders — if `analytics` is denied, GA never initializes (no "load then disable" workaround).
