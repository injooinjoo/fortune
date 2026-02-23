# Discovery Report - CI Workflow Stabilization (KAN-27)

## 1. Goal
- Requested change:
  - Fix workflow failures and make Actions green for Security Scan and CI Playwright path.
- Work type: CI Workflow / QA Pipeline
- Scope:
  - `.github/workflows/security-scan.yml`
  - `.github/workflows/ci.yml`
  - `.gitleaks.toml`

## 2. Search Strategy
- Keywords:
  - `TruffleHog`, `base`, `head`, `playwright install`, `webkit`, `firefox`, `gitleaks`, `id`
- Commands:
  - `rg "TruffleHog|base:|head:" .github/workflows -S`
  - `rg "playwright install|webkit|firefox" .github/workflows playwright.config.js -S`
  - `rg "^\[\[rules\]\]|^id\\s*=|UPSTASH_REDIS_REST_TOKEN|SUPABASE_SERVICE_ROLE_KEY" .gitleaks.toml -n -S`
  - `sed -n '1,260p' .github/workflows/ci.yml`
  - `sed -n '1,260p' .github/workflows/security-scan.yml`
  - `sed -n '1,200p' .gitleaks.toml`
  - `sed -n '1,260p' playwright.config.js`

## 3. Similar Code Findings
- Reusable:
  1. `.github/workflows/e2e-tests.yml` - Playwright full browser install pattern (`npx playwright install --with-deps`)
  2. gitleaks v8 schema requirement - each custom `[[rules]]` block should provide explicit `id`.
- Reference only:
  1. `.github/workflows/qa-monitoring.yml` - Chromium-only install (project scope is chromium smoke, not full matrix)
  2. `playwright.config.js` - canonical browser matrix (chromium/firefox/webkit/mobile)

## 4. Reuse Decision
- Reuse as-is:
  - Use `e2e-tests.yml` browser install pattern in `ci.yml`.
- Extend existing code:
  - Adjust `security-scan.yml` TruffleHog config to rely on action defaults instead of explicit base/head override.
  - Align Security workflow analyze step with CI behavior to avoid non-security lint/info noise as hard failure.
  - Add explicit `id` for all custom gitleaks rules while preserving existing regex patterns.
- New code required:
  - None (workflow patch only).
- Duplicate prevention notes:
  - Keep Playwright install command consistent between CI jobs that run full browser matrix.

## 5. Planned Changes
- Files to edit:
  1. `.github/workflows/ci.yml`
  2. `.github/workflows/security-scan.yml`
  3. `.gitleaks.toml`
- Files to create:
  1. `docs/development/reports/2026-02-23_ci_workflow_failures_rca.md`
  2. `docs/development/reports/2026-02-23_ci_workflow_failures_discovery.md`

## 6. Validation Plan
- Static checks:
  - YAML syntax sanity via `git diff` and workflow run results.
- Runtime checks:
  - Push and inspect new runs via `gh run list --branch master --limit 5`.
- Test cases:
  1. Security Scan no longer fails with `BASE and HEAD commits are the same`.
  2. Security Scan no longer fails with `rule |id| is missing or empty`.
  3. CI Pipeline Playwright stage no longer fails from missing WebKit executable.
