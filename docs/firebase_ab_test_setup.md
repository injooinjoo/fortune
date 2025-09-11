# Firebase A/B Testing & Google Analytics 설정 가이드

## 목차
1. [Firebase Console 설정](#firebase-console-설정)
2. [A/B 테스트 생성](#ab-테스트-생성)
3. [Analytics 이벤트 추적](#analytics-이벤트-추적)
4. [코드 통합](#코드-통합)
5. [테스트 및 디버깅](#테스트-및-디버깅)

## Firebase Console 설정

### 1. Firebase 프로젝트 접속
1. [Firebase Console](https://console.firebase.google.com)에 접속
2. Fortune 프로젝트 선택

### 2. Analytics 활성화 확인
1. 좌측 메뉴에서 **Analytics** 클릭
2. **대시보드**에서 데이터 수집 상태 확인
3. 실시간 데이터가 표시되는지 확인

### 3. Remote Config 설정
1. 좌측 메뉴에서 **Remote Config** 클릭
2. **시작하기** 버튼 클릭 (처음인 경우)
3. 기본 파라미터 생성

## A/B 테스트 생성

### 1. A/B Testing 메뉴 접속
1. Firebase Console에서 **A/B Testing** 메뉴 클릭
2. **실험 만들기** → **Remote Config** 선택

### 2. 실험 기본 정보 설정

#### 실험 1: 결제 화면 UI 테스트
```
실험 이름: payment_ui_test
설명: 결제 화면 레이아웃과 버튼 스타일 최적화
목표 메트릭: purchase (구매 전환율)
```

**변형 설정:**
- **Control (대조군)**: 
  - `payment_ui_layout`: "split"
  - `payment_button_style`: "rounded"
  - `show_discount_badge`: true

- **Variant A**: 
  - `payment_ui_layout`: "compact"
  - `payment_button_style`: "rounded"
  - `show_discount_badge`: true

- **Variant B**: 
  - `payment_ui_layout`: "split"
  - `payment_button_style`: "full_width"
  - `show_discount_badge`: false

#### 실험 2: 온보딩 플로우 테스트
```
실험 이름: onboarding_flow_test
설명: 온보딩 완료율 향상을 위한 플로우 최적화
목표 메트릭: tutorial_complete (온보딩 완료)
```

**변형 설정:**
- **Control**: 
  - `onboarding_flow`: "standard"
  - `onboarding_skippable`: false

- **Variant A (간소화)**: 
  - `onboarding_flow`: "simplified"
  - `onboarding_skippable`: true

- **Variant B (점진적)**: 
  - `onboarding_flow`: "progressive"
  - `onboarding_skippable`: false

#### 실험 3: 운세 카드 UI 테스트
```
실험 이름: fortune_card_ui_test
설명: 운세 카드 디자인과 사용자 참여도 최적화
목표 메트릭: fortune_generation (운세 생성 횟수)
```

**변형 설정:**
- **Control**: 
  - `fortune_ui_style`: "modern"
  - `fortune_animation_enabled`: true
  - `fortune_card_layout`: "card"

- **Variant A (클래식)**: 
  - `fortune_ui_style`: "classic"
  - `fortune_animation_enabled`: false
  - `fortune_card_layout`: "list"

- **Variant B (프리미엄)**: 
  - `fortune_ui_style`: "premium"
  - `fortune_animation_enabled`: true
  - `fortune_card_layout`: "carousel"

#### 실험 4: 토큰 가격 테스트
```
실험 이름: token_pricing_test
설명: 토큰 패키지 가격과 보너스 비율 최적화
목표 메트릭: purchase (구매 전환율), revenue (수익)
```

**변형 설정:**
- **Control**: 
  - `token_bonus_rate`: 1.0
  - `popular_token_package`: "tokens100"

- **Variant A (낮은 가격)**: 
  - `token_bonus_rate`: 1.1
  - `popular_token_package`: "tokens50"

- **Variant B (높은 보너스)**: 
  - `token_bonus_rate`: 1.3
  - `popular_token_package`: "tokens200"

### 3. 타겟팅 설정

#### 사용자 세그먼트
- **국가**: 대한민국
- **언어**: 한국어
- **앱 버전**: 1.0.0 이상
- **플랫폼**: iOS, Android

#### 트래픽 할당
- **테스트 참여 비율**: 
  - 신규 기능: 20-30%
  - UI 변경: 50%
  - 가격 테스트: 30%

### 4. 실험 일정
- **시작일**: 즉시
- **종료 조건**: 
  - 최소 실행 기간: 7일
  - 최소 사용자 수: 1,000명
  - 통계적 유의성 도달 시

## Analytics 이벤트 추적

### 핵심 이벤트 설정

#### 1. A/B 테스트 노출 이벤트
```dart
// 사용자가 실험에 노출될 때
AnalyticsService.instance.logABTestExposure(
  experimentId: 'payment_ui_test',
  variantId: 'variant_a',
  variantName: 'Compact Layout',
  userId: currentUserId,
);
```

#### 2. 전환 이벤트
```dart
// 목표 달성 시 (예: 구매 완료)
AnalyticsService.instance.logABTestConversion(
  experimentId: 'payment_ui_test',
  variantId: 'variant_a',
  conversionType: 'purchase',
  conversionValue: 2500.0,
);
```

#### 3. 커스텀 메트릭
```dart
// 추가 메트릭 추적
AnalyticsService.instance.logABTestMetric(
  experimentId: 'onboarding_flow_test',
  variantId: 'control',
  metricName: 'time_to_complete',
  metricValue: 45, // 초 단위
);
```

### Firebase Console에서 이벤트 확인

1. **Analytics** → **이벤트** 메뉴
2. 다음 이벤트들이 표시되는지 확인:
   - `ab_test_exposure`
   - `ab_test_conversion`
   - `payment_ui_test`
   - `onboarding_test`
   - `fortune_card_ui_test`
   - `token_pricing_test`

## 코드 통합

### 1. 실험 변형 가져오기
```dart
// 결제 화면에서
final variant = await ABTestService.instance.getVariant('payment_ui_test');
final layout = variant.getParameter<String>('layout') ?? 'split';
final buttonStyle = variant.getParameter<String>('button_style') ?? 'rounded';
final showBadge = variant.getParameter<bool>('show_discount_badge') ?? true;

// UI 렌더링에 적용
if (layout == 'compact') {
  return CompactPaymentLayout(
    buttonStyle: buttonStyle,
    showDiscountBadge: showBadge,
  );
} else {
  return SplitPaymentLayout(
    buttonStyle: buttonStyle,
    showDiscountBadge: showBadge,
  );
}
```

### 2. 전환 추적
```dart
// 구매 완료 시
await ABTestService.instance.trackConversion(
  experimentId: 'payment_ui_test',
  conversionType: 'purchase',
  additionalData: {
    'package_id': selectedPackage.id,
    'price': selectedPackage.price,
  },
);
```

### 3. RemoteConfig 값 직접 사용
```dart
// RemoteConfig에서 직접 값 가져오기
final remoteConfig = RemoteConfigService();
final subscriptionPrice = remoteConfig.getSubscriptionPrice();
final tokenPackages = remoteConfig.getTokenPackages();
```

## 테스트 및 디버깅

### 1. Debug 모드에서 변형 강제 설정
```dart
// 개발 중 특정 변형 테스트
if (kDebugMode) {
  await ABTestService.instance.forceVariant(
    'payment_ui_test',
    'variant_b',
  );
}
```

### 2. Analytics DebugView 사용

#### Android
```bash
adb shell setprop debug.firebase.analytics.app com.beyond.fortune
```

#### iOS
Xcode에서 실행 시 Arguments에 추가:
```
-FIRAnalyticsDebugEnabled
```

### 3. 실시간 이벤트 모니터링
1. Firebase Console → Analytics → DebugView
2. 앱에서 이벤트 발생
3. 실시간으로 이벤트 확인

### 4. Remote Config 값 새로고침
```dart
// 강제 새로고침 (개발용)
await RemoteConfigService().refresh();
```

## 결과 분석

### 1. A/B Testing 대시보드
- **개요**: 실험 진행 상황, 참여자 수
- **목표 메트릭**: 전환율, 수익 변화
- **변형별 성과**: 각 변형의 성과 비교

### 2. 통계적 유의성
- **신뢰도**: 95% 이상 권장
- **최소 샘플 크기**: 변형당 최소 500명
- **실행 기간**: 최소 1주일

### 3. 승자 선택
1. 통계적 유의성 확인
2. 비즈니스 목표와 일치 확인
3. 부작용 검토 (다른 메트릭 영향)
4. 점진적 롤아웃 고려

## 베스트 프랙티스

### 1. 실험 설계
- 한 번에 하나의 변수만 테스트
- 명확한 가설 설정
- 충분한 샘플 크기 확보
- 계절성 고려 (주말/주중, 월초/월말)

### 2. 사용자 경험
- 실험 중 일관된 경험 제공
- 세션 내 변형 변경 방지
- 중요 기능은 점진적 테스트

### 3. 데이터 품질
- 이벤트 파라미터 검증
- 중복 이벤트 방지
- 정확한 타임스탬프 기록

### 4. 윤리적 고려사항
- 사용자 프라이버시 보호
- 투명한 데이터 사용
- 부정적 영향 최소화

## 문제 해결

### 이벤트가 표시되지 않을 때
1. Analytics 초기화 확인
2. 네트워크 연결 확인
3. 이벤트 이름/파라미터 검증
4. DebugView에서 확인

### Remote Config 값이 업데이트되지 않을 때
1. 최소 fetch 간격 확인 (개발: 0, 프로덕션: 1시간)
2. 활성화 호출 확인
3. 캐시 정리 후 재시도

### A/B 테스트 결과가 예상과 다를 때
1. 샘플 크기 확인
2. 실험 기간 연장
3. 세그먼트별 분석
4. 외부 요인 검토

## 참고 자료
- [Firebase A/B Testing 문서](https://firebase.google.com/docs/ab-testing)
- [Firebase Analytics 문서](https://firebase.google.com/docs/analytics)
- [Firebase Remote Config 문서](https://firebase.google.com/docs/remote-config)
- [A/B 테스트 베스트 프랙티스](https://firebase.google.com/docs/ab-testing/abtest-best-practices)