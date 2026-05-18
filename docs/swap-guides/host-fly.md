# Swap: hosting — AWS ECS → Fly.io

## Why swap

You want global anycast edge deployment, zero-config WireGuard networking between machines, and a simpler deployment model than ECS. Fly.io is a strong fit for low-to-medium traffic products that want geographic distribution without managing AWS regions. Tradeoff: no IaC parity; state lives in Fly's platform, not your S3 backend.

## What changes

| Aspect | Default (AWS ECS) | After swap (Fly.io) |
|---|---|---|
| Compute | ECS Fargate tasks | Fly Machines |
| Networking | ALB + VPC | Fly proxy (anycast) |
| Deploy | `tofu apply` + ECR | `fly deploy` |
| Secrets | SSM Parameter Store | `fly secrets set` |

## Steps (high level)

1. Install `flyctl`; run `fly launch` in `apps/api/` and `apps/workers/`
2. Commit the generated `fly.toml` files; set `internal_port` to match your app
3. Set secrets: `fly secrets set KEY=value --app your-app`
4. Add `fly deploy --app your-api` steps to CI/CD, replacing ECS deploy steps
5. Keep `infra/tofu/` for Neon, Upstash, S3, and CloudFront (those still live in AWS)

## Files touched

- `apps/api/fly.toml` — new Fly config
- `apps/workers/fly.toml` — new Fly config
- `.github/workflows/deploy.yml` — replace ECS deploy with `fly deploy`
- `infra/tofu/main.tf` — remove ECS/ALB/ECR modules; keep shared-infra modules

## Env vars

- Secrets managed via `fly secrets` instead of SSM; same variable names

## Phase 1 status

This guide is a stub until Phase 2 adds the default code it's replacing. The structural choices documented here will hold; specific code diffs will be filled in later.
