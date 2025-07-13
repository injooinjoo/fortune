import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/core/network/api_client.dart';
import 'package:fortune/core/constants/api_endpoints.dart';
import 'package:fortune/core/errors/exceptions.dart';
import 'package:fortune/domain/entities/fortune.dart';
import 'package:fortune/data/models/fortune_response_model.dart';
import 'package:fortune/core/cache/cache_service.dart';
import 'package:fortune/core/utils/logger.dart';
import 'package:fortune/presentation/providers/offline_mode_provider.dart';
import 'package:fortune/data/services/token_api_service.dart';
import 'package:fortune/presentation/providers/providers.dart';

class FortuneApiServiceWithCache {
  final ApiClient _apiClient;
  final CacheService _cacheService;
  final Ref? _ref;

  FortuneApiServiceWithCache(this._apiClient, {Ref? ref}) 
    : _cacheService = CacheService(),
      _ref = ref;

  bool get _isOffline => _ref?.read(offlineModeProvider).isOffline ?? false;

  // Generic fortune fetcher with caching
  Future<Fortune> getFortune({
    required String fortuneType,
    required String userId,
    Map<String, dynamic>? additionalParams,
    String? endpoint,
  }) async {
    try {
      // Check cache first
      final cachedFortune = await _cacheService.getCachedFortune(fortuneType, userId);
      if (cachedFortune != null) {
        Logger.debug('Returning cached $fortuneType fortune');
        return cachedFortune;
      }

      // If offline and no cache, throw error
      if (_isOffline) {
        throw NetworkException('오프라인 상태입니다. 이전에 조회한 운세만 확인할 수 있습니다.');
      }

      // Fetch from API
      final response = await _apiClient.post(
        endpoint ?? '/api/fortune/$fortuneType',
        data: {
          'userId': userId,
          ...?additionalParams,
        },
      );

      final fortuneResponse = FortuneResponseModel.fromJson(response.data);
      final fortune = fortuneResponse.toEntity();

      // Cache the result
      await _cacheService.cacheFortune(fortune);

      return fortune;
    } on DioException catch (e) {
      // If network error, try cache again
      if (_isNetworkError(e)) {
        final cachedFortune = await _cacheService.getCachedFortune(fortuneType, userId);
        if (cachedFortune != null) {
          Logger.info('Network error: returning cached $fortuneType fortune');
          return cachedFortune;
        }
      }
      throw _handleDioError(e);
    }
  }

  // Daily Fortune
  Future<Fortune> getDailyFortune({
    required String userId,
    DateTime? date,
  }) async {
    return getFortune(
      fortuneType: 'daily',
      userId: userId,
      additionalParams: {
        if (date != null) 'date': date.toIso8601String(),
      },
      endpoint: ApiEndpoints.dailyFortune,
    );
  }

  // Today's Fortune
  Future<Fortune> getTodayFortune({required String userId}) async {
    return getFortune(
      fortuneType: 'today',
      userId: userId,
      endpoint: ApiEndpoints.today,
    );
  }

  // Tomorrow's Fortune
  Future<Fortune> getTomorrowFortune({required String userId}) async {
    return getFortune(
      fortuneType: 'tomorrow',
      userId: userId,
      endpoint: ApiEndpoints.tomorrow,
    );
  }

  // Weekly Fortune
  Future<Fortune> getWeeklyFortune({required String userId}) async {
    return getFortune(
      fortuneType: 'weekly',
      userId: userId,
      endpoint: ApiEndpoints.weekly,
    );
  }

  // Monthly Fortune
  Future<Fortune> getMonthlyFortune({required String userId}) async {
    return getFortune(
      fortuneType: 'monthly',
      userId: userId,
      endpoint: ApiEndpoints.monthly,
    );
  }

  // Saju Fortune
  Future<Fortune> getSajuFortune({
    required String userId,
    required DateTime birthDate,
  }) async {
    return getFortune(
      fortuneType: 'saju',
      userId: userId,
      additionalParams: {
        'birthDate': birthDate.toIso8601String(),
      },
      endpoint: ApiEndpoints.sajuFortune,
    );
  }

  // Compatibility Fortune
  Future<Fortune> getCompatibilityFortune({
    required String userId,
    required DateTime userBirthDate,
    required DateTime partnerBirthDate,
  }) async {
    return getFortune(
      fortuneType: 'compatibility',
      userId: userId,
      additionalParams: {
        'userBirthDate': userBirthDate.toIso8601String(),
        'partnerBirthDate': partnerBirthDate.toIso8601String(),
      },
      endpoint: ApiEndpoints.compatibilityFortune,
    );
  }

  // MBTI Fortune
  Future<Fortune> getMbtiFortune({
    required String userId,
    required String mbtiType,
  }) async {
    return getFortune(
      fortuneType: 'mbti',
      userId: userId,
      additionalParams: {
        'mbtiType': mbtiType,
      },
      endpoint: ApiEndpoints.mbtiFortune,
    );
  }

  // Love Fortune
  Future<Fortune> getLoveFortune({
    required String userId,
    required String relationshipStatus,
  }) async {
    return getFortune(
      fortuneType: 'love',
      userId: userId,
      additionalParams: {
        'relationshipStatus': relationshipStatus,
      },
      endpoint: ApiEndpoints.loveFortune,
    );
  }

  // Wealth Fortune
  Future<Fortune> getWealthFortune({required String userId}) async {
    return getFortune(
      fortuneType: 'wealth',
      userId: userId,
      endpoint: ApiEndpoints.wealthFortune,
    );
  }

  // Generic fortune generator for all types
  Future<Fortune> generateFortune({
    required String fortuneType,
    required String userId,
    Map<String, dynamic>? additionalData,
  }) async {
    return getFortune(
      fortuneType: fortuneType,
      userId: userId,
      additionalParams: additionalData,
      endpoint: '/api/fortune/$fortuneType',
    );
  }

  // Get fortune history from cache
  Future<List<Fortune>> getFortuneHistory({required String userId}) async {
    try {
      final cachedFortunes = await _cacheService.getAllCachedFortunes(userId);
      return cachedFortunes;
    } catch (e) {
      Logger.error('Failed to get fortune history', e);
      return [];
    }
  }

  // Clear user's fortune cache
  Future<void> clearUserCache({required String userId}) async {
    await _cacheService.clearFortuneCache(userId: userId);
  }

  // Helper methods
  bool _isNetworkError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
           e.type == DioExceptionType.sendTimeout ||
           e.type == DioExceptionType.receiveTimeout ||
           e.type == DioExceptionType.connectionError;
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException('네트워크 연결 오류가 발생했습니다.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final message = e.response?.data['message'] ?? '알 수 없는 오류가 발생했습니다.';
        
        if (statusCode == 401) {
          return UnauthorizedException(message);
        } else if (statusCode == 402) {
          return InsufficientTokensException(message);
        } else if (statusCode >= 400 && statusCode < 500) {
          return ServerException(message: message);
        } else {
          return ServerException(message: '서버 오류가 발생했습니다. (${statusCode})');
        }
      default:
        return ServerException(message: '예상치 못한 오류가 발생했습니다.');
    }
  }
}

// Provider for the cached fortune service
final fortuneApiServiceWithCacheProvider = Provider.family<FortuneApiServiceWithCache, Ref>((ref, selfRef) {
  final apiClient = ref.watch(apiClientProvider);
  return FortuneApiServiceWithCache(apiClient, ref: selfRef);
});