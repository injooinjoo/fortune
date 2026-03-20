# Release Risk Register - Full-stack Audit

Date: `2026-03-21`  
Jira: `KAN-155`

## 1. Audit Baseline
- Scope:
  - Flutter app, Supabase Edge Functions, documentation, GitHub Actions.
- Repo footprint reviewed:
  - Dart files: `496`
  - Edge function directories: `68`
  - Flutter tests: `74`
  - Integration tests: `8`
  - Playwright specs: `7`
- Executed commands:
  - `flutter analyze` -> exit `1`, `10 issues found`
  - `dart format --set-exit-if-changed .` -> pass
  - `flutter test` -> pass
  - `npm run source-inventory:check` -> pass
  - `npm run figma:guard` -> pass

## 2. Severity Summary
- Confirmed `P0`: `0`
- Confirmed `P1`: `4`
- Confirmed `P2`: `2`

No read-only evidence showed an active production blocker severe enough to mark `P0`, but there are multiple `P1` items that can quietly ship drift into the main `/chat` surface and long-tail Edge integrations.

## 3. Risk Items

### P1-001 Route inventory and deep-link contract are not aligned
- Severity: `P1`
- Evidence:
  - `docs/getting-started/APP_SURFACES_AND_ROUTES.md:53` lists `/profile` under inactive top-level routes.
  - `docs/APP_ARCHITECTURE.md:55` repeats `/profile` as inactive current-state.
  - `lib/routes/route_config.dart:71` still registers `/profile` with nested edit/relationships/notifications routes.
  - `lib/core/navigation/fortune_chat_route.dart:107-133` defines `/chat?...` as the canonical fortune chat query contract.
  - `lib/services/deep_link_service.dart:64-76` still reads `screen` + `fortuneType`, and `lib/services/deep_link_service.dart:121-126` persists `pending_deep_link_fortune_type` to `SharedPreferences` before navigating to bare `/chat`.
  - `test/unit/services/deep_link_service_test.dart` validates only route recovery, while `test/unit/core/navigation/fortune_chat_route_test.dart` validates only the query builder. There is no contract test that binds the runtime deep-link path to the canonical `/chat` query contract.
- Release impact:
  - External entry flows can regress without docs, router, and deep-link handling failing together.
  - Product/support teams cannot rely on current-state route docs during release validation.
- Root cause:
  - The `/chat` consolidation landed, but the older deep-link and profile-route paths were not fully retired or re-documented.
- Recommended fix:
  - Pick one truth for `/profile`: active route or inactive route, then update docs and router accordingly.
  - Collapse all fortune chat entry paths onto `buildFortuneChatRoute(...)`.
  - Add integration tests covering deep link -> route builder -> `SwipeHomeShell` launch behavior.
- Expected effort: `M`

### P1-002 Edge function response contracts are still fragmented
- Severity: `P1`
- Evidence:
  - Contract scan found five fortune functions without a visible `success: true` success wrapper:
    - `fortune-investment`
    - `fortune-match-insight`
    - `fortune-new-year`
    - `fortune-past-life`
    - `fortune-time`
  - `supabase/functions/fortune-match-insight/index.ts:386-387` returns `JSON.stringify(finalResponse)`.
  - `supabase/functions/fortune-past-life/index.ts:2999-3000` returns `JSON.stringify({ fortune: fortune })`.
  - `supabase/functions/fortune-love/index.ts:799-801` still normalizes legacy payload aliases such as `mainMessage`.
  - `supabase/functions/fortune-family-health/index.ts:342-353` maps `overallScore` and also emits alias fields like `overall_score`.
  - `supabase/functions/fortune-yearly-encounter/index.ts:22`, `:584`, `:693` bypasses the shared `LLMFactory` path and talks directly to Gemini APIs.
- Release impact:
  - Client parsing, analytics, and rollback behavior are inconsistent across fortune types.
  - Shared adapters become harder to harden because callers must carry alias compatibility logic indefinitely.
  - Direct provider calls create a policy gap against the repo's shared LLM module rule.
- Root cause:
  - Standardization happened incrementally per feature, leaving a mixed fleet of envelopes and field aliases.
- Recommended fix:
  - Define a shared fortune success envelope in `_shared` and add a conformance check across every `fortune-*` function.
  - Migrate `fortune-yearly-encounter` and the remaining direct-provider flows onto the shared LLM abstraction or a documented exception wrapper.
  - Introduce schema tests that fail when top-level success/data rules drift.
- Expected effort: `M-L`

### P1-003 CI gates currently tolerate too much first-party drift
- Severity: `P1`
- Evidence:
  - `.github/workflows/flutter-ci.yml:41` runs `flutter analyze --no-fatal-infos --no-fatal-warnings`.
  - `.github/workflows/security-scan.yml:114` repeats the same non-fatal analyze mode.
  - `.github/workflows/flutter-ci.yml:118` only emits a warning when coverage falls below `80%`.
  - `.github/workflows/security-scan.yml:129` marks `code-quality` as `continue-on-error: true`.
  - Local `flutter analyze` already reports first-party issues in `lib/screens/profile/...` plus vendored third-party issues in `third_party/google_sign_in_web/...`.
- Release impact:
  - Green CI does not necessarily mean first-party quality drift has been contained.
  - First-party warnings and info-level regressions can accumulate under a permanently permissive baseline.
- Root cause:
  - CI favors non-blocking operation, but the repo does not maintain a baseline file or touched-files policy to compensate.
- Recommended fix:
  - Make first-party analyzer findings fatal or baseline-managed.
  - Keep vendored third-party packages out of the main app analyze step, or lint them separately.
  - Turn coverage on touched critical surfaces into a fail condition rather than a warning.
- Expected effort: `S-M`

### P1-004 The `/chat` core has a very large presentation-layer blast radius
- Severity: `P1`
- Evidence:
  - `lib/features/character/presentation/providers/character_chat_provider.dart` is `4943` lines with `51` imports and `211` method-like declarations.
  - `lib/features/character/presentation/pages/character_chat_panel.dart` is `2942` lines with `53` imports.
  - Presentation-layer import scan found:
    - `19` direct data-service imports
    - `13` data-model imports
    - `2` data-datasource imports
    - `1` data-repository import
  - Representative examples:
    - `lib/features/character/presentation/providers/character_chat_provider.dart:13-21`
    - `lib/presentation/providers/providers.dart:6-8`
    - `lib/presentation/providers/token_provider.dart:8`
- Release impact:
  - The main `/chat` surface has high regression blast radius for any feature work.
  - Ownership boundaries are weak, so small changes require broad retesting.
- Root cause:
  - Main-surface orchestration accumulated in presentation providers and pages instead of stabilizing behind domain/use-case boundaries.
- Recommended fix:
  - Extract chat session orchestration, message delivery, fortune launch adaptation, and survey assembly into smaller services/use cases.
  - Keep presentation notifiers focused on UI state composition.
- Expected effort: `L`

### P2-001 Design-system debt is concentrated in live widget code
- Severity: `P2`
- Evidence:
  - Design-system scan found:
    - `Color(0x...)` in `25` Dart files
    - `fontSize:` in `28` Dart files
    - `TextStyle(` in `18` Dart files
  - Token-definition files account for part of the count, but live widget examples remain:
    - `lib/features/fortune/presentation/widgets/saju/saju_strength_gauge.dart`
    - `lib/features/fortune/presentation/widgets/saju/saju_concept_card.dart`
    - `lib/features/character/presentation/pages/character_profile_page.dart`
    - `lib/features/chat/presentation/widgets/survey/chat_match_selector.dart`
    - `lib/features/chat/presentation/widgets/survey/ootd_photo_input.dart`
  - `analysis_options.yaml` contains only generic Flutter lints and no design-system enforcement.
- Release impact:
  - UI consistency, dark-mode resilience, and typography accessibility get harder to maintain.
- Root cause:
  - Token migration is incomplete and there is no guardrail that distinguishes allowed token files from disallowed presentation usage.
- Recommended fix:
  - Separate "token definition" exceptions from "UI usage" violations.
  - Add a scoped lint or CI grep for presentation-layer hardcoded style usage.
  - Migrate the top violating feature widgets first.
- Expected effort: `M`

### P2-002 Analyzer signal is polluted by vendored code
- Severity: `P2`
- Evidence:
  - Local `flutter analyze` output includes repository-local third-party files:
    - `third_party/google_sign_in_web/lib/google_sign_in_web.dart`
    - `third_party/google_sign_in_web/lib/src/people.dart`
    - `third_party/google_sign_in_web/lib/web_only.dart`
  - First-party issues in `lib/screens/profile/...` and vendored warnings appear in the same report.
- Release impact:
  - Engineers have a weaker signal-to-noise ratio when triaging analyzer output.
- Root cause:
  - Vendored packages live inside the repo but are not isolated from the main analyzer surface.
- Recommended fix:
  - Exclude vendored packages from the app analyzer or run them as separate package checks.
- Expected effort: `S`

## 4. What Is Working
- `flutter test` passes on the current baseline.
- `dart format --set-exit-if-changed .` passes cleanly.
- `npm run source-inventory:check` passes.
- `npm run figma:guard` passes.
- There is already meaningful test coverage around chat widgets, tarot survey widgets, and fortune route normalization.

## 5. Recommended Priority Order
1. Route/deep-link contract alignment
2. Edge response contract hardening
3. CI gate tightening for first-party code
4. `/chat` orchestration decomposition
5. Design-system migration with scoped enforcement
