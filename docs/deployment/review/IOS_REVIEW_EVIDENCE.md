# iOS Review Evidence (App Store)

## 1. Scope
- Platform: iOS (App Store Connect + TestFlight + App Review)
- Locale: KR + EN
- Gate policy: `P0=0`, `P1=0` required for submission

## 2. Permission-to-Runtime Mapping
| check_id | severity(P0/P1/P2) | check_item | result(pass/fail/pending) | evidence(path\|url\|screenshot) | owner | due_date | status |
|---|---|---|---|---|---|---|---|
| IOS-PERM-001 | P0 | Camera permission key exists and runtime request is mapped | pass | `ios/Runner/Info.plist` (`NSCameraUsageDescription`), `lib/features/interactive/presentation/pages/face_reading_page.dart` | ios-owner | 2026-02-16 | done |
| IOS-PERM-002 | P0 | Photo library permission key exists and runtime request is mapped | pass | `ios/Runner/Info.plist` (`NSPhotoLibraryUsageDescription`), `lib/features/interactive/presentation/pages/face_reading_page.dart` | ios-owner | 2026-02-16 | done |
| IOS-PERM-003 | P0 | Microphone + speech recognition keys exist and runtime requests are mapped | pass | `ios/Runner/Info.plist` (`NSMicrophoneUsageDescription`, `NSSpeechRecognitionUsageDescription`), `lib/services/speech_recognition_service.dart` | ios-owner | 2026-02-16 | done |
| IOS-PERM-004 | P1 | Location key(s) and request flow are minimally scoped for feature use | pending | `ios/Runner/Info.plist` (`NSLocationAlwaysAndWhenInUseUsageDescription`, `NSLocationWhenInUseUsageDescription`), `lib/core/services/location_manager.dart` | ios-owner | TBD | open |
| IOS-PERM-005 | P1 | Calendar keys and usage flow are aligned with review narrative | pending | `ios/Runner/Info.plist` (`NSCalendarsUsageDescription`, `NSCalendarsFullAccessUsageDescription`), `lib/core/services/device_calendar_service.dart` | ios-owner | TBD | open |
| IOS-PERM-006 | P1 | ATT usage description and runtime behavior consistency | pending | `ios/Runner/Info.plist` (`NSUserTrackingUsageDescription`), code search evidence for ATT request flow | ios-owner | TBD | open |

## 3. Privacy Manifest vs App Privacy Declaration
| check_id | severity(P0/P1/P2) | check_item | result(pass/fail/pending) | evidence(path\|url\|screenshot) | owner | due_date | status |
|---|---|---|---|---|---|---|---|
| IOS-PRIV-001 | P0 | Privacy Manifest file exists and is valid plist | pass | `ios/Runner/PrivacyInfo.xcprivacy` | ios-owner | 2026-02-16 | done |
| IOS-PRIV-002 | P1 | `NSPrivacyCollectedDataTypes` matches App Store Connect App Privacy answers | pending | `ios/Runner/PrivacyInfo.xcprivacy`, ASC questionnaire screenshots | privacy-owner | TBD | open |
| IOS-PRIV-003 | P1 | Tracking declaration (`NSPrivacyTracking`) matches runtime tracking behavior | pending | `ios/Runner/PrivacyInfo.xcprivacy`, SDK usage audit | privacy-owner | TBD | open |

## 4. Review Metadata and Account Evidence
| check_id | severity(P0/P1/P2) | check_item | result(pass/fail/pending) | evidence(path\|url\|screenshot) | owner | due_date | status |
|---|---|---|---|---|---|---|---|
| IOS-META-001 | P0 | Review note includes entertainment framing + test flow + premium test guidance | pass | `metadata/review_information/notes.txt`, `ios/fastlane/metadata/review_information/review_notes.txt` | content-owner | 2026-02-16 | done |
| IOS-META-002 | P0 | Demo credentials exist in both metadata sources | pass | `metadata/review_information/demo_user.txt`, `metadata/review_information/demo_password.txt`, `ios/fastlane/metadata/review_information/review_demo_user.txt`, `ios/fastlane/metadata/review_information/review_demo_password.txt` | release-owner | 2026-02-16 | done |
| IOS-META-003 | P1 | KR+EN metadata completeness with no fallback mismatch | pass | `metadata/ko/*`, `metadata/en-US/*`, `ios/fastlane/metadata/ko/*`, `ios/fastlane/metadata/en-US/*`, `ios/fastlane/metadata/en-US/support_url.txt` | content-owner | 2026-02-16 | done |
| IOS-META-004 | P1 | Age rating / content rating questionnaire updated in ASC | pending | ASC screenshots + exported rating config (`ios/fastlane/metadata/app_rating_config.json`) | release-owner | TBD | open |

## 5. Purchase and Subscription Evidence
| check_id | severity(P0/P1/P2) | check_item | result(pass/fail/pending) | evidence(path\|url\|screenshot) | owner | due_date | status |
|---|---|---|---|---|---|---|---|
| IOS-IAP-001 | P0 | Purchase success path (token/subscription) verified end-to-end | pending | UI recording + app logs + backend logs | ios-owner | TBD | open |
| IOS-IAP-002 | P0 | Purchase cancel/error path recovers correctly | pending | UI recording + app logs | ios-owner | TBD | open |
| IOS-IAP-003 | P0 | Restore purchases path verified | pending | restore flow recording + logs | ios-owner | TBD | open |
| IOS-IAP-004 | P0 | Apple receipt verification production-first + 21007 sandbox fallback works | pass | `/supabase/functions/payment-verify-purchase/index.ts` (Apple Production -> Sandbox flow) | backend-owner | 2026-02-16 | done |

## 6. Deep Link / Universal Link Evidence
| check_id | severity(P0/P1/P2) | check_item | result(pass/fail/pending) | evidence(path\|url\|screenshot) | owner | due_date | status |
|---|---|---|---|---|---|---|---|
| IOS-LINK-001 | P0 | Associated Domains entitlement includes apex + www | pass | `ios/Runner/Runner.entitlements` | ios-owner | 2026-02-16 | done |
| IOS-LINK-002 | P0 | AASA endpoint responds on apex domain | pass | `https://zpzg.co.kr/.well-known/apple-app-site-association` | web-owner | 2026-02-16 | done |
| IOS-LINK-003 | P0 | Device-level universal link opens app, not browser fallback | pending | real-device screen recording | qa-owner | TBD | open |

## 7. Version / Build Consistency
| check_id | severity(P0/P1/P2) | check_item | result(pass/fail/pending) | evidence(path\|url\|screenshot) | owner | due_date | status |
|---|---|---|---|---|---|---|---|
| IOS-BUILD-001 | P0 | iOS release no-codesign build succeeds with production defines | pass | `docs/development/reports/2026-02-16_store_review_gate_blockers_verify.md` | ios-owner | 2026-02-16 | done |
| IOS-BUILD-002 | P0 | iOS archive via `flutter build ipa --no-codesign` succeeds | pass | `docs/development/reports/2026-02-16_store_review_gate_blockers_verify.md` | ios-owner | 2026-02-16 | done |
| IOS-VERS-001 | P0 | `pubspec.yaml` version aligns with built iOS app version/build | pending | `pubspec.yaml`, `flutter build` output, app bundle metadata | release-owner | TBD | open |
| IOS-VERS-002 | P0 | App Store Connect selected build matches frozen commit | pending | ASC build screen capture + commit SHA | release-owner | TBD | open |

## 8. Screenshot Compliance
| check_id | severity(P0/P1/P2) | check_item | result(pass/fail/pending) | evidence(path\|url\|screenshot) | owner | due_date | status |
|---|---|---|---|---|---|---|---|
| IOS-SS-001 | P0 | iPhone screenshot set complete (KR+EN) | pending | `/screenshots/appstore/` and ASC captures | design-owner | TBD | open |
| IOS-SS-002 | P0 | iPad screenshot set complete and resolution-compliant | pending | screenshot inventory + dimensions report | design-owner | TBD | open |
| IOS-SS-003 | P1 | Screenshots contain no personal/sensitive data | pending | manual review checklist | design-owner | TBD | open |

## 9. Manual Scenario Evidence
| check_id | severity(P0/P1/P2) | check_item | result(pass/fail/pending) | evidence(path\|url\|screenshot) | owner | due_date | status |
|---|---|---|---|---|---|---|---|
| TC-IOS-001 | P0 | Install -> first launch -> onboarding | pending | video link | qa-owner | TBD | open |
| TC-IOS-002 | P0 | Camera/photo permission timing/copy | pending | screenshot set | qa-owner | TBD | open |
| TC-IOS-003 | P0 | IAP success reflection | pending | purchase logs | qa-owner | TBD | open |
| TC-IOS-004 | P0 | IAP cancel/error recovery | pending | error logs | qa-owner | TBD | open |
| TC-IOS-005 | P0 | Restore purchases | pending | restore logs | qa-owner | TBD | open |
| TC-IOS-006 | P0 | Universal link open behavior | pending | deep link video | qa-owner | TBD | open |
