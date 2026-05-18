# infra/tofu/modules/registry

Provisions AWS ECR repositories for the API and Workers container images, along with lifecycle policies that automatically expire old image tags to control storage costs.

## Resources (Phase 2)

- aws_ecr_repository (api, workers)
- aws_ecr_lifecycle_policy

## Inputs

See `variables.tf`.

## Outputs

See `outputs.tf`.
