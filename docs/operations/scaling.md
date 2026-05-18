# Scaling guidance

The boilerplate ships sized for **early-stage SaaS**: 1 Fargate task per service in staging, 2 in production. Here's how to grow.

## When to bump task count

Watch the `api_p99_latency` and `api_5xx_rate` CloudWatch alarms. If p99 sustained > 1s under normal load, add a task:

```
# Edit production.tfvars
api_task_count = 4
tofu apply -var-file=production.tfvars
```

ECS rolls the new task in with the existing ones (rolling deployment). Zero downtime.

## When to scale task size

Default Fargate task: 0.5 vCPU, 1 GB RAM. Bump to 1 vCPU / 2 GB if individual requests are CPU-bound (e.g., heavy data processing per endpoint). Beyond that, prefer more tasks over bigger tasks — concurrency at the load balancer beats single-task verticality.

## Database

Neon scales independently. If you hit connection limits:
- Use Neon's pgBouncer endpoint for app code (transaction pooling)
- Use the direct endpoint for migrations (session pooling, needed for `SET LOCAL`)

For very high read load, add a Neon read replica and route read-only queries to it via a separate Prisma client.

## Redis

Upstash REST endpoint scales to thousands of req/sec on the free tier; their paid tiers go far higher. If BullMQ throughput becomes a bottleneck:
- Increase worker concurrency per queue (`Worker({ concurrency: 10 })`)
- Split queues across multiple worker tasks (run multiple `workers` ECS services with different queue subsets)
- Move to dedicated Redis (Upstash Pro tier, or ElastiCache via `docs/swap-guides/redis-elasticache.md`)

## CloudFront

Marketing + web SPA are CDN-served — they scale infinitely without intervention. If you have a global user base, CloudFront edge locations handle latency for free.

## What to NOT scale prematurely

- Don't add NAT Gateway unless you need private subnets for compliance (see design spec §12).
- Don't move to Multi-AZ RDS — Neon handles HA already.
- Don't move to ElastiCache — Upstash handles HA already.
- Don't add Aurora — Neon's pricing wins until you're at very high scale.
