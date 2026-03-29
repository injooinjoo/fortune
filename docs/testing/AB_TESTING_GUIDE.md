# A/B Testing 완전 가이드

## 목차
1. [Firebase Console 설정](#1-firebase-console-설정)
2. [코드 통합 및 구현](#2-코드-통합-및-구현)
3. [실험 설계 및 실행](#3-실험-설계-및-실행)
4. [테스트 및 디버깅](#4-테스트-및-디버깅)
5. [결과 분석](#5-결과-분석)
6. [구현 체크리스트](#6-구현-체크리스트)

---

## 1. Firebase Console 설정

### 1.1 프로젝트 초기 설정

#### Firebase 프로젝트 접속
1. [Firebase Console](https://console.firebase.google.com)에 접속
2. Fortune 프로젝트 선택

#### Analytics 활성화 확인
1. 좌측 메뉴에서 **Analytics** 클릭
2. **대시보드**에서 데이터 수집 상태 확인
3. 실시간 데이터가 표시되는지 확인

#### Remote Config 설정
1. 좌측 메뉴에서 **Remote Config** 클릭
2. **시작하기** 버튼 클릭 (처음인 경우)
3. 기본 파라미터 생성

### 1.2 A/B 테스트 생성

#### A/B Testing 메뉴 접속
1. Firebase Console에서 **A/B Testing** 메뉴 클릭
2. **실험 만들기** → **Remote Config** 선택

#### 실험 기본 정보 설정

##### 실험 1: 결제 화면 UI 테스트
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

##### 실험 2: 온보딩 플로우 테스트
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

##### 실험 3: 운세 카드 UI 테스트
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

##### 실험 4: 토큰 가격 테스트
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

### 1.3 타겟팅 설정

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

#### 실험 일정
- **시작일**: 즉시
- **종료 조건**:
  - 최소 실행 기간: 7일
  - 최소 사용자 수: 1,000명
  - 통계적 유의성 도달 시

---

## 2. 코드 통합 및 구현

### 2.1 실험 정의하기

앱 초기화 시점에서 실험을 등록합니다:

```dart
// main.dart 또는 앱 초기화 시점에서
void setupABTests() {
  final abTestService = ABTestService.instance;

  // 홈 화면 레이아웃 테스트
  abTestService.registerExperiment(
    ABTestExperiment(
      id: 'home_layout_test',
      name: '홈 화면 레이아웃 테스트',
      description: '그리드 vs 리스트 레이아웃 비교',
      variants: [
        const ControlVariant(parameters: {'layout': 'list'}),
        const ABTestVariant(
          id: 'grid_variant',
          name: '그리드 레이아웃',
          parameters: {'layout': 'grid'},
          weight: 0.5,
        ),
      ],
      startDate: DateTime.now(),
      trafficAllocation: 1.0, // 100% 트래픽 참여
    ),
  );
}
```

### 2.2 UI에서 AB 테스트 적용하기

#### 방법 1: ABTestWidget 사용 (권장)
```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ABTestWidget(
      experimentId: 'home_layout_test',
      builder: (context, variant) {
        final layout = variant.getParameter<String>('layout');

        if (layout == 'grid') {
          return GridView.builder(...); // 그리드 레이아웃
        }
        return ListView.builder(...); // 리스트 레이아웃
      },
    );
  }
}
```

#### 방법 2: ABTestSwitchWidget 사용
```dart
class FortuneCardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ABTestSwitchWidget(
      experimentId: 'fortune_card_ui_test',
      variants: {
        'control': ModernFortuneCard(),
        'classic': ClassicFortuneCard(),
        'premium': PremiumFortuneCard(),
      },
      defaultWidget: ModernFortuneCard(),
    );
  }
}
```

#### 방법 3: 조건부 렌더링
```dart
ABTestConditionalWidget(
  experimentId: 'payment_ui_test',
  targetVariantId: 'new_payment_flow',
  child: NewPaymentButton(),
  fallback: OldPaymentButton(),
)
```

#### 방법 4: 파라미터 기반 렌더링
```dart
class TokenPurchasePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ABTestParameterWidget<int>(
      experimentId: 'token_pricing_test',
      parameterKey: 'price_100',
      defaultValue: 10000,
      builder: (context, price) {
        return TokenPackageCard(
          title: '토큰 100개',
          price: price!,
          onPurchase: () async {
            // 구매 처리...
            await ref.read(abTestServiceProvider).trackConversion(
              experimentId: 'token_pricing_test',
              conversionType: 'token_purchase',
              additionalData: {'price': price, 'amount': 100},
            );
          },
        );
      },
    );
  }
}
```

### 2.3 전환 이벤트 추적하기

```dart
// 버튼 클릭 시
ElevatedButton(
  onPressed: () async {
    // 구매 로직...

    // 전환 이벤트 추적
    await ABTestService.instance.trackConversion(
      experimentId: 'payment_ui_test',
      conversionType: 'purchase_completed',
      additionalData: {
        'amount': 10000,
        'product_id': 'tokens_100',
      },
    );
  },
  child: Text('구매하기'),
)
```

### 2.4 Analytics 이벤트 추적

#### A/B 테스트 노출 이벤트
```dart
// 사용자가 실험에 노출될 때
AnalyticsService.instance.logABTestExposure(
  experimentId: 'payment_ui_test',
  variantId: 'variant_a',
  variantName: 'Compact Layout',
  userId: currentUserId,
);
```

#### 전환 이벤트
```dart
// 목표 달성 시 (예: 구매 완료)
AnalyticsService.instance.logABTestConversion(
  experimentId: 'payment_ui_test',
  variantId: 'variant_a',
  conversionType: 'purchase',
  conversionValue: 2500.0,
);
```

#### 커스텀 메트릭
```dart
// 추가 메트릭 추적
AnalyticsService.instance.logABTestMetric(
  experimentId: 'onboarding_flow_test',
  variantId: 'control',
  metricName: 'time_to_complete',
  metricValue: 45, // 초 단위
);
```

### 2.5 RemoteConfig 직접 사용

```dart
// RemoteConfig에서 직접 값 가져오기
final remoteConfig = RemoteConfigService();
final subscriptionPrice = remoteConfig.getSubscriptionPrice();
final tokenPackages = remoteConfig.getTokenPackages();

// 실험 변형 가져오기
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

---

## 3. 실험 설계 및 실행

### 3.1 실전 예제

#### 예제 1: 토큰 가격 테스트

```dart
// 1. 실험 정의
abTestService.registerExperiment(
  ABTestExperiment(
    id: 'token_pricing_test',
    name: '토큰 가격 최적화',
    description: '가격과 보너스 비율 테스트',
    variants: [
      const ControlVariant(parameters: {
        'price_100': 10000,
        'bonus_rate': 1.0,
      }),
      const ABTestVariant(
        id: 'lower_price',
        name: '낮은 가격',
        parameters: {
          'price_100': 9000,
          'bonus_rate': 1.1,
        },
        weight: 0.5,
      ),
    ],
    startDate: DateTime.now(),
  ),
);

// 2. UI에서 사용
class TokenPurchasePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ABTestParameterWidget<int>(
      experimentId: 'token_pricing_test',
      parameterKey: 'price_100',
      defaultValue: 10000,
      builder: (context, price) {
        return TokenPackageCard(
          title: '토큰 100개',
          price: price!,
          onPurchase: () async {
            // 구매 처리...
            await ref.read(abTestServiceProvider).trackConversion(
              experimentId: 'token_pricing_test',
              conversionType: 'token_purchase',
              additionalData: {'price': price, 'amount': 100},
            );
          },
        );
      },
    );
  }
}
```

#### 예제 2: 온보딩 플로우 테스트

```dart
// 1. 실험 정의
abTestService.registerExperiment(
  ABTestExperiment(
    id: 'onboarding_flow_test',
    name: '온보딩 최적화',
    description: '단계 수와 스킵 가능 여부 테스트',
    variants: [
      const ControlVariant(parameters: {
        'steps': 5,
        'skippable': false,
      }),
      const ABTestVariant(
        id: 'simplified',
        name: '간소화',
        parameters: {
          'steps': 3,
          'skippable': true,
        },
        weight: 0.5,
      ),
    ],
    startDate: DateTime.now(),
  ),
);

// 2. 온보딩에서 사용
class OnboardingPage extends ConsumerStatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return ABTestWidget(
      experimentId: 'onboarding_flow_test',
      builder: (context, variant) {
        final totalSteps = variant.getParameter<int>('steps') ?? 5;
        final isSkippable = variant.getParameter<bool>('skippable') ?? false;

        return Scaffold(
          appBar: AppBar(
            actions: isSkippable ? [
              TextButton(
                onPressed: () => _skipOnboarding(),
                child: Text('건너뛰기'),
              ),
            ] : null,
          ),
          body: OnboardingStep(
            step: currentStep,
            totalSteps: totalSteps,
            onComplete: () {
              if (currentStep < totalSteps - 1) {
                setState(() => currentStep++);
              } else {
                _completeOnboarding();
              }
            },
          ),
        );
      },
    );
  }

  void _completeOnboarding() async {
    await ref.read(abTestServiceProvider).trackConversion(
      experimentId: 'onboarding_flow_test',
      conversionType: 'onboarding_completed',
    );
    // 홈으로 이동...
  }

  void _skipOnboarding() async {
    await ref.read(abTestServiceProvider).trackConversion(
      experimentId: 'onboarding_flow_test',
      conversionType: 'onboarding_skipped',
    );
    // 홈으로 이동...
  }
}
```

#### 예제 3: 운세 카드 디자인 테스트

```dart
// 1. 실험 정의
abTestService.registerExperiment(
  ABTestExperiment(
    id: 'fortune_card_design',
    name: '운세 카드 디자인',
    description: '카드 스타일과 애니메이션 테스트',
    variants: [
      const ControlVariant(parameters: {
        'style': 'modern',
        'animation': true,
        'shadow': true,
      }),
      const ABTestVariant(
        id: 'minimal',
        name: '미니멀',
        parameters: {
          'style': 'minimal',
          'animation': false,
          'shadow': false,
        },
        weight: 0.33,
      ),
      const ABTestVariant(
        id: 'premium',
        name: '프리미엄',
        parameters: {
          'style': 'premium',
          'animation': true,
          'shadow': true,
          'gradient': true,
        },
        weight: 0.33,
      ),
    ],
    startDate: DateTime.now(),
  ),
);

// 2. 카드 위젯에서 사용
class FortuneCard extends ConsumerWidget {
  final Fortune fortune;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ABTestWidget(
      experimentId: 'fortune_card_design',
      builder: (context, variant) {
        final style = variant.getParameter<String>('style') ?? 'modern';
        final hasAnimation = variant.getParameter<bool>('animation') ?? true;
        final hasShadow = variant.getParameter<bool>('shadow') ?? true;
        final hasGradient = variant.getParameter<bool>('gradient') ?? false;

        Widget card = Container(
          decoration: BoxDecoration(
            color: _getCardColor(style),
            borderRadius: BorderRadius.circular(16),
            boxShadow: hasShadow ? [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ] : null,
            gradient: hasGradient ? LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            ) : null,
          ),
          child: FortuneContent(fortune: fortune),
        );

        if (hasAnimation) {
          card = AnimatedContainer(
            duration: Duration(milliseconds: 300),
            child: card,
          );
        }

        return GestureDetector(
          onTap: () async {
            // 카드 클릭 추적
            await ref.read(abTestServiceProvider).trackConversion(
              experimentId: 'fortune_card_design',
              conversionType: 'card_interaction',
              additionalData: {'style': style},
            );
          },
          child: card,
        );
      },
    );
  }

  Color _getCardColor(String style) {
    switch (style) {
      case 'minimal': return Colors.white;
      case 'premium': return Color(0xFF1A1A2E);
      default: return Color(0xFF2D2D44);
    }
  }
}
```

### 3.2 실험 설계 베스트 프랙티스

#### 실험 설계 원칙
1. **한 번에 하나의 변수만 테스트**: 명확한 인과관계 파악
2. **명확한 가설 설정**: 측정 가능한 가설 작성
3. **충분한 샘플 크기 확보**: 통계적 유의성 확보
4. **계절성 고려**: 주말/주중, 월초/월말 패턴 고려

#### 사용자 경험 고려사항
1. **일관된 경험 제공**: 실험 중 사용자에게 일관된 변형 제공
2. **세션 내 변형 변경 방지**: 사용자 혼란 최소화
3. **중요 기능은 점진적 테스트**: 위험 최소화

#### 데이터 품질 관리
1. **이벤트 파라미터 검증**: 정확한 데이터 수집
2. **중복 이벤트 방지**: 데이터 정확성 유지
3. **정확한 타임스탬프 기록**: 시계열 분석 가능

#### 윤리적 고려사항
1. **사용자 프라이버시 보호**: 개인정보 보호 준수
2. **투명한 데이터 사용**: 사용자 동의 및 투명성
3. **부정적 영향 최소화**: 사용자 경험 저하 방지

### 3.3 측정 지표 설정

#### 주요 성과 지표 (KPI)
- **구독 전환율**: 구독 화면 조회 → 구독 구매
- **토큰 구매율**: 토큰 화면 조회 → 토큰 구매
- **ARPU**: 사용자당 평균 수익
- **리텐션**: D1, D7, D30 재방문율

#### 보조 지표
- **온보딩 완료율**: 시작 → 완료
- **운세 생성률**: 앱 열기 → 운세 생성
- **공유율**: 운세 생성 → 공유
- **평균 세션 시간**: 사용자당 평균 사용 시간

---

## 4. 테스트 및 디버깅

### 4.1 개발자 대시보드

```dart
// 개발자 설정 페이지에 추가
class DeveloperSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('개발자 설정')),
      body: ListView(
        children: [
          ListTile(
            title: Text('AB 테스트 대시보드'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ABTestDashboard(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

### 4.2 디버그 모드

개발 중에는 특정 변형을 강제로 설정할 수 있습니다:

```dart
// 디버그 모드에서만 작동
if (kDebugMode) {
  await ABTestService.instance.forceVariant(
    'payment_ui_test',
    'variant_b',
  );
}

// 실험 데이터 초기화
await ABTestService.instance.reset();

// 테스트 계정은 실험에서 제외
if (isTestAccount) {
  return ControlVariant();
}
```

### 4.3 Analytics DebugView 사용

#### Android
```bash
adb shell setprop debug.firebase.analytics.app com.beyond.ondo
```

#### iOS
Xcode에서 실행 시 Arguments에 추가:
```
-FIRAnalyticsDebugEnabled
```

#### 실시간 이벤트 모니터링
1. Firebase Console → Analytics → DebugView
2. 앱에서 이벤트 발생
3. 실시간으로 이벤트 확인

### 4.4 Remote Config 새로고침

```dart
// Remote Config가 업데이트되지 않는 경우
await RemoteConfigService().refresh();
```

### 4.5 Firebase Console에서 이벤트 확인

1. **Analytics** → **이벤트** 메뉴
2. 다음 이벤트들이 표시되는지 확인:
   - `ab_test_exposure`
   - `ab_test_conversion`
   - `payment_ui_test`
   - `onboarding_test`
   - `fortune_card_ui_test`
   - `token_pricing_test`

---

## 5. 결과 분석

### 5.1 대시보드 지표

대시보드에서 확인할 수 있는 지표:

1. **노출 수 (Impressions)**: 각 변형을 본 사용자 수
2. **전환 수 (Conversions)**: 목표 행동을 완료한 사용자 수
3. **전환율 (Conversion Rate)**: 전환/노출 비율
4. **통계적 유의성**: 95% 이상이면 결과를 신뢰할 수 있음
5. **개선율 (Uplift)**: Control 대비 개선 정도

### 5.2 A/B Testing 대시보드 분석

#### 개요 섹션
- 실험 진행 상황
- 참여자 수
- 실험 기간

#### 목표 메트릭
- 전환율 변화
- 수익 변화
- 통계적 유의성

#### 변형별 성과
- 각 변형의 성과 비교
- 세그먼트별 분석
- 시간별 추이

### 5.3 통계적 유의성

- **신뢰도**: 95% 이상 권장
- **최소 샘플 크기**: 변형당 최소 500명
- **실행 기간**: 최소 1주일
- **충분한 샘플 수집**: 최소 30개 이상의 전환

### 5.4 승자 선택 프로세스

1. **통계적 유의성 확인**: 95% 이상 신뢰도
2. **비즈니스 목표와 일치 확인**: KPI 개선 여부
3. **부작용 검토**: 다른 메트릭 영향 분석
4. **점진적 롤아웃 고려**: 리스크 최소화

---

## 6. 구현 체크리스트

### 6.1 현재 구현 상태

#### ✅ 완료된 작업

**1. 기반 시스템**
- [x] Firebase A/B Testing 가이드 문서 작성
- [x] Remote Config 서비스 구현 (`remote_config_service.dart`)
- [x] A/B Test Manager 구현 (`ab_test_manager.dart`)
- [x] 이벤트 상수 정의 (`ab_test_events.dart`)

**2. 결제 시스템 A/B 테스트**
- [x] 토큰 구매 페이지 A/B 테스트 버전 구현
- [x] 4가지 레이아웃 변형 지원 (Split, Unified, Subscription first, Token first)
- [x] 동적 가격 설정
- [x] 이벤트 추적 통합

**3. 온보딩 A/B 테스트**
- [x] 온보딩 플로우 A/B 테스트 버전 구현
- [x] 4가지 플로우 변형 지원 (Standard, Simplified, Detailed, Progressive)
- [x] 스킵 가능 옵션
- [x] 완료율 추적

### 6.2 앞으로 구현해야 할 작업

#### 📋 Phase 1: Firebase 설정 (1주차)
- [ ] Firebase Console에서 A/B Testing 활성화
- [ ] Remote Config 기본값 설정
- [ ] Analytics 이벤트 검증
- [ ] 사용자 속성 설정
- [ ] 기존 구독 페이지 마이그레이션
- [ ] 첫 실험 시작 (구독 가격 테스트)

#### 📋 Phase 2: 주요 페이지 테스트 (2주차)
- [ ] 홈 화면 A/B 테스트 구현
  - [ ] 홈 화면 레이아웃 테스트
  - [ ] 추천 운세 알고리즘 테스트
  - [ ] CTA 버튼 위치/스타일 테스트
- [ ] 운세 카드 레이아웃 A/B 테스트
  - [ ] 애니메이션 활성화/비활성화 옵션
  - [ ] UI 스타일 변형 (modern/classic/minimal)
- [ ] 토큰 보너스 테스트

#### 📋 Phase 3: 추가 기능 테스트 (3주차)
- [ ] 추천 시스템 A/B 테스트
- [ ] 일일 무료 토큰 테스트
- [ ] 성능 모니터링 구현
  - [ ] 화면 로드 시간 추적
  - [ ] API 응답 시간 측정
  - [ ] 이탈률 모니터링
  - [ ] 전환율 실시간 추적

#### 📋 Phase 4: 자동화 및 최적화 (4주차)
- [ ] A/B 테스트 시뮬레이터 구현
- [ ] 통계적 유의성 계산기
- [ ] 자동 리포트 생성
- [ ] 테스트 결과 분석 및 승리 변형 적용
- [ ] 다음 실험 계획 수립

### 6.3 새로운 A/B 테스트 시나리오

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

### 6.4 개발 가이드라인

#### 새로운 기능 개발 시
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

#### 코드 리뷰 체크리스트
- [ ] Remote Config 값 사용 여부
- [ ] 하드코딩된 값 제거
- [ ] 이벤트 추적 구현
- [ ] A/B 테스트 문서 업데이트

### 6.5 실험 문서화 템플릿

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

### 6.6 정기 점검 항목

#### 주간
- [ ] 실험 진행 상황 확인
- [ ] 이상 징후 모니터링
- [ ] 샘플 크기 확인

#### 월간
- [ ] 실험 결과 분석
- [ ] 승리 변형 적용
- [ ] 다음 실험 계획

#### 분기별
- [ ] A/B 테스트 전략 검토
- [ ] 프로세스 개선
- [ ] 팀 교육

---

## 7. 문제 해결

### 7.1 이벤트가 표시되지 않을 때
1. Analytics 초기화 확인
2. 네트워크 연결 확인
3. 이벤트 이름/파라미터 검증
4. DebugView에서 확인

### 7.2 Remote Config 값이 업데이트되지 않을 때
1. 최소 fetch 간격 확인 (개발: 0, 프로덕션: 1시간)
2. 활성화 호출 확인
3. 캐시 정리 후 재시도

### 7.3 A/B 테스트 결과가 예상과 다를 때
1. 샘플 크기 확인
2. 실험 기간 연장
3. 세그먼트별 분석
4. 외부 요인 검토

---

## 8. 베스트 프랙티스 요약

### ⚡ 핵심 원칙
1. **충분한 샘플 수집**: 최소 30개 이상의 전환이 있어야 통계적 유의성 계산 가능
2. **한 번에 하나씩**: 여러 실험을 동시에 진행하면 결과 해석이 어려움
3. **명확한 목표 설정**: 전환 이벤트를 명확히 정의
4. **충분한 실험 기간**: 최소 1주일 이상 실행 권장
5. **세그먼트 분석**: 사용자 그룹별로 다른 결과가 나올 수 있음

### 📚 참고 자료
- [Firebase A/B Testing 문서](https://firebase.google.com/docs/ab-testing)
- [Firebase Analytics 문서](https://firebase.google.com/docs/analytics)
- [Firebase Remote Config 문서](https://firebase.google.com/docs/remote-config)
- [A/B 테스트 베스트 프랙티스](https://firebase.google.com/docs/ab-testing/abtest-best-practices)

---

이 가이드를 참고하여 체계적으로 A/B 테스트를 구현하고 관리하세요!