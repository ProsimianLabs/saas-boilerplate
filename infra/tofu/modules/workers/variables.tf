variable "project_name" {
  type        = string
  description = "Resource name prefix."
}

variable "environment" {
  type        = string
  description = "\"staging\" or \"production\"."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs the ECS workers service will run in."
}

variable "security_group_id" {
  type        = string
  description = "Security group attached to workers tasks (egress-only)."
}

variable "ecr_repository_url" {
  type        = string
  description = "ECR repository URL for the workers image."
}

variable "secrets_arns" {
  type        = list(string)
  description = "SSM Parameter Store SecureString ARNs the task role can read."
}

variable "log_group_name" {
  type        = string
  description = "CloudWatch log group name for the workers task."
}

variable "task_count" {
  type        = number
  description = "Desired Fargate task count."
  default     = 1
}
