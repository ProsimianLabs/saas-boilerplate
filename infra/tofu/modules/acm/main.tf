# Phase 1 scaffold. Resources stubbed as comments — populated in Phase 2.

# resource "aws_acm_certificate" "alb" {
#   domain_name               = "${var.env_prefix}${var.domain_name}"
#   subject_alternative_names = ["*.${var.env_prefix}${var.domain_name}"]
#   validation_method         = "DNS"
#   lifecycle { create_before_destroy = true }
# }
#
# resource "aws_acm_certificate" "cloudfront" {
#   provider                  = aws.us_east_1
#   domain_name               = "${var.env_prefix}${var.domain_name}"
#   subject_alternative_names = ["*.${var.env_prefix}${var.domain_name}"]
#   validation_method         = "DNS"
#   lifecycle { create_before_destroy = true }
# }
#
# resource "aws_route53_record" "validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.alb.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }
#   zone_id = var.route53_zone_id
#   name    = each.value.name
#   type    = each.value.type
#   records = [each.value.record]
#   ttl     = 60
# }
#
# resource "aws_acm_certificate_validation" "alb" {
#   certificate_arn         = aws_acm_certificate.alb.arn
#   validation_record_fqdns = [for r in aws_route53_record.validation : r.fqdn]
# }
#
# resource "aws_acm_certificate_validation" "cloudfront" {
#   provider                = aws.us_east_1
#   certificate_arn         = aws_acm_certificate.cloudfront.arn
#   validation_record_fqdns = [for r in aws_route53_record.validation : r.fqdn]
# }
