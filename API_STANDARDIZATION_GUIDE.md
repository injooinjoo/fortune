# Flutter API Integration Guide

## 개요
Fortune Flutter 앱의 API 통신 표준화 가이드입니다. 모든 API 호출은 Dio와 Retrofit을 사용하여 타입 안전성을 보장합니다.

## API 클라이언트 설정

### Dio 인스턴스 설정
```dart
// lib/data/datasources/remote/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage;
  
  ApiClient(this._storage) {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _dio.interceptors.addAll([
      AuthInterceptor(_storage),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }
}
```

### 인증 인터셉터
```dart
// lib/data/datasources/remote/interceptors/auth_interceptor.dart
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  
  AuthInterceptor(this._storage);
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // 토큰 갱신 로직
      final refreshed = await _refreshToken();
      if (refreshed) {
        // 원래 요청 재시도
        return handler.resolve(await _retry(err.requestOptions));
      }
    }
    super.onError(err, handler);
  }
}
```

## Retrofit API 서비스 정의

### Fortune API 서비스
```dart
// lib/data/datasources/remote/services/fortune_api_service.dart
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'fortune_api_service.g.dart';

@RestApi()
abstract class FortuneApiService {
  factory FortuneApiService(Dio dio) = _FortuneApiService;
  
  @POST('/fortune/generate-batch')
  Future<ApiResponse<FortuneData>> generateBatchFortune(
    @Body() BatchFortuneRequest request,
  );
  
  @GET('/fortune/{type}')
  Future<ApiResponse<FortuneData>> getFortune(
    @Path('type') String fortuneType,
    @Query('user_id') String userId,
  );
  
  @GET('/fortune/history')
  Future<ApiResponse<List<FortuneHistory>>> getFortuneHistory(
    @Query('user_id') String userId,
    @Query('limit') int limit,
  );
}
```

## 표준 응답 모델

### API 응답 래퍼
```dart
// lib/data/models/api/api_response.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';
part 'api_response.g.dart';

@Freezed(genericArgumentFactories: true)
class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    required bool success,
    T? data,
    String? message,
    ApiError? error,
    ApiMetadata? metadata,
  }) = _ApiResponse<T>;
  
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$ApiResponseFromJson<T>(json, fromJsonT);
}

@freezed
class ApiError with _$ApiError {
  const factory ApiError({
    required String message,
    required String code,
    Map<String, dynamic>? details,
  }) = _ApiError;
  
  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);
}

@freezed
class ApiMetadata with _$ApiMetadata {
  const factory ApiMetadata({
    required String timestamp,
    String? fortuneType,
    String? userId,
  }) = _ApiMetadata;
  
  factory ApiMetadata.fromJson(Map<String, dynamic> json) =>
      _$ApiMetadataFromJson(json);
}
```

## Repository 패턴 구현

### Fortune Repository
```dart
// lib/data/repositories/fortune_repository_impl.dart
class FortuneRepositoryImpl implements FortuneRepository {
  final FortuneApiService _apiService;
  final FortuneLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  
  FortuneRepositoryImpl({
    required FortuneApiService apiService,
    required FortuneLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _apiService = apiService,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo;
  
  @override
  Future<Either<Failure, FortuneData>> getDailyFortune(String userId) async {
    try {
      // 1. 로컬 캐시 확인
      final cached = await _localDataSource.getCachedFortune(
        userId: userId,
        fortuneType: 'daily',
      );
      
      if (cached != null && !cached.isExpired) {
        return Right(cached);
      }
      
      // 2. 네트워크 연결 확인
      if (!await _networkInfo.isConnected) {
        if (cached != null) {
          return Right(cached); // 만료되었지만 오프라인이므로 반환
        }
        return Left(NetworkFailure('No internet connection'));
      }
      
      // 3. API 호출
      final response = await _apiService.getFortune('daily', userId);
      
      if (response.success && response.data != null) {
        // 4. 로컬 저장
        await _localDataSource.cacheFortune(response.data!);
        return Right(response.data!);
      }
      
      return Left(ServerFailure(response.error?.message ?? 'Unknown error'));
      
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
  
  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkFailure('Connection timeout');
      case DioExceptionType.connectionError:
        return NetworkFailure('No internet connection');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 402) {
          return TokenFailure('Insufficient tokens');
        }
        return ServerFailure('Server error: $statusCode');
      default:
        return UnexpectedFailure(error.message ?? 'Unknown error');
    }
  }
}
```

## 에러 처리

### Failure 클래스
```dart
// lib/core/errors/failures.dart
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  
  const Failure(this.message, [this.code]);
  
  @override
  List<Object?> get props => [message, code];
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message, 'NETWORK_ERROR');
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message, 'SERVER_ERROR');
}

class TokenFailure extends Failure {
  const TokenFailure(String message) : super(message, 'TOKEN_ERROR');
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message, 'CACHE_ERROR');
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure(String message) : super(message, 'UNEXPECTED_ERROR');
}
```

## UI에서의 사용

### Provider를 통한 상태 관리
```dart
// lib/presentation/providers/fortune_provider.dart
@riverpod
class DailyFortune extends _$DailyFortune {
  @override
  Future<FortuneData?> build() async {
    final userId = ref.watch(currentUserProvider)?.id;
    if (userId == null) return null;
    
    final repository = ref.watch(fortuneRepositoryProvider);
    final result = await repository.getDailyFortune(userId);
    
    return result.fold(
      (failure) {
        // 에러 처리
        ref.read(errorNotifierProvider.notifier).showError(failure.message);
        return null;
      },
      (fortune) => fortune,
    );
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}
```

### UI에서 사용
```dart
// lib/presentation/screens/daily_fortune_screen.dart
class DailyFortuneScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fortuneAsync = ref.watch(dailyFortuneProvider);
    
    return fortuneAsync.when(
      data: (fortune) => fortune != null
          ? FortuneDetailView(fortune: fortune)
          : const EmptyFortuneView(),
      loading: () => const FortuneLoadingView(),
      error: (error, stack) => FortuneErrorView(
        message: error.toString(),
        onRetry: () => ref.refresh(dailyFortuneProvider),
      ),
    );
  }
}
```

## 모의 데이터 (개발/테스트용)

### Mock API Service
```dart
// lib/data/datasources/remote/services/mock_fortune_api_service.dart
class MockFortuneApiService implements FortuneApiService {
  @override
  Future<ApiResponse<FortuneData>> getDailyFortune(String userId) async {
    await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션
    
    return ApiResponse(
      success: true,
      data: FortuneData(
        fortuneType: 'daily',
        userId: userId,
        content: '오늘은 좋은 일이 생길 예정입니다.',
        scores: FortuneScores(
          overall: 85,
          love: 75,
          career: 90,
          wealth: 80,
        ),
        generatedAt: DateTime.now(),
      ),
      metadata: ApiMetadata(
        timestamp: DateTime.now().toIso8601String(),
        fortuneType: 'daily',
        userId: userId,
      ),
    );
  }
}
```

## API 호출 최적화

### 배치 요청
```dart
// 여러 운세를 한 번에 요청
final batchRequest = BatchFortuneRequest(
  userId: userId,
  fortuneTypes: ['daily', 'love', 'career', 'wealth'],
  userProfile: UserProfile(
    birthDate: birthDate,
    mbti: 'ENFP',
    gender: 'female',
  ),
);

final response = await apiService.generateBatchFortune(batchRequest);
```

### 캐싱 전략
```dart
// 운세 타입별 캐시 기간
const CACHE_DURATIONS = {
  'life_profile': Duration(days: 365), // 평생 운세
  'daily': Duration(hours: 24),        // 일일 운세
  'interactive': Duration(days: 7),    // 상호작용 운세
};
```

## 보안 고려사항

1. **API 키 관리**: 절대 하드코딩하지 않고 환경 변수 사용
2. **인증서 피닝**: 중간자 공격 방지
3. **토큰 저장**: flutter_secure_storage 사용
4. **요청 암호화**: 민감한 데이터는 암호화하여 전송
5. **Rate Limiting**: 클라이언트에서도 요청 빈도 제한

## 테스트 가이드

### Repository 테스트
```dart
// test/data/repositories/fortune_repository_test.dart
void main() {
  group('FortuneRepository', () {
    late FortuneRepository repository;
    late MockFortuneApiService mockApiService;
    late MockFortuneLocalDataSource mockLocalDataSource;
    
    setUp(() {
      mockApiService = MockFortuneApiService();
      mockLocalDataSource = MockFortuneLocalDataSource();
      repository = FortuneRepositoryImpl(
        apiService: mockApiService,
        localDataSource: mockLocalDataSource,
        networkInfo: MockNetworkInfo(),
      );
    });
    
    test('should return cached data when available and not expired', () async {
      // Given
      when(() => mockLocalDataSource.getCachedFortune(any(), any()))
          .thenAnswer((_) async => testFortuneData);
      
      // When
      final result = await repository.getDailyFortune('user123');
      
      // Then
      expect(result.isRight(), true);
      verifyNever(() => mockApiService.getFortune(any(), any()));
    });
  });
}
```