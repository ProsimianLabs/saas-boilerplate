# infra/tofu/modules/acm

Provisions TLS certificates via AWS Certificate Manager: a regional certificate for the ALB (in the deployment region) and a separate certificate in us-east-1 for CloudFront distributions. Both certificates are validated via DNS using Route 53 records that this module creates automatically.

## Resources (Phase 2)

- aws_acm_certificate (×2: regional ALB cert + us-east-1 CloudFront cert)
- aws_acm_certificate_validation
- aws_route53_record (validation)

## Inputs

See `variables.tf`.

## Outputs

See `outputs.tf`.
