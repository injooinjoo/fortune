# Verify Report

Date: 2026-03-09
Topic: GCP Gemini cost incident follow-up

## Completed

- Added shared Gemini safety guard in `_shared/llm`
- Wired direct Gemini fetch paths to the same guard
- Rotated the production Gemini key
- Removed legacy Gemini API keys from GCP
- Deployed Gemini-related Supabase Edge Functions from a clean snapshot
- Re-enabled `generativelanguage.googleapis.com`

## Verification executed

### 1. Type checks

```bash
deno check \
  supabase/functions/_shared/llm/safety.ts \
  supabase/functions/_shared/llm/factory.ts \
  supabase/functions/_shared/llm/providers/gemini.ts \
  supabase/functions/_shared/llm/providers/anthropic.ts \
  supabase/functions/_shared/llm/types.ts \
  supabase/functions/generate-fashion-image/index.ts \
  supabase/functions/fortune-yearly-encounter/index.ts \
  supabase/functions/generate-talisman/index.ts \
  supabase/functions/fortune-past-life/index.ts
```

Result: passed

### 2. Flutter analyze

```bash
flutter analyze
```

Result: no new compile errors for this incident fix. Existing repo infos remain in `lib/features/chat/presentation/pages/chat_home_page.dart`.

### 3. Dart format

```bash
dart format --set-exit-if-changed .
```

Result: passed, `0 changed`

### 4. Supabase secrets

Confirmed:

- `GEMINI_API_KEY`
- `GEMINI_DAILY_REQUEST_LIMIT`
- `GEMINI_EMERGENCY_DISABLE`
- `GEMINI_GUARD_WINDOW_HOURS`
- `LLM_USAGE_GUARD_CACHE_TTL_MS`

### 5. GCP service state

Confirmed:

- `generativelanguage.googleapis.com` enabled again on 2026-03-09
- old Gemini keys deleted
- only rotated production Gemini key remains, plus Firebase auto-created keys

### 6. Gemini API smoke test

```bash
curl -s 'https://generativelanguage.googleapis.com/v1beta/models?key=<rotated-key>'
```

Result: returned `models/gemini-2.5-flash`

## Deployment note

Deployment was executed from a clean snapshot under `/tmp/fortune-incident-deploy.*` to avoid shipping unrelated local worktree changes.

## Known limitation

- `fortune-batch` was intentionally excluded from deployment because it is not present in the clean `HEAD` snapshot and would have required shipping unrelated local worktree content.
