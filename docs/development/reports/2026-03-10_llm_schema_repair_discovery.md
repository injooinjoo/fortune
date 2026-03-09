# Discovery Report

## 1. Goal
- Requested change: restore production LLM usage tracking and DB-backed model config so cost guards can auto-block again.
- Work type: Edge Function / SQL migration / monitoring workflow
- Scope: `supabase/migrations`, `_shared/llm`, monitor workflow, incident runbook

## 2. Search Strategy
- Keywords:
  - `llm_usage_logs`
  - `llm_model_config`
  - `createFromConfig`
  - `usageTrackingAvailable`
- Commands:
  - `rg -n "llm_usage_logs|llm_model_config" supabase/migrations supabase/functions docs -S`
  - `rg -n "createFromConfig(?:Async)?\\(" supabase/functions -S`
  - `curl ... /rest/v1/llm_usage_logs?select=id&limit=1`
  - `curl ... /rest/v1/llm_model_config?select=fortune_type&limit=1`

## 3. Similar Code Findings
- Reusable:
  1. `supabase/migrations/20251126100000_create_llm_model_config.sql` - base table, RLS, trigger layout
  2. `supabase/migrations/20251126100001_create_llm_usage_logs.sql` - usage log schema and summary views
  3. `supabase/migrations/20260227000001_guard_llm_model_config_cost.sql` - current safe Gemini seed set and A/B shutdown pattern
  4. `supabase/functions/_shared/llm/safety.ts` - live monitor shape and degraded-state detection
- Reference only:
  1. `.github/workflows/llm-guard-monitor.yml` - current scheduled monitor and Slack path
  2. `docs/development/GEMINI_COST_INCIDENT_RUNBOOK.md` - existing incident response steps

## 4. Reuse Decision
- Reuse as-is:
  - original table/view definitions and guard seed inventory
- Extend existing code:
  - monitor diagnostics and workflow summary to expose missing-table cause directly
- New code required:
  - a new idempotent repair migration because migration history says applied while the live relations are missing
- Duplicate prevention notes:
  - repair migration must be safe to re-run and must not assume a clean migration-history state

## 5. Planned Changes
- Files to edit:
  1. `supabase/functions/_shared/llm/safety.ts`
  2. `.github/workflows/llm-guard-monitor.yml`
  3. `docs/development/GEMINI_COST_INCIDENT_RUNBOOK.md`
- Files to create:
  1. `supabase/migrations/20260310000001_repair_llm_guard_schema.sql`
  2. `docs/development/reports/2026-03-10_llm_schema_repair_rca.md`
  3. `docs/development/reports/2026-03-10_llm_schema_repair_verify.md`

## 6. Validation Plan
- Static checks:
  - `deno check` on changed edge files
  - `dart format --set-exit-if-changed .`
  - `flutter analyze`
- Runtime checks:
  - run repair SQL remotely through a temporary admin edge function
  - verify `llm_usage_logs` and `llm_model_config` via REST
  - invoke `monitor-llm-usage` and confirm `usageTrackingAvailable=true`
- Test cases:
  - missing table returns `42P01` before repair
  - same endpoints return `200` after repair
  - monitor response no longer reports `usage_tracking_unavailable`
  - Result: pending
  - Notes: run after source edits complete
- `dart format --set-exit-if-changed .`
  - Result: pending
  - Notes: run after source edits complete
- `deno check`
  - Result: pending
  - Notes: run on changed edge files after edits complete

## 3. Tests and QA
- Runtime checks:
  - verify `llm_usage_logs` and `llm_model_config` via REST before and after repair
  - invoke `monitor-llm-usage`
  - confirm GCP unused AI services are disabled

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
