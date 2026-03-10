# Fortune Figma Source Of Truth

## Official File

- Official file name: `Fortune Screen Catalog - Official`
- Figma file key: `dkx3Biwe5xkiMQWsjq95LA`
- Direct link: [Fortune Screen Catalog - Official](https://www.figma.com/design/dkx3Biwe5xkiMQWsjq95LA)

This file is the only official Figma source of truth for Fortune. Draft captures, exploratory files, and one-off review files are not part of the formal design system unless they are merged into this file.

## Standard

- Device: `iPhone 15 Pro`
- Frame size: `393 x 852`
- Scale: `@3x`
- Theme: `light`
- Locale: `ko-KR`
- Governance model: `one file only`

Every frame in the official catalog is normalized to this device standard. Desktop-width captures are out of scope for the official catalog.

## File Structure

- `00 Cover & Governance`
- `10 Entry / Auth / Onboarding`
- `20 Chat Home / Character`
- `30 Fortune Hub / Interactive`
- `40 Trend`
- `50 Health / Exercise`
- `60 History / Profile / More`
- `70 Commerce / Settings / Support`
- `75 Wellness`
- `80 Admin / Policy / Utility`
- `90 Components`
- `99 Archive`

Frame naming is fixed as `flow__screen__state`.

Examples:

- `chat__home__returning`
- `interactive_dream__result__seeded`
- `trend_balance__result__summary`

## Coverage Snapshot

- Managed surfaces: `63`
- Live captures: `37`
- Placeholder specs: `26`
- Component inventory groups: `5`

Live captures are backed by verified local screenshots from the Flutter web build. Placeholder specs remain in the same file when a surface cannot be rendered locally without authenticated data, backend seed data, or `state.extra`.

## Coverage Triage

- `26` placeholder surfaces remain under active governance and are not dead pages.
- Breakdown:
  - `11` auth-gated profile/settings routes
  - `7` runtime result layouts
  - `6` trend content/result layouts waiting on representative seed data
  - `2` `state.extra` dependent detail pages
- Active-route delete candidates: `0`
- Redirect-only exclusions: `/`, `/home`

The official Figma file therefore covers every active router surface either as a live capture or as an explicitly managed placeholder. Removal candidates are tracked through source inventory, not by silently dropping frames from the design registry.

## Capture Model

### Live Capture

Use live capture when the route can be rendered locally at `iPhone 15 Pro 393x852` with stable test-mode setup.

Current live examples:

- `/chat` first-run onboarding
- `/chat` returning home
- `/fortune/interactive/dream` input and seeded result
- `/wellness`, `/wellness/meditation`
- `/premium`, `/subscription`, `/token-purchase`
- `/help`, `/privacy-policy`, `/terms-of-service`

### Placeholder Spec

Use placeholder spec when the route exists but local runtime requirements prevent stable capture.

Current blocker classes:

- Auth-gated profile surfaces
- `GoRouter state.extra` dependent pages
- Result pages that require successful runtime generation
- Trend detail/result pages that require backend `trend_content` seed data

Placeholders stay inside the official file so coverage gaps are explicit and managed, not forgotten.

## Source Pipeline

Official repo sources:

- Router: `lib/routes/route_config.dart`
- Nested routes:
  - `lib/routes/routes/auth_routes.dart`
  - `lib/routes/routes/interactive_routes.dart`
  - `lib/routes/routes/trend_routes.dart`
  - `lib/routes/routes/wellness_routes.dart`
  - `lib/routes/character_routes.dart`
- Capture manifest: `playwright/scripts/figma_capture_manifest.js`
- Live capture runner: `playwright/scripts/capture_figma_screens.js`
- Catalog HTML generator: `playwright/scripts/build_figma_catalog.js`
- Local static server: `playwright/scripts/figma_capture_server.py`

Package scripts:

- `npm run figma:serve-build`
- `npm run figma:capture`
- `npm run figma:catalog`
- `npm run figma:guard`

Generated local outputs are intentionally disposable and should not be treated as source-of-truth artifacts:

- `artifacts/figma_capture/`
- `artifacts/figma_catalog/`

## Operating Rules

1. Maintain one official Figma file only.
2. Cover every router-defined page with at least one frame.
3. Add an extra frame for every key inline result state that materially changes layout.
4. Use verified `iPhone 15 Pro` captures for live screens.
5. Record blocked surfaces as placeholders in the same file until the blocker is removed.
6. Update the Figma file and design docs in the same task as the route or UI change.
7. Do not create separate “final” Figma files for features, audits, or handoff.
8. Redirect-only routes such as `/` and `/home` are documented as route behavior, not as independent screen surfaces.

## Automation Guard

The repository now enforces a design-sync guard in CI through `npm run figma:guard`.

The guard automatically checks:

- manifest counts vs design docs
- placeholder triage completeness
- route or UI changes without a matching Figma sync record
- route changes without manifest and registry/source-of-truth updates

Required repo touchpoints by change type:

- Route changes:
  - `playwright/scripts/figma_capture_manifest.js`
  - `docs/design/FIGMA_SOURCE_OF_TRUTH.md`
  - `docs/design/FIGMA_SCREEN_COMPONENT_REGISTRY.md`
  - `docs/design/FIGMA_SYNC_CHANGELOG.md`
- UI-only visual changes:
  - `docs/design/FIGMA_SYNC_CHANGELOG.md`
  - plus any manifest/doc updates if screen inventory or counts changed

Because branch protection is configured outside this repository, the remaining manual setup is to mark the CI workflow as a required GitHub status check.

## Update Workflow

1. Confirm the target routes and result states from router and page source.
2. Build the web app with valid local test configuration.
3. Serve the built app with `npm run figma:serve-build`.
4. Capture live screens with `npm run figma:capture`.
5. Generate catalog HTML with `npm run figma:catalog`.
6. Append the catalog pages into the existing official Figma file through the Figma MCP capture flow.
7. Update this document, [FIGMA_SCREEN_COMPONENT_REGISTRY.md](./FIGMA_SCREEN_COMPONENT_REGISTRY.md), and [FIGMA_SYNC_CHANGELOG.md](./FIGMA_SYNC_CHANGELOG.md) in the same change.
8. Run `npm run figma:guard` before pushing.

## Known Constraints

- `npx serve build/web --single` is not valid for official capture because dotfiles such as `build/web/assets/.env` are rewritten to `index.html`.
- Flutter web uses hash routing for this app. Official capture URLs must follow the runtime pattern `http://localhost:<port>/?test_mode=true#/route`.
- Some interactive and result surfaces require seeded local storage or backend payloads. Those states must be documented explicitly instead of being silently skipped.

## Documentation Sync

Any official change must keep these documents aligned:

- [README.md](./README.md)
- [FIGMA_SOURCE_OF_TRUTH.md](./FIGMA_SOURCE_OF_TRUTH.md)
- [FIGMA_SCREEN_COMPONENT_REGISTRY.md](./FIGMA_SCREEN_COMPONENT_REGISTRY.md)
- [FIGMA_SYNC_CHANGELOG.md](./FIGMA_SYNC_CHANGELOG.md)
