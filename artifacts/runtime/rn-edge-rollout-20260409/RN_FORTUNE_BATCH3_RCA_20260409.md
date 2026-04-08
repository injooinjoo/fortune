# RN Fortune Batch 3 RCA

Date: 2026-04-09
Target: `apps/mobile-rn`

## Symptom

Several RN fortunes were already calling real edge functions, but the resulting cards still looked generic, over-flattened, or visually inconsistent with the underlying payload.

## Why

1. `adapter.ts` had explicit extraction for only part of the fortune surface.
2. `embedded-result-card.tsx` rendered almost everything as metric grids, bullet lists, and pills.
3. Existing UI primitives for numeric comparison and paired actions were not connected to the embedded result payload.

## Where

- `apps/mobile-rn/src/features/chat-results/adapter.ts`
- `apps/mobile-rn/src/features/chat-results/embedded-result-card.tsx`
- `apps/mobile-rn/src/features/chat-results/types.ts`

## Where Else

- `zodiac` used daily-like payloads without daily-like rendering.
- `zodiac-animal`, `constellation`, `birthstone`, `biorhythm`, `game-enhance` exposed edge-native structure that the card did not honor.

## Fix Strategy

- Reuse the existing primitives instead of introducing a new card system.
- Add minimal payload extensions.
- Promote the remaining edge-backed fortunes from generic flatten to fortune-specific extraction where the payload shape clearly supports it.
