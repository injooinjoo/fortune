# iOS Review Evidence (App Store)

최종 업데이트: 2026-03-22

## 1. Scope
- Platform: iOS
- Goal: App Review 재제출용 보수 패키지 정리
- Current Jira: `KAN-166`
- 기준: 현재 저장소와 2026-03-21 Apple rejection message를 함께 반영

## 2. Permission and Runtime Mapping
| check_id | severity | check_item | result | evidence | status |
|---|---|---|---|---|---|
| IOS-PERM-001 | P0 | Camera permission key exists and is limited to face/photo capture flows | pass | `ios/Runner/Info.plist`, `lib/features/chat/presentation/widgets/survey/chat_face_reading_flow.dart` | done |
| IOS-PERM-002 | P0 | Photo library usage is limited to user-selected media | pass | `ios/Runner/Info.plist`, `lib/services/supabase_storage_service.dart` | done |
| IOS-PERM-003 | P0 | Microphone + speech recognition keys exist for voice input flows | pass | `ios/Runner/Info.plist`, `lib/services/speech_recognition_service.dart` | done |
| IOS-PERM-004 | P1 | Location permission is minimized to when-in-use only | pass | `ios/Runner/Info.plist` (`NSLocationWhenInUseUsageDescription`) | done |
| IOS-PERM-005 | P1 | Calendar permission has been removed from this iOS submission scope | pass | `ios/Runner/Info.plist`, `public/privacy.html`, `docs/deployment/APP_STORE_SUBMISSION_INFO.md`, `ios/fastlane/metadata/review_information/review_notes.txt` | done |
| IOS-PERM-006 | P0 | ATT / tracking prompt removed from this release | pass | `ios/Runner/PrivacyInfo.xcprivacy` | done |
| IOS-PERM-007 | P1 | Push notification permission is not requested at launch and is only requested from settings or test-notification actions | pass | `lib/main.dart`, `lib/services/notification/fcm_service.dart`, `lib/features/notification/presentation/pages/notification_settings_page.dart`, `ios/fastlane/metadata/review_information/review_notes.txt` | done |

## 3. Privacy Manifest and App Privacy
| check_id | severity | check_item | result | evidence | status |
|---|---|---|---|---|---|
| IOS-PRIV-001 | P0 | Privacy manifest is syntactically valid and `NSPrivacyTracking=false` | pass | `ios/Runner/PrivacyInfo.xcprivacy` | done |
| IOS-PRIV-002 | P1 | `NSPrivacyCollectedDataTypes` is mirrored in App Store Connect App Privacy answers | pass | `ios/Runner/PrivacyInfo.xcprivacy`, ASC verification record from 2026-03-20 | done |
| IOS-PRIV-003 | P0 | Tracking domains are not declared for this release | pass | `ios/Runner/PrivacyInfo.xcprivacy` | done |
| IOS-PRIV-004 | P0 | Third-party AI provider disclosure is present in public and in-app privacy policy | pass | `public/privacy.html`, `lib/features/policy/presentation/pages/privacy_policy_page.dart` | done |

## 4. Review Metadata and Public URLs
| check_id | severity | check_item | result | evidence | status |
|---|---|---|---|---|---|
| IOS-META-001 | P0 | Review notes frame the app as entertainment/wellbeing and explain the review path | pass | `ios/fastlane/metadata/review_information/review_notes.txt`, `ios/fastlane/Deliverfile` | done |
| IOS-META-002 | P0 | Demo credentials exist in metadata sources | pass | `metadata/review_information/demo_user.txt`, `metadata/review_information/demo_password.txt`, `ios/fastlane/metadata/review_information/review_demo_user.txt`, `ios/fastlane/metadata/review_information/review_demo_password.txt` | done |
| IOS-META-003 | P0 | Privacy / Terms / Support URLs are publicly reachable | pass | `https://zpzg.co.kr/privacy`, `https://zpzg.co.kr/terms`, `https://zpzg.co.kr/support` | done |
| IOS-META-004 | P1 | App Store description, release notes, public policies, and in-app policy pages are synchronized to the ZPZG positioning | pass | `ios/fastlane/metadata/ko/description.txt`, `ios/fastlane/metadata/en-US/description.txt`, `ios/fastlane/metadata/ko/release_notes.txt`, `ios/fastlane/metadata/en-US/release_notes.txt`, `public/privacy.html`, `public/terms.html`, `lib/features/policy/presentation/pages/*.dart` | done |
| IOS-META-005 | P1 | ASC privacy policy field and support metadata are entered on the submitted version | pass | ASC verification record from 2026-03-20 | done |
| IOS-META-006 | P1 | Age rating and content questionnaire are updated in App Store Connect | pass | ASC verification record from 2026-03-20 | done |

## 5. Runtime / Review-Flow Risks
| check_id | severity | check_item | result | evidence | status |
|---|---|---|---|---|---|
| IOS-RUNTIME-001 | P0 | The previous 2026-03-21 App Review rejection path (`Network connection error` during Apple sign-in flow) is closed in code | pass | `b17233ab`, `lib/core/services/supabase_connection_service.dart`, `lib/presentation/widgets/social_login_bottom_sheet.dart`, `ios/fastlane/Deliverfile` | done |
| IOS-RUNTIME-002 | P0 | The same rejection path is re-verified on a real iPhone after clean install | pending | screen recording + device/app logs | open |
| IOS-RUNTIME-003 | P1 | iPad review path (`/chat`, login, policy, purchase`) is checked on a real iPad | pending | iPad recording + notes | open |
| IOS-RUNTIME-004 | P1 | IPv6-only / NAT64 path is rechecked if available | pending | network test notes + recording | open |

## 6. Purchase and Account Flows
| check_id | severity | check_item | result | evidence | status |
|---|---|---|---|---|---|
| IOS-IAP-001 | P0 | Purchase success path verified end-to-end | pending | device recording + purchase logs | open |
| IOS-IAP-002 | P0 | Purchase cancel/error path recovers correctly | pending | device recording + logs | open |
| IOS-IAP-003 | P0 | Restore purchases path verified | pending | restore flow recording + logs | open |
| IOS-IAP-004 | P0 | Account deletion path is available in-app | pass | `lib/screens/profile/account_deletion_page.dart`, review notes | done |
| IOS-IAP-005 | P0 | Token expiry wording has been removed from current purchase / policy copy | pass | `lib/core/constants/in_app_products.dart`, `lib/features/policy/presentation/pages/terms_of_service_page.dart`, `public/terms.html` | done |

## 7. Universal Links / Deep Links
| check_id | severity | check_item | result | evidence | status |
|---|---|---|---|---|---|
| IOS-LINK-001 | P0 | Associated Domains capability is disabled while universal links are outside current review scope | pass | `ios/Runner/Runner.entitlements` | done |
| IOS-LINK-002 | P0 | AASA responds with HTTP 200 + JSON on apex and www | pass | `https://zpzg.co.kr/.well-known/apple-app-site-association`, `https://www.zpzg.co.kr/.well-known/apple-app-site-association` | done |
| IOS-LINK-003 | P1 | Device-level universal link verification is deferred until the capability is intentionally re-enabled | pass | `ios/Runner/Runner.entitlements`, `docs/deployment/APP_STORE_SUBMISSION_INFO.md` | done |

## 8. Background / Extension Scope
| check_id | severity | check_item | result | evidence | status |
|---|---|---|---|---|---|
| IOS-EXT-001 | P0 | Unused Live Activity, Siri shortcut, NSUserActivity, Quick Action, and BGTask declarations have been removed from the submission scope | pass | `ios/Runner/Info.plist`, `ios/Runner/AppDelegate.swift`, `ios/Runner/NativePlatformPlugin.swift`, `lib/services/native_platform_service.dart`, `ios/fastlane/metadata/review_information/review_notes.txt` | done |
| IOS-EXT-002 | P1 | Widget scope remains relevant to the app and background modes are minimized to `remote-notification` | pass | `ios/Runner/Info.plist`, `lib/services/widget_data_service.dart` | done |

## 9. Build and Verification
| check_id | severity | check_item | result | evidence | status |
|---|---|---|---|---|---|
| IOS-BUILD-001 | P0 | `flutter analyze --no-fatal-infos` has no errors | pass | local verification on 2026-03-22 (`flutter analyze --no-fatal-infos`) | done |
| IOS-BUILD-002 | P0 | `dart format --set-exit-if-changed .` is clean or intentionally reconciled | pass | local verification on 2026-03-22 (`dart format --set-exit-if-changed .`) | done |
| IOS-BUILD-003 | P0 | Regression tests relevant to auth / policy / widget changes pass | pass | local verification on 2026-03-22 (`flutter test`, `flutter test test/features/character/presentation/widgets/embedded_fortune_component_test.dart`, `flutter test test/widget/auth/social_auth_pending_state_test.dart`, `flutter build ios --release --no-codesign`) | done |

## 10. Remaining Manual Evidence Package
- iPhone clean-install recording:
  - delete app
  - reinstall build
  - enter as guest
  - open login bottom sheet from messages/profile path
  - complete Sign in with Apple
  - confirm no misleading network error toast appears
- IAP recordings:
  - success
  - cancellation
  - restore purchases
- iPad recording:
  - `/chat`
  - login
  - policy pages
  - purchase entry
- Optional network note:
  - second network type
  - NAT64 / IPv6-only if available
