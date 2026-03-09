# Discovery Report

## 1. Goal
- Requested change: Audit all LLM API usage, identify hidden spend paths, and harden production against non-Gemini costs.
- Work type: Edge Function / Shared LLM Service / Ops hardening
- Scope: `supabase/functions`, remote Supabase secrets, and GCP enabled AI services/API keys.

## 2. Search Strategy
- Keywords:
  - `openai`, `anthropic`, `grok`, `gemini`, `generativelanguage`, `aiplatform`, `OPENAI_API_KEY`, `XAI_API_KEY`
- Commands:
  - `rg -n --hidden -S "api\\.openai\\.com|api\\.anthropic\\.com|api\\.x\\.ai|generativelanguage" supabase/functions`
  - `rg -n --hidden -S "OPENAI_API_KEY|ANTHROPIC_API_KEY|XAI_API_KEY|GEMINI_API_KEY|LLM_PROVIDER" supabase/functions`
  - `supabase secrets list --project-ref hayjukwfcsdmppairazc`
  - `gcloud services list --enabled --project=fortune2-463710`
  - `gcloud services api-keys list --project=fortune2-463710`
  - `supabase inspect db table-stats --linked -o json`

## 3. Similar Code Findings
- Reusable:
  1. `supabase/functions/_shared/llm/safety.ts` - central provider/model guard already exists and should be reused for all providers.
  2. `supabase/functions/_shared/llm/providers/gemini.ts` - correct provider-level guard enforcement pattern.
- Reference only:
  1. `supabase/functions/character-chat/index.ts` - explicit non-default provider path (`grok-fast`) that needs containment, not duplication.
  2. `supabase/functions/_shared/llm/usage-logger.ts` - canonical place for provider/model attribution.

## 4. Reuse Decision
- Reuse as-is:
  - Existing `assertLlmRequestAllowed` guard in `safety.ts`
  - Existing provider implementations and `LLMFactory`
- Extend existing code:
  - Add guard calls to non-Gemini providers.
  - Pass `featureName` through `LLMFactory`.
  - Clean stale OpenAI-specific gates in edge functions.
- New code required:
  - No new runtime module required for this containment pass.
- Duplicate prevention notes:
  - Containment stays inside the shared provider layer so future call sites inherit the same behavior.

## 5. Planned Changes
- Files to edit:
  1. `supabase/functions/_shared/llm/factory.ts`
  2. `supabase/functions/_shared/llm/providers/openai.ts`
  3. `supabase/functions/_shared/llm/providers/anthropic.ts`
  4. `supabase/functions/_shared/llm/providers/grok.ts`
  5. `supabase/functions/calculate-saju/index.ts`
  6. `supabase/functions/generate-fortune-story/index.ts`
  7. `supabase/functions/fortune-celebrity/index.ts`
  8. `supabase/functions/fortune-pet-compatibility/index.ts`
- Files to create:
  1. `docs/development/reports/2026-03-10_llm_provider_audit_rca.md`

## 6. Validation Plan
- Static checks:
  - `deno check` for changed TS files
  - `dart format --set-exit-if-changed .`
  - `flutter analyze`
- Runtime checks:
  - Confirm production secrets only allow Gemini.
  - Confirm remote GCP API keys do not expose other paid LLM APIs.
- Test cases:
  - `grok-fast` request path must be blocked by safety policy before any network call.
  - `calculate-saju` and `generate-fortune-story` must no longer require `OPENAI_API_KEY`.
  - Usage logs in celebrity/pet compatibility must reflect the actual provider and model.
