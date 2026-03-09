# RCA Report

## 1. Symptom
- Error message: GCP spend spiked on `generativelanguage.googleapis.com`, and the repo still exposed non-Gemini provider paths that could create hidden LLM spend.
- Repro steps:
  1. Search `supabase/functions` for provider SDKs, API keys, and direct fetch calls.
  2. Compare code paths with production Supabase secrets and enabled GCP services.
  3. Inspect remote Supabase table inventory for LLM tracking tables.
- Observed behavior:
  - `OPENAI_API_KEY` is still present in production Supabase secrets.
  - `calculate-saju` and `generate-fortune-story` still gate execution on `OPENAI_API_KEY` even though they route through `LLMFactory`.
  - `character-chat` still has a `grok-fast` route.
  - `fortune-celebrity` and `fortune-pet-compatibility` log provider/model as OpenAI even when the runtime provider comes from `LLMFactory`.
  - Remote `public.llm_usage_logs` and `public.llm_model_config` are absent, so DB-backed LLM usage tracking and DB-driven provider routing are not active in production.
- Expected behavior:
  - Production should only permit allowlisted providers.
  - No function should depend on an unused provider key.
  - Usage logs should attribute the actual provider/model used.

## 2. WHY (Root Cause)
- Direct cause:
  - Historical multi-provider support remained in the codebase after the production posture shifted to Gemini-first.
- Root cause:
  - Provider containment relied on Gemini-only checks, while OpenAI/Anthropic/Grok providers bypassed the shared safety guard.
  - Some functions retained stale OpenAI-specific preconditions from earlier migrations.
  - Production tracking tables expected by the guard were never present in the remote schema, degrading automatic enforcement.
- Data/control flow:
  - Step 1: A function selects an LLM path via `LLMFactory` or a direct provider instantiation.
  - Step 2: Non-Gemini providers can be constructed if code paths or future config changes request them.
  - Step 3: Without provider-level guard enforcement and accurate logging, cost attribution and automated blocking become incomplete.

## 3. WHERE
- Primary locations:
  - `supabase/functions/_shared/llm/providers/openai.ts`
  - `supabase/functions/_shared/llm/providers/anthropic.ts`
  - `supabase/functions/_shared/llm/providers/grok.ts`
  - `supabase/functions/calculate-saju/index.ts`
  - `supabase/functions/generate-fortune-story/index.ts`
  - `supabase/functions/fortune-celebrity/index.ts`
  - `supabase/functions/fortune-pet-compatibility/index.ts`
- Related call sites:
  - `supabase/functions/_shared/llm/factory.ts`
  - `supabase/functions/character-chat/index.ts`
  - `supabase/functions/_shared/llm/safety.ts`

## 4. WHERE ELSE (Global Search)
- Search patterns used:
  - `rg -n "OPENAI_API_KEY|ANTHROPIC_API_KEY|XAI_API_KEY|GEMINI_API_KEY|LLM_PROVIDER" supabase/functions`
  - `rg -n "api\\.openai\\.com|api\\.anthropic\\.com|api\\.x\\.ai|generativelanguage" supabase/functions`
  - `rg -n "provider: 'openai'|provider: \"openai\"|grok-fast" supabase/functions lib`
- Findings:
  1. `supabase/functions/calculate-saju/index.ts:540` - stale OpenAI key gate before shared LLM call.
  2. `supabase/functions/generate-fortune-story/index.ts:210` - stale OpenAI key requirement before shared LLM call.
  3. `supabase/functions/character-chat/index.ts:1643` - explicit Grok provider path.
  4. `supabase/functions/fortune-celebrity/index.ts:365` - provider/model misattributed as OpenAI.
  5. `supabase/functions/fortune-pet-compatibility/index.ts:617` - provider/model misattributed as OpenAI.
  6. `supabase/functions/_shared/llm/providers/gemini.ts:40` - correct reference pattern; Gemini already enforces shared safety guard.

## 5. HOW (Correct Pattern)
- Reference implementation: `supabase/functions/_shared/llm/providers/gemini.ts:40`
- Before:
```ts
const openAIApiKey = Deno.env.get('OPENAI_API_KEY')
if (!openAIApiKey) {
  throw new Error('OpenAI API key not configured')
}
```
- After:
```ts
const llm = await LLMFactory.createFromConfigAsync('fortune-story')
if (!llm.validateConfig()) {
  throw new Error('Configured LLM provider is not available')
}
```
- Why this fix is correct:
  - The selected runtime provider should be validated generically, not through a stale provider-specific secret.
  - Shared safety enforcement must run inside every provider implementation so the allowlist/disable policy is guaranteed regardless of call site.

## 6. Fix Plan
- Files to change:
  1. `supabase/functions/_shared/llm/factory.ts` - pass feature metadata to all providers.
  2. `supabase/functions/_shared/llm/providers/openai.ts` - enforce shared safety guard.
  3. `supabase/functions/_shared/llm/providers/anthropic.ts` - enforce shared safety guard.
  4. `supabase/functions/_shared/llm/providers/grok.ts` - enforce shared safety guard.
  5. `supabase/functions/calculate-saju/index.ts` - remove OpenAI-only gating.
  6. `supabase/functions/generate-fortune-story/index.ts` - remove OpenAI-only gating.
  7. `supabase/functions/fortune-celebrity/index.ts` - log actual provider/model.
  8. `supabase/functions/fortune-pet-compatibility/index.ts` - log actual provider/model.
- Risk assessment:
  - Low to medium. Provider guard changes affect all non-Gemini calls, but that is intentional for production containment.
- Validation plan:
  - `deno check` on changed Edge Function files.
  - `dart format --set-exit-if-changed .`
  - `flutter analyze`
  - Supabase secret hardening and targeted smoke checks.
