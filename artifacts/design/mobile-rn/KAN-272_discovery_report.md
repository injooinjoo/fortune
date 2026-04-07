# KAN-272 Discovery Report

## Goal

- Implement React Native fortune result stack v1 in `apps/mobile-rn`.
- Scope is dark-only `F01` through `F20` plus `/chat` launch and recent-result integration.
- Keep `/fortune`, `/trend`, and `/home` redirect-only in this wave.

## Searches Run

- `rg -n "class .*Screen|export function .*Screen|function .*Screen" apps/mobile-rn/src/screens apps/mobile-rn/src/components -g '*.tsx'`
- `rg -n "extends StateNotifier|class .*Provider|create.*Theme|Card\\(|Chip\\(|PrimaryButton\\(|Screen\\(" apps/mobile-rn/src -g '*.ts' -g '*.tsx'`
- `rg -n "Record<FortuneTypeId|Partial<Record<FortuneTypeId|switch \\(.*fortuneType|fortuneTypesById\\[|type FortuneTypeId" packages/product-contracts apps/mobile-rn -g '*.ts' -g '*.tsx'`
- `rg -n "fortuneBloodType|blood-type|fortuneConstellation|fortuneZodiacAnimal|fortuneDailyCalendar|fortuneCoaching" packages/product-contracts lib apps/mobile-rn .claude/docs -g '*.ts' -g '*.tsx' -g '*.dart' -g '*.md'`
- `rg -n "F0[1-9]|F1[0-9]|F20" artifacts/design/pencil/README.md artifacts/design/pencil/KAN-268_discovery_report.md artifacts/design/pencil/KAN-269_discovery_report.md artifacts/design/pencil/KAN-271_discovery_report.md`

## Files Reviewed

### Reuse Directly

1. `apps/mobile-rn/src/components/screen.tsx`
   - Reuse the existing safe-area + scroll container pattern for result routes.
2. `apps/mobile-rn/src/components/card.tsx`
   - Reuse existing dark card baseline and tokenized border/radius spacing.
3. `apps/mobile-rn/src/components/chip.tsx`
   - Reuse chip tone system for metadata, status, and keyword pills.
4. `apps/mobile-rn/src/components/primary-button.tsx`
   - Reuse existing CTA button baseline for result footer actions.
5. `apps/mobile-rn/src/lib/theme.ts`
   - Reuse the current dark RN theme and navigation theme.

### Reference Pattern

6. `apps/mobile-rn/src/screens/chat-screen.tsx`
   - Reference route launch flow, deep-link pending state consumption, and current chat shell composition.
7. `apps/mobile-rn/src/lib/chat-shell.ts`
   - Reference current `FortuneTypeId` labels and action construction.
8. `apps/mobile-rn/src/lib/mobile-app-state.ts`
   - Reference persisted `lastFortuneType` and chat surface storage boundaries.
9. `apps/mobile-rn/src/providers/mobile-app-state-provider.tsx`
   - Reference `recordChatIntent()` persistence boundary for recent result CTA.
10. `packages/product-contracts/src/fortunes.ts`
    - Reference canonical shared `FortuneTypeId` contract and endpoint mapping.

### Product Truth / Design Truth

11. `docs/getting-started/APP_SURFACES_AND_ROUTES.md`
    - `/chat` is the main surface. Fortune is an internal chat-driven experience.
12. `artifacts/design/pencil/README.md`
    - Current governed Pencil coverage includes dark `F01` through `F20`.
13. `artifacts/design/pencil/KAN-269_discovery_report.md`
    - Use preserved section order and card grammar for `F07` through `F20`.
14. `.claude/docs/paper-artboard-map.md`
    - Use F-number to Paper artboard and Flutter body mapping as the result inventory source.

## Reuse Decision

### Reuse

- Reuse RN presentation primitives: `Screen`, `Card`, `Chip`, `PrimaryButton`, `AppText`.
- Reuse `MobileAppState.chat.lastFortuneType` instead of adding new persisted schema.
- Reuse Expo Router root stack and tab shell.

### Extend

- Extend shared contract with `blood-type` in `packages/product-contracts/src/fortunes.ts`.
- Extend chat shell labels to cover the result kinds used by RN result routing.
- Extend the RN app with a new `src/features/fortune-results/` module and `app/result/[resultKind].tsx`.

### New Code Required

- RN-only `ResultKind` union and `fortuneType -> resultKind` mapper.
- Shared result primitives for Paper-style section cards, metric grids, stat rails, timeline, do/don't pair, bullet list, keyword pills, and footer CTA.
- Dedicated F01-F20 result screens built from shared primitives.
- Recent result CTA card for `/chat`.

## Contract Drift

- `blood-type` exists in Flutter and docs but is missing from `@fortune/product-contracts`.
- `daily-calendar` exists in contracts but is not currently represented in RN chat specialties.
- This wave will fix `blood-type` in the shared contract and keep `daily-calendar` as a valid RN-only result route target.

## Duplicate Prevention

- Do not create a separate in-chat rich result renderer in this wave.
- Do not create new persisted chat schema.
- Do not replace existing `/fortune`, `/trend`, `/home` redirects.
- Keep all new UI under `apps/mobile-rn/src/features/fortune-results/` and chat integration in the existing RN shell.

## Jira

- Issue: `KAN-272`
