# KAN-334 RCA Report

## Symptom
- Some fortune types do not appear under any fortune character in RN chat.
- A subset of those types falls through to non-card fallback behavior because no embedded result mapping exists.

## Why
- Shared contract character specialties were not updated when new fortune types and result kinds were added.
- RN embedded result routing was extended for several result kinds, but local-only card-capable types were left unmapped.

## Where
- Character assignment source:
  - `/Users/jacobmac/Desktop/Dev/fortune/packages/product-contracts/src/characters.ts`
- RN chat routing:
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/chat-screen.tsx`
- RN result kind resolution:
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/features/fortune-results/mapping.ts`

## Where Else
- Flutter already groups related types into shared bodies in:
  - `/Users/jacobmac/Desktop/Dev/fortune/lib/features/character/presentation/widgets/embedded_fortune_component.dart`
- Category hints already exist in:
  - `/Users/jacobmac/Desktop/Dev/fortune/lib/features/chat/domain/constants/chip_category_map.dart`

## Fix Strategy
- Add missing real fortune types to existing shared character specialties.
- Map local embedded-card-capable types to existing RN result kinds.
- Override card labels/copy so shared result kinds still read correctly for the absorbed fortune types.

