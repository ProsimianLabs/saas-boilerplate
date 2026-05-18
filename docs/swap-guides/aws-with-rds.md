# Swap: AWS topology — Neon (serverless) → Amazon RDS for Postgres

## Why swap

You need Postgres to run entirely inside your AWS account for compliance, data-residency, or latency reasons, and you're comfortable paying for provisioned capacity. Tradeoff: RDS is significantly more expensive at low traffic and adds VPC/subnet complexity.

## What changes

| Aspect | Default (Neon) | After swap (RDS) |
|---|---|---|
| Postgres host | Neon serverless | `aws_db_instance` in private subnet |
| Connection pooling | Neon's built-in | RDS Proxy (`aws_db_proxy`) |
| Branching | Neon branches | Manual snapshots / blue-green |
| Cost model | Per-compute-second | Hourly instance + storage |

## Steps (high level)

1. Add `infra/tofu/modules/rds/main.tf` with `aws_db_instance` and `aws_db_proxy`
2. Place RDS in private subnets; update security groups to allow ECS task access
3. Update `DATABASE_URL` in SSM to point to the RDS Proxy endpoint
4. Run Drizzle migrations against the new instance
5. Remove `NEON_*` env vars; update `.env.example`

## Files touched

- `infra/tofu/modules/rds/main.tf` — new module
- `infra/tofu/main.tf` — add `module "rds"`
- `infra/tofu/modules/app/security-groups.tf` — add RDS ingress rule
- `.env.example` — swap connection vars

## Env vars

- Add: `DATABASE_URL` (RDS Proxy endpoint)
- Remove: `NEON_DATABASE_URL` (or rename)

## Phase 1 status

This guide is a stub until Phase 2 adds the default code it's replacing. The structural choices documented here will hold; specific code diffs will be filled in later.
