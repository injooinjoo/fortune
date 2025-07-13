import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/fortune.dart';
import '../models/fortune_response_model.dart';
import '../../presentation/providers/providers.dart';
import 'package:fortune/services/cache_service.dart';
import 'package:fortune/models/fortune_model.dart';
import 'package:flutter/foundation.dart';
import '../../core/config/feature_flags.dart';
import 'fortune_api_service_edge_functions.dart';

class FortuneApiService {
  final ApiClient _apiClient;
  final CacheService _cacheService;

  FortuneApiService(this._apiClient) : _cacheService = CacheService();

  // Daily Fortune
  Future<Fortune> getDailyFortune({
    required String userId,
    DateTime? date,
  }) async {
    final params = {
      'userId': userId,
      if (date != null) 'date': date.toIso8601String(),
    };

    // Check cache first
    final cachedFortune = await _cacheService.getCachedFortune('daily', params);
    if (cachedFortune != null) {
      debugPrint('Returning cached daily fortune');
      return _fortuneModelToEntity(cachedFortune);
    }

    try {
      final queryParams = {
        if (date != null) 'date': date.toIso8601String(),
      };

      final response = await _apiClient.get(
        ApiEndpoints.dailyFortune,
        queryParameters: queryParams,
      );

      final fortuneResponse = FortuneResponseModel.fromJson(response.data);
      final fortune = fortuneResponse.toEntity();

      // Cache the result
      await _cacheService.cacheFortune(
        'daily',
        params,
        _entityToFortuneModel(fortune, 'daily'),
      );

      return fortune;
    } on DioException catch (e) {
      // If network error and cache exists, return cached data
      if (_isNetworkError(e)) {
        final cachedFortune = await _cacheService.getCachedFortune('daily', params);
        if (cachedFortune != null) {
          debugPrint('Network error: returning cached daily fortune');
          return _fortuneModelToEntity(cachedFortune);
        }
      }
      throw _handleDioError(e);
    }
  }

  // Generate Daily Fortune (for compatibility)
  Future<Fortune> generateDailyFortune({
    required String userId,
    DateTime? date,
  }) async {
    return getDailyFortune(userId: userId, date: date);
  }

  // Saju Fortune
  Future<Fortune> getSajuFortune({
    required String userId,
    required DateTime birthDate,
  }) async {
    final params = {
      'userId': userId,
      'birthDate': birthDate.toIso8601String(),
    };

    // Check cache first
    final cachedFortune = await _cacheService.getCachedFortune('saju', params);
    if (cachedFortune != null) {
      debugPrint('Returning cached saju fortune');
      return _fortuneModelToEntity(cachedFortune);
    }

    try {
      final response = await _apiClient.post(
        ApiEndpoints.sajuFortune,
        data: {
          'birthDate': birthDate.toIso8601String(),
        },
      );

      final fortuneResponse = FortuneResponseModel.fromJson(response.data);
      final fortune = fortuneResponse.toEntity();

      // Cache the result
      await _cacheService.cacheFortune(
        'saju',
        params,
        _entityToFortuneModel(fortune, 'saju'),
      );

      return fortune;
    } on DioException catch (e) {
      // If network error and cache exists, return cached data
      if (_isNetworkError(e)) {
        final cachedFortune = await _cacheService.getCachedFortune('saju', params);
        if (cachedFortune != null) {
          debugPrint('Network error: returning cached saju fortune');
          return _fortuneModelToEntity(cachedFortune);
        }
      }
      throw _handleDioError(e);
    }
  }

  // Compatibility Fortune
  Future<Fortune> getCompatibilityFortune({
    required Map<String, dynamic> person1,
    required Map<String, dynamic> person2,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.compatibilityFortune,
        data: {
          'person1': person1,
          'person2': person2,
        },
      );

      final fortuneResponse = FortuneResponseModel.fromJson(response.data);
      return fortuneResponse.toEntity();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Love Fortune
  Future<Fortune> getLoveFortune({
    required String userId,
  }) async {
    final params = {
      'userId': userId,
    };

    // Check cache first
    final cachedFortune = await _cacheService.getCachedFortune('love', params);
    if (cachedFortune != null) {
      debugPrint('Returning cached love fortune');
      return _fortuneModelToEntity(cachedFortune);
    }

    try {
      final response = await _apiClient.get(ApiEndpoints.loveFortune);

      final fortuneResponse = FortuneResponseModel.fromJson(response.data);
      final fortune = fortuneResponse.toEntity();

      // Cache the result
      await _cacheService.cacheFortune(
        'love',
        params,
        _entityToFortuneModel(fortune, 'love'),
      );

      return fortune;
    } on DioException catch (e) {
      // If network error and cache exists, return cached data
      if (_isNetworkError(e)) {
        final cachedFortune = await _cacheService.getCachedFortune('love', params);
        if (cachedFortune != null) {
          debugPrint('Network error: returning cached love fortune');
          return _fortuneModelToEntity(cachedFortune);
        }
      }
      throw _handleDioError(e);
    }
  }

  // Wealth Fortune
  Future<Fortune> getWealthFortune({
    required String userId,
    Map<String, dynamic>? financialData,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.wealthFortune,
        data: financialData ?? {},
      );

      final fortuneResponse = FortuneResponseModel.fromJson(response.data);
      return fortuneResponse.toEntity();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // MBTI Fortune
  Future<Fortune> getMbtiFortune({
    required String userId,
    required String mbtiType,
    List<String>? categories,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.mbtiFortune,
        data: {
          'mbtiType': mbtiType,
          if (categories != null) 'categories': categories,
        },
      );

      final fortuneResponse = FortuneResponseModel.fromJson(response.data);
      return fortuneResponse.toEntity();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Today Fortune
  Future<Fortune> getTodayFortune({required String userId}) async {
    return getDailyFortune(userId: userId, date: DateTime.now());
  }

  // Tomorrow Fortune
  Future<Fortune> getTomorrowFortune({required String userId}) async {
    return getDailyFortune(userId: userId, date: DateTime.now().add(Duration(days: 1)));
  }

  // Weekly Fortune
  Future<Fortune> getWeeklyFortune({required String userId}) async {
    return getFortune(fortuneType: 'weekly', userId: userId);
  }

  // Monthly Fortune
  Future<Fortune> getMonthlyFortune({required String userId}) async {
    return getFortune(fortuneType: 'monthly', userId: userId);
  }

  // Yearly Fortune
  Future<Fortune> getYearlyFortune({required String userId}) async {
    return getFortune(fortuneType: 'yearly', userId: userId);
  }

  // Hourly Fortune
  Future<Fortune> getHourlyFortune({
    required String userId,
    required DateTime targetTime,
  }) async {
    return getFortune(
      fortuneType: 'hourly',
      userId: userId,
      params: {'targetTime': targetTime.toIso8601String()},
    );
  }

  // Zodiac Fortune
  Future<Fortune> getZodiacFortune({
    required String userId,
    required String zodiacSign,
  }) async {
    return getFortune(
      fortuneType: 'zodiac',
      userId: userId,
      params: {'zodiacSign': zodiacSign},
    );
  }

  // Zodiac Animal Fortune
  Future<Fortune> getZodiacAnimalFortune({
    required String userId,
    required String zodiacAnimal,
  }) async {
    return getFortune(
      fortuneType: 'zodiac-animal',
      userId: userId,
      params: {'zodiacAnimal': zodiacAnimal},
    );
  }

  // Blood Type Fortune
  Future<Fortune> getBloodTypeFortune({
    required String userId,
    required String bloodType,
  }) async {
    return getFortune(
      fortuneType: 'blood-type',
      userId: userId,
      params: {'bloodType': bloodType},
    );
  }

  // Tojeong Fortune
  Future<Fortune> getTojeongFortune({required String userId}) async {
    return getFortune(fortuneType: 'tojeong', userId: userId);
  }

  // Palmistry Fortune
  Future<Fortune> getPalmistryFortune({required String userId}) async {
    return getFortune(fortuneType: 'palmistry', userId: userId);
  }

  // Physiognomy Fortune
  Future<Fortune> getPhysiognomyFortune({required String userId}) async {
    return getFortune(fortuneType: 'physiognomy', userId: userId);
  }

  // Marriage Fortune
  Future<Fortune> getMarriageFortune({required String userId}) async {
    return getFortune(fortuneType: 'marriage', userId: userId);
  }

  // Career Fortune
  Future<Fortune> getCareerFortune({required String userId}) async {
    return getFortune(fortuneType: 'career', userId: userId);
  }

  // Business Fortune
  Future<Fortune> getBusinessFortune({required String userId}) async {
    return getFortune(fortuneType: 'business', userId: userId);
  }

  // Employment Fortune
  Future<Fortune> getEmploymentFortune({required String userId}) async {
    return getFortune(fortuneType: 'employment', userId: userId);
  }

  // Startup Fortune
  Future<Fortune> getStartupFortune({required String userId}) async {
    return getFortune(fortuneType: 'startup', userId: userId);
  }

  // Lucky Color Fortune
  Future<Fortune> getLuckyColorFortune({required String userId}) async {
    return getFortune(fortuneType: 'lucky-color', userId: userId);
  }

  // Lucky Number Fortune
  Future<Fortune> getLuckyNumberFortune({required String userId}) async {
    return getFortune(fortuneType: 'lucky-number', userId: userId);
  }

  // Lucky Items Fortune
  Future<Fortune> getLuckyItemsFortune({required String userId}) async {
    return getFortune(fortuneType: 'lucky-items', userId: userId);
  }

  // Lucky Food Fortune
  Future<Fortune> getLuckyFoodFortune({required String userId}) async {
    return getFortune(fortuneType: 'lucky-food', userId: userId);
  }

  // Biorhythm Fortune
  Future<Fortune> getBiorhythmFortune({required String userId}) async {
    return getFortune(fortuneType: 'biorhythm', userId: userId);
  }

  // Past Life Fortune
  Future<Fortune> getPastLifeFortune({required String userId}) async {
    return getFortune(fortuneType: 'past-life', userId: userId);
  }

  // New Year Fortune
  Future<Fortune> getNewYearFortune({required String userId}) async {
    return getFortune(fortuneType: 'new-year', userId: userId);
  }

  // Personality Fortune
  Future<Fortune> getPersonalityFortune({required String userId}) async {
    return getFortune(fortuneType: 'personality', userId: userId);
  }

  // Health Fortune
  Future<Fortune> getHealthFortune({required String userId}) async {
    return getFortune(fortuneType: 'health', userId: userId);
  }

  // Moving Fortune
  Future<Fortune> getMovingFortune({required String userId}) async {
    return getFortune(fortuneType: 'moving', userId: userId);
  }

  // Wish Fortune
  Future<Fortune> getWishFortune({
    required String userId,
    required String wish,
  }) async {
    return getFortune(
      fortuneType: 'wish',
      userId: userId,
      params: {'wish': wish},
    );
  }

  // Talent Fortune
  Future<Fortune> getTalentFortune({required String userId}) async {
    return getFortune(fortuneType: 'talent', userId: userId);
  }

  // Lucky Baseball Fortune
  Future<Fortune> getLuckyBaseballFortune({required String userId}) async {
    return getFortune(fortuneType: 'lucky-baseball', userId: userId);
  }

  // Lucky Golf Fortune
  Future<Fortune> getLuckyGolfFortune({required String userId}) async {
    return getFortune(fortuneType: 'lucky-golf', userId: userId);
  }

  // Lucky Tennis Fortune
  Future<Fortune> getLuckyTennisFortune({required String userId}) async {
    return getFortune(fortuneType: 'lucky-tennis', userId: userId);
  }

  // Lucky Running Fortune
  Future<Fortune> getLuckyRunningFortune({required String userId}) async {
    return getFortune(fortuneType: 'lucky-running', userId: userId);
  }

  // Lucky Cycling Fortune
  Future<Fortune> getLuckyCyclingFortune({required String userId}) async {
    return getFortune(fortuneType: 'lucky-cycling', userId: userId);
  }

  // Lucky Swim Fortune
  Future<Fortune> getLuckySwimFortune({required String userId}) async {
    return getFortune(fortuneType: 'lucky-swim', userId: userId);
  }

  // Lucky Hiking Fortune
  Future<Fortune> getLuckyHikingFortune({required String userId}) async {
    return getFortune(fortuneType: 'lucky-hiking', userId: userId);
  }

  // Lucky Fishing Fortune
  Future<Fortune> getLuckyFishingFortune({required String userId}) async {
    return getFortune(fortuneType: 'lucky-fishing', userId: userId);
  }

  // Generic Fortune
  Future<Fortune> getFortune({
    required String fortuneType,
    required String userId,
    Map<String, dynamic>? params,
  }) async {
    final cacheParams = {
      'userId': userId,
      ...?params,
    };

    // Check cache first
    final cachedFortune = await _cacheService.getCachedFortune(fortuneType, cacheParams);
    if (cachedFortune != null) {
      debugPrint('Returning cached $fortuneType fortune');
      return _fortuneModelToEntity(cachedFortune);
    }

    try {
      final endpoint = '/api/fortune/$fortuneType';
      final response = params != null
          ? await _apiClient.post(endpoint, data: params)
          : await _apiClient.get(endpoint);

      final fortuneResponse = FortuneResponseModel.fromJson(response.data);
      final fortune = fortuneResponse.toEntity();

      // Cache the result
      await _cacheService.cacheFortune(
        fortuneType,
        cacheParams,
        _entityToFortuneModel(fortune, fortuneType),
      );

      return fortune;
    } on DioException catch (e) {
      // If network error and cache exists, return cached data
      if (_isNetworkError(e)) {
        final cachedFortune = await _cacheService.getCachedFortune(fortuneType, cacheParams);
        if (cachedFortune != null) {
          debugPrint('Network error: returning cached $fortuneType fortune');
          return _fortuneModelToEntity(cachedFortune);
        }
      }
      throw _handleDioError(e);
    }
  }

  // Batch Fortune Generation
  Future<List<Fortune>> generateBatchFortunes({
    required String userId,
    required List<String> fortuneTypes,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.batchFortune,
        data: {
          'fortuneTypes': fortuneTypes,
        },
      );

      final fortunes = (response.data['fortunes'] as List)
          .map((json) => FortuneResponseModel.fromJson(json).toEntity())
          .toList();

      return fortunes;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Get Fortune History
  Future<List<Fortune>> getFortuneHistory({
    required String userId,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = {
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      };

      final response = await _apiClient.get(
        ApiEndpoints.fortuneHistory,
        queryParameters: queryParams,
      );

      final fortunes = (response.data['history'] as List)
          .map((json) => FortuneResponseModel.fromJson(json).toEntity())
          .toList();

      return fortunes;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Clear cache for specific fortune type
  Future<void> clearFortuneCache(String fortuneType, String userId) async {
    final params = {'userId': userId};
    await _cacheService.removeCachedFortune(fortuneType, params);
  }

  // Clear all cache
  Future<void> clearAllCache() async {
    await _cacheService.clearAllCache();
  }

  // Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    return await _cacheService.getCacheStats();
  }

  // Get offline fortunes by type
  Future<List<Fortune>> getOfflineFortunes(String fortuneType) async {
    final cachedModels = await _cacheService.getCachedFortunesByType(fortuneType);
    return cachedModels.map(_fortuneModelToEntity).toList();
  }

  // Get all cached fortunes for a user
  Future<List<Fortune>> getAllCachedFortunes(String userId, {bool includeExpired = false}) async {
    final cachedModels = await _cacheService.getAllCachedFortunesForUser(userId, includeExpired: includeExpired);
    return cachedModels.map(_fortuneModelToEntity).toList();
  }

  // Check if should use offline mode
  Future<bool> isOfflineMode() async {
    return await _cacheService.shouldUseOfflineMode();
  }

  // Get most recent cached fortune (for offline fallback)
  Future<Fortune?> getMostRecentCachedFortune(String fortuneType, String userId) async {
    final cachedModel = await _cacheService.getMostRecentCachedFortune(fortuneType, userId);
    return cachedModel != null ? _fortuneModelToEntity(cachedModel) : null;
  }

  // Preload fortunes for offline use
  Future<void> preloadForOfflineUse(String userId) async {
    final essentialFortuneTypes = ['daily', 'weekly', 'monthly', 'zodiac', 'personality'];
    
    for (final type in essentialFortuneTypes) {
      try {
        // Try to fetch and cache each fortune type
        await getFortune(
          fortuneType: type,
          userId: userId,
          params: {},
        );
        debugPrint('Preloaded $type fortune for offline use');
      } catch (e) {
        debugPrint('Failed to preload $type fortune: $e');
      }
    }
  }

  // Helper method to check if it's a network error
  bool _isNetworkError(DioException error) {
    return error.type == DioExceptionType.connectionError ||
           error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.sendTimeout ||
           error.type == DioExceptionType.receiveTimeout;
  }

  // Convert Fortune entity to FortuneModel for caching
  FortuneModel _entityToFortuneModel(Fortune fortune, String type) {
    return FortuneModel(
      id: fortune.id,
      userId: fortune.userId,
      type: type,
      content: fortune.content,
      createdAt: fortune.createdAt,
      metadata: fortune.metadata,
      tokenCost: fortune.tokenCost,
    );
  }

  // Convert FortuneModel to Fortune entity
  Fortune _fortuneModelToEntity(FortuneModel model) {
    return model.toEntity();
  }

  // Generic post method for API calls
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await _apiClient.post(endpoint, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Error Handler
  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('연결 시간이 초과되었습니다');
        
      case DioExceptionType.connectionError:
        return NetworkException('네트워크 연결을 확인해주세요');
        
      case DioExceptionType.cancel:
        return NetworkException('요청이 취소되었습니다');
        
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? '오류가 발생했습니다';
        
        switch (statusCode) {
          case 401:
            return const UnauthorizedException();
          case 403:
            return const ForbiddenException();
          case 404:
            return const NotFoundException();
          case 429:
            return const TooManyRequestsException('요청이 너무 많습니다. 잠시 후 다시 시도해주세요');
          case 500:
            return ServerException(message: '서버 오류가 발생했습니다', statusCode: 500);
          default:
            return ServerException(message: message, statusCode: statusCode);
        }
        
      default:
        return const UnknownException();
    }
  }
}

// Provider
final fortuneApiServiceProvider = Provider<FortuneApiService>((ref) {
  // Check if Edge Functions are enabled
  if (FeatureFlags().isEdgeFunctionsEnabled()) {
    debugPrint('Using Edge Functions for fortune API');
    return FortuneApiServiceWithEdgeFunctions(ref);
  }
  
  // Use traditional API service
  debugPrint('Using traditional API service');
  final apiClient = ref.watch(apiClientProvider);
  return FortuneApiService(apiClient);
});

// Token Exception
class InsufficientTokensException extends AppException {
  const InsufficientTokensException([String message = '토큰이 부족합니다']) 
      : super(message: message, code: 'INSUFFICIENT_TOKENS');
}

// Rate Limit Exception
class TooManyRequestsException extends AppException {
  const TooManyRequestsException([String message = '요청이 너무 많습니다']) 
      : super(message: message, code: 'TOO_MANY_REQUESTS');
}