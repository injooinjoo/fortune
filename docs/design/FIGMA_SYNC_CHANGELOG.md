# Figma Sync Changelog

This file is the repository-side proof that a code change was reconciled with the official Figma file.

## Rules

1. Any route change must update:
   - `playwright/scripts/figma_capture_manifest.js`
   - `docs/design/FIGMA_SOURCE_OF_TRUTH.md`
   - `docs/design/FIGMA_SCREEN_COMPONENT_REGISTRY.md`
   - this changelog
2. Any UI surface change under tracked presentation, screen, shared, or design-system files must append a changelog entry even if the screen list did not change.
3. The official Figma file remains [Fortune Screen Catalog - Official](https://www.figma.com/design/dkx3Biwe5xkiMQWsjq95LA).
4. CI runs `npm run figma:guard` and fails when these records are missing.

## Entries

| Date | Jira | Code Scope | Affected Screens / Components | Figma Action |
| --- | --- | --- | --- | --- |
| 2026-03-10 | `KAN-60` | Official catalog formalization | `10 Entry / Auth / Onboarding` through `99 Archive` | Created the single official catalog file and aligned repo docs |
| 2026-03-10 | `KAN-61` | Wellness route coverage | `wellness__landing__default`, `wellness__meditation__default`, `Wellness Focus Blocks` | Added `75 Wellness` to the official file and synced docs |
| 2026-03-10 | `NO-JIRA` | Figma sync automation guard | `figma_capture_manifest` governance, changelog enforcement, CI drift reporting | Added automatic guard so route/UI changes cannot pass CI without a recorded Figma sync step |
