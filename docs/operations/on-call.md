# On-call runbook (template)

Alerts you will receive in `#alerts`, what they mean, and how to triage.

## Default alarms (Phase 2 wires them in Tofu `alerts` module)

| Alarm | Threshold | What to check first |
|---|---|---|
| **API 5xx rate > 1%** | 5min sustained | OTel traces for the failing endpoint; recent deploy diff |
| **API p99 latency > 2s** | 5min sustained | Slow DB queries (Neon dashboard); cold starts on a new deploy |
| **ECS API task unhealthy** | `runningCount < desiredCount` for 5min | ECS console → task status; CloudWatch logs for the failing container |
| **ALB unhealthy targets > 0** | 5min | Health check failing on a task; investigate that task's logs |
| **BullMQ DLQ depth > 100** | Any time | Worker logs for the failing job type; check Upstash for queue state |
| **Worker task crashes > 3 in 10min** | Crash loop | Container crash logs; recent worker code change |
| **API log error rate > 50/min** | Sustained | Log group filter for `ERROR`; usually downstream service degradation |

## AWS Budget alerts

| Threshold | Action |
|---|---|
| 50% | Informational — no action needed |
| 85% | Review spend; consider scaling down if month is still young |
| 100% | Alert — find the cost driver; check NAT/data transfer/ECS task count |
| 150%+ | Critical — likely runaway resource (unbounded log volume, accidental large EC2, abandoned NAT) |

## Incident response template

When you get a critical alarm:

1. **Acknowledge** in #alerts (thread reply) so collaborators know it's being handled.
2. **Triage** via the trace ID in the alarm message → OTel UI → see the failing trace.
3. **Decide**: rollback or fix forward? If unsure, **rollback** (`gh workflow run rollback.yml -f environment=production`) and investigate calmly.
4. **Post-incident**: write a brief note in #alerts thread — what happened, what you did, what's next. No need for formal RCA docs until incidents get user-impacting and frequent.
