# Swap: email templates — React Email → MJML

## Why swap

Your design team already maintains MJML templates or you need pixel-perfect Outlook compatibility that MJML's table-based compiler guarantees. Tradeoff: MJML requires a separate compile step and loses the React component model; harder to share design tokens.

## What changes

| Aspect | Default (React Email) | After swap (MJML) |
|---|---|---|
| Template language | TSX components | MJML XML |
| Compilation | `@react-email/render` | `mjml` Node.js package |
| Styling | Tailwind / inline styles via helper | MJML attributes |
| Preview | React Email dev server | MJML online editor or custom preview |

## Steps (high level)

1. Remove `@react-email/components` and `@react-email/render`; add `mjml` and `@types/mjml`
2. Move `packages/emails/src/` from `.tsx` templates to `.mjml` files
3. Create a `compile.ts` utility that calls `mjml(fs.readFileSync(...))` and returns HTML
4. Update `apps/api/src/services/email.ts` to use the new compile utility
5. Update the email preview script in `package.json`

## Files touched

- `packages/emails/package.json` — swap deps
- `packages/emails/src/templates/*.tsx` → `packages/emails/src/templates/*.mjml`
- `packages/emails/src/compile.ts` — new MJML compiler utility
- `apps/api/src/services/email.ts` — update render call

## Env vars

- No changes to env vars

## Phase 1 status

This guide is a stub until Phase 2 adds the default code it's replacing. The structural choices documented here will hold; specific code diffs will be filled in later.
