# Swap: hosting — AWS ECS → Google Cloud Run

## Why swap

Your organisation is GCP-first, or you want per-request billing with scale-to-zero and Google's global network. Cloud Run is the closest GCP equivalent to ECS Fargate. Tradeoff: you'll need to migrate secrets to GCP Secret Manager, and IaC modules need rewriting for GCP resources.

## What changes

| Aspect | Default (AWS ECS) | After swap (Cloud Run) |
|---|---|---|
| Compute | ECS Fargate | Cloud Run services |
| Registry | ECR | Artifact Registry |
| Secrets | SSM Parameter Store | GCP Secret Manager |
| IaC | OpenTofu AWS provider | OpenTofu Google provider |
| Networking | ALB + VPC | Cloud Run ingress + VPC connector (optional) |

## Steps (high level)

1. Enable Cloud Run and Artifact Registry APIs in your GCP project
2. Rewrite `infra/tofu/modules/ecs/` → `infra/tofu/modules/cloud-run/` using `google_cloud_run_v2_service`
3. Push images to Artifact Registry; update CI/CD `docker push` target
4. Migrate secrets from SSM to GCP Secret Manager; update IAM bindings for the Cloud Run service account
5. Update DNS / load balancer to point at the Cloud Run service URL

## Files touched

- `infra/tofu/modules/cloud-run/` — new module (replaces `infra/tofu/modules/ecs/`)
- `infra/tofu/main.tf` — swap module references and provider
- `.github/workflows/deploy.yml` — update image push target and deploy command
- `packages/shared/src/config.ts` — swap SSM client for GCP Secret Manager client

## Env vars

- Secrets injected via Cloud Run `--set-secrets` or Secret Manager mounts; same names

## Phase 1 status

This guide is a stub until Phase 2 adds the default code it's replacing. The structural choices documented here will hold; specific code diffs will be filled in later.
