# Phase 1 scaffold. Resources stubbed as comments — populated in Phase 2.

# resource "aws_s3_bucket" "marketing" {
#   bucket = "${var.project_name}-${var.environment}-marketing"
#   tags   = { Project = var.project_name, Environment = var.environment }
# }
#
# resource "aws_s3_bucket_public_access_block" "marketing" {
#   bucket                  = aws_s3_bucket.marketing.id
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }
#
# resource "aws_s3_bucket_website_configuration" "marketing" {
#   bucket = aws_s3_bucket.marketing.id
#   index_document { suffix = "index.html" }
#   error_document { key    = "404.html" }
# }
#
# resource "aws_cloudfront_origin_access_control" "marketing" {
#   name                              = "${var.project_name}-${var.environment}-marketing-oac"
#   origin_access_control_origin_type = "s3"
#   signing_behavior                  = "always"
#   signing_protocol                  = "sigv4"
# }
#
# resource "aws_cloudfront_distribution" "marketing" {
#   enabled             = true
#   default_root_object = "index.html"
#   aliases             = ["${var.env_prefix}${var.domain_name}"]
#
#   origin {
#     domain_name              = aws_s3_bucket.marketing.bucket_regional_domain_name
#     origin_id                = "s3-marketing"
#     origin_access_control_id = aws_cloudfront_origin_access_control.marketing.id
#   }
#
#   default_cache_behavior {
#     allowed_methods        = ["GET", "HEAD"]
#     cached_methods         = ["GET", "HEAD"]
#     target_origin_id       = "s3-marketing"
#     viewer_protocol_policy = "redirect-to-https"
#     forwarded_values { query_string = false; cookies { forward = "none" } }
#   }
#
#   viewer_certificate {
#     acm_certificate_arn      = var.certificate_arn
#     ssl_support_method       = "sni-only"
#     minimum_protocol_version = "TLSv1.2_2021"
#   }
#
#   restrictions { geo_restriction { restriction_type = "none" } }
#   tags = { Project = var.project_name, Environment = var.environment }
# }
#
# resource "aws_s3_bucket_policy" "marketing" {
#   bucket = aws_s3_bucket.marketing.id
#   policy = jsonencode({
#     Version   = "2012-10-17"
#     Statement = [{
#       Effect    = "Allow"
#       Principal = { Service = "cloudfront.amazonaws.com" }
#       Action    = "s3:GetObject"
#       Resource  = "${aws_s3_bucket.marketing.arn}/*"
#       Condition = { StringEquals = { "AWS:SourceArn" = aws_cloudfront_distribution.marketing.arn } }
#     }]
#   })
# }
