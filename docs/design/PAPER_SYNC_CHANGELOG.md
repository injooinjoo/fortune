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
| 2026-03-27 | `KAN-199` | 프로필/정책 관리 화면의 1차 Paper 정렬 | `ProfileScreen`, `ProfileEditPage`, `SajuSummaryPage`, `PrivacyPolicyPage`, `TermsOfServicePage`, `AccountDeletionPage`, `PaperRuntimeExpandablePanel` | Preserved the existing runtime behaviors, but moved non-Paper supplemental controls behind expandable Paper panels so the default visible state now matches the Paper admin and policy surfaces more closely |
| 2026-03-27 | `KAN-199` | 프로필 1차 정렬 후 다크모드 테마 보정 | `ProfileScreen`, `SajuSummaryPage` | Swapped the fallback avatar and saju accent colors to theme-aware tokens so the same Paper-aligned surfaces remain legible in both light mode and dark mode |
| 2026-03-27 | `KAN-202` | Notification/Relationships Paper drift 해소 및 admin surface 확장 | `paper/catalog_inventory.json`, `docs/design/PAPER_*`, `NotificationSettingsPage`, `ProfileRelationshipsPage`, `docs/getting-started/APP_SURFACES_AND_ROUTES.md` | Rebuilt the notification settings artboard around the current runtime behavior, added the missing relationships mobile surface to Paper, and aligned the Flutter admin screens and route inventory with the expanded Paper contract |
| 2026-03-28 | `KAN-205` | 프로필 계열 리스트 반동 억제 | `ProfileScreen`, `ProfileRelationshipsPage` | Switched the profile-area list physics to `AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics())` so pull/overscroll gestures no longer rebound upward as aggressively while preserving scrollability |
| 2026-03-28 | `KAN-207` | Paper 관리 UI 코드 포맷 드리프트 정리 | `DSButton`, `DSColorScheme`, `SocialLoginBottomSheet` | No artboard or route inventory changed. Reconciled repo-side formatting drift on governed Paper UI files so the checked-in code matches the current Paper contract and CI guard expectations |
