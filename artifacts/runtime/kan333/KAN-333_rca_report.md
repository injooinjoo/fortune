# KAN-333 RCA Report

## Symptom
- RN fortune chips are visible and interactive, but the main chat flow does not produce schema-backed edge results.
- Some fortunes ask the wrong questions in live runtime.
- Full-page result screens are disconnected from actual runtime data.

## WHY
- `chat-screen.tsx` completes surveys by building local embedded result fixtures instead of invoking edge functions.
- `chat-survey/registry.ts` collapses multiple fortune types into alias surveys, causing type-specific input loss.
- `fortune-results/mapping.ts` collapses multiple fortune types into shared `resultKind` buckets, causing schema loss on the rendering side.
- `packages/product-contracts/src/fortunes.ts` contains endpoint drift vs Flutter runtime for several fortune types.

## WHERE
- Chat runtime:
  - `apps/mobile-rn/src/screens/chat-screen.tsx`
  - `apps/mobile-rn/src/lib/chat-shell.ts`
- Survey aliasing:
  - `apps/mobile-rn/src/features/chat-survey/registry.ts`
- Fixture-based card generation:
  - `apps/mobile-rn/src/features/chat-results/adapter.ts`
  - `apps/mobile-rn/src/features/chat-results/fixtures.ts`
- Contract drift:
  - `packages/product-contracts/src/fortunes.ts`

## WHERE ELSE
- Flutter runtime already carries separate endpoint resolution and per-type payload handling:
  - `lib/core/fortune/fortune_type_registry.dart`
  - `lib/core/services/generator_factory.dart`
  - `lib/features/character/presentation/providers/character_fortune_adapter.dart`
- RN full-page result layer is also static:
  - `apps/mobile-rn/app/result/[resultKind].tsx`
  - `apps/mobile-rn/src/features/fortune-results/registry.tsx`

## HOW
- Fix contract endpoint mappings RN depends on.
- Add an RN fortune edge runtime that:
  - resolves endpoint from contracts
  - builds a request body from survey answers and profile context
  - invokes the edge function via Supabase
  - normalizes the response
  - adapts normalized/raw payload into the existing embedded result card schema
- Split the highest-risk alias survey types into their own RN surveys where current live behavior is clearly wrong.

## Initial Fix Scope
- Contract endpoint parity for `personality-dna`, `zodiac-animal`, `constellation`, and `birthstone`
- Edge-backed embedded results in RN chat
- Direct RN surveys for at least `exam`, `new-year`, `naming`, `avoid-people`, `lucky-items`, and `biorhythm`
- Safe fallback to local fixture payloads when a type is still unsupported or an edge call fails
