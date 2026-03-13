# Fortune Figma Append Rename Runbook

## Purpose

This runbook is the manual Figma-side rename plan for the official file as of `2026-03-14`.

- Official file: [Fortune Screen Catalog - Official](https://www.figma.com/design/dkx3Biwe5xkiMQWsjq95LA)
- File key: `dkx3Biwe5xkiMQWsjq95LA`
- Canonical current page roots: `89:2` through `94:2`

The current MCP workflow can append refreshed catalog pages into the official file, but it cannot rename existing Figma nodes. The current cleanup pass is already complete, so this runbook now narrows the manual pass to:

1. keeping only the latest canonical current range in the official file
2. renaming governed anchors inside that retained canonical range only

## Current Cleanup Status

No stale legacy page roots remain in the official file.

Historical ranges that were removed and should not be restored:

- `32:2`, `33:2`, `34:2`, `42:2`, `43:2`
- `38:2`, `39:2`, `63:2`
- `64:2` through `69:2`
- `82:2` through `87:2`

If a future append creates duplicates again, delete the older current range first and keep only the newest refreshed range before any rename batch.

## Rename Scope Rule

Rename only the retained canonical current-state range:

- `89:2` `00 Cover & Governance`
- `90:2` `10 Entry / Auth / Onboarding`
- `91:2` `20 Chat Home / Character`
- `92:2` `80 Admin / Policy / Utility`
- `93:2` `90 Components`
- `94:2` `99 Archive`

## Governed Rename Boundary

This manual batch must rename only the governed anchors below:

- page root frames
- page-level `Main Content` / `Header` / main grid wrappers
- governance cards, screen cards, component group cards, archive cards
- screen preview image layers
- screen status badges
- metadata row roots: route, source, note, blocker

Leaf text nodes that only hold visible copy can remain content-driven labels. Example: the text layer whose visible name is `Route #/chat` does not need a machine-readable rename if its parent row is renamed to `meta__route`.

## Page Root Targets

| Node id | Current name | Target name |
| --- | --- | --- |
| `89:2` | `00 Cover & Governance` | `section__00__cover_governance` |
| `90:2` | `10 Entry / Auth / Onboarding` | `section__10__entry_auth_onboarding` |
| `91:2` | `20 Chat Home / Character` | `section__20__chat_character` |
| `92:2` | `80 Admin / Policy / Utility` | `section__80__admin_policy_utility` |
| `93:2` | `90 Components` | `section__90__components` |
| `94:2` | `99 Archive` | `section__99__archive` |

Shared wrapper targets remain the same across pages:

- `Main Content` -> `content`
- `Header` -> `header`
- cover overview wrapper -> `overview`
- cover page links wrapper -> `nav_links`
- screen page wrapper -> `screen_grid`
- component page wrapper -> `component_grid`
- archive page wrapper -> `archive_grid`

## Card Root Contract

Within each retained page:

1. Rename every top-level `Article` directly under `screen_grid` to `screen_card__{screen_key}`.
2. The `screen_key` comes from the repo manifest, not the visible title.
3. Rename every preview image or preview placeholder container to `preview__{screen_key}`.

Representative retained examples:

- `auth__splash__default` -> `screen_card__auth__splash__default`
- `auth__callback__redirected` -> `screen_card__auth__callback__redirected`
- `chat__home__default` -> `screen_card__chat__home__default`
- `chat__home__general_default` -> `screen_card__chat__home__general_default`
- `chat__home__curiosity_default` -> `screen_card__chat__home__curiosity_default`
- `chat__survey__fortune_step` -> `screen_card__chat__survey__fortune_step`
- `chat__result__fortune_complete` -> `screen_card__chat__result__fortune_complete`
- `chat__onboarding__character_intro` -> `screen_card__chat__onboarding__character_intro`
- `premium__insight__default` -> `screen_card__premium__insight__default`
- `account__deletion__auth_gated` -> `screen_card__account__deletion__auth_gated`

Component and archive pages use different card roots:

- `93:2` component cards -> `component_group__{slug}`
- `94:2` archive cards -> `archive_card__{slug}`

Governance page `89:2` overview cards:

- `Single Figma Source of Truth` -> `overview_card__official_file`
- `Hybrid Screen Catalog` -> `overview_card__capture_modes`
- `10 live / 8 placeholder` -> `overview_card__current_coverage`
- `iPhone 15 Pro Only` -> `overview_card__device_standard`
- `Retained Routes and In-Chat States` -> `overview_card__routing_notes`
- `Auth, First-Run, and Runtime Gates` -> `overview_card__runtime_blockers`

## Badge, Preview, And Metadata Contract

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

## Post-Rename Verification

After the manual Figma batch:

1. Re-run MCP `get_metadata` on `89:2` through `94:2`.
2. Confirm page roots are `section__...`.
3. Confirm page-level wrappers are `content`, `header`, `overview`, `nav_links`, `screen_grid`, `component_grid`, or `archive_grid`.
4. Confirm each screen card root is `screen_card__{screen_key}` and each preview layer is `preview__{screen_key}`.
5. Confirm badges and metadata rows use `badge__...` and `meta__...` names.
6. Confirm no historical ranges listed in `Current Cleanup Status` reappear in the official file.

## Success Condition

The manual cleanup is complete enough for future sync work when:

- only `89:2` through `94:2` remain as the retained official page roots
- all governed anchors inside that range follow the naming contract
- removed append generations and legacy product pages do not reappear
