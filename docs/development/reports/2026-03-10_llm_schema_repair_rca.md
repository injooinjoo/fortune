# RCA Report

## Symptom
- `monitor-llm-usage` returned `severity=warning` with `actions=["usage_tracking_unavailable"]`.
- Direct REST checks against production returned:
  - `relation "public.llm_usage_logs" does not exist`
  - `relation "public.llm_model_config" does not exist`

## WHY
- Production migration history reported the original LLM migrations as applied, but the live relations were absent.
- Because `llm_usage_logs` was missing, the Gemini guard could not read request windows or persist circuit-breaker state.
- Because `llm_model_config` was missing, DB-backed safe model routing and A/B shutdown data were also inactive.

## WHERE
- Runtime failure surfaced in `supabase/functions/_shared/llm/safety.ts`.
- Affected DB objects:
  - `public.llm_usage_logs`
  - `public.llm_model_config`
  - `public.llm_usage_daily_summary`
  - `public.llm_usage_provider_summary`

## WHERE ELSE
- `UsageLogger` writes to `llm_usage_logs`.
- `ConfigService` reads from `llm_model_config`.
- `.github/workflows/llm-guard-monitor.yml` depended on the monitor response but did not surface the exact missing-table cause.
- GCP project still had unused AI services enabled:
  - `aiplatform.googleapis.com`
  - `cloudaicompanion.googleapis.com`
  - `geminicloudassist.googleapis.com`

## HOW
- Restore the missing relations with an idempotent repair migration that recreates the tables, policies, trigger, views, and safe Gemini seed rows.
- Keep monitor diagnostics explicit so the next schema regression is visible in the workflow and Slack summary immediately.
- Remove unused AI services at the GCP project level so only `generativelanguage.googleapis.com` remains exposed for runtime LLM spend.

## Fix Plan
1. Add an idempotent repair migration for `llm_usage_logs` and `llm_model_config`.
2. Persist the monitor diagnostic fields in source control and improve workflow summaries.
3. Apply the repair remotely, then verify monitor health and table existence.
4. Disable unused GCP AI services not referenced by the codebase.
