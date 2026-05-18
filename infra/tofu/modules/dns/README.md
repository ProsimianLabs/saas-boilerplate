# infra/tofu/modules/dns

Manages Route 53 DNS records for all application endpoints. Looks up the existing hosted zone (assumed pre-created by the operator) and creates A/ALIAS records pointing the API subdomain to the ALB, and the web and marketing subdomains to their respective CloudFront distributions.

## Resources (Phase 2)

- aws_route53_zone (data source — assumes user created it)
- aws_route53_record (api, web, marketing, apex)

## Inputs

See `variables.tf`.

## Outputs

See `outputs.tf`.
