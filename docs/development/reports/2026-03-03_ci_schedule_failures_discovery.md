# Discovery Report - Scheduled Workflow Failures Stabilization (KAN-38)

## 1. Goal
- Requested change:
  - Fix recurring schedule workflow failures (`zodiac`, `security-scan`, `dependency-update`) without weakening security policy.
- Work type: CI Workflow / Security Rule / Operational Guardrails
- Scope:
  - `.github/workflows/zodiac-fortune-generator.yml`
  - `.github/workflows/dependency-update.yml`
  - `.github/workflows/security-scan.yml`
  - `.gitleaks.toml`

## 2. Search Strategy
- Keywords:
  - `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `trufflehog`, `flutter: command not found`, `create or approve pull requests`, `workflow permissions`
- Commands:
  - `gh run list --limit 30 --json ...`
  - `gh run view 22546095206 --log-failed`
  - `gh run view 22582481972 --log-failed`
  - `gh run view 22559510498 --log`
  - `gh run view 22606245144 --log`
  - `gh run view 22569486418 --log`
  - `sed -n '1,260p' .github/workflows/zodiac-fortune-generator.yml`
  - `sed -n '1,260p' .github/workflows/security-scan.yml`
  - `sed -n '1,260p' .github/workflows/dependency-update.yml`
  - `gh secret list --repo injooinjoo/fortune`
  - `gh api repos/injooinjoo/fortune/actions/permissions/workflow`

## 3. Similar Code Findings
- Reusable:
  1. `.github/workflows/qa-monitoring.yml` - missing `SUPABASE_URL` 시 warning + skip 처리 패턴.
  2. `.github/workflows/security-scan.yml` - strict 실패 흐름 유지 구조(`notify-slack`, `security-report`).
- Reference only:
  1. `docs/development/reports/2026-02-23_ci_workflow_failures_rca.md` - 과거 보안 워크플로우 RCA 문맥.
  2. `docs/development/reports/2026-02-23_ci_workflow_failures_verify.md` - CI 안정화 검증 포맷.

## 4. Reuse Decision
- Reuse as-is:
  - `qa-monitoring`의 preflight + summary 패턴을 `zodiac` 워크플로우에 동일 개념으로 적용.
- Extend existing code:
  - `security-scan`의 TruffleHog/Gitleaks 실행은 유지하고, 실패 시 조치 가이드 summary를 추가.
  - `dependency-update`는 기존 잡 구조를 유지하며 권한 체크 분기와 Flutter setup을 보강.
- New code required:
  - PR 생성 권한 사전 체크 스텝.
  - Postgres/Supabase DSN credential 탐지용 gitleaks 룰.
- Duplicate prevention notes:
  - 신규 워크플로우 생성 없이 기존 워크플로우 3개만 최소 수정.

## 5. Planned Changes
- Files to edit:
  1. `.github/workflows/zodiac-fortune-generator.yml`
  2. `.github/workflows/dependency-update.yml`
  3. `.github/workflows/security-scan.yml`
  4. `.gitleaks.toml`
- Files to create:
  1. `docs/development/reports/2026-03-03_ci_schedule_failures_discovery.md`
  2. `docs/development/reports/2026-03-03_ci_schedule_failures_rca.md`
  3. `docs/development/reports/2026-03-03_ci_schedule_failures_verify.md`

## 6. Validation Plan
- Static checks:
  - `flutter analyze`
  - `dart format --set-exit-if-changed .`
- Runtime checks:
  - `gh run list --branch master --limit 5`
  - `gh workflow run zodiac-fortune-generator.yml`
  - `gh workflow run dependency-update.yml`
  - `gh workflow run security-scan.yml`
- Test cases:
  1. Zodiac: secret 누락 시 성공+skip, 설정 시 실제 생성 실행.
  2. Dependency: `security-audit`에서 Flutter 명령 정상 동작.
  3. Dependency: PR 권한 비활성 시 실패 대신 skip summary.
  4. Security Scan: 탐지 시 strict fail 유지 + remediation summary 출력.
