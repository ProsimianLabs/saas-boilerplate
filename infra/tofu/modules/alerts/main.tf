# Phase 1 scaffold. Resources stubbed as comments — populated in Phase 2.

# resource "aws_sns_topic" "alerts" {
#   name = "${var.project_name}-${var.environment}-alerts"
#   tags = { Project = var.project_name, Environment = var.environment }
# }
#
# resource "aws_sns_topic_policy" "alerts" {
#   arn    = aws_sns_topic.alerts.arn
#   policy = data.aws_iam_policy_document.sns_topic_policy.json
# }
#
# resource "aws_sns_topic_subscription" "email" {
#   for_each  = toset(var.email_subscribers)
#   topic_arn = aws_sns_topic.alerts.arn
#   protocol  = "email"
#   endpoint  = each.value
# }
#
# resource "aws_sns_topic_subscription" "lambda" {
#   topic_arn = aws_sns_topic.alerts.arn
#   protocol  = "lambda"
#   endpoint  = aws_lambda_function.slack_forwarder.arn
# }
#
# resource "aws_iam_role" "slack_forwarder" {
#   name               = "${var.project_name}-${var.environment}-slack-forwarder"
#   assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
#   tags               = { Project = var.project_name, Environment = var.environment }
# }
#
# resource "aws_iam_role_policy" "slack_forwarder_ssm" {
#   name   = "ssm-read"
#   role   = aws_iam_role.slack_forwarder.id
#   policy = data.aws_iam_policy_document.ssm_read.json
# }
#
# resource "aws_lambda_function" "slack_forwarder" {
#   function_name = "${var.project_name}-${var.environment}-slack-forwarder"
#   role          = aws_iam_role.slack_forwarder.arn
#   handler       = "index.handler"
#   runtime       = "nodejs22.x"
#   filename      = data.archive_file.slack_forwarder.output_path
#   source_code_hash = data.archive_file.slack_forwarder.output_base64sha256
#   environment {
#     variables = {
#       SLACK_WEBHOOK_SSM_PARAMETER = var.slack_webhook_ssm_param
#     }
#   }
#   tags = { Project = var.project_name, Environment = var.environment }
# }
#
# data "archive_file" "slack_forwarder" {
#   type        = "zip"
#   source_dir  = "${path.module}/lambda/slack-forwarder"
#   output_path = "${path.module}/lambda/slack-forwarder.zip"
# }
#
# resource "aws_lambda_permission" "sns" {
#   statement_id  = "AllowSNSInvoke"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.slack_forwarder.function_name
#   principal     = "sns.amazonaws.com"
#   source_arn    = aws_sns_topic.alerts.arn
# }
#
# resource "aws_cloudwatch_metric_alarm" "api_5xx" {
#   alarm_name          = "${var.project_name}-${var.environment}-api-5xx"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "HTTPCode_Target_5XX_Count"
#   namespace           = "AWS/ApplicationELB"
#   period              = 60
#   statistic           = "Sum"
#   threshold           = 5
#   alarm_actions       = [aws_sns_topic.alerts.arn]
#   ok_actions          = [aws_sns_topic.alerts.arn]
# }
#
# resource "aws_cloudwatch_metric_alarm" "api_p99_latency" {
#   alarm_name          = "${var.project_name}-${var.environment}-api-p99-latency"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 3
#   metric_name         = "TargetResponseTime"
#   namespace           = "AWS/ApplicationELB"
#   period              = 60
#   extended_statistic  = "p99"
#   threshold           = 2
#   alarm_actions       = [aws_sns_topic.alerts.arn]
#   ok_actions          = [aws_sns_topic.alerts.arn]
# }
#
# resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
#   alarm_name          = "${var.project_name}-${var.environment}-alb-unhealthy-hosts"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "UnHealthyHostCount"
#   namespace           = "AWS/ApplicationELB"
#   period              = 60
#   statistic           = "Maximum"
#   threshold           = 0
#   alarm_actions       = [aws_sns_topic.alerts.arn]
#   ok_actions          = [aws_sns_topic.alerts.arn]
# }
#
# resource "aws_budgets_budget" "monthly" {
#   name         = "${var.project_name}-${var.environment}-monthly"
#   budget_type  = "COST"
#   limit_amount = tostring(var.monthly_budget_usd)
#   limit_unit   = "USD"
#   time_unit    = "MONTHLY"
#
#   notification {
#     comparison_operator        = "GREATER_THAN"
#     threshold                  = 85
#     threshold_type             = "PERCENTAGE"
#     notification_type          = "ACTUAL"
#     subscriber_sns_topic_arns  = [aws_sns_topic.alerts.arn]
#   }
#
#   notification {
#     comparison_operator        = "GREATER_THAN"
#     threshold                  = 100
#     threshold_type             = "PERCENTAGE"
#     notification_type          = "FORECASTED"
#     subscriber_sns_topic_arns  = [aws_sns_topic.alerts.arn]
#   }
# }
