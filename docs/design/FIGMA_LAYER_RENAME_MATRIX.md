# Fortune Figma Layer Rename Matrix

## Purpose

This matrix is the operational rename checklist for the official Figma file.

- Official file: [Fortune Screen Catalog - Official](https://www.figma.com/design/dkx3Biwe5xkiMQWsjq95LA)
- File key: `dkx3Biwe5xkiMQWsjq95LA`

The current MCP toolset can audit the file but cannot directly rename existing Figma nodes. Apply these renames in Figma, then verify structure through MCP `get_metadata`.

## Top-level section roots

| Current root name | Target root name |
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
| `Main Content (20 Chat Home / Character)` | `section__20__chat_character` |
| `Main Content (30 Fortune Hub / Interactive)` | `section__30__fortune_interactive` |
| `Main Content (40 Trend)` | `section__40__trend` |
| `Main Content (50 Health / Exercise)` | `section__50__health_exercise` |
| `Main Content (60 History / Profile / More)` | `section__60__history_profile_more` |
| `Main Content (70 Commerce / Settings / Support)` | `section__70__commerce_settings_support` |
| `Main Content (75 Wellness)` | `section__75__wellness` |
| `Main Content (90 Components)` | `section__90__components` |
| `Main Content (99 Archive)` | `section__99__archive` |

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
| phone shell / device wrapper | `device_frame` |

## Screen card contract

Apply this contract to every governed screen:

| Current layer pattern | Target layer pattern |
| --- | --- |
| `Article` | `screen_card__{screen_key}` |
| `Image ({screen_key})` | `preview__{screen_key}` |
| `Text` badge with `Live Capture` | `badge__live_capture` |
| `Text` badge with `Placeholder Spec` | `badge__placeholder_spec` |
| route row | `meta__route` |
| source chip/list row | `meta__source` |
| note row | `meta__note` |
| blocker row | `meta__blocker` |

Representative examples:

- `screen_card__auth__signup__default`
- `preview__auth__signup__default`
- `screen_card__fortune__hub__default`
- `preview__fortune__hub__default`
- `screen_card__profile__root__auth_gated`
- `preview__profile__root__auth_gated`

## Governance cards

| Visible title | Target layer name |
| --- | --- |
| `Single Figma Source of Truth` | `overview_card__official_file` |
| `Hybrid Screen Catalog` | `overview_card__capture_modes` |
| `35 live / 26 placeholder` or current coverage card | `overview_card__current_coverage` |
| `iPhone 15 Pro Only` | `overview_card__device_standard` |
| `Hash Router and Nested Paths` | `overview_card__routing_notes` |
| `Auth / Backend / Extra State` | `overview_card__runtime_blockers` |

## Component inventory groups

| Visible title | Target layer name |
| --- | --- |
| `App Shell and Headers` | `component_group__app_shell_and_headers` |
| `Cards, Buttons, Inputs` | `component_group__cards_buttons_inputs` |
| `Settings and Commerce Rows` | `component_group__settings_and_commerce_rows` |
| `Fortune and Result Blocks` | `component_group__fortune_and_result_blocks` |
| `Wellness Focus Blocks` | `component_group__wellness_focus_blocks` |

## Archive cards

| Visible title | Target layer name |
| --- | --- |
| `Superseded Summary-only File` | `archive_card__superseded_summary_only_file` |
| `Invalid Direct Interactive Paths` | `archive_card__invalid_direct_interactive_paths` |

## Verification pass after rename

1. Run MCP `get_metadata(fileKey="dkx3Biwe5xkiMQWsjq95LA", nodeId="0:1")`.
2. Confirm section roots use only `section__...` names.
3. Confirm governed structures no longer expose `Article`, `Container`, `Text`, `Link`, or `Code`.
4. Confirm representative screen cards expose `screen_card__...`, `preview__...`, `meta__...`, and badge names.
