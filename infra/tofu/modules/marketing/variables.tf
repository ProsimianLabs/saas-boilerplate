variable "project_name" {
  type        = string
  description = "Resource name prefix."
}

variable "environment" {
  type        = string
  description = "\"staging\" or \"production\"."
}

variable "domain_name" {
  type        = string
  description = "Apex domain name (e.g. example.com)."
}

variable "env_prefix" {
  type        = string
  description = "Subdomain prefix for the environment (e.g. \"\" for production, \"staging.\" for staging)."
}

variable "certificate_arn" {
  type        = string
  description = "ACM certificate ARN in us-east-1 for CloudFront."
}
