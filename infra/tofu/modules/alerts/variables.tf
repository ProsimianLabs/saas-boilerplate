variable "project_name" {
  type        = string
  description = "Resource name prefix."
}

variable "environment" {
  type        = string
  description = "\"staging\" or \"production\"."
}

variable "monthly_budget_usd" {
  type        = number
  description = "Monthly AWS budget limit in USD."
  default     = 100
}

variable "email_subscribers" {
  type        = list(string)
  description = "Email addresses to subscribe to the SNS alerts topic."
  default     = []
}

variable "slack_webhook_ssm_param" {
  type        = string
  description = "SSM Parameter Store name containing the Slack webhook URL (SecureString)."
}

variable "api_target_group_arn" {
  type        = string
  description = "ALB target group ARN for the API service (used by CloudWatch alarms)."
}

variable "api_log_group_name" {
  type        = string
  description = "CloudWatch log group name for the API service."
}
