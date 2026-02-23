# RCA Report - CI Workflow Failures (KAN-27)

## 1. Symptom
- Error message:
  - Security Scan: `BASE and HEAD commits are the same. TruffleHog won't scan anything.`
  - CI Pipeline: `browserType.launch: Executable doesn't exist ... webkit-2203/pw_run.sh`
- Repro steps:
  1. Push to `master`.
  2. Observe `Security Scan` workflow failure.
  3. Observe `CI Pipeline` failure at Playwright E2E stage.
- Observed behavior:
  - TruffleHog exits early before effective diff scan.
  - Playwright E2E launches projects including WebKit, but CI installs only Chromium browser binary.
- Expected behavior:
  - Security scan should run on valid commit range without base/head collision.
  - CI Playwright run should have all required browser binaries for configured projects.

## 2. WHY (Root Cause)
- Direct cause:
  - `.github/workflows/security-scan.yml` passes both `base` and `head` to TruffleHog in push flow (`base=master`, `head=HEAD`), which resolves to same commit in action internals.
  - `.github/workflows/ci.yml` uses `npx playwright install --with-deps chromium`, but `playwright.config.js` runs `firefox`, `webkit`, and mobile projects too.
- Root cause:
  - Workflow configuration drift: runtime project matrix and browser install scope are inconsistent.
  - Security workflow uses an over-constrained TruffleHog invocation for push events.
- Data/control flow:
  - Step 1: Push event triggers `CI Pipeline` and `Security Scan`.
  - Step 2: TruffleHog resolves `BASE/HEAD` to same commit and fails fast.
  - Step 3: Playwright tries to launch WebKit project without installed WebKit binary and fails.

## 3. WHERE
- Primary location:
  - `.github/workflows/security-scan.yml:31`
  - `.github/workflows/ci.yml:80`
- Related call sites:
  - `.github/workflows/e2e-tests.yml:67` (reference: installs all browsers)
  - `playwright.config.js:58` (projects include `firefox`, `webkit`, `Mobile Safari`)

## 4. WHERE ELSE (Global Search)
- Search patterns used:
  - `rg "TruffleHog|base:|head:" .github/workflows -S`
  - `rg "playwright install|webkit|firefox" .github/workflows playwright.config.js -S`
- Findings:
  1. `.github/workflows/security-scan.yml:31` - issue (`base/head` explicit collision risk)
  2. `.github/workflows/ci.yml:80` - issue (Chromium-only install)
  3. `.github/workflows/e2e-tests.yml:67` - safe reference (`npx playwright install --with-deps`)
  4. `.github/workflows/qa-monitoring.yml:65` - Chromium-only install (safe for `--project=chromium` smoke scope)

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

## 6. Fix Plan
- Files to change:
  1. `.github/workflows/security-scan.yml` - remove `base/head` override, align analyze behavior for CI stability.
  2. `.github/workflows/ci.yml` - install all Playwright browsers required by current config.
- Risk assessment:
  - Low: workflow-only change, no runtime app code behavior change.
- Validation plan:
  - Push workflow changes.
  - Check `gh run list --branch master --limit 5` for latest statuses.
  - Confirm:
    - TruffleHog no longer fails with base/head same commit.
    - Playwright no longer fails due missing WebKit executable.
