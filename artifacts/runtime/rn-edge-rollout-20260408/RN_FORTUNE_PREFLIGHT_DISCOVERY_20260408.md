# Discovery Report

## 1. Goal
- Requested change: Make all RN edge-backed fortunes use one shared preflight before result execution.
- Work type: Service / Screen / Runtime orchestration / Documentation
- Scope:
  - RN chat fortune runtime
  - RN persisted personal-result reuse
  - RN token/auth preflight
  - Existing edge invocation path reuse

## 2. Search Strategy
- Keywords:
  - `resolveFortuneResultMessage`
  - `fetchEmbeddedEdgeResultPayload`
  - `consumeRemoteTokens`
  - `fortune_results`
  - `fortune_cache`
  - `cohort_fortune_pool`
- Commands:
  - `rg -n "resolveFortuneResultMessage|fetchEmbeddedEdgeResultPayload|consumeRemoteTokens" apps/mobile-rn/src`
  - `rg -n "fortune_results|fortune_cache|cohort_fortune_pool" supabase/migrations supabase/functions lib`
  - `sed -n '1073,1165p' apps/mobile-rn/src/screens/chat-screen.tsx`
  - `sed -n '1,360p' apps/mobile-rn/src/features/chat-results/edge-runtime.ts`

## 3. Similar Code Findings
- Reusable:
  1. `apps/mobile-rn/src/screens/chat-screen.tsx` - current single choke point for fortune result resolution
  2. `apps/mobile-rn/src/features/chat-results/edge-runtime.ts` - shared request-body building and edge invocation
  3. `apps/mobile-rn/src/lib/premium-remote.ts` - authoritative token consume wrapper
  4. `apps/mobile-rn/src/providers/mobile-app-state-provider.tsx` - remote premium/profile resync hook
  5. `supabase/migrations/20250110000001_create_fortune_results_table.sql` - personal result cache schema with `conditions_hash`
- Reference only:
  1. `lib/core/services/fortune_optimization_service.dart` - legacy Flutter optimization order
  2. `supabase/functions/_shared/cohort/index.ts` - cohort reuse remains server-side
  3. `supabase/functions/soul-consume/index.ts` - token billing edge function behavior

## 4. Reuse Decision
- Reuse as-is:
  - `consumeRemoteTokens()`
  - `syncRemoteProfile()`
  - `buildFortuneRequestBody()` flow inside `edge-runtime.ts`
  - existing edge function cohort/cache logic
- Extend existing code:
  - `edge-runtime.ts` to expose prepared invocation details and raw result flow
  - `runtime-capabilities.ts` to add auth-aware gating for remote fortunes
  - `chat-screen.tsx` to route every edge-backed fortune through the new orchestrator
- New code required:
  - RN runtime orchestrator for `auth -> personal cache -> token gate/consume -> edge call -> persist`
- Duplicate prevention notes:
  - Do not create a second request-body mapper outside `edge-runtime.ts`
  - Do not add another per-screen token flow; fortune runtime must share one entry point
  - Do not silently fallback to local hardcoded result cards for edge-backed fortunes

## 5. Planned Changes
- Files to edit:
  1. `apps/mobile-rn/src/features/chat-results/edge-runtime.ts`
  2. `apps/mobile-rn/src/features/chat-results/runtime-capabilities.ts`
  3. `apps/mobile-rn/src/screens/chat-screen.tsx`
  4. `artifacts/runtime/rn-edge-rollout-20260408/INTEGRATION_MATRIX.md`
- Files to create:
  1. `apps/mobile-rn/src/features/chat-results/runtime-orchestrator.ts`
  2. `artifacts/runtime/rn-edge-rollout-20260408/RN_FORTUNE_PREFLIGHT_DISCOVERY_20260408.md`

## 6. Validation Plan
- Static checks:
  - `npm --prefix apps/mobile-rn run typecheck`
  - `flutter analyze`
- Runtime checks:
  - verify unauthenticated edge-backed fortune shows login guidance instead of fake result
  - verify repeated same-day request hits `fortune_results` without another token spend
  - verify token shortage routes user to premium instead of rendering fallback content
- Test cases:
  1. `daily` with logged-in user and existing cached `fortune_results` row
  2. `exam` survey completion with no cached row and successful token consume
  3. edge-backed fortune while signed out
  4. local-only fortune still rendering locally
