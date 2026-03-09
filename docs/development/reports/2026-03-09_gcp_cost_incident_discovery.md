# Discovery Report

Date: 2026-03-09
Topic: GCP Gemini cost spike follow-up

## Existing code searched

- `rg -n "generativelanguage.googleapis.com" supabase/functions scripts`
- `rg -n "LLM_PROVIDER|GEMINI_API_KEY|UsageLogger|GCP_LOGGING" supabase docs scripts`
- `gcloud services api-keys list --project=fortune2-463710`

## Findings

1. Shared Gemini provider exists in `supabase/functions/_shared/llm/providers/gemini.ts`.
2. Shared provider is instantiated through `supabase/functions/_shared/llm/factory.ts`.
3. Existing guard pattern already exists for model safety in `supabase/functions/_shared/llm/config-service.ts`.
4. Direct Gemini fetch paths bypass the shared provider:
   - `supabase/functions/fortune-yearly-encounter/index.ts`
   - `supabase/functions/fortune-past-life/index.ts`
   - `supabase/functions/generate-fashion-image/index.ts`
5. Usage is already logged through `supabase/functions/_shared/llm/usage-logger.ts`.

## Decision

- Reuse and extend the shared `_shared/llm` layer.
- Add one central runtime safety guard for provider disable / request cap checks.
- Wire that guard into both shared provider and direct Gemini fetch paths.
- Add a dedicated incident runbook instead of scattering incident steps across unrelated docs.
