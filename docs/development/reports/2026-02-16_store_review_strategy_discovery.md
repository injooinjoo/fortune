# Discovery Report - iOS/Android Store Review Strategy Implementation

## 1. Goal
- Requested change:
  - Implement detailed iOS/Android pre-review strategy artifacts as repository-operational checklists and evidence templates.
- Work type: Documentation / Release Ops
- Scope:
  - Create `docs/deployment/review/` and four strategy documents for KR+EN, conservative gate (`P0=0`, `P1=0`), and expanded device matrix.

## 2. Search Strategy
- Keywords:
  - review, checklist, launch, submission, metadata, privacy, permissions, IAP verification
- Commands:
  - `rg "extends StateNotifier" lib/`
  - `rg "class .*Widget" lib/`
  - `rg "class .*Service" lib/`
  - `rg "@freezed" lib/`
  - `rg "StateNotifierProvider" lib/`
  - `rg --files docs/deployment | rg -i "review|checklist|readiness|submission|launch"`
  - `sed -n '1,260p' ios/Runner/Info.plist`
  - `sed -n '1,260p' ios/Runner/PrivacyInfo.xcprivacy`
  - `sed -n '1,260p' android/app/src/main/AndroidManifest.xml`
  - `sed -n '1,320p' supabase/functions/payment-verify-purchase/index.ts`
  - `curl -sSIL https://zpzg.co.kr/privacy.html` (+ support / well-known endpoints)

## 3. Similar Code Findings
- Reusable:
  1. `docs/deployment/LAUNCH_READINESS_AUDIT_2026-02-14.md` - launch gate/risk tracking format.
  2. `docs/deployment/APP_STORE_SUBMISSION_INFO.md` - App Store metadata checklist baseline.
  3. `docs/deployment/GOOGLE_PLAY_SUBMISSION_GUIDE.md` - Play Console submission and policy checklist baseline.
  4. `docs/development/templates/DISCOVERY_REPORT_TEMPLATE.md` - discovery reporting shape.
  5. `docs/development/templates/VERIFY_REPORT_TEMPLATE.md` - verify reporting shape.
- Reference only:
  1. `metadata/` and `ios/fastlane/metadata/` - actual source-of-truth files and parity targets.
  2. `scripts/ios_full_regression.sh` - iOS automated validation command baseline.
  3. `android/app/src/main/AndroidManifest.xml` - permission/app links declaration baseline.
  4. `supabase/functions/payment-verify-purchase/index.ts` - Android purchase verification TODO evidence.

## 4. Reuse Decision
- Reuse as-is:
  - Existing deployment docs as policy/flow references.
  - Existing validation commands (`flutter analyze`, `flutter test`, iOS regression script, Android lint).
- Extend existing code:
  - No runtime/app code extension required.
- New code required:
  - New review-ops documents under `docs/deployment/review/`.
- Duplicate prevention notes:
  - Define `metadata/` as priority-1 and `ios/fastlane/metadata/` as priority-2 to avoid split source decisions.

## 5. Planned Changes
- Files to edit:
  - None.
- Files to create:
  1. `docs/deployment/review/STORE_REVIEW_MASTER_CHECKLIST.md`
  2. `docs/deployment/review/IOS_REVIEW_EVIDENCE.md`
  3. `docs/deployment/review/ANDROID_REVIEW_EVIDENCE.md`
  4. `docs/deployment/review/RELEASE_DECISION_LOG.md`

## 6. Validation Plan
- Static checks:
  - `flutter analyze`
  - `dart format --set-exit-if-changed .`
- Runtime/build checks:
  - `flutter test`
  - `./scripts/ios_full_regression.sh`
  - `flutter build ios --release --no-codesign --dart-define-from-file=.env.production`
  - `flutter build ipa --release --no-codesign --dart-define-from-file=.env.production`
  - `flutter build appbundle --release --dart-define-from-file=.env.production`
  - `cd android && ./gradlew :app:lintRelease`
- Test cases:
  - Track plan-defined `TC-IOS-*`, `TC-AND-*`, `TC-COMMON-*` execution in evidence docs.
