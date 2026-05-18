# Swap: Redis hosting — Upstash → self-hosted Redis (Docker / EC2)

## Why swap

You want full control, zero per-request cost, and are comfortable managing Redis uptime yourself. Suitable for single-region setups or cost-sensitive early-stage products. Tradeoff: you own availability, backups, and upgrades.

## What changes

| Aspect | Default (Upstash) | After swap (self-hosted) |
|---|---|---|
| Connection model | HTTP REST | TCP (`ioredis`) |
| Auth | Upstash token | Redis `requirepass` or ACL |
| Deploy | Managed SaaS | ECS sidecar or dedicated EC2 |
| Persistence | Managed | You configure RDB/AOF |

## Steps (high level)

1. Add a Redis container as an ECS sidecar or a standalone EC2 instance in the Tofu modules
2. Replace `@upstash/redis` with `ioredis` in shared packages
3. Store Redis password in SSM; inject as `REDIS_URL` env var
4. (Optional) Mount EFS or EBS for AOF persistence
5. Remove Upstash env vars from SSM and `.env.example`

## Files touched

- `infra/tofu/modules/app/redis.tf` — new ECS task definition or EC2 instance
- `packages/shared/src/redis.ts` — swap client
- `.env.example` — update Redis vars
- `apps/api/src/**` — update any direct Redis calls

## Env vars

- Add: `REDIS_URL`
- Remove: `UPSTASH_REDIS_REST_URL`, `UPSTASH_REDIS_REST_TOKEN`

## Phase 1 status

This guide is a stub until Phase 2 adds the default code it's replacing. The structural choices documented here will hold; specific code diffs will be filled in later.
