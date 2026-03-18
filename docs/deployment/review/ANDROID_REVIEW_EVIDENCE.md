# Android Review Evidence (Google Play)

최종 업데이트: 2026-03-18

## 1. Scope
- Platform: Android
- Goal: conservative submission hardening for Google Play
- Jira: `KAN-135`

## 2. Manifest Permission Minimality
| check_id | severity | check_item | result | evidence | status |
|---|---|---|---|---|---|
| AND-PERM-001 | P0 | Billing permission declared and purchase feature is mapped | pass | `android/app/src/main/AndroidManifest.xml`, `lib/services/in_app_purchase_service.dart` | done |
| AND-PERM-002 | P1 | Notification permission behavior is manually verified | pending | `android/app/src/main/AndroidManifest.xml`, runtime capture | open |
| AND-PERM-003 | P0 | Broad media permission removed; photo access is user-selected only | pass | `android/app/src/main/AndroidManifest.xml`, `lib/services/supabase_storage_service.dart` | done |
| AND-PERM-004 | P0 | Audio permission is limited to speech/voice features | pass | `android/app/src/main/AndroidManifest.xml`, `lib/services/speech_recognition_service.dart` | done |
| AND-PERM-005 | P1 | Calendar permission flow is justified and manually tested | pending | `android/app/src/main/AndroidManifest.xml`, `lib/core/services/device_calendar_service.dart` | open |
| AND-PERM-006 | P1 | Location permission flow is justified and manually tested | pending | `android/app/src/main/AndroidManifest.xml`, `lib/core/services/location_manager.dart` | open |

## 3. Data Safety and Policy Parity
| check_id | severity | check_item | result | evidence | status |
|---|---|---|---|---|---|
| AND-DATA-001 | P0 | Data Safety form is entered in Play Console | pending | Play Console UI | open |
| AND-DATA-002 | P1 | Data collection declarations match code/runtime behavior | pending | `android/app/src/main/AndroidManifest.xml`, `ios/Runner/PrivacyInfo.xcprivacy`, metadata docs | open |
| AND-DATA-003 | P1 | Ad / tracking declarations remain removed from release narrative | pass | repo config cleanup from KAN-134 + current metadata | done |

## 4. App Links and `.well-known`
| check_id | severity | check_item | result | evidence | status |
|---|---|---|---|---|---|
| AND-LINK-001 | P0 | `autoVerify` remains disabled until live asset links and device checks are complete | pass | `android/app/src/main/AndroidManifest.xml` | done |
| AND-LINK-002 | P0 | `assetlinks.json` is reachable on apex and www with HTTP 200 + JSON | pass | `https://zpzg.co.kr/.well-known/assetlinks.json`, `https://www.zpzg.co.kr/.well-known/assetlinks.json` | done |
| AND-LINK-003 | P1 | `assetlinks.json` fingerprint matches final signing certificate | pending | live JSON + Play Console App Signing certificate if enabled | open |
| AND-LINK-004 | P1 | Device-level App Links open behavior is verified before re-enabling `autoVerify` | pending | adb verification + device recording | open |

## 5. Build and Stability
| check_id | severity | check_item | result | evidence | status |
|---|---|---|---|---|---|
| AND-STAB-001 | P0 | `flutter analyze --no-fatal-infos` has no errors | pass | local verification on 2026-03-18 | done |
| AND-STAB-002 | P0 | `dart format --set-exit-if-changed .` passes | pass | local verification on 2026-03-18 | done |
| AND-STAB-003 | P0 | `flutter test` passes | pass | local verification on 2026-03-18 | done |
| AND-STAB-004 | P0 | `flutter build appbundle --release` remains verified from KAN-134 hardening pass | pass | local verification on 2026-03-18 during KAN-134 | done |

## 6. Store Copy and Support
| check_id | severity | check_item | result | evidence | status |
|---|---|---|---|---|---|
| AND-COPY-001 | P1 | KR/EN store descriptions avoid unlimited access and misleading health claims | pass | `android/fastlane/metadata/android/ko-KR/full_description.txt`, `android/fastlane/metadata/android/en-US/full_description.txt` | done |
| AND-COPY-002 | P0 | Public support / privacy / terms URLs are live | pass | `https://zpzg.co.kr/privacy`, `https://zpzg.co.kr/terms`, `https://zpzg.co.kr/support.html` | done |
| AND-COPY-003 | P1 | Content rating and App Content forms are aligned in Play Console | pending | Play Console UI | open |

## 7. Remaining Manual Evidence
- Pre-launch report
- Device-level permission captures
- Purchase / restore / cancellation recordings
- Play Console Data Safety / Content Rating screenshots
