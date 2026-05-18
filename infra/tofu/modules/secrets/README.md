# infra/tofu/modules/secrets

Provisions AWS SSM Parameter Store SecureString entries for every application secret listed in `.env.example`. Parameters are KMS-encrypted and consumed by ECS task roles at runtime.

## Resources (Phase 2)

- aws_ssm_parameter (SecureString, one per required secret listed in `.env.example`)

## Inputs

See `variables.tf`.

## Outputs

See `outputs.tf`.
