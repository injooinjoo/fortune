# Flutter 패키지 의존성 가이드

> Fortune 앱의 Flutter 마이그레이션을 위한 패키지 선정 및 사용 가이드
> 작성일: 2025년 1월 8일

## 📑 목차
1. [개요](#개요)
2. [핵심 패키지](#핵심-패키지)
3. [기능별 패키지](#기능별-패키지)
4. [개발 도구 패키지](#개발-도구-패키지)
5. [패키지 선정 기준](#패키지-선정-기준)
6. [패키지별 상세 설명](#패키지별-상세-설명)
7. [버전 관리 전략](#버전-관리-전략)

---

## 개요

Fortune Flutter 앱은 안정성, 성능, 유지보수성을 고려하여 패키지를 선정했습니다. 각 패키지는 명확한 목적과 검증된 안정성을 기준으로 선택되었습니다.

### 선정 원칙
- **안정성**: 1.0 이상 버전 또는 널리 사용되는 패키지
- **유지보수**: 활발한 커뮤니티와 정기 업데이트
- **성능**: 앱 크기와 실행 속도에 미치는 영향 최소화
- **호환성**: Flutter 최신 버전과의 호환성

---

## 핵심 패키지

### pubspec.yaml
```yaml
name: flutter_fortune
description: AI 기반 한국 운세 서비스
version: 1.0.0+1
publish_to: 'none'

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.10.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  
  # 상태 관리
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  
  # 네비게이션
  go_router: ^12.0.0
  
  # 네트워킹
  dio: ^5.3.0
  retrofit: ^4.0.0
  pretty_dio_logger: ^1.3.1
  
  # 로컬 저장소
  flutter_secure_storage: ^9.0.0
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.0
  
  # 백엔드 통합
  supabase_flutter: ^2.0.0
  
  # 결제
  flutter_stripe: ^10.0.0
  iamport_flutter: ^0.10.0  # TossPay 지원
  
  # UI/UX
  flutter_animate: ^4.2.0
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  lottie: ^2.7.0
  
  # 유틸리티
  intl: ^0.18.0
  equatable: ^2.0.5
  dartz: ^0.10.1
  get_it: ^7.6.0
  flutter_dotenv: ^5.1.0
  json_annotation: ^4.8.1
  freezed_annotation: ^2.4.1
  
  # 이미지/미디어
  image_picker: ^1.0.0
  image: ^4.1.0
  path_provider: ^2.1.0
  share_plus: ^7.2.0
  screenshot: ^2.1.0
  
  # 권한 관리
  permission_handler: ^11.0.0
  
  # 디바이스 정보
  device_info_plus: ^9.1.0
  package_info_plus: ^4.2.0
  
  # 광고
  google_mobile_ads: ^5.0.0
  
  # 분석
  firebase_core: ^2.24.0
  firebase_analytics: ^10.7.0
  firebase_crashlytics: ^3.4.0
  
  # 기타
  url_launcher: ^6.2.0
  connectivity_plus: ^5.0.0
  flutter_native_splash: ^2.3.0
  uni_links: ^0.5.1
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # 코드 생성
  build_runner: ^2.4.0
  retrofit_generator: ^8.0.0
  json_serializable: ^6.7.0
  freezed: ^2.4.0
  riverpod_generator: ^2.3.0
  hive_generator: ^2.0.0
  
  # 테스트
  mockito: ^5.4.0
  build_runner: ^2.4.0
  
  # 코드 품질
  flutter_lints: ^3.0.0
  very_good_analysis: ^5.1.0
  
  # 아이콘 생성
  flutter_launcher_icons: ^0.13.0
```

---

## 기능별 패키지

### 1. 상태 관리
| 패키지 | 버전 | 선정 이유 |
|--------|------|-----------|
| `flutter_riverpod` | ^2.4.0 | • Provider의 개선된 버전<br>• 컴파일 타임 안정성<br>• 우수한 개발자 경험<br>• 코드 생성 지원 |
| `riverpod_annotation` | ^2.3.0 | • 코드 생성으로 보일러플레이트 감소<br>• 타입 안정성 향상 |

### 2. 네비게이션
| 패키지 | 버전 | 선정 이유 |
|--------|------|-----------|
| `go_router` | ^12.0.0 | • 선언적 라우팅<br>• 딥링크 지원<br>• 웹 URL 지원<br>• Navigator 2.0 기반 |

### 3. 네트워킹
| 패키지 | 버전 | 선정 이유 |
|--------|------|-----------|
| `dio` | ^5.3.0 | • 강력한 HTTP 클라이언트<br>• 인터셉터 지원<br>• 파일 업/다운로드<br>• 취소 가능한 요청 |
| `retrofit` | ^4.0.0 | • Type-safe HTTP 클라이언트<br>• 코드 생성<br>• Dio 기반 |
| `pretty_dio_logger` | ^1.3.1 | • 개발 중 네트워크 디버깅<br>• 보기 좋은 로그 포맷 |

### 4. 로컬 저장소
| 패키지 | 버전 | 선정 이유 |
|--------|------|-----------|
| `flutter_secure_storage` | ^9.0.0 | • 민감한 데이터 암호화 저장<br>• Keychain/Keystore 활용<br>• 토큰, 인증 정보 저장 |
| `hive_flutter` | ^1.1.0 | • NoSQL 로컬 DB<br>• 빠른 성능<br>• 오프라인 캐싱<br>• 타입 안정성 |
| `shared_preferences` | ^2.2.0 | • 간단한 키-값 저장<br>• 설정값 저장<br>• 플랫폼 네이티브 |

### 5. 백엔드 통합
| 패키지 | 버전 | 선정 이유 |
|--------|------|-----------|
| `supabase_flutter` | ^2.0.0 | • 기존 백엔드 호환<br>• 실시간 구독<br>• 인증 통합<br>• 파일 스토리지 |

### 6. 결제
| 패키지 | 버전 | 선정 이유 |
|--------|------|-----------|
| `flutter_stripe` | ^10.0.0 | • Stripe 공식 SDK<br>• PCI 규정 준수<br>• 결제 UI 제공<br>• 구독 관리 |
| `iamport_flutter` | ^0.10.0 | • 한국 PG사 통합<br>• TossPay 지원<br>• 네이버페이 지원<br>• 카카오페이 지원 |

### 7. UI/UX
| 패키지 | 버전 | 선정 이유 |
|--------|------|-----------|
| `flutter_animate` | ^4.2.0 | • 선언적 애니메이션<br>• Framer Motion 유사<br>• 체이닝 가능<br>• 성능 최적화 |
| `cached_network_image` | ^3.3.0 | • 이미지 캐싱<br>• 플레이스홀더<br>• 오프라인 지원<br>• 메모리 관리 |
| `shimmer` | ^3.0.0 | • 스켈레톤 로딩<br>• 부드러운 효과<br>• 커스터마이징 가능 |
| `lottie` | ^2.7.0 | • 복잡한 애니메이션<br>• After Effects 호환<br>• 작은 파일 크기 |

---

## 개발 도구 패키지

### 코드 생성
| 패키지 | 용도 |
|--------|------|
| `build_runner` | 코드 생성 실행 |
| `json_serializable` | JSON 직렬화 코드 생성 |
| `freezed` | 불변 클래스 생성 |
| `retrofit_generator` | HTTP 클라이언트 생성 |
| `riverpod_generator` | Provider 코드 생성 |
| `hive_generator` | Hive 어댑터 생성 |

### 테스트
| 패키지 | 용도 |
|--------|------|
| `mockito` | Mock 객체 생성 |
| `flutter_test` | 위젯 및 단위 테스트 |

### 코드 품질
| 패키지 | 용도 |
|--------|------|
| `flutter_lints` | Flutter 권장 린트 규칙 |
| `very_good_analysis` | 엄격한 분석 규칙 |

---

## 패키지 선정 기준

### 1. 필수 기준
- ✅ **Null Safety 지원**
- ✅ **활발한 유지보수** (최근 6개월 내 업데이트)
- ✅ **충분한 문서화**
- ✅ **1000+ likes on pub.dev** (핵심 패키지)
- ✅ **라이선스 호환성** (MIT, BSD, Apache 2.0)

### 2. 선호 기준
- ⭐ **Flutter Favorite** 뱃지
- ⭐ **대기업 후원** (Google, Meta 등)
- ⭐ **작은 패키지 크기**
- ⭐ **플랫폼별 구현** (iOS/Android 네이티브)
- ⭐ **테스트 커버리지 80% 이상**

### 3. 제외 기준
- ❌ **6개월 이상 업데이트 없음**
- ❌ **Breaking changes 빈번**
- ❌ **의존성 충돌 문제**
- ❌ **보안 이슈 존재**
- ❌ **대체 가능한 네이티브 API 존재**

---

## 패키지별 상세 설명

### 1. flutter_riverpod (상태 관리)
```dart
// 사용 예시
final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier(ref.watch(authRepositoryProvider));
});

class UserNotifier extends StateNotifier<User?> {
  final AuthRepository _authRepository;
  
  UserNotifier(this._authRepository) : super(null) {
    _loadUser();
  }
  
  Future<void> _loadUser() async {
    state = await _authRepository.getCurrentUser();
  }
}

// 위젯에서 사용
class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return user == null ? LoginPrompt() : UserProfile(user);
  }
}
```

### 2. go_router (네비게이션)
```dart
// 라우터 설정
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authState,
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isAuthRoute = state.location.startsWith('/auth');
      
      if (!isAuth && !isAuthRoute) return '/auth/login';
      if (isAuth && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'fortune/:type',
            builder: (context, state) => FortuneScreen(
              type: state.pathParameters['type']!,
            ),
          ),
        ],
      ),
    ],
  );
});
```

### 3. dio + retrofit (네트워킹)
```dart
// API 클라이언트
@RestApi(baseUrl: "https://api.fortune.com")
abstract class FortuneApi {
  factory FortuneApi(Dio dio, {String baseUrl}) = _FortuneApi;
  
  @GET("/fortunes/daily")
  Future<DailyFortuneResponse> getDailyFortune(
    @Query("date") String date,
    @Header("Authorization") String token,
  );
  
  @POST("/fortunes/generate")
  Future<FortuneResponse> generateFortune(
    @Body() FortuneRequest request,
  );
}

// Dio 설정
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  
  dio.interceptors.addAll([
    AuthInterceptor(ref.watch(authRepositoryProvider)),
    if (kDebugMode) PrettyDioLogger(),
  ]);
  
  return dio;
});
```

### 4. hive_flutter (로컬 DB)
```dart
// 모델 정의
@HiveType(typeId: 1)
class CachedFortune extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String type;
  
  @HiveField(2)
  final Map<String, dynamic> data;
  
  @HiveField(3)
  final DateTime cachedAt;
  
  CachedFortune({
    required this.id,
    required this.type,
    required this.data,
    required this.cachedAt,
  });
}

// 사용
class FortuneCache {
  late Box<CachedFortune> _box;
  
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CachedFortuneAdapter());
    _box = await Hive.openBox<CachedFortune>('fortune_cache');
  }
  
  Future<void> cache(String key, CachedFortune fortune) async {
    await _box.put(key, fortune);
  }
  
  CachedFortune? get(String key) {
    final cached = _box.get(key);
    if (cached != null && _isValid(cached)) {
      return cached;
    }
    return null;
  }
}
```

### 5. flutter_stripe (결제)
```dart
// Stripe 초기화
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
  await Stripe.instance.applySettings();
  
  runApp(const MyApp());
}

// 결제 처리
class PaymentService {
  Future<void> purchaseTokens(TokenPackage package) async {
    // 1. 서버에서 Payment Intent 생성
    final paymentIntent = await _api.createPaymentIntent(
      amount: package.price,
      currency: 'krw',
    );
    
    // 2. Payment Sheet 초기화
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntent.clientSecret,
        merchantDisplayName: 'Fortune App',
        customerId: paymentIntent.customerId,
        customerEphemeralKeySecret: paymentIntent.ephemeralKey,
        applePay: const PaymentSheetApplePay(
          merchantCountryCode: 'KR',
        ),
        googlePay: const PaymentSheetGooglePay(
          merchantCountryCode: 'KR',
          testEnv: kDebugMode,
        ),
      ),
    );
    
    // 3. Payment Sheet 표시
    await Stripe.instance.presentPaymentSheet();
    
    // 4. 성공 처리
    await _handlePaymentSuccess(package);
  }
}
```

### 6. flutter_animate (애니메이션)
```dart
// 사용 예시
class FortuneCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text('오늘의 운세')
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.2, end: 0),
          
          FortuneScore(score: 85)
            .animate()
            .scale(delay: 300.ms, duration: 400.ms)
            .shake(delay: 700.ms),
          
          LuckyItems(items: items)
            .animate()
            .fadeIn(delay: 500.ms)
            .slideX(begin: -0.2, end: 0),
        ],
      ),
    )
    .animate()
    .custom(
      duration: 300.ms,
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(value * 0.3),
                blurRadius: 20 * value,
                spreadRadius: 5 * value,
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}
```

---

## 버전 관리 전략

### 1. 버전 제약 규칙
```yaml
# 정확한 버전 (중요 패키지)
flutter_riverpod: 2.4.0

# 호환 버전 (^)
dio: ^5.3.0  # 5.3.0 이상, 6.0.0 미만

# 범위 지정
intl: '>=0.18.0 <0.19.0'
```

### 2. 업데이트 정책
- **Major 업데이트**: 충분한 테스트 후 적용
- **Minor 업데이트**: 변경사항 검토 후 적용
- **Patch 업데이트**: 자동 적용 가능

### 3. 의존성 관리 명령어
```bash
# 의존성 업데이트 확인
flutter pub outdated

# 안전한 업데이트 적용
flutter pub upgrade --major-versions

# 특정 패키지 업데이트
flutter pub upgrade dio

# 의존성 트리 확인
flutter pub deps

# 사용하지 않는 의존성 확인
flutter pub deps --no-dev --executable
```

### 4. 버전 충돌 해결
```yaml
# dependency_overrides 사용 (임시 해결책)
dependency_overrides:
  collection: ^1.17.0
  
# 주의: 프로덕션에서는 제거 필요
```

---

## 패키지 추가 체크리스트

새로운 패키지 추가 시 확인사항:

- [ ] pub.dev에서 패키지 정보 확인
- [ ] 라이선스 호환성 검토
- [ ] 최근 업데이트 날짜 확인
- [ ] Issues 및 PR 상태 검토
- [ ] 패키지 크기 확인
- [ ] 의존성 충돌 검사
- [ ] 예제 코드 실행 테스트
- [ ] 팀 내 검토 및 승인

---

## 대체 패키지 목록

상황에 따라 고려할 수 있는 대체 패키지:

| 기능 | 선택된 패키지 | 대체 패키지 | 비고 |
|------|--------------|------------|------|
| 상태 관리 | flutter_riverpod | bloc, provider, getx | Riverpod이 가장 현대적 |
| 네트워킹 | dio | http, chopper | Dio가 기능 풍부 |
| 로컬 DB | hive | sqflite, drift, isar | Hive가 가장 간단 |
| 네비게이션 | go_router | auto_route, beamer | go_router가 공식 권장 |
| 이미지 캐싱 | cached_network_image | extended_image | 표준 선택 |

---

이 문서는 Fortune Flutter 앱의 패키지 선정 과정과 사용 방법을 상세히 설명합니다. 각 패키지는 프로젝트의 요구사항과 Flutter 생태계의 베스트 프랙티스를 고려하여 신중히 선택되었습니다.