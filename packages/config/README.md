# @saas/config

Shared lint, format, TypeScript, and Tailwind presets for all apps and packages.

## Usage

### ESLint (flat config)

In any package's `eslint.config.js`:

```js
import config from "@saas/config/eslint";
export default config;
```

### Prettier

In any package's `package.json`:

```json
{ "prettier": "@saas/config/prettier" }
```

### TypeScript

In any package's `tsconfig.json`:

```json
{ "extends": "@saas/config/tsconfig/node" }
```

Variants:
- `base` — common compiler options
- `node` — Node 22 LTS server code (apps/api, apps/workers)
- `react` — React app (apps/web)
- `library` — declaration emit on, used by `packages/*`

### Tailwind preset

In any Tailwind config:

```ts
import preset from "@saas/config/tailwind";
export default { presets: [preset], content: [...] };
```
