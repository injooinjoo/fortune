# iOS/Android Launch Readiness Audit

Date: 2026-02-14  
Auditor: Codex

## Scope
- Platform buildability (Android/iOS release)
- Static analysis and unit test health
- Store-policy time-bound checks
- Deep link / universal link readiness
- Release config consistency (versioning, env, signing)

## Commands Executed
- `flutter analyze`
- `dart format --set-exit-if-changed .`
- `./scripts/run_all_tests.sh --unit`
- `flutter build appbundle --release --dart-define-from-file=.env.production`
- `flutter build ios --release --no-codesign --dart-define-from-file=.env.production`
- `flutter build ipa --release --no-codesign --dart-define-from-file=.env.production`
- `cd android && ./gradlew :app:lintRelease`
- `curl -sSL -D - https://zpzg.co.kr/.well-known/apple-app-site-association`
- `curl -sSL -D - https://zpzg.co.kr/.well-known/assetlinks.json`

## Follow-up Update (2026-02-14)
- iOS build/version alignment fixed:
  - `ios/Runner/Info.plist` now uses `$(FLUTTER_BUILD_NUMBER)`.
  - `ios/Runner.xcodeproj/project.pbxproj` synced to `CURRENT_PROJECT_VERSION = 55` and `MARKETING_VERSION = 1.0.4` where previously hardcoded to 52/1.0.0.
  - Rebuilt iOS release app confirms:
    - `CFBundleShortVersionString = 1.0.4`
    - `CFBundleVersion = 55`
- Android lint pipeline fixed to run end-to-end in current environment:
  - Local `audioplayers_android` fork removes legacy `android-junit5` plugin incompatibility.
  - `android/gradle.properties` sets `android.enableJetifier=false` to avoid Java 24 classfile transform failures during lint unit-test model generation.
  - `android/gradlew` auto-falls back to Android Studio JBR on macOS when Java 24+ is detected.
  - `./gradlew :app:lintRelease -q` now exits success.
- Android manifest/resource lint errors fixed:
  - removed invalid `autoVerify` on custom-scheme Supabase deep link intent filter.
  - removed obsolete `WorkManagerInitializer` provider removal block.
  - added `tools:targetApi` on API-gated style attributes in `values/` and `values-night/`.
- Deep-link domain assets prepared for ops deployment:
  - `docs/deployment/well-known/apple-app-site-association`
  - `docs/deployment/well-known/assetlinks.json`
  - `docs/deployment/WELL_KNOWN_DEPLOYMENT_CHECKLIST.md`
  - `scripts/verify_deep_links.sh`

## Passed Checks
- Android release bundle build succeeded:
  - `build/app/outputs/bundle/release/app-release.aab`
- iOS release app build succeeded (`--no-codesign`):
  - `build/ios/iphoneos/Runner.app`
- iOS archive build succeeded (`--no-codesign`):
  - `build/ios/archive/Runner.xcarchive`
- Unit tests passed:
  - `./scripts/run_all_tests.sh --unit` (all green)
- Format check passed:
  - `dart format --set-exit-if-changed .` (0 changed)

## Findings

### P0 (Launch Blockers)
1. Android App Links verification file has placeholder SHA256.
   - Evidence: live `https://zpzg.co.kr/.well-known/assetlinks.json` contains:
     - `"sha256_cert_fingerprints": ["TODO_REPLACE_WITH_YOUR_SHA256_FINGERPRINT"]`
   - Impact:
     - App Links auto-verify can fail in production.
     - OAuth/deep-link flows can open browser instead of app.
   - Required action:
     - Replace with actual Play App Signing SHA-256 (and upload key SHA-256 if needed).

2. Deep-link association endpoints return redirect (307) on root domain.
   - Evidence:
     - `https://zpzg.co.kr/.well-known/apple-app-site-association` -> 307 -> `https://www.zpzg.co.kr/...`
     - `https://zpzg.co.kr/.well-known/assetlinks.json` -> 307 -> `https://www.zpzg.co.kr/...`
   - Impact:
     - Association verification may fail on iOS/Android because no-redirect access is required.
   - Required action:
     - Serve both files directly on `https://zpzg.co.kr/.well-known/...` with HTTP 200.
     - Ensure `Content-Type: application/json`.

### P1 (High Priority)
1. iOS build number is out of sync with Flutter build number.
   - Evidence:
     - `/Users/jacobmac/Desktop/Dev/fortune/pubspec.yaml:19` -> `version: 1.0.4+55`
     - Built iOS app -> `CFBundleVersion = 52`
     - `/Users/jacobmac/Desktop/Dev/fortune/ios/Runner/Info.plist:63` hardcodes `52`
     - `/Users/jacobmac/Desktop/Dev/fortune/ios/Runner.xcodeproj/project.pbxproj` has `CURRENT_PROJECT_VERSION = 52`
   - Impact:
     - App Store submission can be blocked if build number is not monotonic or expected release number mismatches.
   - Required action:
     - Unify iOS build number with release pipeline strategy (prefer `$(FLUTTER_BUILD_NUMBER)` or single source of truth).

2. Production env source-of-truth is ambiguous and currently runtime depends on `.env`.
   - Evidence:
     - `/Users/jacobmac/Desktop/Dev/fortune/lib/main.dart:55` loads `.env` in normal mode.
     - `/Users/jacobmac/Desktop/Dev/fortune/lib/core/config/environment.dart` also defaults to `.env`.
     - Local `.env.production` currently contains placeholders (`your-prod-*` values).
   - Impact:
     - Release may build but fail at runtime if `.env` is not production-resolved at build/package stage.
   - Required action:
     - Define one release env contract:
       - CI injects real `.env` at build time, or
       - switch codepath to explicit production file/defines for release.

### P2 (Medium Priority)
1. Android lint pipeline is currently broken on release lint task.
   - Evidence:
     - `./gradlew :app:lintRelease` fails at `:audioplayers_android:testDebugUnitTest` task creation (`Type T not present`).
   - Impact:
     - CI quality gate for Android release lint is unreliable.
   - Suggested action:
     - Pin/align AGP + plugin versions and rerun lint.

2. Policy deadline risk: target API needs planned upgrade timeline.
   - Current config:
     - `/Users/jacobmac/Desktop/Dev/fortune/android/app/build.gradle` -> `targetSdk = 35`
   - Policy context (official docs):
     - Since 2025-08-31, new apps/updates need API 35+.
     - Google notes API 36 requirement timing for 2026 store windows.
   - Suggested action:
     - Schedule API 36 target migration and regression window before 2026-08.

3. iOS age-rating questionnaire update deadline has passed window.
   - Policy context (official docs):
     - Updated age rating responses required by 2026-01-31 to avoid update interruption.
   - Suggested action:
     - Confirm App Store Connect age-rating questionnaire has been re-submitted.

## Static Analysis Summary
- `flutter analyze` found warnings/info and no blocking compile errors in this run.
- Notable non-blocking items:
  - Deprecated API usages
  - async context warnings
  - unused elements

## Recommended Launch Checklist (Immediate)
1. Fix domain association files:
   - no redirect on root domain
   - valid SHA256 in `assetlinks.json`
2. Normalize iOS build/version strategy:
   - synchronize build number with release numbering
3. Lock production env loading strategy:
   - ensure runtime uses production values deterministically
4. Repair Android lint pipeline:
   - make `:app:lintRelease` green for CI gate
5. Confirm console-side compliance:
   - App Store Connect age rating questionnaire
   - Play Console deep link verification status

## Policy References
- Google Play target API requirement:
  - https://developer.android.com/google/play/requirements/target-sdk
- Android App Links assetlinks rules (no redirects):
  - https://developer.android.com/training/app-links/configure-assetlinks
  - https://developer.android.com/training/app-links/troubleshoot
- Apple upcoming requirements:
  - https://developer.apple.com/news/upcoming-requirements/
- Apple Universal Links association file rules:
  - https://developer.apple.com/library/archive/documentation/General/Conceptual/AppSearch/UniversalLinks.html
  - https://developer-rno.apple.com/library/archive/qa/qa1916/_index.html
