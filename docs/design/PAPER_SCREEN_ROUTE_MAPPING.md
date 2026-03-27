# Paper Screen To App Route Mapping

## Purpose

This document records the one-by-one mapping between the canonical Paper inventory and the current Flutter runtime.

Use this when answering:

- which real app page a Paper artboard represents
- whether a Paper artboard is a route, an internal `/chat` state, or a design-only fallback
- which runtime routes are intentionally documented without a dedicated artboard

Canonical source inputs:

- Paper inventory: `paper/catalog_inventory.json`
- App route inventory: `docs/getting-started/APP_SURFACES_AND_ROUTES.md`

## Mapping Rules

- `route` means a dedicated GoRouter path exists.
- `internal_state` means the surface is rendered inside `/chat` or `/onboarding`, not as a standalone top-level route.
- `design_only` means the Paper artboard is retained for fallback/reference only and does not have a dedicated current runtime surface.
- `catalog_section` means the Paper artboard documents a governed set of surfaces rather than a single runtime page.

## Catalog Section Mapping

| Paper node | Paper artboard | Mapping type | Real app counterpart |
| --- | --- | --- | --- |
| `10X-1` | `Paper Catalog · 00 Cover & Governance` | `catalog_section` | Repo-side Paper governance and design contract |
| `10Y-1` | `Paper Catalog · 10 Entry / Auth / Onboarding` | `catalog_section` | Entry, auth, onboarding flow surfaces |
| `10Z-1` | `Paper Catalog · 20 Chat Home / Character` | `catalog_section` | `/chat`, character detail, in-chat states |
| `110-1` | `Paper Catalog · 80 Admin / Policy / Utility` | `catalog_section` | Premium, profile, policy, account-management routes |
| `111-1` | `Paper Catalog · 90 Components` | `catalog_section` | Shared design-system and chat building blocks |
| `112-1` | `Paper Catalog · 99 Archive` | `catalog_section` | Historical or intentionally retired design references |

## Mobile Surface Mapping

| Paper node | Visible title | Runtime kind | Runtime entry | Actual Flutter surface | Notes |
| --- | --- | --- | --- | --- | --- |
| `8A-0` | `01 - Splash` | `route` | `#/splash` | `SplashScreen` | Initial entry surface |
| `8B-0` | `02 - Entry Hero / Soft Gate` | `internal_state` | `#/chat` before auth completion | `SwipeHomeShell` gating into `SignupScreen` / auth entry shell | First-run soft gate state inside `/chat` |
| `E3-0` | `03 - Auth Fallback` | `route` | `#/signup` | `SignupScreen` | Dedicated fallback auth route |
| `8C-0` | `04 - Nickname Fallback` | `design_only` | none | no dedicated current runtime surface | Retained Paper fallback after onboarding cleanup |
| `9P-0` | `05 - Onboarding Birth` | `route` | `#/onboarding` | `OnboardingPage` birth step | Main onboarding entry state |
| `E4-0` | `06 - Interest Select` | `internal_state` | `#/onboarding` | `InterestSelectionStep` inside `OnboardingPage` | Step-level onboarding state |
| `E5-0` | `07 - Personalized Handoff` | `internal_state` | `#/onboarding` | `PersonalizedHandoffStep` inside `OnboardingPage` | Final onboarding handoff state |
| `9Q-0` | `08 - Character List (First Run)` | `route` | `#/chat` | `SwipeHomeShell` with `CharacterListPanel` | Main retained chat shell |
| `9R-0` | `09 - Character Chat` | `internal_state` | `#/chat?openCharacterChat=true&characterId=:id` | `CharacterChatPanel` inside `SwipeHomeShell` | Chat overlay / detail conversation state |
| `E6-0` | `10 - Character Profile` | `route` | `#/character/:id` | `CharacterProfilePage` | Character detail route |
| `9S-0` | `11 - Premium` | `route` | `#/premium` | `PremiumScreen` | Premium entry route |
| `EA-0` | `12 - Profile` | `route` | `#/profile` | `ProfileScreen` | Logged-in account hub |
| `EB-0` | `13 - Profile Edit` | `route` | `#/profile/edit` | `ProfileEditPage` | Nested profile route |
| `EC-0` | `14 - Saju Summary` | `route` | `#/profile/saju-summary` | `SajuSummaryPage` | Nested profile route |
| `ED-0` | `15 - Notification Settings` | `route` | `#/profile/notifications` | `NotificationSettingsPage` | Nested profile route |
| `E7-0` | `16 - Privacy Policy` | `route` | `#/privacy-policy` | `PrivacyPolicyPage` | Dedicated policy route |
| `E8-0` | `17 - Terms of Service` | `route` | `#/terms-of-service` | `TermsOfServicePage` | Dedicated policy route |
| `E9-0` | `18 - Account Deletion` | `route` | `#/account-deletion` | `AccountDeletionPage` | Auth-gated destructive flow |
| `3TB-1` | `19 - Relationships` | `route` | `#/profile/relationships` | `ProfileRelationshipsPage` | Nested profile route for story-character relationship state |

## Runtime Routes Without A Dedicated Paper Artboard

| App route | Current app source | Paper status | Reason |
| --- | --- | --- | --- |
| `/` | `lib/routes/routes/auth_routes.dart` | intentionally not an artboard | Redirect-only route to `/chat` |
| `/home` | `lib/routes/route_config.dart` | intentionally not an artboard | Redirect-only route to `/chat` |
| `/auth/callback` | `lib/routes/routes/auth_routes.dart`, `lib/screens/auth/callback_page.dart` | documented only | Transient callback route that is easier to govern as behavior instead of a stable visual surface |

## Maintenance Notes

Update this file whenever any of the following changes:

- `paper/catalog_inventory.json`
- `lib/routes/route_config.dart`
- `lib/routes/routes/auth_routes.dart`
- `lib/routes/character_routes.dart`
- any retained `/chat` or `/onboarding` internal state that changes its Paper mapping
