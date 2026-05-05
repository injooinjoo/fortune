# 자동 QA 시스템 (Playwright MCP 기반)

> 최종 업데이트: 2025.01.03

개발 완료 후 실제 앱을 자동으로 테스트하여 기능이 정상 동작하는지 검증하는 시스템입니다.

## 개요

```
개발 작업 완료
      ↓
자동 QA 트리거
      ↓
Playwright MCP 실행
      ↓
브라우저에서 실제 테스트
      ↓
결과 리포트 생성
```

---

## 사전 준비

### 1. Playwright MCP 서버 설정

`.claude/settings.local.json`에 Playwright MCP가 설정되어 있습니다:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-playwright"],
      "env": {
        "PLAYWRIGHT_HEADLESS": "false",
        "PLAYWRIGHT_TIMEOUT": "30000"
      }
    }
  }
}
```

### 2. Flutter Web 서버 실행

테스트를 위해서는 Flutter Web 앱이 실행 중이어야 합니다:

```bash
# 개발 서버 실행 (포트 3000)
flutter run -d chrome --web-port=3000

# 또는 빌드 후 서버 실행
flutter build web
npx serve build/web -l 3000
```

### 3. 테스트 환경 변수

`.env.test` 파일에 테스트 계정 정보가 설정되어 있습니다:

```env
# 테스트 모드 플래그
FLUTTER_TEST_MODE=true
BYPASS_AUTH=true

# 테스트 계정
TEST_ACCOUNT_EMAIL=test@fortune.com
TEST_ACCOUNT_PASSWORD=TestFortuneApp2025!@#SecurePassword
```

---

## 사용 방법

### CLI 직접 실행

```bash
# Playwright 테스트 실행
npx playwright test playwright/tests/e2e/fortune.spec.js

# 특정 테스트만
npx playwright test -g "daily fortune"

# 디버그 모드 (브라우저 표시)
npx playwright test --headed --debug
```

---

## 자동 실행 트리거

다음 작업 완료 시 자동으로 QA가 실행됩니다:

| 트리거 | 조건 | 테스트 범위 |
|--------|------|------------|
| 운세 페이지 수정 | `*_fortune_page.dart` 변경 | 해당 운세 페이지 |
| UI 컴포넌트 수정 | `presentation/widgets/` 변경 | 관련 페이지들 |
| Edge Function 배포 | `supabase functions deploy` 후 | API 연동 테스트 |
| 구독 수정 | `premium` 코드 변경 | 구독 플로우 |
| 라우팅 수정 | `route_config.dart` 변경 | 네비게이션 테스트 |

### 자동 트리거 비활성화

특정 상황에서 자동 QA를 건너뛰려면:

```bash
# 커밋 메시지에 [skip-qa] 포함
git commit -m "fix: typo [skip-qa]"
```

---

## 테스트 시나리오

### 1. 운세 페이지 시나리오 (`fortune-page`)

```
1. 페이지 로딩 (networkidle 대기)
2. Flutter 앱 초기화 대기 (3초)
3. 메인 콘텐츠 확인 (운세, 오늘 등 키워드)
4. 입력 폼 존재 확인
5. 운세 생성 버튼 클릭
6. 로딩 상태 확인 및 완료 대기
7. 결과 화면 렌더링 확인
8. 스크린샷 캡처
```

**적용 페이지**: `/fortune/*`, `/saju/*`, `/tarot/*`

### 2. 일반 페이지 시나리오 (`page-render`)

```
1. 페이지 로딩
2. Flutter 초기화 대기
3. 콘텐츠 렌더링 확인
4. 스크린샷 캡처
```

**적용 페이지**: `/home`, `/profile`, `/subscription` 등

### 3. 인증 플로우 시나리오 (`auth-flow`)

```
1. 랜딩 페이지 접근
2. 로그인 버튼 확인
3. 테스트 계정 로그인 (BYPASS_AUTH)
4. 홈 화면 리다이렉트 확인
```

---

## 검증 항목

### 공통 검증

| 항목 | 설명 | 중요도 |
|------|------|--------|
| 콘솔 에러 | JavaScript 콘솔 에러 없음 | 높음 |
| 네트워크 에러 | API 4xx/5xx 응답 없음 | 높음 |
| 페이지 로딩 | 30초 내 로딩 완료 | 높음 |
| UI 렌더링 | 주요 요소 표시 | 중간 |

### 운세 페이지 검증

| 항목 | 설명 |
|------|------|
| 입력 폼 | 생년월일, 시간, 성별 입력 가능 |
| 운세 생성 | 버튼 클릭 후 API 호출 |
| 로딩 상태 | 로딩 인디케이터 표시 |
| 결과 표시 | 운세 결과 화면 렌더링 |

---

## 인증 처리

### 테스트 모드 인증

테스트 환경에서는 인증을 우회합니다:

```javascript
// auth.helper.js
await page.addInitScript(() => {
  window.FLUTTER_TEST_MODE = true;
  window.BYPASS_AUTH = true;
  window.TEST_ACCOUNT_EMAIL = 'test@fortune.com';
});
```

### Flutter 앱 내 처리

`TestAuthService`가 테스트 모드를 감지하고 자동 로그인합니다:

```dart
// lib/core/services/test_auth_service.dart
static bool isTestMode() {
  return const String.fromEnvironment('FLUTTER_TEST_MODE') == 'true';
}
```

---

## 결과 리포트

### 성공 시

```
============================================
🎭 자동 QA 테스트 결과
============================================

📍 테스트 대상: /fortune/daily
🕐 실행 시간: 2024-01-15T10:30:00

테스트 항목:
  ✅ 페이지 로딩
  ✅ Flutter 초기화
  ✅ 메인 콘텐츠
  ✅ 인터랙션
  ✅ 스크린샷

📸 스크린샷:
  - playwright/screenshots/fortune-daily-1705312200.png

============================================
총 결과: ✅ PASS
============================================
```

### 실패 시

```
============================================
🎭 자동 QA 테스트 결과
============================================

📍 테스트 대상: /fortune/daily
🕐 실행 시간: 2024-01-15T10:30:00

테스트 항목:
  ✅ 페이지 로딩
  ✅ Flutter 초기화
  ❌ 메인 콘텐츠
  ⏭️ 인터랙션 (스킵)

⚠️ 발견된 문제:
  - [console] TypeError: Cannot read property 'data' of undefined
  - [network] 500 - https://api.fortune.com/v1/daily

📸 스크린샷:
  - playwright/screenshots/error-1705312200.png

============================================
총 결과: ❌ FAIL
============================================

권장 조치:
1. 콘솔 에러 확인 후 해당 코드 수정
2. API 응답 확인 (Edge Function 로그 체크)
3. `/investigate`로 근본 원인 분석
```

---

## 파일 구조

```
playwright/
├── tests/
│   └── e2e/
│       ├── fortune.spec.js      # 운세 E2E 테스트
│       ├── auth.spec.js         # 인증 테스트
│       └── navigation.spec.js   # 네비게이션 테스트
├── scenarios/
│   ├── fortune-page.scenario.js # 운세 페이지 시나리오
│   └── index.js                 # 시나리오 인덱스
├── helpers/
│   └── auth.helper.js           # 인증 헬퍼
├── screenshots/                 # 테스트 스크린샷
├── global-setup.js              # 전역 설정
└── global-teardown.js           # 전역 정리

playwright.config.js             # Playwright 설정
.env.test                        # 테스트 환경 변수
```

---

## 관련 도구

| 도구 | 역할 |
|------|------|
| iOS Simulator MCP | RN 앱 화면 캡처/탐색 (주력 QA 경로) |
| `/qa` (글로벌) | 헤드리스 브라우저 기반 QA (웹 surface가 있을 때) |
| `/investigate` (글로벌) | 테스트 실패 시 근본 원인 분석 |

---

## 트러블슈팅

### 서버 연결 실패

```
Error: net::ERR_CONNECTION_REFUSED
```

**해결**: Flutter Web 서버가 실행 중인지 확인
```bash
curl http://localhost:3000
```

### Flutter 앱 로딩 실패

```
Error: Timeout waiting for page to load
```

**해결**: 타임아웃 증가 또는 Flutter 빌드 확인
```bash
flutter clean && flutter pub get && flutter run -d chrome
```

### 인증 우회 실패

```
Error: Redirected to login page
```

**해결**: TestAuthService 확인, 환경 변수 설정 확인
```dart
// main.dart에서 테스트 모드 처리 확인
if (TestAuthService.isTestMode()) {
  await TestAuthService().autoLoginTestAccount();
}
```

### 요소를 찾을 수 없음

```
Error: Element not found: text=운세
```

**해결**: Flutter Web에서는 일반 DOM 셀렉터가 다르게 동작합니다.
- `flt-semantics` 태그 사용
- 텍스트 기반 셀렉터 사용 (`text=운세`)
- waitForTimeout으로 충분한 대기 시간 확보