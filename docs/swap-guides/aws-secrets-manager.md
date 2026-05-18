# Swap: secrets — SSM Parameter Store → AWS Secrets Manager

## Why swap

You need automatic secret rotation, cross-account sharing, or fine-grained audit trails per secret. Secrets Manager supports first-class rotation lambdas and a richer policy model. Tradeoff: ~$0.40/secret/month vs. SSM Advanced Parameter at $0.05; small but real cost difference at scale.

## What changes

| Aspect | Default (SSM Parameter Store) | After swap (Secrets Manager) |
|---|---|---|
| Storage | `/myapp/production/SECRET_NAME` paths | Named secrets with versioning |
| SDK | `@aws-sdk/client-ssm` | `@aws-sdk/client-secrets-manager` |
| Rotation | Manual | Lambda-based automatic rotation |
| Cost | ~$0.05/param/month (Advanced) | ~$0.40/secret/month |

## Steps (high level)

1. Create secrets in Secrets Manager (console or Tofu `aws_secretsmanager_secret`)
2. Update IAM task role to allow `secretsmanager:GetSecretValue` instead of `ssm:GetParameter`
3. Replace the SSM fetch utility in `packages/shared/src/config.ts` with Secrets Manager client
4. Update ECS task definition to inject secrets via `secrets:` block pointing to ARNs
5. Remove old SSM parameters (after verifying the swap)

## Files touched

- `infra/tofu/modules/app/secrets.tf` — new Secrets Manager resources
- `infra/tofu/modules/app/iam.tf` — update task role policy
- `packages/shared/src/config.ts` — swap AWS SDK client
- `infra/tofu/modules/ecs/task-definition.tf` — update `secrets` block

## Env vars

- No new env vars; secrets are injected by ECS at task start

## Phase 1 status

This guide is a stub until Phase 2 adds the default code it's replacing. The structural choices documented here will hold; specific code diffs will be filled in later.
