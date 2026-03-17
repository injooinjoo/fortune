# Figma Page Usage Audit

## Current Runtime Scope

As of `2026-03-14`, the app runtime is contracted to:

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
| `89:2` | `00 Cover & Governance` | `governance_only` | Catalog governance only |
| `90:2` | `10 Entry / Auth / Onboarding` | `active_runtime` | `/`, `/splash`, `/signup`, `/auth/callback`, `/onboarding`, `/onboarding/toss-style` |
| `91:2` | `20 Chat Home / Character` | `active_runtime` | `/chat`, `/character/:id`, plus internal `/chat` states for 일반 채팅, 호기심, survey, result, and onboarding |
| `92:2` | `80 Admin / Policy / Utility` | `active_runtime` | `/profile`, `/premium`, `/privacy-policy`, `/terms-of-service`, `/account-deletion` |
| `93:2` | `90 Components` | `governance_only` | Retained component inventory only |
| `94:2` | `99 Archive` | `archive_only` | Removed product families and historical capture notes |
| `95:2` | `20 Chat Home / Character (refresh append)` | `historical_append` | Earlier chat refresh append retained for history; superseded for Haneul survey/result by `181:2` |
| `180:2` | `20 Chat Home / Character (premium append)` | `historical_append` | Previous premium Haneul append retained for history; superseded by the richer mystical refresh at `181:2` |
| `181:2` | `20 Chat Home / Character (rich mystical append)` | `active_append` | Latest official append containing the rich mystical Haneul Curiosity Survey Step and Curiosity Result Complete captures, plus the refreshed chat home states |

## Official File Status

The official file keeps the retained canonical governance range `89:2` through `94:2` and currently also includes the intentional chat refresh append pages `95:2`, `180:2`, and `181:2`.

There is no current runtime route gap inside the official catalog. `/auth/callback` is now represented as `auth__callback__redirected` on `90:2`.

## Historical Root Ranges To Ignore

These ids may still appear in old screenshots, comments, or docs, but they are no longer present in the official file:

- `32:2`, `33:2`, `34:2`, `42:2`, `43:2`
- `38:2`, `39:2`, `63:2`
- `64:2` through `69:2`
- `82:2` through `87:2`
- `35:2`, `36:2`, `37:2`, `40:2`, `41:2`

## Conclusion

The official design catalog should now be interpreted as a reduced product:

- keep `89:2` through `94:2` as the canonical governance range
- treat `181:2` as the latest live-refresh chat append until the `20 Chat Home / Character` page is consolidated back into the retained range
- keep `180:2` and `95:2` as historical append references only
- keep `89:2`, `93:2`, and `94:2` for governance, components, and archive
- treat any lingering references to removed tabs or direct `/fortune`, `/trend`, `/history`, `/more`, or `/subscription` flows as stale artifacts
