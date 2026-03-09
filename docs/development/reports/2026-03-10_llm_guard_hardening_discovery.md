# Discovery Report

Date: 2026-03-10
Topic: Gemini cost guard hardening

## Existing code searched

- `rg -n "(slack|webhook|alert|monitor|notification)" supabase lib scripts docs .github`
- `rg -n "GEMINI_|LLM_|llm_usage_logs|generativelanguage|vertex|gemini-" supabase/functions docs scripts`
- `rg -n "gemini-.*(preview|exp)" supabase/functions scripts docs`

## Findings

1. Runtime blocking already exists in `supabase/functions/_shared/llm/safety.ts`, but only for 24h request/cost caps.
2. Model safety already exists in `supabase/functions/_shared/llm/config-service.ts`, but only as a coarse high-cost fallback rule.
3. Direct Gemini fetch paths still exist outside the shared provider:
   - `supabase/functions/fortune-yearly-encounter/index.ts`
   - `supabase/functions/fortune-past-life/index.ts`
   - `supabase/functions/generate-fashion-image/index.ts`
   - `supabase/functions/generate-talisman/index.ts`
4. Repository-level Slack notification infrastructure already exists in reusable GitHub workflows.
5. Mobile push delivery infrastructure already exists in `supabase/functions/_shared/notification_push.ts`.
6. Current production code still contains preview/experimental Gemini model strings in `generate-talisman`.

## External product check

- Official Google release on 2026-03-03 introduced `Gemini 3.1 Flash-Lite` as a preview model.
- The preview model is not a safe production default because it is preview and priced above `Gemini 2.5 Flash-Lite`.

## Decision

- Keep production on stable Gemini defaults and add explicit preview gating.
- Add DB-backed circuit breaker state so one threshold breach blocks across all Edge Function instances.
- Add burst-window detection to catch loops and sudden spikes faster than the existing 24h limit.
- Add an authenticated monitor function plus scheduled GitHub workflow for out-of-band checks and Slack alerting.
- Reuse existing push infrastructure as an optional direct alert channel for the admin account instead of introducing a new notification stack.
