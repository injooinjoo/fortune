# Repository Guidelines

## Project Structure & Modules
- `lib/` app code: `core/`, `data/`, `features/` (fortune, auth, profile, payment), `presentation/`, `main.dart`.
- Tests: `test/` (unit, widget), `integration_test/` (device E2E).
- Web/E2E: `playwright/` with `package.json` test scripts.
- Platforms: `android/`, `ios/`, `macos/`, `web/`; assets in `assets/`.
- Tools & docs: `scripts/` helpers, `docs/` index (see `docs/README.md`), `.claude/` patterns for UI/state/LLM.

## Build, Test, and Dev Commands
- Setup: `flutter pub get`; analyze: `flutter analyze`; format: `dart format .`.
- Run dev: `flutter run --dart-define-from-file=.env.development`.
- Build: iOS `flutter build ios ... --release`; Android `flutter build appbundle ... --release`.
- Tests: `./scripts/run_all_tests.sh [--unit|--widget|--integration|--coverage]` or `flutter test`.
- Playwright E2E: `npm run test:install` then `npm run test:e2e` (report: `npm run test:report`).

## Coding Style & Naming
- Follow Effective Dart + `flutter_lints` (`analysis_options.yaml`): single quotes, prefer `const`, final locals, no `print` (use logger), annotate overrides.
- Names: files `snake_case.dart`, classes/widgets `PascalCase`, providers `...Provider`.
- Patterns (see CLAUDE.md): Riverpod `StateNotifier` (avoid `@riverpod` macro), use context typography (not raw Toss tokens), use `UnifiedBlurWrapper` instead of direct `ImageFilter.blur`.

## Testing Guidelines
- Place tests as `*_test.dart` in `test/` and flows in `integration_test/`.
- Keep coverage meaningful on touched code; add regression tests for fixed bugs.
- For E2E UI changes, add/adjust Playwright specs under `playwright/tests/`.

## Commit & PR Guidelines
- Conventional Commits (`feat:`, `fix:`, `refactor:`, `chore:`, `improve:`). Link JIRA when applicable.
- Optional JIRA automation: `./scripts/git_jira_commit.sh "msg" "KAN-123" [done|in-progress]` (see `docs/development/GIT_JIRA_WORKFLOW.md`).
- Before PR: run analyze, format, unit/widget/integration as applicable; include description, linked issue, and screenshots for UI changes.

## Security & Config
- Never commit secrets. Use `--dart-define-from-file` with `.env.development`/`.env.production` (keys for Supabase/OAuth/Firebase; see README).
- Optional secret scan: project includes `.gitleaks.toml`.

## Agent-Specific (Codex CLI)
- Use `apply_patch` for edits and keep diffs focused; avoid bulk destructive changes.
- Prefer `rg` for search; read large files in chunks; add brief preambles and maintain a lightweight plan via `update_plan`.
- Do not run networked or privileged commands; avoid `git commit`/branching unless requested.
- Validate by running targeted tests/scripts only when appropriate for the task.
