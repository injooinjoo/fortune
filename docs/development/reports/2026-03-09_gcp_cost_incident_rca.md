# RCA Report

Date: 2026-03-09
Incident: GCP cost spike on Gemini usage

## Symptom

- GCP spend rose abruptly in `fortune2-463710`.
- The spike aligned with heavy `generativelanguage.googleapis.com` traffic.

## Why

1. Gemini API calls were made through API keys, not service-account based server auth.
2. Multiple Gemini API keys existed in the production project.
3. Those keys had API target restrictions only and no stronger application boundary.
4. The codebase had no central runtime circuit breaker for Gemini traffic.

## Where

- Shared Gemini call path:
  - `supabase/functions/_shared/llm/providers/gemini.ts`
- Direct bypass paths:
  - `supabase/functions/fortune-yearly-encounter/index.ts`
  - `supabase/functions/fortune-past-life/index.ts`
  - `supabase/functions/generate-fashion-image/index.ts`

## Where else

- `gcloud services api-keys list --project=fortune2-463710` showed multiple Gemini keys:
  - `fortune`
  - `Gemini API Key_translate`
  - `nanobanana`
  - `note`
  - `노트만들기`
  - `Notemaker`
- Monitoring showed the main traffic came from:
  - `apikey:4241948a-24f0-41e2-accf-813972db41e3`
  - `apikey:5e15c5e4-0ef3-4bf3-a6c8-c701fc87daed`

## How

- Add central request guardrails in `_shared/llm`.
- Enforce request caps before Gemini calls are sent.
- Rotate the production Gemini key.
- Remove extra Gemini keys from the production project.
- Keep logging and incident runbooks close to the shared LLM layer.
