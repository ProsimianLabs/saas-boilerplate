# Swap: hosting — AWS ECS → Render

## Why swap

Render offers a Heroku-like experience with zero-ops Docker deployments and automatic TLS. Good fit for teams that want a simple dashboard and auto-deploy from Git without managing AWS infrastructure. Tradeoff: less control over networking/IAM; Render's free tier sleeps services.

## What changes

| Aspect | Default (AWS ECS) | After swap (Render) |
|---|---|---|
| Compute | ECS Fargate | Render Web Service / Background Worker |
| Deploy | ECR + ECS deploy | `render.yaml` + Git push |
| Secrets | SSM Parameter Store | Render environment variables |
| Networking | ALB + VPC | Render's managed proxy |

## Steps (high level)

1. Create a `render.yaml` at the repo root defining services for `api` and `workers`
2. Connect the Render dashboard to your GitHub repo; set environment variables manually or via `render.yaml` `envVarGroups`
3. Add `preDeployCommand` for running migrations
4. Replace ECS deploy steps in CI/CD with a Render deploy hook URL (optional; Render auto-deploys on push)
5. Remove ECS/ECR/ALB Tofu modules; keep S3/CloudFront for marketing

## Files touched

- `render.yaml` — new Render Blueprint file
- `.github/workflows/deploy.yml` — simplify or remove ECS steps
- `infra/tofu/main.tf` — remove ECS/ALB/ECR modules

## Env vars

- Same variable names; configured in Render dashboard or `render.yaml`

## Phase 1 status

This guide is a stub until Phase 2 adds the default code it's replacing. The structural choices documented here will hold; specific code diffs will be filled in later.
