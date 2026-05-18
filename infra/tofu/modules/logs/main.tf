# Phase 1 scaffold. Resources stubbed as comments — populated in Phase 2.

# resource "aws_cloudwatch_log_group" "api" {
#   name              = "/ecs/${var.project_name}-${var.environment}/api"
#   retention_in_days = 30
# }
#
# resource "aws_cloudwatch_log_group" "workers" {
#   name              = "/ecs/${var.project_name}-${var.environment}/workers"
#   retention_in_days = 30
# }
#
# resource "aws_cloudwatch_log_group" "alerts_lambda" {
#   name              = "/aws/lambda/${var.project_name}-${var.environment}-alerts"
#   retention_in_days = 14
# }
#
# resource "aws_cloudwatch_log_metric_filter" "error_rate" {
#   name           = "${var.project_name}-${var.environment}-api-error-rate"
#   pattern        = "ERROR"
#   log_group_name = aws_cloudwatch_log_group.api.name
#   metric_transformation {
#     name      = "ApiErrorCount"
#     namespace = "${var.project_name}/${var.environment}"
#     value     = "1"
#   }
# }
