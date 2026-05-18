variable "domain_name" {
  type        = string
  description = "Root domain name (e.g. example.com)."
}

variable "env_prefix" {
  type        = string
  description = "Environment subdomain prefix (e.g. \"\" for production, \"staging.\" for staging)."
}

variable "alb_dns_name" {
  type        = string
  description = "DNS name of the Application Load Balancer."
}

variable "api_alb_zone_id" {
  type        = string
  description = "Hosted zone ID of the ALB (for Route 53 alias records)."
}

variable "web_cloudfront_domain_name" {
  type        = string
  description = "CloudFront distribution domain for the web app."
}

variable "marketing_cloudfront_domain_name" {
  type        = string
  description = "CloudFront distribution domain for the marketing site."
}
