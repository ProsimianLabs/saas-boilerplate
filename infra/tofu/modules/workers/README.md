# infra/tofu/modules/workers

Provisions the ECS Fargate task definition and service for background workers. Workers run without an ALB attachment — they pull jobs from queues and process them asynchronously. Shares the ECS cluster created by the api module.

## Resources (Phase 2)

- aws_ecs_task_definition (workers)
- aws_ecs_service (workers, no LB attachment)

## Inputs

See `variables.tf`.

## Outputs

See `outputs.tf`.
