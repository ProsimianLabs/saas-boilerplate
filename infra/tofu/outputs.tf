# Phase 1: outputs declared as the corresponding modules get populated.

# output "api_url" {
#   description = "Public URL of the API."
#   value       = "https://${var.env_prefix}api.${var.domain_name}"
# }
#
# output "web_url" {
#   description = "Public URL of the web app SPA."
#   value       = "https://${var.env_prefix}app.${var.domain_name}"
# }
#
# output "marketing_url" {
#   description = "Public URL of the marketing site."
#   value       = "https://${var.domain_name}"
# }
#
# output "ecr_api_repository_url" {
#   description = "ECR repo URL for the API image."
#   value       = module.registry.api_repository_url
# }
#
# output "ecr_workers_repository_url" {
#   description = "ECR repo URL for the workers image."
#   value       = module.registry.workers_repository_url
# }
