# docker

Local development stack.

## Start

```
docker compose -f docker/compose.yaml up -d
```

## Services

| Service | Port | Purpose |
|---|---|---|
| postgres | 5432 | DB for apps/api + apps/workers + integration tests |
| redis | 6379 | BullMQ queue backend + general cache |
| otel-collector | 4317 (gRPC), 4318 (HTTP) | Receives traces/logs/metrics; forwards to stdout in dev |
| mailhog | 1025 (SMTP), 8025 (UI) | Email capture in dev — web UI at http://localhost:8025 |

## Initial setup

After first `up -d`, run the bundled RLS role bootstrap:

```
psql 'postgresql://postgres:postgres@localhost:5432/saas' -f apps/api/prisma/init.sql
```

Then Prisma migrations:

```
DATABASE_URL_ADMIN='postgresql://app_admin:CHANGE_ME@localhost:5432/saas?schema=public' pnpm --filter @saas/api prisma:deploy
```

## Stop

```
docker compose -f docker/compose.yaml down
```

Add `-v` to wipe the postgres volume too.
