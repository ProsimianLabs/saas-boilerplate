variable "project_name" {
  type        = string
  description = "Resource name prefix."
}

variable "environment" {
  type        = string
  description = "\"staging\" or \"production\"."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to deploy the ALB into."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs for the ALB."
}

variable "certificate_arn" {
  type        = string
  description = "ACM certificate ARN for the HTTPS listener."
}

variable "alb_security_group_id" {
  type        = string
  description = "Security group ID attached to the ALB."
}
