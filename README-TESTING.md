# Fortune Flutter App - 테스트 가이드

## 🎯 테스트 환경 설정 완료!

이제 **로그인 과정을 우회**하고 **전체 기능을 테스트**할 수 있습니다.

## 🔧 테스트 모드 실행 방법

### 1. 빠른 테스트 (권장)
```bash
# 인증 우회 모드로 빠른 테스트
./scripts/quick-test.sh
```

### 2. 전체 테스트 실행
```bash
# 모든 테스트 실행 (Flutter + Playwright)
./scripts/test.sh

# Flutter 통합 테스트만 실행
./scripts/test.sh flutter

# Playwright E2E 테스트만 실행
./scripts/test.sh playwright
```

### 3. 수동으로 테스트 모드 앱 실행
```bash
# 테스트 환경변수 설정
export FLUTTER_TEST_MODE=true
export TEST_MODE=true
export BYPASS_AUTH=true

# 앱 실행 (Chrome)
flutter run -d chrome --dart-define=FLUTTER_TEST_MODE=true --dart-define=TEST_MODE=true

# 앱 실행 (시뮬레이터)
flutter run -d iPhone --dart-define=FLUTTER_TEST_MODE=true --dart-define=TEST_MODE=true
```

## 🔑 인증 우회 기능

### 자동으로 설정되는 것들:
- ✅ **테스트 계정 자동 로그인** (test@fortune.com)
- ✅ **프리미엄 기능 활성화**
- ✅ **무제한 토큰** (999,999개)
- ✅ **온보딩 스킵**
- ✅ **결제 우회**

### 테스트 계정 정보:
- 이메일: `test@fortune.com`
- 비밀번호: `Test123!@#`
- 사용자 ID: `test-user-id-12345`
- 프로필: 완전 설정됨
- 토큰: 무제한

## 🧪 테스트 유형

### 1. Flutter 통합 테스트
- 위치: `integration_test/`
- 실행: `flutter test integration_test/ -d iPhone --dart-define=TEST_MODE=true`
- 내용: 앱 플로우, 인증, 운세 생성, 결제

### 2. Playwright E2E 테스트
- 위치: `playwright/tests/`
- 실행: `npm run test`
- 내용: 웹 브라우저에서 전체 사용자 플로우

### 3. 단위 테스트 (준비 중)
- 위치: `test/` (아직 생성되지 않음)
- 실행: `flutter test`
- 내용: 모델, 서비스, 유틸리티

## 🎮 테스트 시나리오

### ✅ 현재 동작하는 테스트:
1. **앱 시작 및 인증 우회**
2. **메인 화면 접근**
3. **네비게이션 테스트**
4. **기본 UI 요소 확인**

### 🚧 추가 구현 필요:
1. 운세 생성 플로우
2. 결제 시스템 테스트
3. 프로필 관리 테스트
4. 오프라인 모드 테스트

## 🐛 디버깅 및 트러블슈팅

### 테스트가 실패하는 경우:

1. **로그인 화면에서 멈추는 경우**:
   ```bash
   # 환경변수가 제대로 설정되었는지 확인
   echo $FLUTTER_TEST_MODE
   echo $TEST_MODE
   echo $BYPASS_AUTH
   ```

2. **빌드 오류가 발생하는 경우**:
   ```bash
   flutter clean
   flutter pub get
   flutter analyze
   ```

3. **Playwright 테스트 실패**:
   ```bash
   # Node.js 의존성 재설치
   npm install
   npx playwright install

   # 헤드리스 모드 비활성화 (디버깅용)
   npm run test:headed
   ```

### 로그 확인:
- Flutter 로그: `🔧 [TEST]` 마커로 검색
- Playwright 로그: `🧪 [TEST]` 마커로 검색
- 인증 로그: `🔧 [AUTH]` 마커로 검색

## 📊 테스트 결과 확인

### 결과 파일 위치:
- **Playwright 스크린샷**: `test-results/*.png`
- **HTML 리포트**: `playwright-report/index.html`
- **커버리지 리포트**: `coverage/html/index.html`

### 리포트 보기:
```bash
# Playwright 리포트 열기
npm run test:report

# 커버리지 리포트 (있는 경우)
open coverage/html/index.html
```

## 🔧 고급 설정

### 테스트 환경 커스터마이징:
`.env.test` 파일을 수정하여 테스트 설정 변경:
```env
TEST_ACCOUNT_EMAIL=custom@test.com
TEST_USER_ID=custom-test-id
MOCK_PREMIUM_FEATURES=true
BYPASS_PAYMENT=true
```

### CI/CD 통합:
```bash
# GitHub Actions용
./scripts/test.sh all --ci
```

## 📝 테스트 작성 가이드

### 새로운 Playwright 테스트 추가:
```javascript
// playwright/tests/e2e/new-feature.spec.js
const { test, expect } = require('@playwright/test');
const { AuthHelper } = require('../../helpers/auth.helper');

test.describe('New Feature Tests', () => {
  test.beforeEach(async ({ page }) => {
    const authHelper = new AuthHelper(page);
    await authHelper.authenticate(); // 자동 인증
  });

  test('should test new feature', async ({ page }) => {
    // 테스트 코드 작성
  });
});
```

### Flutter 통합 테스트 추가:
```dart
// integration_test/new_feature_test.dart
testWidgets('new feature test', (WidgetTester tester) async {
  // 테스트 모드에서는 인증이 자동으로 우회됨
  app.main();
  await tester.pumpAndSettle();

  // 테스트 코드 작성
});
```

## 🚀 다음 단계

1. **현재 상태**: 인증 우회 시스템 구축 완료 ✅
2. **즉시 가능**: 기능 테스트 및 UI 검증 ✅
3. **추천 순서**:
   - `./scripts/quick-test.sh` 실행하여 기본 동작 확인
   - `./scripts/test.sh flutter` 로 Flutter 테스트 실행
   - `./scripts/test.sh playwright` 로 E2E 테스트 실행

**이제 로그인 과정 없이 전체 앱 기능을 테스트할 수 있습니다!** 🎉