# 외부 서비스 설정 가이드

> Flutter 마이그레이션을 위한 외부 서비스 통합 문서
> 작성일: 2025년 1월 8일

## 📑 목차
1. [개요](#개요)
2. [OpenAI 설정](#openai-설정)
3. [Stripe 결제 설정](#stripe-결제-설정)
4. [TossPay 설정](#tosspay-설정)
5. [Redis/Upstash 설정](#redisupstash-설정)
6. [Google AdSense 설정](#google-adsense-설정)
7. [Supabase 설정](#supabase-설정)
8. [에러 모니터링](#에러-모니터링)
9. [Flutter 마이그레이션 가이드](#flutter-마이그레이션-가이드)

---

## 개요

Fortune 앱은 다양한 외부 서비스를 통합하여 AI 기반 운세 생성, 결제 처리, 캐싱, 광고 등의 기능을 제공합니다.

### 필수 서비스
- **OpenAI**: GPT-4.1-nano 모델을 통한 운세 생성
- **Stripe**: 국제 결제 처리
- **TossPay**: 한국 결제 처리
- **Redis/Upstash**: 캐싱 및 Rate Limiting
- **Supabase**: 인증 및 데이터베이스

---

## OpenAI 설정

### 1. API 키 설정
```env
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxxxxxxxxxx
```

### 2. 클라이언트 구현
```typescript
// src/lib/openai-client-improved.ts
export class OpenAIClient {
  private client: OpenAI;
  
  constructor() {
    this.client = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY,
      maxRetries: 3,
      timeout: 30000,
    });
  }
  
  async generateFortune(params: {
    systemPrompt: string;
    userPrompt: string;
    model?: string;
    temperature?: number;
  }) {
    const completion = await this.client.chat.completions.create({
      model: params.model || 'gpt-4.1-nano',
      messages: [
        { role: 'system', content: params.systemPrompt },
        { role: 'user', content: params.userPrompt }
      ],
      temperature: params.temperature || 0.7,
      response_format: { type: 'json_object' }
    });
    
    return JSON.parse(completion.choices[0].message.content);
  }
}
```

### 3. 프롬프트 전략
```typescript
// 시스템 프롬프트 예시
const SYSTEM_PROMPT = `당신은 한국의 전통 운세 전문가입니다. 
사용자의 생년월일, MBTI, 성별 등을 고려하여 개인화된 운세를 제공합니다.
응답은 반드시 다음 JSON 형식을 따라주세요:
{
  "title": "오늘의 운세",
  "overall_fortune": "전체 운세 설명",
  "categories": {
    "love": { "score": 85, "description": "애정운 설명" },
    "money": { "score": 70, "description": "금전운 설명" },
    "health": { "score": 90, "description": "건강운 설명" }
  },
  "lucky_items": {
    "number": 7,
    "color": "파란색",
    "direction": "동쪽"
  }
}`;
```

### 4. 토큰 사용량 추적
```typescript
// 토큰 사용량 기록
await supabase.from('token_usage').insert({
  user_id: userId,
  model: 'gpt-4.1-nano',
  prompt_tokens: usage.prompt_tokens,
  completion_tokens: usage.completion_tokens,
  total_cost: calculateCost(usage),
  fortune_type: fortuneType
});
```

### 5. Flutter 통합
```dart
// Flutter에서 OpenAI 사용
class OpenAIService {
  final String apiKey = dotenv.env['OPENAI_API_KEY']!;
  
  Future<FortuneResponse> generateFortune({
    required String fortuneType,
    required UserProfile userProfile,
  }) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4.1-nano',
        'messages': [
          {'role': 'system', 'content': getSystemPrompt()},
          {'role': 'user', 'content': getUserPrompt(userProfile)}
        ],
        'temperature': 0.7,
        'response_format': {'type': 'json_object'}
      }),
    );
    
    return FortuneResponse.fromJson(jsonDecode(response.body));
  }
}
```

---

## Stripe 결제 설정

### 1. 환경 변수
```env
# 테스트 환경
STRIPE_SECRET_KEY=sk_test_xxxxxxxxxxxxxxxxxxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxxxxxxxxxx

# 프로덕션 환경
STRIPE_SECRET_KEY=sk_live_xxxxxxxxxxxxxxxxxxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxxxxxxxxxx

# 가격 ID
STRIPE_PREMIUM_MONTHLY_PRICE_ID=price_xxxxxxxxxxxxx
STRIPE_PREMIUM_YEARLY_PRICE_ID=price_xxxxxxxxxxxxx
STRIPE_TOKEN_SMALL_PRICE_ID=price_xxxxxxxxxxxxx
STRIPE_TOKEN_MEDIUM_PRICE_ID=price_xxxxxxxxxxxxx
STRIPE_TOKEN_LARGE_PRICE_ID=price_xxxxxxxxxxxxx
```

### 2. 상품 설정
```typescript
// 상품 정의
const PRODUCTS = {
  subscriptions: {
    premium_monthly: {
      price: 9900,
      currency: 'krw',
      interval: 'month',
      features: ['무제한 운세', '광고 제거', '프리미엄 운세']
    },
    premium_yearly: {
      price: 99000,
      currency: 'krw',
      interval: 'year',
      features: ['2개월 무료', '무제한 운세', '광고 제거']
    }
  },
  tokens: {
    small: { amount: 10, price: 1000, bonus: 0 },
    medium: { amount: 60, price: 5000, bonus: 12 },
    large: { amount: 150, price: 10000, bonus: 50 }
  }
};
```

### 3. Webhook 처리
```typescript
// src/app/api/payment/webhook/stripe/route.ts
export async function POST(request: Request) {
  const sig = request.headers.get('stripe-signature')!;
  const body = await request.text();
  
  let event: Stripe.Event;
  
  try {
    event = stripe.webhooks.constructEvent(
      body,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET!
    );
  } catch (err) {
    return NextResponse.json({ error: 'Invalid signature' }, { status: 400 });
  }
  
  switch (event.type) {
    case 'checkout.session.completed':
      await handleCheckoutComplete(event.data.object);
      break;
    case 'customer.subscription.deleted':
      await handleSubscriptionCancelled(event.data.object);
      break;
    // 기타 이벤트 처리
  }
  
  return NextResponse.json({ received: true });
}
```

### 4. Flutter 통합
```dart
// pubspec.yaml
dependencies:
  flutter_stripe: ^10.0.0

// 초기화
void main() async {
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
  await Stripe.instance.applySettings();
  runApp(MyApp());
}

// 결제 처리
class PaymentService {
  Future<void> purchaseTokens(String packageId) async {
    // 1. 서버에서 Payment Intent 생성
    final response = await api.createPaymentIntent(packageId);
    
    // 2. Payment Sheet 표시
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: response.clientSecret,
        merchantDisplayName: 'Fortune App',
        customerId: response.customerId,
        style: ThemeMode.dark,
      ),
    );
    
    await Stripe.instance.presentPaymentSheet();
  }
}
```

---

## TossPay 설정

### 1. 환경 변수
```env
# 테스트 환경
TOSS_CLIENT_KEY=test_ck_xxxxxxxxxxxxxxxxxxxxx
TOSS_SECRET_KEY=test_sk_xxxxxxxxxxxxxxxxxxxxx

# 프로덕션 환경
TOSS_CLIENT_KEY=live_ck_xxxxxxxxxxxxxxxxxxxxx
TOSS_SECRET_KEY=live_sk_xxxxxxxxxxxxxxxxxxxxx
```

### 2. 결제 요청
```typescript
// 결제 창 호출
const tossPayments = await loadTossPayments(clientKey);

await tossPayments.requestPayment('카드', {
  amount: 5000,
  orderId: generateOrderId(),
  orderName: '운세 토큰 60개',
  customerName: userProfile.name,
  successUrl: `${window.location.origin}/payment/success`,
  failUrl: `${window.location.origin}/payment/fail`,
});
```

### 3. 결제 확인
```typescript
// 서버에서 결제 확인
async function confirmPayment(paymentKey: string, orderId: string, amount: number) {
  const response = await fetch('https://api.tosspayments.com/v1/payments/confirm', {
    method: 'POST',
    headers: {
      'Authorization': `Basic ${Buffer.from(secretKey + ':').toString('base64')}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      paymentKey,
      orderId,
      amount,
    }),
  });
  
  if (response.ok) {
    // 토큰 지급 처리
    await grantTokensToUser(orderId, amount);
  }
}
```

### 4. Flutter 통합
```dart
// TossPay WebView 통합
import 'package:webview_flutter/webview_flutter.dart';

class TossPayWebView extends StatelessWidget {
  final String paymentUrl;
  
  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      controller: WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (NavigationRequest request) {
              if (request.url.contains('/payment/success')) {
                // 결제 성공 처리
                Navigator.pop(context, true);
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(paymentUrl)),
    );
  }
}
```

---

## Redis/Upstash 설정

### 1. 환경 변수
```env
UPSTASH_REDIS_REST_URL=https://xxxxx.upstash.io
UPSTASH_REDIS_REST_TOKEN=xxxxxxxxxxxxxxxxxxxxx
```

### 2. Redis 클라이언트
```typescript
// src/lib/redis.ts
import { Redis } from '@upstash/redis';

export const redis = new Redis({
  url: process.env.UPSTASH_REDIS_REST_URL!,
  token: process.env.UPSTASH_REDIS_REST_TOKEN!,
});

// Rate Limiting 구현
export async function checkRateLimit(
  identifier: string,
  limit: number = 10,
  window: number = 60
): Promise<{ allowed: boolean; remaining: number }> {
  const key = `rate_limit:${identifier}`;
  const current = await redis.incr(key);
  
  if (current === 1) {
    await redis.expire(key, window);
  }
  
  return {
    allowed: current <= limit,
    remaining: Math.max(0, limit - current)
  };
}
```

### 3. 캐싱 전략
```typescript
// 하이브리드 캐시 구현
class HybridCache {
  private memoryCache = new LRUCache<string, any>({ max: 1000 });
  
  async get(key: string): Promise<any> {
    // 1. 메모리 캐시 확인
    const memoryResult = this.memoryCache.get(key);
    if (memoryResult) return memoryResult;
    
    // 2. Redis 캐시 확인
    try {
      const redisResult = await redis.get(key);
      if (redisResult) {
        this.memoryCache.set(key, redisResult);
        return redisResult;
      }
    } catch (error) {
      console.error('Redis error:', error);
    }
    
    return null;
  }
  
  async set(key: string, value: any, ttl: number) {
    // 메모리 캐시 저장
    this.memoryCache.set(key, value);
    
    // Redis 저장 (비동기)
    redis.setex(key, ttl, JSON.stringify(value)).catch(console.error);
  }
}
```

### 4. Flutter 통합
```dart
// Local caching with Hive
import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  late Box<dynamic> _cacheBox;
  
  Future<void> init() async {
    await Hive.initFlutter();
    _cacheBox = await Hive.openBox('fortune_cache');
  }
  
  Future<T?> get<T>(String key) async {
    final cached = _cacheBox.get(key);
    if (cached != null && cached['expiry'] > DateTime.now().millisecondsSinceEpoch) {
      return cached['data'] as T;
    }
    return null;
  }
  
  Future<void> set(String key, dynamic value, Duration ttl) async {
    await _cacheBox.put(key, {
      'data': value,
      'expiry': DateTime.now().add(ttl).millisecondsSinceEpoch,
    });
  }
}

// Rate limiting
class RateLimiter {
  final Map<String, List<int>> _requests = {};
  
  bool checkLimit(String key, int limit, Duration window) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final windowStart = now - window.inMilliseconds;
    
    _requests[key] = (_requests[key] ?? [])
      .where((timestamp) => timestamp > windowStart)
      .toList();
    
    if (_requests[key]!.length < limit) {
      _requests[key]!.add(now);
      return true;
    }
    
    return false;
  }
}
```

---

## Google AdSense 설정

### 1. 환경 변수
```env
NEXT_PUBLIC_ADSENSE_CLIENT_ID=ca-pub-xxxxxxxxxxxxx
NEXT_PUBLIC_ADSENSE_SLOT_ID=xxxxxxxxxxxxx
NEXT_PUBLIC_ADSENSE_DISPLAY_SLOT=xxxxxxxxxxxxx
```

### 2. AdSense Provider
```typescript
// src/components/ads/AdSenseProvider.tsx
export function AdSenseProvider({ children }: { children: React.ReactNode }) {
  useEffect(() => {
    // AdSense 스크립트 로드
    const script = document.createElement('script');
    script.src = 'https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js';
    script.async = true;
    script.crossOrigin = 'anonymous';
    document.head.appendChild(script);
    
    // Ad blocker 감지
    script.onerror = () => {
      console.log('AdSense blocked');
      // 대체 콘텐츠 표시
    };
  }, []);
  
  return <>{children}</>;
}
```

### 3. Flutter 통합
```dart
// pubspec.yaml
dependencies:
  google_mobile_ads: ^5.0.0

// 광고 초기화
class AdService {
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    
    // 테스트 디바이스 설정
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: ['YOUR_TEST_DEVICE_ID']),
    );
  }
  
  // 배너 광고
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: Platform.isAndroid 
        ? 'ca-app-pub-xxxxx/xxxxx' 
        : 'ca-app-pub-xxxxx/xxxxx',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          // 에러 처리
        },
      ),
    )..load();
  }
}
```

---

## Supabase 설정

### 1. 환경 변수
```env
NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.xxxxx
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.xxxxx
```

### 2. 클라이언트 초기화
```typescript
// src/lib/supabase.ts
import { createClient } from '@supabase/supabase-js';

// 클라이언트용 (RLS 적용)
export const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
  {
    auth: {
      autoRefreshToken: true,
      persistSession: true,
      detectSessionInUrl: true,
    },
  }
);

// 서버용 (RLS 우회)
export const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  }
);
```

### 3. Flutter 통합
```dart
// main.dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
    authCallbackUrlHostname: 'login-callback',
  );
  
  runApp(MyApp());
}

// 인증 서비스
class AuthService {
  final SupabaseClient _client = Supabase.instance.client;
  
  Future<AuthResponse> signInWithGoogle() async {
    return await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.fortune://login-callback',
    );
  }
  
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  
  User? get currentUser => _client.auth.currentUser;
}
```

---

## 에러 모니터링

### 1. 커스텀 에러 모니터링
```typescript
// src/lib/error-monitor.ts
class ErrorMonitor {
  private errorQueue: ErrorEvent[] = [];
  
  initialize() {
    // 브라우저 에러 캡처
    window.addEventListener('error', this.handleError);
    window.addEventListener('unhandledrejection', this.handlePromiseRejection);
  }
  
  captureException(error: Error, context?: any) {
    const errorEvent = {
      message: error.message,
      stack: error.stack,
      context,
      timestamp: new Date().toISOString(),
      userAgent: navigator.userAgent,
      url: window.location.href,
    };
    
    this.errorQueue.push(errorEvent);
    this.flushErrors();
  }
  
  private async flushErrors() {
    if (this.errorQueue.length === 0) return;
    
    const errors = [...this.errorQueue];
    this.errorQueue = [];
    
    try {
      await fetch('/api/errors/log', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ errors }),
      });
    } catch (e) {
      // 에러 로깅 실패 시 로컬 스토리지에 저장
      localStorage.setItem('pending_errors', JSON.stringify(errors));
    }
  }
}
```

### 2. Flutter 에러 모니터링
```dart
// Flutter 에러 핸들링
void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    // 에러 로깅
    ErrorService.logError(details.exception, details.stack);
  };
  
  PlatformDispatcher.instance.onError = (error, stack) {
    // 비동기 에러 로깅
    ErrorService.logError(error, stack);
    return true;
  };
  
  runZonedGuarded(() {
    runApp(MyApp());
  }, (error, stack) {
    ErrorService.logError(error, stack);
  });
}

// 에러 서비스
class ErrorService {
  static final _errorQueue = <ErrorLog>[];
  
  static void logError(dynamic error, StackTrace? stack) {
    final errorLog = ErrorLog(
      message: error.toString(),
      stackTrace: stack?.toString(),
      timestamp: DateTime.now(),
      deviceInfo: await _getDeviceInfo(),
    );
    
    _errorQueue.add(errorLog);
    _flushErrors();
  }
  
  static Future<void> _flushErrors() async {
    if (_errorQueue.isEmpty) return;
    
    final errors = List<ErrorLog>.from(_errorQueue);
    _errorQueue.clear();
    
    try {
      await ApiClient.post('/api/errors/log', {
        'errors': errors.map((e) => e.toJson()).toList(),
      });
    } catch (e) {
      // 오프라인 저장
      await LocalStorage.saveErrors(errors);
    }
  }
}
```

---

## Flutter 마이그레이션 가이드

### 1. 환경 설정
```dart
// config/env.dart
class Environment {
  static const String openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String stripePublishableKey = String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');
  
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');
}
```

### 2. 서비스 레이어 구조
```dart
// services/service_locator.dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // 외부 서비스
  getIt.registerLazySingleton<OpenAIService>(() => OpenAIService());
  getIt.registerLazySingleton<SupabaseService>(() => SupabaseService());
  getIt.registerLazySingleton<PaymentService>(() => PaymentService());
  getIt.registerLazySingleton<CacheService>(() => CacheService());
  getIt.registerLazySingleton<AdService>(() => AdService());
  
  // 앱 서비스
  getIt.registerLazySingleton<FortuneService>(() => FortuneService());
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<TokenService>(() => TokenService());
}
```

### 3. 네트워크 레이어
```dart
// network/api_client.dart
class ApiClient {
  final Dio _dio;
  
  ApiClient() : _dio = Dio() {
    _dio.options.baseUrl = Environment.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    
    // 인터셉터 추가
    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(RetryInterceptor());
    _dio.interceptors.add(LoggingInterceptor());
  }
  
  // Retry 로직
  Future<T> retryRequest<T>(Future<T> Function() request) async {
    int attempts = 0;
    
    while (attempts < 3) {
      try {
        return await request();
      } catch (e) {
        attempts++;
        if (attempts >= 3) rethrow;
        
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
    
    throw Exception('Request failed after 3 attempts');
  }
}
```

### 4. 상태 관리
```dart
// providers/fortune_provider.dart
import 'package:riverpod/riverpod.dart';

final fortuneServiceProvider = Provider((ref) => getIt<FortuneService>());

final dailyFortuneProvider = FutureProvider.autoDispose<DailyFortune>((ref) async {
  final service = ref.watch(fortuneServiceProvider);
  final user = ref.watch(currentUserProvider);
  
  if (user == null) throw Exception('User not authenticated');
  
  // 캐시 확인
  final cached = await ref.watch(cacheServiceProvider).get<DailyFortune>(
    'daily_fortune_${user.id}_${DateTime.now().toIso8601String().split('T')[0]}'
  );
  
  if (cached != null) return cached;
  
  // API 호출
  return service.getDailyFortune(user);
});
```

### 5. 보안 고려사항
```dart
// security/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  
  static Future<void> saveApiKey(String key, String value) async {
    await _storage.write(key: key, value: value);
  }
  
  static Future<String?> getApiKey(String key) async {
    return await _storage.read(key: key);
  }
  
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
```

---

## 체크리스트

### 개발 환경
- [ ] 모든 API 키 발급 및 테스트
- [ ] 개발/스테이징/프로덕션 환경 분리
- [ ] 환경별 설정 파일 준비

### OpenAI
- [ ] API 키 보안 저장
- [ ] 프롬프트 템플릿 마이그레이션
- [ ] 토큰 사용량 추적 구현
- [ ] 에러 핸들링 및 재시도 로직

### 결제
- [ ] Stripe Flutter SDK 통합
- [ ] TossPay WebView 구현
- [ ] Webhook 엔드포인트 설정
- [ ] 결제 플로우 테스트

### 캐싱
- [ ] Hive 또는 SharedPreferences 설정
- [ ] 캐시 TTL 전략 구현
- [ ] 오프라인 모드 지원

### 광고
- [ ] Google Mobile Ads 통합
- [ ] 광고 ID 설정
- [ ] 광고 로드 실패 처리

### 인증
- [ ] Supabase Flutter SDK 설정
- [ ] OAuth 콜백 URL 설정
- [ ] 세션 관리 구현

### 모니터링
- [ ] 에러 로깅 시스템 구축
- [ ] 분석 도구 통합
- [ ] 성능 모니터링 설정

---

이 가이드는 Fortune 앱의 모든 외부 서비스를 Flutter로 성공적으로 마이그레이션하기 위한 상세한 설정 방법을 제공합니다.