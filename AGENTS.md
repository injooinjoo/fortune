# Repository Guidelines

## Project Structure & Modules
- `lib/`: core, data, features, presentation, `main.dart`.
- `assets/`: images, fonts, animations (declare in `pubspec.yaml`).
- `test/`, `integration_test/`: unit/widget/integration tests.
- Platforms: `android/`, `ios/`, `web/`; config lives in each.
- `docs/`, `supabase/`, and root scripts support build and ops.

## Build, Run, and Verify
- Deps: `flutter pub get`; Analyze: `flutter analyze`; Format/Fix: `dart format .` / `dart fix --apply`.
- Dev run: `flutter run --dart-define-from-file=.env.development`.
- Clean reinstall (required before PR):
  1) `pkill -f flutter`  2) `flutter clean`  3) `flutter pub get`
  4) Uninstall simulator app: `xcrun simctl uninstall <DEVICE_ID> com.beyond.fortuneFlutter`
  5) Re-run: `flutter run -d <DEVICE_ID> --dart-define-from-file=.env.development`
- Production builds:
  - iOS: `flutter build ios --dart-define-from-file=.env.production --release`
  - Android: `flutter build appbundle --dart-define-from-file=.env.production --release`

## Coding Style & Naming
- Effective Dart; lints from `analysis_options.yaml` (`flutter_lints`).
- 2-space indent; files `snake_case.dart`; types `PascalCase`; members `lowerCamelCase`.
- Widget names end with `Screen`/`Page`/`Widget`; respect layer boundaries.

## Testing Guidelines
- Mirror `lib/` paths; name tests `*_test.dart`.
- Prefer deterministic tests; mock network/IO; cover Riverpod providers, navigation, and core fortune logic.
- CI gate: analyzer clean + tests green locally.

## App Flow Validation (must pass)
- Splash → auth check → route: unauthenticated to Landing; authenticated to onboarding or home by profile completeness.
- "오늘의 이야기가 완성되었어요!" shows only for unauthenticated users.
- Verify login (Google/Apple/Kakao/Naver), onboarding, profile management, and fortune generation display.
- After Hot Restart (`R`), initial state behaves correctly.

## Commits & Pull Requests
- Conventional Commits (`feat:`, `fix:`, `refactor:`, `chore:`…).
- PR must include summary, linked issues, test scope, and UI screenshots/GIFs.
- Pre-PR checklist: format, analyze clean, tests added/updated, full clean reinstall verified, no secrets/debug prints.

## Security & Configuration
- Never commit secrets. Use `.env.*` and pass with `--dart-define-from-file`.
- Keys required: Supabase URL/Anon, OAuth providers, Firebase messaging.
- iOS native changes: `cd ios && pod install`.
