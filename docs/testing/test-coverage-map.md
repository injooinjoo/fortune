# Feature to Test Coverage Map

> 최종 업데이트: 2025-02-13

## Overview

| Feature | 테스트 파일 수 | 커버리지 | 우선순위 | 상태 |
|---------|-------------|---------|---------|------|
| **Fortune (인사이트)** | 15 | High | P0 | ✅ 양호 |
| **Auth** | 3 | Medium | P0 | ✅ 양호 |
| **Chat** | 0 | None | P1 | ❌ 테스트 필요 |
| **Premium/Payment** | 3 | Medium | P0 | ⚠️ 부분적 |
| **Profile** | 3 | Medium | P1 | ⚠️ 부분적 |
| **Character** | 0 | None | P2 | ❌ 테스트 필요 |
| **Wellness** | 0 | None | P2 | ❌ 테스트 필요 |
| **Settings** | 2 | Low | P2 | ⚠️ 부분적 |
| **Interactive** | 3 | Medium | P1 | ✅ 양호 |
| **Trend** | 1 | Low | P2 | ⚠️ 부분적 |

---

## 테스트 피라미드

```
                    /\
                   /  \
                  / E2E \        ← ~10% (integration_test/, playwright/)
                 /--------\
                /Integration\    ← ~20% (Playwright smoke tests)
               /--------------\
              /    Widget      \  ← ~30% (test/widget/)
             /------------------\
            /       Unit         \ ← ~40% (test/unit/)
           ----------------------
```

---

## Detailed Mapping

### Fortune Feature (`lib/features/fortune/`)

| Source File | Test File | Test Type | Priority |
|-------------|-----------|-----------|----------|
| pages/daily_fortune_page.dart | test/widget/fortune/daily_fortune_test.dart | Widget | P0 |
| pages/love_fortune_page.dart | test/widget/fortune/love_fortune_test.dart | Widget | P0 |
| pages/compatibility_page.dart | test/widget/fortune/compatibility_test.dart | Widget | P0 |
| pages/tarot_page.dart | test/widget/pages/tarot_page_test.dart | Widget | P1 |
| pages/mbti_fortune_page.dart | test/widget/fortune/mbti_fortune_test.dart | Widget | P1 |
| pages/dream_fortune_page.dart | test/widget/fortune/dream_fortune_test.dart | Widget | P1 |
| pages/biorhythm_page.dart | test/widget/fortune/biorhythm_test.dart | Widget | P2 |
| pages/investment_page.dart | test/widget/fortune/investment_test.dart | Widget | P2 |
| pages/career_coaching_page.dart | test/widget/fortune/career_coaching_test.dart | Widget | P1 |
| pages/celebrity_page.dart | test/widget/fortune/celebrity_test.dart | Widget | P2 |
| pages/face_reading_page.dart | test/widget/fortune/face_reading_test.dart | Widget | P1 |
| pages/traditional_saju_page.dart | test/widget/fortune/traditional_saju_test.dart | Widget | P0 |
| providers/fortune_provider.dart | test/unit/providers/fortune_provider_test.dart | Unit | P0 |
| services/unified_fortune_service.dart | test/unit/services/unified_fortune_service_test.dart | Unit | P0 |

### Auth Feature (`lib/core/auth/`)

| Source File | Test File | Test Type | Priority |
|-------------|-----------|-----------|----------|
| providers/auth_provider.dart | test/unit/providers/auth/auth_provider_test.dart | Unit | P0 |
| services/auth_service.dart | test/unit/services/auth/auth_service_test.dart | Unit | P0 |
| services/social_auth_service.dart | test/unit/services/auth/social_auth_service_test.dart | Unit | P0 |
| pages/landing_page.dart | test/widget/auth/landing_page_test.dart | Widget | P0 |
| pages/signup_screen.dart | test/widget/auth/signup_screen_test.dart | Widget | P0 |

### Premium/Payment (`lib/features/premium/`)

| Source File | Test File | Test Type | Priority |
|-------------|-----------|-----------|----------|
| pages/premium_screen.dart | test/widget/premium/premium_screen_test.dart | Widget | P0 |
| pages/token_purchase_page.dart | test/widget/premium/token_purchase_test.dart | Widget | P0 |
| services/payment_service.dart | test/unit/services/payment_service_test.dart | Unit | P0 |

---

## Missing Coverage (Action Required)

### P1 - High Priority (이번 주 추가)

| Feature | 필요한 테스트 | 예상 시간 |
|---------|------------|----------|
| **Chat** | chat_home_page, chat_provider, message_service | 4h |
| **Profile** | profile_edit, profile_provider | 2h |

### P2 - Medium Priority (다음 스프린트)

| Feature | 필요한 테스트 | 예상 시간 |
|---------|------------|----------|
| **Character** | character_page, character_provider, affinity_service | 6h |
| **Wellness** | wellness_page, meditation_provider | 3h |
| **Health** | health_fortune_page, health_provider | 3h |

---

## Integration Test Coverage

### Current Flow Tests (`integration_test/`)

| Flow | Test File | Status |
|------|----------|--------|
| App Startup | integration_test/app_test.dart | ✅ |
| Auth Flow | integration_test/flows/auth_flow_test.dart | ✅ |
| Fortune Generation | integration_test/flows/fortune_generation_test.dart | ✅ |
| Premium Flow | integration_test/flows/premium_flow_test.dart | ✅ |
| User Journey | integration_test/flows/user_journey_test.dart | ✅ |
| Navigation | integration_test/navigation_test.dart | ✅ |
| Accessibility | integration_test/accessibility_test.dart | ✅ |
| Offline | integration_test/offline_capability_test.dart | ✅ |
| Performance | integration_test/performance_test.dart | ✅ |

### E2E Tests (Playwright)

| Test Suite | Routes | Status |
|-----------|--------|--------|
| Smoke Tests | 50+ | ✅ |
| Visual Regression | 10+ | ⚠️ 부분적 |
| Critical Flows | 5 | ✅ |

---

## Mocking Strategy

### Test Doubles

| Type | Library | Usage |
|------|---------|-------|
| Mocks | `mocktail` | Services, Providers, API clients |
| Fakes | Custom | User models, Fortune data |
| Stubs | Custom | Network responses |

### Key Mock Classes

```dart
// test/mocks/
├── mock_fortune_service.dart
├── mock_auth_provider.dart
├── mock_supabase_client.dart
├── mock_cache_service.dart
└── test_data.dart  // Factory for test data
```

---

## Coverage Thresholds

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| Line Coverage | 85% | ~80% | ⚠️ |
| Branch Coverage | 70% | ~65% | ⚠️ |
| Function Coverage | 90% | ~85% | ⚠️ |

### Coverage Commands

```bash
# Run tests with coverage
flutter test --coverage

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# View report
open coverage/html/index.html
```

---

## CI/CD Test Pipelines

| Pipeline | Tests | Trigger |
|----------|-------|---------|
| `flutter-ci.yml` | Unit + Widget + Integration | PR, Push to main |
| `flutter-test.yml` | Unit + Widget + Coverage | PR, Push to main |
| `e2e-tests.yml` | Playwright Smoke (50+ routes) | PR, Push to main |
| `qa-monitoring.yml` | Smoke + Performance + Edge Functions | 3x daily |
| `security-scan.yml` | Static analysis + Dependencies | PR, Daily |

---

## Test Quality Guidelines

### Golden Tests

```yaml
Font Consistency:
  - Use fixed font in tests (Roboto)
  - Set textScaleFactor: 1.0
  - Use fixed device size (iPhone 14 Pro)

Environment:
  - Locale: ko_KR
  - Theme: Both light and dark
  - Platform: Both iOS and Android
```

### Flaky Test Prevention

1. **Avoid real timers** - Use `fakeAsync`
2. **Mock network** - Never hit real APIs in unit tests
3. **Isolate tests** - No shared state between tests
4. **Deterministic data** - Use factories with fixed seeds
5. **Retry strategy** - Max 2 retries for E2E only

---

## Maintenance Schedule

| Task | Frequency | Owner |
|------|----------|-------|
| Coverage Report Review | Weekly | QA |
| Flaky Test Investigation | Daily | Dev |
| Test Gap Analysis | Bi-weekly | QA |
| Golden Update | Monthly | Dev |
| Dependency Update | Weekly (automated) | CI |

---

## Related Documents

- [QA Dashboard](../qa-dashboard/README.md)
- [Testing Guide](./README.md)
- [CI/CD Workflows](../../.github/workflows/)
