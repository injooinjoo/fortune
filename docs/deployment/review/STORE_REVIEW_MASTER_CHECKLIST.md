# Store Review Master Checklist (iOS / Android)

최종 업데이트: 2026-03-20

## 1. Release Policy
- Submission allowed only when all `P0` and `P1` items are closed.
- Current Jira for deployment / public review hardening: `KAN-153`

## 2. Source-of-Truth
- Metadata source:
  - `metadata/`
  - `ios/fastlane/metadata/`
  - `android/fastlane/metadata/android/`
- Public review site source:
  - `public/`
- Live domain:
  - `https://zpzg.co.kr`
  - `https://www.zpzg.co.kr`

## 3. Current Pass Items
| check_id | severity | check_item | result | evidence | status |
|---|---|---|---|---|---|
| COM-KICK-001 | P0 | Jira issue created for final review hardening | pass | `KAN-153` | done |
| COM-URL-001 | P0 | Privacy URL returns HTTP 200 | pass | `https://zpzg.co.kr/privacy` | done |
| COM-URL-002 | P0 | Terms URL returns HTTP 200 | pass | `https://zpzg.co.kr/terms` | done |
| COM-URL-003 | P0 | Support URL returns HTTP 200 | pass | `https://zpzg.co.kr/support.html`, `https://zpzg.co.kr/support` | done |
| COM-URL-004 | P0 | AASA endpoint returns HTTP 200 on apex and www | pass | `https://zpzg.co.kr/.well-known/apple-app-site-association`, `https://www.zpzg.co.kr/.well-known/apple-app-site-association` | done |
| COM-URL-005 | P0 | Asset Links endpoint returns HTTP 200 + JSON on apex and www | pass | `https://zpzg.co.kr/.well-known/assetlinks.json`, `https://www.zpzg.co.kr/.well-known/assetlinks.json` | done |
| COM-URL-006 | P0 | AASA content type is normalized to `application/json` | pass | live curl verification on 2026-03-18 | done |
| COM-AUTO-001 | P0 | `flutter analyze --no-fatal-infos` has no errors | pass | local verification on 2026-03-20 | done |
| COM-AUTO-002 | P0 | Touched Dart files in KAN-153 are formatted | pass | targeted `dart format --set-exit-if-changed` verification on 2026-03-20 | done |
| COM-AUTO-003 | P0 | `flutter test` passes | pass | local verification on 2026-03-20 | done |
| COM-AUTO-004 | P0 | `./scripts/build_web_release.sh` completes and emits public review assets into `build/web` | pass | local verification on 2026-03-18 | done |
| COM-AUTO-005 | P0 | Source inventory regenerated after doc/static changes | pass | `artifacts/file_inventory.json` regeneration on 2026-03-20 | done |
| COM-AUTO-006 | P0 | `flutter build ios --release --no-codesign` passes after iOS review hardening | pass | local verification on 2026-03-20 | done |
| COM-ASC-001 | P1 | App Store Connect App Privacy questionnaire entered and reviewed | pass | ASC App Privacy UI verified via Playwright on 2026-03-20 | done |
| COM-ASC-002 | P1 | App Store age rating / content questionnaire updated | pass | ASC App Information UI verified via Playwright on 2026-03-20 | done |

## 4. Remaining Open Items
| check_id | severity | check_item | result | evidence | status |
|---|---|---|---|---|---|
| COM-PLAY-001 | P1 | Google Play Data Safety form entered and reviewed | pending | Play Console UI | open |
| COM-PLAY-002 | P1 | Google Play content rating / app content forms updated | pending | Play Console UI | open |
| COM-IAP-001 | P0 | iOS/Android purchase success, cancellation, restore flows captured | pending | device recordings + logs | open |
| COM-LINK-001 | P1 | Device-level universal links / app links verified before re-enabling capability | pending | real-device tests | open |
| COM-SIGN-001 | P1 | Final Play App Signing SHA-256 checked against live `assetlinks.json` | pending | Play Console UI | open |

## 5. Block Rule
- Block release when any row with severity `P0` or `P1` is still `pending`.
- Current state:
  - ATT removal, when-in-use location scope, and contextual push-permission flow are aligned in the iOS binary and review notes as of 2026-03-20.
  - Public review URLs and `.well-known` deployment are live.
  - App Store Connect privacy metadata, support/privacy URLs, age rating, and review notes were verified on 2026-03-20.
  - Google Play console declarations and manual purchase/device evidence are still required.
