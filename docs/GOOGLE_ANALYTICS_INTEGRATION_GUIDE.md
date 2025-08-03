# Google Analytics Integration Guide for Fortune App

## 📊 개요

Fortune 앱은 Firebase Analytics(Google Analytics for Firebase)를 통해 모든 사용자 동선을 추적합니다. 웹과 앱(iOS/Android) 모두에서 동일한 방식으로 작동합니다.

---

## 🏗️ 아키텍처

### 1. 3계층 Analytics 구조

```
┌─────────────────────────────────────────┐
│          Analytics Tracker              │ ← 통합 추적 레이어
├─────────────────────────────────────────┤
│   AB Test Manager  │  Analytics Service │ ← 개별 서비스 레이어
├─────────────────────────────────────────┤
│         Firebase Analytics SDK          │ ← Firebase SDK
└─────────────────────────────────────────┘
```

### 2. 주요 컴포넌트

- **AnalyticsTracker**: 통합 추적 서비스
- **AnalyticsService**: Firebase Analytics 래퍼
- **ABTestManager**: A/B 테스트 및 이벤트 관리
- **AnalyticsAwareWidget**: 자동 화면 추적 위젯

---

## 🚀 설정 방법

### 1. Firebase 프로젝트 설정

```bash
# Firebase CLI 설치
npm install -g firebase-tools

# Firebase 로그인
firebase login

# 프로젝트 초기화
firebase init
```

### 2. 플랫폼별 설정

#### Android
```xml
<!-- android/app/google-services.json 추가 -->
<!-- android/build.gradle -->
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
}
```

#### iOS
```ruby
# ios/Runner/GoogleService-Info.plist 추가
# ios/Podfile
pod 'Firebase/Analytics'
```

#### Web
```html
<!-- web/index.html -->
<script>
  // Firebase 설정
  const firebaseConfig = {
    apiKey: "...",
    authDomain: "...",
    projectId: "...",
    storageBucket: "...",
    messagingSenderId: "...",
    appId: "...",
    measurementId: "G-XXXXXXXXXX"
  };
</script>
```

---

## 📱 구현 가이드

### 1. 앱 초기화

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 초기화
  await Firebase.initializeApp();
  
  // Analytics 초기화
  final analytics = AnalyticsService();
  await analytics.initialize();
  
  // Remote Config 초기화
  final remoteConfig = RemoteConfigService();
  await remoteConfig.initialize();
  
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### 2. 자동 화면 추적

```dart
// 모든 화면에 AnalyticsAwareWidget 사용
class HomeScreen extends AnalyticsAwareWidget {
  const HomeScreen({super.key}) : super(
    screenName: 'home_screen',
    screenClass: 'HomeScreen',
  );
  
  @override
  AnalyticsAwareState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends AnalyticsAwareState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 버튼 클릭 추적
          ElevatedButton(
            onPressed: () {
              // 자동으로 화면 정보와 함께 추적
              trackAction(
                action: 'button_click',
                target: 'fortune_generate',
              );
              
              // 네비게이션
              context.push('/fortune/daily');
            },
            child: Text('오늘의 운세'),
          ),
        ],
      ),
    );
  }
}
```

### 3. 사용자 동선 추적

```dart
// 전체 사용자 플로우 자동 추적
class FortuneGenerationFlow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracker = ref.read(analyticsTrackerProvider);
    
    return Stepper(
      onStepContinue: () {
        // 각 단계 자동 추적
        tracker.trackFunnelStep(
          funnelName: 'fortune_generation',
          step: currentStep,
          stepName: stepNames[currentStep],
        );
      },
      steps: [
        Step(title: Text('운세 선택')),
        Step(title: Text('정보 입력')),
        Step(title: Text('결과 확인')),
      ],
    );
  }
}
```

### 4. 전환 추적

```dart
// 구독 전환 추적
void handleSubscriptionPurchase() async {
  final tracker = ref.read(analyticsTrackerProvider);
  
  try {
    final result = await purchaseSubscription();
    
    // 전환 추적 (사용자 동선 포함)
    await tracker.trackConversion(
      conversionType: 'subscription',
      value: 2500,
      currency: 'KRW',
      parameters: {
        'plan': 'monthly',
        'source': 'token_purchase_page',
      },
    );
  } catch (e) {
    // 에러 추적
    await tracker.trackError(
      errorType: 'purchase_failed',
      errorMessage: e.toString(),
    );
  }
}
```

### 5. 가시성 추적

```dart
// 리스트 아이템 노출 추적
ListView.builder(
  itemBuilder: (context, index) {
    return AnalyticsVisibilityDetector(
      itemId: fortunes[index].id,
      itemType: 'fortune_card',
      parameters: {
        'fortune_type': fortunes[index].type,
        'position': index,
      },
      child: FortuneCard(fortune: fortunes[index]),
    );
  },
);
```

### 6. 스크롤 깊이 추적

```dart
// 스크롤 추적
AnalyticsScrollTracker(
  scrollAreaName: 'fortune_list',
  scrollThreshold: 0.9, // 90% 스크롤 시 추적
  child: ListView(
    children: fortuneCards,
  ),
);
```

---

## 📊 주요 추적 이벤트

### 1. 화면 조회 (자동)
- `screen_view`: 모든 화면 진입
- `screen_exit`: 화면 이탈 및 체류 시간

### 2. 사용자 행동
- `user_action`: 버튼 클릭, 스와이프 등
- `scroll_depth_reached`: 스크롤 깊이
- `item_impression`: 아이템 노출

### 3. 전환 이벤트
- `conversion`: 구독, 토큰 구매
- `sign_up`: 회원가입
- `first_fortune_generated`: 첫 운세 생성

### 4. 퍼널 이벤트
- `funnel_step`: 각 단계별 진행률
- `funnel_complete`: 퍼널 완료
- `funnel_abandon`: 이탈

---

## 📈 Google Analytics 콘솔에서 확인

### 1. 실시간 보고서
- 현재 활성 사용자
- 실시간 이벤트
- 화면별 사용자 분포

### 2. 사용자 동선 분석
```
홈 화면 → 운세 목록 → 타로 운세 → 결과 화면 → 공유
         ↓
      토큰 구매 → 구독 전환
```

### 3. 전환 퍼널
```
앱 설치 (100%)
    ↓
온보딩 시작 (95%)
    ↓
온보딩 완료 (80%)
    ↓
첫 운세 생성 (70%)
    ↓
토큰 구매 (20%)
    ↓
구독 전환 (5%)
```

### 4. A/B 테스트 결과
- 실험별 전환율
- 변형별 사용자 행동
- 통계적 유의성

---

## 🔧 디버깅

### 1. DebugView 활성화

#### Android
```bash
adb shell setprop debug.firebase.analytics.app com.beyond.fortune
```

#### iOS
```bash
# Xcode에서 -FIRDebugEnabled 추가
```

### 2. 로그 확인
```dart
// 개발 환경에서 로그 활성화
if (kDebugMode) {
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
}
```

---

## 📝 베스트 프랙티스

### 1. 이벤트 네이밍
```dart
// ✅ Good
'button_click'
'fortune_generated'
'subscription_purchased'

// ❌ Bad
'btn_clk'
'event1'
'user_did_something'
```

### 2. 파라미터 제한
- 이벤트당 최대 25개 파라미터
- 파라미터 이름: 최대 40자
- 파라미터 값: 최대 100자

### 3. 사용자 속성
```dart
// 초기 설정
tracker.setUserProperties(
  userId: user.id,
  isPremium: user.isPremium,
  gender: user.gender,
  birthYear: user.birthYear,
  mbti: user.mbti,
);
```

### 4. 개인정보 보호
- PII(개인식별정보) 전송 금지
- 민감한 정보 해싱 처리
- GDPR/CCPA 준수

---

## 🚨 주의사항

### 1. 할당량
- 일일 이벤트: 500만 개
- 고유 이벤트: 500개
- 사용자 속성: 25개

### 2. 데이터 지연
- 실시간: 몇 초
- 표준 보고서: 24시간

### 3. 데이터 보관
- 무료: 14개월
- Analytics 360: 50개월

---

## 📊 대시보드 설정

### 1. 주요 지표
- DAU/MAU
- 평균 세션 시간
- 화면별 전환율
- 수익 지표

### 2. 커스텀 보고서
- 사용자 동선 분석
- 코호트 분석
- 퍼널 분석
- A/B 테스트 결과

### 3. 알림 설정
- 전환율 하락
- 에러율 증가
- 트래픽 급증

---

이 가이드를 따라 Google Analytics를 완벽하게 통합하면, 웹과 앱 모두에서 사용자 행동을 정확하게 추적하고 분석할 수 있습니다.