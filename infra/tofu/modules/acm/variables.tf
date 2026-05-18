variable "domain_name" {
  type        = string
  description = "Root domain name (e.g. example.com)."
}

variable "env_prefix" {
  type        = string
  description = "Environment subdomain prefix (e.g. \"\" for production, \"staging.\" for staging)."
}

variable "route53_zone_id" {
  type        = string
  description = "Route 53 hosted zone ID used to create DNS validation records."
}
