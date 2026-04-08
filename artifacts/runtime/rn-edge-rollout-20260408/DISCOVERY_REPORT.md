# RN Fortune Edge Rollout Discovery

Date: 2026-04-08
Scope: React Native chat fortune results and result routing
Jira: Blocked. `mcp__jira__getAccessibleAtlassianResources` succeeded, but project access failed with `Tenant is restricted: suspended-inactivity`.

## Goal

Make RN fortune results behave like `하늘 > 오늘 운세` wherever a real edge function exists:

- invoke edge through RN runtime
- align survey/request schema with edge requirements
- adapt edge payloads into the embedded chat result card
- keep result metadata / design references synchronized

## Source Of Truth

- `packages/product-contracts/src/fortunes.ts`
- `packages/product-contracts/src/characters.ts`
- `packages/product-contracts/src/fortune-result-normalizer.ts`
- `apps/mobile-rn/src/features/chat-survey/registry.ts`
- `apps/mobile-rn/src/features/chat-results/edge-runtime.ts`
- `apps/mobile-rn/src/features/chat-results/adapter.ts`
- `apps/mobile-rn/src/features/fortune-results/mapping.ts`
- `.claude/docs/25-fortune-result-schemas.md`
- `lib/features/chat/domain/configs/survey_configs.dart`

## Inventory Summary

### Edge-backed and already viable in RN

- `daily`
- `daily-calendar`
- `new-year`
- `traditional-saju`
- `love`
- `compatibility`
- `blind-date`
- `avoid-people`
- `yearly-encounter`
- `career`
- `lucky-items`
- `game-enhance`
- `exercise`
- `dream`
- `family`
- `naming`
- `exam`
- `biorhythm`
- `wish`
- `talisman`
- `zodiac`
- `zodiac-animal`
- `constellation`
- `birthstone`

### Edge-backed but schema/body is weak or partial today

- `mbti`
- `blood-type`
- `personality-dna`
- `ex-lover`
- `wealth`
- `talent`
- `health`
- `tarot`

### Edge-backed but RN survey/runtime is missing

- `moving`
- `decision`
- `celebrity`
- `pet-compatibility`
- `match-insight`

### Edge-backed but blocked by missing RN input type

- `face-reading` (`imageUrl` / `imageBase64` / Instagram-style image source required)
- `past-life` (photo input required for portrait flow)
- `ootd-evaluation` (photo input expected for intended quality)

### Local-only or non-edge utility

- `fortune-cookie`
- `breathing`
- `daily-review`
- `weekly-review`
- `chat-insight`
- `coaching`
- `view-all`
- `profile-creation`

### Contract inconsistencies

- `decision`: edge function and schema exist, but contract still marks `isLocalOnly: true`
- `wish`: edge endpoint exists (`/analyze-wish`), but contract still marks `isLocalOnly: true`
- `lotto`: contract points to `/fortune-lucky-lottery`, but no matching edge function exists in `supabase/functions`

## Current RN Drift

### Survey alias drift

- `face-reading -> traditional-saju`
- `celebrity -> love`
- `lotto -> wealth`
- `pet-compatibility -> family`

### Result-kind collapse drift

- `celebrity -> love`
- `moving -> past-life`
- `talisman -> past-life`
- `breathing -> health`
- `chat-insight -> coaching`
- `weekly-review -> daily-review`
- `lucky-items -> wealth`
- `lotto -> wealth`
- `dream -> tarot`
- `pet-compatibility -> family`
- `match-insight -> exercise`

### Request-body gaps

- `health`: missing `sleepQuality`, `exerciseFrequency`, `mealRegularity`
- `wealth`: missing `income`, `expense`, `risk`, `urgency`
- `talent`: missing `problemSolving`, `experience`, `timeAvailable`
- `ex-lover`: only core fields forwarded, extended reconciliation/healing inputs not forwarded
- `personality-dna`: currently lacks `zodiacAnimal`
- `mbti`: can produce a weak request if profile MBTI/name are absent
- `blood-type`: incorrectly gated by `birthDate`, though edge primarily needs `bloodType`

## Design / Result Surface Notes

- Chat-embedded result card is the real runtime surface for RN fortune completion.
- Full result route exists, but `apps/mobile-rn/app/result/[resultKind].tsx` still renders static registered shells instead of live edge payload.
- `apps/mobile-rn/src/features/fortune-results/mapping.ts` already tracks `paperNodeId` for all current result kinds.
- Repo-side `pencil` file is currently a schema/router review board, not a dedicated fortune result UI source of truth.

## Batch 1 Implementation Plan

Implement the largest edge-backed subset without introducing new RN input primitives:

1. Add direct RN surveys for:
   - `moving`
   - `decision`
   - `celebrity`
   - `pet-compatibility`
   - `match-insight`
2. Expand existing RN surveys for:
   - `wealth`
   - `talent`
   - `health`
   - `personality-dna`
3. Fix request-body generation in `edge-runtime.ts`
4. Improve adapter parsing for:
   - `moving`
   - `decision`
   - `celebrity`
   - `pet-compatibility`
   - `match-insight`
   - plus richer generic detail sections for shared cards
5. Leave image-required fortunes for Batch 2:
   - `face-reading`
   - `past-life`
   - `ootd-evaluation`

## Expected Outcome After Batch 1

- More RN fortunes complete through real edge functions instead of local fallback
- Fewer aliased surveys
- Richer embedded result cards from edge payloads
- Clear boundary for remaining image-input work
