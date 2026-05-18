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
