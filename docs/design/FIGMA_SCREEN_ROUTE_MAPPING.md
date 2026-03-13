# Figma Screen To App Route Mapping

## Purpose

This document records the one-by-one mapping between the official Figma catalog and the current Flutter runtime.

Use this when answering:

- which real app page a Figma card represents
- whether a Figma card is a route, an internal `/chat` state, a component inventory item, or stale scope
- which app routes still exist without a dedicated current-state Figma card

Canonical source inputs:

- Official file: [Fortune Screen Catalog - Official](https://www.figma.com/design/dkx3Biwe5xkiMQWsjq95LA)
- Figma file key: `dkx3Biwe5xkiMQWsjq95LA`
- Canonical page roots: `64:2` through `69:2`
- Capture manifest: `playwright/scripts/figma_capture_manifest.js`
- App route inventory: `docs/getting-started/APP_SURFACES_AND_ROUTES.md`

## Mapping Rules

- `route` means a dedicated GoRouter path exists for the surface.
- `internal_state` means the surface is rendered inside `/chat`, not as a standalone top-level route.
- `governance` means the Figma page documents process, not a runtime page.
- `component_inventory` means the Figma page groups reusable UI building blocks.
- `archive` means the Figma page tracks removed or stale product scope.

## Canonical Page Root Mapping

| Figma node | Figma page | Mapping type | Real app counterpart | Primary repo sources |
| --- | --- | --- | --- | --- |
| `64:2` | `00 Cover & Governance` | `governance` | Repo-side Figma governance and capture rules | `docs/design/FIGMA_SOURCE_OF_TRUTH.md`, `docs/design/FIGMA_PAGE_USAGE_AUDIT.md`, `playwright/scripts/build_figma_catalog.js` |
| `65:2` | `10 Entry / Auth / Onboarding` | `route_group` | Entry/auth/onboarding runtime routes | `lib/routes/routes/auth_routes.dart`, `lib/routes/route_config.dart`, `lib/screens/onboarding/onboarding_page.dart` |
| `66:2` | `20 Chat Home / Character` | `route_group` + `internal_state_group` | `/chat`, `/character/:id`, and in-chat states | `lib/routes/route_config.dart`, `lib/routes/character_routes.dart`, `lib/features/character/presentation/pages/swipe_home_shell.dart` |
| `67:2` | `80 Admin / Policy / Utility` | `route_group` | Premium, policy, and account-management routes | `lib/routes/route_config.dart`, `lib/screens/premium/premium_screen.dart`, `lib/features/policy/presentation/pages/*.dart` |
| `68:2` | `90 Components` | `component_inventory` | Shared chat/policy/design-system building blocks | `docs/design/FIGMA_SCREEN_COMPONENT_REGISTRY.md`, `lib/shared/components`, `lib/core/design_system/components` |
| `69:2` | `99 Archive` | `archive` | Removed or stale page groups kept only for cleanup history | `docs/design/FIGMA_PAGE_USAGE_AUDIT.md`, `docs/design/FIGMA_SYNC_CHANGELOG.md` |

## Screen Card Mapping

### 10 Entry / Auth / Onboarding

| Figma card id | Visible title | Runtime kind | Runtime entry | Actual Flutter surface | Primary source files | Catalog status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `auth__splash__default` | Splash | `route` | `#/splash` | `SplashScreen` | `lib/routes/routes/auth_routes.dart`, `lib/routes/route_config.dart`, `lib/screens/splash_screen.dart` | `live` | Initial entry surface before auth/chat resolution |
| `auth__signup__default` | Signup | `route` | `#/signup` | `SignupScreen` | `lib/routes/routes/auth_routes.dart`, `lib/screens/auth/signup_screen.dart` | `live` | Dedicated signup page |
| `onboarding__profile__default` | Onboarding | `route` | `#/onboarding` | `OnboardingPage` | `lib/routes/routes/auth_routes.dart`, `lib/screens/onboarding/onboarding_page.dart` | `live` | Main onboarding entry |
| `onboarding__toss_style__default` | Onboarding Toss Style | `route` | `#/onboarding/toss-style` | `OnboardingPage(isPartialCompletion: isPartial)` | `lib/routes/route_config.dart`, `lib/screens/onboarding/onboarding_page.dart` | `live` | Variant route backed by query-param-driven partial mode |

### 20 Chat Home / Character

| Figma card id | Visible title | Runtime kind | Runtime entry | Actual Flutter surface | Primary source files | Catalog status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `chat__home__default` | Chat Home | `route` | `#/chat` | `SwipeHomeShell` with `CharacterListPanel` as main body | `lib/routes/route_config.dart`, `lib/features/character/presentation/pages/swipe_home_shell.dart`, `lib/features/character/presentation/pages/character_list_panel.dart` | `live` | Shared retained chat shell |
| `chat__home__general_default` | General Chat Home | `internal_state` | `#/chat` | `SwipeHomeShell` general-chat mode inside `CharacterListPanel` | `lib/features/character/presentation/pages/swipe_home_shell.dart`, `lib/features/character/presentation/pages/character_list_panel.dart` | `placeholder` | Not a standalone route; needs deterministic general-mode capture |
| `chat__home__curiosity_default` | Curiosity Home | `internal_state` | `#/chat` | `SwipeHomeShell` curiosity mode inside `CharacterListPanel` | `lib/features/character/presentation/pages/swipe_home_shell.dart`, `lib/features/character/presentation/pages/character_list_panel.dart` | `placeholder` | Not a standalone route; needs deterministic curiosity-mode capture |
| `chat__character__luts` | Character Chat | `internal_state` | `#/chat?openCharacterChat=true&characterId=luts` | `CharacterChatPanel` overlay launched from `SwipeHomeShell` | `lib/features/character/presentation/pages/swipe_home_shell.dart`, `lib/features/character/presentation/pages/character_chat_panel.dart`, `lib/features/character/presentation/providers/character_chat_provider.dart` | `live` | Deep-linked open-chat runtime state inside `/chat` |
| `chat__survey__fortune_step` | Curiosity Survey Step | `internal_state` | `#/chat?fortuneType=daily` | Survey widgets rendered inside `CharacterChatPanel` | `lib/features/character/presentation/pages/character_chat_panel.dart`, `lib/features/character/presentation/providers/character_chat_survey_provider.dart`, `lib/features/chat/domain/configs/survey_configs.dart` | `placeholder` | Represents active survey step, not a route change |
| `chat__result__fortune_complete` | Curiosity Result Complete | `internal_state` | `#/chat?fortuneType=daily` | Completed result UI inside `CharacterChatPanel` using embedded result widgets | `lib/features/character/presentation/pages/character_chat_panel.dart`, `lib/features/character/presentation/widgets/embedded_fortune_component.dart`, `lib/features/chat/presentation/widgets/chat_saju_result_card.dart` | `placeholder` | Needs seeded survey answers and deterministic result payload |
| `character__profile__luts` | Character Profile | `route` | `#/character/luts` | `CharacterProfilePage` | `lib/routes/character_routes.dart`, `lib/features/character/presentation/pages/character_profile_page.dart` | `live` | Route requires `:id`; optional `state.extra` can hydrate character data |
| `chat__onboarding__character_intro` | Character Chat Onboarding | `internal_state` | `#/chat` | `CharacterOnboardingPage` returned early from `SwipeHomeShell` | `lib/features/character/presentation/pages/swipe_home_shell.dart`, `lib/features/character/presentation/pages/character_onboarding_page.dart`, `lib/services/storage_service.dart` | `placeholder` | First-run storage-gated state inside `/chat` |
| `chat__profile_sheet__default` | Chat Account Sheet | `internal_state` | bottom sheet on `/chat` | `ProfileBottomSheet` | `lib/features/chat/presentation/widgets/profile_bottom_sheet.dart` | `placeholder` | Sheet state, not its own route |

### 80 Admin / Policy / Utility

| Figma card id | Visible title | Runtime kind | Runtime entry | Actual Flutter surface | Primary source files | Catalog status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `premium__insight__default` | Premium Insight | `route` | `#/premium` | `PremiumScreen` | `lib/routes/route_config.dart`, `lib/screens/premium/premium_screen.dart`, `lib/features/character/presentation/utils/fortune_chat_navigation.dart` | `placeholder` | Dedicated route exists; current catalog still lacks fresh live capture |
| `policy__privacy__default` | Privacy Policy | `route` | `#/privacy-policy` | `PrivacyPolicyPage` | `lib/routes/route_config.dart`, `lib/features/policy/presentation/pages/privacy_policy_page.dart` | `live` | Dedicated policy page |
| `policy__terms__default` | Terms Of Service | `route` | `#/terms-of-service` | `TermsOfServicePage` | `lib/routes/route_config.dart`, `lib/features/policy/presentation/pages/terms_of_service_page.dart` | `live` | Dedicated policy page |
| `account__deletion__auth_gated` | Account Deletion | `route` | `#/account-deletion` | `AccountDeletionPage` | `lib/routes/route_config.dart`, `lib/screens/profile/account_deletion_page.dart` | `placeholder` | Route exists but destructive flow requires authenticated session |

## App Routes Without A Dedicated Current Figma Card

| App route | Current app source | Figma status | Reason |
| --- | --- | --- | --- |
| `/auth/callback` | `lib/routes/routes/auth_routes.dart`, `lib/screens/auth/callback_page.dart` | not represented in canonical page roots `64:2`-`69:2` | Older append generation `33:2` included this route, but the current canonical catalog does not carry a dedicated callback card |
| `/` | `lib/routes/routes/auth_routes.dart` | intentionally not a screen card | Redirect-only route to `/chat` |
| `/home` | `lib/routes/route_config.dart` | intentionally not a screen card | Redirect-only route to `/chat` |

## Stale Figma Page Groups With No Current Runtime Match

These page roots are still in the official file but should not be used for current-state review:

| Figma node | Figma page | Current app match |
| --- | --- | --- |
| `32:2`, `33:2`, `34:2`, `42:2`, `43:2` | Older append generation of current-state pages | superseded by `64:2` through `69:2` |
| `38:2`, `39:2`, `63:2` | Legacy product groups such as History, More, and Commerce | no active current-state route group |

## Legacy Figma Roots Already Deleted

These legacy product roots were removed from the official file on `2026-03-13` and should not be reintroduced:

| Figma node | Figma page | Current app match |
| --- | --- | --- |
| `60:2` | `30 Fortune Hub / Interactive` | no active current-state route group |
| `61:2` | `40 Trend` | no active current-state route group |
| `62:2` | `50 Health / Exercise` | no active current-state route group |

## Maintenance Notes

Update this file whenever any of the following changes:

- `playwright/scripts/figma_capture_manifest.js`
- `lib/routes/route_config.dart`
- `lib/routes/routes/auth_routes.dart`
- `lib/routes/character_routes.dart`
- any retained `/chat` internal state that changes which screen card it maps to

When a route exists in runtime but is intentionally not represented as a dedicated Figma card, record it in `App Routes Without A Dedicated Current Figma Card` instead of forcing it into the screen-card tables.
