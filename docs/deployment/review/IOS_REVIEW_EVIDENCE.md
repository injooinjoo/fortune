# iOS Review Evidence (App Store)

최종 업데이트: 2026-03-20

## 1. Scope
- Platform: iOS
- Goal: conservative submission hardening for App Review
- Jira: `KAN-153`

## 2. Permission and Runtime Mapping
| check_id | severity | check_item | result | evidence | status |
|---|---|---|---|---|---|
| IOS-PERM-001 | P0 | Camera permission key exists and is limited to face/photo capture flows | pass | `ios/Runner/Info.plist`, `lib/features/interactive/presentation/pages/face_reading_page.dart` | done |
| IOS-PERM-002 | P0 | Photo library usage is limited to user-selected media | pass | `ios/Runner/Info.plist`, `lib/services/supabase_storage_service.dart` | done |
| IOS-PERM-003 | P0 | Microphone + speech recognition keys exist for voice input flows | pass | `ios/Runner/Info.plist`, `lib/services/speech_recognition_service.dart` | done |
| IOS-PERM-004 | P1 | Location permission is minimized to when-in-use only | pass | `ios/Runner/Info.plist` (`NSLocationWhenInUseUsageDescription`) | done |
| IOS-PERM-005 | P1 | Calendar permission flow and review narrative are manually verified | pending | `ios/Runner/Info.plist`, `lib/core/services/device_calendar_service.dart` | open |
| IOS-PERM-006 | P0 | ATT / tracking prompt removed from this release | pass | `ios/Runner/Info.plist`, `ios/Runner/PrivacyInfo.xcprivacy` | done |
| IOS-PERM-007 | P1 | Push notification permission is not requested at launch and is only requested from settings or test-notification actions | pass | `lib/main.dart`, `lib/services/notification/fcm_service.dart`, `lib/features/notification/presentation/pages/notification_settings_page.dart`, `ios/fastlane/metadata/review_information/review_notes.txt` | done |

## 3. Privacy Manifest and App Privacy
| check_id | severity | check_item | result | evidence | status |
|---|---|---|---|---|---|
| IOS-PRIV-001 | P0 | Privacy manifest is syntactically valid and `NSPrivacyTracking=false` | pass | `ios/Runner/PrivacyInfo.xcprivacy` | done |
| IOS-PRIV-002 | P1 | `NSPrivacyCollectedDataTypes` is mirrored in App Store Connect App Privacy answers | pending | `ios/Runner/PrivacyInfo.xcprivacy`, App Store Connect questionnaire | open |
| IOS-PRIV-003 | P0 | Tracking domains are not declared for this release | pass | `ios/Runner/PrivacyInfo.xcprivacy` | done |

## 4. Review Metadata and Public URLs
| check_id | severity | check_item | result | evidence | status |
|---|---|---|---|---|---|
| IOS-META-001 | P0 | Review notes frame the app as entertainment/wellbeing and explain review flow | pass | `metadata/review_information/notes.txt`, `ios/fastlane/metadata/review_information/review_notes.txt`, `ios/fastlane/Deliverfile` | done |
| IOS-META-002 | P0 | Demo credentials exist in both metadata sources | pass | `metadata/review_information/demo_user.txt`, `metadata/review_information/demo_password.txt`, `ios/fastlane/metadata/review_information/review_demo_user.txt`, `ios/fastlane/metadata/review_information/review_demo_password.txt` | done |
| IOS-META-003 | P0 | Privacy / Terms / Support URLs are publicly reachable | pass | `https://zpzg.co.kr/privacy`, `https://zpzg.co.kr/terms`, `https://zpzg.co.kr/support.html` | done |
| IOS-META-004 | P1 | ASC privacy policy field and support metadata are entered on the submitted version | pending | App Store Connect UI | open |
| IOS-META-005 | P1 | Age rating and content questionnaire are updated in App Store Connect | pending | App Store Connect UI | open |

## 5. Purchase and Account Flows
| check_id | severity | check_item | result | evidence | status |
|---|---|---|---|---|---|
| IOS-IAP-001 | P0 | Purchase success path verified end-to-end | pending | device recording + purchase logs | open |
| IOS-IAP-002 | P0 | Purchase cancel/error path recovers correctly | pending | device recording + logs | open |
| IOS-IAP-003 | P0 | Restore purchases path verified | pending | restore flow recording + logs | open |
| IOS-IAP-004 | P0 | Account deletion path is available in-app | pass | in-app settings flow, review notes | done |

## 6. Universal Links / Deep Links
| check_id | severity | check_item | result | evidence | status |
|---|---|---|---|---|---|
| IOS-LINK-001 | P0 | Associated Domains capability is disabled until live AASA and device verification are ready | pass | `ios/Runner/Runner.entitlements` | done |
| IOS-LINK-002 | P0 | AASA responds with HTTP 200 + JSON on apex and www | pass | `https://zpzg.co.kr/.well-known/apple-app-site-association`, `https://www.zpzg.co.kr/.well-known/apple-app-site-association` | done |
| IOS-LINK-003 | P1 | Device-level universal link open behavior is re-verified before re-enabling capability | pending | real-device recording | open |

## 7. Build and Verification
| check_id | severity | check_item | result | evidence | status |
|---|---|---|---|---|---|
| IOS-BUILD-001 | P0 | `flutter analyze --no-fatal-infos` has no errors | pass | local verification on 2026-03-20 | done |
| IOS-BUILD-002 | P0 | Touched Dart files in KAN-153 are formatted | pass | targeted `dart format --set-exit-if-changed` verification on 2026-03-20 | done |
| IOS-BUILD-003 | P0 | `flutter test` passes | pass | local verification on 2026-03-20 | done |
| IOS-BUILD-004 | P0 | `flutter build ios --release --no-codesign` passes after permission hardening | pass | local verification on 2026-03-20 | done |

## 8. Remaining Manual Evidence
- Real-device permission timing captures
- Purchase / restore / cancellation recordings
- App Store Connect screenshots for App Privacy, support URL, and age rating
