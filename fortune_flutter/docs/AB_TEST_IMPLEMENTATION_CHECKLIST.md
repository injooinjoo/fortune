# A/B Test Implementation Checklist

## 🎯 현재 구현 상태

### ✅ 완료된 작업

#### 1. 기반 시스템
- [x] Firebase A/B Testing 가이드 문서 작성
- [x] Remote Config 서비스 구현 (`remote_config_service.dart`)
- [x] A/B Test Manager 구현 (`ab_test_manager.dart`)
- [x] 이벤트 상수 정의 (`ab_test_events.dart`)

#### 2. 결제 시스템 A/B 테스트
- [x] 토큰 구매 페이지 A/B 테스트 버전 구현
- [x] 4가지 레이아웃 변형 지원
  - Split layout (구독/토큰 분리)
  - Unified layout (통합)
  - Subscription first (구독 강조)
  - Token first (토큰 강조)
- [x] 동적 가격 설정
- [x] 이벤트 추적 통합

#### 3. 온보딩 A/B 테스트
- [x] 온보딩 플로우 A/B 테스트 버전 구현
- [x] 4가지 플로우 변형 지원
  - Standard (기본)
  - Simplified (간소화)
  - Detailed (상세)
  - Progressive (점진적)
- [x] 스킵 가능 옵션
- [x] 완료율 추적

---

## 📋 앞으로 구현해야 할 작업

### 1. Firebase 설정
- [ ] Firebase Console에서 A/B Testing 활성화
- [ ] Remote Config 기본값 설정
- [ ] Analytics 이벤트 검증
- [ ] 사용자 속성 설정

### 2. 기존 페이지 마이그레이션

#### 구독 페이지
- [ ] `subscription_page.dart`를 A/B 테스트 버전으로 업데이트
- [ ] Remote Config 값 사용하도록 변경
- [ ] 이벤트 추적 추가

#### 운세 페이지들
- [ ] 운세 카드 레이아웃 A/B 테스트 적용
- [ ] 애니메이션 활성화/비활성화 옵션
- [ ] UI 스타일 변형 (modern/classic/minimal)

#### 홈 화면
- [ ] 홈 화면 레이아웃 A/B 테스트
- [ ] 추천 운세 알고리즘 테스트
- [ ] CTA 버튼 위치/스타일 테스트

### 3. 새로운 A/B 테스트 시나리오

#### 토큰 보너스 테스트
```dart
// remote_config_service.dart에 추가
static const String tokenBonusRateKey = 'token_bonus_rate';
static const String showBonusBadgeKey = 'show_bonus_badge';
static const String bonusMessageKey = 'bonus_message';
```

#### 일일 무료 토큰 테스트
```dart
// 일일 무료 토큰 개수 테스트
static const String dailyFreeTokensKey = 'daily_free_tokens';
static const String freeTokenTimeKey = 'free_token_time'; // 지급 시간
```

#### 추천 시스템 테스트
```dart
// 추천 보상 테스트
static const String referralBonusTokensKey = 'referral_bonus_tokens';
static const String referralMessageKey = 'referral_message';
```

### 4. 성능 모니터링
- [ ] 화면 로드 시간 추적
- [ ] API 응답 시간 측정
- [ ] 이탈률 모니터링
- [ ] 전환율 실시간 추적

### 5. 테스트 자동화
- [ ] A/B 테스트 시뮬레이터 구현
- [ ] 통계적 유의성 계산기
- [ ] 자동 리포트 생성

---

## 🚀 구현 우선순위

### Phase 1 (1주차)
1. Firebase Console 설정
2. 기존 구독 페이지 마이그레이션
3. 첫 실험 시작 (구독 가격 테스트)

### Phase 2 (2주차)
1. 홈 화면 A/B 테스트 구현
2. 운세 카드 레이아웃 테스트
3. 토큰 보너스 테스트

### Phase 3 (3주차)
1. 추천 시스템 A/B 테스트
2. 일일 무료 토큰 테스트
3. 성능 모니터링 구현

### Phase 4 (4주차)
1. 테스트 결과 분석
2. 승리 변형 적용
3. 다음 실험 계획

---

## 📊 측정 지표

### 주요 성과 지표 (KPI)
- **구독 전환율**: 구독 화면 조회 → 구독 구매
- **토큰 구매율**: 토큰 화면 조회 → 토큰 구매
- **ARPU**: 사용자당 평균 수익
- **리텐션**: D1, D7, D30 재방문율

### 보조 지표
- **온보딩 완료율**: 시작 → 완료
- **운세 생성률**: 앱 열기 → 운세 생성
- **공유율**: 운세 생성 → 공유
- **평균 세션 시간**: 사용자당 평균 사용 시간

---

## 🛠 개발 가이드라인

### 새로운 기능 개발 시
1. **항상 Remote Config 고려**
   ```dart
   // ❌ Bad
   const price = 2500;
   
   // ✅ Good
   final price = remoteConfig.getSubscriptionPrice();
   ```

2. **이벤트 추적 필수**
   ```dart
   // 모든 사용자 액션에 이벤트 추가
   abTestManager.logEvent(
     eventName: ABTestEvents.buttonClicked,
     parameters: {'button_id': 'subscribe'},
   );
   ```

3. **A/B 테스트 컨텍스트 포함**
   ```dart
   // 이벤트에 실험 정보 자동 포함
   abTestManager.logEventWithABTest(
     eventName: 'custom_event',
     parameters: customParams,
   );
   ```

### 코드 리뷰 체크리스트
- [ ] Remote Config 값 사용 여부
- [ ] 하드코딩된 값 제거
- [ ] 이벤트 추적 구현
- [ ] A/B 테스트 문서 업데이트

---

## 📝 실험 문서화 템플릿

```markdown
## 실험명: [실험 이름]

### 가설
[측정 가능한 가설 작성]

### 변형
- Control: [기본값]
- Variant A: [변형 A]
- Variant B: [변형 B]

### 측정 지표
- Primary: [주요 지표]
- Secondary: [보조 지표]

### 실험 기간
- 시작: YYYY-MM-DD
- 종료: YYYY-MM-DD

### 결과
- 승자: [승리 변형]
- 향상도: [X%]
- 통계적 유의성: [p-value]

### 학습
[실험에서 얻은 인사이트]
```

---

## 🔄 정기 점검 항목

### 주간
- [ ] 실험 진행 상황 확인
- [ ] 이상 징후 모니터링
- [ ] 샘플 크기 확인

### 월간
- [ ] 실험 결과 분석
- [ ] 승리 변형 적용
- [ ] 다음 실험 계획

### 분기별
- [ ] A/B 테스트 전략 검토
- [ ] 프로세스 개선
- [ ] 팀 교육

---

이 체크리스트를 참고하여 체계적으로 A/B 테스트를 구현하고 관리하세요!