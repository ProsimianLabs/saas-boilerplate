# Root module. Wires up provider configuration + module instantiations.
# Phase 1: module blocks are commented out — uncomment as each module's
# resources are populated in Phase 2.

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "OpenTofu"
    }
  }
}

# Second provider alias for CloudFront cert (must live in us-east-1).
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "OpenTofu"
    }
  }
}

# ─── Modules (uncomment as Phase 2 populates them) ─────────────────────────
#
# module "network" {
#   source       = "./modules/network"
#   project_name = var.project_name
#   environment  = var.environment
# }
#
# module "acm" {
#   source        = "./modules/acm"
#   providers     = { aws.us_east_1 = aws.us_east_1 }
#   domain_name   = var.domain_name
#   env_prefix    = var.env_prefix
# }
#
# module "dns" {
#   source       = "./modules/dns"
#   domain_name  = var.domain_name
#   env_prefix   = var.env_prefix
# }
#
# module "registry" {
#   source       = "./modules/registry"
#   project_name = var.project_name
# }
#
# module "secrets" {
#   source       = "./modules/secrets"
#   project_name = var.project_name
#   environment  = var.environment
# }
#
# module "logs" {
#   source       = "./modules/logs"
#   project_name = var.project_name
#   environment  = var.environment
# }
#
# module "loadbalancer" {
#   source        = "./modules/loadbalancer"
#   project_name  = var.project_name
#   environment   = var.environment
#   vpc_id        = module.network.vpc_id
#   subnet_ids    = module.network.public_subnet_ids
#   certificate_arn = module.acm.alb_cert_arn
# }
#
# module "api" {
#   source              = "./modules/api"
#   project_name        = var.project_name
#   environment         = var.environment
#   vpc_id              = module.network.vpc_id
#   subnet_ids          = module.network.public_subnet_ids
#   security_group_id   = module.network.api_security_group_id
#   ecr_repository_url  = module.registry.api_repository_url
#   target_group_arn    = module.loadbalancer.api_target_group_arn
#   secrets_arns        = module.secrets.api_secret_arns
#   log_group_name      = module.logs.api_log_group_name
#   task_count          = var.api_task_count
# }
#
# module "workers" {
#   source              = "./modules/workers"
#   project_name        = var.project_name
#   environment         = var.environment
#   vpc_id              = module.network.vpc_id
#   subnet_ids          = module.network.public_subnet_ids
#   security_group_id   = module.network.workers_security_group_id
#   ecr_repository_url  = module.registry.workers_repository_url
#   secrets_arns        = module.secrets.workers_secret_arns
#   log_group_name      = module.logs.workers_log_group_name
#   task_count          = var.workers_task_count
# }
#
# module "web" {
#   source       = "./modules/web"
#   providers    = { aws.us_east_1 = aws.us_east_1 }
#   project_name = var.project_name
#   environment  = var.environment
#   domain_name  = var.domain_name
#   env_prefix   = var.env_prefix
#   certificate_arn = module.acm.cloudfront_cert_arn
# }
#
# module "marketing" {
#   source       = "./modules/marketing"
#   providers    = { aws.us_east_1 = aws.us_east_1 }
#   project_name = var.project_name
#   environment  = var.environment
#   domain_name  = var.domain_name
#   env_prefix   = var.env_prefix
#   certificate_arn = module.acm.cloudfront_cert_arn
# }
#
# module "alerts" {
#   source                   = "./modules/alerts"
#   project_name             = var.project_name
#   environment              = var.environment
#   monthly_budget_usd       = var.monthly_budget_usd
#   email_subscribers        = var.budget_email_subscribers
#   slack_webhook_ssm_param  = "/${var.project_name}/${var.environment}/slack/alerts-webhook"
#   api_target_group_arn     = module.loadbalancer.api_target_group_arn
#   api_log_group_name       = module.logs.api_log_group_name
# }
