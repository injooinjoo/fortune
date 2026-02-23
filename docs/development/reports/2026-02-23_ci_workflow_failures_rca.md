# RCA Report - CI Workflow Failures (KAN-27)

## 1. Symptom
- Error message:
  - Security Scan (KAN-26): `BASE and HEAD commits are the same. TruffleHog won't scan anything.`
  - Security Scan (KAN-27): `Failed to load config: rule |id| is missing or empty ...` (gitleaks)
  - CI Pipeline: `browserType.launch: Executable doesn't exist ... webkit-2203/pw_run.sh`
- Repro steps:
  1. Push to `master`.
  2. Observe `Security Scan` workflow failure.
  3. Observe `CI Pipeline` failure at Playwright E2E stage.
- Observed behavior:
  - TruffleHog exits early before effective diff scan (KAN-26).
  - Gitleaks exits before scan because custom rule IDs are missing, then SARIF artifact upload also fails (KAN-27).
  - Playwright E2E launches projects including WebKit, but CI installs only Chromium browser binary.
- Expected behavior:
  - Security scan should run on valid commit range and parse custom leak rules without config errors.
  - CI Playwright run should have all required browser binaries for configured projects.

## 2. WHY (Root Cause)
- Direct cause:
  - `.github/workflows/security-scan.yml` previously passed both `base` and `head` to TruffleHog in push flow (`base=master`, `head=HEAD`), which resolved to same commit in action internals.
  - `.gitleaks.toml` defines custom `[[rules]]` without required `id`, and gitleaks v8.24.3 rejects the config.
  - `.github/workflows/ci.yml` uses `npx playwright install --with-deps chromium`, but `playwright.config.js` runs `firefox`, `webkit`, and mobile projects too.
- Root cause:
  - Security tooling configuration drift:
    - over-constrained TruffleHog commit range
    - invalid custom gitleaks rule schema for current gitleaks version
  - Test tooling configuration drift: runtime Playwright matrix and installed browsers are inconsistent.
- Data/control flow:
  - Step 1: Push event triggers `CI Pipeline` and `Security Scan`.
  - Step 2: Security scan runs TruffleHog and gitleaks.
  - Step 3: TruffleHog can fail early with invalid base/head pairing; gitleaks can fail early on invalid rule schema.
  - Step 4: CI Playwright can fail when WebKit project launches without installed WebKit binary.

## 3. WHERE
- Primary location:
  - `.github/workflows/security-scan.yml:31`
  - `.github/workflows/ci.yml:80`
  - `.gitleaks.toml:14`
- Related call sites:
  - `.github/workflows/e2e-tests.yml:67` (reference: installs all browsers)
  - `playwright.config.js:58` (projects include `firefox`, `webkit`, `Mobile Safari`)

## 4. WHERE ELSE (Global Search)
- Search patterns used:
  - `rg "TruffleHog|base:|head:" .github/workflows -S`
  - `rg "^\[\[rules\]\]|^id\\s*=|UPSTASH_REDIS_REST_TOKEN|SUPABASE_SERVICE_ROLE_KEY" .gitleaks.toml -n -S`
  - `rg "playwright install|webkit|firefox" .github/workflows playwright.config.js -S`
- Findings:
  1. `.github/workflows/security-scan.yml:31` - issue (`base/head` explicit collision risk)
  2. `.github/workflows/ci.yml:80` - issue (Chromium-only install)
  3. `.gitleaks.toml:14-48` - issue (all custom rules missing mandatory `id`)
  4. `.github/workflows/e2e-tests.yml:67` - safe reference (`npx playwright install --with-deps`)
  5. `.github/workflows/qa-monitoring.yml:65` - Chromium-only install (safe for `--project=chromium` smoke scope)

## 5. HOW (Correct Pattern)
- Reference implementation:
  - `.github/workflows/e2e-tests.yml:67`
- Before:
```yaml
- name: Install Playwright Browsers
  run: npx playwright install --with-deps chromium
```
- After:
```yaml
- name: Install Playwright Browsers
  run: npx playwright install --with-deps
```
- Why this fix is correct:
  - CI Pipeline test matrix uses multiple browsers, so full browser install is required.
  - Removing explicit `base/head` lets TruffleHog action compute proper commit range by event context.
  - Adding stable `id` values to each gitleaks rule satisfies required schema and allows SARIF output generation.

## 6. Fix Plan
- Files to change:
  1. `.github/workflows/security-scan.yml` - remove `base/head` override, align analyze behavior for CI stability.
  2. `.github/workflows/ci.yml` - install all Playwright browsers required by current config.
  3. `.gitleaks.toml` - add unique `id` for each custom rule definition.
- Risk assessment:
  - Low: workflow-only change, no runtime app code behavior change.
- Validation plan:
  - Push workflow changes.
  - Check `gh run list --branch master --limit 5` for latest statuses.
  - Confirm:
    - Security Scan no longer fails with TruffleHog base/head collision or gitleaks config parse error.
    - Playwright no longer fails due missing WebKit executable.
