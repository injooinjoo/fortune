# Store Review Master Checklist (iOS/Android)

## 1. Purpose
- Objective: Block policy, quality, metadata, payment, and permission issues before App Store / Play Store submission.
- Release policy: **Submission allowed only when `P0=0` and `P1=0`**.
- Scope:
  - First launch
  - KR + EN metadata
  - Expanded device matrix (real devices + simulators/emulators)

## 2. Fixed Checklist Fields
Every check item must include the following fields:
- `check_id`
- `severity(P0/P1/P2)`
- `result(pass/fail/pending)`
- `evidence(path|url|screenshot)`
- `owner`
- `due_date`
- `status(open/in_progress/done/blocked)`

## 3. Severity Policy
- `P0`: Immediate launch blocker. Submission prohibited.
- `P1`: High risk blocker under this project policy. Submission prohibited.
- `P2`: Medium/low risk. Can proceed with explicit follow-up.

## 4. Kickoff and Freeze
| check_id | severity(P0/P1/P2) | check_item | result(pass/fail/pending) | evidence(path\|url\|screenshot) | owner | due_date | status |
|---|---|---|---|---|---|---|---|
| COM-KICK-001 | P0 | Jira issue created (`FORT` preferred, fallback `KAN`) | pass | `KAN-18` | release-owner | 2026-02-16 | done |
| COM-KICK-002 | P0 | Review target commit SHA frozen | pending | `git rev-parse HEAD` output in `/docs/deployment/review/RELEASE_DECISION_LOG.md` | release-owner | TBD | open |
| COM-KICK-003 | P0 | Block rule declared (`P0/P1 fail => no submit`) | pass | This document section 1/3 | release-owner | 2026-02-16 | done |

## 5. Source-of-Truth Matrix (KR+EN)
Priority policy:
- Priority 1: `/Users/jacobmac/Desktop/Dev/fortune/metadata/`
- Priority 2: `/Users/jacobmac/Desktop/Dev/fortune/ios/fastlane/metadata/`

| check_id | severity(P0/P1/P2) | check_item | result(pass/fail/pending) | evidence(path\|url\|screenshot) | owner | due_date | status |
|---|---|---|---|---|---|---|---|
| COM-SOT-001 | P0 | KR app name/subtitle/keywords parity (priority-1 vs priority-2) | pass | `metadata/ko/name.txt`, `metadata/ko/subtitle.txt`, `metadata/ko/keywords.txt`, `ios/fastlane/metadata/ko/name.txt`, `ios/fastlane/metadata/ko/subtitle.txt`, `ios/fastlane/metadata/ko/keywords.txt` | content-owner | 2026-02-16 | done |
| COM-SOT-002 | P0 | EN app name/subtitle/keywords parity (priority-1 vs priority-2) | pass | `metadata/en-US/name.txt`, `metadata/en-US/subtitle.txt`, `metadata/en-US/keywords.txt`, `ios/fastlane/metadata/en-US/name.txt`, `ios/fastlane/metadata/en-US/subtitle.txt`, `ios/fastlane/metadata/en-US/keywords.txt` | content-owner | 2026-02-16 | done |
| COM-SOT-003 | P0 | KR privacy/support URL present in both sources | pass | `metadata/ko/privacy_url.txt`, `metadata/ko/support_url.txt`, `ios/fastlane/metadata/ko/privacy_url.txt`, `ios/fastlane/metadata/ko/support_url.txt` | content-owner | 2026-02-16 | done |
| COM-SOT-004 | P1 | EN support URL present in priority-2 source | fail | Missing file: `ios/fastlane/metadata/en-US/support_url.txt` | content-owner | TBD | open |
| COM-SOT-005 | P0 | Review note + demo account evidence files exist | pass | `metadata/review_information/notes.txt`, `metadata/review_information/demo_user.txt`, `metadata/review_information/demo_password.txt`, `ios/fastlane/metadata/review_information/review_notes.txt`, `ios/fastlane/metadata/review_information/review_demo_user.txt`, `ios/fastlane/metadata/review_information/review_demo_password.txt` | release-owner | 2026-02-16 | done |

## 6. URL Health Evidence
Run and attach output:
- `curl -sSIL https://zpzg.co.kr/privacy.html`
- `curl -sSIL https://zpzg.co.kr/support.html`
- `curl -sSIL https://zpzg.co.kr/.well-known/apple-app-site-association`
- `curl -sSIL https://zpzg.co.kr/.well-known/assetlinks.json`

| check_id | severity(P0/P1/P2) | check_item | result(pass/fail/pending) | evidence(path\|url\|screenshot) | owner | due_date | status |
|---|---|---|---|---|---|---|---|
| COM-URL-001 | P0 | Privacy URL returns HTTP 200 | pass | URL: `https://zpzg.co.kr/privacy.html` | web-owner | 2026-02-16 | done |
| COM-URL-002 | P0 | Support URL returns HTTP 200 | pass | URL: `https://zpzg.co.kr/support.html` | web-owner | 2026-02-16 | done |
| COM-URL-003 | P0 | AASA endpoint returns HTTP 200 on apex domain | pass | URL: `https://zpzg.co.kr/.well-known/apple-app-site-association` | web-owner | 2026-02-16 | done |
| COM-URL-004 | P0 | Asset Links endpoint returns HTTP 200 and JSON | pass | URL: `https://zpzg.co.kr/.well-known/assetlinks.json` | web-owner | 2026-02-16 | done |
| COM-URL-005 | P2 | AASA Content-Type normalized to `application/json` | pending | Current: `application/octet-stream` | web-owner | TBD | open |

## 7. Automated Gates
| check_id | severity(P0/P1/P2) | check_item | result(pass/fail/pending) | evidence(path\|url\|screenshot) | owner | due_date | status |
|---|---|---|---|---|---|---|---|
| COM-AUTO-001 | P0 | `flutter analyze` | fail | `docs/development/reports/2026-02-16_store_review_strategy_verify.md` | eng-owner | 2026-02-16 | blocked |
| COM-AUTO-002 | P0 | `dart format --set-exit-if-changed .` | pass | `docs/development/reports/2026-02-16_store_review_strategy_verify.md` | eng-owner | 2026-02-16 | done |
| COM-AUTO-003 | P0 | `flutter test` | pass | `docs/development/reports/2026-02-16_store_review_strategy_verify.md` | eng-owner | 2026-02-16 | done |
| COM-AUTO-004 | P0 | `bash ./scripts/ios_full_regression.sh` | fail | `docs/development/reports/2026-02-16_store_review_strategy_verify.md` | ios-owner | 2026-02-16 | blocked |
| COM-AUTO-005 | P0 | `flutter build ios --release --no-codesign --dart-define-from-file=.env.production` | pass | `docs/development/reports/2026-02-16_store_review_strategy_verify.md` | ios-owner | 2026-02-16 | done |
| COM-AUTO-006 | P0 | `flutter build ipa --release --no-codesign --dart-define-from-file=.env.production` | pass | `docs/development/reports/2026-02-16_store_review_strategy_verify.md` | ios-owner | 2026-02-16 | done |
| COM-AUTO-007 | P0 | `flutter build appbundle --release --dart-define-from-file=.env.production` | pass | `docs/development/reports/2026-02-16_store_review_strategy_verify.md` | android-owner | 2026-02-16 | done |
| COM-AUTO-008 | P0 | `cd android && ./gradlew :app:lintRelease` | pass | `docs/development/reports/2026-02-16_store_review_strategy_verify.md` | android-owner | 2026-02-16 | done |

## 8. Manual Verification Matrix (Expanded)
| check_id | severity(P0/P1/P2) | check_item | result(pass/fail/pending) | evidence(path\|url\|screenshot) | owner | due_date | status |
|---|---|---|---|---|---|---|---|
| COM-MAN-001 | P0 | iOS real device run (KR/EN) | pending | video + screenshots | qa-owner | TBD | open |
| COM-MAN-002 | P0 | iOS simulator run: iPhone + iPad (KR/EN) | pending | simulator captures | qa-owner | TBD | open |
| COM-MAN-003 | P0 | Android real device run (KR/EN) | pending | video + screenshots | qa-owner | TBD | open |
| COM-MAN-004 | P0 | Android emulator run (API 35+, KR/EN) | pending | emulator captures | qa-owner | TBD | open |

## 9. Required Test Cases
| check_id | severity(P0/P1/P2) | check_item | result(pass/fail/pending) | evidence(path\|url\|screenshot) | owner | due_date | status |
|---|---|---|---|---|---|---|---|
| TC-IOS-001 | P0 | App install -> first launch -> onboarding complete | pending | iOS run recording | qa-owner | TBD | open |
| TC-IOS-002 | P0 | Camera/photo permission timing and copy validation | pending | permission prompt captures | qa-owner | TBD | open |
| TC-IOS-003 | P0 | IAP success -> token/subscription reflected | pending | purchase logs + UI capture | qa-owner | TBD | open |
| TC-IOS-004 | P0 | IAP cancel/error handling and UI recovery | pending | cancel/error logs | qa-owner | TBD | open |
| TC-IOS-005 | P0 | Restore purchases flow | pending | restore logs + UI capture | qa-owner | TBD | open |
| TC-IOS-006 | P0 | Universal link opens app (not browser fallback) | pending | deep link video | qa-owner | TBD | open |
| TC-AND-001 | P0 | AAB build/install/run | pending | build log + install capture | qa-owner | TBD | open |
| TC-AND-002 | P0 | Runtime permission grant/deny/re-request | pending | permission flow captures | qa-owner | TBD | open |
| TC-AND-003 | P1 | Purchase success/cancel/restore on Android | pending | billing + backend logs | qa-owner | TBD | open |
| TC-AND-004 | P0 | App Links autoVerify + deep link open | pending | adb/app link evidence | qa-owner | TBD | open |
| TC-COMMON-001 | P0 | KR/EN metadata parity | pending | matrix snapshot | content-owner | TBD | open |
| TC-COMMON-002 | P0 | Privacy/Support URL HTTP 200 | pass | URL checks in section 6 | web-owner | 2026-02-16 | done |
| TC-COMMON-003 | P0 | Analyze/test/release build all green | fail | `docs/development/reports/2026-02-16_store_review_strategy_verify.md` | eng-owner | 2026-02-16 | blocked |

## 10. Known Baseline Risks (Track Until Closed)
| check_id | severity(P0/P1/P2) | check_item | result(pass/fail/pending) | evidence(path\|url\|screenshot) | owner | due_date | status |
|---|---|---|---|---|---|---|---|
| RISK-001 | P1 | Android server-side purchase validation is TODO | fail | `/supabase/functions/payment-verify-purchase/index.ts` (`// TODO: Google Play 영수증 검증 구현`) | backend-owner | TBD | open |
| RISK-002 | P1 | EN support URL missing in fastlane metadata fallback source | fail | Missing: `ios/fastlane/metadata/en-US/support_url.txt` | content-owner | TBD | open |

## 11. Submit/Block Rule
- **Block**: Any row with `severity=P0 or P1` and `result=fail` or `result=pending`.
- **Submit**: Only when all `P0/P1` rows are `pass`, with evidence links filled.
