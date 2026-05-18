# Secrets management

All secrets live in **AWS SSM Parameter Store** as `SecureString` (KMS-encrypted with `alias/aws/ssm`). Free at our scale (≤10K params). See design spec §12 for the Secrets Manager comparison and why we picked SSM.

## Naming convention

```
/<project>/<environment>/<category>/<name>
```

Examples:
- `/saas/staging/db/url`
- `/saas/production/stripe/secret-key`
- `/saas/production/slack/alerts-webhook`

## Adding a new secret

1. Add the env var to the relevant app's `.env.example` (commented if it has a sane local-dev default, uncommented if production-required).
2. Put the value in SSM:
   ```
   aws ssm put-parameter --name /saas/<env>/<cat>/<name> --type SecureString --value '<value>'
   ```
3. Add the parameter ARN to the `secrets` Tofu module's input list so the task role gets read permission.
4. In Phase 2, reference the secret in the ECS task definition's `secrets` block:
   ```hcl
   secrets = [{ name = "STRIPE_SECRET_KEY", valueFrom = "arn:aws:ssm:..." }]
   ```

## Rotating a secret

For static third-party API keys (no built-in rotation):

1. Generate new value in the provider's console (e.g., Stripe dashboard → API keys → roll).
2. `aws ssm put-parameter --name ... --value '<new>' --overwrite`
3. Force a new ECS deployment to pick up: `aws ecs update-service --cluster ... --service ... --force-new-deployment`
4. Once new tasks are healthy, revoke the old key in the provider's console.

## DB credential rotation (Neon)

Neon supports password reset on app roles. After rotation:
1. Update SSM `DATABASE_URL` parameter.
2. Force ECS redeploy.
3. Optionally drop the old role's connections via Neon dashboard.

## Why not Secrets Manager?

See design spec §12. Tl;dr: Secrets Manager costs $0.40/secret/month with no functional benefit for our use case (no RDS rotation, no cross-region replication needs, no random password generation needs). Swap guide for users who specifically want it: `docs/swap-guides/aws-secrets-manager.md`.
