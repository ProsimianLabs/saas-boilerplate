# Phase 1 scaffold. Resources stubbed as comments — populated in Phase 2.

# data "aws_route53_zone" "main" {
#   name         = var.domain_name
#   private_zone = false
# }
#
# resource "aws_route53_record" "api" {
#   zone_id = data.aws_route53_zone.main.zone_id
#   name    = "api.${var.env_prefix}${var.domain_name}"
#   type    = "A"
#   alias {
#     name                   = var.alb_dns_name
#     zone_id                = var.api_alb_zone_id
#     evaluate_target_health = true
#   }
# }
#
# resource "aws_route53_record" "web" {
#   zone_id = data.aws_route53_zone.main.zone_id
#   name    = "app.${var.env_prefix}${var.domain_name}"
#   type    = "A"
#   alias {
#     name                   = var.web_cloudfront_domain_name
#     zone_id                = "Z2FDTNDATAQYW2"
#     evaluate_target_health = false
#   }
# }
#
# resource "aws_route53_record" "marketing" {
#   zone_id = data.aws_route53_zone.main.zone_id
#   name    = "${var.env_prefix}${var.domain_name}"
#   type    = "A"
#   alias {
#     name                   = var.marketing_cloudfront_domain_name
#     zone_id                = "Z2FDTNDATAQYW2"
#     evaluate_target_health = false
#   }
# }
