# Flutter Fortune 프로젝트 구조 설계

> Clean Architecture 기반의 확장 가능하고 유지보수가 용이한 Flutter 프로젝트 구조
> 작성일: 2025년 1월 8일

## 📑 목차
1. [개요](#개요)
2. [아키텍처 원칙](#아키텍처-원칙)
3. [프로젝트 구조 상세](#프로젝트-구조-상세)
4. [레이어별 설명](#레이어별-설명)
5. [핵심 패턴 및 컨벤션](#핵심-패턴-및-컨벤션)
6. [파일 명명 규칙](#파일-명명-규칙)
7. [예제 코드](#예제-코드)
8. [마이그레이션 매핑](#마이그레이션-매핑)

---

## 개요

Fortune Flutter 앱은 Clean Architecture와 Domain-Driven Design 원칙을 따라 설계되었습니다. 이는 기존 Next.js 앱의 구조적 장점을 유지하면서 Flutter의 특성을 최대한 활용합니다.

### 주요 특징
- **명확한 레이어 분리**: Presentation, Domain, Data
- **의존성 역전**: 비즈니스 로직이 프레임워크에 의존하지 않음
- **테스트 용이성**: 각 레이어가 독립적으로 테스트 가능
- **확장성**: 새로운 기능 추가가 기존 코드에 미치는 영향 최소화

---

## 아키텍처 원칙

### 1. Clean Architecture 레이어
```
┌─────────────────────────────────────────┐
│          Presentation Layer             │
│  (UI, State Management, Navigation)     │
├─────────────────────────────────────────┤
│            Domain Layer                 │
│   (Business Logic, Use Cases)          │
├─────────────────────────────────────────┤
│             Data Layer                  │
│  (API, Database, Cache, Repository)    │
└─────────────────────────────────────────┘
```

### 2. 의존성 방향
- Presentation → Domain → Data
- 내부 레이어는 외부 레이어를 알지 못함
- 인터페이스를 통한 의존성 주입

### 3. 데이터 플로우
```
User Action → Widget → Provider → Use Case → Repository → Data Source
                ↓                      ↓            ↓            ↓
              State ← Entity ← Domain Model ← Data Model ← API Response
```

---

## 프로젝트 구조 상세

```
flutter_fortune/
├── lib/
│   ├── main.dart                    # 앱 진입점
│   ├── app.dart                     # 앱 설정 및 초기화
│   ├── injection_container.dart    # 의존성 주입 설정
│   │
│   ├── core/                       # 핵심 공통 모듈
│   │   ├── constants/              # 상수 정의
│   │   │   ├── app_constants.dart
│   │   │   ├── fortune_categories.dart
│   │   │   ├── token_costs.dart
│   │   │   └── time_periods.dart
│   │   │
│   │   ├── errors/                 # 에러 처리
│   │   │   ├── exceptions.dart
│   │   │   ├── failures.dart
│   │   │   └── error_messages.dart
│   │   │
│   │   ├── extensions/             # Dart 확장
│   │   │   ├── date_extensions.dart
│   │   │   ├── string_extensions.dart
│   │   │   └── context_extensions.dart
│   │   │
│   │   ├── theme/                  # 테마 설정
│   │   │   ├── app_theme.dart
│   │   │   ├── app_colors.dart
│   │   │   ├── app_typography.dart
│   │   │   └── app_spacing.dart
│   │   │
│   │   ├── utils/                  # 유틸리티
│   │   │   ├── deterministic_random.dart
│   │   │   ├── korean_date_utils.dart
│   │   │   ├── security_utils.dart
│   │   │   ├── input_validators.dart
│   │   │   └── format_utils.dart
│   │   │
│   │   └── network/                # 네트워크 설정
│   │       ├── network_info.dart
│   │       └── api_endpoints.dart
│   │
│   ├── features/                   # 기능별 모듈
│   │   ├── auth/                   # 인증 기능
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── auth_remote_data_source.dart
│   │   │   │   │   └── auth_local_data_source.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── auth_user_model.dart
│   │   │   │   │   └── auth_token_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── auth_user.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── sign_in_with_google.dart
│   │   │   │       ├── sign_out.dart
│   │   │   │       └── get_current_user.dart
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── auth_provider.dart
│   │   │       ├── screens/
│   │   │       │   ├── login_screen.dart
│   │   │       │   └── splash_screen.dart
│   │   │       └── widgets/
│   │   │           ├── social_login_button.dart
│   │   │           └── auth_loading_indicator.dart
│   │   │
│   │   ├── fortune/                # 운세 기능
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── fortune_remote_data_source.dart
│   │   │   │   │   └── fortune_local_data_source.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── fortune_model.dart
│   │   │   │   │   ├── daily_fortune_model.dart
│   │   │   │   │   ├── saju_model.dart
│   │   │   │   │   └── tarot_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── fortune_repository_impl.dart
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── fortune.dart
│   │   │   │   │   ├── fortune_category.dart
│   │   │   │   │   └── fortune_result.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── fortune_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_daily_fortune.dart
│   │   │   │       ├── get_saju_fortune.dart
│   │   │   │       ├── get_tarot_reading.dart
│   │   │   │       └── generate_batch_fortunes.dart
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   ├── fortune_list_provider.dart
│   │   │       │   └── fortune_detail_provider.dart
│   │   │       ├── screens/
│   │   │       │   ├── fortune_categories_screen.dart
│   │   │       │   ├── daily_fortune_screen.dart
│   │   │       │   ├── saju_input_screen.dart
│   │   │       │   └── fortune_result_screen.dart
│   │   │       └── widgets/
│   │   │           ├── fortune_card.dart
│   │   │           ├── fortune_score_gauge.dart
│   │   │           ├── lucky_items_display.dart
│   │   │           └── fortune_share_button.dart
│   │   │
│   │   ├── user_profile/           # 사용자 프로필
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── payment/                # 결제 기능
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   └── token/                  # 토큰 관리
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   │
│   ├── shared/                     # 공유 컴포넌트
│   │   ├── widgets/
│   │   │   ├── app_bar.dart
│   │   │   ├── bottom_navigation.dart
│   │   │   ├── loading_overlay.dart
│   │   │   ├── error_dialog.dart
│   │   │   └── custom_button.dart
│   │   │
│   │   ├── providers/
│   │   │   ├── app_state_provider.dart
│   │   │   └── navigation_provider.dart
│   │   │
│   │   └── services/
│   │       ├── navigation_service.dart
│   │       ├── analytics_service.dart
│   │       └── notification_service.dart
│   │
│   └── config/                     # 설정
│       ├── routes/
│       │   ├── app_router.dart
│       │   ├── route_guards.dart
│       │   └── route_constants.dart
│       │
│       ├── localization/
│       │   ├── app_localizations.dart
│       │   └── l10n/
│       │       ├── intl_ko.arb
│       │       └── intl_en.arb
│       │
│       └── environment/
│           ├── environment.dart
│           └── env_config.dart
│
├── test/                           # 테스트
│   ├── unit/
│   │   ├── core/
│   │   └── features/
│   │       ├── auth/
│   │       └── fortune/
│   │
│   ├── widget/
│   │   └── features/
│   │
│   └── integration/
│       ├── app_test.dart
│       └── api_test.dart
│
├── assets/                         # 리소스
│   ├── images/
│   │   ├── fortune_icons/
│   │   ├── backgrounds/
│   │   └── logos/
│   │
│   ├── animations/
│   │   └── lottie/
│   │
│   └── fonts/
│       └── Pretendard/
│
├── android/                        # Android 플랫폼 코드
├── ios/                           # iOS 플랫폼 코드
├── web/                           # Web 플랫폼 코드
│
├── pubspec.yaml                   # 패키지 의존성
├── analysis_options.yaml          # 코드 분석 규칙
└── README.md                      # 프로젝트 문서
```

---

## 레이어별 설명

### 1. Core Layer
앱 전체에서 사용되는 공통 기능과 유틸리티를 포함합니다.

```dart
// core/constants/fortune_categories.dart
class FortuneCategories {
  static const lifeProfile = [
    'saju', 'traditional-saju', 'tojeong', 'personality'
  ];
  
  static const dailyFortune = [
    'daily', 'hourly', 'today', 'tomorrow'
  ];
  
  static const interactive = [
    'tarot', 'dream', 'compatibility', 'worry-bead'
  ];
}

// core/utils/korean_date_utils.dart
class KoreanDateUtils {
  static String getTimeZodiac(DateTime dateTime) {
    final hour = dateTime.hour;
    const zodiacAnimals = ['쥐', '소', '호랑이', '토끼', ...];
    return zodiacAnimals[(hour ~/ 2) % 12];
  }
  
  static String formatKoreanDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }
}
```

### 2. Features Layer
각 기능별로 독립적인 모듈로 구성되며, 각 모듈은 data, domain, presentation 레이어를 포함합니다.

#### Data Layer
- **Models**: API 응답을 Dart 객체로 변환
- **Data Sources**: 실제 데이터 접근 (API, DB, Cache)
- **Repositories**: Domain 레이어의 Repository 인터페이스 구현

```dart
// features/fortune/data/models/daily_fortune_model.dart
class DailyFortuneModel extends DailyFortune {
  const DailyFortuneModel({
    required String id,
    required DateTime date,
    required Map<String, dynamic> fortuneData,
  }) : super(id: id, date: date, fortuneData: fortuneData);
  
  factory DailyFortuneModel.fromJson(Map<String, dynamic> json) {
    return DailyFortuneModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      fortuneData: json['fortune_data'],
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'fortune_data': fortuneData,
  };
}
```

#### Domain Layer
- **Entities**: 비즈니스 객체
- **Use Cases**: 비즈니스 로직
- **Repository Interfaces**: 데이터 접근 추상화

```dart
// features/fortune/domain/usecases/get_daily_fortune.dart
class GetDailyFortune {
  final FortuneRepository repository;
  
  GetDailyFortune(this.repository);
  
  Future<Either<Failure, DailyFortune>> call(GetDailyFortuneParams params) async {
    // 토큰 확인
    if (params.userTokens < TokenCosts.dailyFortune) {
      return Left(InsufficientTokensFailure());
    }
    
    // 캐시 확인
    final cached = await repository.getCachedDailyFortune(params.userId, params.date);
    if (cached != null) {
      return Right(cached);
    }
    
    // API 호출
    return await repository.generateDailyFortune(params);
  }
}
```

#### Presentation Layer
- **Providers**: 상태 관리 (Riverpod)
- **Screens**: 전체 화면 위젯
- **Widgets**: 재사용 가능한 UI 컴포넌트

```dart
// features/fortune/presentation/providers/daily_fortune_provider.dart
final dailyFortuneProvider = StateNotifierProvider.family<
  DailyFortuneNotifier, 
  AsyncValue<DailyFortune>, 
  DateTime
>((ref, date) {
  final useCase = ref.watch(getDailyFortuneProvider);
  return DailyFortuneNotifier(useCase, date);
});

class DailyFortuneNotifier extends StateNotifier<AsyncValue<DailyFortune>> {
  final GetDailyFortune _getDailyFortune;
  final DateTime _date;
  
  DailyFortuneNotifier(this._getDailyFortune, this._date) 
    : super(const AsyncValue.loading()) {
    loadFortune();
  }
  
  Future<void> loadFortune() async {
    state = const AsyncValue.loading();
    
    final result = await _getDailyFortune(
      GetDailyFortuneParams(
        userId: currentUser.id,
        date: _date,
        userTokens: currentUser.tokenBalance,
      ),
    );
    
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (fortune) => state = AsyncValue.data(fortune),
    );
  }
}
```

### 3. Shared Layer
여러 기능에서 공통으로 사용되는 위젯과 서비스를 포함합니다.

```dart
// shared/widgets/loading_overlay.dart
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  
  const LoadingOverlay({
    required this.isLoading,
    required this.child,
    this.message,
  });
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(message!, style: context.textTheme.bodyLarge),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
```

---

## 핵심 패턴 및 컨벤션

### 1. Repository 패턴
```dart
// Domain Layer - Interface
abstract class FortuneRepository {
  Future<Either<Failure, DailyFortune>> generateDailyFortune(params);
  Future<DailyFortune?> getCachedDailyFortune(userId, date);
}

// Data Layer - Implementation
class FortuneRepositoryImpl implements FortuneRepository {
  final FortuneRemoteDataSource remoteDataSource;
  final FortuneLocalDataSource localDataSource;
  
  @override
  Future<Either<Failure, DailyFortune>> generateDailyFortune(params) async {
    try {
      final fortune = await remoteDataSource.generateDailyFortune(params);
      await localDataSource.cacheDailyFortune(fortune);
      return Right(fortune);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
```

### 2. Use Case 패턴
```dart
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
```

### 3. 의존성 주입
```dart
// injection_container.dart
final getIt = GetIt.instance;

Future<void> init() async {
  // Features - Fortune
  // Use Cases
  getIt.registerLazySingleton(() => GetDailyFortune(getIt()));
  
  // Repository
  getIt.registerLazySingleton<FortuneRepository>(
    () => FortuneRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );
  
  // Data Sources
  getIt.registerLazySingleton<FortuneRemoteDataSource>(
    () => FortuneRemoteDataSourceImpl(client: getIt()),
  );
  
  // External
  getIt.registerLazySingleton(() => http.Client());
  getIt.registerLazySingleton(() => InternetConnectionChecker());
}
```

### 4. 에러 처리
```dart
// Either 패턴 사용
Future<Either<Failure, Success>> someOperation() async {
  try {
    final result = await doSomething();
    return Right(Success(result));
  } on ServerException {
    return Left(ServerFailure());
  } on CacheException {
    return Left(CacheFailure());
  }
}

// UI에서 처리
result.fold(
  (failure) => showErrorSnackBar(mapFailureToMessage(failure)),
  (success) => navigateToNextScreen(success),
);
```

### 5. 상태 관리 패턴
```dart
// Riverpod StateNotifier
class TokenBalanceNotifier extends StateNotifier<int> {
  final TokenRepository _repository;
  
  TokenBalanceNotifier(this._repository) : super(0) {
    loadBalance();
  }
  
  Future<void> loadBalance() async {
    final balance = await _repository.getBalance();
    state = balance;
  }
  
  Future<void> consumeTokens(int amount) async {
    if (state < amount) throw InsufficientTokensException();
    
    await _repository.consumeTokens(amount);
    state = state - amount;
  }
}

// Provider 정의
final tokenBalanceProvider = StateNotifierProvider<TokenBalanceNotifier, int>((ref) {
  return TokenBalanceNotifier(ref.watch(tokenRepositoryProvider));
});
```

---

## 파일 명명 규칙

### 1. 일반 규칙
- **소문자 + 밑줄**: `user_profile.dart`
- **클래스명은 PascalCase**: `class UserProfile`
- **상수는 lowerCamelCase**: `const defaultTimeout = 30;`

### 2. 파일 타입별 접미사
- **Screen**: `_screen.dart` (login_screen.dart)
- **Widget**: `_widget.dart` 또는 구체적 이름 (fortune_card.dart)
- **Provider**: `_provider.dart` (auth_provider.dart)
- **Model**: `_model.dart` (user_model.dart)
- **Repository**: `_repository.dart` (auth_repository.dart)
- **Use Case**: 동사구 사용 (get_daily_fortune.dart)

### 3. 테스트 파일
- 원본 파일명 + `_test.dart`: `auth_repository_test.dart`

---

## 예제 코드

### 1. 완전한 Feature 구현 예제 (Daily Fortune)

#### Entity (Domain Layer)
```dart
// features/fortune/domain/entities/daily_fortune.dart
class DailyFortune extends Equatable {
  final String id;
  final DateTime date;
  final OverallScore overallScore;
  final CategoryScores categoryScores;
  final LuckyItems luckyItems;
  final String advice;
  
  const DailyFortune({
    required this.id,
    required this.date,
    required this.overallScore,
    required this.categoryScores,
    required this.luckyItems,
    required this.advice,
  });
  
  @override
  List<Object?> get props => [id, date, overallScore, categoryScores, luckyItems, advice];
}

class CategoryScores extends Equatable {
  final int love;
  final int money;
  final int health;
  final int work;
  
  const CategoryScores({
    required this.love,
    required this.money,
    required this.health,
    required this.work,
  });
  
  @override
  List<Object?> get props => [love, money, health, work];
}
```

#### Screen (Presentation Layer)
```dart
// features/fortune/presentation/screens/daily_fortune_screen.dart
class DailyFortuneScreen extends ConsumerWidget {
  final DateTime selectedDate;
  
  const DailyFortuneScreen({
    Key? key,
    required this.selectedDate,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fortuneAsync = ref.watch(dailyFortuneProvider(selectedDate));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${selectedDate.formatKorean()} 운세'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context, ref),
          ),
        ],
      ),
      body: fortuneAsync.when(
        data: (fortune) => _buildFortuneContent(context, fortune),
        loading: () => const Center(child: FortuneLoadingAnimation()),
        error: (error, stack) => ErrorRetryWidget(
          message: _getErrorMessage(error),
          onRetry: () => ref.refresh(dailyFortuneProvider(selectedDate)),
        ),
      ),
    );
  }
  
  Widget _buildFortuneContent(BuildContext context, DailyFortune fortune) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 종합 점수
          OverallScoreCard(score: fortune.overallScore),
          const SizedBox(height: 24),
          
          // 카테고리별 점수
          CategoryScoresGrid(scores: fortune.categoryScores),
          const SizedBox(height: 24),
          
          // 행운의 아이템
          LuckyItemsCard(items: fortune.luckyItems),
          const SizedBox(height: 24),
          
          // 오늘의 조언
          AdviceCard(advice: fortune.advice),
          const SizedBox(height: 32),
          
          // 공유 버튼
          FortuneShareButton(fortune: fortune),
        ],
      ),
    );
  }
}
```

### 2. Navigation Guard 예제
```dart
// config/routes/route_guards.dart
class AuthGuard extends GoRouteGuard {
  final AuthRepository authRepository;
  
  AuthGuard(this.authRepository);
  
  @override
  Future<String?> redirect(BuildContext context, GoRouterState state) async {
    final isAuthenticated = await authRepository.isAuthenticated();
    
    if (!isAuthenticated && !_isPublicRoute(state.location)) {
      return '/login?redirect=${state.location}';
    }
    
    if (isAuthenticated && state.location == '/login') {
      return '/home';
    }
    
    return null;
  }
  
  bool _isPublicRoute(String location) {
    const publicRoutes = ['/login', '/signup', '/forgot-password'];
    return publicRoutes.any((route) => location.startsWith(route));
  }
}
```

### 3. API Client 설정
```dart
// core/network/api_client.dart
class ApiClient {
  late final Dio _dio;
  
  ApiClient({required String baseUrl, required List<Interceptor> interceptors}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    _dio.interceptors.addAll([
      ...interceptors,
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    ]);
  }
  
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data!;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('Connection timeout');
      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response?.statusCode);
      case DioExceptionType.cancel:
        return RequestCancelledException();
      default:
        return NetworkException('No internet connection');
    }
  }
}
```

---

## 마이그레이션 매핑

### Next.js → Flutter 컴포넌트 매핑

| Next.js | Flutter |
|---------|---------|
| `app/page.tsx` | `screens/*_screen.dart` |
| `components/*.tsx` | `widgets/*.dart` |
| `app/api/route.ts` | `data/datasources/*_api.dart` |
| `lib/services/*.ts` | `domain/usecases/*.dart` |
| `contexts/*.tsx` | `providers/*.dart` |
| `hooks/*.ts` | `providers/*.dart` 또는 `hooks/*.dart` |
| `lib/utils/*.ts` | `core/utils/*.dart` |

### 주요 패키지 매핑

| Next.js Package | Flutter Package | 용도 |
|----------------|-----------------|------|
| `next/navigation` | `go_router` | 라우팅 |
| `@supabase/supabase-js` | `supabase_flutter` | 백엔드 |
| `react-hook-form` | `flutter_form_builder` | 폼 관리 |
| `framer-motion` | `flutter_animate` | 애니메이션 |
| `@tanstack/react-query` | `flutter_riverpod` | 상태 관리 |
| `tailwindcss` | Flutter Theme | 스타일링 |
| `next-auth` | `firebase_auth` 또는 Supabase Auth | 인증 |

### 폴더 구조 변환 예시

**Next.js 구조:**
```
app/
  fortune/
    daily/
      page.tsx
  api/
    fortune/
      daily/
        route.ts
components/
  fortune/
    DailyFortuneCard.tsx
lib/
  services/
    fortune-service.ts
```

**Flutter 구조:**
```
features/
  fortune/
    presentation/
      screens/
        daily_fortune_screen.dart
      widgets/
        daily_fortune_card.dart
    domain/
      usecases/
        get_daily_fortune.dart
    data/
      datasources/
        fortune_api.dart
```

---

## 개발 시작 가이드

### 1. 프로젝트 생성
```bash
flutter create flutter_fortune --org com.fortune --platforms ios,android,web
cd flutter_fortune
```

### 2. 기본 패키지 설치
```bash
flutter pub add \
  flutter_riverpod \
  go_router \
  dio \
  equatable \
  dartz \
  get_it \
  flutter_secure_storage \
  hive_flutter \
  supabase_flutter \
  flutter_dotenv \
  intl \
  cached_network_image \
  flutter_animate \
  json_annotation \
  freezed_annotation

flutter pub add --dev \
  build_runner \
  json_serializable \
  freezed \
  flutter_test \
  mockito \
  flutter_lints
```

### 3. 프로젝트 구조 생성
```bash
# 기본 폴더 구조 생성 스크립트
mkdir -p lib/{core,features,shared,config}
mkdir -p lib/core/{constants,errors,extensions,theme,utils,network}
mkdir -p lib/features/{auth,fortune,user_profile,payment,token}
mkdir -p lib/features/auth/{data,domain,presentation}
mkdir -p lib/shared/{widgets,providers,services}
mkdir -p lib/config/{routes,localization,environment}
mkdir -p test/{unit,widget,integration}
mkdir -p assets/{images,animations,fonts}
```

### 4. 환경 설정
```bash
# .env 파일 생성
echo "SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
OPENAI_API_KEY=your_openai_api_key" > .env

# Git에서 제외
echo ".env" >> .gitignore
```

---

이 문서는 Fortune 앱을 Flutter로 마이그레이션하기 위한 완전한 프로젝트 구조 가이드입니다. Clean Architecture 원칙을 따르며, 확장 가능하고 테스트 가능한 코드베이스를 제공합니다.