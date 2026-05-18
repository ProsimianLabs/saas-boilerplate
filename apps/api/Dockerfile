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
