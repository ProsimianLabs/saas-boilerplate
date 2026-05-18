# Swap guides

For each opinionated default in the boilerplate, here's how to swap it for an alternative without abandoning the rest of the stack. Each guide is opinionated about the *what* and *how*; you decide *whether*.

| Slot | Default | Guides |
|---|---|---|
| Marketing framework | Astro | [Next.js](./marketing-nextjs.md), [Vite SPA](./marketing-vite.md) |
| Redis hosting | Upstash | [ElastiCache](./redis-elasticache.md), [self-hosted](./redis-self-hosted.md) |
| Auth provider | BetterAuth | [Neon Auth wrapper](./auth-neon-auth.md), [Clerk](./auth-clerk.md) |
| IaC | OpenTofu | [AWS CDK](./iac-cdk.md), [Pulumi](./iac-pulumi.md), [ECS Express Mode CLI (no IaC)](./aws-ecs-express-mode.md) |
| AWS topology | Public subnets, no NAT | [+ NAT Gateway / private subnets](./aws-with-nat-gateway.md), [+ RDS instead of Neon](./aws-with-rds.md) |
| Secrets | SSM Parameter Store | [AWS Secrets Manager](./aws-secrets-manager.md) |
| Database | Neon | [Supabase](./db-supabase.md), [Railway Postgres](./db-railway.md) |
| Email templates | React Email | [MJML](./email-mjml.md) |
| Email sending | Resend | [SendGrid](./email-sendgrid.md), [Postmark](./email-postmark.md) |
| Hosting (instead of AWS) | — | [Fly.io](./host-fly.md), [Render](./host-render.md), [Railway](./host-railway.md), [Cloud Run](./host-cloud-run.md) |
| Multi-tenancy enforcement | Postgres RLS | [App-layer wrapper](./multi-tenancy-app-layer.md) |
| Routing | TanStack Router | [React Router 7](./router-react-router.md) |
