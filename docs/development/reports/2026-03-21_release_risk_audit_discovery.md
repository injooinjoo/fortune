# Discovery Report - Full-stack Release Risk Audit

## 1. Goal
- Requested change:
  - Produce a repository-backed full-stack release risk audit for the Ondo app.
- Work type: Documentation / Audit / Release Readiness
- Scope:
  - Flutter app, Supabase Edge Functions, documentation, and GitHub Actions.
  - Create fixed audit outputs:
    - risk register
    - improvement proposal
    - execution roadmap
    - verify report

## 2. Search Strategy
- Keywords:
  - route, deep_link, fortuneType, success, overallScore, mainMessage, Color(0x, fontSize, TextStyle, workflow, coverage
- Commands:
  - `flutter analyze`
  - `dart format --set-exit-if-changed .`
  - `flutter test`
  - `npm run source-inventory:check`
  - `npm run figma:guard`
  - `rg --files docs | rg 'audit|review|quality|risk|roadmap'`
  - `sed -n '1,260p' lib/routes/route_config.dart`
  - `sed -n '1,260p' lib/core/navigation/fortune_chat_route.dart`
  - `sed -n '1,260p' lib/services/deep_link_service.dart`
  - `rg -n "import .*data/|import .*features/.*/data/" lib/features/*/presentation lib/presentation`
  - `rg -n "success: true|overallScore|mainMessage|overall_score" supabase/functions -g 'index.ts'`
  - `python` scans for large files, design-system debt clusters, and Edge contract variance

## 3. Similar Code Findings
- Reusable:
  1. `docs/development/templates/DISCOVERY_REPORT_TEMPLATE.md` - discovery structure baseline.
  2. `docs/development/reports/2026-02-16_store_review_strategy_discovery.md` - report style for documentation-only audit work.
  3. `docs/development/reports/2026-02-16_store_review_strategy_verify.md` - verify report shape for audit artifacts.
  4. `docs/deployment/review/RELEASE_DECISION_LOG.md` - risk-oriented release decision language and evidence fields.
- Reference only:
  1. `docs/getting-started/APP_SURFACES_AND_ROUTES.md` - current-state route inventory source of truth.
  2. `docs/APP_ARCHITECTURE.md` - current-state architecture narrative.
  3. `lib/routes/route_config.dart` - actual router implementation.
  4. `lib/core/navigation/fortune_chat_route.dart` - canonical chat route query contract.
  5. `lib/services/deep_link_service.dart` - legacy deep-link path still in runtime.
  6. `lib/features/character/presentation/providers/character_chat_provider.dart` - main `/chat` orchestration hotspot.
  7. `.github/workflows/flutter-ci.yml` - build/analyze/test gate behavior.
  8. `.github/workflows/security-scan.yml` - security/analyze gate behavior.

## 4. Reuse Decision
- Reuse as-is:
  - Existing release/audit doc structure and report naming convention under `docs/development/reports/`.
  - Existing release decision vocabulary from deployment review docs.
- Extend existing code:
  - No runtime or API changes in this task.
- New code required:
  - New markdown audit artifacts under `docs/development/reports/`.
- Duplicate prevention notes:
  - Keep the audit in `docs/development/reports/` instead of creating another audit folder.
  - Do not duplicate release review checklists already living under `docs/deployment/review/`; reference them where useful.

## 5. Planned Changes
- Files to edit:
  1. `artifacts/file_inventory.json` (if repository guard regeneration is required)
  2. `docs/development/FILE_INVENTORY.md` (if repository guard regeneration is required)
  3. `docs/development/UNUSED_CANDIDATES.md` (if repository guard regeneration is required)
- Files to create:
  1. `docs/development/reports/2026-03-21_release_risk_audit_discovery.md`
  2. `docs/development/reports/2026-03-21_release_risk_register.md`
  3. `docs/development/reports/2026-03-21_release_improvement_proposal.md`
  4. `docs/development/reports/2026-03-21_release_execution_roadmap.md`
  5. `docs/development/reports/2026-03-21_release_risk_audit_verify.md`

## 6. Validation Plan
- Static checks:
  - `flutter analyze`
  - `dart format --set-exit-if-changed .`
- Runtime/build checks:
  - `flutter test`
  - `npm run source-inventory:check`
  - `npm run figma:guard`
- Test cases:
  - Confirm documentation-only change does not alter Dart formatting state.
  - Confirm repo guard scripts still pass after report files are added.
