# Playwright MCP 테스트 스위트

이 프로젝트의 Playwright 테스트는 운세 앱의 Model Context Protocol(MCP) 통합과 사용자 경험을 종합적으로 검증합니다.

## 테스트 구조

### 1. 기본 동작 테스트 (`example.spec.ts`)
- 메인 페이지 로딩 및 기본 요소 확인
- 단계별 프로필 설정 과정
- MBTI 선택 모달 동작

### 2. MCP 통합 테스트 (`mcp-integration.spec.ts`)
- 프로필 데이터 저장 및 검증
- API 엔드포인트 통합 테스트
- 네트워크 오류 상황 처리
- 반응형 디자인 및 접근성
- 성능 메트릭 모니터링

### 3. 시각적 회귀 테스트 (`visual-regression.spec.ts`)
- 메인 페이지 스크린샷 비교
- MBTI 선택 모달 UI 검증
- 다크 모드 지원 확인
- 모바일/데스크톱 뷰 검증
- 에러 상태 및 로딩 상태 UI

### 4. API 테스트 (`api-tests.spec.ts`)
- MBTI API 엔드포인트 검증
- 모든 MBTI 타입 테스트
- API 성능 및 동시 요청 처리
- 데이터 구조 및 헤더 검증

## 실행 방법

### 전체 테스트 실행
```bash
npm run test
```

### UI 모드로 테스트 실행
```bash
npm run test:ui
```

### 헤드리스 모드 해제하여 실행
```bash
npm run test:headed
```

### 디버그 모드
```bash
npm run test:debug
```

### 테스트 리포트 보기
```bash
npm run test:report
```

## 테스트 커버리지

- ✅ 프로필 설정 플로우
- ✅ MBTI 선택 및 저장
- ✅ API 엔드포인트 통합
- ✅ 네트워크 오류 처리
- ✅ 반응형 디자인
- ✅ 접근성 기본 요구사항
- ✅ 성능 메트릭
- ✅ 시각적 회귀 테스트

## CI/CD 통합

GitHub Actions를 통해 자동화된 테스트가 실행됩니다:
- PR 및 메인 브랜치 푸시 시 자동 실행
- 테스트 결과 및 스크린샷 아티팩트 저장
- 실패 시 상세한 디버깅 정보 제공

## 헬퍼 함수

`tests/helpers/test-utils.ts`에서 재사용 가능한 유틸리티 함수들을 제공합니다:
- `completeProfileSetup()`: 전체 프로필 설정 과정 자동화
- `mockApiResponse()`: API 응답 모킹
- `simulateNetworkError()`: 네트워크 오류 시뮬레이션
- `collectPerformanceMetrics()`: 성능 메트릭 수집

## 모범 사례

1. **페이지 객체 패턴**: 복잡한 UI 상호작용은 헬퍼 함수로 추상화
2. **데이터 분리**: 테스트 데이터를 함수 매개변수로 전달하여 재사용성 향상
3. **비동기 처리**: 모든 상호작용에서 적절한 대기 조건 사용
4. **에러 처리**: 네트워크 오류 및 예외 상황에 대한 견고한 테스트
5. **성능 고려**: 테스트 실행 시간 최적화 및 병렬 실행 활용

## 디버깅 팁

- `--headed` 플래그로 브라우저 동작 시각적 확인
- `--debug` 플래그로 단계별 디버깅
- 스크린샷 비교를 통한 UI 변경사항 추적
- 네트워크 탭에서 API 호출 모니터링 