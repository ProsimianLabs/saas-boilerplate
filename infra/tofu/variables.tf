variable "project_name" {
  description = "Short project name used as a prefix for AWS resources."
  type        = string
  default     = "saas"
}

variable "aws_region" {
  description = "AWS region for the deploy. CloudFront cert is always in us-east-1 regardless."
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS account ID this stack deploys into. Used for IAM ARN constraints."
  type        = string
}

variable "domain_name" {
  description = "Apex domain, e.g. \"mysaas.com\". Subdomains constructed from env_prefix + service."
  type        = string
}

variable "env_prefix" {
  description = "Hostname prefix per env: \"\" for production, \"staging.\" for staging."
  type        = string
  validation {
    condition     = contains(["", "staging."], var.env_prefix)
    error_message = "env_prefix must be \"\" or \"staging.\"."
  }
}

variable "environment" {
  description = "\"staging\" or \"production\". Used in resource names/tags."
  type        = string
  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "environment must be \"staging\" or \"production\"."
  }
}

variable "monthly_budget_usd" {
  description = "AWS Budget monthly limit in USD."
  type        = number
  default     = 300
}

variable "budget_email_subscribers" {
  description = "Email addresses that get budget alerts as a fallback to Slack."
  type        = list(string)
  default     = []
}

variable "api_task_count" {
  description = "Desired Fargate task count for the API service."
  type        = number
  default     = 1
}

variable "workers_task_count" {
  description = "Desired Fargate task count for the workers service."
  type        = number
  default     = 1
}

variable "staging_auto_deploy" {
  description = "If true, deploy-staging.yml runs automatically on push to main."
  type        = bool
  default     = true
}

variable "production_auto_deploy" {
  description = "If true, deploy-production.yml runs automatically after successful staging deploy. Default false; manual review via GitHub Environments."
  type        = bool
  default     = false
}
