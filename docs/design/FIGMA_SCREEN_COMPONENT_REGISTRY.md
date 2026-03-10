# Fortune Screen And Component Registry

## Reference

- Official file: [Fortune Screen Catalog - Official](https://www.figma.com/design/dkx3Biwe5xkiMQWsjq95LA)
- Figma file key: `dkx3Biwe5xkiMQWsjq95LA`
- Device standard: `iPhone 15 Pro 393x852 @3x`
- Capture manifest: `playwright/scripts/figma_capture_manifest.js`
- Live capture runner: `playwright/scripts/capture_figma_screens.js`
- Catalog generator: `playwright/scripts/build_figma_catalog.js`

This document is the repository-side registry for the official Figma file.

## Coverage Summary

| Figma page | Total | Live | Placeholder |
| --- | ---: | ---: | ---: |
| `10 Entry / Auth / Onboarding` | 6 | 6 | 0 |
| `20 Chat Home / Character` | 5 | 4 | 1 |
| `30 Fortune Hub / Interactive` | 15 | 11 | 4 |
| `40 Trend` | 7 | 1 | 6 |
| `50 Health / Exercise` | 6 | 3 | 3 |
| `60 History / Profile / More` | 9 | 2 | 7 |
| `70 Commerce / Settings / Support` | 11 | 6 | 5 |
| `75 Wellness` | 2 | 2 | 0 |
| `80 Admin / Policy / Utility` | 2 | 2 | 0 |

Additional official pages:

- `00 Cover & Governance`
- `90 Components`
- `99 Archive`

## Screen Catalog

### 10 Entry / Auth / Onboarding

- `auth__splash__redirected` | `#/splash` | `live`
- `auth__signup__default` | `#/signup` | `live`
- `auth__callback__redirected` | `#/auth/callback` | `live`
- `onboarding__profile__default` | `#/onboarding` | `live`
- `onboarding__toss_style__default` | `#/onboarding/toss-style` | `live`
- `chat__onboarding__first_run` | `#/chat` | `live`

### 20 Chat Home / Character

- `chat__home__returning` | `#/chat` | `live`
- `chat__character__luts` | `#/chat?openCharacterChat=true&characterId=luts` | `live`
- `character__profile__luts` | `#/character/luts` | `live`
- `character__profile__baek_hyunwoo` | `#/character/baek_hyunwoo` | `live`
- `chat__result_card__fortune` | runtime-only state | `placeholder`

### 30 Fortune Hub / Interactive

- `fortune__hub__default` | `#/fortune` | `live`
- `interactive__hub__list` | `#/fortune/interactive` | `live`
- `interactive_dream__input__default` | `#/fortune/interactive/dream` | `live`
- `interactive_dream__result__seeded` | `#/fortune/interactive/dream` | `live`
- `interactive_psychology__input__default` | `#/fortune/interactive/psychology-test` | `live`
- `interactive_psychology__result__api` | runtime result | `placeholder`
- `interactive_tarot__input__default` | `#/fortune/interactive/tarot` | `live`
- `interactive_tarot__animated_flow__default` | `#/fortune/interactive/tarot/animated-flow` | `live`
- `interactive_face_reading__input__default` | `#/fortune/interactive/face-reading` | `live`
- `interactive_face_reading__result__analysis` | runtime result | `placeholder`
- `interactive_taemong__input__default` | `#/fortune/interactive/taemong` | `live`
- `interactive_taemong__result__analysis` | runtime result | `placeholder`
- `interactive_worry_bead__input__default` | `#/fortune/interactive/worry-bead` | `live`
- `interactive_worry_bead__result__analysis` | runtime result | `placeholder`
- `interactive_dream_journal__default` | `#/fortune/interactive/dream-journal` | `live`

### 40 Trend

- `trend__hub__empty` | `#/trend` | `live`
- `trend_psychology__detail__content` | backend content dependent | `placeholder`
- `trend_psychology__result__summary` | backend content dependent | `placeholder`
- `trend_worldcup__detail__bracket` | backend content dependent | `placeholder`
- `trend_worldcup__result__winner` | backend content dependent | `placeholder`
- `trend_balance__detail__play` | backend content dependent | `placeholder`
- `trend_balance__result__summary` | backend content dependent | `placeholder`

### 50 Health / Exercise

- `health__input__default` | `#/health-toss` | `live`
- `health__result__analysis` | runtime result | `placeholder`
- `medical_document__result__analysis` | `state.extra` required | `placeholder`
- `exercise__input__default` | `#/exercise` | `live`
- `exercise__result__analysis` | runtime result | `placeholder`
- `sports_game__input__default` | `#/sports-game` | `live`

### 60 History / Profile / More

- `history__empty__default` | `#/history` | `live`
- `fortune_history__detail__extra` | `state.extra` required | `placeholder`
- `more__guest__default` | `#/more` | `live`
- `profile__root__auth_gated` | `#/profile` | `placeholder`
- `profile__edit__auth_gated` | `#/profile/edit` | `placeholder`
- `profile__saju__auth_gated` | `#/profile/saju` | `placeholder`
- `profile__saju_summary__auth_gated` | `#/profile/saju-summary` | `placeholder`
- `profile__elements__auth_gated` | `#/profile/elements` | `placeholder`
- `profile__verification__auth_gated` | `#/profile/verification` | `placeholder`

### 70 Commerce / Settings / Support

- `premium__default` | `#/premium` | `live`
- `subscription__default` | `#/subscription` | `live`
- `token_purchase__default` | `#/token-purchase` | `live`
- `help__default` | `#/help` | `live`
- `privacy_policy__default` | `#/privacy-policy` | `live`
- `terms_of_service__default` | `#/terms-of-service` | `live`
- `profile__notifications__auth_gated` | `#/profile/notifications` | `placeholder`
- `profile__font__auth_gated` | `#/profile/font` | `placeholder`
- `profile__social_accounts__auth_gated` | `#/profile/social-accounts` | `placeholder`
- `profile__phone_management__auth_gated` | `#/profile/phone-management` | `placeholder`
- `profile__account_deletion__auth_gated` | `#/profile/account-deletion` | `placeholder`

### 75 Wellness

- `wellness__landing__default` | `#/wellness` | `live`
- `wellness__meditation__default` | `#/wellness/meditation` | `live`

### 80 Admin / Policy / Utility

- `admin__celebrity_crawling__error` | `#/admin/celebrity-crawling` | `live`
- `manseryeok__default` | `#/manseryeok` | `live`

### 90 Components

- `App Shell and Headers`
  - `lib/shared/layouts/main_shell.dart`
  - `lib/shared/components/app_header.dart`
  - `lib/shared/components/profile_header_icon.dart`
- `Cards, Buttons, Inputs`
  - `lib/core/design_system/components/ds_card.dart`
  - `lib/core/design_system/components/ds_button.dart`
  - `lib/core/design_system/components/ds_text_field.dart`
  - `lib/core/widgets/unified_button.dart`
- `Settings and Commerce Rows`
  - `lib/shared/components/settings_list_tile.dart`
  - `lib/shared/components/premium_membership_card.dart`
  - `lib/shared/components/token_balance_widget.dart`
  - `lib/shared/components/token_insufficient_modal.dart`
- `Fortune and Result Blocks`
  - `lib/shared/components/section_header.dart`
  - `lib/shared/components/loading_states.dart`
  - `lib/features/character/presentation/widgets/character_message_bubble.dart`
  - `lib/features/chat/presentation/widgets/chat_saju_result_card.dart`
- `Wellness Focus Blocks`
  - `lib/features/wellness/presentation/pages/wellness_page.dart`
  - `lib/features/wellness/presentation/pages/meditation_page.dart`
  - `lib/features/wellness/presentation/widgets/breathing_timer_widget.dart`
  - `lib/features/wellness/presentation/widgets/meditation_completion_sheet.dart`

### 99 Archive

- Superseded, blocked, or intentionally excluded surfaces move here only after they are removed from active governance pages.

## Placeholder Governance

### Auth-gated profile surfaces

- `profile__root__auth_gated`
- `profile__edit__auth_gated`
- `profile__saju__auth_gated`
- `profile__saju_summary__auth_gated`
- `profile__elements__auth_gated`
- `profile__verification__auth_gated`
- `profile__notifications__auth_gated`
- `profile__font__auth_gated`
- `profile__social_accounts__auth_gated`
- `profile__phone_management__auth_gated`
- `profile__account_deletion__auth_gated`

Blocker:

- Current test auto-login cannot establish a usable authenticated profile session because backend user creation fails in local capture mode.

### `state.extra` dependent pages

- `fortune_history__detail__extra`
- `medical_document__result__analysis`

Blocker:

- These surfaces require runtime navigation payloads and do not render correctly from a bare direct URL.

### Runtime result pages

- `chat__result_card__fortune`
- `interactive_psychology__result__api`
- `interactive_face_reading__result__analysis`
- `interactive_taemong__result__analysis`
- `interactive_worry_bead__result__analysis`
- `health__result__analysis`
- `exercise__result__analysis`

Blocker:

- These states require successful local completion of the input flow plus generated backend or local result payloads.

### Trend content pages

- `trend_psychology__detail__content`
- `trend_psychology__result__summary`
- `trend_worldcup__detail__bracket`
- `trend_worldcup__result__winner`
- `trend_balance__detail__play`
- `trend_balance__result__summary`

Blocker:

- Current local backend seed data does not provide usable `trend_content` records for direct capture.

## Representative Content Rules

- Character representative samples are fixed to `luts` and `baek_hyunwoo`.
- Dream result coverage uses a seeded local storage payload for `interactive_dream__result__seeded`.
- Trend detail pages are not duplicated per content item. One representative content record per layout family is enough once seed data exists.
- Loading, toast, snackbar, and generic error states are excluded unless they are the stable route surface itself.
- Redirect-only routes `/` and `/home` are excluded from independent frame coverage because they do not produce unique UI surfaces.

## Update Checklist

1. Confirm the target screen exists in router or runtime flow.
2. Add or update the entry in `playwright/scripts/figma_capture_manifest.js`.
3. Refresh live screenshots and catalog HTML.
4. Update the official Figma file.
5. Sync this registry and [FIGMA_SOURCE_OF_TRUTH.md](./FIGMA_SOURCE_OF_TRUTH.md).
