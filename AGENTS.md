# Repository Guidelines

## Project Structure & Modules
- Source: `lib/` with `core/`, `data/`, `features/`, `presentation/`, and `main.dart`.
- Assets: `assets/` for images, fonts, animations (declare in `pubspec.yaml`).
- Tests: `test/` + `integration_test/`; mirror `lib/` paths and name `*_test.dart`.
- Platforms: `android/`, `ios/`, `web`; support in `docs/`, `supabase/`, `scripts/`.

## Setup, Build, and Run
- Deps: `flutter pub get`; iOS pods: `cd ios && pod install && cd ..`.
- Analyze/format: `flutter analyze`, `dart format .`, `dart fix --apply`.
- Run (dev): `flutter run --dart-define-from-file=.env.development`.
- Builds: iOS `flutter build ios --dart-define-from-file=.env.production --release`; Android `flutter build appbundle --dart-define-from-file=.env.production --release`.
- Clean reinstall (pre‑PR): `pkill -f flutter && flutter clean && flutter pub get`; uninstall sim: `xcrun simctl uninstall <DEVICE_ID> com.beyond.fortune`; rerun with `-d <DEVICE_ID>`.

## Coding Style & Naming
- Follow Effective Dart and `flutter_lints` (`analysis_options.yaml`).
- Indent 2 spaces. Files `snake_case.dart`; types `PascalCase`; members `lowerCamelCase`.
- Widget names end with `Screen`/`Page`/`Widget`. Respect layer boundaries.

## Testing Guidelines
- Deterministic tests; mock network/IO. Cover Riverpod providers, navigation, fortune generation.
- Run: `flutter test` (unit/widget) and `flutter test integration_test/` (integration).
- After Hot Restart (`R`), verify initial state and flows.
- Target coverage ≥80% (critical paths higher). Generate HTML via coverage tool if configured.

## App Flow Validation (must pass)
- Splash → auth check → unauthenticated → Landing; authenticated → Onboarding or Home by profile completeness.
- “오늘의 이야기가 완성되었어요!” shows only for unauthenticated users.
- Verify social login (Google/Apple/Kakao/Naver), onboarding, profile management, and fortune rendering.

## Commits, PRs, and JIRA Automation
- Commits: Conventional Commits (`feat:`, `fix:`, `refactor:`, `chore:`…).
- PRs: clear summary, linked issues, test scope, and UI screenshots/GIFs.
- JIRA link & update in one step: `./scripts/git_jira_commit.sh "message" "KAN-XX" [done|in-progress]`.
- Create UX/Design request: `./scripts/create_ux_request.sh "title" "details" "category"` (see `UX_REQUEST_GUIDE.md`).

## Security & Configuration
- Never commit secrets. Use `.env.*` and pass via `--dart-define-from-file`.
- Keys: Supabase URL/Anon, OAuth providers (Google/Apple/Kakao/Naver), Firebase Messaging. Optional: Stripe/Toss/OpenAI/Sentry as needed.
- iOS native changes require `pod install`.

## Agent‑Specific Rules (Claude Code)
- No batch modifications across files (no mass `sed/awk/regex` or multi‑file scripts). Edit one file at a time with context.
- On UX complaints/improvements, auto‑create JIRA via `./scripts/parse_ux_request.sh` and close via `./scripts/git_jira_commit.sh ... done`.
- Before PR: format, analyze clean, tests green, clean reinstall validated, and no secrets/debug prints.
