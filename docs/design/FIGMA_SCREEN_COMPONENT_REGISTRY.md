# Fortune Screen And Component Registry

## Reference

- Official file: [Fortune Screen Catalog - Official](https://www.figma.com/design/dkx3Biwe5xkiMQWsjq95LA)
- Figma file key: `dkx3Biwe5xkiMQWsjq95LA`
- Device standard: `iPhone 15 Pro 393x852 @3x`
- Capture manifest: `playwright/scripts/figma_capture_manifest.js`
- Layer naming contract: `docs/design/FIGMA_LAYER_NAMING_STANDARD.md`
- Detailed screen mapping: `docs/design/FIGMA_SCREEN_ROUTE_MAPPING.md`
- Sync changelog: `docs/design/FIGMA_SYNC_CHANGELOG.md`

## Canonical Current Page Roots

- `64:2` `00 Cover & Governance`
- `65:2` `10 Entry / Auth / Onboarding`
- `66:2` `20 Chat Home / Character`
- `67:2` `80 Admin / Policy / Utility`
- `68:2` `90 Components`
- `69:2` `99 Archive`

## Coverage Summary

| Figma page | Total | Live | Placeholder |
| --- | ---: | ---: | ---: |
| `10 Entry / Auth / Onboarding` | 4 | 4 | 0 |
| `20 Chat Home / Character` | 9 | 3 | 6 |
| `80 Admin / Policy / Utility` | 4 | 2 | 2 |

Additional official pages:

- `00 Cover & Governance`
- `90 Components`
- `99 Archive`

## Placeholder Triage

| Triage | Count |
| --- | ---: |
| `capture_next_auth` | 1 |
| `capture_next_runtime` | 7 |

## Screen Catalog

### 10 Entry / Auth / Onboarding

- `auth__splash__default` | `#/splash` | `live`
- `auth__signup__default` | `#/signup` | `live`
- `onboarding__profile__default` | `#/onboarding` | `live`
- `onboarding__toss_style__default` | `#/onboarding/toss-style` | `live`

### 20 Chat Home / Character

- `chat__home__default` | `#/chat` | `live`
- `chat__home__general_default` | `#/chat` | `placeholder`
- `chat__home__curiosity_default` | `#/chat` | `placeholder`
- `chat__character__luts` | `#/chat?openCharacterChat=true&characterId=luts` | `live`
- `chat__survey__fortune_step` | `#/chat?fortuneType=daily` | `placeholder`
- `chat__result__fortune_complete` | `#/chat?fortuneType=daily` | `placeholder`
- `character__profile__luts` | `#/character/luts` | `live`
- `chat__onboarding__character_intro` | `#/chat` | `placeholder`
- `chat__profile_sheet__default` | bottom-sheet runtime state | `placeholder`

### 80 Admin / Policy / Utility

- `premium__insight__default` | `#/premium` | `placeholder`
- `policy__privacy__default` | `#/privacy-policy` | `live`
- `policy__terms__default` | `#/terms-of-service` | `live`
- `account__deletion__auth_gated` | `#/account-deletion` | `placeholder`

## Component Inventory

### Chat Shell and Headers

- `lib/features/character/presentation/pages/swipe_home_shell.dart`
- `lib/features/character/presentation/pages/character_list_panel.dart`
- `lib/shared/components/app_header.dart`

### Character Entry and Onboarding

- `lib/features/character/presentation/pages/swipe_home_shell.dart`
- `lib/features/character/presentation/pages/character_onboarding_page.dart`
- `lib/services/storage_service.dart`

### Conversation, Survey, and Result Blocks

- `lib/features/character/presentation/pages/character_chat_panel.dart`
- `lib/features/character/presentation/widgets/character_message_bubble.dart`
- `lib/features/chat/presentation/widgets/survey/chat_survey_chips.dart`
- `lib/features/chat/presentation/widgets/chat_saju_result_card.dart`
- `lib/features/character/presentation/widgets/embedded_fortune_component.dart`
- `lib/shared/components/section_header.dart`

### Account, Premium, and Policy Controls

- `lib/features/chat/presentation/widgets/profile_bottom_sheet.dart`
- `lib/screens/premium/premium_screen.dart`
- `lib/screens/profile/account_deletion_page.dart`
- `lib/shared/components/settings_list_tile.dart`

### Design System Core

- `lib/core/design_system/components/ds_card.dart`
- `lib/core/design_system/components/ds_button.dart`
- `lib/core/design_system/components/ds_text_field.dart`
- `lib/core/widgets/unified_button.dart`

## Manual Delete Targets In The Official File

Delete the following stale page roots manually in Figma:

- `32:2` `00 Cover & Governance`
- `33:2` `10 Entry / Auth / Onboarding`
- `34:2` `20 Chat Home / Character`
- `38:2` `60 History / Profile / More`
- `39:2` `70 Commerce / Settings / Support`
- `42:2` `90 Components`
- `43:2` `99 Archive`
- `60:2` `30 Fortune Hub / Interactive`
- `61:2` `40 Trend`
- `62:2` `50 Health / Exercise`
- `63:2` `60 History / Profile / More`

Historical references to `35:2`, `36:2`, `37:2`, `40:2`, and `41:2` are stale and should be ignored.
