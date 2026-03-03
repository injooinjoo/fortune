# RCA Report - Scheduled Workflow Failures (KAN-38)

## 1. Symptom
- Error message:
  - Zodiac (`#227`, `#228`): `curl: (3) URL rejected: No host part in the URL`
  - Security Scan (`#245`, `#246`): `Found verified GoogleGeminiAPIKey result`, `exit code 183`
  - Dependency Update (`#33`):
    - `security-audit`: `flutter: command not found`
    - `update-dependencies`: `GitHub Actions is not permitted to create or approve pull requests.`
- Repro steps:
  1. Trigger scheduled workflows on `master` (`671d2dc`).
  2. Observe recurring failures in the same jobs.
- Observed behavior:
  - 환경 미설정/권한 제한이 기능 실패로 누적되고 Slack 실패 알림이 반복 발생.
- Expected behavior:
  - 설정 누락은 명확한 경고와 함께 안전하게 skip.
  - 보안 탐지는 strict 실패를 유지하되 대응 지침이 요약으로 제공.
  - 의존성 감사 잡은 Flutter 런타임 누락 없이 동작.

## 2. WHY (Root Cause)
- Direct cause:
  1. Zodiac workflow가 필수 secret 존재 여부를 사전 검증하지 않고 curl 호출.
  2. Secret scan은 유효한 민감정보 탐지를 정상적으로 실패 처리하지만, 운영 대응 가이드가 누락.
  3. Dependency workflow의 `security-audit` job에는 Flutter setup이 없음.
  4. Repository setting에서 Actions PR 생성/승인 기능이 비활성 상태인데 workflow가 무조건 PR 생성 시도.
- Root cause:
  - 운영 설정 의존성(secret/repo permission)을 workflow 레벨에서 사전 검증하지 않은 설계.
  - 보안 strict 정책은 맞지만, 실패 시 운영자가 즉시 따라야 할 조치 문서화가 부족.
- Data/control flow:
  - Step 1: Schedule trigger starts workflow.
  - Step 2: Missing config or restricted permission path entered.
  - Step 3: Guardrail 미부재로 hard failure 발생.
  - Step 4: Slack alarm repeats without actionable in-run guidance.

## 3. WHERE
- Primary location:
  - `.github/workflows/zodiac-fortune-generator.yml:27-73`
  - `.github/workflows/security-scan.yml:27-36`
  - `.github/workflows/dependency-update.yml:42-79`
- Related call sites:
  - `.github/workflows/qa-monitoring.yml:262-268` (skip-with-warning reference pattern)
  - `.gitleaks.toml` (secret pattern coverage)

## 4. WHERE ELSE (Global Search)
- Search patterns used:
  - `rg -n "SUPABASE_URL|SUPABASE_SERVICE_ROLE_KEY" .github/workflows`
  - `rg -n "trufflehog|gitleaks" .github/workflows/security-scan.yml`
  - `rg -n "create-pull-request|flutter pub outdated|flutter-action" .github/workflows/dependency-update.yml`
  - `gh secret list --repo injooinjoo/fortune`
  - `gh api repos/injooinjoo/fortune/actions/permissions/workflow`
- Findings:
  1. `.github/workflows/zodiac-fortune-generator.yml` - missing preflight check (issue)
  2. `.github/workflows/dependency-update.yml` - no Flutter setup in `security-audit` (issue)
  3. `.github/workflows/dependency-update.yml` - unconditional PR create step (issue)
  4. `.github/workflows/security-scan.yml` - strict fail exists but no remediation summary (improvement needed)
  5. `.github/workflows/qa-monitoring.yml` - valid skip+warning pattern (safe reference)

## 5. HOW (Correct Pattern)
- Reference implementation:
  - `.github/workflows/qa-monitoring.yml:262-268`
- Before:
```yaml
- name: Generate Zodiac Age Fortunes
  env:
    SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
    SUPABASE_SERVICE_ROLE_KEY: ${{ secrets.SUPABASE_SERVICE_ROLE_KEY }}
  run: curl ...
```
- After:
```yaml
- name: Preflight required secrets
  id: preflight
  run: |
    # missing secret -> summary + skip
    echo "has_secrets=false" >> "$GITHUB_OUTPUT"

- name: Generate Zodiac Age Fortunes
  if: steps.preflight.outputs.has_secrets == 'true'
  run: curl ...
```
- Why this fix is correct:
  - 설정 의존성이 없는 경로는 명시적으로 skip 처리하여 alert noise를 줄이고,
    실제 실행 가능 조건에서만 실패를 의미 있게 유지한다.
  - 보안 스캔은 strict 실패를 유지하면서 대응 단계를 run summary에 강제 제공해 운영 반응 속도를 높인다.

## 6. Fix Plan
- Files to change:
  1. `.github/workflows/zodiac-fortune-generator.yml` - preflight secret guard + conditional failure issue creation.
  2. `.github/workflows/dependency-update.yml` - Flutter setup in `security-audit`, PR permission guard in `update-dependencies`.
  3. `.github/workflows/security-scan.yml` - remediation summary steps + strict enforcement step.
  4. `.gitleaks.toml` - Postgres/Supabase DSN-with-credentials rule.
- Risk assessment:
  - Medium-low: workflow behavior changes only, application runtime code is untouched.
  - Remaining risk: leaked key material in historical commits remains until external rotation/hardening is completed.
- Validation plan:
  - `flutter analyze`
  - `dart format --set-exit-if-changed .`
  - Push 후 `gh run list --branch master --limit 5` 확인.
