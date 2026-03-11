# Fortune Screen And Component Registry

## Reference

- Official file: [Fortune Screen Catalog - Official](https://www.figma.com/design/dkx3Biwe5xkiMQWsjq95LA)
- Figma file key: `dkx3Biwe5xkiMQWsjq95LA`
- Device standard: `iPhone 15 Pro 393x852 @3x`
- Capture manifest: `playwright/scripts/figma_capture_manifest.js`
- Layer naming contract: `docs/design/FIGMA_LAYER_NAMING_STANDARD.md`
- Sync changelog: `docs/design/FIGMA_SYNC_CHANGELOG.md`

## Coverage Summary

| Figma page | Total | Live | Placeholder |
| --- | ---: | ---: | ---: |
| `10 Entry / Auth / Onboarding` | 4 | 4 | 0 |
| `20 Chat / Character` | 4 | 3 | 1 |
| `80 Admin / Policy / Utility` | 4 | 3 | 1 |

Additional official pages:

- `00 Cover & Governance`
- `90 Components`
- `99 Archive`

## Placeholder Triage

| Triage | Count |
| --- | ---: |
| `capture_next_auth` | 1 |
| `capture_next_runtime` | 1 |

## Screen Catalog

### 10 Entry / Auth / Onboarding

- `auth__splash__default` | `#/splash` | `live`
- `auth__signup__default` | `#/signup` | `live`
- `onboarding__profile__default` | `#/onboarding` | `live`
- `onboarding__toss_style__default` | `#/onboarding/toss-style` | `live`

### 20 Chat / Character

- `chat__home__default` | `#/chat` | `live`
- `chat__character__luts` | `#/chat?openCharacterChat=true&characterId=luts` | `live`
- `character__profile__luts` | `#/character/luts` | `live`
- `chat__profile_sheet__default` | bottom-sheet runtime state | `placeholder`

### 80 Admin / Policy / Utility

- `policy__privacy__default` | `#/privacy-policy` | `live`
- `policy__terms__default` | `#/terms-of-service` | `live`
- `account__deletion__auth_gated` | `#/account-deletion` | `placeholder`
- `utility__manseryeok__default` | `#/manseryeok` | `live`

## Component Inventory

### Chat Shell and Headers

- `lib/features/character/presentation/pages/swipe_home_shell.dart`
- `lib/features/character/presentation/pages/character_list_panel.dart`
- `lib/shared/components/app_header.dart`

### Conversation Blocks

- `lib/features/character/presentation/widgets/character_message_bubble.dart`
- `lib/features/chat/presentation/widgets/chat_saju_result_card.dart`
- `lib/shared/components/section_header.dart`

### Account and Policy Controls

- `lib/features/chat/presentation/widgets/profile_bottom_sheet.dart`
- `lib/screens/profile/account_deletion_page.dart`
- `lib/shared/components/settings_list_tile.dart`

### Design System Core

- `lib/core/design_system/components/ds_card.dart`
- `lib/core/design_system/components/ds_button.dart`
- `lib/core/design_system/components/ds_text_field.dart`
- `lib/core/widgets/unified_button.dart`

## Removed Page Groups

The following former catalog groups are no longer part of the active registry and should be deleted manually from the official file:

- `35:2` `30 Fortune Hub / Interactive`
- `36:2` `40 Trend`
- `37:2` `50 Health / Exercise`
- `38:2` `60 History / Profile / More`
- `39:2` `70 Commerce / Settings / Support`
- `40:2` `75 Wellness`
