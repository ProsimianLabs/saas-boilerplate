# @saas/ui

Shared React components used by both `apps/web` and `apps/marketing` (via React islands).

## Contents

| Dir | Source |
|---|---|
| `src/shadcn/` | shadcn/ui components vendored via `npx shadcn add <component>` |
| `src/magicui/` | Magic UI animated components vendored via `npx magicui-cli add <component>` |
| `src/assets/` | SVG logos and shared media |

Both shadcn and Magic UI use the **copy-paste vendor pattern** — components live in your repo, you own them, customize freely. Re-running `add` overwrites; track changes in git.

## Logo files

- `logo.svg` — full-color horizontal lockup (~200×40 viewbox)
- `logo-mark.svg` — icon-only (square, used for favicon, app icons)
- `logo-mono.svg` — single-color version using `currentColor` for theming

Imported via `vite-plugin-svgr` (web app) or Astro's native SVG support (marketing).

## components.json

shadcn's config file lives here. CLI commands like `npx shadcn add button` target `src/shadcn/` per its `aliases` config.
