# RN Fortune Schema Batch 2 RCA

Date: 2026-04-08
Scope: RN chat fortune edge integration drift

## Symptom

Edge-backed fortunes in RN were not consistently using the actual edge schema. Some requests failed silently or degraded into cards that still looked partially hardcoded.

## Root Cause

The first rollout standardized orchestration and caching, but it did not fully normalize fortune-specific request/output contracts. RN still carried legacy survey shapes and adapter expectations for several fortunes.

## Where

- `apps/mobile-rn/src/features/chat-survey/registry.ts`
- `apps/mobile-rn/src/features/chat-results/edge-runtime.ts`
- `apps/mobile-rn/src/features/chat-results/adapter.ts`
- `packages/product-contracts/src/fortune-result-normalizer.ts`

## Where Else

The same drift pattern is most likely anywhere RN:

- aliases a reduced survey onto a richer edge contract
- expects camelCase output while edge returns snake_case
- merges fallback copy after successful API extraction

## How

- Match RN request keys to real edge input contracts.
- Prefer API-derived card sections over fallback sections when extraction succeeds.
- Surface edge-only structures through normalization or fortune-specific extraction.
