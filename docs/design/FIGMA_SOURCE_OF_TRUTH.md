# Fortune Figma Source Of Truth

## Official File

- Official file name: `Fortune Screen Catalog - Official`
- Figma file key: `dkx3Biwe5xkiMQWsjq95LA`
- Direct link: [Fortune Screen Catalog - Official](https://www.figma.com/design/dkx3Biwe5xkiMQWsjq95LA)
- Layer naming contract: `docs/design/FIGMA_LAYER_NAMING_STANDARD.md`

This file remains the only official Figma source of truth for Fortune.

## Coverage Snapshot

- Managed surfaces: `12`
- Live captures: `10`
- Placeholder specs: `2`

## Runtime Scope

The current product scope is intentionally reduced to:

- `10 Entry / Auth / Onboarding`
- `20 Chat / Character`
- `80 Admin / Policy / Utility`

Live runtime routes covered by the official catalog:

- `/splash`
- `/signup`
- `/onboarding`
- `/onboarding/toss-style`
- `/chat`
- `/character/:id`
- `/privacy-policy`
- `/terms-of-service`
- `/account-deletion`
- `/manseryeok`

## Official File Structure

- `00 Cover & Governance`
- `10 Entry / Auth / Onboarding`
- `20 Chat / Character`
- `80 Admin / Policy / Utility`
- `90 Components`
- `99 Archive`

The following legacy product groups are no longer valid source-of-truth sections and should be removed manually from the official file:

- `35:2` `30 Fortune Hub / Interactive`
- `36:2` `40 Trend`
- `37:2` `50 Health / Exercise`
- `38:2` `60 History / Profile / More`
- `39:2` `70 Commerce / Settings / Support`
- `40:2` `75 Wellness`

## Capture Sources

Canonical repo sources:

- Router: `lib/routes/route_config.dart`
- Auth routes: `lib/routes/routes/auth_routes.dart`
- Character routes: `lib/routes/character_routes.dart`
- Capture manifest: `playwright/scripts/figma_capture_manifest.js`
- Live capture runner: `playwright/scripts/capture_figma_screens.js`
- Catalog HTML generator: `playwright/scripts/build_figma_catalog.js`

## MCP Operator Workflow

Use the Figma MCP workflow in this order when a retained surface needs design context or re-capture:

1. `get_metadata` to identify the page, node hierarchy, and candidate retained frames.
2. `get_screenshot` to verify the current visual state of the selected node before any code/design sync work.
3. `get_design_context` to retrieve the implementation-oriented payload after the node is confirmed.

This workflow applies to retained runtime surfaces only. Removed groups `30/40/50/60/70/75` should not receive new MCP sync work.

## Rules

1. Do not reintroduce deleted page groups into the official file.
2. Any route change must update:
   - `playwright/scripts/figma_capture_manifest.js`
   - `docs/design/FIGMA_PAGE_USAGE_AUDIT.md`
   - `docs/design/FIGMA_SCREEN_COMPONENT_REGISTRY.md`
   - `docs/design/FIGMA_SYNC_CHANGELOG.md`
3. `90 Components` must only reference retained chat/policy/runtime components.
4. Removed product groups belong in `99 Archive` only if historical reference is still required.
5. Redirect-only routes such as `/` and `/home` are documented as behavior, not standalone screens.
