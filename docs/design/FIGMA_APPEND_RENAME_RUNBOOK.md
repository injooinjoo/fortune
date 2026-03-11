# Fortune Figma Append Rename Runbook

## Purpose

This runbook is the manual Figma-side cleanup plan for the refreshed catalog pages appended on `2026-03-11`.

- Official file: [Fortune Screen Catalog - Official](https://www.figma.com/design/dkx3Biwe5xkiMQWsjq95LA)
- File key: `dkx3Biwe5xkiMQWsjq95LA`
- Scope: refreshed appended pages `32:2` through `43:2`

The current MCP workflow can append refreshed catalog pages into the official file, but it cannot rename existing Figma nodes. This document narrows the manual pass to the governed anchors that matter for future MCP audits and design-to-code reconciliation.

## Important Scope Rule

Rename the refreshed appended page range first:

- `32:2` `00 Cover & Governance`
- `33:2` `10 Entry / Auth / Onboarding`
- `34:2` `20 Chat Home / Character`
- `35:2` `30 Fortune Hub / Interactive`
- `36:2` `40 Trend`
- `37:2` `50 Health / Exercise`
- `38:2` `60 History / Profile / More`
- `39:2` `70 Commerce / Settings / Support`
- `40:2` `75 Wellness`
- `41:2` `80 Admin / Policy / Utility`
- `42:2` `90 Components`
- `43:2` `99 Archive`

Do not spend time renaming the older pre-refresh page set first. The refreshed appended pages are the repo-backed source for the next sync pass.

## Governed Rename Boundary

This manual batch must rename only the governed anchors below:

- page root frames
- page-level `Main Content` / `Header` / main grid wrappers
- governance cards, screen cards, component group cards, archive cards
- screen preview image layers
- screen status badges
- metadata row roots: route, source, note, blocker

Leaf text nodes that only hold visible copy can remain content-driven labels. Example: the text layer whose visible name is `Route #/signup` does not need a machine-readable rename if its parent row is renamed to `meta__route`.

## Batch 1: Page Root And Main Wrapper Rename

Apply these renames in the Figma layer panel:

| Node id | Current name | Target name |
| --- | --- | --- |
| `32:2` | `00 Cover & Governance` | `section__00__cover_governance` |
| `32:3` | `Main Content` | `content` |
| `32:4` | `Header` | `header` |
| `32:15` | `Container` | `overview` |
| `32:108` | `Section` | `nav_links` |
| `33:2` | `10 Entry / Auth / Onboarding` | `section__10__entry_auth_onboarding` |
| `33:3` | `Main Content` | `content` |
| `33:4` | `Header` | `header` |
| `33:15` | `Section` | `screen_grid` |
| `34:2` | `20 Chat Home / Character` | `section__20__chat_character` |
| `34:3` | `Main Content` | `content` |
| `34:4` | `Header` | `header` |
| `34:15` | `Section` | `screen_grid` |
| `35:2` | `30 Fortune Hub / Interactive` | `section__30__fortune_interactive` |
| `35:3` | `Main Content` | `content` |
| `35:4` | `Header` | `header` |
| `35:15` | `Section` | `screen_grid` |
| `36:2` | `40 Trend` | `section__40__trend` |
| `36:3` | `Main Content` | `content` |
| `36:4` | `Header` | `header` |
| `36:15` | `Section` | `screen_grid` |
| `37:2` | `50 Health / Exercise` | `section__50__health_exercise` |
| `37:3` | `Main Content` | `content` |
| `37:4` | `Header` | `header` |
| `37:15` | `Section` | `screen_grid` |
| `38:2` | `60 History / Profile / More` | `section__60__history_profile_more` |
| `38:3` | `Main Content` | `content` |
| `38:4` | `Header` | `header` |
| `38:15` | `Section` | `screen_grid` |
| `39:2` | `70 Commerce / Settings / Support` | `section__70__commerce_settings_support` |
| `39:3` | `Main Content` | `content` |
| `39:4` | `Header` | `header` |
| `39:15` | `Section` | `screen_grid` |
| `40:2` | `75 Wellness` | `section__75__wellness` |
| `40:3` | `Main Content` | `content` |
| `40:4` | `Header` | `header` |
| `40:15` | `Section` | `screen_grid` |
| `41:2` | `80 Admin / Policy / Utility` | `section__80__admin_policy_utility` |
| `41:3` | `Main Content` | `content` |
| `41:4` | `Header` | `header` |
| `41:15` | `Section` | `screen_grid` |
| `42:2` | `90 Components` | `section__90__components` |
| `42:3` | `Main Content` | `content` |
| `42:4` | `Header` | `header` |
| `42:15` | `Section` | `component_grid` |
| `43:2` | `99 Archive` | `section__99__archive` |
| `43:3` | `Main Content` | `content` |
| `43:4` | `Header` | `header` |
| `43:15` | `Section` | `archive_grid` |

## Batch 2: Card Root Rename

Within each renamed section:

1. Rename every top-level `Article` directly under `screen_grid` to `screen_card__{screen_key}`.
2. The `screen_key` is already visible in the first label line of each card.
3. Rename every preview image layer from `Image ({screen_key})` to `preview__{screen_key}`.

Examples from the refreshed page set:

- `auth__signup__default` -> `screen_card__auth__signup__default`
- `chat__home__returning` -> `screen_card__chat__home__returning`
- `interactive_face_reading__result__analysis` -> `screen_card__interactive_face_reading__result__analysis`
- `profile__notifications__auth_gated` -> `screen_card__profile__notifications__auth_gated`
- `wellness__meditation__default` -> `screen_card__wellness__meditation__default`
- `manseryeok__default` -> `screen_card__manseryeok__default`

Component and archive pages use different card roots:

- `42:2` component `Article` cards -> `component_group__{slug}`
- `43:2` archive `Article` cards -> `archive_card__{slug}`

Governance page `32:2` overview cards:

- `Single Figma Source of Truth` -> `overview_card__official_file`
- `Hybrid Screen Catalog` -> `overview_card__capture_modes`
- `36 live / 26 placeholder` -> `overview_card__current_coverage`
- `iPhone 15 Pro Only` -> `overview_card__device_standard`
- `Hash Router and Nested Paths` -> `overview_card__routing_notes`
- `Auth / Backend / Extra State` -> `overview_card__runtime_blockers`

## Batch 3: Badge, Preview, And Metadata Rename

For every screen card:

- Badge layer with visible text `Live Capture` -> `badge__live_capture`
- Badge layer with visible text `Placeholder Spec` -> `badge__placeholder_spec`
- Device screenshot/image layer -> `preview__{screen_key}`
- Route row container -> `meta__route`
- Source file row or source file list container -> `meta__source`
- Note row container -> `meta__note`
- Blocker row container -> `meta__blocker`

Use the visible row content to classify the metadata row:

- row begins with `Route #/...` -> `meta__route`
- row begins with `Note ...` -> `meta__note`
- row begins with `Blocker ...` -> `meta__blocker`
- row that contains source file chips / code paths -> `meta__source`

## Batch 4: Component And Archive Page Rename

Inside `42:2`:

- `App Shell and Headers` -> `component_group__app_shell_and_headers`
- `Cards, Buttons, Inputs` -> `component_group__cards_buttons_inputs`
- `Settings and Commerce Rows` -> `component_group__settings_and_commerce_rows`
- `Fortune and Result Blocks` -> `component_group__fortune_and_result_blocks`
- `Wellness Focus Blocks` -> `component_group__wellness_focus_blocks`

Inside `43:2`:

- `Superseded Summary-only File` -> `archive_card__superseded_summary_only_file`
- `Invalid Direct Interactive Paths` -> `archive_card__invalid_direct_interactive_paths`

## Post-Rename Verification

After the manual Figma batch:

1. Re-run MCP `get_metadata` on the refreshed appended pages only.
2. Confirm page roots are `section__...`.
3. Confirm page-level wrappers are `content`, `header`, `overview`, `nav_links`, `screen_grid`, `component_grid`, or `archive_grid`.
4. Confirm each screen card root is `screen_card__{screen_key}` and each preview layer is `preview__{screen_key}`.
5. Confirm badges and metadata rows use `badge__...` and `meta__...` names.
6. Only after the refreshed appended set is clean, decide whether the older pre-refresh page set should move to archive or be deleted from the official file.

## Success Condition

The rename pass is complete enough for future sync work when:

- the refreshed appended page range `32:2` through `43:2` is the clean canonical set
- all governed anchors inside that range follow the naming contract
- old pre-refresh pages are no longer treated as the active catalog source
