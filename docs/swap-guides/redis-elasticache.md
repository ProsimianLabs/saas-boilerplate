# Swap: Redis hosting — Upstash → AWS ElastiCache

## Why swap

You need low-latency Redis inside your VPC (sub-millisecond p99 vs. Upstash's regional HTTP-over-TLS model) or want consolidated AWS billing. Tradeoff: ElastiCache is a provisioned resource — it costs money even when idle and adds IaC complexity.

## What changes

| Aspect | Default (Upstash) | After swap (ElastiCache) |
|---|---|---|
| Connection model | HTTP REST (Upstash SDK) | TCP (`ioredis` / `redis`) |
| Auth | `UPSTASH_REDIS_REST_TOKEN` | IAM auth or auth token |
| Network | Public endpoint | VPC-private |
| Cost model | Per-request | Hourly instance |

## Steps (high level)

1. Add an `aws_elasticache_replication_group` (or serverless) resource to `infra/tofu/modules/app/`
2. Place ElastiCache in the private subnet; add a security group rule from the ECS task SG
3. Replace `@upstash/redis` with `ioredis` in `packages/shared/` and `apps/api/`
4. Update all Redis usage to use async `ioredis` client (connection string from SSM)
5. Remove `UPSTASH_REDIS_REST_URL` / `UPSTASH_REDIS_REST_TOKEN` from env; add `REDIS_URL`

## Files touched

- `infra/tofu/modules/app/elasticache.tf` — new resource
- `infra/tofu/modules/app/security-groups.tf` — add ingress rule
- `packages/shared/src/redis.ts` — swap client
- `apps/api/src/**` — update any direct Redis calls

## Env vars

- Add: `REDIS_URL`
- Remove: `UPSTASH_REDIS_REST_URL`, `UPSTASH_REDIS_REST_TOKEN`

## Phase 1 status

This guide is a stub until Phase 2 adds the default code it's replacing. The structural choices documented here will hold; specific code diffs will be filled in later.
