# KAN-333 Discovery Report

## Scope
- React Native chat fortune runtime in `apps/mobile-rn`
- Contract endpoint/source-of-truth in `packages/product-contracts`
- Flutter runtime parity references in `lib/`
- Live iOS simulator verification on April 8, 2026

## Similar Code Search
- Fortune type registry and endpoint resolution:
  - `packages/product-contracts/src/fortunes.ts`
  - `lib/core/fortune/fortune_type_registry.dart`
- RN chat runtime:
  - `apps/mobile-rn/src/screens/chat-screen.tsx`
  - `apps/mobile-rn/src/lib/chat-shell.ts`
  - `apps/mobile-rn/src/features/chat-survey/registry.ts`
  - `apps/mobile-rn/src/features/chat-results/adapter.ts`
  - `apps/mobile-rn/src/features/chat-results/fixtures.ts`
- RN result pages:
  - `apps/mobile-rn/app/result/[resultKind].tsx`
  - `apps/mobile-rn/src/features/fortune-results/registry.tsx`
  - `apps/mobile-rn/src/features/fortune-results/screens/`
- Flutter reference path:
  - `lib/core/services/generator_factory.dart`
  - `lib/core/services/fortune_generators/*.dart`
  - `lib/features/character/presentation/providers/character_fortune_adapter.dart`

## Current State
- RN main fortune flow is chat-first and character-first.
- Survey completion currently generates local embedded result fixtures instead of calling edge functions.
- Full-page result screens exist, but they render static `resultKind` shells and do not consume runtime payloads.
- Survey aliasing and result aliasing are both active and inconsistent with each other.

## Live Verification
- App launched on booted iPhone 17 simulator.
- `com.beyond.fortune://?debugChatGate=ready` unlocked the chat surface.
- `com.beyond.fortune://?screen=chat&fortuneType=exam` auto-opened James Kim.
- Completing the `exam` chat flow showed a generic embedded card built from local fixtures.
- Direct `/result/exam` route rendered a dedicated static exam page.

## Reuse vs Extend vs New
- Reuse:
  - `resolveFortuneEndpoint`, `fortuneTypesById`, and `normalizeFortuneResult` from `@fortune/product-contracts`
  - Existing embedded result UI in `apps/mobile-rn/src/features/chat-results/embedded-result-card.tsx`
  - Existing survey UI and message shell in `apps/mobile-rn/src/screens/chat-screen.tsx`
- Extend:
  - `chat-survey/registry.ts` to add direct surveys for high-drift fortunes
  - `chat-results/adapter.ts` to support real edge payload adaptation
  - `chat-screen.tsx` to invoke edge functions on survey completion
- New:
  - A dedicated RN edge runtime helper for fortune invocation and payload adaptation

## Decision
- Extend existing RN chat runtime rather than create a separate feature surface.
- Keep the current embedded card UI, but feed it normalized edge payloads.
- Fix contract endpoint drift where RN depends on contract endpoint resolution.
