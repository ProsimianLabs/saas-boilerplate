// SNS -> Slack forwarder. Handles AWS Budgets, CloudWatch Alarms, and custom
// SNS payloads with one code path. Posts Block Kit messages to a webhook URL
// stored in SSM Parameter Store (SecureString, KMS-encrypted).
//
// Pattern lifted from a production setup. Source is in the repo, not a
// vendored package — users own it.

import https from 'node:https';
import { SSMClient, GetParameterCommand } from '@aws-sdk/client-ssm';

const ssm = new SSMClient({});
let cachedWebhookUrl = null;

async function loadWebhookUrl() {
  if (cachedWebhookUrl) return cachedWebhookUrl;
  const name = process.env.SLACK_WEBHOOK_SSM_PARAMETER;
  if (!name) return null;
  const res = await ssm.send(new GetParameterCommand({ Name: name, WithDecryption: true }));
  cachedWebhookUrl = res.Parameter?.Value || null;
  return cachedWebhookUrl;
}

function formatBudgetAlert(message) {
  const budgetName = message.match(/Budget Name: (.+)/)?.[1]?.trim() || 'Unknown';
  const budgetLimit = message.match(/Budgeted Amount: \$([\.\d,]+)/)?.[1]?.trim() || '?';
  const actualSpend = message.match(/ACTUAL Amount: \$([\.\d,]+)/)?.[1]?.trim();
  const forecastedSpend = message.match(/FORECASTED Amount: \$([\.\d,]+)/)?.[1]?.trim();
  const thresholdDollars = message.match(/Alert Threshold: > \$([\.\d,]+)/)?.[1]?.trim();
  const isForecasted = message.includes('FORECASTED');
  const spend = actualSpend || forecastedSpend || '?';
  let thresholdPct = '?';
  if (thresholdDollars && budgetLimit !== '?') {
    const t = parseFloat(thresholdDollars.replace(/,/g, ''));
    const l = parseFloat(budgetLimit.replace(/,/g, ''));
    if (l > 0 && Number.isFinite(t) && Number.isFinite(l)) {
      thresholdPct = Math.round((t / l) * 100).toString();
    }
  }
  const pct = parseFloat(thresholdPct) || 0;
  const emoji = pct >= 100 ? '🔴' : pct >= 85 ? '⚠️' : 'ℹ️';
  const typeLabel = isForecasted
    ? `Forecasted spend exceeds ${thresholdPct}% of budget`
    : `Actual spend exceeded ${thresholdPct}% of budget`;
  return {
    text: `${emoji} Budget alert: ${budgetName} at ${thresholdPct}%`,
    blocks: [
      { type: 'header', text: { type: 'plain_text', text: `${emoji} AWS Budget Alert`, emoji: true } },
      {
        type: 'section',
        fields: [
          { type: 'mrkdwn', text: `*Budget*\n${budgetName}` },
          { type: 'mrkdwn', text: `*Spend*\n$${spend} / $${budgetLimit} (${thresholdPct}%)` },
        ],
      },
      { type: 'section', text: { type: 'mrkdwn', text: `*Type:* ${typeLabel}` } },
      { type: 'context', elements: [{ type: 'mrkdwn', text: `AWS Budget Alert · ${new Date().toLocaleDateString('en-US', { dateStyle: 'medium' })}` }] },
    ],
  };
}

function formatCloudWatchAlarm(payload) {
  const { AlarmName, AlarmDescription, NewStateValue, NewStateReason } = payload;
  const emoji = NewStateValue === 'ALARM' ? '🔴' : NewStateValue === 'OK' ? '✅' : 'ℹ️';
  return {
    text: `${emoji} CloudWatch: ${AlarmName} -> ${NewStateValue}`,
    blocks: [
      { type: 'header', text: { type: 'plain_text', text: `${emoji} CloudWatch Alarm`, emoji: true } },
      {
        type: 'section',
        fields: [
          { type: 'mrkdwn', text: `*Alarm*\n${AlarmName}` },
          { type: 'mrkdwn', text: `*State*\n${NewStateValue}` },
        ],
      },
      ...(AlarmDescription ? [{ type: 'section', text: { type: 'mrkdwn', text: `*Description:* ${AlarmDescription}` } }] : []),
      { type: 'section', text: { type: 'mrkdwn', text: `*Reason:* ${NewStateReason}` } },
    ],
  };
}

async function postToSlack(payload) {
  const webhookUrl = await loadWebhookUrl();
  if (!webhookUrl) {
    console.warn('Slack webhook URL not configured; skipping');
    return;
  }
  const url = new URL(webhookUrl);
  const body = JSON.stringify(payload);
  return new Promise((resolve) => {
    const req = https.request(
      {
        hostname: url.hostname,
        path: url.pathname,
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(body) },
      },
      (res) => {
        console.log('Slack response:', res.statusCode);
        resolve({ statusCode: 200, body: 'OK' });
      },
    );
    req.on('error', (err) => {
      console.error('Slack webhook failed:', err.message);
      resolve({ statusCode: 200, body: 'Webhook failed (non-fatal)' });
    });
    req.write(body);
    req.end();
  });
}

export const handler = async (event) => {
  const record = event.Records?.[0];
  if (!record) return { statusCode: 200, body: 'No records' };
  const message = record.Sns?.Message || '';
  console.log('Alert received:', message.slice(0, 500));

  // Try to parse as CloudWatch Alarm JSON; fall back to AWS Budgets text format
  let payload;
  try {
    const parsed = JSON.parse(message);
    if (parsed.AlarmName) {
      payload = formatCloudWatchAlarm(parsed);
    } else {
      payload = { text: message.slice(0, 500), blocks: [{ type: 'section', text: { type: 'mrkdwn', text: message.slice(0, 2000) } }] };
    }
  } catch {
    payload = formatBudgetAlert(message);
  }

  await postToSlack(payload);
  return { statusCode: 200, body: 'OK' };
};
