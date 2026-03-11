# Fortune Figma Layer Naming Standard

## Purpose

This document defines the canonical internal layer names for the official Figma file:

- Official file: [Fortune Screen Catalog - Official](https://www.figma.com/design/dkx3Biwe5xkiMQWsjq95LA)
- File key: `dkx3Biwe5xkiMQWsjq95LA`

Visible titles in the catalog remain human-readable. Internal Figma frame and layer names must follow the machine-readable contract below so MCP audits, capture regeneration, and repo-side governance stay aligned.

## Naming Grammar

### Top-level section frames

Top-level governed pages use:

`section__{nn}__{slug}`

Examples:

- `section__00__cover_governance`
- `section__30__fortune_interactive`
- `section__90__components`

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
- `screen_card__interactive_face_reading__result__analysis`

### Governance and archive cards

Non-screen informational cards use:

- governance/cover cards: `overview_card__{slug}`
- archive cards: `archive_card__{slug}`

Examples:

- `overview_card__official_file`
- `overview_card__runtime_blockers`
- `archive_card__invalid_direct_interactive_paths`

### Component inventory cards

Component inventory cards use:

`component_group__{slug}`

Examples:

- `component_group__app_shell_and_headers`
- `component_group__fortune_and_result_blocks`

## Forbidden Generic Names

Do not leave governed structural layers with these ad hoc names:

- `Main Content (...)`
- `Article`
- `Container`
- `Text`
- `Link`
- `Code`

These may exist temporarily during import, but the official file must be normalized to the canonical layer contract before the sync is considered complete.

## Canonical Section Roots

| Visible title | Canonical layer name |
| --- | --- |
| `00 Cover & Governance` | `section__00__cover_governance` |
| `10 Entry / Auth / Onboarding` | `section__10__entry_auth_onboarding` |
| `20 Chat Home / Character` | `section__20__chat_character` |
| `30 Fortune Hub / Interactive` | `section__30__fortune_interactive` |
| `40 Trend` | `section__40__trend` |
| `50 Health / Exercise` | `section__50__health_exercise` |
| `60 History / Profile / More` | `section__60__history_profile_more` |
| `70 Commerce / Settings / Support` | `section__70__commerce_settings_support` |
| `75 Wellness` | `section__75__wellness` |
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
