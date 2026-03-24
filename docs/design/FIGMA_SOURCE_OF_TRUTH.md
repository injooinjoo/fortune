# Fortune Figma Source Of Truth

## Official File

- Official file name: `Fortune Screen Catalog - Official`
- Figma file key: `dkx3Biwe5xkiMQWsjq95LA`
- Direct link: [Fortune Screen Catalog - Official](https://www.figma.com/design/dkx3Biwe5xkiMQWsjq95LA)
- Layer naming contract: `docs/design/FIGMA_LAYER_NAMING_STANDARD.md`
- Screen-to-route mapping: `docs/design/FIGMA_SCREEN_ROUTE_MAPPING.md`

This file remains the only official Figma source of truth for current-state Fortune surfaces.

## Coverage Snapshot

- Managed surfaces: `18`
- Live captures: `15`
- Placeholder specs: `3`

## Runtime Scope

The retained current-state product scope is:

- `10 Entry / Auth / Onboarding`
- `20 Chat Home / Character`
- `80 Admin / Policy / Utility`

Runtime routes represented by the official catalog:

- `/splash`
- `/signup`
- `/auth/callback`
- `/onboarding`
- `/onboarding/toss-style`
- `/chat`
- `/profile`
- `/premium`
- `/character/:id`
- `/privacy-policy`
- `/terms-of-service`
- `/account-deletion`

Redirect-only routes that intentionally do not get their own official screen card:

- `/`
- `/home`

Internal `/chat` states represented as catalog surfaces:

- 일반 채팅 홈
- 호기심 홈
- 채팅 설문 진행 상태
- 채팅 결과 상태
- 첫 진입 캐릭터 온보딩

Current runtime routes without their own dedicated current Figma card:

- `/profile/edit`
- `/profile/saju-summary`
- `/profile/relationships`
- `/profile/notifications`

## Canonical Current Page Roots

Only the following page roots should be treated as the canonical current set inside the official file:

- `89:2` `00 Cover & Governance`
- `90:2` `10 Entry / Auth / Onboarding`
- `91:2` `20 Chat Home / Character`
- `92:2` `80 Admin / Policy / Utility`
- `93:2` `90 Components`
- `94:2` `99 Archive`

Repo-side current-state sync work must target this range only.

## Latest Single-Page Refresh Append

The official file currently contains the rich mystical Haneul chat refresh append created by `KAN-127`:

- `181:2` `20 Chat Home / Character`

This page now holds the latest official live captures for:

- `chat__home__general_default`
- `chat__home__curiosity_default`
- `chat__survey__fortune_step`
- `chat__result__fortune_complete`

Treat `181:2` as the freshest official chat-page payload until the retained canonical range is consolidated again.

Older chat append still present in the file:

- `180:2` `20 Chat Home / Character`
- `95:2` `20 Chat Home / Character`

`180:2` remains as the previous premium append, but it is superseded for the Haneul survey/result shell by `181:2`.

`95:2` remains as an earlier historical refresh append and is also superseded by `181:2`.

## Official File Cleanliness

The official file currently keeps the retained canonical governance range `89:2` through `94:2`, plus the intentional chat refresh append pages `95:2`, `180:2`, and `181:2`.

No removed legacy page roots remain alongside that retained range and the retained chat refresh append pages.

Historical root ranges that were removed from the official file and must not be cited as current:

- older append generation: `32:2`, `33:2`, `34:2`, `42:2`, `43:2`
- earlier contracted canonical range: `64:2` through `69:2`
- superseded pre-refresh range: `82:2` through `87:2`
- deleted legacy groups: `38:2`, `39:2`, `63:2`

## Capture Sources

Canonical repo sources:

- Router: `lib/routes/route_config.dart`
- Auth routes: `lib/routes/routes/auth_routes.dart`
- Character routes: `lib/routes/character_routes.dart`
- Retained chat state: `lib/features/character/presentation/providers/character_chat_provider.dart`
- Design-system badges: `lib/core/design_system/components/ds_badge.dart`
- Selection chip core: `lib/core/design_system/components/ds_chip.dart`
- Chat survey selectors: `lib/features/chat/presentation/widgets/survey/chat_survey_chips.dart`
- Chat survey image actions: `lib/features/chat/presentation/widgets/survey/chat_face_reading_flow.dart`, `lib/features/chat/presentation/widgets/survey/chat_image_input.dart`
- Chat calendar and match selectors: `lib/features/chat/presentation/widgets/survey/chat_inline_calendar.dart`, `lib/features/chat/presentation/widgets/survey/chat_match_selector.dart`
- Curiosity result composition: `lib/features/character/presentation/widgets/embedded_fortune_component.dart`, `lib/features/character/presentation/utils/fortune_key_localizer.dart`, plus `lib/features/character/presentation/widgets/fortune_bodies/*.dart`
- Capture manifest: `playwright/scripts/figma_capture_manifest.js`
- Live capture runner: `playwright/scripts/capture_figma_screens.js`
- Catalog HTML generator: `playwright/scripts/build_figma_catalog.js`
- Card taxonomy: `docs/design/CARD_COMPONENT_TAXONOMY.md`

## MCP Operator Workflow

Use the Figma MCP workflow in this order when a retained surface needs design context or re-capture:

1. `get_metadata` to identify the page, node hierarchy, and candidate retained frames.
2. `get_screenshot` to verify the current visual state of the selected node before any code/design sync work.
3. `get_design_context` to retrieve the implementation-oriented payload after the node is confirmed.

This workflow applies to retained runtime surfaces only.

## Rules

1. Treat `89:2` through `94:2` as the canonical governance range, and explicitly document any newer single-page append such as `181:2` until it is consolidated.
2. Do not reintroduce removed page groups into the official file.
3. Any route change must update:
   - `playwright/scripts/figma_capture_manifest.js`
   - `docs/design/FIGMA_PAGE_USAGE_AUDIT.md`
   - `docs/design/FIGMA_SCREEN_ROUTE_MAPPING.md`
   - `docs/design/FIGMA_SCREEN_COMPONENT_REGISTRY.md`
   - `docs/design/FIGMA_SYNC_CHANGELOG.md`
4. `90 Components` must only reference retained chat, policy, and account-management components.
5. `99 Archive` must record removed product families and historical references, not active runtime coverage.
6. Redirect-only routes such as `/` and `/home` are documented as behavior, not standalone screens.
