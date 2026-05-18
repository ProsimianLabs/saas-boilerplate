# Launch workflow — staging-first to production

This is the canonical adoption arc for a new SaaS built on this boilerplate.

## Prerequisites

- AWS account (or org) with admin IAM access
- Domain registered (any registrar)
- GitHub repo (fork of this boilerplate)
- Slack workspace with admin access to create incoming webhooks
- Local: Docker, pnpm 10+, Node 22, OpenTofu 1.8+

## Step 1: Verify locally

```
git clone https://github.com/<your-org>/saas-boilerplate.git
cd saas-boilerplate
pnpm install
docker compose -f docker/compose.yaml up -d
psql 'postgresql://postgres:postgres@localhost:5432/saas' -f apps/api/prisma/init.sql
```

Phase 2+ adds `pnpm dev`; for Phase 1, just verify the install resolves and Docker comes up cleanly.

## Step 2: Domain + Route53

- Buy or transfer domain to Route53 (or any registrar with NS delegation).
- Create a Route53 hosted zone for the apex domain.
- Update the registrar's nameservers to point to Route53.

## Step 3: Managed services

Region matching matters — every API request makes at least one DB round-trip; cross-region adds 60–100ms per query.

| Service | Action | Region |
|---|---|---|
| **Neon** | Create project (free tier OK for staging). Match the region to `var.aws_region`. | Same as AWS deploy region |
| | Run `psql <neon-conn-string> -f apps/api/prisma/init.sql` to create `app_user` + `app_admin` roles | |
| | Capture two connection strings: one for `app_user` (DATABASE_URL), one for `app_admin` (DATABASE_URL_ADMIN) | |
| **Upstash** | Create Redis database (free tier OK). Match region. | Same |
| | Capture `REDIS_URL` | |
| **Resend** | Sign up; verify your sending domain | n/a |
| | Generate API key; capture `RESEND_API_KEY` | |
| **Slack** | Create three incoming webhooks for #deploys, #alerts, #app-events | n/a |
| | Capture three webhook URLs | |

## Step 4: Configure staging tfvars + secrets

```
cd infra/tofu
cp staging.tfvars.example staging.tfvars
# Edit staging.tfvars — set domain, region, account_id, env_prefix="staging."
```

For each secret, put it in SSM Parameter Store **before** running tofu apply:

```
aws ssm put-parameter --name /saas/staging/db/url        --type SecureString --value '<DATABASE_URL value>'
aws ssm put-parameter --name /saas/staging/db/admin-url  --type SecureString --value '<DATABASE_URL_ADMIN value>'
aws ssm put-parameter --name /saas/staging/redis/url     --type SecureString --value '<REDIS_URL value>'
aws ssm put-parameter --name /saas/staging/resend/key    --type SecureString --value '<RESEND_API_KEY value>'
aws ssm put-parameter --name /saas/staging/auth/secret   --type SecureString --value "$(openssl rand -base64 32)"
aws ssm put-parameter --name /saas/staging/slack/deploys-webhook   --type SecureString --value '<webhook>'
aws ssm put-parameter --name /saas/staging/slack/alerts-webhook    --type SecureString --value '<webhook>'
aws ssm put-parameter --name /saas/staging/slack/app-events-webhook --type SecureString --value '<webhook>'
```

**Credential discipline**: staging uses test/sandbox keys for every third-party service that has them (Stripe sandbox, Resend dev mode, OAuth dev apps). Live keys belong only in `production.tfvars` SSM.

## Step 5: Deploy staging

```
tofu init
tofu workspace new staging || tofu workspace select staging
tofu apply -var-file=staging.tfvars
```

First apply takes ~10 minutes (CloudFront distribution provisioning is the slowest step).

## Step 6: Validate staging

- Hit `https://staging.api.<your-domain>/healthz` → should return 200
- Hit `https://staging.app.<your-domain>` → should serve the SPA (placeholder in Phase 1)
- Open Slack #alerts channel → should receive AWS Budget creation confirmation

## Step 7: Soak

Run staging for at least a few hours (longer for first-time launches). Do E2E tests, manual flows, smoke checks. Catch problems here, not in production.

## Step 8: Provision production

Repeat Step 3 (managed services) for production — separate Neon project, separate Upstash instance, separate Slack webhooks if you want noise isolation. Repeat Step 4 with `/saas/production/` SSM paths. Live Stripe keys go here, not in staging.

## Step 9: Deploy production

```
cp production.tfvars.example production.tfvars
# Edit — env_prefix="", task counts higher, monthly_budget_usd higher
tofu workspace new production || tofu workspace select production
tofu apply -var-file=production.tfvars
```

The apex domain comes up at the same time as `app.<domain>` and `api.<domain>`. Marketing site is now live.

## Step 10: GitHub Actions wiring

- In repo Settings → Secrets and variables → Actions:
  - Add `AWS_STAGING_ROLE_ARN` and `AWS_PRODUCTION_ROLE_ARN` (OIDC-trusted roles created in Step 5/9)
  - Add `RENOVATE_TOKEN` (GitHub PAT with `repo` scope) — or skip and use the hosted Renovate App
- In repo Settings → Environments:
  - For `production`, add yourself as a required reviewer (the production-deploy gate)

After this, push-to-main triggers auto staging deploy; production deploys require manual workflow_dispatch + reviewer approval.
