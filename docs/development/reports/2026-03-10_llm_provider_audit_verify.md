# Verify Report

## 1. Change Summary
- What changed:
  - Added shared LLM safety enforcement to OpenAI, Anthropic, and Grok providers.
  - Removed stale `OPENAI_API_KEY` gating from `calculate-saju` and `generate-fortune-story`.
  - Corrected provider/model attribution in LLM usage logging for celebrity and pet compatibility functions.
  - Hardened production secrets to Gemini-only and removed the production `OPENAI_API_KEY`.
- Why changed:
  - Prevent hidden spend from dormant non-Gemini provider paths and avoid production breakage after removing unused provider secrets.
- Affected area:
  - `supabase/functions/_shared/llm/*`
  - `supabase/functions/calculate-saju`
  - `supabase/functions/generate-fortune-story`
  - `supabase/functions/fortune-celebrity`
  - `supabase/functions/fortune-pet-compatibility`
  - production Supabase function secrets

## 2. Static Validation
- `flutter analyze`
  - Result: completed with existing `info` only
  - Notes: 14 existing lints remain in `lib/features/chat/presentation/pages/chat_home_page.dart`; no new errors introduced by this change.
- `dart format --set-exit-if-changed .`
  - Result: passed
  - Notes: `0 changed`
- `dart run build_runner build --delete-conflicting-outputs` (if applicable)
  - Result: not required
  - Notes: no generated Dart model changes
- `deno check`
  - Result: passed
  - Notes: checked the changed Edge Function files and shared LLM modules

## 3. Tests and QA
- Unit/Widget/Integration tests run:
  - Command: `deno check ...`, `dart format --set-exit-if-changed .`, `flutter analyze`
  - Result: passed except existing Flutter infos
- Playwright QA (if applicable):
  - Command: not run
  - Result: not applicable for this backend/ops hardening pass

## 4. Files Changed
1. `supabase/functions/_shared/llm/factory.ts` - pass feature metadata to all providers
2. `supabase/functions/_shared/llm/providers/openai.ts` - enforce shared safety guard before text/image calls
3. `supabase/functions/_shared/llm/providers/anthropic.ts` - enforce shared safety guard
4. `supabase/functions/_shared/llm/providers/grok.ts` - enforce shared safety guard
5. `supabase/functions/calculate-saju/index.ts` - remove OpenAI-only gate, use generic provider validation, fix hanja maps
6. `supabase/functions/generate-fortune-story/index.ts` - remove OpenAI-only gate, validate configured provider
7. `supabase/functions/fortune-celebrity/index.ts` - fix provider/model attribution for usage logging
8. `supabase/functions/fortune-pet-compatibility/index.ts` - fix provider/model attribution for usage logging
9. `docs/development/GEMINI_COST_INCIDENT_RUNBOOK.md` - add Gemini-only provider secret policy and OpenAI secret removal
10. `docs/development/reports/2026-03-10_llm_provider_audit_rca.md` - RCA record
11. `docs/development/reports/2026-03-10_llm_provider_audit_discovery.md` - discovery record

## 5. Risks and Follow-ups
- Known risks:
  - Remote `public.llm_usage_logs` and `public.llm_model_config` are still absent, so DB-backed automatic LLM counting and DB-driven routing remain degraded/non-active in production.
  - `fortune-celebrity`, `fortune-pet-compatibility`, and `character-chat` were not redeployed in this pass because the current worktree contains unrelated changes in nearby files; production safety still improved because unused non-Gemini secrets were removed.
- Deferred items:
  - Reconcile migration drift and restore `llm_usage_logs`.
  - Redeploy remaining LLM functions from a reviewed clean snapshot once nearby unrelated changes are either committed separately or confirmed by the user.
  - Optionally disable unused GCP AI services after explicit confirmation of no operational dependency.

## 6. User Manual Test Request
- Scenario:
  1. Call `calculate-saju` once with a normal authenticated request.
  2. Call `generate-fortune-story` once with a normal authenticated request.
  3. Open character chat in the app and confirm normal Gemini-backed responses still work in default mode.
- Expected result:
  - `calculate-saju` and `generate-fortune-story` continue to succeed without `OPENAI_API_KEY`.
  - Default chat paths continue to work.
  - No OpenAI secret exists in production secrets.
- Failure signal:
  - `Configured LLM provider is not available`
  - unexpected 500s from the two redeployed functions
  - requests blocked on a provider other than Gemini in normal app flows

## 7. Completion Gate
- User confirmation required before final completion declaration.
