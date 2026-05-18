# Phase 1 scaffold. Resources stubbed as comments — populated in Phase 2.

# resource "aws_ssm_parameter" "secret" {
#   for_each = toset(var.secret_names)
#   name     = "/${var.project_name}/${var.environment}/${each.key}"
#   type     = "SecureString"
#   value    = "PLACEHOLDER"
#   tags     = { Project = var.project_name, Environment = var.environment }
#   lifecycle { ignore_changes = [value] }
# }
