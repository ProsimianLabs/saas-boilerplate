# Swap: hosting — AWS ECS → Railway

## Why swap

Railway combines compute, Postgres, and Redis on one platform with a single monthly bill and a fast deploy loop. Ideal for solo founders or small teams who want to minimise ops surface. Tradeoff: less granular IAM/networking control; vendor lock-in for the database tier if you adopt Railway Postgres.

## What changes

| Aspect | Default (AWS ECS) | After swap (Railway) |
|---|---|---|
| Compute | ECS Fargate | Railway Service (Docker) |
| Database | Neon (external) | Railway Postgres plugin (optional) |
| Secrets | SSM Parameter Store | Railway environment variables |
| Deploy | `tofu apply` + ECR | `railway up` or Git push |

## Steps (high level)

1. Install Railway CLI; run `railway init` in the repo root
2. Create services for `api` and `workers` pointing to their Dockerfiles
3. Set environment variables in the Railway dashboard
4. (Optional) Add Postgres and Redis plugins to the Railway project
5. Replace ECS deploy steps in CI/CD with `railway up --service api`

## Files touched

- `railway.toml` — optional Railway config file per service
- `.github/workflows/deploy.yml` — replace ECS steps with `railway up`
- `infra/tofu/main.tf` — remove ECS/ALB/ECR modules

## Env vars

- Same variable names; configured in Railway dashboard or via `railway variables set`

## Phase 1 status

This guide is a stub until Phase 2 adds the default code it's replacing. The structural choices documented here will hold; specific code diffs will be filled in later.
