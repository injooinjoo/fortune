# 모니터링 도구 설정 가이드 📊

## 🎯 개요
Fortune 앱의 성능, 오류, 사용자 행동을 모니터링하기 위한 도구 설정 가이드입니다.

## 🔍 모니터링 도구 스택

### 1. Sentry (오류 추적)
- 실시간 오류 모니터링
- 성능 추적
- 릴리즈 상태 관리

### 2. Firebase Analytics (사용자 분석)
- 사용자 행동 추적
- 이벤트 분석
- 사용자 세그먼트

### 3. Firebase Crashlytics (크래시 리포트)
- 앱 크래시 자동 수집
- 실시간 알림
- 상세 스택 트레이스

### 4. Custom Monitoring (자체 구축)
- API 응답 시간
- 토큰 사용량
- 운세 조회 통계

## 🛠️ Sentry 설정

### 1. 프로젝트 생성
```bash
# Sentry CLI 설치
npm install -g @sentry/cli

# 로그인
sentry-cli login
```

### 2. Flutter 통합
```yaml
# pubspec.yaml
dependencies:
  sentry_flutter: ^8.11.1
```

### 3. 초기화 코드
```dart
// main.dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = const String.fromEnvironment('SENTRY_DSN');
      options.environment = const String.fromEnvironment('ENVIRONMENT');
      options.tracesSampleRate = 1.0;
      options.profilesSampleRate = 1.0;
      options.attachScreenshot = true;
      options.attachViewHierarchy = true;
      
      // 릴리즈 정보
      options.release = 'fortune@1.0.0+1';
      
      // 성능 모니터링
      options.enableAutoPerformanceTracing = true;
      
      // 사용자 정보 마스킹
      options.beforeSend = (event, hint) {
        // PII 제거
        if (event.user != null) {
          event.user = SentryUser(
            id: event.user!.id,
            // 이메일, 이름 등 제거
          );
        }
        return event;
      };
    },
    appRunner: () => runApp(const MyApp()),
  );
}
```

### 4. 오류 캡처
```dart
// 수동 오류 보고
try {
  // 위험한 작업
} catch (error, stackTrace) {
  await Sentry.captureException(
    error,
    stackTrace: stackTrace,
    withScope: (scope) {
      scope.setTag('feature', 'payment');
      scope.setContext('purchase', {
        'product_id': 'fortune_tokens_1000',
        'amount': 1200,
      });
    },
  );
}

// 메시지 로깅
Sentry.captureMessage(
  'Payment flow started',
  level: SentryLevel.info,
);
```

### 5. 성능 추적
```dart
// 트랜잭션 추적
final transaction = Sentry.startTransaction(
  'fortune-api-call',
  'http',
);

try {
  final response = await apiClient.getFortune();
  transaction.setData('fortune_type', response.type);
  transaction.status = const SpanStatus.ok();
} catch (e) {
  transaction.status = const SpanStatus.internalError();
  rethrow;
} finally {
  await transaction.finish();
}
```

## 📱 Firebase Analytics 설정

### 1. Firebase 프로젝트 설정
```bash
# Firebase CLI 설치
npm install -g firebase-tools

# 프로젝트 초기화
firebase init

# FlutterFire CLI
dart pub global activate flutterfire_cli
flutterfire configure
```

### 2. 패키지 추가
```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^3.15.1
  firebase_analytics: ^11.6.4
```

### 3. 이벤트 추적
```dart
// analytics_service.dart
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  // 화면 추적
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenName,
    );
  }
  
  // 운세 조회 이벤트
  Future<void> logFortuneView({
    required String fortuneType,
    required int tokensUsed,
    required bool isSuccess,
  }) async {
    await _analytics.logEvent(
      name: 'fortune_view',
      parameters: {
        'fortune_type': fortuneType,
        'tokens_used': tokensUsed,
        'is_success': isSuccess,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
  
  // 구매 이벤트
  Future<void> logPurchase({
    required String productId,
    required double price,
    required String currency,
  }) async {
    await _analytics.logPurchase(
      currency: currency,
      value: price,
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: productId,
          itemCategory: 'tokens',
          quantity: 1,
          price: price,
        ),
      ],
    );
  }
  
  // 사용자 속성
  Future<void> setUserProperties({
    required String userId,
    required String? birthYear,
    required String? gender,
  }) async {
    await _analytics.setUserId(id: userId);
    await _analytics.setUserProperty(
      name: 'birth_year',
      value: birthYear,
    );
    await _analytics.setUserProperty(
      name: 'gender',
      value: gender,
    );
  }
}
```

## 🚨 Firebase Crashlytics 설정

### 1. 패키지 추가
```yaml
dependencies:
  firebase_crashlytics: ^4.3.7
```

### 2. 초기화
```dart
// main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Crashlytics 설정
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  
  // 비동기 오류 캐치
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  
  runApp(const MyApp());
}
```

### 3. 커스텀 로깅
```dart
// 사용자 정보 설정
await FirebaseCrashlytics.instance.setUserIdentifier(userId);

// 커스텀 키
await FirebaseCrashlytics.instance.setCustomKey('fortune_type', 'daily');
await FirebaseCrashlytics.instance.setCustomKey('tokens_balance', 1500);

// 로그 메시지
FirebaseCrashlytics.instance.log('Fortune API call started');

// 비치명적 오류
await FirebaseCrashlytics.instance.recordError(
  error,
  stackTrace,
  reason: 'API timeout',
  fatal: false,
);
```

## 📊 커스텀 모니터링 시스템

### 1. API 응답 시간 모니터링
```dart
// api_monitor.dart
class ApiMonitor {
  static final _stopwatch = Stopwatch();
  
  static Future<T> measure<T>({
    required String endpoint,
    required Future<T> Function() operation,
  }) async {
    _stopwatch.reset();
    _stopwatch.start();
    
    try {
      final result = await operation();
      _stopwatch.stop();
      
      // 성공 로깅
      await _logApiCall(
        endpoint: endpoint,
        duration: _stopwatch.elapsedMilliseconds,
        status: 'success',
      );
      
      return result;
    } catch (error) {
      _stopwatch.stop();
      
      // 실패 로깅
      await _logApiCall(
        endpoint: endpoint,
        duration: _stopwatch.elapsedMilliseconds,
        status: 'error',
        error: error.toString(),
      );
      
      rethrow;
    }
  }
  
  static Future<void> _logApiCall({
    required String endpoint,
    required int duration,
    required String status,
    String? error,
  }) async {
    // Supabase에 저장
    await supabase.from('api_metrics').insert({
      'endpoint': endpoint,
      'duration_ms': duration,
      'status': status,
      'error': error,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
```

### 2. 토큰 사용량 추적
```dart
// token_monitor.dart
class TokenMonitor {
  static Future<void> trackUsage({
    required String userId,
    required String fortuneType,
    required int tokensUsed,
  }) async {
    await supabase.from('token_usage').insert({
      'user_id': userId,
      'fortune_type': fortuneType,
      'tokens_used': tokensUsed,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  static Future<Map<String, dynamic>> getDailyStats() async {
    final response = await supabase
        .from('token_usage')
        .select('fortune_type, sum(tokens_used)')
        .gte('timestamp', DateTime.now().subtract(Duration(days: 1)))
        .execute();
        
    return response.data;
  }
}
```

## 📈 대시보드 설정

### 1. Supabase 실시간 대시보드
```sql
-- 실시간 통계 뷰
CREATE VIEW app_statistics AS
SELECT 
  COUNT(DISTINCT user_id) as active_users,
  SUM(tokens_used) as total_tokens_used,
  AVG(duration_ms) as avg_api_response_time,
  COUNT(*) as total_api_calls
FROM (
  SELECT * FROM api_metrics 
  WHERE timestamp > NOW() - INTERVAL '24 hours'
) recent_metrics;
```

### 2. 알림 설정
```typescript
// Edge Function: monitoring-alerts
const checkThresholds = async () => {
  // API 응답 시간 체크
  const avgResponseTime = await getAvgResponseTime();
  if (avgResponseTime > 3000) {
    await sendAlert('API response time is slow: ' + avgResponseTime + 'ms');
  }
  
  // 오류율 체크
  const errorRate = await getErrorRate();
  if (errorRate > 0.05) {
    await sendAlert('High error rate: ' + (errorRate * 100) + '%');
  }
  
  // 토큰 사용량 급증 체크
  const tokenSpike = await checkTokenSpike();
  if (tokenSpike) {
    await sendAlert('Unusual token usage detected');
  }
};
```

## 🔔 알림 채널

### 1. Slack 통합
```dart
// slack_notifier.dart
class SlackNotifier {
  static const webhookUrl = String.fromEnvironment('SLACK_WEBHOOK_URL');
  
  static Future<void> sendAlert({
    required String title,
    required String message,
    required String severity,
  }) async {
    final color = severity == 'critical' ? '#FF0000' : '#FFA500';
    
    await http.post(
      Uri.parse(webhookUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'attachments': [{
          'color': color,
          'title': title,
          'text': message,
          'footer': 'Fortune Monitoring',
          'ts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        }],
      }),
    );
  }
}
```

### 2. 이메일 알림
```typescript
// 이메일 알림 설정
const sendEmailAlert = async (alert: Alert) => {
  await sendEmail({
    to: 'dev-team@fortune.com',
    subject: `[${alert.severity}] ${alert.title}`,
    html: `
      <h2>${alert.title}</h2>
      <p>${alert.message}</p>
      <p>Time: ${new Date().toISOString()}</p>
      <p>Environment: ${Deno.env.get('ENVIRONMENT')}</p>
    `,
  });
};
```

## 📊 모니터링 체크리스트

### 개발 환경
- [ ] Sentry DSN 설정
- [ ] Firebase 프로젝트 생성
- [ ] Analytics 이벤트 정의
- [ ] Crashlytics 활성화
- [ ] 로컬 테스트

### 스테이징 환경
- [ ] 환경별 설정 분리
- [ ] 알림 채널 테스트
- [ ] 대시보드 구성
- [ ] 임계값 설정

### 프로덕션 환경
- [ ] 실시간 모니터링 활성화
- [ ] 알림 규칙 설정
- [ ] 보고서 자동화
- [ ] 백업 계획

## 🚨 트러블슈팅

### Sentry 이벤트가 전송되지 않음
```dart
// DSN 확인
print('Sentry DSN: ${Sentry.dsn}');

// 네트워크 확인
await Sentry.flush(timeout: Duration(seconds: 5));
```

### Firebase Analytics 데이터 없음
- 24시간 대기 (첫 데이터)
- DebugView 활성화
- 이벤트 이름 규칙 확인

### 성능 저하
- 샘플링 비율 조정
- 배치 처리 활성화
- 로컬 캐싱 구현

---

**팁**: 모니터링은 앱의 건강 상태를 파악하는 핵심입니다. 적절한 알림 설정으로 문제를 조기에 발견하세요!