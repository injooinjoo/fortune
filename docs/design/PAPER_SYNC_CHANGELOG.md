# Paper Sync Changelog

This file is the repository-side proof that a code change was reconciled with the canonical Paper contract.

## Rules

1. Any route or governed design contract change must update:
   - `paper/catalog_inventory.json` when the artboard set changes
   - `docs/design/PAPER_SOURCE_OF_TRUTH.md`
   - `docs/design/PAPER_SCREEN_ROUTE_MAPPING.md`
   - `docs/design/PAPER_SCREEN_COMPONENT_REGISTRY.md`
   - this changelog
2. Any UI surface change under tracked presentation, screen, shared, or design-system files must append a changelog entry even if the Paper artboard list does not change.
3. CI runs `npm run paper:guard` and fails when these records are missing.

## Entries

| Date | Jira | Code Scope | Affected Screens / Components | Paper Action |
| --- | --- | --- | --- | --- |
| 2026-03-27 | `KAN-198` | Paper 단일 SoT 전환 및 legacy design contract 제거 | `paper/catalog_inventory.json`, `paper/design-tokens.json`, `docs/design/PAPER_*`, `scripts/design/paper_sync_guard.js`, CI/design contract docs | Replaced the repository-side official design contract with Paper, retired the previous design docs/scripts/CI hooks, and locked the current `Fortune / iPhone` Paper artboard inventory in repo-local governance files |
