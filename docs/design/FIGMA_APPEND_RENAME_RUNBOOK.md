# Fortune Figma Append Rename Runbook

## Purpose

This runbook is the manual Figma-side cleanup and rename plan for the official file as of `2026-03-13`.

- Official file: [Fortune Screen Catalog - Official](https://www.figma.com/design/dkx3Biwe5xkiMQWsjq95LA)
- File key: `dkx3Biwe5xkiMQWsjq95LA`
- Canonical current page roots: `64:2` through `69:2`

The current MCP workflow can append refreshed catalog pages into the official file, but it cannot delete or rename existing Figma nodes. This document narrows the manual pass to:

1. deleting stale page roots already confirmed in the official file
2. renaming governed anchors inside the retained canonical range only

## Cleanup First

Delete these stale page roots before any rename pass:

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

### Ignore These Historical IDs

Do not spend time hunting for:

- `35:2`
- `36:2`
- `37:2`
- `40:2`
- `41:2`

Those ids are not present in the current official file.

## Rename Scope Rule

Rename only the retained canonical current-state range:

- `64:2` `00 Cover & Governance`
- `65:2` `10 Entry / Auth / Onboarding`
- `66:2` `20 Chat Home / Character`
- `67:2` `80 Admin / Policy / Utility`
- `68:2` `90 Components`
- `69:2` `99 Archive`

Do not rename stale pages first. Delete them instead.

## Governed Rename Boundary

This manual batch must rename only the governed anchors below:

- page root frames
- page-level `Main Content` / `Header` / main grid wrappers
- governance cards, screen cards, component group cards, archive cards
- screen preview image layers
- screen status badges
- metadata row roots: route, source, note, blocker

Leaf text nodes that only hold visible copy can remain content-driven labels. Example: the text layer whose visible name is `Route #/chat` does not need a machine-readable rename if its parent row is renamed to `meta__route`.

## Batch 1: Page Root And Main Wrapper Rename

Apply these renames in the Figma layer panel:

| Node id | Current name | Target name |
| --- | --- | --- |
| `64:2` | `00 Cover & Governance` | `section__00__cover_governance` |
| `64:3` | `Main Content` | `content` |
| `64:4` | `Header` | `header` |
| `64:15` | `Container` | `overview` |
| `64:108` | `Section` | `nav_links` |
| `65:2` | `10 Entry / Auth / Onboarding` | `section__10__entry_auth_onboarding` |
| `65:3` | `Main Content` | `content` |
| `65:4` | `Header` | `header` |
| `65:15` | `Section` | `screen_grid` |
| `66:2` | `20 Chat Home / Character` | `section__20__chat_character` |
| `66:3` | `Main Content` | `content` |
| `66:4` | `Header` | `header` |
| `66:15` | `Section` | `screen_grid` |
| `67:2` | `80 Admin / Policy / Utility` | `section__80__admin_policy_utility` |
| `67:3` | `Main Content` | `content` |
| `67:4` | `Header` | `header` |
| `67:15` | `Section` | `screen_grid` |
| `68:2` | `90 Components` | `section__90__components` |
| `68:3` | `Main Content` | `content` |
| `68:4` | `Header` | `header` |
| `68:15` | `Section` | `component_grid` |
| `69:2` | `99 Archive` | `section__99__archive` |
| `69:3` | `Main Content` | `content` |
| `69:4` | `Header` | `header` |
| `69:15` | `Section` | `archive_grid` |

## Batch 2: Card Root Rename

Within each retained page:

1. Rename every top-level `Article` directly under `screen_grid` to `screen_card__{screen_key}`.
2. The `screen_key` comes from the repo manifest, not the visible title.
3. Rename every preview image or preview placeholder container to `preview__{screen_key}`.

Representative retained examples:

- `auth__splash__default` -> `screen_card__auth__splash__default`
- `auth__signup__default` -> `screen_card__auth__signup__default`
- `chat__home__default` -> `screen_card__chat__home__default`
- `chat__home__general_default` -> `screen_card__chat__home__general_default`
- `chat__home__curiosity_default` -> `screen_card__chat__home__curiosity_default`
- `chat__survey__fortune_step` -> `screen_card__chat__survey__fortune_step`
- `chat__result__fortune_complete` -> `screen_card__chat__result__fortune_complete`
- `character__profile__luts` -> `screen_card__character__profile__luts`
- `premium__insight__default` -> `screen_card__premium__insight__default`
- `account__deletion__auth_gated` -> `screen_card__account__deletion__auth_gated`

Component and archive pages use different card roots:

- `68:2` component `Article` cards -> `component_group__{slug}`
- `69:2` archive `Article` cards -> `archive_card__{slug}`

Governance page `64:2` overview cards:

- `Single Figma Source of Truth` -> `overview_card__official_file`
- `Hybrid Screen Catalog` -> `overview_card__capture_modes`
- `9 live / 8 placeholder` -> `overview_card__current_coverage`
- `iPhone 15 Pro Only` -> `overview_card__device_standard`
- `Retained Routes and In-Chat States` -> `overview_card__routing_notes`
- `Auth, First-Run, and Runtime Gates` -> `overview_card__runtime_blockers`

## Batch 3: Badge, Preview, And Metadata Rename

For every retained screen card:

- badge with visible text `Live Capture` -> `badge__live_capture`
- badge with visible text `Placeholder Spec` -> `badge__placeholder_spec`
- device screenshot/image layer or preview placeholder root -> `preview__{screen_key}`
- route row container -> `meta__route`
- source file row or source file list container -> `meta__source`
- note row container -> `meta__note`
- blocker row container -> `meta__blocker`

Use the visible row content to classify the metadata row:

- row begins with `Route #/...` -> `meta__route`
- row begins with `Note ...` -> `meta__note`
- row begins with `Blocker ...` -> `meta__blocker`
- row that contains source file chips or code paths -> `meta__source`

## Batch 4: Component And Archive Page Rename

Inside `68:2`:

- `Chat Shell and Headers` -> `component_group__chat_shell_and_headers`
- `Character Entry and Onboarding` -> `component_group__character_entry_and_onboarding`
- `Conversation, Survey, and Result Blocks` -> `component_group__conversation_survey_and_result_blocks`
- `Account, Premium, and Policy Controls` -> `component_group__account_premium_and_policy_controls`
- `Design System Core` -> `component_group__design_system_core`

Inside `69:2`:

- `Superseded Append Generation` -> `archive_card__superseded_append_generation`
- `Legacy Product Delete Targets` -> `archive_card__legacy_product_delete_targets`

## Post-Rename Verification

After the manual Figma batch:

1. Re-run MCP `get_metadata` on `64:2` through `69:2`.
2. Confirm page roots are `section__...`.
3. Confirm page-level wrappers are `content`, `header`, `overview`, `nav_links`, `screen_grid`, `component_grid`, or `archive_grid`.
4. Confirm each screen card root is `screen_card__{screen_key}` and each preview layer is `preview__{screen_key}`.
5. Confirm badges and metadata rows use `badge__...` and `meta__...` names.
6. Confirm stale roots listed in the cleanup section are no longer present.

## Success Condition

The manual cleanup is complete enough for future sync work when:

- only `64:2` through `69:2` remain as the retained official page roots
- all governed anchors inside that range follow the naming contract
- stale append generations and legacy product pages are no longer present in the official file
