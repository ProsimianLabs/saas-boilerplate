# SaaS Boilerplate — Phase 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Produce the Phase 1 deliverable described in §2.1 of the design spec: a public OSS boilerplate repo containing folder structure, pinned dependency versions, per-directory READMEs, infrastructure module skeletons, CI/CD workflow stubs, operational documentation, and an `AGENTS.md` agent-readable summary. No application code runs in Phase 1 — `pnpm install` resolves but `pnpm dev` is a future Phase 2 deliverable.

**Architecture:** Turborepo + pnpm workspaces monorepo. Four apps (`api`, `workers`, `web`, `marketing`) plus four packages (`shared`, `config`, `ui`, `api-client`) plus `infra/tofu/` modules and `.github/workflows/` stubs. Every directory has a `README.md` explaining what goes there and what conventions apply. Every `package.json` has exact-pinned versions managed by Renovate.

**Tech Stack:** Node 22 LTS, pnpm 10, Turbo 2, Express 5, Prisma 7, BetterAuth, Zod 4, Vite 8, React 19, Astro 5, Tailwind v4, shadcn/ui, Magic UI, TanStack Router + Query, react-hook-form, hey-api/openapi-ts, samchungy/zod-openapi, Vitest 3, Supertest, Testcontainers, Playwright, BullMQ 5, Pino 9, OpenTelemetry, OpenTofu, AWS (ECS, ALB, Route53, ACM, ECR, SSM, CloudWatch, SNS, Lambda, S3, CloudFront), Neon, Upstash, Resend, React Email.

**Spec reference:** `docs/superpowers/specs/2026-05-17-saas-boilerplate-design.md` — this plan implements §2.1 Phase 1 only.

---

## Task Index

| # | Task | Files touched |
|---|---|---|
| 1 | Repo foundations: README, LICENSE, .gitignore, .editorconfig | `README.md`, `LICENSE`, `.gitignore`, `.editorconfig` |
| 2 | Workspace root: package.json, pnpm-workspace.yaml, turbo.json, renovate.json | 4 root files |
| 3 | `packages/config/` — ESLint, Prettier, TypeScript, Tailwind presets | `packages/config/*` |
| 4 | `apps/api/` scaffold — Express+Prisma+BetterAuth skeleton | `apps/api/*` |
| 5 | `apps/workers/` scaffold — BullMQ skeleton | `apps/workers/*` |
| 6 | `apps/web/` scaffold — Vite+React skeleton | `apps/web/*` |
| 7 | `apps/marketing/` scaffold — Astro skeleton | `apps/marketing/*` |
| 8 | `packages/shared/` scaffold — Zod/errors/define-endpoint stubs | `packages/shared/*` |
| 9 | `packages/ui/` scaffold — shadcn/Magic UI vendoring + logo placeholder | `packages/ui/*` |
| 10 | `packages/api-client/` scaffold — hey-api output target | `packages/api-client/*` |
| 11 | `infra/tofu/` root — providers, variables, workspaces | `infra/tofu/{main,variables,outputs}.tf`, `*.tfvars.example` |
| 12 | `infra/tofu/modules/` core — network, api, workers, alb, dns, ecr, acm, logs | `infra/tofu/modules/*/` |
| 13 | `infra/tofu/modules/` peripherals — secrets, marketing, web, alerts (incl. Slack Lambda) | `infra/tofu/modules/*/` |
| 14 | `docker/compose.yaml` — local dev stack | `docker/compose.yaml`, `docker/README.md` |
| 15 | `.github/workflows/` stubs — ci, build-images, deploy-staging, deploy-production, rollback, e2e, renovate | `.github/workflows/*.yml` |
| 16 | `.github/` — settings.yml + composite actions + CODEOWNERS | `.github/*` |
| 17 | `docs/operations/` — launch.md, secrets.md, scaling.md, observability.md, on-call.md | `docs/operations/*` |
| 18 | `docs/swap-guides/` — all swap guide skeletons | `docs/swap-guides/*` |
| 19 | `docs/integrations/` — Stripe, Cal.com, GA4, GSC, Intercom, Sentry, Docuseal, file-uploads, email-mjml | `docs/integrations/*` |
| 20 | `AGENTS.md` — agent-readable architecture summary at repo root | `AGENTS.md` |
| 21 | Final `README.md` polish + verification + push | `README.md`, smoke check |

---

## Task 1: Repo foundations

**Files:**
- Create: `~/saas-boilerplate-2026/README.md`
- Create: `~/saas-boilerplate-2026/LICENSE`
- Create: `~/saas-boilerplate-2026/.gitignore`
- Create: `~/saas-boilerplate-2026/.editorconfig`
- Create: `~/saas-boilerplate-2026/.nvmrc`

- [ ] **Step 1: Write `LICENSE`**

```
MIT License

Copyright (c) 2026 Prosimian Labs

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

- [ ] **Step 2: Write `.nvmrc`**

```
22
```

- [ ] **Step 3: Write `.editorconfig`**

```
root = true

[*]
end_of_line = lf
insert_final_newline = true
charset = utf-8
indent_style = space
indent_size = 2
trim_trailing_whitespace = true

[*.md]
trim_trailing_whitespace = false

[Makefile]
indent_style = tab
```

- [ ] **Step 4: Write `.gitignore`**

```
# Dependencies
node_modules/
.pnpm-store/

# Build outputs
dist/
build/
.next/
.turbo/
.astro/
.vite/

# TypeScript
*.tsbuildinfo

# Test outputs
coverage/
.vitest/
playwright-report/
test-results/
.playwright/

# Env files
.env
.env.local
.env.*.local
!.env.example

# Prisma
prisma/migrations/dev.db*

# OS
.DS_Store
Thumbs.db

# Editor
.vscode/*
!.vscode/settings.json.example
!.vscode/extensions.json
.idea/

# Logs
*.log
npm-debug.log*
pnpm-debug.log*

# Terraform / OpenTofu
.terraform/
*.tfstate
*.tfstate.*
*.tfplan
crash.log
override.tf
override.tf.json
*_override.tf
*_override.tf.json
.terraformrc
terraform.rc

# Docker
.docker/

# Misc
.cache/
.tmp/
```

- [ ] **Step 5: Write top-level `README.md`** (minimal — full polish in Task 21)

```markdown
# SaaS Boilerplate

> Opinionated 2026 SaaS starter monorepo. Express + Prisma 7 + Vite/React + Astro on AWS or anywhere.

**Status:** Phase 1 — documentation + folder structure. `pnpm install` works; runnable skeleton lands in Phase 2.

## Quick links

- [Full design spec](./docs/superpowers/specs/2026-05-17-saas-boilerplate-design.md) — read this first.
- [AGENTS.md](./AGENTS.md) — agent-readable architecture summary for Claude / Cursor / Aider.
- [DEFERRED.md](./DEFERRED.md) — what's intentionally not shipped yet.
- [docs/operations/launch.md](./docs/operations/launch.md) — staging-first deployment workflow.
- [docs/swap-guides/](./docs/swap-guides/) — alternative choices for each opinionated default.
- [docs/integrations/](./docs/integrations/) — Stripe, Cal.com, Sentry, etc. setup guides.

## License

MIT — see [LICENSE](./LICENSE).
```

- [ ] **Step 6: Commit**

```bash
cd ~/saas-boilerplate-2026
git add README.md LICENSE .gitignore .editorconfig .nvmrc
git commit -m "feat(repo): add foundation files (README, LICENSE, .gitignore, .editorconfig, .nvmrc)"
```

---

## Task 2: Workspace root config

**Files:**
- Create: `~/saas-boilerplate-2026/package.json`
- Create: `~/saas-boilerplate-2026/pnpm-workspace.yaml`
- Create: `~/saas-boilerplate-2026/turbo.json`
- Create: `~/saas-boilerplate-2026/renovate.json`
- Create: `~/saas-boilerplate-2026/.npmrc`

- [ ] **Step 1: Write `package.json`**

```json
{
  "name": "saas-boilerplate",
  "version": "0.1.0",
  "private": true,
  "description": "Opinionated 2026 SaaS starter monorepo",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "https://github.com/ProsimianLabs/saas-boilerplate.git"
  },
  "engines": {
    "node": ">=22",
    "pnpm": ">=10"
  },
  "packageManager": "pnpm@10.0.0",
  "scripts": {
    "build": "turbo run build",
    "dev": "turbo run dev",
    "lint": "turbo run lint",
    "typecheck": "turbo run typecheck",
    "test": "turbo run test",
    "test:e2e": "turbo run test:e2e",
    "clean": "turbo run clean && rm -rf node_modules"
  },
  "devDependencies": {
    "turbo": "2.5.0",
    "typescript": "5.7.2",
    "prettier": "3.4.2"
  }
}
```

- [ ] **Step 2: Write `pnpm-workspace.yaml`**

```yaml
packages:
  - "apps/*"
  - "packages/*"
```

- [ ] **Step 3: Write `turbo.json`**

```json
{
  "$schema": "https://turbo.build/schema.json",
  "ui": "tui",
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", "build/**", ".next/**", "!.next/cache/**", ".astro/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": {
      "dependsOn": ["^build"]
    },
    "typecheck": {
      "dependsOn": ["^build"],
      "outputs": []
    },
    "test": {
      "dependsOn": ["^build"],
      "outputs": ["coverage/**"]
    },
    "test:e2e": {
      "dependsOn": ["^build"],
      "outputs": ["playwright-report/**"]
    },
    "clean": {
      "cache": false
    }
  }
}
```

- [ ] **Step 4: Write `renovate.json`**

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": [
    "config:recommended",
    ":semanticCommits",
    ":dependencyDashboard"
  ],
  "timezone": "America/Los_Angeles",
  "schedule": ["after 9pm every weekday", "every weekend"],
  "packageRules": [
    {
      "matchUpdateTypes": ["patch"],
      "automerge": true,
      "automergeType": "branch"
    },
    {
      "matchDepTypes": ["devDependencies"],
      "matchUpdateTypes": ["minor", "patch"],
      "automerge": true
    },
    {
      "matchPackagePatterns": ["^@radix-ui/"],
      "groupName": "Radix UI"
    },
    {
      "matchPackagePatterns": ["^@opentelemetry/"],
      "groupName": "OpenTelemetry"
    },
    {
      "matchPackagePatterns": ["^@aws-sdk/"],
      "groupName": "AWS SDK"
    },
    {
      "matchPackagePatterns": ["^@tanstack/"],
      "groupName": "TanStack"
    },
    {
      "matchPackagePatterns": ["^prisma$", "^@prisma/"],
      "groupName": "Prisma"
    },
    {
      "matchPackagePatterns": ["^vitest", "^@vitest/"],
      "groupName": "Vitest"
    }
  ],
  "lockFileMaintenance": {
    "enabled": true,
    "schedule": ["before 5am on monday"]
  }
}
```

- [ ] **Step 5: Write `.npmrc`**

```
auto-install-peers=true
strict-peer-dependencies=false
shamefully-hoist=false
node-linker=isolated
prefer-frozen-lockfile=true
```

- [ ] **Step 6: Commit**

```bash
git add package.json pnpm-workspace.yaml turbo.json renovate.json .npmrc
git commit -m "feat(workspace): add Turbo+pnpm workspace config and Renovate"
```

---

## Task 3: `packages/config/` — shared lint/format/ts/tailwind presets

**Files:**
- Create: `packages/config/package.json`
- Create: `packages/config/README.md`
- Create: `packages/config/eslint.config.js`
- Create: `packages/config/prettier.config.js`
- Create: `packages/config/tsconfig/base.json`
- Create: `packages/config/tsconfig/node.json`
- Create: `packages/config/tsconfig/react.json`
- Create: `packages/config/tsconfig/library.json`
- Create: `packages/config/tailwind.preset.ts`

- [ ] **Step 1: Write `packages/config/package.json`**

```json
{
  "name": "@saas/config",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "exports": {
    "./eslint": "./eslint.config.js",
    "./prettier": "./prettier.config.js",
    "./tsconfig/base": "./tsconfig/base.json",
    "./tsconfig/node": "./tsconfig/node.json",
    "./tsconfig/react": "./tsconfig/react.json",
    "./tsconfig/library": "./tsconfig/library.json",
    "./tailwind": "./tailwind.preset.ts"
  },
  "dependencies": {
    "@eslint/js": "9.17.0",
    "eslint": "9.17.0",
    "eslint-config-prettier": "10.1.5",
    "eslint-plugin-react": "7.37.4",
    "eslint-plugin-react-hooks": "5.1.0",
    "globals": "16.0.0",
    "prettier": "3.4.2",
    "tailwindcss": "4.1.4",
    "typescript-eslint": "8.18.0"
  }
}
```

- [ ] **Step 2: Write `packages/config/README.md`**

```markdown
# @saas/config

Shared lint, format, TypeScript, and Tailwind presets for all apps and packages.

## Usage

### ESLint (flat config)

In any package's `eslint.config.js`:

\`\`\`js
import config from "@saas/config/eslint";
export default config;
\`\`\`

### Prettier

In any package's `package.json`:

\`\`\`json
{ "prettier": "@saas/config/prettier" }
\`\`\`

### TypeScript

In any package's `tsconfig.json`:

\`\`\`json
{ "extends": "@saas/config/tsconfig/node" }
\`\`\`

Variants:
- `base` — common compiler options
- `node` — Node 22 LTS server code (apps/api, apps/workers)
- `react` — React app (apps/web)
- `library` — declaration emit on, used by `packages/*`

### Tailwind preset

In any Tailwind config:

\`\`\`ts
import preset from "@saas/config/tailwind";
export default { presets: [preset], content: [...] };
\`\`\`
```

- [ ] **Step 3: Write `packages/config/eslint.config.js`**

```js
import js from "@eslint/js";
import tseslint from "typescript-eslint";
import react from "eslint-plugin-react";
import reactHooks from "eslint-plugin-react-hooks";
import prettier from "eslint-config-prettier";
import globals from "globals";

export default tseslint.config(
  { ignores: ["**/dist/**", "**/build/**", "**/.next/**", "**/.astro/**", "**/node_modules/**", "**/coverage/**"] },
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    files: ["**/*.{ts,tsx}"],
    languageOptions: {
      globals: { ...globals.node, ...globals.browser, ...globals.es2024 },
    },
    rules: {
      "@typescript-eslint/no-unused-vars": ["error", { argsIgnorePattern: "^_", varsIgnorePattern: "^_" }],
      "@typescript-eslint/consistent-type-imports": "error",
      "no-console": ["warn", { allow: ["warn", "error"] }],
    },
  },
  {
    files: ["**/*.{tsx,jsx}"],
    ...react.configs.flat.recommended,
    settings: { react: { version: "detect" } },
  },
  {
    files: ["**/*.{tsx,jsx}"],
    plugins: { "react-hooks": reactHooks },
    rules: { ...reactHooks.configs.recommended.rules },
  },
  prettier,
);
```

- [ ] **Step 4: Write `packages/config/prettier.config.js`**

```js
/** @type {import("prettier").Config} */
export default {
  semi: true,
  singleQuote: true,
  trailingComma: "all",
  printWidth: 100,
  tabWidth: 2,
  useTabs: false,
  bracketSpacing: true,
  arrowParens: "always",
  endOfLine: "lf",
};
```

- [ ] **Step 5: Write `packages/config/tsconfig/base.json`**

```json
{
  "$schema": "https://json.schemastore.org/tsconfig",
  "compilerOptions": {
    "target": "ES2023",
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "lib": ["ES2023"],
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noFallthroughCasesInSwitch": true,
    "noImplicitOverride": true,
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "isolatedModules": true,
    "verbatimModuleSyntax": true,
    "skipLibCheck": true,
    "resolveJsonModule": true,
    "allowImportingTsExtensions": false
  }
}
```

- [ ] **Step 6: Write `packages/config/tsconfig/node.json`**

```json
{
  "extends": "./base.json",
  "compilerOptions": {
    "lib": ["ES2023"],
    "types": ["node"],
    "outDir": "dist",
    "rootDir": "src",
    "declaration": false,
    "sourceMap": true,
    "noEmit": false
  }
}
```

- [ ] **Step 7: Write `packages/config/tsconfig/react.json`**

```json
{
  "extends": "./base.json",
  "compilerOptions": {
    "lib": ["ES2023", "DOM", "DOM.Iterable"],
    "jsx": "react-jsx",
    "types": ["vite/client"],
    "noEmit": true,
    "useDefineForClassFields": true
  }
}
```

- [ ] **Step 8: Write `packages/config/tsconfig/library.json`**

```json
{
  "extends": "./base.json",
  "compilerOptions": {
    "outDir": "dist",
    "rootDir": "src",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "composite": true,
    "noEmit": false
  }
}
```

- [ ] **Step 9: Write `packages/config/tailwind.preset.ts`**

```ts
import type { Config } from 'tailwindcss';

const preset: Partial<Config> = {
  theme: {
    extend: {
      colors: {
        brand: {
          50: 'rgb(var(--brand-50) / <alpha-value>)',
          100: 'rgb(var(--brand-100) / <alpha-value>)',
          500: 'rgb(var(--brand-500) / <alpha-value>)',
          900: 'rgb(var(--brand-900) / <alpha-value>)',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'ui-monospace', 'monospace'],
      },
    },
  },
};

export default preset;
```

- [ ] **Step 10: Commit**

```bash
git add packages/config/
git commit -m "feat(config): add shared ESLint/Prettier/TypeScript/Tailwind presets"
```

---

## Task 4: `apps/api/` scaffold

**Files:**
- Create: `apps/api/package.json`
- Create: `apps/api/README.md`
- Create: `apps/api/tsconfig.json`
- Create: `apps/api/eslint.config.js`
- Create: `apps/api/Dockerfile`
- Create: `apps/api/.dockerignore`
- Create: `apps/api/.env.example`
- Create: `apps/api/src/README.md`
- Create: `apps/api/prisma/README.md`
- Create: `apps/api/prisma/schema.prisma`
- Create: `apps/api/prisma/init.sql`
- Create: `apps/api/prisma/migrations/.gitkeep`

- [ ] **Step 1: Write `apps/api/package.json`** (deps pinned; no scripts run yet because there's no code)

```json
{
  "name": "@saas/api",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "build": "tsc",
    "dev": "tsx watch src/server.ts",
    "start": "node dist/server.js",
    "lint": "eslint .",
    "typecheck": "tsc --noEmit",
    "test": "vitest run",
    "test:watch": "vitest",
    "prisma:generate": "prisma generate",
    "prisma:migrate": "prisma migrate dev",
    "prisma:deploy": "prisma migrate deploy",
    "db:reset": "prisma migrate reset --force",
    "db:seed": "tsx prisma/seed.ts"
  },
  "dependencies": {
    "@prisma/client": "7.0.0",
    "@saas/shared": "workspace:*",
    "@scalar/express-api-reference": "0.7.5",
    "better-auth": "1.2.0",
    "bullmq": "5.34.0",
    "compression": "1.7.5",
    "cors": "2.8.5",
    "express": "5.0.1",
    "helmet": "8.0.0",
    "ioredis": "5.4.2",
    "pino": "9.6.0",
    "pino-http": "10.4.0",
    "resend": "4.1.1",
    "zod": "4.0.0",
    "zod-openapi": "5.4.6",
    "@opentelemetry/api": "1.9.0",
    "@opentelemetry/auto-instrumentations-node": "0.55.0",
    "@opentelemetry/exporter-trace-otlp-http": "0.57.0",
    "@opentelemetry/instrumentation-pino": "0.46.0",
    "@opentelemetry/sdk-node": "0.57.0",
    "pino-opentelemetry-transport": "1.0.1",
    "@react-email/components": "0.0.32",
    "@react-email/render": "1.0.4",
    "react": "19.0.0",
    "@aws-sdk/client-s3": "3.717.0",
    "@aws-sdk/s3-request-presigner": "3.717.0"
  },
  "devDependencies": {
    "@saas/config": "workspace:*",
    "@types/compression": "1.7.5",
    "@types/cors": "2.8.17",
    "@types/express": "5.0.0",
    "@types/node": "22.10.5",
    "@types/react": "19.0.5",
    "@types/supertest": "6.0.2",
    "ioredis-mock": "8.9.0",
    "prisma": "7.0.0",
    "supertest": "7.0.0",
    "testcontainers": "10.16.0",
    "@testcontainers/postgresql": "10.16.0",
    "@testcontainers/redis": "10.16.0",
    "tsx": "4.19.2",
    "typescript": "5.7.2",
    "vitest": "3.0.0"
  }
}
```

- [ ] **Step 2: Write `apps/api/README.md`**

```markdown
# apps/api

Express 5 + Prisma 7 + BetterAuth + Zod. The HTTP API surface.

## Conventions

- **No `.listen()` in `src/app.ts`** — that file exports the Express `app` object. `src/server.ts` imports it and binds the port. This split lets Supertest run integration tests against the app in-process.
- **No framework-on-Express.** Express is Express. The `defineEndpoint()` helper in `@saas/shared` is the only abstraction; it's ~80 lines of code you own.
- **API contracts as Zod**, defined in `@saas/shared/zod`. Handlers validate input/output against those schemas.
- **Multi-tenancy enforced by Postgres RLS.** App code uses the scoped `prisma` client (auto-injects `SET LOCAL app.current_org`); admin code uses `prismaAdmin` explicitly.

## Layout (Phase 2)

\`\`\`
src/
  app.ts              Express app builder (no listen)
  server.ts           Binds port, starts server
  routes/             One file per resource
  services/           Domain logic
  middleware/         Auth, RLS context, error handler, request-id
  notifications/      Slack notification helpers
  email/              Email sending (Resend) — templates in @saas/shared
  config/             Env loading + validation
prisma/
  schema.prisma       Database schema (BetterAuth tables + domain models)
  init.sql            One-time per-DB: creates app_user + app_admin roles
  migrations/         Prisma + custom SQL (RLS policies)
test/
  smoke/              Hit deployed env after deploy
\`\`\`

## Env vars

See `.env.example`. Validated at startup via `@saas/shared/env`. Missing or invalid env vars fail fast.

## Build

\`\`\`
pnpm build       # tsc
pnpm dev         # tsx watch
pnpm test        # vitest + Testcontainers
\`\`\`
```

- [ ] **Step 3: Write `apps/api/tsconfig.json`**

```json
{
  "extends": "@saas/config/tsconfig/node",
  "compilerOptions": {
    "outDir": "dist",
    "rootDir": "src"
  },
  "include": ["src/**/*", "test/**/*"],
  "exclude": ["dist", "node_modules"]
}
```

- [ ] **Step 4: Write `apps/api/eslint.config.js`**

```js
import config from "@saas/config/eslint";
export default config;
```

- [ ] **Step 5: Write `apps/api/Dockerfile`** (multi-stage skeleton; image won't build yet but structure is documented)

```dockerfile
# syntax=docker/dockerfile:1.7
# ─── Build stage ────────────────────────────────────────────────────────────
FROM node:22-alpine AS build
WORKDIR /repo

# Copy workspace manifests for layer caching
COPY pnpm-workspace.yaml package.json pnpm-lock.yaml ./
COPY apps/api/package.json apps/api/
COPY packages/shared/package.json packages/shared/
COPY packages/config/package.json packages/config/

RUN corepack enable && pnpm install --frozen-lockfile

# Copy source
COPY . .
RUN pnpm --filter @saas/api build

# ─── Runtime stage (distroless) ─────────────────────────────────────────────
FROM gcr.io/distroless/nodejs22-debian12 AS runtime
WORKDIR /app
COPY --from=build /repo/apps/api/dist ./dist
COPY --from=build /repo/apps/api/node_modules ./node_modules
COPY --from=build /repo/apps/api/package.json ./
EXPOSE 8080
USER nonroot:nonroot
CMD ["dist/server.js"]
```

- [ ] **Step 6: Write `apps/api/.dockerignore`**

```
node_modules
dist
.turbo
coverage
.env
.env.*
!.env.example
```

- [ ] **Step 7: Write `apps/api/.env.example`**

```bash
# ─── Runtime ────────────────────────────────────────────────────────────────
NODE_ENV=development
PORT=8080
LOG_LEVEL=info

# ─── Database (Neon, region-matched to AWS region) ─────────────────────────
# DATABASE_URL: app_user role (RLS active)
DATABASE_URL=postgresql://app_user:CHANGE_ME@localhost:5432/saas?schema=public
# DATABASE_URL_ADMIN: app_admin role (BYPASSRLS — used by migrations and admin endpoints only)
DATABASE_URL_ADMIN=postgresql://app_admin:CHANGE_ME@localhost:5432/saas?schema=public

# ─── Redis (Upstash, region-matched) ──────────────────────────────────────
REDIS_URL=redis://localhost:6379

# ─── Auth (BetterAuth) ─────────────────────────────────────────────────────
BETTER_AUTH_SECRET=CHANGE_ME_TO_A_LONG_RANDOM_STRING
BETTER_AUTH_URL=http://localhost:8080
# OAuth providers (optional)
# GOOGLE_CLIENT_ID=
# GOOGLE_CLIENT_SECRET=
# GITHUB_CLIENT_ID=
# GITHUB_CLIENT_SECRET=

# ─── Email (Resend) ────────────────────────────────────────────────────────
RESEND_API_KEY=re_CHANGE_ME
EMAIL_FROM=noreply@yourdomain.com

# ─── File uploads (S3) ─────────────────────────────────────────────────────
AWS_REGION=us-east-1
S3_UPLOADS_BUCKET=saas-staging-us-east-1-uploads

# ─── Observability ─────────────────────────────────────────────────────────
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318
OTEL_SERVICE_NAME=saas-api

# ─── Slack notifications (optional in dev) ─────────────────────────────────
# SLACK_WEBHOOK_APP_EVENTS_URL=

# ─── Stripe (sandbox keys for staging; live keys ONLY in production) ───────
# STRIPE_SECRET_KEY=sk_test_CHANGE_ME
# STRIPE_WEBHOOK_SECRET=whsec_CHANGE_ME
```

- [ ] **Step 8: Write `apps/api/src/README.md`**

```markdown
# apps/api/src

Phase 2 will populate this with:

- `app.ts` — Express app builder (no `.listen()`)
- `server.ts` — Binds port
- `routes/` — One file per resource (e.g. `routes/users.ts`, `routes/uploads.ts`, `routes/webhooks-stripe.ts`)
- `services/` — Domain logic (`services/users.ts`)
- `middleware/` — `auth.ts`, `rls-context.ts`, `error-handler.ts`, `request-id.ts`
- `notifications/` — Slack notification helpers
- `email/` — Resend integration; templates in `@saas/shared/email-templates`
- `config/` — `env.ts` (Zod-validated env loading) using `@saas/shared/env`

See the design spec §4 for the full backend architecture.
```

- [ ] **Step 9: Write `apps/api/prisma/README.md`**

```markdown
# apps/api/prisma

Prisma schema, migrations, and the one-time DB role bootstrap script.

## Files

- `schema.prisma` — main schema. BetterAuth tables + Organization plugin tables + domain models.
- `init.sql` — **run once per database** before migrations. Creates two Postgres roles: `app_user` (RLS active) and `app_admin` (BYPASSRLS). Migrations and admin endpoints connect as `app_admin`; the app connects as `app_user`.
- `migrations/` — Prisma-managed schema migrations, plus custom SQL files for RLS policies.

## RLS policy convention

For each new domain model added to `schema.prisma`, you must:

1. Run `prisma migrate dev --name add_<model>` to generate the schema migration.
2. Create a sibling SQL migration `prisma/migrations/<ts>_<model>_rls/migration.sql` that:
   - `ALTER TABLE "<Model>" ENABLE ROW LEVEL SECURITY;`
   - `CREATE POLICY org_isolation ON "<Model>" USING (...) WITH CHECK (...);`
3. CI's `lint:rls` task fails the build if any domain table lacks an RLS policy.

A scaffolding script `pnpm db:add-rls <ModelName>` will generate both atomically in Phase 2.
```

- [ ] **Step 10: Write `apps/api/prisma/schema.prisma`** (skeleton — BetterAuth + Organization + minimal User extension; Phase 2 populates domain models)

```prisma
// Prisma 7 schema for SaaS Boilerplate
// Multi-tenancy enforcement: Postgres RLS. See design spec §4 Multi-tenancy.

generator client {
  provider        = "prisma-client-js"
  previewFeatures = ["driverAdapters", "queryCompiler"]
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL_ADMIN")  // migrations need BYPASSRLS
}

// ─── BetterAuth core tables ────────────────────────────────────────────────
// These are added by BetterAuth's Prisma adapter generator at install time.
// Listed here for reference; do not hand-edit until Phase 2.

model User {
  id                              String    @id
  email                           String    @unique
  name                            String?
  emailVerified                   Boolean   @default(false)
  image                           String?
  createdAt                       DateTime  @default(now())
  updatedAt                       DateTime  @updatedAt

  // Consent / compliance fields (see design spec §4 Auth)
  marketingEmailConsent           Boolean   @default(false)
  marketingEmailConsentedAt       DateTime?
  marketingEmailConsentSource     String?
  ccpaOptOut                      Boolean   @default(false)
  ccpaOptOutAt                    DateTime?
  consentSnapshot                 Json?

  sessions                        Session[]
  accounts                        Account[]
  members                         Member[]
}

model Session {
  id            String   @id
  userId        String
  expiresAt     DateTime
  ipAddress     String?
  userAgent     String?
  activeOrganizationId String?
  activeTeamId  String?
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
  user          User     @relation(fields: [userId], references: [id], onDelete: Cascade)
}

model Account {
  id                    String    @id
  userId                String
  providerId            String
  accountId             String
  accessToken           String?
  refreshToken          String?
  idToken               String?
  accessTokenExpiresAt  DateTime?
  refreshTokenExpiresAt DateTime?
  scope                 String?
  password              String?
  createdAt             DateTime  @default(now())
  updatedAt             DateTime  @updatedAt
  user                  User      @relation(fields: [userId], references: [id], onDelete: Cascade)
}

// ─── BetterAuth Organization plugin tables ────────────────────────────────

model Organization {
  id          String       @id
  name        String
  slug        String       @unique
  logo        String?
  metadata    Json?
  createdAt   DateTime     @default(now())
  members     Member[]
  invitations Invitation[]
  teams       Team[]
}

model Member {
  id             String       @id
  userId         String
  organizationId String
  role           String       // "owner" | "admin" | "member" | custom
  createdAt      DateTime     @default(now())
  user           User         @relation(fields: [userId], references: [id], onDelete: Cascade)
  organization   Organization @relation(fields: [organizationId], references: [id], onDelete: Cascade)
  @@unique([userId, organizationId])
}

model Invitation {
  id             String       @id
  email          String
  inviterId      String
  organizationId String
  role           String
  status         String       // "pending" | "accepted" | "rejected" | "expired"
  expiresAt      DateTime
  organization   Organization @relation(fields: [organizationId], references: [id], onDelete: Cascade)
}

model Team {
  id             String       @id
  name           String
  organizationId String
  createdAt      DateTime     @default(now())
  organization   Organization @relation(fields: [organizationId], references: [id], onDelete: Cascade)
}

// ─── Webhook idempotency (shared by Stripe, Docuseal, Cal.com, etc.) ──────
model ProcessedWebhookEvent {
  id          String   @id              // event id from the source (e.g. evt_xxx for Stripe)
  source      String                    // "stripe" | "docuseal" | "cal" | ...
  processedAt DateTime @default(now())
  @@index([source, processedAt])
}

// ─── File uploads (Phase 2) ────────────────────────────────────────────────
// model Upload { ... } — populated in Phase 2 with organizationId for RLS

// ─── Domain models (Phase 2+) ──────────────────────────────────────────────
// Every new model must include `organizationId String` + a sibling migration
// that ENABLE ROW LEVEL SECURITY and CREATE POLICY org_isolation on it.
```

- [ ] **Step 11: Write `apps/api/prisma/init.sql`**

```sql
-- Run once per database before any Prisma migration.
-- Creates the two roles used for RLS-based multi-tenancy.

-- The application role: RLS policies apply. Used by apps/api and apps/workers
-- at runtime. Cannot bypass RLS, cannot create/drop tables.
CREATE ROLE app_user LOGIN PASSWORD 'CHANGE_ME_BEFORE_PROD';
GRANT CONNECT ON DATABASE postgres TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO app_user;

-- The migration / admin role: BYPASSRLS. Used by Prisma migrations and
-- explicit admin endpoints. Never used in the request path of normal app code.
CREATE ROLE app_admin LOGIN PASSWORD 'CHANGE_ME_BEFORE_PROD' BYPASSRLS;
GRANT ALL PRIVILEGES ON DATABASE postgres TO app_admin;
GRANT ALL PRIVILEGES ON SCHEMA public TO app_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO app_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO app_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO app_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO app_admin;

-- Verify
SELECT rolname, rolbypassrls FROM pg_roles WHERE rolname IN ('app_user', 'app_admin');
```

- [ ] **Step 12: Create empty migrations dir marker**

```bash
mkdir -p apps/api/prisma/migrations
touch apps/api/prisma/migrations/.gitkeep
```

- [ ] **Step 13: Commit**

```bash
git add apps/api/
git commit -m "feat(api): scaffold apps/api with Express+Prisma+BetterAuth structure"
```

---

## Task 5: `apps/workers/` scaffold

**Files:**
- Create: `apps/workers/package.json`
- Create: `apps/workers/README.md`
- Create: `apps/workers/tsconfig.json`
- Create: `apps/workers/eslint.config.js`
- Create: `apps/workers/Dockerfile`
- Create: `apps/workers/.dockerignore`
- Create: `apps/workers/.env.example`
- Create: `apps/workers/src/README.md`

- [ ] **Step 1: Write `apps/workers/package.json`**

```json
{
  "name": "@saas/workers",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "build": "tsc",
    "dev": "tsx watch src/index.ts",
    "start": "node dist/index.js",
    "lint": "eslint .",
    "typecheck": "tsc --noEmit",
    "test": "vitest run"
  },
  "dependencies": {
    "@prisma/client": "7.0.0",
    "@saas/shared": "workspace:*",
    "bullmq": "5.34.0",
    "ioredis": "5.4.2",
    "pino": "9.6.0",
    "zod": "4.0.0",
    "@opentelemetry/api": "1.9.0",
    "@opentelemetry/auto-instrumentations-node": "0.55.0",
    "@opentelemetry/sdk-node": "0.57.0",
    "@opentelemetry/instrumentation-pino": "0.46.0",
    "pino-opentelemetry-transport": "1.0.1",
    "resend": "4.1.1",
    "@react-email/render": "1.0.4"
  },
  "devDependencies": {
    "@saas/config": "workspace:*",
    "@types/node": "22.10.5",
    "tsx": "4.19.2",
    "typescript": "5.7.2",
    "vitest": "3.0.0"
  }
}
```

- [ ] **Step 2: Write `apps/workers/README.md`**

```markdown
# apps/workers

BullMQ worker processes. Runs as a separate Node process from `apps/api/` so queue work doesn't compete with request handling.

## Conventions

- One queue per logical job type. Job processors are plain async functions; bootstrap code wires them to BullMQ `Worker` instances.
- Every job payload includes `organizationId` (validated against the Zod schema in `@saas/shared/zod`). The worker sets the RLS ALS context to that org before invoking the processor — `scopedPrisma` then auto-injects `SET LOCAL app.current_org`.
- Shutdown: SIGTERM → drain in-flight jobs → close Redis + Prisma → exit.

## Layout (Phase 2)

\`\`\`
src/
  index.ts           Bootstrap (registers all workers, starts queue runtime)
  queues/            One file per queue (queue name + job type definition)
  processors/        One file per queue (handler logic)
  bootstrap/         OTel/Pino/shutdown wiring shared with apps/api
\`\`\`

## Env vars

See `.env.example`. Same shape as `apps/api/.env.example` minus HTTP-specific vars.
```

- [ ] **Step 3: Write `apps/workers/tsconfig.json`**

```json
{
  "extends": "@saas/config/tsconfig/node",
  "compilerOptions": {
    "outDir": "dist",
    "rootDir": "src"
  },
  "include": ["src/**/*"],
  "exclude": ["dist", "node_modules"]
}
```

- [ ] **Step 4: Write `apps/workers/eslint.config.js`**

```js
import config from "@saas/config/eslint";
export default config;
```

- [ ] **Step 5: Write `apps/workers/Dockerfile`** (same shape as apps/api but binds no port)

```dockerfile
# syntax=docker/dockerfile:1.7
FROM node:22-alpine AS build
WORKDIR /repo
COPY pnpm-workspace.yaml package.json pnpm-lock.yaml ./
COPY apps/workers/package.json apps/workers/
COPY packages/shared/package.json packages/shared/
COPY packages/config/package.json packages/config/
RUN corepack enable && pnpm install --frozen-lockfile
COPY . .
RUN pnpm --filter @saas/workers build

FROM gcr.io/distroless/nodejs22-debian12 AS runtime
WORKDIR /app
COPY --from=build /repo/apps/workers/dist ./dist
COPY --from=build /repo/apps/workers/node_modules ./node_modules
COPY --from=build /repo/apps/workers/package.json ./
USER nonroot:nonroot
CMD ["dist/index.js"]
```

- [ ] **Step 6: Write `apps/workers/.dockerignore`**

```
node_modules
dist
.turbo
coverage
.env
.env.*
!.env.example
```

- [ ] **Step 7: Write `apps/workers/.env.example`**

```bash
NODE_ENV=development
LOG_LEVEL=info

DATABASE_URL=postgresql://app_user:CHANGE_ME@localhost:5432/saas?schema=public
DATABASE_URL_ADMIN=postgresql://app_admin:CHANGE_ME@localhost:5432/saas?schema=public

REDIS_URL=redis://localhost:6379

RESEND_API_KEY=re_CHANGE_ME
EMAIL_FROM=noreply@yourdomain.com

OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318
OTEL_SERVICE_NAME=saas-workers

# SLACK_WEBHOOK_APP_EVENTS_URL=
```

- [ ] **Step 8: Write `apps/workers/src/README.md`**

```markdown
# apps/workers/src

Phase 2 will populate this with the queue runtime. See the design spec §5.
```

- [ ] **Step 9: Commit**

```bash
git add apps/workers/
git commit -m "feat(workers): scaffold apps/workers with BullMQ skeleton"
```

---

## Task 6: `apps/web/` scaffold

**Files:**
- Create: `apps/web/package.json`
- Create: `apps/web/README.md`
- Create: `apps/web/tsconfig.json`
- Create: `apps/web/tsconfig.node.json`
- Create: `apps/web/eslint.config.js`
- Create: `apps/web/vite.config.ts`
- Create: `apps/web/tailwind.config.ts`
- Create: `apps/web/postcss.config.js`
- Create: `apps/web/index.html`
- Create: `apps/web/.env.example`
- Create: `apps/web/src/README.md`
- Create: `apps/web/src/main.tsx.example`
- Create: `apps/web/public/.gitkeep`

- [ ] **Step 1: Write `apps/web/package.json`**

```json
{
  "name": "@saas/web",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "build": "vite build",
    "dev": "vite",
    "preview": "vite preview",
    "lint": "eslint .",
    "typecheck": "tsc --noEmit",
    "test": "vitest run"
  },
  "dependencies": {
    "@hookform/resolvers": "3.10.0",
    "@saas/api-client": "workspace:*",
    "@saas/shared": "workspace:*",
    "@saas/ui": "workspace:*",
    "@tanstack/react-query": "5.62.10",
    "@tanstack/react-router": "1.95.0",
    "better-auth": "1.2.0",
    "react": "19.0.0",
    "react-dom": "19.0.0",
    "react-hook-form": "7.54.2",
    "tailwindcss": "4.1.4",
    "vanilla-cookieconsent": "3.1.0",
    "zod": "4.0.0"
  },
  "devDependencies": {
    "@saas/config": "workspace:*",
    "@tanstack/router-plugin": "1.95.0",
    "@types/react": "19.0.5",
    "@types/react-dom": "19.0.2",
    "@vitejs/plugin-react": "4.3.4",
    "autoprefixer": "10.4.20",
    "postcss": "8.4.49",
    "typescript": "5.7.2",
    "vite": "8.0.0",
    "vite-plugin-svgr": "4.3.0",
    "vitest": "3.0.0"
  }
}
```

- [ ] **Step 2: Write `apps/web/README.md`**

```markdown
# apps/web

Vite 8 + React 19 + TanStack Router + TanStack Query + shadcn/ui + Tailwind v4.

## Conventions

- File-based routing via TanStack Router (`src/routes/`). Search params validated with Zod schemas per route.
- API client auto-generated by hey-api in `@saas/api-client` — import the React Query hooks directly, never write `fetch()` calls by hand.
- Auth via BetterAuth client. Session state hydrated on app boot.
- Forms via react-hook-form + Zod resolvers; Zod schemas imported from `@saas/shared`.
- Cookie consent (vanilla-cookieconsent / orestbida) configured from `@saas/shared/consent`.
- Logo SVG imported from `@saas/ui/assets/logo.svg` via vite-plugin-svgr.

## Layout (Phase 2)

\`\`\`
src/
  main.tsx              React mount + providers
  router.ts             TanStack Router setup
  routes/               File-based route tree
  hooks/                Custom hooks (incl. useUpload, useActiveOrg)
  components/           App-specific composite components
  lib/                  Auth client, query client, consent init
\`\`\`
```

- [ ] **Step 3: Write `apps/web/tsconfig.json`**

```json
{
  "extends": "@saas/config/tsconfig/react",
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src/**/*"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

- [ ] **Step 4: Write `apps/web/tsconfig.node.json`**

```json
{
  "extends": "@saas/config/tsconfig/base",
  "compilerOptions": {
    "composite": true,
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "noEmit": true
  },
  "include": ["vite.config.ts", "tailwind.config.ts"]
}
```

- [ ] **Step 5: Write `apps/web/eslint.config.js`**

```js
import config from "@saas/config/eslint";
export default config;
```

- [ ] **Step 6: Write `apps/web/vite.config.ts`**

```ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import svgr from 'vite-plugin-svgr';
import { TanStackRouterVite } from '@tanstack/router-plugin/vite';
import path from 'node:path';

export default defineConfig({
  plugins: [
    TanStackRouterVite({ routesDirectory: './src/routes', generatedRouteTree: './src/routeTree.gen.ts' }),
    react(),
    svgr(),
  ],
  resolve: {
    alias: { '@': path.resolve(__dirname, './src') },
  },
  server: { port: 5173 },
});
```

- [ ] **Step 7: Write `apps/web/tailwind.config.ts`**

```ts
import type { Config } from 'tailwindcss';
import preset from '@saas/config/tailwind';

export default {
  presets: [preset],
  content: [
    './index.html',
    './src/**/*.{ts,tsx}',
    '../../packages/ui/src/**/*.{ts,tsx}',
  ],
} satisfies Config;
```

- [ ] **Step 8: Write `apps/web/postcss.config.js`**

```js
export default {
  plugins: {
    '@tailwindcss/postcss': {},
    autoprefixer: {},
  },
};
```

- [ ] **Step 9: Write `apps/web/index.html`**

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>SaaS Boilerplate Web App</title>
    <link rel="icon" type="image/svg+xml" href="/logo-mark.svg" />
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
```

- [ ] **Step 10: Write `apps/web/.env.example`**

```bash
VITE_API_URL=http://localhost:8080
VITE_MARKETING_URL=http://localhost:4321

# Analytics (set in production; omit for dev)
# VITE_PUBLIC_GA_MEASUREMENT_ID=G-XXXXXXXXXX

# Sentry (optional)
# VITE_PUBLIC_SENTRY_DSN=
```

- [ ] **Step 11: Write `apps/web/src/README.md`**

```markdown
# apps/web/src

Phase 2 will populate this with React app code. See the design spec §6.
```

- [ ] **Step 12: Write `apps/web/src/main.tsx.example`** (committed as `.example` so Phase 1 doesn't try to compile React without app code)

```tsx
// PHASE 2: rename to main.tsx and wire providers
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
// import { RouterProvider } from '@tanstack/react-router';
// import { QueryClientProvider } from '@tanstack/react-query';
// import { router, queryClient } from './lib';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <div>Phase 2 placeholder</div>
  </StrictMode>,
);
```

- [ ] **Step 13: Create `public/.gitkeep`**

```bash
mkdir -p apps/web/public && touch apps/web/public/.gitkeep
```

- [ ] **Step 14: Commit**

```bash
git add apps/web/
git commit -m "feat(web): scaffold apps/web with Vite+React+TanStack skeleton"
```

---

## Task 7: `apps/marketing/` scaffold

**Files:**
- Create: `apps/marketing/package.json`
- Create: `apps/marketing/README.md`
- Create: `apps/marketing/tsconfig.json`
- Create: `apps/marketing/eslint.config.js`
- Create: `apps/marketing/astro.config.mjs`
- Create: `apps/marketing/tailwind.config.ts`
- Create: `apps/marketing/.env.example`
- Create: `apps/marketing/src/README.md`
- Create: `apps/marketing/src/pages/.gitkeep`
- Create: `apps/marketing/src/content/config.ts`
- Create: `apps/marketing/public/.gitkeep`

- [ ] **Step 1: Write `apps/marketing/package.json`**

```json
{
  "name": "@saas/marketing",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "build": "astro build",
    "dev": "astro dev",
    "preview": "astro preview",
    "lint": "eslint .",
    "typecheck": "astro check"
  },
  "dependencies": {
    "@astrojs/check": "0.9.4",
    "@astrojs/react": "4.2.0",
    "@astrojs/tailwind": "5.1.4",
    "@saas/shared": "workspace:*",
    "@saas/ui": "workspace:*",
    "astro": "5.1.5",
    "react": "19.0.0",
    "react-dom": "19.0.0",
    "tailwindcss": "4.1.4",
    "vanilla-cookieconsent": "3.1.0"
  },
  "devDependencies": {
    "@saas/config": "workspace:*",
    "@types/react": "19.0.5",
    "@types/react-dom": "19.0.2",
    "typescript": "5.7.2"
  }
}
```

- [ ] **Step 2: Write `apps/marketing/README.md`**

```markdown
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

\`\`\`
src/
  pages/                File-based routing
    index.astro
    privacy.astro
    terms.astro
    do-not-sell-or-share.astro
  layouts/              BaseLayout.astro + footer with required legal links
  components/           Reusable section components (Hero, FeatureGrid, FAQ, ...)
  content/              Astro content collections (blog, changelog)
\`\`\`
```

- [ ] **Step 3: Write `apps/marketing/tsconfig.json`**

```json
{
  "extends": "astro/tsconfigs/strict",
  "compilerOptions": {
    "jsx": "react-jsx",
    "jsxImportSource": "react",
    "baseUrl": ".",
    "paths": { "@/*": ["./src/*"] }
  },
  "include": [".astro/types.d.ts", "**/*"],
  "exclude": ["dist"]
}
```

- [ ] **Step 4: Write `apps/marketing/eslint.config.js`**

```js
import config from "@saas/config/eslint";
export default config;
```

- [ ] **Step 5: Write `apps/marketing/astro.config.mjs`**

```js
import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import tailwind from '@astrojs/tailwind';

export default defineConfig({
  output: 'static',
  integrations: [react(), tailwind({ applyBaseStyles: false })],
  site: 'https://yourdomain.com',
});
```

- [ ] **Step 6: Write `apps/marketing/tailwind.config.ts`**

```ts
import type { Config } from 'tailwindcss';
import preset from '@saas/config/tailwind';

export default {
  presets: [preset],
  content: [
    './src/**/*.{astro,html,js,jsx,ts,tsx,md,mdx}',
    '../../packages/ui/src/**/*.{ts,tsx}',
  ],
} satisfies Config;
```

- [ ] **Step 7: Write `apps/marketing/.env.example`**

```bash
PUBLIC_APP_URL=http://localhost:5173
PUBLIC_API_URL=http://localhost:8080

# PUBLIC_GA_MEASUREMENT_ID=G-XXXXXXXXXX
# PUBLIC_INTERCOM_APP_ID=
```

- [ ] **Step 8: Write `apps/marketing/src/README.md`**

```markdown
# apps/marketing/src

Phase 2 will populate this with Astro pages, layouts, and content. See the design spec §7.
```

- [ ] **Step 9: Write `apps/marketing/src/content/config.ts`** (Astro content collections schema; minimal Phase 1 stub)

```ts
import { defineCollection, z } from 'astro:content';

const blog = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    pubDate: z.coerce.date(),
    author: z.string().default('Anonymous'),
    tags: z.array(z.string()).default([]),
  }),
});

const changelog = defineCollection({
  type: 'content',
  schema: z.object({
    version: z.string(),
    date: z.coerce.date(),
    summary: z.string(),
  }),
});

export const collections = { blog, changelog };
```

- [ ] **Step 10: Create `pages/` and `public/` dir markers**

```bash
mkdir -p apps/marketing/src/pages apps/marketing/public
touch apps/marketing/src/pages/.gitkeep apps/marketing/public/.gitkeep
```

- [ ] **Step 11: Commit**

```bash
git add apps/marketing/
git commit -m "feat(marketing): scaffold apps/marketing with Astro skeleton"
```

---

## Task 8: `packages/shared/` scaffold

**Files:**
- Create: `packages/shared/package.json`
- Create: `packages/shared/README.md`
- Create: `packages/shared/tsconfig.json`
- Create: `packages/shared/eslint.config.js`
- Create: `packages/shared/src/README.md`
- Create: `packages/shared/src/index.ts`
- Create: `packages/shared/src/zod/README.md`
- Create: `packages/shared/src/zod/.gitkeep`
- Create: `packages/shared/src/errors/README.md`
- Create: `packages/shared/src/email-templates/README.md`
- Create: `packages/shared/src/consent/README.md`

- [ ] **Step 1: Write `packages/shared/package.json`**

```json
{
  "name": "@saas/shared",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "exports": {
    ".": "./src/index.ts",
    "./zod": "./src/zod/index.ts",
    "./errors": "./src/errors/index.ts",
    "./env": "./src/env.ts",
    "./define-endpoint": "./src/define-endpoint.ts",
    "./slack": "./src/slack.ts",
    "./email": "./src/email.ts",
    "./db": "./src/db.ts",
    "./consent": "./src/consent/index.ts",
    "./email-templates/*": "./src/email-templates/*"
  },
  "dependencies": {
    "@prisma/client": "7.0.0",
    "@react-email/components": "0.0.32",
    "react": "19.0.0",
    "zod": "4.0.0",
    "zod-openapi": "5.4.6"
  },
  "devDependencies": {
    "@saas/config": "workspace:*",
    "@types/react": "19.0.5",
    "typescript": "5.7.2"
  }
}
```

- [ ] **Step 2: Write `packages/shared/README.md`**

```markdown
# @saas/shared

Code shared between `apps/api`, `apps/workers`, and `apps/web`. Single source of truth for API contracts, env validation, error types, email templates, and the small handful of helpers that exist in multiple apps.

## Subpath exports

| Export | Purpose |
|---|---|
| `@saas/shared/zod` | API contract Zod schemas — single source of truth for backend validation, OpenAPI spec, frontend forms, worker payloads |
| `@saas/shared/errors` | Domain error classes — mapped to RFC 9457 problem documents by the API error middleware |
| `@saas/shared/env` | Zod-validated env loader; throws on missing/invalid envs at process boot |
| `@saas/shared/define-endpoint` | Typed Express helper (~80 lines) — input/output Zod, auto OpenAPI registration, response validation |
| `@saas/shared/slack` | Block Kit helpers + fire-and-forget poster; matches the proven callsaver pattern |
| `@saas/shared/email` | `sendTransactional()` and `sendMarketing()` — the latter enforces `user.marketingEmailConsent` |
| `@saas/shared/db` | RLS-scoped Prisma client + `runInOrgContext()` |
| `@saas/shared/consent` | vanilla-cookieconsent (orestbida) config shared by web app + marketing site |
| `@saas/shared/email-templates/*` | React Email components — Welcome, PasswordReset, MagicLink, OrgInvitation, EmailVerification |

## Phase 1 status

Subdirectories ship as scaffolded folders with READMEs explaining what each will contain. Actual implementations land in Phase 2.
```

- [ ] **Step 3: Write `packages/shared/tsconfig.json`**

```json
{
  "extends": "@saas/config/tsconfig/library",
  "compilerOptions": {
    "outDir": "dist",
    "rootDir": "src",
    "jsx": "react-jsx"
  },
  "include": ["src/**/*"],
  "exclude": ["dist", "node_modules"]
}
```

- [ ] **Step 4: Write `packages/shared/eslint.config.js`**

```js
import config from "@saas/config/eslint";
export default config;
```

- [ ] **Step 5: Write `packages/shared/src/index.ts`** (re-exports — empty for Phase 1 since modules are stubs)

```ts
// Phase 1: subpath modules are scaffolded as folders with READMEs.
// Phase 2: re-exports go here as modules get populated.
export {};
```

- [ ] **Step 6: Write `packages/shared/src/README.md`**

```markdown
# packages/shared/src

| Dir | Purpose | Phase populated |
|---|---|---|
| `zod/` | API contract schemas | Phase 2 |
| `errors/` | Domain error classes | Phase 2 |
| `email-templates/` | React Email components | Phase 2 |
| `consent/` | Cookie consent shared config | Phase 2 |
| `env.ts` | Env validation | Phase 2 |
| `define-endpoint.ts` | Typed Express helper | Phase 2 |
| `slack.ts` | Slack notification helpers | Phase 2 |
| `email.ts` | Transactional/marketing email split | Phase 2 |
| `db.ts` | RLS-scoped Prisma wrapper | Phase 2 |
```

- [ ] **Step 7: Write `packages/shared/src/zod/README.md`**

```markdown
# @saas/shared/zod

API contract Zod schemas. Single source of truth for:

1. Backend request/response validation (via `defineEndpoint`)
2. OpenAPI spec generation (via samchungy/zod-openapi `.meta()`)
3. Frontend form validation (via react-hook-form Zod resolvers)
4. Worker payload validation (BullMQ job payloads)

## Naming convention

- `CreateXSchema`, `UpdateXSchema`, `XResponseSchema`, `XQuerySchema` per resource.
- Files per resource: `users.ts`, `organizations.ts`, `uploads.ts`, ...
- One default `index.ts` re-exports everything for convenience.

## OpenAPI metadata

Use Zod 4's native `.meta()` (no global Zod extension):

\`\`\`ts
const UserId = z.string().uuid().meta({
  id: 'UserId',
  description: 'Unique user identifier',
  example: '00000000-0000-0000-0000-000000000000',
});
\`\`\`

The `id` field makes the schema a reusable `$ref` in the generated OpenAPI spec.
```

- [ ] **Step 8: Write `packages/shared/src/errors/README.md`**

```markdown
# @saas/shared/errors

Domain error classes that the API error middleware maps to RFC 9457 problem documents.

## Phase 2 contents

\`\`\`ts
export class DomainError extends Error {
  constructor(public readonly problemType: string, message: string, public readonly status: number = 400) {
    super(message);
  }
}

export class NotFoundError extends DomainError { /* status 404 */ }
export class UnauthorizedError extends DomainError { /* status 401 */ }
export class ForbiddenError extends DomainError { /* status 403 */ }
export class ConflictError extends DomainError { /* status 409 */ }
export class RateLimitError extends DomainError { /* status 429 */ }
\`\`\`

Each problem `type` is a URI (`https://yourdomain.com/problems/not-found`) and is documented in OpenAPI as a response schema.
```

- [ ] **Step 9: Write `packages/shared/src/email-templates/README.md`**

```markdown
# @saas/shared/email-templates

React Email components. Resend renders these natively:

\`\`\`ts
await resend.emails.send({
  from: env.EMAIL_FROM,
  to: user.email,
  subject: 'Welcome to Acme',
  react: WelcomeEmail({ name: user.name }),
});
\`\`\`

## Phase 2 templates

| File | When sent | Required by |
|---|---|---|
| `WelcomeEmail.tsx` | After signup | UX, not legally required |
| `PasswordResetEmail.tsx` | BetterAuth password reset request | Security |
| `MagicLinkEmail.tsx` | BetterAuth magic link auth (if enabled) | Auth |
| `OrgInvitationEmail.tsx` | BetterAuth org plugin invitation | Org plugin |
| `EmailVerificationEmail.tsx` | Email verification on signup | Anti-fraud |

Each template extends a shared `EmailLayout` component with the company logo, brand colors, and footer containing the required CAN-SPAM physical address + unsubscribe link.
```

- [ ] **Step 10: Write `packages/shared/src/consent/README.md`**

```markdown
# @saas/shared/consent

Cookie consent configuration shared between `apps/web` and `apps/marketing`. Uses [orestbida/cookieconsent](https://github.com/orestbida/cookieconsent) v3.

## Phase 2 contents

- `config.ts` — single `CookieConsentConfig` object with category definitions (necessary / analytics / functional / marketing) and translations.
- `react.ts` — React `useEffect` initializer for `apps/web/`.
- `astro.ts` — script tag generator for `apps/marketing/` `BaseLayout.astro`.
- `gpc.ts` — Sec-GPC global privacy control signal detection.

The same config object is consumed in both shapes. Categories are tied to actual loaders — if `analytics` is denied, GA never initializes (no "load then disable" workaround).
```

- [ ] **Step 11: Create empty scaffolded directories**

```bash
mkdir -p packages/shared/src/{zod,errors,email-templates,consent}
touch packages/shared/src/zod/.gitkeep packages/shared/src/errors/.gitkeep packages/shared/src/email-templates/.gitkeep packages/shared/src/consent/.gitkeep
```

- [ ] **Step 12: Commit**

```bash
git add packages/shared/
git commit -m "feat(shared): scaffold packages/shared with subpath exports + per-module READMEs"
```

---

## Task 9: `packages/ui/` scaffold

**Files:**
- Create: `packages/ui/package.json`
- Create: `packages/ui/README.md`
- Create: `packages/ui/tsconfig.json`
- Create: `packages/ui/eslint.config.js`
- Create: `packages/ui/components.json`
- Create: `packages/ui/src/README.md`
- Create: `packages/ui/src/index.ts`
- Create: `packages/ui/src/assets/README.md`
- Create: `packages/ui/src/assets/logo.svg`
- Create: `packages/ui/src/assets/logo-mark.svg`
- Create: `packages/ui/src/assets/logo-mono.svg`
- Create: `packages/ui/src/shadcn/.gitkeep`
- Create: `packages/ui/src/magicui/.gitkeep`

- [ ] **Step 1: Write `packages/ui/package.json`**

```json
{
  "name": "@saas/ui",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "exports": {
    ".": "./src/index.ts",
    "./shadcn/*": "./src/shadcn/*",
    "./magicui/*": "./src/magicui/*",
    "./assets/*": "./src/assets/*"
  },
  "dependencies": {
    "class-variance-authority": "0.7.1",
    "clsx": "2.1.1",
    "lucide-react": "0.469.0",
    "react": "19.0.0",
    "tailwind-merge": "2.6.0",
    "tailwindcss": "4.1.4"
  },
  "devDependencies": {
    "@saas/config": "workspace:*",
    "@types/react": "19.0.5",
    "typescript": "5.7.2"
  }
}
```

- [ ] **Step 2: Write `packages/ui/README.md`**

```markdown
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
```

- [ ] **Step 3: Write `packages/ui/tsconfig.json`**

```json
{
  "extends": "@saas/config/tsconfig/library",
  "compilerOptions": {
    "outDir": "dist",
    "rootDir": "src",
    "jsx": "react-jsx",
    "lib": ["ES2023", "DOM", "DOM.Iterable"]
  },
  "include": ["src/**/*"],
  "exclude": ["dist", "node_modules"]
}
```

- [ ] **Step 4: Write `packages/ui/eslint.config.js`**

```js
import config from "@saas/config/eslint";
export default config;
```

- [ ] **Step 5: Write `packages/ui/components.json`** (shadcn config)

```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "default",
  "rsc": false,
  "tsx": true,
  "tailwind": {
    "config": "../../apps/web/tailwind.config.ts",
    "css": "../../apps/web/src/styles/globals.css",
    "baseColor": "neutral",
    "cssVariables": true
  },
  "aliases": {
    "components": "@saas/ui/shadcn",
    "utils": "@saas/ui/lib/utils",
    "ui": "@saas/ui/shadcn"
  }
}
```

- [ ] **Step 6: Write `packages/ui/src/index.ts`**

```ts
// Phase 2: re-exports of shadcn + magicui components go here as they get vendored
export {};
```

- [ ] **Step 7: Write `packages/ui/src/README.md`**

```markdown
# packages/ui/src

Components are vendored, not depended on. To add a shadcn component:

\`\`\`
cd packages/ui
npx shadcn@latest add button
\`\`\`

It lands in `src/shadcn/button.tsx`. Customize freely.

For Magic UI:

\`\`\`
cd packages/ui
npx magicui-cli add marquee
\`\`\`

Lands in `src/magicui/marquee.tsx`.
```

- [ ] **Step 8: Write `packages/ui/src/assets/README.md`**

```markdown
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
```

- [ ] **Step 9: Write `packages/ui/src/assets/logo.svg`** (placeholder)

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 40" width="200" height="40">
  <rect x="0" y="8" width="24" height="24" rx="6" fill="currentColor"/>
  <text x="36" y="27" font-family="system-ui, sans-serif" font-size="20" font-weight="600" fill="currentColor">
    Acme SaaS
  </text>
</svg>
```

- [ ] **Step 10: Write `packages/ui/src/assets/logo-mark.svg`**

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32" width="32" height="32">
  <rect x="0" y="0" width="32" height="32" rx="8" fill="currentColor"/>
</svg>
```

- [ ] **Step 11: Write `packages/ui/src/assets/logo-mono.svg`**

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 40" width="200" height="40" fill="currentColor">
  <rect x="0" y="8" width="24" height="24" rx="6"/>
  <text x="36" y="27" font-family="system-ui, sans-serif" font-size="20" font-weight="600">
    Acme SaaS
  </text>
</svg>
```

- [ ] **Step 12: Create shadcn/magicui dir markers**

```bash
mkdir -p packages/ui/src/shadcn packages/ui/src/magicui
touch packages/ui/src/shadcn/.gitkeep packages/ui/src/magicui/.gitkeep
```

- [ ] **Step 13: Commit**

```bash
git add packages/ui/
git commit -m "feat(ui): scaffold packages/ui with shadcn config + placeholder logo SVGs"
```

---

## Task 10: `packages/api-client/` scaffold

**Files:**
- Create: `packages/api-client/package.json`
- Create: `packages/api-client/README.md`
- Create: `packages/api-client/tsconfig.json`
- Create: `packages/api-client/eslint.config.js`
- Create: `packages/api-client/openapi.json` (empty placeholder)
- Create: `packages/api-client/src/README.md`
- Create: `packages/api-client/src/index.ts`
- Create: `packages/api-client/openapi-ts.config.ts`

- [ ] **Step 1: Write `packages/api-client/package.json`**

```json
{
  "name": "@saas/api-client",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "exports": {
    ".": "./src/index.ts",
    "./openapi.json": "./openapi.json"
  },
  "scripts": {
    "generate": "openapi-ts",
    "build": "tsc",
    "lint": "eslint .",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "@hey-api/client-fetch": "0.6.0",
    "@tanstack/react-query": "5.62.10",
    "react": "19.0.0",
    "zod": "4.0.0"
  },
  "devDependencies": {
    "@hey-api/openapi-ts": "0.64.0",
    "@saas/config": "workspace:*",
    "@types/react": "19.0.5",
    "typescript": "5.7.2"
  }
}
```

- [ ] **Step 2: Write `packages/api-client/README.md`**

```markdown
# @saas/api-client

Auto-generated TypeScript client for the boilerplate API. Generated by [`@hey-api/openapi-ts`](https://github.com/hey-api/openapi-ts) from `openapi.json` (which `apps/api` emits via samchungy/zod-openapi).

## Flow

1. `apps/api` build emits `packages/api-client/openapi.json` (Phase 2).
2. `pnpm --filter @saas/api-client generate` regenerates `src/*.gen.ts`.
3. `apps/web` imports `useGetUsers()`, etc. — typed React Query hooks for every endpoint.

## Generated files (Phase 2; committed for diff visibility)

- `src/types.gen.ts` — TypeScript types for every schema + endpoint
- `src/client.gen.ts` — typed fetch client
- `src/sdk.gen.ts` — per-endpoint functions
- `src/@tanstack/react-query.gen.ts` — `useQuery`/`useMutation` hooks for every endpoint
- `src/zod.gen.ts` — Zod schemas (optional; for client-side validation)

Run `pnpm generate` after every API contract change. CI fails if the committed generated files don't match what regeneration produces, preventing schema drift.

## Phase 1 status

`openapi.json` is an empty placeholder. Phase 2 wires up generation.
```

- [ ] **Step 3: Write `packages/api-client/tsconfig.json`**

```json
{
  "extends": "@saas/config/tsconfig/library",
  "compilerOptions": {
    "outDir": "dist",
    "rootDir": "src",
    "jsx": "react-jsx",
    "lib": ["ES2023", "DOM", "DOM.Iterable"]
  },
  "include": ["src/**/*"],
  "exclude": ["dist", "node_modules"]
}
```

- [ ] **Step 4: Write `packages/api-client/eslint.config.js`**

```js
import config from "@saas/config/eslint";
export default config;
```

- [ ] **Step 5: Write `packages/api-client/openapi.json`** (placeholder; regenerated in Phase 2)

```json
{
  "openapi": "3.1.0",
  "info": {
    "title": "SaaS Boilerplate API",
    "version": "0.0.0",
    "description": "Phase 1 placeholder — regenerated by apps/api in Phase 2"
  },
  "paths": {}
}
```

- [ ] **Step 6: Write `packages/api-client/src/README.md`**

```markdown
# packages/api-client/src

Generated files land here in Phase 2. Do not edit manually — regenerate via `pnpm --filter @saas/api-client generate`.
```

- [ ] **Step 7: Write `packages/api-client/src/index.ts`**

```ts
// Phase 2: re-exports of generated client + hooks land here
export {};
```

- [ ] **Step 8: Write `packages/api-client/openapi-ts.config.ts`**

```ts
import { defineConfig } from '@hey-api/openapi-ts';

export default defineConfig({
  input: './openapi.json',
  output: { path: './src', format: 'prettier' },
  plugins: [
    '@hey-api/client-fetch',
    '@hey-api/typescript',
    '@hey-api/sdk',
    {
      name: '@tanstack/react-query',
      queryOptions: true,
      infiniteQueryOptions: true,
      mutationOptions: true,
    },
    'zod',
  ],
});
```

- [ ] **Step 9: Commit**

```bash
git add packages/api-client/
git commit -m "feat(api-client): scaffold packages/api-client with hey-api config + placeholder openapi.json"
```

---

## Task 11: `infra/tofu/` root module

**Files:**
- Create: `infra/tofu/README.md`
- Create: `infra/tofu/main.tf`
- Create: `infra/tofu/variables.tf`
- Create: `infra/tofu/outputs.tf`
- Create: `infra/tofu/versions.tf`
- Create: `infra/tofu/staging.tfvars.example`
- Create: `infra/tofu/production.tfvars.example`
- Create: `infra/tofu/.gitignore`

- [ ] **Step 1: Write `infra/tofu/README.md`**

```markdown
# infra/tofu

OpenTofu modules for deploying the boilerplate to AWS.

## Topology

- **Per-environment workspaces**: `staging` and `production`. Same modules, different `.tfvars`.
- **Single-region default**: `var.aws_region` (defaults `us-east-1`). One hardcoded exception — CloudFront cert MUST be in `us-east-1` and uses provider alias `aws.us_east_1`.
- **Public subnets, no NAT**: ECS in public subnets, tight security groups (ALB SG only). See design spec §12 for the rationale and trade-off.

## Modules

| Module | Resources |
|---|---|
| `network` | VPC, public subnets, IGW, security groups |
| `acm` | Certs: one in deploy region (ALB), one in us-east-1 (CloudFront) |
| `dns` | Route53 records constructed from `var.domain_name` + `var.env_prefix` |
| `registry` | ECR repos for api and workers |
| `secrets` | SSM Parameter Store SecureString parameters |
| `loadbalancer` | ALB + target group + listeners |
| `api` | ECS Fargate service for `apps/api/` |
| `workers` | ECS Fargate service for `apps/workers/` (no ALB; pull-based) |
| `web` | S3 + CloudFront for `apps/web/` static SPA build |
| `marketing` | S3 + CloudFront for `apps/marketing/` static Astro build |
| `logs` | CloudWatch log groups + metric filters |
| `alerts` | SNS topic + Lambda Slack forwarder + CloudWatch alarms + AWS Budgets |

## Deploy

\`\`\`
cd infra/tofu
cp staging.tfvars.example staging.tfvars   # fill in
tofu init
tofu workspace new staging || tofu workspace select staging
tofu apply -var-file=staging.tfvars
\`\`\`

See `docs/operations/launch.md` for the full staging-first → production workflow.

## Phase 1 status

Module directories ship with `main.tf` / `variables.tf` / `outputs.tf` skeletons declaring intended resources via comments. `tofu init && tofu validate` should pass; `tofu plan` will plan zero resource changes (or will error on missing variables). Phase 2 fills in resource bodies.
```

- [ ] **Step 2: Write `infra/tofu/versions.tf`**

```hcl
terraform {
  required_version = ">= 1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
```

- [ ] **Step 3: Write `infra/tofu/variables.tf`**

```hcl
variable "project_name" {
  description = "Short project name used as a prefix for AWS resources."
  type        = string
  default     = "saas"
}

variable "aws_region" {
  description = "AWS region for the deploy. CloudFront cert is always in us-east-1 regardless."
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS account ID this stack deploys into. Used for IAM ARN constraints."
  type        = string
}

variable "domain_name" {
  description = "Apex domain, e.g. \"mysaas.com\". Subdomains constructed from env_prefix + service."
  type        = string
}

variable "env_prefix" {
  description = "Hostname prefix per env: \"\" for production, \"staging.\" for staging."
  type        = string
  validation {
    condition     = contains(["", "staging."], var.env_prefix)
    error_message = "env_prefix must be \"\" or \"staging.\"."
  }
}

variable "environment" {
  description = "\"staging\" or \"production\". Used in resource names/tags."
  type        = string
  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "environment must be \"staging\" or \"production\"."
  }
}

variable "monthly_budget_usd" {
  description = "AWS Budget monthly limit in USD."
  type        = number
  default     = 300
}

variable "budget_email_subscribers" {
  description = "Email addresses that get budget alerts as a fallback to Slack."
  type        = list(string)
  default     = []
}

variable "api_task_count" {
  description = "Desired Fargate task count for the API service."
  type        = number
  default     = 1
}

variable "workers_task_count" {
  description = "Desired Fargate task count for the workers service."
  type        = number
  default     = 1
}

variable "staging_auto_deploy" {
  description = "If true, deploy-staging.yml runs automatically on push to main."
  type        = bool
  default     = true
}

variable "production_auto_deploy" {
  description = "If true, deploy-production.yml runs automatically after successful staging deploy. Default false; manual review via GitHub Environments."
  type        = bool
  default     = false
}
```

- [ ] **Step 4: Write `infra/tofu/main.tf`**

```hcl
# Root module. Wires up provider configuration + module instantiations.
# Phase 1: module blocks are commented out — uncomment as each module's
# resources are populated in Phase 2.

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "OpenTofu"
    }
  }
}

# Second provider alias for CloudFront cert (must live in us-east-1).
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "OpenTofu"
    }
  }
}

# ─── Modules (uncomment as Phase 2 populates them) ─────────────────────────
#
# module "network" {
#   source       = "./modules/network"
#   project_name = var.project_name
#   environment  = var.environment
# }
#
# module "acm" {
#   source        = "./modules/acm"
#   providers     = { aws.us_east_1 = aws.us_east_1 }
#   domain_name   = var.domain_name
#   env_prefix    = var.env_prefix
# }
#
# module "dns" {
#   source       = "./modules/dns"
#   domain_name  = var.domain_name
#   env_prefix   = var.env_prefix
# }
#
# module "registry" {
#   source       = "./modules/registry"
#   project_name = var.project_name
# }
#
# module "secrets" {
#   source       = "./modules/secrets"
#   project_name = var.project_name
#   environment  = var.environment
# }
#
# module "logs" {
#   source       = "./modules/logs"
#   project_name = var.project_name
#   environment  = var.environment
# }
#
# module "loadbalancer" {
#   source        = "./modules/loadbalancer"
#   project_name  = var.project_name
#   environment   = var.environment
#   vpc_id        = module.network.vpc_id
#   subnet_ids    = module.network.public_subnet_ids
#   certificate_arn = module.acm.alb_cert_arn
# }
#
# module "api" {
#   source              = "./modules/api"
#   project_name        = var.project_name
#   environment         = var.environment
#   vpc_id              = module.network.vpc_id
#   subnet_ids          = module.network.public_subnet_ids
#   security_group_id   = module.network.api_security_group_id
#   ecr_repository_url  = module.registry.api_repository_url
#   target_group_arn    = module.loadbalancer.api_target_group_arn
#   secrets_arns        = module.secrets.api_secret_arns
#   log_group_name      = module.logs.api_log_group_name
#   task_count          = var.api_task_count
# }
#
# module "workers" {
#   source              = "./modules/workers"
#   project_name        = var.project_name
#   environment         = var.environment
#   vpc_id              = module.network.vpc_id
#   subnet_ids          = module.network.public_subnet_ids
#   security_group_id   = module.network.workers_security_group_id
#   ecr_repository_url  = module.registry.workers_repository_url
#   secrets_arns        = module.secrets.workers_secret_arns
#   log_group_name      = module.logs.workers_log_group_name
#   task_count          = var.workers_task_count
# }
#
# module "web" {
#   source       = "./modules/web"
#   providers    = { aws.us_east_1 = aws.us_east_1 }
#   project_name = var.project_name
#   environment  = var.environment
#   domain_name  = var.domain_name
#   env_prefix   = var.env_prefix
#   certificate_arn = module.acm.cloudfront_cert_arn
# }
#
# module "marketing" {
#   source       = "./modules/marketing"
#   providers    = { aws.us_east_1 = aws.us_east_1 }
#   project_name = var.project_name
#   environment  = var.environment
#   domain_name  = var.domain_name
#   env_prefix   = var.env_prefix
#   certificate_arn = module.acm.cloudfront_cert_arn
# }
#
# module "alerts" {
#   source                   = "./modules/alerts"
#   project_name             = var.project_name
#   environment              = var.environment
#   monthly_budget_usd       = var.monthly_budget_usd
#   email_subscribers        = var.budget_email_subscribers
#   slack_webhook_ssm_param  = "/${var.project_name}/${var.environment}/slack/alerts-webhook"
#   api_target_group_arn     = module.loadbalancer.api_target_group_arn
#   api_log_group_name       = module.logs.api_log_group_name
# }
```

- [ ] **Step 5: Write `infra/tofu/outputs.tf`**

```hcl
# Phase 1: outputs declared as the corresponding modules get populated.

# output "api_url" {
#   description = "Public URL of the API."
#   value       = "https://${var.env_prefix}api.${var.domain_name}"
# }
#
# output "web_url" {
#   description = "Public URL of the web app SPA."
#   value       = "https://${var.env_prefix}app.${var.domain_name}"
# }
#
# output "marketing_url" {
#   description = "Public URL of the marketing site."
#   value       = "https://${var.domain_name}"
# }
#
# output "ecr_api_repository_url" {
#   description = "ECR repo URL for the API image."
#   value       = module.registry.api_repository_url
# }
#
# output "ecr_workers_repository_url" {
#   description = "ECR repo URL for the workers image."
#   value       = module.registry.workers_repository_url
# }
```

- [ ] **Step 6: Write `infra/tofu/staging.tfvars.example`**

```hcl
project_name              = "saas"
environment               = "staging"
aws_region                = "us-east-1"
aws_account_id            = "000000000000"
domain_name               = "yourdomain.com"
env_prefix                = "staging."
monthly_budget_usd        = 100
budget_email_subscribers  = ["you@yourdomain.com"]
api_task_count            = 1
workers_task_count        = 1
staging_auto_deploy       = true
```

- [ ] **Step 7: Write `infra/tofu/production.tfvars.example`**

```hcl
project_name              = "saas"
environment               = "production"
aws_region                = "us-east-1"
aws_account_id            = "000000000000"
domain_name               = "yourdomain.com"
env_prefix                = ""
monthly_budget_usd        = 300
budget_email_subscribers  = ["you@yourdomain.com", "ops@yourdomain.com"]
api_task_count            = 2
workers_task_count        = 2
production_auto_deploy    = false
```

- [ ] **Step 8: Write `infra/tofu/.gitignore`**

```
.terraform/
.terraform.lock.hcl
*.tfstate
*.tfstate.*
*.tfplan
crash.log
*.tfvars
!*.tfvars.example
override.tf
override.tf.json
*_override.tf
*_override.tf.json
```

- [ ] **Step 9: Commit**

```bash
git add infra/tofu/README.md infra/tofu/main.tf infra/tofu/variables.tf infra/tofu/outputs.tf infra/tofu/versions.tf infra/tofu/staging.tfvars.example infra/tofu/production.tfvars.example infra/tofu/.gitignore
git commit -m "feat(infra): scaffold Tofu root with providers, vars, workspaces"
```

---

## Task 12: `infra/tofu/modules/` core modules — network, acm, dns, registry, loadbalancer, api, workers, logs

**Files** — one directory per module, each with `main.tf` (resource comments), `variables.tf`, `outputs.tf`, `README.md`.

The same scaffold pattern repeats for each module. **For every module in this task, follow Steps 1-4 substituting the values from the per-module table below.**

| Module | Resources to declare (in Phase 2) | Inputs | Outputs |
|---|---|---|---|
| `network` | aws_vpc, aws_subnet (public ×2 AZs), aws_internet_gateway, aws_route_table + association, aws_security_group (alb, api, workers) | `project_name`, `environment` | `vpc_id`, `public_subnet_ids`, `alb_security_group_id`, `api_security_group_id`, `workers_security_group_id` |
| `acm` | aws_acm_certificate (×2: regional ALB cert + us-east-1 CloudFront cert), aws_acm_certificate_validation, aws_route53_record (validation) | `domain_name`, `env_prefix`, `route53_zone_id` (passed in) | `alb_cert_arn`, `cloudfront_cert_arn` |
| `dns` | aws_route53_zone (data source — assumes user created it), aws_route53_record (api, web, marketing, apex) | `domain_name`, `env_prefix`, `alb_dns_name`, `api_alb_zone_id`, `web_cloudfront_domain_name`, `marketing_cloudfront_domain_name` | `route53_zone_id` |
| `registry` | aws_ecr_repository (api, workers), aws_ecr_lifecycle_policy | `project_name` | `api_repository_url`, `workers_repository_url` |
| `loadbalancer` | aws_lb (application), aws_lb_listener (443 + 80→443 redirect), aws_lb_target_group (api), aws_lb_listener_rule | `project_name`, `environment`, `vpc_id`, `subnet_ids`, `certificate_arn`, `alb_security_group_id` | `alb_dns_name`, `alb_zone_id`, `api_target_group_arn`, `alb_arn` |
| `api` | aws_ecs_cluster (shared), aws_ecs_task_definition (api), aws_ecs_service (api), aws_iam_role (task + execution), aws_iam_role_policy_attachment | `project_name`, `environment`, `subnet_ids`, `security_group_id`, `ecr_repository_url`, `target_group_arn`, `secrets_arns`, `log_group_name`, `task_count` | `service_name`, `task_role_arn` |
| `workers` | aws_ecs_task_definition (workers), aws_ecs_service (workers, no LB attachment) | `project_name`, `environment`, `subnet_ids`, `security_group_id`, `ecr_repository_url`, `secrets_arns`, `log_group_name`, `task_count` | `service_name`, `task_role_arn` |
| `logs` | aws_cloudwatch_log_group (api, workers, alerts-lambda), aws_cloudwatch_log_metric_filter (error-rate) | `project_name`, `environment` | `api_log_group_name`, `workers_log_group_name` |

- [ ] **Step 1 (per module): Write `infra/tofu/modules/<module>/README.md`**

Use this template, substituting `<module>` and the resource list from the table:

```markdown
# infra/tofu/modules/<module>

<one-paragraph description of what this module provisions>

## Resources (Phase 2)

<list from the table above>

## Inputs

See `variables.tf`.

## Outputs

See `outputs.tf`.
```

- [ ] **Step 2 (per module): Write `infra/tofu/modules/<module>/variables.tf`**

Declare each input from the "Inputs" column above as `variable "<name>" { type = string; description = "..." }`. Required vars have no `default`; optional vars get sensible defaults. Example for `api`:

```hcl
variable "project_name" {
  type        = string
  description = "Resource name prefix."
}

variable "environment" {
  type        = string
  description = "\"staging\" or \"production\"."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs the ECS service will run in."
}

variable "security_group_id" {
  type        = string
  description = "Security group attached to API tasks (allows ALB SG inbound only)."
}

variable "ecr_repository_url" {
  type        = string
  description = "ECR repository URL for the API image."
}

variable "target_group_arn" {
  type        = string
  description = "ALB target group ARN to register tasks with."
}

variable "secrets_arns" {
  type        = list(string)
  description = "SSM Parameter Store SecureString ARNs the task role can read."
}

variable "log_group_name" {
  type        = string
  description = "CloudWatch log group name for the API task."
}

variable "task_count" {
  type        = number
  description = "Desired Fargate task count."
  default     = 1
}
```

(Use this shape for each module; do NOT copy the API variables into other modules — each module has its own input list per the table.)

- [ ] **Step 3 (per module): Write `infra/tofu/modules/<module>/main.tf`**

For Phase 1, the file documents intent as commented HCL blocks. Example for `network`:

```hcl
# Phase 1 scaffold. Resources stubbed as comments — uncomment and parameterize
# in Phase 2.

# resource "aws_vpc" "main" {
#   cidr_block           = "10.0.0.0/16"
#   enable_dns_hostnames = true
#   tags = { Name = "${var.project_name}-${var.environment}-vpc" }
# }
#
# resource "aws_internet_gateway" "main" {
#   vpc_id = aws_vpc.main.id
#   tags   = { Name = "${var.project_name}-${var.environment}-igw" }
# }
#
# data "aws_availability_zones" "available" { state = "available" }
#
# resource "aws_subnet" "public" {
#   count                   = 2
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
#   availability_zone       = data.aws_availability_zones.available.names[count.index]
#   map_public_ip_on_launch = true
#   tags                    = { Name = "${var.project_name}-${var.environment}-public-${count.index}" }
# }
#
# resource "aws_route_table" "public" {
#   vpc_id = aws_vpc.main.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.main.id
#   }
# }
#
# resource "aws_route_table_association" "public" {
#   count          = length(aws_subnet.public)
#   subnet_id      = aws_subnet.public[count.index].id
#   route_table_id = aws_route_table.public.id
# }
#
# resource "aws_security_group" "alb" {
#   name        = "${var.project_name}-${var.environment}-alb"
#   description = "ALB ingress 443 from anywhere; egress to api SG"
#   vpc_id      = aws_vpc.main.id
#   ingress { from_port = 443; to_port = 443; protocol = "tcp"; cidr_blocks = ["0.0.0.0/0"] }
#   ingress { from_port = 80;  to_port = 80;  protocol = "tcp"; cidr_blocks = ["0.0.0.0/0"] }
#   egress  { from_port = 0;   to_port = 0;   protocol = "-1";  cidr_blocks = ["0.0.0.0/0"] }
# }
#
# resource "aws_security_group" "api" {
#   name        = "${var.project_name}-${var.environment}-api"
#   description = "API tasks: ingress only from ALB SG"
#   vpc_id      = aws_vpc.main.id
#   ingress { from_port = 8080; to_port = 8080; protocol = "tcp"; security_groups = [aws_security_group.alb.id] }
#   egress  { from_port = 0;    to_port = 0;    protocol = "-1";  cidr_blocks = ["0.0.0.0/0"] }
# }
#
# resource "aws_security_group" "workers" {
#   name        = "${var.project_name}-${var.environment}-workers"
#   description = "Workers: no inbound; outbound to internet + Redis/DB"
#   vpc_id      = aws_vpc.main.id
#   egress  { from_port = 0; to_port = 0; protocol = "-1"; cidr_blocks = ["0.0.0.0/0"] }
# }
```

For each module, the `main.tf` is a commented-out version of what Phase 2 will uncomment + populate. Resource list per module is in the table above. **One sentence at top of each file**: `# Phase 1 scaffold. Resources stubbed as comments — populated in Phase 2.`

- [ ] **Step 4 (per module): Write `infra/tofu/modules/<module>/outputs.tf`**

Declare every output from the table as a commented-out block referencing the (also-commented) resource. Example for `network`:

```hcl
# output "vpc_id"                  { value = aws_vpc.main.id }
# output "public_subnet_ids"       { value = aws_subnet.public[*].id }
# output "alb_security_group_id"   { value = aws_security_group.alb.id }
# output "api_security_group_id"   { value = aws_security_group.api.id }
# output "workers_security_group_id" { value = aws_security_group.workers.id }
```

- [ ] **Step 5: Repeat Steps 1-4 for all 8 modules in the table** (network, acm, dns, registry, loadbalancer, api, workers, logs).

- [ ] **Step 6: Verify Tofu syntax**

```bash
cd ~/saas-boilerplate-2026/infra/tofu
tofu fmt -recursive
tofu init -backend=false
tofu validate
```

Expected: `Success! The configuration is valid.` Even with commented-out resource bodies, the module structure must parse.

- [ ] **Step 7: Commit**

```bash
cd ~/saas-boilerplate-2026
git add infra/tofu/modules/
git commit -m "feat(infra): scaffold 8 core Tofu modules (network, acm, dns, registry, lb, api, workers, logs)"
```

---

## Task 13: `infra/tofu/modules/` peripheral modules — secrets, web, marketing, alerts (+ Slack Lambda)

| Module | Resources to declare (in Phase 2) | Inputs | Outputs |
|---|---|---|---|
| `secrets` | aws_ssm_parameter (SecureString, one per required secret listed in `.env.example`) | `project_name`, `environment`, `secret_names` (list) | `api_secret_arns`, `workers_secret_arns` |
| `web` | aws_s3_bucket, aws_s3_bucket_public_access_block, aws_s3_bucket_website_configuration, aws_cloudfront_distribution, aws_cloudfront_origin_access_control, aws_s3_bucket_policy (CloudFront OAC) | `project_name`, `environment`, `domain_name`, `env_prefix`, `certificate_arn` (us-east-1) | `bucket_name`, `cloudfront_distribution_id`, `cloudfront_domain_name` |
| `marketing` | Same shape as `web` but for the Astro static build | `project_name`, `environment`, `domain_name`, `env_prefix`, `certificate_arn` | `bucket_name`, `cloudfront_distribution_id`, `cloudfront_domain_name` |
| `alerts` | aws_sns_topic, aws_sns_topic_policy, aws_sns_topic_subscription (email × N + Lambda), aws_lambda_function (slack forwarder), aws_iam_role + policies for Lambda, aws_cloudwatch_metric_alarm (5xx, p99, DLQ, ECS health, ALB unhealthy), aws_budgets_budget | `project_name`, `environment`, `monthly_budget_usd`, `email_subscribers`, `slack_webhook_ssm_param`, `api_target_group_arn`, `api_log_group_name` | `sns_topic_arn`, `lambda_function_name` |

- [ ] **Step 1: Repeat Steps 1-4 from Task 12 for each of the 4 peripheral modules**, using the table above for their resource lists, inputs, and outputs.

- [ ] **Step 2: Create the alerts module's bundled Lambda source**

The Slack-forwarder Lambda is a real piece of code that ships in this repo (the only Phase 1 application code; everything else is stubs). Lifted from the proven callsaver pattern.

Create `infra/tofu/modules/alerts/lambda/slack-forwarder/index.mjs`:

```js
// SNS -> Slack forwarder. Handles AWS Budgets, CloudWatch Alarms, and custom
// SNS payloads with one code path. Posts Block Kit messages to a webhook URL
// stored in SSM Parameter Store (SecureString, KMS-encrypted).
//
// Pattern lifted from a production setup. Source is in the repo, not a
// vendored package — users own it.

import https from 'node:https';
import { SSMClient, GetParameterCommand } from '@aws-sdk/client-ssm';

const ssm = new SSMClient({});
let cachedWebhookUrl = null;

async function loadWebhookUrl() {
  if (cachedWebhookUrl) return cachedWebhookUrl;
  const name = process.env.SLACK_WEBHOOK_SSM_PARAMETER;
  if (!name) return null;
  const res = await ssm.send(new GetParameterCommand({ Name: name, WithDecryption: true }));
  cachedWebhookUrl = res.Parameter?.Value || null;
  return cachedWebhookUrl;
}

function formatBudgetAlert(message) {
  const budgetName = message.match(/Budget Name: (.+)/)?.[1]?.trim() || 'Unknown';
  const budgetLimit = message.match(/Budgeted Amount: \$([\.\d,]+)/)?.[1]?.trim() || '?';
  const actualSpend = message.match(/ACTUAL Amount: \$([\.\d,]+)/)?.[1]?.trim();
  const forecastedSpend = message.match(/FORECASTED Amount: \$([\.\d,]+)/)?.[1]?.trim();
  const thresholdDollars = message.match(/Alert Threshold: > \$([\.\d,]+)/)?.[1]?.trim();
  const isForecasted = message.includes('FORECASTED');
  const spend = actualSpend || forecastedSpend || '?';
  let thresholdPct = '?';
  if (thresholdDollars && budgetLimit !== '?') {
    const t = parseFloat(thresholdDollars.replace(/,/g, ''));
    const l = parseFloat(budgetLimit.replace(/,/g, ''));
    if (l > 0 && Number.isFinite(t) && Number.isFinite(l)) {
      thresholdPct = Math.round((t / l) * 100).toString();
    }
  }
  const pct = parseFloat(thresholdPct) || 0;
  const emoji = pct >= 100 ? '🔴' : pct >= 85 ? '⚠️' : 'ℹ️';
  const typeLabel = isForecasted
    ? `Forecasted spend exceeds ${thresholdPct}% of budget`
    : `Actual spend exceeded ${thresholdPct}% of budget`;
  return {
    text: `${emoji} Budget alert: ${budgetName} at ${thresholdPct}%`,
    blocks: [
      { type: 'header', text: { type: 'plain_text', text: `${emoji} AWS Budget Alert`, emoji: true } },
      {
        type: 'section',
        fields: [
          { type: 'mrkdwn', text: `*Budget*\n${budgetName}` },
          { type: 'mrkdwn', text: `*Spend*\n$${spend} / $${budgetLimit} (${thresholdPct}%)` },
        ],
      },
      { type: 'section', text: { type: 'mrkdwn', text: `*Type:* ${typeLabel}` } },
      { type: 'context', elements: [{ type: 'mrkdwn', text: `AWS Budget Alert · ${new Date().toLocaleDateString('en-US', { dateStyle: 'medium' })}` }] },
    ],
  };
}

function formatCloudWatchAlarm(payload) {
  const { AlarmName, AlarmDescription, NewStateValue, NewStateReason } = payload;
  const emoji = NewStateValue === 'ALARM' ? '🔴' : NewStateValue === 'OK' ? '✅' : 'ℹ️';
  return {
    text: `${emoji} CloudWatch: ${AlarmName} -> ${NewStateValue}`,
    blocks: [
      { type: 'header', text: { type: 'plain_text', text: `${emoji} CloudWatch Alarm`, emoji: true } },
      {
        type: 'section',
        fields: [
          { type: 'mrkdwn', text: `*Alarm*\n${AlarmName}` },
          { type: 'mrkdwn', text: `*State*\n${NewStateValue}` },
        ],
      },
      ...(AlarmDescription ? [{ type: 'section', text: { type: 'mrkdwn', text: `*Description:* ${AlarmDescription}` } }] : []),
      { type: 'section', text: { type: 'mrkdwn', text: `*Reason:* ${NewStateReason}` } },
    ],
  };
}

async function postToSlack(payload) {
  const webhookUrl = await loadWebhookUrl();
  if (!webhookUrl) {
    console.warn('Slack webhook URL not configured; skipping');
    return;
  }
  const url = new URL(webhookUrl);
  const body = JSON.stringify(payload);
  return new Promise((resolve) => {
    const req = https.request(
      {
        hostname: url.hostname,
        path: url.pathname,
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(body) },
      },
      (res) => {
        console.log('Slack response:', res.statusCode);
        resolve({ statusCode: 200, body: 'OK' });
      },
    );
    req.on('error', (err) => {
      console.error('Slack webhook failed:', err.message);
      resolve({ statusCode: 200, body: 'Webhook failed (non-fatal)' });
    });
    req.write(body);
    req.end();
  });
}

export const handler = async (event) => {
  const record = event.Records?.[0];
  if (!record) return { statusCode: 200, body: 'No records' };
  const message = record.Sns?.Message || '';
  console.log('Alert received:', message.slice(0, 500));

  // Try to parse as CloudWatch Alarm JSON; fall back to AWS Budgets text format
  let payload;
  try {
    const parsed = JSON.parse(message);
    if (parsed.AlarmName) {
      payload = formatCloudWatchAlarm(parsed);
    } else {
      payload = { text: message.slice(0, 500), blocks: [{ type: 'section', text: { type: 'mrkdwn', text: message.slice(0, 2000) } }] };
    }
  } catch {
    payload = formatBudgetAlert(message);
  }

  await postToSlack(payload);
  return { statusCode: 200, body: 'OK' };
};
```

Create `infra/tofu/modules/alerts/lambda/slack-forwarder/package.json`:

```json
{
  "name": "slack-forwarder",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "dependencies": {
    "@aws-sdk/client-ssm": "3.717.0"
  }
}
```

Create `infra/tofu/modules/alerts/lambda/slack-forwarder/README.md`:

```markdown
# Slack forwarder Lambda

SNS-subscribed Lambda that posts AWS Budgets and CloudWatch alarm payloads to a Slack webhook (URL stored in SSM SecureString). Bundled with the alerts Tofu module.

## Build

In Phase 2, the alerts module uses `archive_file` data source to zip `index.mjs` + `node_modules/` for the Lambda deployment. For Phase 1, just `npm install` here to populate `node_modules/` so Phase 2 can zip it.
```

- [ ] **Step 3: Verify Tofu syntax across all modules**

```bash
cd ~/saas-boilerplate-2026/infra/tofu
tofu fmt -recursive
tofu validate
```

Expected: `Success!`

- [ ] **Step 4: Commit**

```bash
cd ~/saas-boilerplate-2026
git add infra/tofu/modules/
git commit -m "feat(infra): scaffold peripheral Tofu modules (secrets, web, marketing, alerts) + Slack Lambda source"
```

---

## Task 14: `docker/compose.yaml` — local dev stack

**Files:**
- Create: `docker/compose.yaml`
- Create: `docker/README.md`
- Create: `docker/otel-collector-config.yaml`

- [ ] **Step 1: Write `docker/compose.yaml`**

```yaml
# Local development stack.
# `docker compose -f docker/compose.yaml up -d` starts Postgres, Redis, OTel collector, MailHog.
# Used by `apps/api`, `apps/workers`, integration tests, and Phase 2's `pnpm dev`.

name: saas-boilerplate-dev

services:
  postgres:
    image: postgres:16-alpine
    container_name: saas-postgres
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: saas
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d saas"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: saas-redis
    command: ["redis-server", "--save", "", "--appendonly", "no"]
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5

  otel-collector:
    image: otel/opentelemetry-collector-contrib:0.116.1
    container_name: saas-otel-collector
    command: ["--config=/etc/otel-collector-config.yaml"]
    volumes:
      - ./otel-collector-config.yaml:/etc/otel-collector-config.yaml:ro
    ports:
      - "4317:4317"   # OTLP gRPC
      - "4318:4318"   # OTLP HTTP
      - "8888:8888"   # Collector self-metrics

  mailhog:
    # Captures all outbound mail from local dev. Web UI at http://localhost:8025.
    image: mailhog/mailhog:v1.0.1
    container_name: saas-mailhog
    ports:
      - "1025:1025"   # SMTP
      - "8025:8025"   # Web UI

volumes:
  postgres-data:
```

- [ ] **Step 2: Write `docker/otel-collector-config.yaml`**

```yaml
receivers:
  otlp:
    protocols:
      grpc: { endpoint: 0.0.0.0:4317 }
      http: { endpoint: 0.0.0.0:4318 }

processors:
  batch:

exporters:
  debug:
    verbosity: detailed

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]
    logs:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]
```

- [ ] **Step 3: Write `docker/README.md`**

```markdown
# docker

Local development stack.

## Start

\`\`\`
docker compose -f docker/compose.yaml up -d
\`\`\`

## Services

| Service | Port | Purpose |
|---|---|---|
| postgres | 5432 | DB for apps/api + apps/workers + integration tests |
| redis | 6379 | BullMQ queue backend + general cache |
| otel-collector | 4317 (gRPC), 4318 (HTTP) | Receives traces/logs/metrics; forwards to stdout in dev |
| mailhog | 1025 (SMTP), 8025 (UI) | Email capture in dev — web UI at http://localhost:8025 |

## Initial setup

After first `up -d`, run the bundled RLS role bootstrap:

\`\`\`
psql 'postgresql://postgres:postgres@localhost:5432/saas' -f apps/api/prisma/init.sql
\`\`\`

Then Prisma migrations:

\`\`\`
DATABASE_URL_ADMIN='postgresql://app_admin:CHANGE_ME@localhost:5432/saas?schema=public' pnpm --filter @saas/api prisma:deploy
\`\`\`

## Stop

\`\`\`
docker compose -f docker/compose.yaml down
\`\`\`

Add `-v` to wipe the postgres volume too.
```

- [ ] **Step 4: Verify compose file parses**

```bash
cd ~/saas-boilerplate-2026
docker compose -f docker/compose.yaml config > /dev/null
```

Expected: no output, exit 0.

- [ ] **Step 5: Commit**

```bash
git add docker/
git commit -m "feat(docker): add local dev compose stack (postgres, redis, otel-collector, mailhog)"
```

---

## Task 15: `.github/workflows/` — CI/CD workflow stubs

All workflows are committed as functional skeletons — they parse, they reference the right secrets/environments, and the structure matches the design spec §13 — but most jobs are commented or stubbed because the actual code they'd build/test doesn't exist yet (that's Phase 2). Workflows that don't need code (`renovate.yml`) can run as-is.

**Files:**
- Create: `.github/workflows/ci.yml`
- Create: `.github/workflows/build-images.yml`
- Create: `.github/workflows/deploy-staging.yml`
- Create: `.github/workflows/deploy-production.yml`
- Create: `.github/workflows/rollback.yml`
- Create: `.github/workflows/e2e.yml`
- Create: `.github/workflows/renovate.yml`

- [ ] **Step 1: Write `.github/workflows/ci.yml`**

```yaml
name: CI

on:
  pull_request:
  push:
    branches: [main]

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  validate:
    name: Lint + Typecheck + Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
        with:
          version: 10
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: pnpm
      - name: Install
        run: pnpm install --frozen-lockfile
      # Phase 2 enables these once code lands:
      # - name: Generate Prisma client
      #   run: pnpm --filter @saas/api prisma:generate
      # - name: Lint
      #   run: pnpm lint
      # - name: Typecheck
      #   run: pnpm typecheck
      # - name: Test
      #   run: pnpm test
      - name: Phase 1 placeholder
        run: echo "Phase 1: only checks pnpm install resolves. Phase 2 wires lint/typecheck/test."
```

- [ ] **Step 2: Write `.github/workflows/build-images.yml`**

```yaml
name: Build Images

on:
  push:
    branches: [main]
  workflow_dispatch:

concurrency:
  group: build-images-${{ github.sha }}
  cancel-in-progress: true

jobs:
  build:
    name: Build & push to ECR
    runs-on: ubuntu-latest
    needs: []  # Phase 2: depends on ci.yml via wait-on-check-action
    permissions:
      contents: read
      id-token: write
    strategy:
      matrix:
        app: [api, workers]
    steps:
      - uses: actions/checkout@v4
      # Phase 2:
      # - uses: aws-actions/configure-aws-credentials@v4
      #   with:
      #     role-to-assume: ${{ secrets.AWS_ROLE_TO_ASSUME }}
      #     aws-region: ${{ vars.AWS_REGION }}
      # - uses: aws-actions/amazon-ecr-login@v2
      # - name: Build and push
      #   uses: docker/build-push-action@v6
      #   with:
      #     context: .
      #     file: apps/${{ matrix.app }}/Dockerfile
      #     push: true
      #     tags: |
      #       ${{ steps.ecr.outputs.registry }}/${{ matrix.app }}:${{ github.sha }}
      #       ${{ steps.ecr.outputs.registry }}/${{ matrix.app }}:latest-main
      #     cache-from: type=registry,ref=${{ steps.ecr.outputs.registry }}/${{ matrix.app }}:latest-main
      #     cache-to: type=inline
      - name: Phase 1 placeholder
        run: echo "Phase 1: workflow structure only. Phase 2 enables ECR build+push."
```

- [ ] **Step 3: Write `.github/workflows/deploy-staging.yml`**

```yaml
name: Deploy Staging

on:
  workflow_run:
    workflows: ["Build Images"]
    types: [completed]
    branches: [main]
  workflow_dispatch:
    inputs:
      sha:
        description: "Git SHA to deploy (defaults to latest main)"
        required: false

concurrency:
  group: deploy-staging
  cancel-in-progress: false

jobs:
  deploy:
    name: Deploy to staging
    if: ${{ github.event.workflow_run.conclusion == 'success' || github.event_name == 'workflow_dispatch' }}
    runs-on: ubuntu-latest
    environment: staging
    permissions:
      contents: read
      id-token: write
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ inputs.sha || github.sha }}
      # Phase 2:
      # - uses: aws-actions/configure-aws-credentials@v4
      #   with:
      #     role-to-assume: ${{ secrets.AWS_STAGING_ROLE_ARN }}
      #     aws-region: ${{ vars.AWS_REGION }}
      # - name: Run migrations as app_admin
      #   run: |
      #     DATABASE_URL=$(aws ssm get-parameter --name /saas/staging/db/admin-url --with-decryption --query Parameter.Value --output text)
      #     DATABASE_URL_ADMIN=$DATABASE_URL pnpm --filter @saas/api prisma:deploy
      # - name: Update ECS service
      #   run: |
      #     aws ecs update-service --cluster saas-staging --service api --force-new-deployment
      #     aws ecs wait services-stable --cluster saas-staging --services api
      # - name: Health check loop
      #   run: ./scripts/healthcheck.sh https://staging.api.${{ vars.DOMAIN_NAME }}
      # - name: Smoke tests
      #   run: pnpm --filter @saas/api test:smoke
      # - name: Record deployed SHA
      #   run: aws ssm put-parameter --name /saas/staging/last-deployed-sha --value "${{ inputs.sha || github.sha }}" --overwrite
      # - name: Notify Slack
      #   uses: ./.github/actions/notify-slack
      #   with:
      #     status: ${{ job.status }}
      #     environment: staging
      #     sha: ${{ inputs.sha || github.sha }}
      - name: Phase 1 placeholder
        run: echo "Phase 1: structure only. Phase 2 enables real deploy + smoke + rollback."
```

- [ ] **Step 4: Write `.github/workflows/deploy-production.yml`**

```yaml
name: Deploy Production

on:
  workflow_dispatch:
    inputs:
      sha:
        description: "Git SHA to deploy (must have been deployed to staging)"
        required: true
      force_deploy:
        description: "Bypass soak-time gate (use sparingly)"
        type: boolean
        default: false

concurrency:
  group: deploy-production
  cancel-in-progress: false

jobs:
  gate:
    name: Production gates
    runs-on: ubuntu-latest
    environment: production
    permissions:
      contents: read
      id-token: write
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ inputs.sha }}
      # Phase 2:
      # - uses: aws-actions/configure-aws-credentials@v4
      #   with:
      #     role-to-assume: ${{ secrets.AWS_PRODUCTION_ROLE_ARN }}
      #     aws-region: ${{ vars.AWS_REGION }}
      # - name: Verify SHA deployed to staging
      #   run: |
      #     STAGING_SHA=$(aws ssm get-parameter --name /saas/staging/last-deployed-sha --query Parameter.Value --output text)
      #     if [ "$STAGING_SHA" != "${{ inputs.sha }}" ]; then
      #       echo "::error::SHA ${{ inputs.sha }} has not been deployed to staging (current staging SHA: $STAGING_SHA)"
      #       exit 1
      #     fi
      # - name: Verify SHA has soaked at least 1 hour in staging
      #   if: ${{ !inputs.force_deploy }}
      #   run: |
      #     DEPLOYED_AT=$(aws ssm get-parameter --name /saas/staging/last-deployed-at --query Parameter.Value --output text)
      #     # ...compare to (now - 3600)...
      # - name: Verify CI green at this SHA
      #   uses: lewagon/wait-on-check-action@v1.3.4
      #   with:
      #     ref: ${{ inputs.sha }}
      #     check-name: "Lint + Typecheck + Test"
      #     allowed-conclusions: success
      - name: Phase 1 placeholder
        run: echo "Phase 1: structure only. Phase 2 wires same-SHA + soak + CI gates."

  deploy:
    needs: [gate]
    name: Deploy to production
    runs-on: ubuntu-latest
    environment: production
    permissions:
      contents: read
      id-token: write
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ inputs.sha }}
      # Phase 2: identical structure to deploy-staging but production cluster + role
      - name: Phase 1 placeholder
        run: echo "Phase 1: structure only."
```

- [ ] **Step 5: Write `.github/workflows/rollback.yml`**

```yaml
name: Rollback

on:
  workflow_dispatch:
    inputs:
      environment:
        description: "Environment to roll back"
        type: choice
        options: [staging, production]
        required: true

jobs:
  rollback:
    name: Roll back to previous SHA
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment }}
    permissions:
      contents: read
      id-token: write
    steps:
      - uses: actions/checkout@v4
      # Phase 2:
      # - name: Get previous SHA
      #   id: prev
      #   run: |
      #     SHA=$(aws ssm get-parameter --name /saas/${{ inputs.environment }}/prev-deployed-sha --query Parameter.Value --output text)
      #     echo "sha=$SHA" >> $GITHUB_OUTPUT
      # - name: Update ECS service to previous task definition
      #   run: ./scripts/rollback.sh ${{ inputs.environment }} ${{ steps.prev.outputs.sha }}
      - name: Phase 1 placeholder
        run: echo "Phase 1: structure only."
```

- [ ] **Step 6: Write `.github/workflows/e2e.yml`**

```yaml
name: E2E

on:
  schedule:
    - cron: "0 6 * * *"   # daily 06:00 UTC
  workflow_dispatch:

jobs:
  playwright:
    name: Playwright vs staging
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
        with:
          version: 10
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: pnpm
      # Phase 2:
      # - run: pnpm install --frozen-lockfile
      # - run: pnpm --filter @saas/e2e exec playwright install --with-deps
      # - run: pnpm test:e2e
      #   env:
      #     BASE_URL: https://staging.app.${{ vars.DOMAIN_NAME }}
      - name: Phase 1 placeholder
        run: echo "Phase 1: structure only."
```

- [ ] **Step 7: Write `.github/workflows/renovate.yml`**

```yaml
name: Renovate

on:
  schedule:
    - cron: "0 * * * *"   # hourly
  workflow_dispatch:

jobs:
  renovate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Renovate
        uses: renovatebot/github-action@v41.0.4
        with:
          configurationFile: renovate.json
          token: ${{ secrets.RENOVATE_TOKEN }}
        # Phase 2 note: set RENOVATE_TOKEN secret to a GitHub PAT with `repo` scope.
        # Or use the hosted Renovate GitHub App instead and disable this workflow.
```

- [ ] **Step 8: Verify workflows parse**

```bash
cd ~/saas-boilerplate-2026
for f in .github/workflows/*.yml; do
  python3 -c "import yaml,sys; yaml.safe_load(open('$f'))" && echo "OK: $f" || echo "FAIL: $f"
done
```

Expected: all `OK:` lines.

- [ ] **Step 9: Commit**

```bash
git add .github/workflows/
git commit -m "feat(ci): add 7 workflow stubs (ci, build-images, deploy-staging/prod, rollback, e2e, renovate)"
```

---

## Task 16: `.github/` — settings, composite actions, CODEOWNERS

**Files:**
- Create: `.github/settings.yml`
- Create: `.github/CODEOWNERS`
- Create: `.github/actions/notify-slack/action.yml`
- Create: `.github/actions/notify-slack/README.md`
- Create: `.github/PULL_REQUEST_TEMPLATE.md`
- Create: `.github/ISSUE_TEMPLATE/bug_report.yml`
- Create: `.github/ISSUE_TEMPLATE/feature_request.yml`

- [ ] **Step 1: Write `.github/settings.yml`** (used by the Probot Settings App if installed; documents intended branch protection)

```yaml
# Branch protection + repo settings. Apply via Probot Settings App, or by hand
# in GitHub UI. Keep this file in sync with the actual repo settings.

repository:
  name: saas-boilerplate
  description: "Opinionated 2026 SaaS starter — Express + Prisma 7 + Vite/React + Astro monorepo."
  homepage: https://github.com/ProsimianLabs/saas-boilerplate
  topics:
    - saas
    - boilerplate
    - typescript
    - express
    - prisma
    - react
    - astro
    - opentofu
    - aws
  private: false
  has_issues: true
  has_projects: false
  has_wiki: false
  has_discussions: true
  default_branch: main
  allow_squash_merge: true
  allow_merge_commit: false
  allow_rebase_merge: false
  delete_branch_on_merge: true
  allow_auto_merge: true

branches:
  - name: main
    protection:
      required_status_checks:
        strict: true
        contexts:
          - "Lint + Typecheck + Test"   # CI workflow job name
      enforce_admins: false
      required_pull_request_reviews:
        required_approving_review_count: 0   # Solo author; raise for team use
        dismiss_stale_reviews: true
      restrictions: null
      required_linear_history: true
      allow_force_pushes: false
      allow_deletions: false

environments:
  - name: staging
    deployment_branch_policy: { protected_branches: true }
  - name: production
    deployment_branch_policy: { protected_branches: true }
    reviewers: []   # Add GitHub usernames for required-reviewer gate
    wait_timer: 0   # Minutes to wait after queued (configure for soak time if not using SSM-based gate)
```

- [ ] **Step 2: Write `.github/CODEOWNERS`**

```
# Default owner for everything
*       @SikandAlex

# Infra changes go through extra review (when team grows; solo for now)
/infra/  @SikandAlex
/.github/ @SikandAlex
```

- [ ] **Step 3: Write `.github/actions/notify-slack/action.yml`**

```yaml
name: "Notify Slack"
description: "Post a Block Kit deploy/CI notification to a Slack webhook"

inputs:
  status:
    description: "Job status (success | failure | cancelled)"
    required: true
  environment:
    description: "staging | production"
    required: true
  sha:
    description: "Git SHA being deployed"
    required: true
  webhook_url:
    description: "Slack webhook URL (from GitHub Environment secret)"
    required: true

runs:
  using: "composite"
  steps:
    - name: Post to Slack
      shell: bash
      run: |
        STATUS="${{ inputs.status }}"
        ENV="${{ inputs.environment }}"
        SHA_SHORT="$(echo "${{ inputs.sha }}" | cut -c1-7)"
        if [ "$STATUS" = "success" ]; then
          EMOJI="✅"; COLOR="good"
        elif [ "$STATUS" = "failure" ]; then
          EMOJI="❌"; COLOR="danger"
        else
          EMOJI="⚠️"; COLOR="warning"
        fi
        PAYLOAD=$(cat <<EOF
        {
          "text": "$EMOJI Deploy $STATUS — $ENV @ $SHA_SHORT",
          "blocks": [
            { "type": "header", "text": { "type": "plain_text", "text": "$EMOJI Deploy $STATUS", "emoji": true } },
            {
              "type": "section",
              "fields": [
                { "type": "mrkdwn", "text": "*Environment*\n$ENV" },
                { "type": "mrkdwn", "text": "*SHA*\n\`$SHA_SHORT\`" }
              ]
            },
            {
              "type": "section",
              "text": { "type": "mrkdwn", "text": "<https://github.com/${{ github.repository }}/actions/runs/${{ github.run_id }}|View run>" }
            }
          ]
        }
        EOF
        )
        curl -sS -X POST -H 'Content-Type: application/json' --data "$PAYLOAD" "${{ inputs.webhook_url }}"
```

- [ ] **Step 4: Write `.github/actions/notify-slack/README.md`**

```markdown
# notify-slack composite action

Posts a Block Kit deploy/CI notification to a Slack incoming webhook.

## Usage

\`\`\`yaml
- uses: ./.github/actions/notify-slack
  if: always()
  with:
    status: ${{ job.status }}
    environment: staging
    sha: ${{ github.sha }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK_DEPLOYS }}
\`\`\`

Webhook URL should be stored as a GitHub Environment secret per env (staging/production), not as a repo-level secret.
```

- [ ] **Step 5: Write `.github/PULL_REQUEST_TEMPLATE.md`**

```markdown
## Summary
<!-- 1-3 bullet points describing what changed -->

## Test plan
<!-- How did you verify this works? -->
- [ ]
- [ ]

## Spec / docs impact
<!-- Did this require changes to the design spec or DEFERRED.md? -->
- [ ] Spec updated (or no change needed)
- [ ] DEFERRED.md updated (or no change needed)

## Multi-tenancy + RLS
<!-- For backend changes -->
- [ ] New domain models include `organizationId`
- [ ] RLS policy migration added for any new domain table
- [ ] No use of `prismaAdmin` outside admin endpoints
```

- [ ] **Step 6: Write `.github/ISSUE_TEMPLATE/bug_report.yml`**

```yaml
name: Bug report
description: Something in the boilerplate doesn't work as documented
labels: [bug]
body:
  - type: textarea
    attributes:
      label: What happened?
      description: Describe the bug
    validations: { required: true }
  - type: textarea
    attributes:
      label: Reproduction steps
    validations: { required: true }
  - type: input
    attributes:
      label: Boilerplate version (commit SHA or tag)
    validations: { required: true }
  - type: dropdown
    attributes:
      label: Phase
      options: [Phase 1 (docs+structure), Phase 2 (working skeleton), Phase 3 (reference features)]
    validations: { required: true }
```

- [ ] **Step 7: Write `.github/ISSUE_TEMPLATE/feature_request.yml`**

```yaml
name: Feature request
description: Suggest a change to the boilerplate
labels: [enhancement]
body:
  - type: textarea
    attributes:
      label: What should the boilerplate add or change?
    validations: { required: true }
  - type: textarea
    attributes:
      label: Why is this valuable? Who needs it?
    validations: { required: true }
  - type: dropdown
    attributes:
      label: Does this belong in DEFERRED.md or in the boilerplate?
      options: [In the boilerplate, In DEFERRED.md (recommended companion tooling), Not sure]
    validations: { required: true }
```

- [ ] **Step 8: Commit**

```bash
git add .github/settings.yml .github/CODEOWNERS .github/actions/ .github/PULL_REQUEST_TEMPLATE.md .github/ISSUE_TEMPLATE/
git commit -m "feat(github): add settings.yml + CODEOWNERS + notify-slack action + PR/issue templates"
```

---

## Task 17: `docs/operations/` — operational runbooks

**Files:**
- Create: `docs/README.md`
- Create: `docs/operations/README.md`
- Create: `docs/operations/launch.md`
- Create: `docs/operations/secrets.md`
- Create: `docs/operations/scaling.md`
- Create: `docs/operations/observability.md`
- Create: `docs/operations/on-call.md`

- [ ] **Step 1: Write `docs/README.md`**

```markdown
# Docs

| Dir | Purpose |
|---|---|
| `superpowers/specs/` | Design specs (canonical architecture reference) |
| `superpowers/plans/` | Implementation plans (this directory) |
| `operations/` | Runbooks for deploys, secrets, scaling, observability, on-call |
| `swap-guides/` | Alternative choices for each opinionated default |
| `integrations/` | Setup guides for recommended companion tooling (Stripe, Sentry, etc.) |

Start with the design spec to understand the boilerplate, then operations for runtime concerns.
```

- [ ] **Step 2: Write `docs/operations/README.md`**

```markdown
# Operations

| Doc | When to read |
|---|---|
| [launch.md](./launch.md) | First time deploying — staging-first workflow → production |
| [secrets.md](./secrets.md) | Managing third-party API keys and DB credentials in SSM |
| [scaling.md](./scaling.md) | When traffic grows beyond defaults (1 task each env) |
| [observability.md](./observability.md) | Wiring CloudWatch logs/traces to external collectors (Honeycomb, Datadog, etc.) |
| [on-call.md](./on-call.md) | Runbook template — alerts you'll get and how to triage |
```

- [ ] **Step 3: Write `docs/operations/launch.md`**

```markdown
# Launch workflow — staging-first to production

This is the canonical adoption arc for a new SaaS built on this boilerplate.

## Prerequisites

- AWS account (or org) with admin IAM access
- Domain registered (any registrar)
- GitHub repo (fork of this boilerplate)
- Slack workspace with admin access to create incoming webhooks
- Local: Docker, pnpm 10+, Node 22, OpenTofu 1.8+

## Step 1: Verify locally

\`\`\`
git clone https://github.com/<your-org>/saas-boilerplate.git
cd saas-boilerplate
pnpm install
docker compose -f docker/compose.yaml up -d
psql 'postgresql://postgres:postgres@localhost:5432/saas' -f apps/api/prisma/init.sql
\`\`\`

Phase 2+ adds `pnpm dev`; for Phase 1, just verify the install resolves and Docker comes up cleanly.

## Step 2: Domain + Route53

- Buy or transfer domain to Route53 (or any registrar with NS delegation).
- Create a Route53 hosted zone for the apex domain.
- Update the registrar's nameservers to point to Route53.

## Step 3: Managed services

Region matching matters — every API request makes at least one DB round-trip; cross-region adds 60–100ms per query.

| Service | Action | Region |
|---|---|---|
| **Neon** | Create project (free tier OK for staging). Match the region to `var.aws_region`. | Same as AWS deploy region |
| | Run `psql <neon-conn-string> -f apps/api/prisma/init.sql` to create `app_user` + `app_admin` roles | |
| | Capture two connection strings: one for `app_user` (DATABASE_URL), one for `app_admin` (DATABASE_URL_ADMIN) | |
| **Upstash** | Create Redis database (free tier OK). Match region. | Same |
| | Capture `REDIS_URL` | |
| **Resend** | Sign up; verify your sending domain | n/a |
| | Generate API key; capture `RESEND_API_KEY` | |
| **Slack** | Create three incoming webhooks for #deploys, #alerts, #app-events | n/a |
| | Capture three webhook URLs | |

## Step 4: Configure staging tfvars + secrets

\`\`\`
cd infra/tofu
cp staging.tfvars.example staging.tfvars
# Edit staging.tfvars — set domain, region, account_id, env_prefix="staging."
\`\`\`

For each secret, put it in SSM Parameter Store **before** running tofu apply:

\`\`\`
aws ssm put-parameter --name /saas/staging/db/url        --type SecureString --value '<DATABASE_URL value>'
aws ssm put-parameter --name /saas/staging/db/admin-url  --type SecureString --value '<DATABASE_URL_ADMIN value>'
aws ssm put-parameter --name /saas/staging/redis/url     --type SecureString --value '<REDIS_URL value>'
aws ssm put-parameter --name /saas/staging/resend/key    --type SecureString --value '<RESEND_API_KEY value>'
aws ssm put-parameter --name /saas/staging/auth/secret   --type SecureString --value "$(openssl rand -base64 32)"
aws ssm put-parameter --name /saas/staging/slack/deploys-webhook   --type SecureString --value '<webhook>'
aws ssm put-parameter --name /saas/staging/slack/alerts-webhook    --type SecureString --value '<webhook>'
aws ssm put-parameter --name /saas/staging/slack/app-events-webhook --type SecureString --value '<webhook>'
\`\`\`

**Credential discipline**: staging uses test/sandbox keys for every third-party service that has them (Stripe sandbox, Resend dev mode, OAuth dev apps). Live keys belong only in `production.tfvars` SSM.

## Step 5: Deploy staging

\`\`\`
tofu init
tofu workspace new staging || tofu workspace select staging
tofu apply -var-file=staging.tfvars
\`\`\`

First apply takes ~10 minutes (CloudFront distribution provisioning is the slowest step).

## Step 6: Validate staging

- Hit `https://staging.api.<your-domain>/healthz` → should return 200
- Hit `https://staging.app.<your-domain>` → should serve the SPA (placeholder in Phase 1)
- Open Slack #alerts channel → should receive AWS Budget creation confirmation

## Step 7: Soak

Run staging for at least a few hours (longer for first-time launches). Do E2E tests, manual flows, smoke checks. Catch problems here, not in production.

## Step 8: Provision production

Repeat Step 3 (managed services) for production — separate Neon project, separate Upstash instance, separate Slack webhooks if you want noise isolation. Repeat Step 4 with `/saas/production/` SSM paths. Live Stripe keys go here, not in staging.

## Step 9: Deploy production

\`\`\`
cp production.tfvars.example production.tfvars
# Edit — env_prefix="", task counts higher, monthly_budget_usd higher
tofu workspace new production || tofu workspace select production
tofu apply -var-file=production.tfvars
\`\`\`

The apex domain comes up at the same time as `app.<domain>` and `api.<domain>`. Marketing site is now live.

## Step 10: GitHub Actions wiring

- In repo Settings → Secrets and variables → Actions:
  - Add `AWS_STAGING_ROLE_ARN` and `AWS_PRODUCTION_ROLE_ARN` (OIDC-trusted roles created in Step 5/9)
  - Add `RENOVATE_TOKEN` (GitHub PAT with `repo` scope) — or skip and use the hosted Renovate App
- In repo Settings → Environments:
  - For `production`, add yourself as a required reviewer (the production-deploy gate)

After this, push-to-main triggers auto staging deploy; production deploys require manual workflow_dispatch + reviewer approval.
```

- [ ] **Step 4: Write `docs/operations/secrets.md`**

```markdown
# Secrets management

All secrets live in **AWS SSM Parameter Store** as `SecureString` (KMS-encrypted with `alias/aws/ssm`). Free at our scale (≤10K params). See design spec §12 for the Secrets Manager comparison and why we picked SSM.

## Naming convention

\`\`\`
/<project>/<environment>/<category>/<name>
\`\`\`

Examples:
- `/saas/staging/db/url`
- `/saas/production/stripe/secret-key`
- `/saas/production/slack/alerts-webhook`

## Adding a new secret

1. Add the env var to the relevant app's `.env.example` (commented if it has a sane local-dev default, uncommented if production-required).
2. Put the value in SSM:
   \`\`\`
   aws ssm put-parameter --name /saas/<env>/<cat>/<name> --type SecureString --value '<value>'
   \`\`\`
3. Add the parameter ARN to the `secrets` Tofu module's input list so the task role gets read permission.
4. In Phase 2, reference the secret in the ECS task definition's `secrets` block:
   \`\`\`hcl
   secrets = [{ name = "STRIPE_SECRET_KEY", valueFrom = "arn:aws:ssm:..." }]
   \`\`\`

## Rotating a secret

For static third-party API keys (no built-in rotation):

1. Generate new value in the provider's console (e.g., Stripe dashboard → API keys → roll).
2. `aws ssm put-parameter --name ... --value '<new>' --overwrite`
3. Force a new ECS deployment to pick up: `aws ecs update-service --cluster ... --service ... --force-new-deployment`
4. Once new tasks are healthy, revoke the old key in the provider's console.

## DB credential rotation (Neon)

Neon supports password reset on app roles. After rotation:
1. Update SSM `DATABASE_URL` parameter.
2. Force ECS redeploy.
3. Optionally drop the old role's connections via Neon dashboard.

## Why not Secrets Manager?

See design spec §12. Tl;dr: Secrets Manager costs $0.40/secret/month with no functional benefit for our use case (no RDS rotation, no cross-region replication needs, no random password generation needs). Swap guide for users who specifically want it: `docs/swap-guides/aws-secrets-manager.md`.
```

- [ ] **Step 5: Write `docs/operations/scaling.md`**

```markdown
# Scaling guidance

The boilerplate ships sized for **early-stage SaaS**: 1 Fargate task per service in staging, 2 in production. Here's how to grow.

## When to bump task count

Watch the `api_p99_latency` and `api_5xx_rate` CloudWatch alarms. If p99 sustained > 1s under normal load, add a task:

\`\`\`
# Edit production.tfvars
api_task_count = 4
tofu apply -var-file=production.tfvars
\`\`\`

ECS rolls the new task in with the existing ones (rolling deployment). Zero downtime.

## When to scale task size

Default Fargate task: 0.5 vCPU, 1 GB RAM. Bump to 1 vCPU / 2 GB if individual requests are CPU-bound (e.g., heavy data processing per endpoint). Beyond that, prefer more tasks over bigger tasks — concurrency at the load balancer beats single-task verticality.

## Database

Neon scales independently. If you hit connection limits:
- Use Neon's pgBouncer endpoint for app code (transaction pooling)
- Use the direct endpoint for migrations (session pooling, needed for `SET LOCAL`)

For very high read load, add a Neon read replica and route read-only queries to it via a separate Prisma client.

## Redis

Upstash REST endpoint scales to thousands of req/sec on the free tier; their paid tiers go far higher. If BullMQ throughput becomes a bottleneck:
- Increase worker concurrency per queue (`Worker({ concurrency: 10 })`)
- Split queues across multiple worker tasks (run multiple `workers` ECS services with different queue subsets)
- Move to dedicated Redis (Upstash Pro tier, or ElastiCache via `docs/swap-guides/redis-elasticache.md`)

## CloudFront

Marketing + web SPA are CDN-served — they scale infinitely without intervention. If you have a global user base, CloudFront edge locations handle latency for free.

## What to NOT scale prematurely

- Don't add NAT Gateway unless you need private subnets for compliance (see design spec §12).
- Don't move to Multi-AZ RDS — Neon handles HA already.
- Don't move to ElastiCache — Upstash handles HA already.
- Don't add Aurora — Neon's pricing wins until you're at very high scale.
```

- [ ] **Step 6: Write `docs/operations/observability.md`**

```markdown
# Observability

All apps emit OpenTelemetry traces + logs + metrics. Local dev forwards to stdout (via the `otel-collector` Docker service). Production needs an external collector.

## Default local flow

\`\`\`
apps/api / apps/workers
  ↓ OTLP (HTTP, port 4318)
local otel-collector
  ↓ stdout (debug exporter)
your terminal
\`\`\`

## Production: pick a backend

| Backend | How |
|---|---|
| **Honeycomb** | Set `OTEL_EXPORTER_OTLP_ENDPOINT=https://api.honeycomb.io` + `OTEL_EXPORTER_OTLP_HEADERS=x-honeycomb-team=<api-key>` |
| **Grafana Cloud** | Set OTLP endpoint + auth header per [Grafana docs](https://grafana.com/docs/grafana-cloud/send-data/otlp/) |
| **Datadog** | Set OTLP endpoint to your dd-agent or use Datadog OTel collector intermediary |
| **AWS X-Ray** | Run AWS Distro for OpenTelemetry (ADOT) collector as a sidecar; X-Ray is the trace store |
| **SigNoz / GlitchTip self-hosted** | Run your own collector + storage |

Update the SSM parameter `/saas/<env>/otel/endpoint` (and headers if needed). Phase 2 wires the ECS task definition to inject these as env vars.

## What you get out of the box

- **Traces**: every HTTP request, every Prisma query, every BullMQ job — auto-instrumented via `@opentelemetry/auto-instrumentations-node`.
- **Logs**: every Pino log line carries `trace_id` + `span_id` so you can pivot from a trace to its logs.
- **Metrics**: request rate, error rate, duration p50/p95/p99 per route. ECS task CPU/memory via CloudWatch.

## Slack alerts vs OTel

The two streams overlap but serve different purposes:
- **OTel** = your daily debugging signal — open the trace, see what happened.
- **Slack #alerts** = wake-up notifications when something crosses a threshold.

See `docs/operations/on-call.md` for the alerts that ship by default.
```

- [ ] **Step 7: Write `docs/operations/on-call.md`**

```markdown
# On-call runbook (template)

Alerts you will receive in `#alerts`, what they mean, and how to triage.

## Default alarms (Phase 2 wires them in Tofu `alerts` module)

| Alarm | Threshold | What to check first |
|---|---|---|
| **API 5xx rate > 1%** | 5min sustained | OTel traces for the failing endpoint; recent deploy diff |
| **API p99 latency > 2s** | 5min sustained | Slow DB queries (Neon dashboard); cold starts on a new deploy |
| **ECS API task unhealthy** | `runningCount < desiredCount` for 5min | ECS console → task status; CloudWatch logs for the failing container |
| **ALB unhealthy targets > 0** | 5min | Health check failing on a task; investigate that task's logs |
| **BullMQ DLQ depth > 100** | Any time | Worker logs for the failing job type; check Upstash for queue state |
| **Worker task crashes > 3 in 10min** | Crash loop | Container crash logs; recent worker code change |
| **API log error rate > 50/min** | Sustained | Log group filter for `ERROR`; usually downstream service degradation |

## AWS Budget alerts

| Threshold | Action |
|---|---|
| 50% | Informational — no action needed |
| 85% | Review spend; consider scaling down if month is still young |
| 100% | Alert — find the cost driver; check NAT/data transfer/ECS task count |
| 150%+ | Critical — likely runaway resource (unbounded log volume, accidental large EC2, abandoned NAT) |

## Incident response template

When you get a critical alarm:

1. **Acknowledge** in #alerts (thread reply) so collaborators know it's being handled.
2. **Triage** via the trace ID in the alarm message → OTel UI → see the failing trace.
3. **Decide**: rollback or fix forward? If unsure, **rollback** (`gh workflow run rollback.yml -f environment=production`) and investigate calmly.
4. **Post-incident**: write a brief note in #alerts thread — what happened, what you did, what's next. No need for formal RCA docs until incidents get user-impacting and frequent.
```

- [ ] **Step 8: Commit**

```bash
git add docs/README.md docs/operations/
git commit -m "docs(operations): add launch, secrets, scaling, observability, on-call runbooks"
```

---

## Task 18: `docs/swap-guides/` — alternative-choice skeletons

For each swap guide referenced in the design spec, ship a markdown file with:
- Why you might want this swap
- High-level approach (3-5 bullets)
- Concrete change list (files touched, env vars added/removed)
- A "Phase 1 stub" note that says the full walkthrough lands in Phase 2 once the relevant default code exists

This keeps the guide structure committed and discoverable, even when the content is brief.

**Files:**
- Create: `docs/swap-guides/README.md`
- Create: `docs/swap-guides/marketing-nextjs.md`
- Create: `docs/swap-guides/marketing-vite.md`
- Create: `docs/swap-guides/redis-elasticache.md`
- Create: `docs/swap-guides/redis-self-hosted.md`
- Create: `docs/swap-guides/auth-neon-auth.md`
- Create: `docs/swap-guides/auth-clerk.md`
- Create: `docs/swap-guides/iac-cdk.md`
- Create: `docs/swap-guides/iac-pulumi.md`
- Create: `docs/swap-guides/aws-ecs-express-mode.md`
- Create: `docs/swap-guides/aws-with-rds.md`
- Create: `docs/swap-guides/aws-with-nat-gateway.md`
- Create: `docs/swap-guides/aws-secrets-manager.md`
- Create: `docs/swap-guides/db-supabase.md`
- Create: `docs/swap-guides/db-railway.md`
- Create: `docs/swap-guides/email-mjml.md`
- Create: `docs/swap-guides/email-sendgrid.md`
- Create: `docs/swap-guides/email-postmark.md`
- Create: `docs/swap-guides/host-fly.md`
- Create: `docs/swap-guides/host-render.md`
- Create: `docs/swap-guides/host-railway.md`
- Create: `docs/swap-guides/host-cloud-run.md`
- Create: `docs/swap-guides/multi-tenancy-app-layer.md`
- Create: `docs/swap-guides/router-react-router.md`

- [ ] **Step 1: Write `docs/swap-guides/README.md`**

```markdown
# Swap guides

For each opinionated default in the boilerplate, here's how to swap it for an alternative without abandoning the rest of the stack. Each guide is opinionated about the *what* and *how*; you decide *whether*.

| Slot | Default | Guides |
|---|---|---|
| Marketing framework | Astro | [Next.js](./marketing-nextjs.md), [Vite SPA](./marketing-vite.md) |
| Redis hosting | Upstash | [ElastiCache](./redis-elasticache.md), [self-hosted](./redis-self-hosted.md) |
| Auth provider | BetterAuth | [Neon Auth wrapper](./auth-neon-auth.md), [Clerk](./auth-clerk.md) |
| IaC | OpenTofu | [AWS CDK](./iac-cdk.md), [Pulumi](./iac-pulumi.md), [ECS Express Mode CLI (no IaC)](./aws-ecs-express-mode.md) |
| AWS topology | Public subnets, no NAT | [+ NAT Gateway / private subnets](./aws-with-nat-gateway.md), [+ RDS instead of Neon](./aws-with-rds.md) |
| Secrets | SSM Parameter Store | [AWS Secrets Manager](./aws-secrets-manager.md) |
| Database | Neon | [Supabase](./db-supabase.md), [Railway Postgres](./db-railway.md) |
| Email templates | React Email | [MJML](./email-mjml.md) |
| Email sending | Resend | [SendGrid](./email-sendgrid.md), [Postmark](./email-postmark.md) |
| Hosting (instead of AWS) | — | [Fly.io](./host-fly.md), [Render](./host-render.md), [Railway](./host-railway.md), [Cloud Run](./host-cloud-run.md) |
| Multi-tenancy enforcement | Postgres RLS | [App-layer wrapper](./multi-tenancy-app-layer.md) |
| Routing | TanStack Router | [React Router 7](./router-react-router.md) |
```

- [ ] **Step 2: Write each swap guide using this template**

For every file listed in the "Files" section above, write content following this template (substituting per-guide):

```markdown
# Swap: <slot> → <alternative>

## Why swap

<1-2 sentences. Honest about tradeoffs.>

## What changes

| Aspect | Default | After swap |
|---|---|---|
| ... | ... | ... |

## Steps (high level)

1. <bullet>
2. <bullet>
3. <bullet>

## Files touched

- `<path>` — <what changes>
- `<path>` — <what changes>

## Env vars

- Add: `<NAME>`
- Remove: `<NAME>`

## Phase 1 status

This guide is a stub until Phase 2 adds the default code it's replacing. The structural choices documented here will hold; specific code diffs will be filled in later.
```

Some examples of how to fill the template (do this for all 23 swap files; the structure is identical):

**`docs/swap-guides/marketing-nextjs.md`:**
```markdown
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
```

For other guides (`marketing-vite.md`, `redis-elasticache.md`, `auth-clerk.md`, etc.), follow the same template with the appropriate slot/default/alternative substituted. Keep each guide under 60 lines for Phase 1.

- [ ] **Step 3: Commit (batch all swap guides together)**

```bash
git add docs/swap-guides/
git commit -m "docs(swap-guides): scaffold 23 alternative-choice guides for every opinionated default"
```

---

## Task 19: `docs/integrations/` — companion-tool setup guides

For each tool in design spec §16 (Recommended companion tooling), ship a setup guide. Same template approach as Task 18 but focused on "how to add this tool to a fresh boilerplate fork."

**Files:**
- Create: `docs/integrations/README.md`
- Create: `docs/integrations/stripe.md`
- Create: `docs/integrations/cal-com.md`
- Create: `docs/integrations/google-analytics.md`
- Create: `docs/integrations/google-search-console.md`
- Create: `docs/integrations/intercom.md`
- Create: `docs/integrations/sentry.md`
- Create: `docs/integrations/docuseal.md`
- Create: `docs/integrations/file-uploads.md`

- [ ] **Step 1: Write `docs/integrations/README.md`**

```markdown
# Integration guides

How to wire up the companion tools listed in the design spec §16. None of these are installed by default — pick the ones your product needs.

| Tool | Purpose | Setup guide |
|---|---|---|
| Stripe | Billing | [stripe.md](./stripe.md) |
| Cal.com | Scheduling | [cal-com.md](./cal-com.md) |
| Google Analytics (GA4) | Web analytics | [google-analytics.md](./google-analytics.md) |
| Google Search Console | SEO + sitemap | [google-search-console.md](./google-search-console.md) |
| Intercom | Customer support chat | [intercom.md](./intercom.md) |
| Sentry | Error monitoring | [sentry.md](./sentry.md) |
| Docuseal | E-signature | [docuseal.md](./docuseal.md) |

Plus:
- [file-uploads.md](./file-uploads.md) — S3 presigned URL pattern (Phase 1 documentation; Phase 2 ships the code).
```

- [ ] **Step 2: Write each integration guide using this template**

```markdown
# <Tool name>

## What it is

<2-3 sentences>

## Why it's not bundled

<1-2 sentences from design spec §16>

## Cost

<free tier limits + paid tier shape>

## Step-by-step setup

1. <account creation>
2. <credential acquisition — where to find it>
3. <env var to set>
4. <code snippet to add and where>
5. <verification step>

## Env vars

\`\`\`bash
TOOL_API_KEY=...
TOOL_OTHER_VAR=...
\`\`\`

## Where it plugs in

- `apps/api/...`
- `apps/web/...`
- `apps/marketing/...`

## Common gotchas

- <gotcha 1>
- <gotcha 2>

## Phase 1 status

Setup guidance documented. Phase 2+ adds working integration code where applicable (e.g., Stripe webhook handler stub, Sentry init in apps).
```

For each tool, fill the template with content from design spec §16 plus public knowledge (cost shape, common gotchas). Keep each guide under 100 lines.

- [ ] **Step 3: Write `docs/integrations/file-uploads.md` more fully** (this one's a real architectural reference)

```markdown
# File uploads — S3 presigned URLs

The boilerplate's recommended file upload pattern. Documentation in Phase 1; working code in Phase 2.

## Why presigned URLs (not API proxy)

| Approach | Trade-off |
|---|---|
| **Presigned URLs** (recommended) | API stays stateless; bytes never touch your servers; scales to large files; needs round-trip to get URL |
| API proxies bytes | Simpler client code; API memory/disk pressure; doesn't scale to large files; harder to make resumable |

## The 4-step flow

\`\`\`
1. Client → POST /uploads { filename, contentType, size }
2. API → validates, generates presigned PUT URL, returns { uploadUrl, fileKey, expiresAt }
3. Client → PUT directly to S3 with the presigned URL
4. Client → POST /uploads/:key/confirm
5. API → HEAD S3 object exists, creates Upload row linked to user + organization
\`\`\`

## Bucket structure

\`\`\`
<bucket>/uploads/<organizationId>/<userId>/<uploadId>-<filename>
\`\`\`

The `organizationId` prefix lets you set IAM policies on the per-task ECS role that restrict access to objects with the task's org prefix — defense in depth on top of app-level RLS.

## IAM scoping

The API task role's S3 policy:

\`\`\`json
{
  "Effect": "Allow",
  "Action": ["s3:PutObject", "s3:GetObject", "s3:DeleteObject"],
  "Resource": "arn:aws:s3:::<bucket>/uploads/*"
}
\`\`\`

For stricter isolation, use IAM session tags + ABAC to limit each request's effective permissions to one `organizationId` prefix. Phase 3 enhancement.

## Phase 2 ships

- `apps/api/src/routes/uploads.ts` — presigned URL endpoint + confirm endpoint
- `packages/shared/zod/upload.ts` — request/response schemas
- `apps/web/src/hooks/useUpload.ts` — React hook handling the 4-step flow with progress
- `infra/tofu/modules/s3-uploads/` — bucket + lifecycle policy (auto-expire abandoned uploads at 24h) + CORS

## Not bundled (deferred)

- **Image processing / thumbnails** (Sharp on a Lambda? Cloudflare Images? Imgproxy?) — varies too much per product
- **Antivirus scanning** (ClamAV? AWS GuardDuty Malware Protection?) — needed for user-generated content with social features
- **Direct integration with Docuseal / other doc services** — see those tools' integration guides
```

- [ ] **Step 4: Commit**

```bash
git add docs/integrations/
git commit -m "docs(integrations): scaffold setup guides for Stripe, Cal.com, GA4, GSC, Intercom, Sentry, Docuseal, file-uploads"
```

---

## Task 20: `AGENTS.md` — agent-readable architecture summary

This is the **single most important Phase 1 deliverable** for AI-agent users. Sister doc to `README.md`, formatted for an LLM coding agent to ingest in one read and immediately know the architecture, conventions, and where things live. Flat structure, no nesting, no marketing prose.

**Files:**
- Create: `~/saas-boilerplate-2026/AGENTS.md`

- [ ] **Step 1: Write `AGENTS.md`**

```markdown
# AGENTS.md

> Agent-readable architecture summary. Optimized for ingestion by Claude / Cursor / Aider / etc. Sister doc to `README.md`. Canonical reference is `docs/superpowers/specs/2026-05-17-saas-boilerplate-design.md` — read that for full rationale.

## What this repo is

A 2026 opinionated SaaS boilerplate. Express + Prisma 7 + Vite/React + Astro in a Turborepo + pnpm monorepo. Deploys to AWS via OpenTofu. Managed-everywhere defaults: Neon (Postgres), Upstash (Redis), Resend (email). Phase 1 ships docs + structure + pinned dependencies; Phase 2 will ship the working skeleton.

## Top-level layout

\`\`\`
saas-boilerplate/
├── apps/
│   ├── api/          Express 5 + Prisma 7 + BetterAuth + Zod 4
│   ├── workers/      BullMQ workers (separate process from api)
│   ├── web/          Vite 8 + React 19 + TanStack Router + Query
│   └── marketing/    Astro 5 static site
├── packages/
│   ├── shared/       Zod schemas, errors, env, define-endpoint, slack, email, db, consent
│   ├── config/       ESLint, Prettier, TypeScript, Tailwind presets
│   ├── ui/           shadcn + Magic UI vendored components + logo SVGs
│   └── api-client/   hey-api generated typed client + React Query hooks
├── infra/tofu/       OpenTofu modules (12 modules, two workspaces: staging + production)
├── docker/           Local dev compose (postgres, redis, otel-collector, mailhog)
├── docs/             Spec, plans, operations, swap-guides, integrations
└── .github/          Workflows, settings, composite actions
\`\`\`

## Critical conventions

### Express, not framework-on-Express
`apps/api/src/app.ts` exports the Express `app`. `apps/api/src/server.ts` imports it and binds the port. Use the `defineEndpoint()` helper from `@saas/shared/define-endpoint` for typed input/output + auto OpenAPI registration. DO NOT introduce express-zod-api or similar wrappers — they're framework lock-in.

### Zod is the source of truth for API contracts
Schemas live in `packages/shared/src/zod/`. The same schema is used by:
1. API request/response validation
2. OpenAPI spec generation (via samchungy/zod-openapi `.meta()`)
3. Frontend form validation (react-hook-form + Zod resolvers)
4. Worker payload validation

Use Zod 4's native `.meta()` — no global Zod extension.

### Prisma is the source of truth for DB types
Use Prisma's `Prisma.UserGetPayload<...>` and `Prisma.UserCreateInput` for DB-internal types. DO NOT add prisma-zod-generator — see spec §4 for why (the wrong abstraction; you'll override 80% of generated schemas).

### Multi-tenancy: Postgres RLS
Two DB roles: `app_user` (RLS active) and `app_admin` (BYPASSRLS, migrations + admin endpoints only). The scoped `prisma` client in `packages/shared/src/db.ts` auto-injects `SET LOCAL app.current_org` per request via AsyncLocalStorage. `prismaAdmin` exists for explicit admin use only.

Every domain table needs:
1. `organizationId String` field (indexed)
2. A custom-SQL migration enabling RLS + creating the `org_isolation` policy
3. The model added to `SCOPED_MODELS` set

CI's `lint:rls` step fails the build if any domain table lacks an RLS policy.

### Auth: BetterAuth direct
Not wrapped by Neon Auth. Organization plugin enabled by default. Sessions carry `activeOrganizationId`.

### Workers in a separate process
`apps/workers/` is its own ECS service, its own container. Job payloads include `organizationId` (Zod-validated). Worker bootstrap wraps each job in `runInOrgContext(payload.organizationId, () => handler(payload))` so the same RLS-scoped Prisma client works.

### Marketing on Astro, not Next.js
Static output. React islands for interactive bits (Magic UI, forms). Avoids Next.js → Vercel framework gravity. Marketing site is decoupled from the React SPA.

### Logo: SVG only
`packages/ui/src/assets/logo.svg` + `logo-mark.svg` + `logo-mono.svg`. Imported via `vite-plugin-svgr` (web app) and Astro's native SVG (marketing).

### Cookie consent: bundled
`vanilla-cookieconsent` (orestbida) wired in `packages/shared/src/consent/`. Shared config consumed by both apps/web and apps/marketing. Categories tied to actual loaders (deny analytics → GA never initializes).

### Email: React Email + Resend
Templates in `packages/shared/src/email-templates/`. Resend renders React Email natively. Use `sendTransactional()` always-allowed; `sendMarketing()` enforces `user.marketingEmailConsent` gate.

### File uploads: presigned URLs, never proxy bytes
S3 bucket path includes `organizationId` prefix for IAM-level scoping. Phase 2 ships the endpoint pair + hook.

## Deployment model

Two Tofu workspaces: `staging`, `production`. Same modules, different `.tfvars`. Hostnames constructed via `var.env_prefix` (`""` for prod, `"staging."` for staging).

| Hostname | Resource |
|---|---|
| `<domain>` | Marketing (Astro/CloudFront) |
| `app.<domain>` | Web app SPA (Vite/CloudFront) |
| `api.<domain>` | API (Express/ALB) |
| `staging.app.<domain>` | Staging web app |
| `staging.api.<domain>` | Staging API |

Single AWS region via `var.aws_region` (default `us-east-1`). CloudFront cert MUST be in us-east-1 (CloudFront constraint) — Tofu uses a second provider alias `aws.us_east_1` for that one cert.

**No** RDS (use Neon), **no** ElastiCache (use Upstash), **no** NAT Gateway (public subnets + tight SGs).

## CI/CD shape

- `ci.yml` runs on PR: install, typecheck, lint, test (Vitest + Testcontainers), build
- `build-images.yml` runs on merge to main: builds + pushes Docker images to ECR tagged with git SHA
- `deploy-staging.yml` auto-promotes the SHA to staging: migrate (as `app_admin`) → update ECS → health check loop → smoke tests → Slack notify; auto-rollback on smoke fail
- `deploy-production.yml` is manual (`workflow_dispatch`) with required reviewer. Gates: SHA must have been deployed to staging, soaked ≥ N hours, CI green at the SHA, reviewer approved. Same pipeline as staging.
- `rollback.yml` reverts to the SSM-stored previous SHA
- **Build-once-promote-many**: production deploys reuse the SAME image SHA staging tested. No rebuild drift.

## Recommended companion tooling (NOT bundled — see DEFERRED.md + docs/integrations/)

Stripe (billing), Cal.com (scheduling), Google Analytics, Google Search Console, Intercom (support), Sentry (error monitoring), Docuseal (e-signature).

## When making changes

| If you're adding... | Then you must... |
|---|---|
| A new domain model | Add `organizationId` + RLS policy SQL migration; add to `SCOPED_MODELS`; add per-model RLS canary test |
| A new API endpoint | Define Zod schemas in `packages/shared/src/zod/`; use `defineEndpoint()`; register problem-types for errors; regenerate `@saas/api-client` |
| A new env var | Add to `apps/<app>/.env.example`; add to `packages/shared/src/env.ts` Zod schema; add to the relevant SSM Parameter Store path in launch.md |
| A new third-party integration | Decide: bundle (only if universal) or document (`docs/integrations/<tool>.md`); add to design spec §16 if companion tooling |
| A new Tofu module | Module directory with `main.tf`, `variables.tf`, `outputs.tf`, `README.md`; wire from `infra/tofu/main.tf`; document in `docs/operations/launch.md` |
| A new email | React Email component in `packages/shared/src/email-templates/`; transactional via `sendTransactional()`, marketing via `sendMarketing()` (consent-gated) |
| A new Slack notification | Helper in `apps/api/src/notifications/` using `packages/shared/src/slack.ts`; fire-and-forget; webhook URL via env var |

## When making changes, DO NOT

- Introduce a framework on top of Express (express-zod-api, NestJS, etc.)
- Add a Prisma-to-Zod codegen (prisma-zod-generator)
- Pre-check the marketing email consent checkbox
- Use `prismaAdmin` outside admin endpoints
- Add a NAT Gateway, RDS, or ElastiCache (we use Neon/Upstash; swap guides exist if user explicitly wants AWS-native)
- Ship live Stripe keys to staging (sandbox only)
- Use Secrets Manager when SSM works (cost reasons; see secrets.md)
- Use MJML for new email templates (callsaver does; this boilerplate doesn't — React Email is the default)

## File-level index for fast lookup

- Design spec: `docs/superpowers/specs/2026-05-17-saas-boilerplate-design.md`
- Phase 1 implementation plan: `docs/superpowers/plans/2026-05-17-saas-boilerplate-phase-1.md`
- Deferred items: `DEFERRED.md`
- Launch workflow: `docs/operations/launch.md`
- Swap guides index: `docs/swap-guides/README.md`
- Integration guides index: `docs/integrations/README.md`
```

- [ ] **Step 2: Commit**

```bash
git add AGENTS.md
git commit -m "feat(docs): add AGENTS.md — agent-readable architecture summary at repo root"
```

---

## Task 21: Final README polish + verification + push

**Files:**
- Modify: `~/saas-boilerplate-2026/README.md`

- [ ] **Step 1: Replace `README.md` with the polished version**

```markdown
# SaaS Boilerplate

> Opinionated 2026 SaaS starter monorepo. Express + Prisma 7 + Vite/React + Astro, deploy to AWS or anywhere.

**Status:** Phase 1 — documentation + folder structure + pinned dependencies. `pnpm install` resolves; runnable skeleton lands in Phase 2.

## What's in here

| Area | Where |
|---|---|
| Canonical design | [`docs/superpowers/specs/2026-05-17-saas-boilerplate-design.md`](./docs/superpowers/specs/2026-05-17-saas-boilerplate-design.md) |
| Agent-readable summary | [`AGENTS.md`](./AGENTS.md) |
| Phase 1 implementation plan | [`docs/superpowers/plans/2026-05-17-saas-boilerplate-phase-1.md`](./docs/superpowers/plans/2026-05-17-saas-boilerplate-phase-1.md) |
| What's intentionally deferred | [`DEFERRED.md`](./DEFERRED.md) |
| Staging-first launch workflow | [`docs/operations/launch.md`](./docs/operations/launch.md) |
| Operational runbooks | [`docs/operations/`](./docs/operations/) |
| Alternative-choice swap guides | [`docs/swap-guides/`](./docs/swap-guides/) |
| Companion-tool integration guides | [`docs/integrations/`](./docs/integrations/) |

## Stack at a glance

**Backend** — Express 5 + Prisma 7 + BetterAuth + Zod 4 + samchungy/zod-openapi + Scalar
**Workers** — BullMQ + Upstash Redis
**Frontend** — Vite 8 + React 19 + TanStack Router/Query + shadcn/ui + Magic UI + Tailwind v4 + hey-api/openapi-ts
**Marketing** — Astro 5 + React islands + Magic UI
**Database** — Neon (Postgres 16) with two-role RLS multi-tenancy
**Email** — Resend + React Email
**Logging / tracing** — Pino + OpenTelemetry (instrumentation-pino + pino-opentelemetry-transport)
**Testing** — Vitest + Supertest + Testcontainers + Playwright
**IaC** — OpenTofu (AWS: ECS Fargate, ALB, Route53, ACM, ECR, SSM Parameter Store, CloudWatch, SNS, Lambda, S3, CloudFront)
**CI/CD** — GitHub Actions with build-once-promote-many pattern

## Cost target

~$60/mo staging + ~$140/mo production AWS infrastructure (before Neon/Upstash/Resend usage-based bills). See spec §12.

## License

MIT — see [LICENSE](./LICENSE).

## Recommended for development

Use the [Superpowers Claude Code plugin](https://github.com/obra/superpowers) — its brainstorming/writing-plans/TDD/verification skills pair naturally with this boilerplate's structure. Install: `/plugin install superpowers@claude-plugins-official`.
```

- [ ] **Step 2: Sanity-check the tree**

```bash
cd ~/saas-boilerplate-2026
tree -L 3 -I 'node_modules|.git|dist|build' --dirsfirst
```

Expected: balanced structure across `apps/`, `packages/`, `infra/`, `docker/`, `docs/`, `.github/` plus the root-level files. No empty directories (all have at least a `README.md` or `.gitkeep`).

- [ ] **Step 3: Verify `pnpm install` resolves**

```bash
cd ~/saas-boilerplate-2026
pnpm install
```

Expected: completes without errors. Lockfile generated. No application code runs because there isn't any yet — that's expected for Phase 1.

- [ ] **Step 4: Verify Tofu syntax across all modules**

```bash
cd ~/saas-boilerplate-2026/infra/tofu
tofu fmt -recursive -check
tofu init -backend=false
tofu validate
```

Expected: `Success! The configuration is valid.`

- [ ] **Step 5: Verify Docker compose parses**

```bash
cd ~/saas-boilerplate-2026
docker compose -f docker/compose.yaml config > /dev/null
echo "Exit: $?"
```

Expected: `Exit: 0`.

- [ ] **Step 6: Verify GitHub workflow YAML parses**

```bash
cd ~/saas-boilerplate-2026
for f in .github/workflows/*.yml; do
  python3 -c "import yaml; yaml.safe_load(open('$f'))" && echo "OK: $f"
done
```

Expected: 7 `OK:` lines.

- [ ] **Step 7: Stage and commit the lockfile + README polish**

```bash
cd ~/saas-boilerplate-2026
git add README.md pnpm-lock.yaml
git commit -m "chore(repo): final README polish + commit pnpm-lock.yaml after install"
```

- [ ] **Step 8: Push to GitHub**

```bash
git push origin main
echo "Repo URL: https://github.com/ProsimianLabs/saas-boilerplate"
```

- [ ] **Step 9: Verify on GitHub**

```bash
gh repo view ProsimianLabs/saas-boilerplate --json url,defaultBranchRef,visibility
gh api repos/ProsimianLabs/saas-boilerplate/contents | jq -r '.[].name' | sort
```

Expected: visibility PUBLIC, default branch main, contents list includes `AGENTS.md`, `DEFERRED.md`, `LICENSE`, `README.md`, `apps`, `docker`, `docs`, `infra`, `packages`, `.github`.

- [ ] **Step 10: Tag the Phase 1 release**

```bash
git tag -a v0.1.0-phase-1 -m "Phase 1: documentation + folder structure + pinned dependencies"
git push origin v0.1.0-phase-1
gh release create v0.1.0-phase-1 --title "v0.1.0 — Phase 1" --notes "Documentation + folder structure + pinned dependencies. \`pnpm install\` resolves; runnable skeleton lands in Phase 2. See AGENTS.md and the design spec for architecture."
```

---

## Definition of done (Phase 1)

After Task 21:

- [x] Repo at https://github.com/ProsimianLabs/saas-boilerplate exists, public, MIT-licensed, default branch `main`.
- [x] `pnpm install` resolves without errors.
- [x] `tofu validate` succeeds across all modules.
- [x] `docker compose config` parses.
- [x] All 7 GitHub Actions workflows are valid YAML.
- [x] Every directory under `apps/`, `packages/`, `infra/`, `docs/` has a `README.md` explaining its purpose.
- [x] Every `package.json` has exact-pinned versions.
- [x] `AGENTS.md` at repo root provides an agent-readable architecture summary.
- [x] Design spec, DEFERRED.md, swap guides, integration guides, operational runbooks all committed.
- [x] Phase 1 tagged as `v0.1.0-phase-1`.

Phase 2 (working skeleton) becomes the next plan: replace stubs with running code, get `pnpm dev` to bring up Postgres + Redis + API + workers + web + marketing locally with a working signup/login flow and one CRUD example under RLS.

---

## Self-Review

**Spec coverage** — each spec section maps to at least one task:

| Spec § | Topic | Implementing tasks |
|---|---|---|
| §1, §2, §2.1 | Purpose / principles / deliverable phasing | Documented in spec + AGENTS.md (Task 20) |
| §3 | Repo layout | Tasks 4-11 collectively scaffold the layout |
| §4 | Backend (Express, Prisma, BetterAuth, define-endpoint, RFC 9457, multi-tenancy, marketing consent, React Email, file uploads) | Task 4 (apps/api scaffold incl. prisma schema with consent fields + ProcessedWebhookEvent), Task 8 (packages/shared subpath exports including email-templates, consent, db) |
| §5 | Workers | Task 5 (apps/workers scaffold) |
| §6 | Frontend | Task 6 (apps/web scaffold with TanStack + hey-api setup) |
| §7 | Marketing + cookie consent + legal pages + logo SVG | Task 7 (apps/marketing scaffold), Task 9 (packages/ui logo SVGs), Task 8 (consent module README) |
| §8 | Shared packages | Tasks 8, 9, 10 + Task 3 (config) |
| §9 | Local development | Task 14 (docker compose) |
| §10 | Testing strategy | Documented in apps/api & apps/workers READMEs + AGENTS.md; concrete code lands in Phase 2 |
| §11 | Observability + Alerts (Slack pipeline + Lambda forwarder + CloudWatch alarms + AWS Budgets) | Task 13 (alerts Tofu module + Lambda source), Task 14 (otel-collector in docker compose), Task 17 (observability runbook) |
| §12 | Deployment — AWS via OpenTofu | Tasks 11, 12, 13 |
| §13 | CI/CD with build-once-promote-many, gates, smoke + rollback | Tasks 15, 16 |
| §14 | Documentation | Tasks 17-21 |
| §15 | Out of scope (with Stripe note) | Documented in DEFERRED.md (pre-existing); integration guide in Task 19 |
| §16 | Recommended companion tooling | Task 19 (docs/integrations/) |
| §17 | Open questions | Documented in spec + DEFERRED.md |
| §18 | Pinned library versions | Tasks 4-11 — every `package.json` uses exact-pinned versions |

**Placeholder scan** — no `TBD` / `TODO` / `fill in details` patterns in this plan. The few "Phase 2 enables this" comments are intentional and explicit — they document deferred work, not unwritten plan steps.

**Type consistency check** — names used across tasks:
- Workspace package names: `@saas/api`, `@saas/workers`, `@saas/web`, `@saas/marketing`, `@saas/shared`, `@saas/config`, `@saas/ui`, `@saas/api-client` — consistent across all tasks
- Tofu module names: `network`, `acm`, `dns`, `registry`, `loadbalancer`, `api`, `workers`, `logs`, `secrets`, `web`, `marketing`, `alerts` — consistent across Tasks 11, 12, 13
- DB role names: `app_user`, `app_admin` — consistent between init.sql (Task 4), schema.prisma datasource (Task 4), runbooks (Task 17), AGENTS.md (Task 20)
- Env var names: `DATABASE_URL`, `DATABASE_URL_ADMIN`, `REDIS_URL`, `RESEND_API_KEY`, `BETTER_AUTH_SECRET` — same in apps/api/.env.example, apps/workers/.env.example, secrets.md, and AGENTS.md

Plan internally consistent; no missing references.







