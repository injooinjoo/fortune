# Fortune Figma Source Of Truth

## Official File

- Official file name: `Fortune Screen Catalog - Official`
- Figma file key: `dkx3Biwe5xkiMQWsjq95LA`
- Direct link: [Fortune Screen Catalog - Official](https://www.figma.com/design/dkx3Biwe5xkiMQWsjq95LA)
- Layer naming contract: `docs/design/FIGMA_LAYER_NAMING_STANDARD.md`
- Screen-to-route mapping: `docs/design/FIGMA_SCREEN_ROUTE_MAPPING.md`

This file remains the only official Figma source of truth for current-state Fortune surfaces.

## Coverage Snapshot

- Managed surfaces: `17`
- Live captures: `9`
- Placeholder specs: `8`

## Runtime Scope

The retained current-state product scope is:

- `10 Entry / Auth / Onboarding`
- `20 Chat Home / Character`
- `80 Admin / Policy / Utility`

Runtime routes represented by the official catalog:

- `/splash`
- `/signup`
- `/onboarding`
- `/onboarding/toss-style`
- `/chat`
- `/premium`
- `/character/:id`
- `/privacy-policy`
- `/terms-of-service`
- `/account-deletion`

App routes that still exist in runtime but do not currently have a dedicated canonical Figma card:

- `/auth/callback`

Internal `/chat` states represented as catalog surfaces:

- 일반 채팅 홈
- 호기심 홈
- 채팅 설문 진행 상태
- 채팅 결과 상태
- 첫 진입 캐릭터 온보딩
- 채팅 계정 시트

## Canonical Current Page Roots

Only the following page roots should be treated as the current canonical set inside the official file:

- `64:2` `00 Cover & Governance`
- `65:2` `10 Entry / Auth / Onboarding`
- `66:2` `20 Chat Home / Character`
- `67:2` `80 Admin / Policy / Utility`
- `68:2` `90 Components`
- `69:2` `99 Archive`

Repo-side current-state sync work must target this range only.

## Stale Page Roots Still Present In The Official File

The official file still contains older append generations and legacy product pages that must not be treated as source of truth.

### Superseded current-state append generation

- `32:2` `00 Cover & Governance`
- `33:2` `10 Entry / Auth / Onboarding`
- `34:2` `20 Chat Home / Character`
- `42:2` `90 Components`
- `43:2` `99 Archive`

### Legacy product groups

- `38:2` `60 History / Profile / More`
- `39:2` `70 Commerce / Settings / Support`
- `60:2` `30 Fortune Hub / Interactive`
- `61:2` `40 Trend`
- `62:2` `50 Health / Exercise`
- `63:2` `60 History / Profile / More`

### Historical node IDs that are no longer present

Do not follow older docs or comments that still reference:

- `35:2`
- `36:2`
- `37:2`
- `40:2`
- `41:2`

Those page ids are not present in the current official file.

## Capture Sources

Canonical repo sources:

- Router: `lib/routes/route_config.dart`
- Auth routes: `lib/routes/routes/auth_routes.dart`
- Character routes: `lib/routes/character_routes.dart`
- Retained chat state: `lib/features/character/presentation/providers/character_chat_provider.dart`
- Capture manifest: `playwright/scripts/figma_capture_manifest.js`
- Live capture runner: `playwright/scripts/capture_figma_screens.js`
- Catalog HTML generator: `playwright/scripts/build_figma_catalog.js`

## MCP Operator Workflow

Use the Figma MCP workflow in this order when a retained surface needs design context or re-capture:

1. `get_metadata` to identify the page, node hierarchy, and candidate retained frames.
2. `get_screenshot` to verify the current visual state of the selected node before any code/design sync work.
3. `get_design_context` to retrieve the implementation-oriented payload after the node is confirmed.

This workflow applies to retained runtime surfaces only. Stale roots listed above should not receive new MCP sync work.

## Rules

1. Treat `64:2` through `69:2` as the only canonical current-state page range.
2. Do not reintroduce removed page groups into the official file.
3. Any route change must update:
   - `playwright/scripts/figma_capture_manifest.js`
   - `docs/design/FIGMA_PAGE_USAGE_AUDIT.md`
   - `docs/design/FIGMA_SCREEN_ROUTE_MAPPING.md`
   - `docs/design/FIGMA_SCREEN_COMPONENT_REGISTRY.md`
   - `docs/design/FIGMA_SYNC_CHANGELOG.md`
4. `90 Components` must only reference retained chat, policy, and account-management components.
5. `99 Archive` must record stale append generations and legacy delete targets, not active runtime coverage.
6. Redirect-only routes such as `/` and `/home` are documented as behavior, not standalone screens.
