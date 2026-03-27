# Fortune Paper Screen And Component Registry

## Reference

- Paper inventory: `paper/catalog_inventory.json`
- Paper source of truth: `docs/design/PAPER_SOURCE_OF_TRUTH.md`
- Detailed screen mapping: `docs/design/PAPER_SCREEN_ROUTE_MAPPING.md`
- Sync changelog: `docs/design/PAPER_SYNC_CHANGELOG.md`

## Coverage Summary

| Section | Artboards | Notes |
| --- | ---: | --- |
| `10 Entry / Auth / Onboarding` | 7 | entry gate, auth fallback, onboarding step states |
| `20 Chat Home / Character` | 3 | chat shell, chat detail, character detail |
| `80 Admin / Policy / Utility` | 9 | premium, profile, relationship, policy, account-management |
| `Catalog / Governance` | 7 | inventory, governance, components, archive |

## Mobile Surface Inventory

### Entry / Auth / Onboarding

- `01 - Splash`
- `02 - Entry Hero / Soft Gate`
- `03 - Auth Fallback`
- `04 - Nickname Fallback`
- `05 - Onboarding Birth`
- `06 - Interest Select`
- `07 - Personalized Handoff`

### Chat Home / Character

- `08 - Character List (First Run)`
- `09 - Character Chat`
- `10 - Character Profile`

### Admin / Policy / Utility

- `11 - Premium`
- `12 - Profile`
- `13 - Profile Edit`
- `14 - Saju Summary`
- `15 - Notification Settings`
- `16 - Privacy Policy`
- `17 - Terms of Service`
- `18 - Account Deletion`
- `19 - Relationships`

## Component Inventory

### Chat Shell and Navigation

- `lib/core/navigation/fortune_chat_route.dart`
- `lib/features/character/presentation/pages/swipe_home_shell.dart`
- `lib/features/character/presentation/pages/character_list_panel.dart`
- `lib/features/character/presentation/pages/character_chat_panel.dart`

### Entry and Onboarding

- `lib/screens/auth/signup_screen.dart`
- `lib/presentation/widgets/social_login_bottom_sheet.dart`
- `lib/screens/onboarding/onboarding_page.dart`
- `lib/screens/onboarding/steps/birth_input_step.dart`
- `lib/screens/onboarding/widgets/interest_selection_step.dart`
- `lib/screens/onboarding/widgets/personalized_handoff_step.dart`

### Profile, Premium, and Policy

- `lib/screens/premium/premium_screen.dart`
- `lib/screens/profile/profile_screen.dart`
- `lib/screens/profile/profile_edit_page.dart`
- `lib/screens/profile/saju_summary_page.dart`
- `lib/screens/profile/account_deletion_page.dart`
- `lib/screens/profile/profile_relationships_page.dart`
- `lib/features/notification/presentation/pages/notification_settings_page.dart`
- `lib/features/policy/presentation/pages/privacy_policy_page.dart`
- `lib/features/policy/presentation/pages/terms_of_service_page.dart`

### Shared Paper Runtime Building Blocks

- `lib/core/widgets/paper_runtime_chrome.dart`
- `lib/core/widgets/paper_runtime_surface_kit.dart`
- `lib/core/design_system/components/*.dart`

## Rules

1. Any new governed surface must be represented in `paper/catalog_inventory.json` before it is treated as canonical.
2. If a Paper artboard gains or loses runtime ownership, update this registry and `PAPER_SCREEN_ROUTE_MAPPING.md` in the same turn.
3. If a UI change affects an existing governed surface, append a record to `PAPER_SYNC_CHANGELOG.md` even when the artboard list does not change.
