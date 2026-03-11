# Figma Page Usage Audit

## Scope

This audit maps the visible top-level Figma page groups from the official catalog to the current runtime router and active app surfaces.

Audit basis:

- Figma structure from the official catalog screenshot
- Figma MCP metadata audit on `2026-03-11` via `get_metadata(fileKey="dkx3Biwe5xkiMQWsjq95LA", nodeId="0:1")`
- Figma MCP metadata audit on `2026-03-11` via refreshed appended page range `get_metadata(..., nodeId="32:2"..."43:2")`
- Router definitions in `lib/routes/route_config.dart`
- Nested route groups in:
  - `lib/routes/routes/auth_routes.dart`
  - `lib/routes/routes/interactive_routes.dart`
  - `lib/routes/routes/trend_routes.dart`
  - `lib/routes/routes/wellness_routes.dart`
  - `lib/routes/character_routes.dart`
- Current official design docs:
  - `docs/design/FIGMA_LAYER_NAMING_STANDARD.md`
  - `docs/design/FIGMA_SOURCE_OF_TRUTH.md`
  - `docs/design/FIGMA_SCREEN_COMPONENT_REGISTRY.md`

This document answers one question only:

`Which Figma page groups still map to current product/runtime usage, and which should be treated as governance-only, archive-only, or duplicate review candidates?`

## Status Legend

- `active_runtime`: backed by live routes or active runtime states
- `governance_only`: needed for design governance but not a runtime page
- `archive_only`: intentionally non-runtime; keep only as historical reference
- `duplicate_review`: likely duplicate catalog wrappers and not canonical page groups

## Canonical Top-Level Groups

| Figma page group | Status | Why |
| --- | --- | --- |
| `00 Cover & Governance` | `governance_only` | Catalog cover/admin meta page, not an app route |
| `10 Entry / Auth / Onboarding` | `active_runtime` | `/`, `/splash`, `/signup`, `/auth/callback`, `/onboarding`, `/onboarding/toss-style` |
| `20 Chat Home / Character` | `active_runtime` | `/chat`, `/character/:id` are active |
| `30 Fortune Hub / Interactive` | `active_runtime` | `/fortune`, `/interactive/*` active |
| `40 Trend` | `active_runtime` | `/trend`, `/trend/*` active |
| `50 Health / Exercise` | `active_runtime` | `/health-toss`, `/medical-document-result`, `/exercise`, `/sports-game` active |
| `60 History / Profile / More` | `active_runtime` | `/history`, `/more`, `/profile/*` active |
| `70 Commerce / Settings / Support` | `active_runtime` | `/premium`, `/subscription`, `/token-purchase`, `/help`, `/privacy-policy`, `/terms-of-service`, profile settings routes active |
| `75 Wellness` | `active_runtime` | `/wellness`, `/wellness/meditation` active |
| `80 Admin / Policy / Utility` | `active_runtime` | `/manseryeok` active |
| `90 Components` | `governance_only` | Component inventory, not a runtime page bucket |
| `99 Archive` | `archive_only` | Explicit historical/retired surface bucket |

Target canonical layer roots for these groups are defined in [FIGMA_LAYER_NAMING_STANDARD.md](./FIGMA_LAYER_NAMING_STANDARD.md).

## Duplicate Review Groups

The following visible groups are not canonical runtime buckets by themselves and should be reviewed as likely duplicates of the numbered top-level groups:

- `Main Content (20 Chat Home / Character)`
- `Main Content (30 Fortune Hub / Interactive)`
- `Main Content (40 Trend)`
- `Main Content (50 Health / Exercise)`
- `Main Content (60 History / Profile / More)`
- `Main Content (70 Commerce / Settings / Support)`
- `Main Content (75 Wellness)`
- `Main Content (90 Components)`
- `Main Content (99 Archive)`

Recommendation:

1. Treat the numbered groups (`20`, `30`, `40`, etc.) as the canonical page buckets and normalize their layer names to `section__...`.
2. Keep `Main Content (...)` wrappers only if they are required for:
   - prototype flows
   - export/layout presentation
   - preserved annotation history
3. If a `Main Content (...)` page only mirrors the same frames already stored under the numbered canonical bucket, move it to `99 Archive` or remove it from active governance.

## Important Runtime Corrections

### `/home` is no longer a standalone surface

Current runtime behavior in `lib/routes/route_config.dart`:

- `/chat` is the actual main entry surface
- `/home` is a redirect to `/chat`

Implication for Figma:

- Any old Figma page that still represents a separate `Home dashboard` should not be treated as an active independent screen
- If that content is still valuable, relabel it under chat-first behavior or move it to `99 Archive`

### `20 Chat Home / Character` should map to current chat-first shell

This bucket is still active, but it should represent the current runtime stack, not the removed legacy chat home implementation.

Preferred runtime mapping:

- `#/chat`
- `#/character/:id`

Do not treat removed legacy chat-home variants as active just because they once lived in this bucket.

## Keep / Review / Archive Summary

### Keep as active runtime buckets

- `10 Entry / Auth / Onboarding`
- `20 Chat Home / Character`
- `30 Fortune Hub / Interactive`
- `40 Trend`
- `50 Health / Exercise`
- `60 History / Profile / More`
- `70 Commerce / Settings / Support`
- `75 Wellness`
- `80 Admin / Policy / Utility`

### Keep, but not as runtime pages

- `00 Cover & Governance`
- `90 Components`

### Keep only as archive/history

- `99 Archive`

### Review for dedupe

- every `Main Content (...)` bucket shown in the file tree

## Practical Cleanup Rule For Figma

When auditing the official file:

1. If a page group matches a live route bucket above, keep it.
2. If a page group is `00` or `90`, keep it as governance/component infrastructure.
3. If a page group is `99`, do not count it as active UI coverage.
4. If a page group starts with `Main Content (...)`, assume `duplicate_review` until a prototype/export dependency is confirmed.
5. If a page/frame represents old standalone `/home` behavior, archive it unless it has already been re-scoped to `/chat`.

## Current Conclusion

Based on the current repository runtime:

- The numbered top-level page groups are mostly correct and still useful.
- The biggest Figma cleanup target is not the numbered buckets.
- The biggest cleanup target is the duplicated `Main Content (...)` layer/page structure plus any old `/home`-era chat/dashboard frames.
- The refreshed appended pages fix coverage content, but they still arrive with generic `Main Content` / `Header` / `Article` / `Container` wrappers, so naming cleanup remains a separate manual governance step.
