# KAN-334 Discovery Report

## Goal
- Find fortune types that do not surface inside RN chat bubble cards.
- Reassign uncovered fortunes to existing fortune-view characters.
- Align shared character specialties with RN embedded result routing.

## Files Inspected
- `/Users/jacobmac/Desktop/Dev/fortune/packages/product-contracts/src/fortunes.ts`
- `/Users/jacobmac/Desktop/Dev/fortune/packages/product-contracts/src/characters.ts`
- `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/lib/chat-characters.ts`
- `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/chat-screen.tsx`
- `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/features/fortune-results/mapping.ts`
- `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/features/chat-results/fixtures.ts`
- `/Users/jacobmac/Desktop/Dev/fortune/lib/features/character/presentation/widgets/embedded_fortune_component.dart`
- `/Users/jacobmac/Desktop/Dev/fortune/lib/features/chat/domain/constants/chip_category_map.dart`

## Findings
- RN fortune characters are imported directly from shared contract `fortuneCharacters`.
- Any type missing from shared `fortuneCharacters.specialties` is absent from:
  - highlighted expert selection
  - fortune character quick actions
  - recent result reopen expert resolution
- Several uncovered types already have RN resultKind mappings, so they are renderable but undiscoverable from the character surface.
- Three uncovered local types are not mapped to any RN resultKind:
  - `breathing`
  - `weekly-review`
  - `chat-insight`

## Missing Character Assignments
- `daily-calendar`
- `blood-type`
- `health`
- `constellation`
- `breathing`
- `daily-review`
- `weekly-review`
- `chat-insight`
- `coaching`
- `decision`

## Reuse Decisions
- Reuse shared character source of truth:
  - `/Users/jacobmac/Desktop/Dev/fortune/packages/product-contracts/src/characters.ts`
- Reuse existing RN embedded result kinds instead of introducing new screens:
  - `health` for `breathing`
  - `coaching` for `chat-insight`
  - `daily-review` for `weekly-review`
- Reuse existing embedded card fixtures with type-specific copy overrides.

## Character Allocation Plan
- `fortune_haneul`: `daily-calendar`
- `fortune_muhyeon`: `blood-type`
- `fortune_stella`: `constellation`
- `fortune_dr_mind`: `coaching`, `decision`, `daily-review`, `weekly-review`, `chat-insight`
- `fortune_marco`: `health`, `breathing`

## Explicit Non-Fortune Exclusions
- `view-all`
- `profile-creation`

