# Swap: IaC — OpenTofu → AWS CDK

## Why swap

Your team writes TypeScript all day and wants IaC in the same language with full IDE support and AWS-native constructs. Tradeoff: CDK compiles to CloudFormation, which has slower deploys and harder state inspection than Tofu/Terraform.

## What changes

| Aspect | Default (OpenTofu) | After swap (AWS CDK) |
|---|---|---|
| Language | HCL | TypeScript |
| State backend | S3 + DynamoDB lock | CloudFormation stacks |
| Provider | OpenTofu AWS provider | `aws-cdk-lib` |
| Plan/apply | `tofu plan` / `tofu apply` | `cdk diff` / `cdk deploy` |

## Steps (high level)

1. Run `cdk init app --language typescript` in `infra/cdk/`
2. Translate each Tofu module (`vpc`, `ecs`, `rds-proxy`, etc.) to a CDK `Stack` or `Construct`
3. Replace `infra/tofu/` references in CI/CD workflows with `cdk deploy --all`
4. Migrate state: run Tofu destroy or use CDK import for existing resources
5. Delete `infra/tofu/` once CDK stacks are stable

## Files touched

- `infra/cdk/` — new CDK app (replaces `infra/tofu/`)
- `.github/workflows/deploy.yml` — swap Tofu steps for CDK steps
- `package.json` — add `aws-cdk` and `aws-cdk-lib` to root devDeps

## Env vars

- No changes to runtime env vars; CDK uses the same SSM parameters

## Phase 1 status

This guide is a stub until Phase 2 adds the default code it's replacing. The structural choices documented here will hold; specific code diffs will be filled in later.
