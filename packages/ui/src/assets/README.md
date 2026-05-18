# packages/ui/src/assets

Logo files and shared media.

## Logo guidance

Use SVG only. Reasons in the design spec §7:

- Scales infinitely (retina, 4K, print, favicon)
- Themeable via `currentColor` and CSS variables
- Smaller than PNG retina sets
- Crawlable and accessible

## Required variants

- `logo.svg` — horizontal lockup, full color
- `logo-mark.svg` — icon only, square viewbox (used for favicon)
- `logo-mono.svg` — single-color using `currentColor` (used in dark mode, emails, footers)

Replace the placeholder SVGs in this directory with your brand assets before going live.
