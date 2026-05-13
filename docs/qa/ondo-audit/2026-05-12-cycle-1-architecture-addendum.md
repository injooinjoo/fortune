# Ondo Audit Cycle 1 Addendum — Architecture / Duplication / Optimization

Date: 2026-05-12 KST
Mode: read-only structural scan
Repo: `/Users/injoo/Desktop/Dev/fortune`

## Why this addendum exists
User clarified that the continuous loop must also catch structural variables such as:
- the same code written many times;
- logic that should be centralized but is implemented separately;
- code that cannot be changed once in one place;
- app optimization, realistic efficient structure, and performance quality.

The `paperclip-ondo-fortune` continuous audit skill was updated to include an explicit **Architecture / duplication / optimization audit** phase.

## Current repo state observed

```text
## master...origin/master [ahead 1]
?? docs/qa/ondo-audit/
```

The untracked `docs/qa/ondo-audit/` files are audit artifacts from this session.

## Structural scan summary

Static scan target: TypeScript/TSX/JS/JSX files excluding common dependency/build folders.

- Scanned files: 661
- Largest active files found:
  - `apps/mobile-rn/src/screens/chat-screen.tsx` — 4,685 lines
  - `supabase/functions/character-chat/index.ts` — 3,897 lines
  - `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx` — 3,386 lines
  - `supabase/functions/fortune-past-life/index.ts` — 3,012 lines
  - `apps/mobile-rn/src/features/fortune-results/screens/batch-e.tsx` — 2,372 lines
  - `supabase/functions/fortune-daily/index.ts` — 1,976 lines
  - `apps/mobile-rn/src/features/chat-survey/registry.ts` — 1,859 lines
  - `apps/mobile-rn/src/lib/story-chat-runtime.ts` — 1,463 lines
  - `apps/mobile-rn/src/providers/mobile-app-state-provider.tsx` — 1,069 lines
  - `supabase/functions/payment-verify-purchase/index.ts` — 977 lines

## P1 structural findings

### P1-ARCH-1. `chat-screen.tsx` is too large and owns too many responsibilities
Evidence:
- `apps/mobile-rn/src/screens/chat-screen.tsx` is 4,685 lines.
- Cycle 1 findings already showed this file contains billing/order logic, survey completion, result generation, async poster job orchestration, navigation, premium/cost sheet integration, chat rendering, and multiple runtime side effects.

Impact:
- A change to billing or result generation can accidentally affect chat UI, survey, scroll behavior, navigation, or progress cards.
- Button/UX bugs become harder to isolate.
- Performance optimization becomes harder because state and callbacks are concentrated in one screen.

Recommended direction:
- Split by responsibility, not by arbitrary component size:
  1. `useFortuneRequestFlow` — survey completion, cost confirmation, billing preflight/reservation.
  2. `useAsyncPosterFlow` — poster queue, cancellation, progress card lifecycle.
  3. `useChatNavigationActions` — result/premium/signup/profile routes.
  4. `ChatScreenView` — presentational composition only.
- Do not refactor all at once. Start with the P1 bug-prone flows already found: billing-before-result and async-poster queue-before-charge.

### P1-ARCH-2. `character-chat` Edge Function is a high-risk monolith
Evidence:
- `supabase/functions/character-chat/index.ts` is 3,897 lines.
- It is known to contain character chat runtime, scheduling, LLM invocation, prompt/context assembly, persistence, usage logging, push/notification behavior, and no-reply sensitive paths.

Impact:
- No-reply bugs, scheduled reply bugs, push/list/room consistency, and billing/usage logging can regress each other.
- Edge redeploy blast radius is too large: a minor prompt or scheduling fix can redeploy the entire function.

Recommended direction:
- Extract internal modules under the function directory or `_shared` where safe:
  - request validation/auth
  - canonical message persistence
  - LLM prompt/context builder
  - scheduling policy
  - usage logging/billing policy
  - push payload construction
- Keep public function name stable; avoid creating versioned/new Edge Functions.

### P1-ARCH-3. Result hero components repeat local animation/math helpers across many files
Evidence:
- Duplicate helper/function names found across many hero files:
  - `clamp01` appears in 35+ hero/primitives files.
  - `stage`, `easeOut`, `tween` appear across many hero files.
- Affected folder pattern:
  - `apps/mobile-rn/src/features/fortune-results/heroes/hero-*.tsx`
  - `apps/mobile-rn/src/features/fortune-results/primitives/*`

Impact:
- Animation timing/easing/reveal policy cannot be changed once in one place.
- Visual polish/performance tuning requires touching many files.
- Inconsistent behavior becomes likely across result types.

Recommended direction:
- Introduce/expand shared primitives:
  - `fortune-results/primitives/animation.ts`
  - `clamp01`, `easeOut`, `tween`, `stage`, common reveal progress helpers.
- Move one hero family first and run visual regression/simulator checks before broad migration.

### P1-ARCH-4. Long-running/poster job processing logic is duplicated
Evidence from duplicate 8-line code chunks:
- `supabase/functions/process-poster-jobs/index.ts` duplicated with `supabase/functions/process-long-running-jobs/index.ts` around multiple ranges including approximate lines 259+, 292+, 334+, 361+.
- Shared startup/CORS/handler chunks also overlap with `supabase/functions/start-poster-job/index.ts` around lines 39–50.

Impact:
- Cancellation, billing, retry, error-state, and status semantics can drift between poster jobs and long-running text jobs.
- Fixing one queue pipeline may leave the other with the same bug.

Recommended direction:
- Extract queue/job lifecycle primitives into `_shared`:
  - claim job
  - mark processing/done/failed/cancelled
  - billing preflight/reservation check
  - retry/backoff policy
  - error normalization
- Keep job-specific render/generation handlers separate.

### P1-ARCH-5. Fortune type/source-of-truth is still too spread out
Evidence from repeated literal scan:
- Fortune type strings such as `palm-reading`, `beauty-simulation`, `blind-date-guide`, `face-reading-guide`, `personality-dna`, `yearly-encounter`, `ootd-evaluation`, etc. appear across many files including:
  - `apps/mobile-rn/src/features/chat-results/edge-runtime.ts`
  - `apps/mobile-rn/src/features/chat-results/fixtures.ts`
  - `apps/mobile-rn/src/features/chat-survey/registry.ts`
  - `apps/mobile-rn/src/features/fortune-results/mapping.ts`
  - `apps/mobile-rn/src/features/fortune-results/registry.tsx`
  - `apps/mobile-rn/src/features/haneul/all-fortunes-sheet.tsx`
  - `apps/mobile-rn/src/features/haneul/haneul-quick-actions.tsx`
  - `apps/mobile-rn/src/lib/chat-shell.ts`
  - `packages/product-contracts/src/fortune-catalog.ts`
  - `packages/product-contracts/src/fortune-pricing.ts`
  - `packages/product-contracts/src/fortunes.ts`
  - `supabase/functions/_shared/fortune-pricing-generated.ts`
  - function-specific Edge files.

Impact:
- Adding/renaming/changing one fortune requires many edits.
- Existing Cycle 1 bug class — result card payload/mapping/billing drift — is more likely when the registry is distributed.

Recommended direction:
- Define one canonical contract in `packages/product-contracts`:
  - fortune id
  - price tier
  - survey schema id
  - result kind
  - edge function/handler
  - renderer/hero id
  - async vs immediate mode
- Generate mobile and Edge lookup tables from it.
- Add a contract test that fails if any fortune id is missing in survey, result mapping, pricing, or Edge runtime.

## P2 structural findings

### P2-ARCH-1. Design/artifact duplicate files are inside the repository scan surface
Evidence:
- Exact duplicate file groups include many `Ondo Design System/...` duplicate pairs such as:
  - `Ondo Design System/ui_kits/mobile/ios-frame.jsx`
  - `Ondo Design System/project/ui_kits/mobile/ios-frame.jsx`
  - `Ondo Design System/project/story_chat/ios-frame.jsx`
  - `Ondo Design System/project/fortune_results/ios-frame.jsx`
- Exact duplicate groups also include `artifacts/ios-review-fixes/new-files/...` matching active files under `apps/mobile-rn/src` or `supabase/functions`.

Impact:
- Static audits, duplicate scans, and search results are noisy.
- Future agents may edit artifact/design copies instead of active source files.
- Build/test configs must ensure these folders never enter production bundles.

Recommended direction:
- Explicitly mark design/artifact folders as non-source in repo docs and audit scripts.
- Consider moving design snapshots outside active repo or into `docs/design-artifacts/` with clear README.
- Ensure TypeScript/Metro/Expo/Supabase build configs exclude these artifacts.

### P2-ARCH-2. CORS/header boilerplate still appears across many Edge Functions
Evidence:
- Repeated string `Access-Control-Allow-Methods` appears in many function files even though `_shared/cors.ts` exists.
- Repeated imports of `../_shared/cors.ts` are expected, but any local CORS object duplication should be reduced.

Impact:
- Header/security changes can drift across functions.

Recommended direction:
- Enforce `_shared/cors.ts` usage and add grep/audit check blocking local CORS header objects in new functions.

### P2-ARCH-3. Screen-level imports and primitives indicate repeated UI shell patterns
Evidence:
- Many screens import the same local primitives:
  - `../components/app-text`
  - `../components/screen`
  - `../lib/theme`
- This is not a bug by itself, but combined with large screen files suggests repeated screen scaffolding.

Impact:
- Button/loading/error/accessibility patterns drift.

Recommended direction:
- Create a small set of screen-level templates/primitives:
  - `ScreenHeaderAction`
  - `AsyncPrimaryButton`
  - `StoreUnavailableCTA`
  - `PolicyLinkRow`
  - `SelectableProductCard` with accessibility state.

## Optimization target model

The goal should not be “refactor everything.” The realistic target is:

1. **One source of truth for business rules**
   - pricing, product IDs, fortune IDs, async/immediate mode, result mapping.

2. **One reusable flow for paid AI execution**
   - confirm cost → reserve/charge → execute/generate/queue → commit/refund → render.

3. **One reusable job lifecycle**
   - poster jobs and long-running text jobs should share state transitions and cancellation semantics.

4. **Small screen files, fat domain/runtime modules**
   - screens compose hooks/components; they should not own billing/job/network policy.

5. **Shared UI primitives for buttons and error states**
   - every button should have consistent loading, disabled, duplicate-tap, accessibility, haptic, and failure behavior.

## Proposed next fix/refactor batches

### Structural Batch 1 — highest ROI, low visual risk
- Add shared hero animation helpers and migrate 2–3 hero components first.
- Add contract tests for fortune id coverage across pricing/mapping/registry/survey.
- Add audit script to flag duplicate fortune IDs or missing mappings.

### Structural Batch 2 — billing/job correctness
- Extract paid fortune execution flow from `chat-screen.tsx`.
- Introduce reserve/charge-before-generate semantics.
- Extract shared poster/long-running job lifecycle helpers.

### Structural Batch 3 — screen/button consistency
- Add `AsyncPrimaryButton` / `SelectableCard` / `UnavailableActionCTA` primitives.
- Apply first to Premium and Signup because Cycle 1 found button issues there.

### Structural Batch 4 — source tree hygiene
- Classify `Ondo Design System` and `artifacts` folders.
- Add explicit ignore/exclusion guidance for audits/build/test.
- Avoid editing duplicated artifact copies as active source.

## Added to future cycle checklist
Every audit cycle should now include:
- largest-file review;
- duplicate helper scan;
- repeated business constant/route/product/fortune-id scan;
- artifact/design duplicate noise check;
- source-of-truth drift check;
- performance/refactor opportunities ranked by change-cost reduction.
