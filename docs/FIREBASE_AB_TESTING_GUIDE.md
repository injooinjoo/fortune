# Firebase A/B Testing Guide for Fortune App

## 목차
1. [개요](#개요)
2. [Firebase 설정](#firebase-설정)
3. [Flutter 통합](#flutter-통합)
4. [A/B 테스트 전략](#ab-테스트-전략)
5. [구현 가이드](#구현-가이드)
6. [테스트 시나리오](#테스트-시나리오)
7. [모니터링 및 분석](#모니터링-및-분석)
8. [베스트 프랙티스](#베스트-프랙티스)

---

## 개요

Fortune 앱에서 Firebase A/B Testing을 활용하여 사용자 경험을 최적화하고 전환율을 개선합니다.

### 주요 목표
- 구독 전환율 최적화
- 토큰 구매 증가
- 사용자 참여도 향상
- 운세 이용률 증가

---

## Firebase 설정

### 1. Firebase Console 설정
```
1. Firebase Console > A/B Testing 활성화
2. Remote Config 설정
3. Analytics 이벤트 정의
4. 사용자 속성 설정
```

### 2. 필수 이벤트 정의
```dart
// 추적할 주요 이벤트
const Map<String, String> firebaseEvents = {
  // 구독 관련
  'subscription_screen_view': '구독 화면 조회',
  'subscription_plan_selected': '구독 플랜 선택',
  'subscription_purchased': '구독 구매 완료',
  'subscription_cancelled': '구독 취소',
  
  // 토큰 관련
  'token_purchase_screen_view': '토큰 구매 화면 조회',
  'token_package_selected': '토큰 패키지 선택',
  'token_purchased': '토큰 구매 완료',
  
  // 운세 관련
  'fortune_type_selected': '운세 종류 선택',
  'fortune_generated': '운세 생성',
  'fortune_shared': '운세 공유',
  
  // 온보딩
  'onboarding_started': '온보딩 시작',
  'onboarding_completed': '온보딩 완료',
  'onboarding_skipped': '온보딩 스킵',
};
```

---

## Flutter 통합

### 1. 의존성 추가
```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^3.15.1
  firebase_analytics: ^11.5.2
  firebase_remote_config: ^5.0.0
  firebase_ab_testing: ^1.0.0  # 커스텀 패키지
```

### 2. Remote Config 서비스
```dart
// lib/services/remote_config_service.dart
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  late FirebaseRemoteConfig _remoteConfig;
  
  // A/B 테스트 파라미터
  static const String subscriptionPriceKey = 'subscription_price';
  static const String subscriptionTitleKey = 'subscription_title';
  static const String subscriptionFeaturesKey = 'subscription_features';
  static const String tokenBonusRateKey = 'token_bonus_rate';
  static const String onboardingFlowKey = 'onboarding_flow';
  static const String fortuneUIStyleKey = 'fortune_ui_style';
  static const String paymentUILayoutKey = 'payment_ui_layout';
  
  Future<void> initialize() async {
    _remoteConfig = FirebaseRemoteConfig.instance;
    
    // 기본값 설정
    await _remoteConfig.setDefaults({
      subscriptionPriceKey: 2500,
      subscriptionTitleKey: '무제한 이용권',
      subscriptionFeaturesKey: json.encode([
        '모든 운세 무제한 이용',
        '광고 제거',
        '우선 고객 지원',
        '프리미엄 기능 이용',
      ]),
      tokenBonusRateKey: 1.0,
      onboardingFlowKey: 'standard',
      fortuneUIStyleKey: 'modern',
      paymentUILayoutKey: 'split',
    });
    
    // 설정
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    
    // 가져오기 및 활성화
    await _remoteConfig.fetchAndActivate();
  }
  
  // 구독 가격 가져오기
  int getSubscriptionPrice() {
    return _remoteConfig.getInt(subscriptionPriceKey);
  }
  
  // 구독 제목 가져오기
  String getSubscriptionTitle() {
    return _remoteConfig.getString(subscriptionTitleKey);
  }
  
  // 구독 기능 목록 가져오기
  List<String> getSubscriptionFeatures() {
    final featuresJson = _remoteConfig.getString(subscriptionFeaturesKey);
    return List<String>.from(json.decode(featuresJson));
  }
  
  // 토큰 보너스 비율 가져오기
  double getTokenBonusRate() {
    return _remoteConfig.getDouble(tokenBonusRateKey);
  }
  
  // 온보딩 플로우 타입 가져오기
  String getOnboardingFlow() {
    return _remoteConfig.getString(onboardingFlowKey);
  }
  
  // 운세 UI 스타일 가져오기
  String getFortuneUIStyle() {
    return _remoteConfig.getString(fortuneUIStyleKey);
  }
  
  // 결제 UI 레이아웃 가져오기
  String getPaymentUILayout() {
    return _remoteConfig.getString(paymentUILayoutKey);
  }
}

// Provider
final remoteConfigProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService();
});
```

### 3. A/B 테스트 매니저
```dart
// lib/services/ab_test_manager.dart
import 'package:firebase_analytics/firebase_analytics.dart';

class ABTestManager {
  static final ABTestManager _instance = ABTestManager._internal();
  factory ABTestManager() => _instance;
  ABTestManager._internal();
  
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  // 실험 그룹 설정
  Future<void> setExperimentGroup(String experimentName, String variant) async {
    await _analytics.setUserProperty(
      name: 'experiment_$experimentName',
      value: variant,
    );
  }
  
  // 이벤트 로깅 with A/B 테스트 정보
  Future<void> logEventWithABTest({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    final params = parameters ?? {};
    
    // Remote Config 값들 추가
    final remoteConfig = RemoteConfigService();
    params['subscription_price_variant'] = remoteConfig.getSubscriptionPrice();
    params['payment_ui_variant'] = remoteConfig.getPaymentUILayout();
    params['onboarding_flow_variant'] = remoteConfig.getOnboardingFlow();
    
    await _analytics.logEvent(
      name: eventName,
      parameters: params,
    );
  }
  
  // 전환 이벤트 로깅
  Future<void> logConversion({
    required String conversionType,
    required dynamic value,
    Map<String, dynamic>? additionalParams,
  }) async {
    final params = additionalParams ?? {};
    params['conversion_type'] = conversionType;
    params['conversion_value'] = value;
    
    await logEventWithABTest(
      eventName: 'conversion',
      parameters: params,
    );
  }
}
```

---

## A/B 테스트 전략

### 1. 구독 가격 테스트
```dart
// 테스트 변형
const subscriptionPriceVariants = {
  'control': 2500,      // 기본
  'variant_a': 1900,    // 낮은 가격
  'variant_b': 3900,    // 높은 가격
  'variant_c': 2900,    // 중간 가격
};

// 가설: 낮은 가격이 전환율을 높일 것이다
// 측정 지표: 구독 전환율, LTV, 이탈률
```

### 2. 온보딩 플로우 테스트
```dart
// 테스트 변형
const onboardingFlowVariants = {
  'standard': ['name', 'birthdate', 'gender', 'complete'],
  'simplified': ['name', 'complete'],
  'detailed': ['name', 'birthdate', 'gender', 'mbti', 'location', 'complete'],
  'progressive': ['name', 'complete', 'later_prompts'],
};

// 가설: 간단한 온보딩이 완료율을 높일 것이다
// 측정 지표: 온보딩 완료율, 7일 리텐션
```

### 3. 결제 UI 레이아웃 테스트
```dart
// 테스트 변형
const paymentUIVariants = {
  'split': 'subscription_and_tokens_separated',
  'unified': 'all_options_together',
  'subscription_first': 'subscription_prominent',
  'token_first': 'tokens_prominent',
};

// 가설: 구독을 강조하면 구독 전환율이 높아질 것이다
// 측정 지표: 구독 전환율, 토큰 구매율
```

---

## 구현 가이드

### 1. 구독 페이지 A/B 테스트 적용
```dart
// lib/screens/subscription/subscription_page.dart
class SubscriptionPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remoteConfig = ref.watch(remoteConfigProvider);
    final abTestManager = ABTestManager();
    
    // A/B 테스트 값 가져오기
    final subscriptionPrice = remoteConfig.getSubscriptionPrice();
    final subscriptionTitle = remoteConfig.getSubscriptionTitle();
    final subscriptionFeatures = remoteConfig.getSubscriptionFeatures();
    
    // 화면 조회 이벤트
    abTestManager.logEventWithABTest(
      eventName: 'subscription_screen_view',
      parameters: {
        'screen_name': 'subscription_page',
      },
    );
    
    return Scaffold(
      body: Column(
        children: [
          // 동적 가격 표시
          Text(
            '₩${NumberFormat('#,###').format(subscriptionPrice)}/월',
            style: AppTextStyles.heading1,
          ),
          
          // 동적 제목
          Text(
            subscriptionTitle,
            style: AppTextStyles.heading2,
          ),
          
          // 동적 기능 목록
          ...subscriptionFeatures.map((feature) => 
            ListTile(
              leading: Icon(Icons.check),
              title: Text(feature),
            ),
          ),
          
          // 구매 버튼
          ElevatedButton(
            onPressed: () => _handlePurchase(subscriptionPrice),
            child: Text('구독하기'),
          ),
        ],
      ),
    );
  }
  
  void _handlePurchase(int price) async {
    // 구매 시작 이벤트
    await ABTestManager().logEventWithABTest(
      eventName: 'subscription_plan_selected',
      parameters: {
        'price': price,
        'plan_type': 'monthly',
      },
    );
    
    // 구매 로직...
  }
}
```

### 2. 토큰 구매 페이지 A/B 테스트
```dart
// lib/features/payment/presentation/pages/token_purchase_page_v2.dart
class TokenPurchasePageV2 extends ConsumerStatefulWidget {
  @override
  ConsumerState<TokenPurchasePageV2> createState() => _TokenPurchasePageV2State();
}

class _TokenPurchasePageV2State extends ConsumerState<TokenPurchasePageV2> {
  @override
  Widget build(BuildContext context) {
    final remoteConfig = ref.watch(remoteConfigProvider);
    final paymentLayout = remoteConfig.getPaymentUILayout();
    
    // 레이아웃에 따른 UI 변경
    switch (paymentLayout) {
      case 'split':
        return _buildSplitLayout();
      case 'unified':
        return _buildUnifiedLayout();
      case 'subscription_first':
        return _buildSubscriptionFirstLayout();
      case 'token_first':
        return _buildTokenFirstLayout();
      default:
        return _buildSplitLayout();
    }
  }
  
  Widget _buildSplitLayout() {
    // 구독과 토큰 구매 분리된 레이아웃
    return Column(
      children: [
        _buildSubscriptionSection(),
        SizedBox(height: 24),
        _buildTokenSection(),
      ],
    );
  }
  
  Widget _buildSubscriptionSection() {
    final remoteConfig = ref.watch(remoteConfigProvider);
    final price = remoteConfig.getSubscriptionPrice();
    final title = remoteConfig.getSubscriptionTitle();
    
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text('₩${NumberFormat('#,###').format(price)}/월'),
        trailing: ElevatedButton(
          onPressed: _handleSubscriptionPurchase,
          child: Text('구독하기'),
        ),
      ),
    );
  }
  
  void _handleSubscriptionPurchase() async {
    final price = ref.read(remoteConfigProvider).getSubscriptionPrice();
    
    await ABTestManager().logEventWithABTest(
      eventName: 'subscription_purchased',
      parameters: {
        'price': price,
        'source': 'token_purchase_page',
      },
    );
    
    // 구매 처리...
  }
}
```

### 3. 온보딩 A/B 테스트
```dart
// lib/screens/onboarding/enhanced_onboarding_flow.dart
class EnhancedOnboardingFlow extends ConsumerStatefulWidget {
  @override
  ConsumerState<EnhancedOnboardingFlow> createState() => _EnhancedOnboardingFlowState();
}

class _EnhancedOnboardingFlowState extends ConsumerState<EnhancedOnboardingFlow> {
  late List<String> _steps;
  int _currentStep = 0;
  
  @override
  void initState() {
    super.initState();
    _initializeFlow();
  }
  
  void _initializeFlow() {
    final flowType = ref.read(remoteConfigProvider).getOnboardingFlow();
    
    switch (flowType) {
      case 'simplified':
        _steps = ['name', 'complete'];
        break;
      case 'detailed':
        _steps = ['name', 'birthdate', 'gender', 'mbti', 'location', 'complete'];
        break;
      case 'progressive':
        _steps = ['name', 'complete'];
        // 나중에 추가 정보 요청
        break;
      default:
        _steps = ['name', 'birthdate', 'gender', 'complete'];
    }
    
    // 온보딩 시작 이벤트
    ABTestManager().logEventWithABTest(
      eventName: 'onboarding_started',
      parameters: {
        'flow_type': flowType,
        'total_steps': _steps.length,
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentStep(),
    );
  }
  
  Widget _buildCurrentStep() {
    final step = _steps[_currentStep];
    
    switch (step) {
      case 'name':
        return NameStep(onComplete: _nextStep);
      case 'birthdate':
        return BirthDateStep(onComplete: _nextStep);
      case 'gender':
        return GenderStep(onComplete: _nextStep);
      case 'mbti':
        return MBTIStep(onComplete: _nextStep);
      case 'location':
        return LocationStep(onComplete: _nextStep);
      case 'complete':
        return CompleteStep(onComplete: _completeOnboarding);
      default:
        return Container();
    }
  }
  
  void _nextStep() {
    setState(() {
      _currentStep++;
    });
    
    // 각 단계 완료 추적
    ABTestManager().logEventWithABTest(
      eventName: 'onboarding_step_completed',
      parameters: {
        'step_name': _steps[_currentStep - 1],
        'step_number': _currentStep,
      },
    );
  }
  
  void _completeOnboarding() {
    // 온보딩 완료 이벤트
    ABTestManager().logEventWithABTest(
      eventName: 'onboarding_completed',
      parameters: {
        'flow_type': ref.read(remoteConfigProvider).getOnboardingFlow(),
        'completion_time': DateTime.now().toIso8601String(),
      },
    );
    
    // 홈으로 이동
    context.go('/home');
  }
}
```

---

## 테스트 시나리오

### 1. 구독 가격 실험
```yaml
experiment_name: subscription_price_test_v1
duration: 30 days
traffic_allocation: 100%
variants:
  - name: control
    percentage: 25%
    price: 2500
  - name: lower_price
    percentage: 25%
    price: 1900
  - name: higher_price
    percentage: 25%
    price: 3900
  - name: mid_price
    percentage: 25%
    price: 2900

success_metrics:
  primary:
    - subscription_conversion_rate
    - revenue_per_user
  secondary:
    - 7_day_retention
    - 30_day_retention
    - lifetime_value
```

### 2. 온보딩 플로우 실험
```yaml
experiment_name: onboarding_flow_test_v1
duration: 21 days
traffic_allocation: 100%
variants:
  - name: standard
    percentage: 25%
    steps: 4
  - name: simplified
    percentage: 25%
    steps: 2
  - name: detailed
    percentage: 25%
    steps: 6
  - name: progressive
    percentage: 25%
    steps: 2+delayed

success_metrics:
  primary:
    - onboarding_completion_rate
    - time_to_first_fortune
  secondary:
    - profile_completion_rate
    - 7_day_retention
```

### 3. 결제 UI 실험
```yaml
experiment_name: payment_ui_layout_test_v1
duration: 28 days
traffic_allocation: 100%
variants:
  - name: split_layout
    percentage: 25%
  - name: unified_layout
    percentage: 25%
  - name: subscription_first
    percentage: 25%
  - name: token_first
    percentage: 25%

success_metrics:
  primary:
    - subscription_conversion_rate
    - token_purchase_rate
  secondary:
    - average_revenue_per_user
    - purchase_abandonment_rate
```

---

## 모니터링 및 분석

### 1. 대시보드 설정
```dart
// Firebase Console에서 모니터링할 주요 지표
const dashboardMetrics = {
  'Conversion Funnel': [
    'app_open',
    'subscription_screen_view',
    'subscription_plan_selected',
    'subscription_purchased',
  ],
  
  'Revenue Metrics': [
    'subscription_revenue',
    'token_revenue',
    'total_revenue',
    'arpu',
  ],
  
  'Engagement Metrics': [
    'dau',
    'mau',
    'session_duration',
    'fortune_generated_per_user',
  ],
  
  'Retention Metrics': [
    'day_1_retention',
    'day_7_retention',
    'day_30_retention',
  ],
};
```

### 2. 실시간 모니터링
```dart
// lib/services/analytics_monitor.dart
class AnalyticsMonitor {
  static void trackExperimentHealth() {
    // 실험 상태 확인
    Timer.periodic(Duration(hours: 1), (timer) {
      _checkSampleSize();
      _checkStatisticalSignificance();
      _checkForAnomalies();
    });
  }
  
  static void _checkSampleSize() {
    // 각 변형의 샘플 크기 확인
    // 최소 샘플 크기 도달 여부 체크
  }
  
  static void _checkStatisticalSignificance() {
    // 통계적 유의성 계산
    // p-value < 0.05 체크
  }
  
  static void _checkForAnomalies() {
    // 이상 징후 감지
    // 급격한 지표 변화 알림
  }
}
```

---

## 베스트 프랙티스

### 1. 실험 설계 원칙
- **단일 변수 테스트**: 한 번에 하나의 변수만 테스트
- **충분한 샘플 크기**: 통계적 유의성을 위한 최소 샘플 확보
- **적절한 실험 기간**: 주기적 패턴을 고려한 기간 설정
- **명확한 가설**: 측정 가능한 가설 설정

### 2. 코드 구현 가이드
```dart
// ✅ Good: A/B 테스트 값 사용
final price = remoteConfig.getSubscriptionPrice();
Text('₩${NumberFormat('#,###').format(price)}');

// ❌ Bad: 하드코딩된 값
Text('₩2,500');

// ✅ Good: 이벤트 로깅
ABTestManager().logEventWithABTest(
  eventName: 'button_clicked',
  parameters: {'button_id': 'subscribe'},
);

// ❌ Bad: 이벤트 로깅 없음
onPressed: () => subscribe();
```

### 3. 실험 종료 후 처리
```dart
// 실험 결과에 따른 코드 정리
void cleanupExperiment(String experimentName) {
  switch (experimentName) {
    case 'subscription_price_test_v1':
      // 승리 변형을 기본값으로 설정
      // 다른 변형 코드 제거
      break;
  }
}
```

### 4. 문서화
- 모든 실험의 가설, 설정, 결과 문서화
- 학습 내용 공유
- 실패한 실험도 기록

---

## 다음 단계

1. Firebase Console에서 A/B Testing 활성화
2. Remote Config 기본값 설정
3. 첫 번째 실험 설계 및 실행
4. 결과 분석 및 반복

이 가이드를 따라 체계적으로 A/B 테스트를 진행하면 데이터 기반의 제품 개선이 가능합니다.