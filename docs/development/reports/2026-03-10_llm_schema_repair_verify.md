# Verify Report

## 1. Change Summary
- What changed:
  - added an idempotent schema repair migration for `llm_usage_logs` and `llm_model_config`
  - kept `usageTrackingError` in the guard snapshot
  - improved monitor workflow summaries and runbook guidance
- Why changed:
  - production auto-blocking was degraded because usage tracking tables were missing
- Affected area:
  - Supabase DB schema, LLM guard monitoring, incident operations

## 2. Static Validation
- `flutter analyze`
  - Result: completed with existing info only
  - Notes: 14 existing infos remain in `lib/features/chat/presentation/pages/chat_home_page.dart`; no new analyzer errors
- `dart format --set-exit-if-changed .`
  - Result: passed
  - Notes: `Formatted 1019 files (0 changed)`
- `deno check`
  - Result: passed
  - Notes: `supabase/functions/_shared/llm/safety.ts` and `supabase/functions/monitor-llm-usage/index.ts`

## 3. Tests and QA
- Runtime checks:
  - verified `llm_usage_logs` via REST after repair: `HTTP 200`
  - verified `llm_model_config` via REST after repair: `HTTP 200` with Gemini safe defaults present
  - invoked `llm-schema-repair-temp`, confirmed `llmUsageLogs=llm_usage_logs` and `llmModelConfig=llm_model_config`
  - invoked `monitor-llm-usage`, confirmed `severity=healthy`, `usageTrackingAvailable=true`, `actions=[]`
  - confirmed unused GCP AI services are disabled; only `generativelanguage.googleapis.com` remains enabled from the audited AI services

## 4. Files Changed
1. `supabase/migrations/20260310000001_repair_llm_guard_schema.sql` - idempotent relation repair and safe seed rows
2. `supabase/functions/_shared/llm/safety.ts` - include the concrete usage tracking failure in monitor output
3. `.github/workflows/llm-guard-monitor.yml` - expose tracking degradation in workflow summary
4. `docs/development/GEMINI_COST_INCIDENT_RUNBOOK.md` - document schema repair procedure

## 5. Risks and Follow-ups
- Known risks:
  - migration history drift still exists until normal `supabase db push` can reconcile it
- Deferred items:
  - optional later cleanup of legacy seed aliases once runtime references are fully normalized

## 6. User Manual Test Request
- Scenario:
  1. Trigger `monitor-llm-usage` with the shared monitor secret.
  2. Confirm `severity` is no worse than `healthy` or expected live thresholds.
  3. Confirm `usageTrackingAvailable` is `true`.
- Expected result:
  - the monitor returns active window data instead of `usage_tracking_unavailable`
- Failure signal:
  - `42P01`, `usageTrackingAvailable=false`, or `actions` still include `usage_tracking_unavailable`

## 7. Completion Gate
- User confirmation required before final completion declaration.
