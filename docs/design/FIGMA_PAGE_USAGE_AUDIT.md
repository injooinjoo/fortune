# Figma Page Usage Audit

## Current Runtime Scope

As of `2026-03-13`, the app runtime is contracted to:

- `10 Entry / Auth / Onboarding`
- `20 Chat Home / Character`
- `80 Admin / Policy / Utility`

Repo evidence:

- Router: `lib/routes/route_config.dart`
- Character routes: `lib/routes/character_routes.dart`
- Auth routes: `lib/routes/routes/auth_routes.dart`
- Figma capture manifest: `playwright/scripts/figma_capture_manifest.js`

## Canonical Current Page Roots

| Node ID | Figma page group | Status | Runtime coverage |
| --- | --- | --- | --- |
| `64:2` | `00 Cover & Governance` | `governance_only` | Catalog governance only |
| `65:2` | `10 Entry / Auth / Onboarding` | `active_runtime` | `/`, `/splash`, `/signup`, `/onboarding`, `/onboarding/toss-style` |
| `66:2` | `20 Chat Home / Character` | `active_runtime` | `/chat`, `/character/:id`, plus internal `/chat` states for 일반 채팅, 호기심, survey, result, onboarding, and account sheet |
| `67:2` | `80 Admin / Policy / Utility` | `active_runtime` | `/premium`, `/privacy-policy`, `/terms-of-service`, `/account-deletion` |
| `68:2` | `90 Components` | `governance_only` | Retained component inventory only |
| `69:2` | `99 Archive` | `archive_only` | Stale append generations and legacy delete targets |

## Stale Page Roots Still In The Official File

### Superseded current-state append generation

| Node ID | Page |
| --- | --- |
| `32:2` | `00 Cover & Governance` |
| `33:2` | `10 Entry / Auth / Onboarding` |
| `34:2` | `20 Chat Home / Character` |
| `42:2` | `90 Components` |
| `43:2` | `99 Archive` |

These pages are older append generations and should not be used for current-state reviews, MCP audits, or route verification.

### Legacy product groups

| Node ID | Page |
| --- | --- |
| `38:2` | `60 History / Profile / More` |
| `39:2` | `70 Commerce / Settings / Support` |
| `63:2` | `60 History / Profile / More` |

These groups no longer map to runtime and should be treated as deleted product scope.

## Legacy Roots Deleted From The Official File

The following legacy roots were deleted from the official file on `2026-03-13`:

| Node ID | Page |
| --- | --- |
| `60:2` | `30 Fortune Hub / Interactive` |
| `61:2` | `40 Trend` |
| `62:2` | `50 Health / Exercise` |

## Current Runtime Route Gap

`/auth/callback` still exists in app runtime via `lib/routes/routes/auth_routes.dart` and `lib/screens/auth/callback_page.dart`, but it does not have a dedicated screen card inside the canonical current page roots `64:2` through `69:2`.

The older append generation `33:2` contained a callback card, so treat that as historical reference only, not current-state coverage.

## Historical Node IDs To Ignore

Older docs may still mention:

- `35:2`
- `36:2`
- `37:2`
- `40:2`
- `41:2`

These page ids are not present in the current official file and should not be used for cleanup or rename work.

## Manual Figma Cleanup Order

1. Delete the stale current-state append roots `32:2`, `33:2`, `34:2`, `42:2`, and `43:2`.
2. Delete the remaining legacy product roots `38:2`, `39:2`, and `63:2`.
3. Keep only `64:2` through `69:2` as the canonical official catalog range.
4. Run the rename pass only on the retained canonical range.

## Conclusion

The official design catalog should now be interpreted as a reduced product:

- keep only `64:2` through `69:2` as canonical
- represent `/chat` internal current-state surfaces directly inside `66:2`
- keep `64:2`, `68:2`, and `69:2` for governance, components, and archive
- treat `60:2`, `61:2`, and `62:2` as completed deletions
- delete the stale page roots listed above
- treat any lingering references to removed tabs or direct `/fortune`, `/trend`, `/history`, `/profile`, `/more`, or `/subscription` flows as stale artifacts
