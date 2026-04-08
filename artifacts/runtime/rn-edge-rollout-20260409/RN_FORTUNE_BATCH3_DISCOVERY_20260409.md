# RN Fortune Batch 3 Discovery

Date: 2026-04-09
Target: `apps/mobile-rn`

## Scope

- Continue the RN edge rollout after commit `1bdcd51d`
- Focus on fortunes that were technically edge-backed but still rendered through generic flatten paths
- Improve embedded result readability without changing the overall chat-card architecture

## Findings

1. `zodiac` still consumed `/fortune-daily` output through non-daily code paths.
   - Request side was already wired.
   - Display side missed `daily`-style summary, metrics, warnings, lucky items, and timeline extraction.

2. `zodiac-animal`, `constellation`, `birthstone`, `biorhythm`, and `game-enhance` had real edge payloads but weak presentation.
   - Most of them fell back to generic text flattening.
   - Their native structures were better suited for score rails or structured detail sections.

3. `embedded-result-card` still underused existing RN result primitives.
   - `StatRail` and `DoDontPair` already existed in `fortune-results/primitives.tsx`.
   - The chat card did not consume them, even when edge payloads had strong numeric or paired recommendation/warning structure.

4. Long `luckyItems` phrases still rendered as pills.
   - This made some real edge payloads harder to scan than necessary.

## Decision

- Keep the existing embedded result card architecture.
- Extend the payload shape minimally with:
  - `scoreRails`
  - `actionPair`
- Add targeted extraction for the remaining high-signal fortune groups instead of redesigning the whole card system.

## Files To Touch

- `apps/mobile-rn/src/features/chat-results/adapter.ts`
- `apps/mobile-rn/src/features/chat-results/embedded-result-card.tsx`
- `apps/mobile-rn/src/features/chat-results/types.ts`
- `artifacts/design/pencil/RN_EDGE_RESULT_CARD_GUIDE_20260408.md`
- `artifacts/runtime/rn-edge-rollout-20260408/INTEGRATION_MATRIX.md`
