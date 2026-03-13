# Figma Sync Changelog

This file is the repository-side proof that a code change was reconciled with the official Figma file.

## Rules

1. Any route change must update:
   - `playwright/scripts/figma_capture_manifest.js`
   - `docs/design/FIGMA_LAYER_NAMING_STANDARD.md` when the layer contract changes
   - `docs/design/FIGMA_SOURCE_OF_TRUTH.md`
   - `docs/design/FIGMA_SCREEN_ROUTE_MAPPING.md`
   - `docs/design/FIGMA_SCREEN_COMPONENT_REGISTRY.md`
   - this changelog
2. Any UI surface change under tracked presentation, screen, shared, or design-system files must append a changelog entry even if the screen list did not change.
3. The official Figma file remains [Fortune Screen Catalog - Official](https://www.figma.com/design/dkx3Biwe5xkiMQWsjq95LA).
4. CI runs `npm run figma:guard` and fails when these records are missing.

## Entries

| Date | Jira | Code Scope | Affected Screens / Components | Figma Action |
| --- | --- | --- | --- | --- |
| 2026-03-13 | `KAN-83` | Legacy `30/40/50` surface removal and stale design artifact pruning | deleted official-file roots `60:2`, `61:2`, `62:2`; removed legacy `/fortune`, `/interactive/*`, `/trend*`, `/health-toss`, `/exercise`, `/sports-game` capture references from repo-side design artifacts | Deleted the stale `30 Fortune Hub / Interactive`, `40 Trend`, and `50 Health / Exercise` roots from the official Figma file, then pruned the repo-side legacy capture inventories so those groups are no longer treated as live or pending official catalog surfaces |
| 2026-03-13 | `KAN-84` | Detailed screen-to-runtime reconciliation docs | `65:2` through `69:2`, `auth__*`, `chat__*`, `policy__*`, `premium__*`, callback route gap notes | Added a card-level mapping registry between canonical Figma pages and actual Flutter runtime surfaces, linked the new registry from the Figma governance docs, and documented that `/auth/callback` still exists in runtime but is not represented as a dedicated current-state Figma card |
| 2026-03-13 | `KAN-82` | Official catalog deep cleanup and current-code reconciliation | `00 Cover & Governance`, `99 Archive`, design governance docs, cleanup runbook, stale page inventory | Rebased the repo-side Figma contract onto the confirmed canonical page roots `64:2` through `69:2`, replaced stale `/fortune/interactive/*` governance copy with `/chat`-centered current-state wording, and recorded the exact stale roots still present in the official file for manual deletion |
| 2026-03-12 | `KAN-80` | Current-state chat surface expansion | `chat__home__general_default`, `chat__home__curiosity_default`, `chat__survey__fortune_step`, `chat__result__fortune_complete`, `chat__onboarding__character_intro`, `premium__insight__default`, removed stale `utility__manseryeok__default`, updated component groups | Expanded the repo-backed catalog to reflect `/chat` internal experiences and the retained premium route, while dropping the non-routable manseryeok screen from current-state coverage so the official Figma file can be re-appended from the updated manifest |
| 2026-03-11 | `KAN-70` | Reused retained runtime load paths | `chat__character__luts`, `utility__manseryeok__default`, retained provider-backed capture sources | Extended the retained manifest/source registry so character chat and manseryeok provider state changes remain covered by the official catalog guard |
| 2026-03-11 | `KAN-71` | Figma guard parity for contracted catalog | `chat__profile_sheet__default`, `account__deletion__auth_gated`, retained catalog governance docs | Added explicit placeholder triage metadata, corrected retained surface counts in the docs, and documented the MCP operator workflow required by the sync guard |
| 2026-03-11 | `KAN-71` | Product contraction for `30/40/50/60/70/75` | active catalog reduced to `10 Entry / Auth / Onboarding`, `20 Chat / Character`, `80 Admin / Policy / Utility`; removed commerce/history/profile/more/trend/wellness references | Rewrote the repo manifest and design source docs to the retained surfaces only, and recorded the manual Figma page delete list for nodes `35:2` through `40:2` |
| 2026-03-11 | `KAN-67` | Manual Figma rename runbook for refreshed append range | appended official-file pages `32:2` through `43:2`, governed anchor naming scope | Added a node-id-based manual rename runbook so the refreshed MCP-appended catalog pages can be normalized page-by-page without touching the older pre-refresh page set first |
| 2026-03-11 | `KAN-67` | MCP catalog append refresh helper | `00 Cover & Governance` through `99 Archive`, helper operator path | Regenerated catalog HTML, appended refreshed pages into the official file through MCP existing-file capture, corrected the appended cover card to `36 live / 26 placeholder`, and recorded remaining manual rename cleanup |
| 2026-03-11 | `KAN-67` | Live MCP audit of official catalog parity | Cover governance counts, legacy section/layer names, representative signup screen card | Verified repo parity, recorded stale `35 live / 26 placeholder` cover card, and documented remaining manual Figma rename cleanup |
| 2026-03-11 | `KAN-65` | Figma layer governance + MCP sync contract | `section__00__cover_governance` through `section__99__archive`, all governed `screen_card__*`, component groups, sync guard | Added canonical layer naming docs, manifest contract fields, catalog export attributes, and guard checks for MCP-managed governance |
| 2026-03-10 | `KAN-60` | Official catalog formalization | `10 Entry / Auth / Onboarding` through `99 Archive` | Created the single official catalog file and aligned repo docs |
| 2026-03-10 | `KAN-61` | Wellness route coverage | `wellness__landing__default`, `wellness__meditation__default`, `Wellness Focus Blocks` | Added `75 Wellness` to the official file and synced docs |
| 2026-03-10 | `NO-JIRA` | Figma sync automation guard | `figma_capture_manifest` governance, changelog enforcement, CI drift reporting | Added automatic guard so route/UI changes cannot pass CI without a recorded Figma sync step |
