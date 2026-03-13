# Fortune Figma Layer Rename Matrix

## Purpose

This matrix is the operational rename checklist for the official Figma file.

- Official file: [Fortune Screen Catalog - Official](https://www.figma.com/design/dkx3Biwe5xkiMQWsjq95LA)
- File key: `dkx3Biwe5xkiMQWsjq95LA`

The current MCP toolset can audit the file but cannot directly rename existing Figma nodes. Apply these renames in Figma, then verify structure through MCP `get_metadata`.

Use [FIGMA_APPEND_RENAME_RUNBOOK.md](./FIGMA_APPEND_RENAME_RUNBOOK.md) for the exact current canonical range and current historical ids.

## Top-level section roots

Only the retained canonical pages should be renamed:

| Current root name | Target root name |
| --- | --- |
| `00 Cover & Governance` | `section__00__cover_governance` |
| `10 Entry / Auth / Onboarding` | `section__10__entry_auth_onboarding` |
| `20 Chat Home / Character` | `section__20__chat_character` |
| `80 Admin / Policy / Utility` | `section__80__admin_policy_utility` |
| `90 Components` | `section__90__components` |
| `99 Archive` | `section__99__archive` |

Historical roots such as `32:2`, `33:2`, `34:2`, `38:2`, `39:2`, `42:2`, `43:2`, `63:2`, `64:2`-`69:2`, and `82:2`-`87:2` are not rename targets.

## Shared structural roles

Apply these renames wherever governed catalog structure still uses generic names:

| Current generic name | Target role |
| --- | --- |
| `Header` | `header` |
| `Main Content` | `content` |
| section wrapper holding screen cards | `screen_grid` |
| section wrapper holding component groups | `component_grid` |
| section wrapper holding archive cards | `archive_grid` |
| overview wrapper on cover page | `overview` |
| catalog link wrapper on cover page | `nav_links` |
| phone shell or device wrapper | `device_frame` |

## Screen card contract

Apply this contract to every governed retained screen:

| Current layer pattern | Target layer pattern |
| --- | --- |
| `Article` | `screen_card__{screen_key}` |
| preview image or preview placeholder container | `preview__{screen_key}` |
| badge with `Live Capture` | `badge__live_capture` |
| badge with `Placeholder Spec` | `badge__placeholder_spec` |
| route row | `meta__route` |
| source chip/list row | `meta__source` |
| note row | `meta__note` |
| blocker row | `meta__blocker` |

Representative retained examples:

- `screen_card__auth__splash__default`
- `screen_card__auth__signup__default`
- `screen_card__chat__home__default`
- `screen_card__chat__home__general_default`
- `screen_card__chat__home__curiosity_default`
- `screen_card__chat__survey__fortune_step`
- `screen_card__chat__result__fortune_complete`
- `screen_card__chat__profile_sheet__default`
- `screen_card__premium__insight__default`
- `screen_card__account__deletion__auth_gated`

## Governance cards

| Visible title | Target layer name |
| --- | --- |
| `Single Figma Source of Truth` | `overview_card__official_file` |
| `Hybrid Screen Catalog` | `overview_card__capture_modes` |
| current coverage card such as `10 live / 8 placeholder` | `overview_card__current_coverage` |
| `iPhone 15 Pro Only` | `overview_card__device_standard` |
| `Retained Routes and In-Chat States` | `overview_card__routing_notes` |
| `Auth, First-Run, and Runtime Gates` | `overview_card__runtime_blockers` |

## Component inventory groups

| Visible title | Target layer name |
| --- | --- |
| `Chat Shell and Headers` | `component_group__chat_shell_and_headers` |
| `Character Entry and Onboarding` | `component_group__character_entry_and_onboarding` |
| `Conversation, Survey, and Result Blocks` | `component_group__conversation_survey_and_result_blocks` |
| `Account, Premium, and Policy Controls` | `component_group__account_premium_and_policy_controls` |
| `Design System Core` | `component_group__design_system_core` |

## Archive cards

| Visible title | Target layer name |
| --- | --- |
| `Superseded Append Generation` | `archive_card__superseded_append_generation` |
| `Legacy Product Delete Targets` | `archive_card__legacy_product_delete_targets` |

## Verification pass after rename

1. Run MCP `get_metadata(fileKey=\"dkx3Biwe5xkiMQWsjq95LA\", nodeId=\"89:2\")` through `nodeId=\"94:2\"`.
2. Confirm section roots use only `section__...` names.
3. Confirm governed structures no longer expose `Article`, `Container`, `Text`, `Link`, or `Code`.
4. Confirm representative screen cards expose `screen_card__...`, `preview__...`, `meta__...`, and badge names.
5. Confirm no historical roots listed in the cleanup runbook have reappeared.
