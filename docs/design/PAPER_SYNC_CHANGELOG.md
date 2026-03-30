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
| 2026-03-28 | `KAN-207` | 구매 로딩 오버레이 문구 정리 | `PurchaseLoadingOverlay` | Preserved the existing purchase overlay layout and interaction, but softened the warning copy so the loading state now tells users not to leave the app and to wait for the payment sheet in clearer Korean |
| 2026-03-28 | `KAN-208` | 운세 공통 accent card의 rounded border paint assert 수정 | `FortuneTipCard`, `FortuneQuoteBlock` | No artboard or route inventory changed. Replaced the mixed-color rounded `Border` pattern with a shared clipped accent surface so the Paper-aligned fortune cards keep the same left accent treatment without tripping Flutter's non-uniform border radius assertion |
| 2026-03-28 | `KAN-210` | Character/Profile/Premium 관리 화면의 2차 Paper 정렬 | `CharacterProfilePage`, `PremiumScreen`, `ProfileScreen`, `PrivacyPolicyPage`, `NotificationSettingsPage`, `ProfileRelationshipsPage`, `AccountDeletionPage` | Moved non-Paper commerce and management controls behind secondary sections, restored the Paper-first visible state for the premium, profile, privacy, relationship, and account-deletion surfaces, and rebuilt the character profile around the retained Paper artboard layout while preserving runtime behavior. |
| 2026-03-28 | `KAN-210` | Character Chat / Profile Edit / Terms 의 Paper 노출 상태 추가 정렬 | `CharacterChatPanel`, `ProfileEditPage`, `TermsOfServicePage` | Simplified the character-chat header and moved fortune chips down to the Paper position, pushed secondary profile-edit metadata below the first-fold Paper state, and strengthened the terms section hierarchy so the remaining untouched 08-19 admin/chat surfaces follow the Paper artboards more closely. |
| 2026-03-29 | `KAN-215` | Ondo 2차 브랜딩 정리와 위젯 shell 식별자 동기화 | `PrivacyPolicyPage`, `docs/design/PAPER_*`, `docs/index.html`, `OndoWidgetBundle`, `OndoOverallWidget`, `OndoCategoryWidget`, `OndoTimeSlotWidget`, `OndoLottoWidget` | No artboard or route inventory changed. Reconciled the governed Paper docs, policy/runtime copy, and iOS widget shell identifiers with the Ondo brand so repository-side design contracts no longer expose the legacy app brand. |
| 2026-03-30 | `FORT-TBD` | formatter 출력과 Paper guard 정렬 | `CharacterListPanel`, `CharacterProfilePage`, `CharacterChoiceWidget`, `CharacterMessageBubble`, `SajuStrengthGauge`, `SocialAccountsSection`, `SocialLoginBottomSheet`, `SmartImage` | No artboard or route inventory changed. Recorded the repository-side formatter reconciliation on governed UI surfaces so Flutter CI/CD and the Paper sync guard agree on the current contract state. |
| 2026-03-30 | `FORT-TBD` | Flutter 3.38 formatter 재정렬 | `CharacterListPanel`, `CharacterProfilePage`, `CharacterMessageBubble`, `SajuStrengthGauge`, `SocialAccountsSection`, `SocialLoginBottomSheet`, `SmartImage` | No artboard or route inventory changed. Re-ran the governed UI files through the same Flutter 3.38 formatter used in CI and recorded the reconciliation in the Paper sync log so the Flutter CI/CD formatting gate and Paper guard stay aligned on the exact checked-in output. |
