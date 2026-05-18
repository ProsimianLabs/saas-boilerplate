# Observability

All apps emit OpenTelemetry traces + logs + metrics. Local dev forwards to stdout (via the `otel-collector` Docker service). Production needs an external collector.

## Default local flow

```
apps/api / apps/workers
  ↓ OTLP (HTTP, port 4318)
local otel-collector
  ↓ stdout (debug exporter)
your terminal
```

## Production: pick a backend

| Backend | How |
|---|---|
| **Honeycomb** | Set `OTEL_EXPORTER_OTLP_ENDPOINT=https://api.honeycomb.io` + `OTEL_EXPORTER_OTLP_HEADERS=x-honeycomb-team=<api-key>` |
| **Grafana Cloud** | Set OTLP endpoint + auth header per [Grafana docs](https://grafana.com/docs/grafana-cloud/send-data/otlp/) |
| **Datadog** | Set OTLP endpoint to your dd-agent or use Datadog OTel collector intermediary |
| **AWS X-Ray** | Run AWS Distro for OpenTelemetry (ADOT) collector as a sidecar; X-Ray is the trace store |
| **SigNoz / GlitchTip self-hosted** | Run your own collector + storage |

Update the SSM parameter `/saas/<env>/otel/endpoint` (and headers if needed). Phase 2 wires the ECS task definition to inject these as env vars.

## What you get out of the box

- **Traces**: every HTTP request, every Prisma query, every BullMQ job — auto-instrumented via `@opentelemetry/auto-instrumentations-node`.
- **Logs**: every Pino log line carries `trace_id` + `span_id` so you can pivot from a trace to its logs.
- **Metrics**: request rate, error rate, duration p50/p95/p99 per route. ECS task CPU/memory via CloudWatch.

## Slack alerts vs OTel

The two streams overlap but serve different purposes:
- **OTel** = your daily debugging signal — open the trace, see what happened.
- **Slack #alerts** = wake-up notifications when something crosses a threshold.

See `docs/operations/on-call.md` for the alerts that ship by default.
