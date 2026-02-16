# Android Review Evidence (Google Play)

## 1. Scope
- Platform: Android (Google Play Console)
- Locale: KR + EN
- Gate policy: `P0=0`, `P1=0` required for production submission

## 2. Manifest Permission Minimality and Runtime Mapping
| check_id | severity(P0/P1/P2) | check_item | result(pass/fail/pending) | evidence(path\|url\|screenshot) | owner | due_date | status |
|---|---|---|---|---|---|---|---|
| AND-PERM-001 | P0 | Billing permission declared and purchase feature mapped | pass | `android/app/src/main/AndroidManifest.xml` (`com.android.vending.BILLING`), `lib/services/in_app_purchase_service.dart` | android-owner | 2026-02-16 | done |
| AND-PERM-002 | P1 | Notification permission declared with runtime request behavior validated | pending | `android/app/src/main/AndroidManifest.xml` (`POST_NOTIFICATIONS`), runtime evidence | android-owner | TBD | open |
| AND-PERM-003 | P1 | Storage/media permission footprint is minimal and justified | pending | `android/app/src/main/AndroidManifest.xml` (`READ_MEDIA_IMAGES`, legacy storage perms), `lib/services/talisman_share_service.dart` | android-owner | TBD | open |
| AND-PERM-004 | P0 | Audio permission is justified by speech feature and runtime handling | pass | `android/app/src/main/AndroidManifest.xml` (`RECORD_AUDIO`), `lib/services/speech_recognition_service.dart` | android-owner | 2026-02-16 | done |
| AND-PERM-005 | P1 | Calendar permissions are justified and user-facing flow is clear | pending | `android/app/src/main/AndroidManifest.xml` (`READ_CALENDAR`, `WRITE_CALENDAR`), `lib/core/services/device_calendar_service.dart` | android-owner | TBD | open |
| AND-PERM-006 | P1 | Location permissions are minimally scoped for real feature needs | pending | `android/app/src/main/AndroidManifest.xml` (`ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`), `lib/core/services/location_manager.dart` | android-owner | TBD | open |

## 3. Data Safety and Policy Form Parity
| check_id | severity(P0/P1/P2) | check_item | result(pass/fail/pending) | evidence(path\|url\|screenshot) | owner | due_date | status |
|---|---|---|---|---|---|---|---|
| AND-DATA-001 | P0 | Data Safety form is completed in Play Console | pending | Play Console screenshots | privacy-owner | TBD | open |
| AND-DATA-002 | P1 | Data collection types in form match actual SDK/code behavior | pending | code map (`lib/services/analytics_service.dart`, auth/payment/location features) + form capture | privacy-owner | TBD | open |
| AND-DATA-003 | P1 | Ad/Tracking declarations match actual ad SDK integration state | pending | dependency audit + Play Console app content form | privacy-owner | TBD | open |

## 4. App Links and Domain Verification
| check_id | severity(P0/P1/P2) | check_item | result(pass/fail/pending) | evidence(path\|url\|screenshot) | owner | due_date | status |
|---|---|---|---|---|---|---|---|
| AND-LINK-001 | P0 | Manifest intent filter has `autoVerify=true` for official domains | pass | `android/app/src/main/AndroidManifest.xml` (https hosts `zpzg.co.kr`, `www.zpzg.co.kr`) | android-owner | 2026-02-16 | done |
| AND-LINK-002 | P0 | `assetlinks.json` is reachable and JSON on apex domain | pass | `https://zpzg.co.kr/.well-known/assetlinks.json` | web-owner | 2026-02-16 | done |
| AND-LINK-003 | P0 | `assetlinks.json` package and SHA-256 match release signing | pass | URL payload (`com.beyond.fortune`, SHA fingerprint) | web-owner | 2026-02-16 | done |
| AND-LINK-004 | P0 | Device-level App Links open app directly | pending | adb verification + on-device capture | qa-owner | TBD | open |

## 5. Purchase Verification Correctness
| check_id | severity(P0/P1/P2) | check_item | result(pass/fail/pending) | evidence(path\|url\|screenshot) | owner | due_date | status |
|---|---|---|---|---|---|---|---|
| AND-IAP-001 | P0 | Purchase success/cancel/restore user flows verified on Android | pending | UI recording + billing logs | qa-owner | TBD | open |
| AND-IAP-002 | P1 | Server-side Google Play purchase token verification implemented | pass | `supabase/functions/payment-verify-purchase/index.ts` (Google OAuth JWT + Android Publisher API products/subscriptions verification), `docs/development/reports/2026-02-16_store_review_gate_blockers_verify.md` | backend-owner | 2026-02-16 | done |
| AND-IAP-003 | P1 | Play subscription status reflected correctly after backend activation | pending | subscription logs + DB snapshot | backend-owner | TBD | open |

## 6. Stability Risk (ANR/Crash) and Build Evidence
| check_id | severity(P0/P1/P2) | check_item | result(pass/fail/pending) | evidence(path\|url\|screenshot) | owner | due_date | status |
|---|---|---|---|---|---|---|---|
| AND-STAB-001 | P0 | Release AAB build succeeds | pass | `docs/development/reports/2026-02-16_store_review_gate_blockers_verify.md` | android-owner | 2026-02-16 | done |
| AND-STAB-002 | P0 | Release lint passes (`lintRelease`) | pass | `docs/development/reports/2026-02-16_store_review_gate_blockers_verify.md` | android-owner | 2026-02-16 | done |
| AND-STAB-003 | P1 | Core scenario run shows no blocker-level crashes/ANR | pending | real-device run logs | qa-owner | TBD | open |

## 7. Policy-Sensitive Store Text Review
| check_id | severity(P0/P1/P2) | check_item | result(pass/fail/pending) | evidence(path\|url\|screenshot) | owner | due_date | status |
|---|---|---|---|---|---|---|---|
| AND-COPY-001 | P1 | KR/EN short/full descriptions avoid misleading or exaggerated claims | pending | `android/fastlane/metadata/android/ko-KR/full_description.txt`, `android/fastlane/metadata/android/en-US/full_description.txt` | content-owner | TBD | open |
| AND-COPY-002 | P1 | Content rating and app content forms are consistent with app behavior | pending | Play Console app content screenshots | release-owner | TBD | open |

## 8. Manual Scenario Evidence
| check_id | severity(P0/P1/P2) | check_item | result(pass/fail/pending) | evidence(path\|url\|screenshot) | owner | due_date | status |
|---|---|---|---|---|---|---|---|
| TC-AND-001 | P0 | AAB build/install/run | pending | build + install capture | qa-owner | TBD | open |
| TC-AND-002 | P0 | Runtime permission grant/deny/re-request | pending | permission captures | qa-owner | TBD | open |
| TC-AND-003 | P1 | Purchase success/cancel/restore | pending | billing logs + videos | qa-owner | TBD | open |
| TC-AND-004 | P0 | App Links autoVerify and deep link open | pending | adb + video evidence | qa-owner | TBD | open |
