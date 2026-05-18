# infra/tofu

OpenTofu modules for deploying the boilerplate to AWS.

## Topology

- **Per-environment workspaces**: `staging` and `production`. Same modules, different `.tfvars`.
- **Single-region default**: `var.aws_region` (defaults `us-east-1`). One hardcoded exception — CloudFront cert MUST be in `us-east-1` and uses provider alias `aws.us_east_1`.
- **Public subnets, no NAT**: ECS in public subnets, tight security groups (ALB SG only). See design spec §12 for the rationale and trade-off.

## Modules

| Module | Resources |
|---|---|
| `network` | VPC, public subnets, IGW, security groups |
| `acm` | Certs: one in deploy region (ALB), one in us-east-1 (CloudFront) |
| `dns` | Route53 records constructed from `var.domain_name` + `var.env_prefix` |
| `registry` | ECR repos for api and workers |
| `secrets` | SSM Parameter Store SecureString parameters |
| `loadbalancer` | ALB + target group + listeners |
| `api` | ECS Fargate service for `apps/api/` |
| `workers` | ECS Fargate service for `apps/workers/` (no ALB; pull-based) |
| `web` | S3 + CloudFront for `apps/web/` static SPA build |
| `marketing` | S3 + CloudFront for `apps/marketing/` static Astro build |
| `logs` | CloudWatch log groups + metric filters |
| `alerts` | SNS topic + Lambda Slack forwarder + CloudWatch alarms + AWS Budgets |

## Deploy

```
cd infra/tofu
cp staging.tfvars.example staging.tfvars   # fill in
tofu init
tofu workspace new staging || tofu workspace select staging
tofu apply -var-file=staging.tfvars
```

See `docs/operations/launch.md` for the full staging-first → production workflow.

## Phase 1 status

Module directories ship with `main.tf` / `variables.tf` / `outputs.tf` skeletons declaring intended resources via comments. `tofu init && tofu validate` should pass; `tofu plan` will plan zero resource changes (or will error on missing variables). Phase 2 fills in resource bodies.
