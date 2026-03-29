# Ondo Paper Source Of Truth

## Official File

- Paper file name: `Ondo`
- Paper page: `iPhone`
- Paper page id: `01K4GP58P8JRM8PGBP0586VKYV`
- Paper root node id: `root_node_01K4GP58P8JRM8PGBP0586VKYV`
- Canonical inventory: `paper/catalog_inventory.json`
- Screen-to-route mapping: `docs/design/PAPER_SCREEN_ROUTE_MAPPING.md`
- Screen/component registry: `docs/design/PAPER_SCREEN_COMPONENT_REGISTRY.md`

This file remains the only official Paper source of truth for current-state Ondo surfaces.

## Coverage Snapshot

- Total artboards: `26`
- Mobile surfaces: `19`
- Catalog/governance artboards: `7`
- Font families: `Noto Sans KR`, `Nanum Myeongjo`

## Runtime Scope

The retained current-state product scope is:

- `10 Entry / Auth / Onboarding`
- `20 Chat Home / Character`
- `80 Admin / Policy / Utility`

Runtime routes represented directly by Paper artboards:

- `/splash`
- `/signup`
- `/onboarding`
- `/chat`
- `/character/:id`
- `/premium`
- `/profile`
- `/profile/edit`
- `/profile/saju-summary`
- `/profile/relationships`
- `/profile/notifications`
- `/privacy-policy`
- `/terms-of-service`
- `/account-deletion`

Runtime behavior documented without a dedicated Paper artboard:

- `/` redirect to `/chat`
- `/home` redirect to `/chat`
- `/auth/callback` transient auth callback route

## Canonical Structure

Canonical catalog sections inside Paper:

- `Paper Catalog · 00 Cover & Governance`
- `Paper Catalog · 10 Entry / Auth / Onboarding`
- `Paper Catalog · 20 Chat Home / Character`
- `Paper Catalog · 80 Admin / Policy / Utility`
- `Paper Catalog · 90 Components`
- `Paper Catalog · 99 Archive`

Canonical mobile surface artboards:

- `01 - Splash`
- `02 - Entry Hero / Soft Gate`
- `03 - Auth Fallback`
- `04 - Nickname Fallback`
- `05 - Onboarding Birth`
- `06 - Interest Select`
- `07 - Personalized Handoff`
- `08 - Character List (First Run)`
- `09 - Character Chat`
- `10 - Character Profile`
- `11 - Premium`
- `12 - Profile`
- `13 - Profile Edit`
- `14 - Saju Summary`
- `15 - Notification Settings`
- `16 - Privacy Policy`
- `17 - Terms of Service`
- `18 - Account Deletion`
- `19 - Relationships`

## Rules

1. Treat `paper/catalog_inventory.json` as the repo-side snapshot of the current Paper file.
2. Any route or governed UI contract change must update:
   - `paper/catalog_inventory.json` when the artboard set changes
   - `docs/design/PAPER_SOURCE_OF_TRUTH.md`
   - `docs/design/PAPER_SCREEN_ROUTE_MAPPING.md`
   - `docs/design/PAPER_SCREEN_COMPONENT_REGISTRY.md`
   - `docs/design/PAPER_SYNC_CHANGELOG.md`
3. `npm run paper:guard` is the only design contract guard used by CI.
4. Paper is manual SoT only. Remote push/capture automation is intentionally out of scope.
