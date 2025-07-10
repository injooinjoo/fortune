import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/fortune.dart';
import '../models/fortune_response_model.dart';
import '../../core/providers/providers.dart';
import 'package:fortune/services/cache_service.dart';
import 'package:fortune/models/fortune_model.dart';
import 'package:flutter/foundation.dart';

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
    required Map<String, dynamic> financialData,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.wealthFortune,
        data: financialData,
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
    required List<String> categories,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.mbtiFortune,
        data: {
          'mbtiType': mbtiType,
          'categories': categories,
        },
      );

      final fortuneResponse = FortuneResponseModel.fromJson(response.data);
      return fortuneResponse.toEntity();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
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