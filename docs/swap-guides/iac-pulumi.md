# Swap: IaC — OpenTofu → Pulumi

## Why swap

You prefer a general-purpose language (TypeScript, Python, Go) over HCL and want Pulumi's automatic diff engine and secrets encryption built in. Tradeoff: Pulumi state backend requires either Pulumi Cloud or a self-managed S3 backend configuration.

## What changes

| Aspect | Default (OpenTofu) | After swap (Pulumi) |
|---|---|---|
| Language | HCL | TypeScript (or Python/Go) |
| State backend | S3 + DynamoDB | Pulumi Cloud or S3 backend |
| Plan/apply | `tofu plan` / `tofu apply` | `pulumi preview` / `pulumi up` |
| Secrets | SSM (separate) | Pulumi secrets (encrypted in state) |

## Steps (high level)

1. Run `pulumi new aws-typescript` in `infra/pulumi/`
2. Translate each Tofu module to a Pulumi component resource
3. Configure backend: `pulumi login s3://your-state-bucket` or Pulumi Cloud
4. Replace Tofu CI steps with `pulumi preview --diff` / `pulumi up --yes`
5. Delete `infra/tofu/` once Pulumi stacks are verified

## Files touched

- `infra/pulumi/` — new Pulumi project (replaces `infra/tofu/`)
- `.github/workflows/deploy.yml` — swap Tofu steps
- `package.json` — add `@pulumi/aws`, `@pulumi/pulumi`

## Env vars

- Add: `PULUMI_ACCESS_TOKEN` (if using Pulumi Cloud)
- No runtime env var changes

## Phase 1 status

This guide is a stub until Phase 2 adds the default code it's replacing. The structural choices documented here will hold; specific code diffs will be filled in later.
