# Swap: AWS topology — public subnets → private subnets + NAT Gateway

## Why swap

Security posture or compliance requires your ECS tasks to have no public IP. A NAT Gateway allows outbound internet access (for Neon, Upstash, Resend, etc.) without exposing tasks directly. Tradeoff: NAT Gateway costs ~$32/month per AZ plus data-transfer charges.

## What changes

| Aspect | Default (public subnets) | After swap (private + NAT) |
|---|---|---|
| ECS task network | Public subnet, public IP | Private subnet, no public IP |
| Outbound internet | Direct | Via NAT Gateway |
| Inbound traffic | ALB in public subnet | ALB remains in public subnet |
| Cost | Lower | +~$32/month/AZ |

## Steps (high level)

1. Add private subnets and `aws_nat_gateway` resources to `infra/tofu/modules/vpc/main.tf`
2. Update ECS task definition to use private subnets; set `assign_public_ip = false`
3. Update security groups: tasks no longer need inbound rules for direct access
4. Test outbound connectivity (Neon, Upstash, Resend) from a private-subnet task
5. Update `infra/tofu/modules/vpc/outputs.tf` to export private subnet IDs

## Files touched

- `infra/tofu/modules/vpc/main.tf` — add private subnets, NAT Gateway, route tables
- `infra/tofu/modules/vpc/outputs.tf` — export private subnet IDs
- `infra/tofu/modules/ecs/main.tf` — update subnet references and `assign_public_ip`
- `infra/tofu/modules/ecs/security-groups.tf` — tighten inbound rules

## Env vars

- No changes to env vars

## Phase 1 status

This guide is a stub until Phase 2 adds the default code it's replacing. The structural choices documented here will hold; specific code diffs will be filled in later.
