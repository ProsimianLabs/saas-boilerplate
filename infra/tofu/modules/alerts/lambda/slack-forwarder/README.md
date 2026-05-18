# Slack forwarder Lambda

SNS-subscribed Lambda that posts AWS Budgets and CloudWatch alarm payloads to a Slack webhook (URL stored in SSM SecureString). Bundled with the alerts Tofu module.

## Build

In Phase 2, the alerts module uses `archive_file` data source to zip `index.mjs` + `node_modules/` for the Lambda deployment. For Phase 1, just `npm install` here to populate `node_modules/` so Phase 2 can zip it.
