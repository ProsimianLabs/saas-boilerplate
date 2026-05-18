# Google Search Console

## What it is

Google Search Console (GSC) is Google's free SEO tooling platform. It shows which queries drive traffic to your site, crawl errors, indexing coverage, Core Web Vitals, and lets you submit sitemaps. Essential for any marketing site you want Google to index.

## Why it's not bundled

Domain verification is per-domain and not portable — the boilerplate can't pre-verify a domain it doesn't own. Sitemap content depends on the user's marketing site structure and content.

## Cost

Free, no limits.

## Step-by-step setup

1. Go to search.google.com/search-console and add your property. Use the **Domain** property type for full coverage (requires DNS TXT record) or the **URL prefix** type (HTML meta tag, easier).
2. For DNS TXT verification: add the TXT record to your domain's DNS (via your registrar or Route 53). If using Tofu/Route 53, add a `aws_route53_record` resource with `type = "TXT"` and the verification value.
3. For HTML meta tag verification: add `<meta name="google-site-verification" content="..." />` to `apps/marketing/src/layouts/BaseLayout.astro` inside `<head>`.
4. Submit your sitemap: GSC → Sitemaps → enter `https://yourdomain.com/sitemap.xml`. Astro generates this automatically if you enable `@astrojs/sitemap` in `astro.config.mjs`.
5. Verify: GSC dashboard shows "Ownership verified" and begins reporting data within 24–48h.

## Env vars

No runtime env vars required. The verification meta tag is a static string in the layout.

## Where it plugs in

- `apps/marketing/src/layouts/BaseLayout.astro` — verification meta tag
- `apps/marketing/astro.config.mjs` — `@astrojs/sitemap` integration
- `infra/tofu/modules/dns/` — optional DNS TXT record resource

## Common gotchas

- GSC data has a 2–3 day lag; don't expect real-time data.
- The Domain property (DNS TXT) covers all subdomains and protocols; the URL prefix property covers only the exact prefix. Use Domain for full coverage.
- `@astrojs/sitemap` only includes pages that Astro knows about at build time; dynamic routes need `getStaticPaths()` to appear in the sitemap.
- Core Web Vitals in GSC reflect real user data (CrUX) — requires enough traffic before the report populates.

## Phase 1 status

Setup guidance documented. Phase 2+ ensures `@astrojs/sitemap` is configured in `apps/marketing/astro.config.mjs` with the correct `site` URL.
