# Verify Report

Date: 2026-03-10
Topic: Gemini cost guard hardening

## Completed

- Added Gemini model catalog and preview/high-cost gating
- Added shared alert transport for webhook/push notifications
- Hardened shared LLM safety with burst limits and circuit-breaker state
- Added `monitor-llm-usage` Edge Function
- Added scheduled GitHub workflow `.github/workflows/llm-guard-monitor.yml`
- Set new production secrets for burst limits, allowlist, preview disable, and monitor secret
- Deployed all Gemini/LLM-backed Edge Functions from a clean snapshot

## Verification executed

### 1. Type checks

```bash
deno check supabase/functions/_shared/llm/models.ts
deno check supabase/functions/_shared/llm/alerts.ts
deno check supabase/functions/_shared/llm/safety.ts
deno check supabase/functions/_shared/llm/config.ts
deno check supabase/functions/_shared/llm/config-service.ts
deno check supabase/functions/_shared/llm/providers/gemini.ts
deno check supabase/functions/_shared/llm/usage-logger.ts
deno check supabase/functions/_shared/notification_push.ts
deno check supabase/functions/monitor-llm-usage/index.ts
deno check supabase/functions/free-chat/index.ts
deno check supabase/functions/fortune-yearly-encounter/index.ts
deno check supabase/functions/fortune-past-life/index.ts
deno check supabase/functions/generate-fashion-image/index.ts
deno check supabase/functions/generate-talisman/index.ts
```

Result: passed

### 2. Workflow syntax

```bash
ruby -e "require 'yaml'; YAML.load_file('.github/workflows/llm-guard-monitor.yml'); puts 'YAML OK'"
```

Result: `YAML OK`

### 3. Dart format

```bash
dart format --set-exit-if-changed .
```

Result: passed, `0 changed`

### 4. Flutter analyze

```bash
flutter analyze
```

Result: no new errors. Existing repo infos remain in `lib/features/chat/presentation/pages/chat_home_page.dart` (14 infos).

### 5. Secret verification

Confirmed:

- `GEMINI_BURST_REQUEST_LIMIT`
- `GEMINI_BURST_WINDOW_MINUTES`
- `GEMINI_FEATURE_BURST_REQUEST_LIMIT`
- `GEMINI_CIRCUIT_BREAKER_COOLDOWN_MINUTES`
- `LLM_GUARD_ALERT_THRESHOLD_RATIO`
- `LLM_GUARD_MONITOR_SECRET`
- `LLM_ALLOW_PREVIEW_MODELS`
- `GEMINI_MODEL_ALLOWLIST`

Confirmed GitHub repository secrets:

- `SUPABASE_URL`
- `LLM_GUARD_MONITOR_SECRET`
- `SLACK_WEBHOOK_URL`

### 6. Deployment verification

Redeployed from clean snapshot to avoid unrelated local worktree changes:

- all functions importing `_shared/llm`
- direct Gemini fetch functions
- `monitor-llm-usage` with `--no-verify-jwt`

### 7. Monitor endpoint smoke test

```bash
curl -sS \
  -X POST \
  -H "Content-Type: application/json" \
  -H "x-llm-monitor-secret: <secret>" \
  https://hayjukwfcsdmppairazc.supabase.co/functions/v1/monitor-llm-usage
```

Result: endpoint returned success with:

- `severity=warning`
- `actions=["usage_tracking_unavailable"]`

## Residual risk

- The remote project currently does not expose `public.llm_usage_logs`, so request-count and cost-window enforcement is running in degraded mode.
- In degraded mode, provider disable, model allowlist, preview gating, GitHub scheduled checks, and manual emergency disable still work.
- Full burst/daily auto-blocking will become active only after the remote logging table path is restored.
