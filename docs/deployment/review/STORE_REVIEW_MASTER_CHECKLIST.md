# Store Review Master Checklist (iOS / Android)

최종 업데이트: 2026-03-22

## 1. Release Policy
- Apple 재제출은 `APPLE-P0`, `APPLE-P1`가 모두 닫혔을 때만 진행합니다.
- Android / Play 배포 점검은 별도 `PLAY-*` 행으로 관리합니다.
- Current Jira for this hardening batch: `KAN-166`

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

## 3. Apple Current Pass Items
| check_id | severity | check_item | result | evidence | status |
|---|---|---|---|---|---|
| APPLE-KICK-001 | P0 | Jira issue created for current App Review hardening batch | pass | `KAN-166` | done |
| APPLE-URL-001 | P0 | Privacy URL returns HTTP 200 | pass | `https://zpzg.co.kr/privacy` | done |
| APPLE-URL-002 | P0 | Terms URL returns HTTP 200 | pass | `https://zpzg.co.kr/terms` | done |
| APPLE-URL-003 | P0 | Support URL returns HTTP 200 | pass | `https://zpzg.co.kr/support` | done |
| APPLE-URL-004 | P0 | AASA endpoint returns HTTP 200 on apex and www | pass | `https://zpzg.co.kr/.well-known/apple-app-site-association`, `https://www.zpzg.co.kr/.well-known/apple-app-site-association` | done |
| APPLE-POLICY-001 | P0 | Public policies, in-app policies, and App Store metadata are aligned to the ZPZG positioning | pass | `public/privacy.html`, `public/terms.html`, `lib/features/policy/presentation/pages/*.dart`, `ios/fastlane/metadata/*` | done |
| APPLE-POLICY-002 | P0 | Third-party AI provider disclosure is included in privacy policy | pass | `public/privacy.html`, `lib/features/policy/presentation/pages/privacy_policy_page.dart` | done |
| APPLE-IAP-001 | P0 | Token expiry wording has been removed from current copy | pass | `lib/core/constants/in_app_products.dart`, `public/terms.html`, `lib/features/policy/presentation/pages/terms_of_service_page.dart` | done |
| APPLE-IOS-001 | P0 | Live Activity / Siri / Quick Action / calendar / BGTask overdeclarations were removed from the current iOS submission scope | pass | `ios/Runner/Info.plist`, `ios/Runner/AppDelegate.swift`, `ios/Runner/NativePlatformPlugin.swift`, `ios/fastlane/metadata/review_information/review_notes.txt` | done |
| APPLE-IOS-002 | P0 | Associated Domains remains disabled while universal links are outside the current review scope | pass | `ios/Runner/Runner.entitlements` | done |
| APPLE-IOS-003 | P0 | Review notes explain entertainment/wellbeing framing and current review path | pass | `ios/fastlane/metadata/review_information/review_notes.txt`, `ios/fastlane/Deliverfile` | done |
| APPLE-ASC-001 | P1 | App Store Connect App Privacy questionnaire entered and reviewed | pass | ASC verification record from 2026-03-20 | done |
| APPLE-ASC-002 | P1 | App Store age rating / content questionnaire updated | pass | ASC verification record from 2026-03-20 | done |

## 4. Apple Remaining Manual Items
| check_id | severity | check_item | result | evidence | status |
|---|---|---|---|---|---|
| APPLE-RUNTIME-001 | P0 | Previous 2026-03-21 Apple rejection path is re-verified on a real iPhone after clean install | pending | recording + device/app logs | open |
| APPLE-IAP-002 | P0 | Purchase success, cancellation, and restore flows are captured on-device | pending | recordings + logs | open |
| APPLE-RUNTIME-002 | P1 | iPad review path is verified (`/chat`, login, policy, purchase entry) | pending | iPad notes + recording | open |
| APPLE-RUNTIME-003 | P1 | NAT64 / IPv6-only retry path is checked if a test network is available | pending | network notes | open |

## 5. Android / Play Separate Open Items
| check_id | severity | check_item | result | evidence | status |
|---|---|---|---|---|---|
| PLAY-001 | P1 | Google Play Data Safety form entered and reviewed | pending | Play Console UI | open |
| PLAY-002 | P1 | Google Play content rating / app content forms updated | pending | Play Console UI | open |
| PLAY-003 | P1 | Final Play App Signing SHA-256 checked against live `assetlinks.json` | pending | Play Console UI | open |

## 6. Block Rule
- Apple 재제출 차단 기준:
  - `APPLE-P0`, `APPLE-P1` 중 `open`이 있으면 재제출 보류
- Cross-platform release 차단 기준:
  - Apple + Play rows 모두 닫혀야 전체 스토어 체크리스트 완료

현재 상태:
- 코드/정책/메타데이터 기준 Apple blocker는 정리됨
- Apple 재제출의 남은 항목은 `실기기 증빙 패키지`뿐임
- Android / Play 행은 별도 배포 준비 과제로 유지
