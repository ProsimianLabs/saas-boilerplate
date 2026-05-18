# infra/tofu/modules/network

Provisions the foundational VPC networking layer: a VPC with two public subnets spread across availability zones, an internet gateway with route table associations, and three security groups (ALB, API tasks, and Workers) that enforce least-privilege traffic rules between the load balancer and the compute tier.

## Resources (Phase 2)

- aws_vpc
- aws_subnet (public ×2 AZs)
- aws_internet_gateway
- aws_route_table + association
- aws_security_group (alb, api, workers)

## Inputs

See `variables.tf`.

## Outputs

See `outputs.tf`.
