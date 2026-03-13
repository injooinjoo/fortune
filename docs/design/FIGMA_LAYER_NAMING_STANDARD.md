# Fortune Figma Layer Naming Standard

## Purpose

This document defines the canonical internal layer names for the official Figma file:

- Official file: [Fortune Screen Catalog - Official](https://www.figma.com/design/dkx3Biwe5xkiMQWsjq95LA)
- File key: `dkx3Biwe5xkiMQWsjq95LA`

Visible titles in the catalog remain human-readable. Internal Figma frame and layer names must follow the machine-readable contract below so MCP audits, capture regeneration, and repo-side governance stay aligned.

## Governed Scope

The canonical naming contract is enforced on governed anchors, not every leaf text node in the imported Figma structure.

Governed anchors are:

- page root frames
- page-level structural wrappers
- governance cards
- screen cards
- component group cards
- archive cards
- preview image layers
- badge roots
- metadata row roots

Leaf text nodes that only hold visible copy may keep content-driven names after import, as long as their governed parent layer already uses the canonical machine-readable name.

## Naming Grammar

### Top-level section frames

Top-level governed pages use:

`section__{nn}__{slug}`

Examples:

- `section__00__cover_governance`
- `section__20__chat_character`
- `section__99__archive`

Only the retained canonical page roots should be normalized:

- `64:2` `00 Cover & Governance`
- `65:2` `10 Entry / Auth / Onboarding`
- `66:2` `20 Chat Home / Character`
- `67:2` `80 Admin / Policy / Utility`
- `68:2` `90 Components`
- `69:2` `99 Archive`

Stale roots such as `32:2`, `33:2`, `34:2`, `38:2`, `39:2`, `42:2`, `43:2`, and `63:2` are delete targets, not canonical roots.

The legacy roots `60:2`, `61:2`, and `62:2` were already deleted from the official file on `2026-03-13`.

### Shared structural roles

Only these generic structural role names are allowed for section internals:

- `content`
- `header`
- `overview`
- `screen_grid`
- `component_grid`
- `archive_grid`
- `nav_links`
- `device_frame`

These names are reserved because the catalog generator and MCP capture verification rely on them.

### Screen cards

Each screen card uses:

- card root: `screen_card__{screen_key}`
- preview/image layer: `preview__{screen_key}`
- live badge: `badge__live_capture`
- placeholder badge: `badge__placeholder_spec`
- route metadata row: `meta__route`
- source metadata row/list: `meta__source`
- note metadata row: `meta__note`
- blocker metadata row: `meta__blocker`

Examples:

- `screen_card__auth__signup__default`
- `preview__auth__signup__default`
- `screen_card__chat__home__general_default`
- `preview__chat__home__general_default`
- `screen_card__chat__survey__fortune_step`
- `screen_card__premium__insight__default`

### Governance and archive cards

Non-screen informational cards use:

- governance/cover cards: `overview_card__{slug}`
- archive cards: `archive_card__{slug}`

Examples:

- `overview_card__official_file`
- `overview_card__runtime_blockers`
- `archive_card__superseded_append_generation`
- `archive_card__legacy_product_delete_targets`

### Component inventory cards

Component inventory cards use:

`component_group__{slug}`

Examples:

- `component_group__chat_shell_and_headers`
- `component_group__conversation_survey_and_result_blocks`
- `component_group__account_premium_and_policy_controls`

## Forbidden Generic Names

Do not leave governed anchor layers with these ad hoc names:

- `Main Content (...)`
- `Article`
- `Container`
- `Text`
- `Link`
- `Code`

These may exist temporarily during import, but page roots, page-level wrappers, cards, previews, badges, and metadata rows must be normalized to the canonical layer contract before the sync is considered complete.

For the current cleanup order, use [FIGMA_APPEND_RENAME_RUNBOOK.md](./FIGMA_APPEND_RENAME_RUNBOOK.md) to delete stale roots first and limit the rename pass to `64:2` through `69:2`.

## Canonical Section Roots

| Visible title | Canonical layer name |
| --- | --- |
| `00 Cover & Governance` | `section__00__cover_governance` |
| `10 Entry / Auth / Onboarding` | `section__10__entry_auth_onboarding` |
| `20 Chat Home / Character` | `section__20__chat_character` |
| `80 Admin / Policy / Utility` | `section__80__admin_policy_utility` |
| `90 Components` | `section__90__components` |
| `99 Archive` | `section__99__archive` |

## MCP Operator Workflow

### Audit

Use `get_metadata` to inspect structure after rename batches. This is the primary audit tool for verifying section roots, screen-card names, and repeated structural roles.

### Visual verification

Use `get_screenshot` on representative screen-card nodes to verify that renaming did not change layout or visual output.

### Design context

Use `get_design_context` only on exact screen-card nodes such as `screen_card__auth__signup__default`. Do not run it on the catalog root or full-page wrappers because those nodes are too broad for implementation work.

## Code Connect Status

Code Connect is intentionally deferred for this catalog. The current Figma seat does not support Code Connect access, so this contract is designed to keep the file ready for future adoption without depending on it now.
