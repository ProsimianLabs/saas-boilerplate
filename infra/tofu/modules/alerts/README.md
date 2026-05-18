# infra/tofu/modules/alerts

Provisions SNS topics, CloudWatch alarms (5xx rate, p99 latency, DLQ depth, ECS health, ALB unhealthy hosts), an AWS Budgets budget, and a Lambda function that forwards SNS notifications to a Slack webhook. The Slack forwarder source lives in `lambda/slack-forwarder/`.

## Resources (Phase 2)

- aws_sns_topic
- aws_sns_topic_policy
- aws_sns_topic_subscription (email × N + Lambda)
- aws_lambda_function (slack forwarder)
- aws_iam_role + policies for Lambda
- aws_cloudwatch_metric_alarm (5xx, p99, DLQ, ECS health, ALB unhealthy)
- aws_budgets_budget

## Inputs

See `variables.tf`.

## Outputs

See `outputs.tf`.
