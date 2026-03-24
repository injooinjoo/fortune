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

- `89:2` `00 Cover & Governance`
- `90:2` `10 Entry / Auth / Onboarding`
- `91:2` `20 Chat Home / Character`
- `92:2` `80 Admin / Policy / Utility`
- `93:2` `90 Components`
- `94:2` `99 Archive`

Latest official rich mystical chat append:

- `181:2` `20 Chat Home / Character`

Historical chat append retained in file:

- `180:2` `20 Chat Home / Character`
- `95:2` `20 Chat Home / Character`

## Coverage Summary

| Figma page | Total | Live | Placeholder |
| --- | ---: | ---: | ---: |
| `10 Entry / Auth / Onboarding` | 5 | 3 | 2 |
| `20 Chat Home / Character` | 8 | 8 | 0 |
| `80 Admin / Policy / Utility` | 5 | 4 | 1 |

Additional official pages:

- `00 Cover & Governance`
- `90 Components`
- `99 Archive`

## Placeholder Triage

| Triage | Count |
| --- | ---: |
| `capture_next_auth` | 1 |
| `capture_next_runtime` | 1 |
| `capture_next_state_extra` | 1 |

## Screen Catalog

### 10 Entry / Auth / Onboarding

- `auth__splash__default` | `#/splash` | `placeholder`
- `auth__signup__default` | `#/signup` | `live`
- `auth__callback__redirected` | `#/auth/callback` | `placeholder`
- `onboarding__profile__default` | `#/onboarding` | `live`
- `onboarding__toss_style__default` | `#/onboarding/toss-style` | `live`

### 20 Chat Home / Character

- `chat__home__default` | `#/chat` | `live`
- `chat__home__general_default` | `#/chat?catalogState=general-home` | `live`
- `chat__home__curiosity_default` | `#/chat?catalogState=curiosity-home` | `live`
- `chat__character__luts` | `#/chat?openCharacterChat=true&characterId=luts` | `live`
- `chat__survey__fortune_step` | `#/chat?catalogState=curiosity-survey&fortuneType=daily` | `live`
- `chat__result__fortune_complete` | `#/chat?catalogState=curiosity-result&fortuneType=daily` | `live`
- `character__profile__luts` | `#/character/luts` | `live`
- `chat__onboarding__character_intro` | `#/chat` | `live`

### 80 Admin / Policy / Utility

- `account__profile__default` | `#/profile` | `live`
- `premium__insight__default` | `#/premium` | `live`
- `policy__privacy__default` | `#/privacy-policy` | `live`
- `policy__terms__default` | `#/terms-of-service` | `live`
- `account__deletion__auth_gated` | `#/account-deletion` | `placeholder`

## Component Inventory

### Chat Shell and Headers

- `lib/core/navigation/fortune_chat_route.dart`
- `lib/features/character/presentation/pages/swipe_home_shell.dart`
- `lib/features/character/presentation/pages/character_list_panel.dart`
- `lib/shared/components/app_header.dart`

### Character Entry and Onboarding

- `lib/features/character/presentation/pages/swipe_home_shell.dart`
- `lib/features/character/presentation/pages/character_onboarding_page.dart`
- `lib/screens/onboarding/onboarding_page.dart`
- `lib/screens/onboarding/steps/name_input_step.dart`
- `lib/screens/onboarding/steps/birth_input_step.dart`
- `lib/services/storage_service.dart`

### Conversation, Survey, and Result Blocks

- `lib/features/character/presentation/utils/chat_catalog_preview.dart`
- `lib/features/character/presentation/pages/character_chat_panel.dart`
- `lib/features/character/presentation/providers/character_fortune_adapter.dart`
- `lib/features/character/presentation/utils/fortune_key_localizer.dart`
- `lib/features/character/presentation/widgets/character_message_bubble.dart`
- `lib/features/chat/presentation/widgets/survey/chat_face_reading_flow.dart`
- `lib/features/chat/presentation/widgets/survey/chat_image_input.dart`
- `lib/features/chat/presentation/widgets/survey/chat_inline_calendar.dart`
- `lib/features/chat/presentation/widgets/survey/chat_match_selector.dart`
- `lib/features/chat/presentation/widgets/survey/chat_survey_chips.dart`
- `lib/features/chat/presentation/widgets/chat_saju_result_card.dart`
- `lib/features/character/presentation/widgets/embedded_fortune_component.dart`
- `lib/shared/widgets/smart_image.dart`
- `lib/shared/widgets/smart_image_local_file.dart`
- `lib/shared/widgets/smart_image_local_file_io.dart`
- `lib/shared/widgets/smart_image_local_file_web.dart`
- `lib/features/character/presentation/widgets/fortune_bodies/_fortune_body_shared.dart`
- `lib/features/character/presentation/widgets/fortune_bodies/career_fortune_body.dart`
- `lib/features/character/presentation/widgets/fortune_bodies/coaching_fortune_body.dart`
- `lib/features/character/presentation/widgets/fortune_bodies/family_fortune_body.dart`
- `lib/features/character/presentation/widgets/fortune_bodies/health_fortune_body.dart`
- `lib/features/character/presentation/widgets/fortune_bodies/interactive_fortune_body.dart`
- `lib/features/character/presentation/widgets/fortune_bodies/mystical_fortune_body.dart`
- `lib/features/character/presentation/widgets/fortune_bodies/personality_fortune_body.dart`
- `lib/features/character/presentation/widgets/fortune_bodies/relationship_fortune_body.dart`
- `lib/features/character/presentation/widgets/fortune_bodies/wealth_fortune_body.dart`
- `lib/features/character/presentation/widgets/haneul_fortune_result_widget.dart`
- `lib/shared/components/section_header.dart`

### Insight and Fortune Cards

- `lib/features/chat_insight/presentation/widgets/insight_history_card.dart`
- `lib/features/fortune/presentation/widgets/saju/today_iljin_card.dart`
- `lib/shared/components/cards/fortune_cards.dart`

### Account, Premium, and Policy Controls

- `lib/screens/profile/profile_screen.dart`
- `lib/screens/profile/profile_edit_page.dart`
- `lib/screens/profile/providers/character_relationships_provider.dart`
- `lib/screens/premium/premium_screen.dart`
- `lib/screens/profile/account_deletion_page.dart`
- `lib/presentation/widgets/social_accounts_section.dart`
- `lib/shared/components/settings_list_tile.dart`

### Design System Core

- `lib/core/design_system/components/ds_card.dart`
- `lib/core/design_system/components/ds_button.dart`
- `lib/core/design_system/components/ds_badge.dart`
- `lib/core/design_system/components/ds_chip.dart`
- `lib/core/design_system/components/ds_text_field.dart`
- `lib/core/widgets/unified_button.dart`

## Historical Root Ranges Removed From The Official File

These ids are no longer present in the official file and should be treated as historical only:

- `32:2`, `33:2`, `34:2`, `42:2`, `43:2`
- `38:2`, `39:2`, `63:2`
- `64:2` through `69:2`
- `82:2` through `87:2`
