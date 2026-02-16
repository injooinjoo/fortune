# RCA Report - Store Review Gate Blockers (KAN-19)

## 1. Symptom
- Error message:
  - `flutter analyze` exits with 78 issues.
  - `bash ./scripts/ios_full_regression.sh` fails at analyze + integration steps.
  - Android purchase verification has explicit TODO and validates only token presence.
- Repro steps:
  1. Run `flutter analyze`
  2. Run `bash ./scripts/ios_full_regression.sh`
  3. Inspect `supabase/functions/payment-verify-purchase/index.ts` Android branch
- Observed behavior:
  - Analyze gate blocks release due lint/warning debt.
  - iOS integration runner exits when `iPhone 15 Pro` simulator is absent.
  - Android purchase validation is non-authoritative.
- Expected behavior:
  - Analyze gate passes.
  - iOS integration runner auto-falls back to available simulator.
  - Android purchase is validated against Google Play API.

## 2. WHY (Root Cause)
- Direct cause:
  - Lint backlog (primarily `curly_braces_in_flow_control_structures`) causes analyzer non-zero exit.
  - Integration runner has strict device-name dependency.
  - Android purchase branch has TODO stub implementation.
- Root cause:
  - Release gate scripts/docs were stricter than current code hygiene and infra assumptions.
  - Google Play purchase verification implementation was deferred.
- Data/control flow:
  - Step 1: `flutter analyze` reports 7 diagnostic codes, exits 1.
  - Step 2: `ios_full_regression.sh` forwards integration to `run_ios_integration_tests.sh`.
  - Step 3: integration script fails immediately when default simulator name is missing.
  - Step 4: payment edge function accepts Android `purchaseToken` without Google API verification.

## 3. WHERE
- Primary locations:
  - `supabase/functions/payment-verify-purchase/index.ts` (Android verification TODO)
  - `scripts/run_ios_integration_tests.sh` (simulator strict lookup)
  - `scripts/ios_full_regression.sh` (integration invocation)
  - Multiple lint hotspots identified by `flutter analyze`
- Related call sites:
  - `lib/services/in_app_purchase_service.dart` posts to `/payment-verify-purchase`.

## 4. WHERE ELSE (Global Search)
- Search patterns used:
  - `rg -n "TODO: Google Play|purchaseToken 존재|Android: Google Play 검증" supabase/functions/payment-verify-purchase/index.ts`
  - `rg -n "Simulator '.*' not found|simctl list devices|iPhone 15 Pro" scripts/run_ios_integration_tests.sh scripts/ios_full_regression.sh`
  - `flutter analyze ... | awk ...` (diagnostic code aggregation)
- Findings:
  1. `supabase/functions/payment-verify-purchase/index.ts:254` - Google verification TODO found.
  2. `scripts/run_ios_integration_tests.sh:35-40` - hard fail on missing named simulator.
  3. Analyze diagnostics breakdown:
     - `curly_braces_in_flow_control_structures` 64
     - `use_build_context_synchronously` 3
     - `unused_element` 3
     - `prefer_const_constructors` 3
     - `deprecated_member_use` 3
     - `unnecessary_import` 1
     - `deprecated_member_use_from_same_package` 1

## 5. HOW (Correct Pattern)
- Reference implementation:
  - Existing Apple verification pattern in `payment-verify-purchase` (external authoritative validation).
  - Existing robust shell fallback style in repo scripts (warning + continue with explicit fallback target).
- Before:
```ts
// TODO: Google Play 영수증 검증 구현
isValid = true
```
- After:
```ts
// Android Publisher API token acquisition + purchase endpoint verification
// Product/subscription path split, strict state checks, product/package validation
```
- Why this fix is correct:
  - Aligns Android purchase validation with iOS production-grade pattern.
  - Removes infra brittleness in iOS integration path.
  - Brings analyzer gate to pass by resolving actual diagnostics instead of hiding failures.

## 6. Fix Plan
- Files to change:
  1. `supabase/functions/payment-verify-purchase/index.ts` - implement Google Play verification.
  2. `scripts/run_ios_integration_tests.sh` - add available iPhone simulator fallback.
  3. `scripts/ios_full_regression.sh` - clarify fallback behavior text.
  4. Lint-issue source files from analyzer output - apply/fix targeted diagnostics.
  5. `ios/fastlane/metadata/en-US/support_url.txt` - add missing fallback metadata file.
  6. Review docs under `docs/deployment/review/` - update gate statuses to current results.
- Risk assessment:
  - Medium: external API auth/signing logic for Google Play can fail without env config.
  - Low: script fallback change and lint fixes are localized.
- Validation plan:
  - Re-run full gate commands (analyze/format/test/iOS build/IPA archive/AAB/lintRelease/ios_full_regression).

