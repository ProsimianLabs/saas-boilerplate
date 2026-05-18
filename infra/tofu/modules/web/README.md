# infra/tofu/modules/web

Provisions an S3 static-hosting bucket plus a CloudFront distribution (with Origin Access Control) for the Next.js web application build.

## Resources (Phase 2)

- aws_s3_bucket
- aws_s3_bucket_public_access_block
- aws_s3_bucket_website_configuration
- aws_cloudfront_distribution
- aws_cloudfront_origin_access_control
- aws_s3_bucket_policy (CloudFront OAC)

## Inputs

See `variables.tf`.

## Outputs

See `outputs.tf`.
