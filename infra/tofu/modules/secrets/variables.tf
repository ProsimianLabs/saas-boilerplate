variable "project_name" {
  type        = string
  description = "Resource name prefix."
}

variable "environment" {
  type        = string
  description = "\"staging\" or \"production\"."
}

variable "secret_names" {
  type        = list(string)
  description = "List of secret names to create as SSM SecureString parameters."
}
