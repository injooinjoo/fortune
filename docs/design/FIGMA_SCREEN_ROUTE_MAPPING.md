# Figma Screen To App Route Mapping

## Purpose

This document records the one-by-one mapping between the official Figma catalog and the current Flutter runtime.

Use this when answering:

- which real app page a Figma card represents
- whether a Figma card is a route, an internal `/chat` state, a component inventory item, or governance/archive scope
- which runtime routes are intentionally documented only as redirect behavior

Canonical source inputs:

- Official file: [Fortune Screen Catalog - Official](https://www.figma.com/design/dkx3Biwe5xkiMQWsjq95LA)
- Figma file key: `dkx3Biwe5xkiMQWsjq95LA`
- Canonical page roots: `89:2` through `94:2`
- Latest chat refresh append: `181:2`
- Capture manifest: `playwright/scripts/figma_capture_manifest.js`
- App route inventory: `docs/getting-started/APP_SURFACES_AND_ROUTES.md`

## Mapping Rules

- `route` means a dedicated GoRouter path exists for the surface.
- `internal_state` means the surface is rendered inside `/chat`, not as a standalone top-level route.
- `governance` means the Figma page documents process, not a runtime page.
- `component_inventory` means the Figma page groups reusable UI building blocks.
- `archive` means the Figma page tracks removed or historical product scope.

## Canonical Page Root Mapping

| Figma node | Figma page | Mapping type | Real app counterpart | Primary repo sources |
| --- | --- | --- | --- | --- |
| `89:2` | `00 Cover & Governance` | `governance` | Repo-side Figma governance and capture rules | `docs/design/FIGMA_SOURCE_OF_TRUTH.md`, `docs/design/FIGMA_PAGE_USAGE_AUDIT.md`, `playwright/scripts/build_figma_catalog.js` |
| `90:2` | `10 Entry / Auth / Onboarding` | `route_group` | Entry, auth callback, and onboarding runtime routes | `lib/routes/routes/auth_routes.dart`, `lib/routes/route_config.dart`, `lib/screens/auth/callback_page.dart`, `lib/screens/onboarding/onboarding_page.dart` |
| `91:2` | `20 Chat Home / Character` | `route_group` + `internal_state_group` | `/chat`, `/character/:id`, and in-chat states | `lib/routes/route_config.dart`, `lib/routes/character_routes.dart`, `lib/features/character/presentation/pages/swipe_home_shell.dart` |
| `92:2` | `80 Admin / Policy / Utility` | `route_group` | Premium, policy, and account-management routes | `lib/routes/route_config.dart`, `lib/screens/premium/premium_screen.dart`, `lib/features/policy/presentation/pages/*.dart` |
| `93:2` | `90 Components` | `component_inventory` | Shared chat, policy, account, and design-system building blocks | `docs/design/FIGMA_SCREEN_COMPONENT_REGISTRY.md`, `lib/shared/components`, `lib/core/design_system/components` |
| `94:2` | `99 Archive` | `archive` | Removed product families and historical capture notes | `docs/design/FIGMA_PAGE_USAGE_AUDIT.md`, `docs/design/FIGMA_SYNC_CHANGELOG.md` |

The latest official chat refresh currently lives on appended page `181:2` (`20 Chat Home / Character`) and should be treated as the freshest chat-page payload until the canonical range is consolidated. The previous append `180:2` remains in the file as a superseded premium refresh, and the earlier append `95:2` remains as a superseded historical refresh.

## Screen Card Mapping

### 10 Entry / Auth / Onboarding

| Figma card id | Visible title | Runtime kind | Runtime entry | Actual Flutter surface | Primary source files | Catalog status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `auth__splash__default` | Splash | `route` | `#/splash` | `SplashScreen` | `lib/routes/routes/auth_routes.dart`, `lib/routes/route_config.dart`, `lib/screens/splash_screen.dart` | `placeholder` | Initial entry surface before auth/chat resolution; deterministic capture still timing-gated |
| `auth__signup__default` | Signup | `route` | `#/signup` | `SignupScreen` | `lib/routes/routes/auth_routes.dart`, `lib/screens/auth/signup_screen.dart` | `live` | Dedicated signup page |
| `auth__callback__redirected` | Auth Callback Redirect | `route` | `#/auth/callback` | `CallbackPage` | `lib/routes/routes/auth_routes.dart`, `lib/screens/auth/callback_page.dart` | `placeholder` | Transient callback route that requires OAuth params or seeded auth state |
| `onboarding__profile__default` | Onboarding | `route` | `#/onboarding` | `OnboardingPage` | `lib/routes/routes/auth_routes.dart`, `lib/screens/onboarding/onboarding_page.dart` | `live` | Main onboarding entry |
| `onboarding__toss_style__default` | Onboarding Toss Style | `route` | `#/onboarding/toss-style` | `OnboardingPage(isPartialCompletion: isPartial)` | `lib/routes/route_config.dart`, `lib/screens/onboarding/onboarding_page.dart` | `live` | Variant route backed by query-param-driven partial mode |

### 20 Chat Home / Character

| Figma card id | Visible title | Runtime kind | Runtime entry | Actual Flutter surface | Primary source files | Catalog status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `chat__home__default` | Chat Home | `route` | `#/chat` | `SwipeHomeShell` with `CharacterListPanel` as main body | `lib/routes/route_config.dart`, `lib/features/character/presentation/pages/swipe_home_shell.dart`, `lib/features/character/presentation/pages/character_list_panel.dart` | `live` | Shared retained chat shell |
| `chat__home__general_default` | General Chat Home | `internal_state` | `#/chat?catalogState=general-home` | `SwipeHomeShell` general-chat mode inside `CharacterListPanel` | `lib/core/navigation/fortune_chat_route.dart`, `lib/features/character/presentation/utils/chat_catalog_preview.dart`, `lib/features/character/presentation/pages/swipe_home_shell.dart`, `lib/features/character/presentation/pages/character_list_panel.dart` | `live` | Deterministic preview-only capture contract for the story-tab shell |
| `chat__home__curiosity_default` | Curiosity Home | `internal_state` | `#/chat?catalogState=curiosity-home` | `SwipeHomeShell` curiosity mode inside `CharacterListPanel` | `lib/core/navigation/fortune_chat_route.dart`, `lib/features/character/presentation/utils/chat_catalog_preview.dart`, `lib/features/character/presentation/pages/swipe_home_shell.dart`, `lib/features/character/presentation/pages/character_list_panel.dart` | `live` | Deterministic preview-only capture contract for the fortune-tab shell |
| `chat__character__luts` | Character Chat | `internal_state` | `#/chat?openCharacterChat=true&characterId=luts` | `CharacterChatPanel` overlay launched from `SwipeHomeShell` | `lib/features/character/presentation/pages/swipe_home_shell.dart`, `lib/features/character/presentation/pages/character_chat_panel.dart`, `lib/features/character/presentation/providers/character_chat_provider.dart` | `live` | Deep-linked open-chat runtime state inside `/chat` |
| `chat__survey__fortune_step` | Curiosity Survey Step | `internal_state` | `#/chat?catalogState=curiosity-survey&fortuneType=daily` | Survey widgets rendered inside `CharacterChatPanel` | `lib/core/navigation/fortune_chat_route.dart`, `lib/features/character/presentation/utils/chat_catalog_preview.dart`, `lib/features/character/presentation/pages/character_chat_panel.dart`, `lib/features/character/presentation/providers/character_chat_survey_provider.dart`, `lib/features/chat/domain/configs/survey_configs.dart` | `live` | Deterministic seeded survey step rendered through the preview-only `/chat` contract; latest official node `181:143` |
| `chat__result__fortune_complete` | Curiosity Result Complete | `internal_state` | `#/chat?catalogState=curiosity-result&fortuneType=daily` | Completed result UI inside `CharacterChatPanel` using embedded result widgets | `lib/core/navigation/fortune_chat_route.dart`, `lib/features/character/presentation/utils/chat_catalog_preview.dart`, `lib/features/character/presentation/pages/character_chat_panel.dart`, `lib/features/character/presentation/providers/character_fortune_adapter.dart`, `lib/features/character/presentation/widgets/embedded_fortune_component.dart`, `lib/features/character/presentation/widgets/haneul_fortune_result_widget.dart`, `lib/features/chat/presentation/widgets/chat_saju_result_card.dart` | `live` | Deterministic seeded result payload rendered through the preview-only `/chat` contract; latest official node `181:183` |
| `character__profile__luts` | Character Profile | `route` | `#/character/luts` | `CharacterProfilePage` | `lib/routes/character_routes.dart`, `lib/features/character/presentation/pages/character_profile_page.dart` | `live` | Route requires `:id`; optional `state.extra` can hydrate character data |
| `chat__onboarding__character_intro` | Character Chat Onboarding | `internal_state` | `#/chat` | `CharacterOnboardingPage` returned early from `SwipeHomeShell` | `lib/features/character/presentation/pages/swipe_home_shell.dart`, `lib/features/character/presentation/pages/character_onboarding_page.dart`, `lib/services/storage_service.dart` | `live` | First-run storage-gated onboarding state inside `/chat` |

### 80 Admin / Policy / Utility

| Figma card id | Visible title | Runtime kind | Runtime entry | Actual Flutter surface | Primary source files | Catalog status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `account__profile__default` | Account Profile | `route` | `#/profile` | `ProfileScreen` | `lib/routes/route_config.dart`, `lib/screens/profile/profile_screen.dart`, `lib/screens/profile/profile_edit_page.dart`, `lib/screens/profile/profile_relationships_page.dart`, `lib/screens/profile/providers/character_relationships_provider.dart`, `lib/screens/profile/saju_summary_page.dart` | `live` | Logged-in profile/settings hub with legal links folded into the page instead of a chat bottom sheet |
| `premium__insight__default` | Premium Insight | `route` | `#/premium` | `PremiumScreen` | `lib/routes/route_config.dart`, `lib/screens/premium/premium_screen.dart`, `lib/features/character/presentation/utils/fortune_chat_navigation.dart` | `live` | Dedicated premium entry route with current live capture |
| `policy__privacy__default` | Privacy Policy | `route` | `#/privacy-policy` | `PrivacyPolicyPage` | `lib/routes/route_config.dart`, `lib/features/policy/presentation/pages/privacy_policy_page.dart` | `live` | Dedicated policy page |
| `policy__terms__default` | Terms Of Service | `route` | `#/terms-of-service` | `TermsOfServicePage` | `lib/routes/route_config.dart`, `lib/features/policy/presentation/pages/terms_of_service_page.dart` | `live` | Dedicated policy page |
| `account__deletion__auth_gated` | Account Deletion | `route` | `#/account-deletion` | `AccountDeletionPage` | `lib/routes/route_config.dart`, `lib/screens/profile/account_deletion_page.dart` | `placeholder` | Route exists but destructive flow requires authenticated session |

## App Routes Without A Dedicated Current Figma Card

| App route | Current app source | Figma status | Reason |
| --- | --- | --- | --- |
| `/` | `lib/routes/routes/auth_routes.dart` | intentionally not a screen card | Redirect-only route to `/chat` |
| `/home` | `lib/routes/route_config.dart` | intentionally not a screen card | Redirect-only route to `/chat` |
| `/profile/edit` | `lib/routes/route_config.dart`, `lib/screens/profile/profile_edit_page.dart` | currently folded into `account__profile__default` | Subroute is live in runtime but not yet captured as its own official current-state screen card |
| `/profile/saju-summary` | `lib/routes/route_config.dart`, `lib/screens/profile/saju_summary_page.dart` | currently folded into `account__profile__default` | Subroute is live in runtime but not yet captured as its own official current-state screen card |
| `/profile/relationships` | `lib/routes/route_config.dart`, `lib/screens/profile/profile_relationships_page.dart` | currently folded into `account__profile__default` | Subroute is live in runtime but not yet captured as its own official current-state screen card |
| `/profile/notifications` | `lib/routes/route_config.dart`, `lib/features/notification/presentation/pages/notification_settings_page.dart` | currently folded into `account__profile__default` | Nested profile setting link reuses the existing notification settings screen without a dedicated new card yet |

## Historical Root Ranges Removed From The Official File

These ids may appear in old comments, screenshots, or docs, but they are no longer present in the official file:

| Historical ids | Historical meaning |
| --- | --- |
| `32:2`, `33:2`, `34:2`, `42:2`, `43:2` | older append generation of the contracted catalog |
| `38:2`, `39:2`, `63:2` | removed legacy product groups |
| `64:2` through `69:2` | earlier canonical current range before the 2026-03-14 refresh |
| `82:2` through `87:2` | pre-refresh current range superseded by the latest append |

## Maintenance Notes

Update this file whenever any of the following changes:

- `playwright/scripts/figma_capture_manifest.js`
- `lib/routes/route_config.dart`
- `lib/routes/routes/auth_routes.dart`
- `lib/routes/character_routes.dart`
- any retained `/chat` internal state that changes which screen card it maps to

When a route exists in runtime but is intentionally not represented as a dedicated Figma card, record it in `App Routes Without A Dedicated Current Figma Card` instead of forcing it into the screen-card tables.
