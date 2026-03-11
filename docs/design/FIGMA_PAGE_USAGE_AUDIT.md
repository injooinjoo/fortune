# Figma Page Usage Audit

## Current Runtime Scope

As of `2026-03-11`, the app runtime is contracted to:

- `10 Entry / Auth / Onboarding`
- `20 Chat / Character`
- `80 Admin / Policy / Utility`

Repo evidence:

- Router: `lib/routes/route_config.dart`
- Character routes: `lib/routes/character_routes.dart`
- Auth routes: `lib/routes/routes/auth_routes.dart`
- Figma capture manifest: `playwright/scripts/figma_capture_manifest.js`

## Active Figma Groups

| Figma page group | Status | Runtime coverage |
| --- | --- | --- |
| `00 Cover & Governance` | `governance_only` | Catalog governance only |
| `10 Entry / Auth / Onboarding` | `active_runtime` | `/`, `/splash`, `/signup`, `/auth/callback`, `/onboarding`, `/onboarding/toss-style` |
| `20 Chat / Character` | `active_runtime` | `/chat`, `/character/:id` |
| `80 Admin / Policy / Utility` | `active_runtime` | `/privacy-policy`, `/terms-of-service`, `/account-deletion`, `/manseryeok` |
| `90 Components` | `governance_only` | Retained component inventory only |
| `99 Archive` | `archive_only` | Historical or removed product references |

## Removed Product Groups

The following groups no longer map to runtime and should be treated as deleted product scope:

- `30 Fortune Hub / Interactive`
- `40 Trend`
- `50 Health / Exercise`
- `60 History / Profile / More`
- `70 Commerce / Settings / Support`
- `75 Wellness`

These groups were removed from:

- router/runtime entrypoints
- frontend feature folders
- repo-side Figma capture manifest
- registry/source-of-truth docs
- integration/playwright assets tied to the old multi-tab shell

## Manual Figma Page Delete List

The official file does not expose page-delete mutations through the available MCP tooling, so the following pages must be deleted manually in Figma:

| Node ID | Page |
| --- | --- |
| `35:2` | `30 Fortune Hub / Interactive` |
| `36:2` | `40 Trend` |
| `37:2` | `50 Health / Exercise` |
| `38:2` | `60 History / Profile / More` |
| `39:2` | `70 Commerce / Settings / Support` |
| `40:2` | `75 Wellness` |

## Conclusion

The official design catalog should now be interpreted as a reduced product:

- keep `10`, `20`, and `80` as live runtime coverage
- keep `00`, `90`, and `99` for governance/components/archive
- delete the manual Figma pages listed above
- treat any lingering references to `30/40/50/60/70/75` as stale artifacts
