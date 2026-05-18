# notify-slack composite action

Posts a Block Kit deploy/CI notification to a Slack incoming webhook.

## Usage

```yaml
- uses: ./.github/actions/notify-slack
  if: always()
  with:
    status: ${{ job.status }}
    environment: staging
    sha: ${{ github.sha }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK_DEPLOYS }}
```

Webhook URL should be stored as a GitHub Environment secret per env (staging/production), not as a repo-level secret.
