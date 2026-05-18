# infra/tofu/modules/logs

Provisions CloudWatch log groups for the API, workers, and alerts Lambda, with configurable retention. Also creates a CloudWatch log metric filter to track application error rates and feed alarms in Phase 2.

## Resources (Phase 2)

- aws_cloudwatch_log_group (api, workers, alerts-lambda)
- aws_cloudwatch_log_metric_filter (error-rate)

## Inputs

See `variables.tf`.

## Outputs

See `outputs.tf`.
