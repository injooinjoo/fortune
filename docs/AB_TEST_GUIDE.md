# Firebase AB 테스트 사용 가이드

## 🚀 빠른 시작

### 1. 실험 정의하기

```dart
// main.dart 또는 앱 초기화 시점에서
void setupABTests() {
  final abTestService = ABTestService.instance;
  
  // 예시 1: 홈 화면 레이아웃 테스트
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

### 2. UI에서 AB 테스트 적용하기

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

### 3. 전환 이벤트 추적하기

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

### 4. 실험 결과 확인하기

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

## 📊 실전 예제

### 예제 1: 토큰 가격 테스트

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

### 예제 2: 온보딩 플로우 테스트

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

### 예제 3: 운세 카드 디자인 테스트

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

## 🔬 디버그 모드

개발 중에는 특정 변형을 강제로 설정할 수 있습니다:

```dart
// 디버그 모드에서만 작동
if (kDebugMode) {
  await ABTestService.instance.forceVariant(
    'payment_ui_test',
    'variant_b',
  );
}
```

## 📈 결과 분석

대시보드에서 확인할 수 있는 지표:

1. **노출 수 (Impressions)**: 각 변형을 본 사용자 수
2. **전환 수 (Conversions)**: 목표 행동을 완료한 사용자 수
3. **전환율 (Conversion Rate)**: 전환/노출 비율
4. **통계적 유의성**: 95% 이상이면 결과를 신뢰할 수 있음
5. **개선율 (Uplift)**: Control 대비 개선 정도

## ⚡ 베스트 프랙티스

1. **충분한 샘플 수집**: 최소 30개 이상의 전환이 있어야 통계적 유의성 계산 가능
2. **한 번에 하나씩**: 여러 실험을 동시에 진행하면 결과 해석이 어려움
3. **명확한 목표 설정**: 전환 이벤트를 명확히 정의
4. **충분한 실험 기간**: 최소 1주일 이상 실행 권장
5. **세그먼트 분석**: 사용자 그룹별로 다른 결과가 나올 수 있음

## 🛠️ 문제 해결

### Remote Config가 업데이트되지 않는 경우
```dart
await RemoteConfigService().refresh();
```

### 실험 데이터 초기화
```dart
await ABTestService.instance.reset();
```

### 특정 사용자 제외
```dart
// 테스트 계정은 실험에서 제외
if (isTestAccount) {
  return ControlVariant();
}
```