# apps/workers

BullMQ worker processes. Runs as a separate Node process from `apps/api/` so queue work doesn't compete with request handling.

## Conventions

- One queue per logical job type. Job processors are plain async functions; bootstrap code wires them to BullMQ `Worker` instances.
- Every job payload includes `organizationId` (validated against the Zod schema in `@saas/shared/zod`). The worker sets the RLS ALS context to that org before invoking the processor — `scopedPrisma` then auto-injects `SET LOCAL app.current_org`.
- Shutdown: SIGTERM → drain in-flight jobs → close Redis + Prisma → exit.

## Layout (Phase 2)

```
src/
  index.ts           Bootstrap (registers all workers, starts queue runtime)
  queues/            One file per queue (queue name + job type definition)
  processors/        One file per queue (handler logic)
  bootstrap/         OTel/Pino/shutdown wiring shared with apps/api
```

## Env vars

See `.env.example`. Same shape as `apps/api/.env.example` minus HTTP-specific vars.
