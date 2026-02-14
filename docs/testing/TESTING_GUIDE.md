# ZPZG 테스트 가이드

## 개요

Fortune 앱은 3단계 테스트 전략을 사용합니다:

| 종류 | 용도 | 위치 | 실행 방법 |
|------|------|------|-----------|
| **Unit Test** | 비즈니스 로직 | `test/unit/` | `flutter test test/unit/` |
| **Widget Test** | UI 컴포넌트 | `test/widget/` | `flutter test test/widget/` |
| **Integration Test** | 전체 앱 E2E | `integration_test/` | `flutter test integration_test/` |

## 빠른 시작

### 전체 테스트 실행
```bash
./scripts/run_all_tests.sh
```

### 개별 실행
```bash
./scripts/run_all_tests.sh --unit       # Unit만
./scripts/run_all_tests.sh --widget     # Widget만
./scripts/run_all_tests.sh --integration # E2E (디바이스 필요)
./scripts/run_all_tests.sh --ci         # CI 환경
./scripts/run_all_tests.sh --coverage   # 커버리지
```

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
