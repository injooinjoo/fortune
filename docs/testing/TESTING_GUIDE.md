# Ondo 테스트 가이드

## 개요

온도 앱은 RN 우선 검증 + 레거시 Flutter 검증 전략을 함께 사용합니다:

| 종류 | 용도 | 실행 방법 |
|------|------|-----------|
| **RN Verify** | RN 앱/공용 TypeScript workspace 기본 검증 | `npm run rn:verify` |
| **RN Verify + Smoke** | RN 기본 검증 + 웹 smoke 게이트 | `./scripts/verify_rn.sh --smoke` |
| **Flutter Legacy** | 기존 Flutter surface 유지보수 검증 | `flutter analyze`, `flutter test`, `./scripts/run_all_tests.sh` |

기존 Flutter 테스트 분류는 아래와 같습니다:

| 종류 | 용도 | 위치 | 실행 방법 |
|------|------|------|-----------|
| **Unit Test** | 비즈니스 로직 | `test/unit/` | `flutter test test/unit/` |
| **Widget Test** | UI 컴포넌트 | `test/widget/` | `flutter test test/widget/` |
| **Integration Test** | 전체 앱 E2E | `integration_test/` | `flutter test integration_test/` |

## 빠른 시작

### 전체 테스트 실행
```bash
npm run rn:verify
```

### 개별 실행
```bash
./scripts/verify_rn.sh --smoke        # RN 기본 검증 + Playwright smoke
./scripts/verify_rn.sh --e2e          # RN 기본 검증 + Playwright E2E
./scripts/run_all_tests.sh --unit       # Unit만
./scripts/run_all_tests.sh --widget     # Widget만
./scripts/run_all_tests.sh --integration # E2E (디바이스 필요)
./scripts/run_all_tests.sh --ci         # CI 환경
./scripts/run_all_tests.sh --coverage   # 커버리지
```

## 자동 테스트 (GitHub Actions)

- `Flutter CI/CD`
  - 대상: `main/master/develop` 대상 PR, 해당 브랜치 push, 수동 실행
  - 범위: `dart format --set-exit-if-changed .`, `flutter analyze --no-fatal-infos --no-fatal-warnings`, `flutter test --coverage`
- 로컬 기본 검증
  - RN/TypeScript 변경: `npm run rn:verify`
  - Flutter/Dart 변경: `flutter analyze`, `dart format --set-exit-if-changed .`, `flutter test`
- `E2E Tests`
  - 대상: `main/master/develop` 대상 PR, 해당 브랜치 push, 수동 실행
  - 기본 범위: Playwright smoke 게이트(`npm run test:smoke:ci`)
  - 수동 확장: `workflow_dispatch`에서 `all`, `comprehensive` 선택 가능
- `CI Pipeline`
  - 대상: `main/master/develop` 대상 PR, 해당 브랜치 push
  - 범위: source inventory drift, Paper 디자인 계약 drift

로컬 명령은 참고용이며 자동 게이트의 source of truth는 GitHub Actions workflow 설정입니다.

## 테스트 구조

```
test/
├── unit/                    # Unit Tests
│   ├── providers/           # Provider 테스트
│   └── services/            # Service 테스트
├── widget/                  # Widget Tests
│   ├── blur/
│   └── pages/
├── helpers/                 # 테스트 헬퍼
└── mocks/                   # Mock 클래스

integration_test/
├── app_test.dart           # 앱 시작 테스트
└── fortune_flow_test.dart  # 운세 플로우 E2E
```

## 자세한 내용

- Unit Test: Provider 상태, Service 로직 테스트
- Widget Test: UI 컴포넌트 렌더링 및 인터랙션 테스트
- Integration Test: 실제 디바이스에서 전체 플로우 테스트
- Playwright Smoke: 인증 우회 후 핵심 채팅 표면 진입과 세션 유지 검증
