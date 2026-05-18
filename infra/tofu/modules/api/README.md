# infra/tofu/modules/api

Provisions the ECS Fargate cluster (shared with workers), the API task definition and service, and the IAM roles (task role + execution role) with policies granting the task access to SSM Parameter Store secrets, ECR image pulls, and CloudWatch log delivery.

## Resources (Phase 2)

- aws_ecs_cluster (shared)
- aws_ecs_task_definition (api)
- aws_ecs_service (api)
- aws_iam_role (task + execution)
- aws_iam_role_policy_attachment

## Inputs

See `variables.tf`.

## Outputs

See `outputs.tf`.
