import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/fortune.dart';
import '../../models/fortune_response_model.dart';
import 'package:fortune/services/cache_service.dart';
import '../../../models/fortune_model.dart';

class SajuFortuneApi {
  final ApiClient _apiClient;
  final CacheService _cacheService;

  SajuFortuneApi(this._apiClient, this._cacheService);

  // Saju Fortune
  Future<Fortune> getSajuFortune(
      {required String userId, required DateTime birthDate}) async {
    final stopwatch = Logger.startTimer('getSajuFortune - Total');

    Logger.info('🔍 [FortuneApiService] getSajuFortune called', {
      'userId': userId,
      'birthDate': birthDate.toIso8601String(),
      'age': DateTime.now().year - birthDate.year
    });

    final params = {'userId': userId, 'birthDate': birthDate.toIso8601String()};

    // Check cache first
    Logger.debug('🔍 [FortuneApiService] Checking cache for saju fortune...');
    final cacheStopwatch = Logger.startTimer('Cache Check - saju');
    final cachedFortune = await _cacheService.getCachedFortune('saju', params);
    Logger.endTimer('Cache Check - saju', cacheStopwatch);

    if (cachedFortune != null) {
      Logger.info(
          '💾 [FortuneApiService] Cache hit! Returning cached saju fortune',
          {'cacheTime': '${cacheStopwatch.elapsedMilliseconds}ms'});
      Logger.endTimer('getSajuFortune - Total', stopwatch);
      return _fortuneModelToEntity(cachedFortune);
    }
    Logger.debug('🔍 [FortuneApiService] Cache miss - fetching from API');

    try {
      Logger.debug('🔍 [FortuneApiService] Making API call', {
        'endpoint': ApiEndpoints.sajuFortune,
        'birthDate': birthDate.toIso8601String()
      });

      final apiStopwatch = Logger.startTimer('API Call - saju');
      final response = await _apiClient.post(ApiEndpoints.sajuFortune,
          data: {'birthDate': birthDate.toIso8601String()});
      Logger.endTimer('API Call - saju', apiStopwatch);

      Logger.info('🔍 [FortuneApiService] API response received', {
        'statusCode': _getStatusCode(response),
        'apiTime': '${apiStopwatch.elapsedMilliseconds}ms'
      });

      final fortuneResponse =
          FortuneResponseModel.fromJson(_getResponseData(response));
      final fortune = fortuneResponse.toEntity();

      Logger.info(
          '🔍 [FortuneApiService] Saju fortune processed successfully', {
        'fortuneId': fortune.id,
        'overallScore': fortune.overallScore,
        'tokensUsed': fortune.tokenCost
      });

      // Cache the result
      Logger.debug('🔍 [FortuneApiService] Caching fortune result...');
      final cacheWriteStopwatch = Logger.startTimer('Cache Write - saju');
      await _cacheService.cacheFortune(
          'saju', params, _entityToFortuneModel(fortune, 'saju'));
      Logger.endTimer('Cache Write - saju', cacheWriteStopwatch);

      Logger.endTimer('getSajuFortune - Total', stopwatch);
      Logger.info('✅ [FortuneApiService] getSajuFortune completed', {
        'totalTime': '${stopwatch.elapsedMilliseconds}ms',
        'fromCache': false
      });

      return fortune;
    } on DioException catch (e) {
      Logger.error('❌ [FortuneApiService] DioException in getSajuFortune', {
        'type': e.type.toString(),
        'message': e.message,
        'statusCode': e.response?.statusCode
      });

      // If network error and cache exists, return cached data
      if (_isNetworkError(e)) {
        Logger.warning(
            '🔍 [FortuneApiService] Network error detected, checking offline cache...');
        final cachedFortune =
            await _cacheService.getCachedFortune('saju', params);
        if (cachedFortune != null) {
          Logger.info('Network error: returning cached saju fortune');
          Logger.endTimer('getSajuFortune - Total', stopwatch);
          return _fortuneModelToEntity(cachedFortune);
        }
      }
      Logger.endTimer('getSajuFortune - Total', stopwatch);
      rethrow;
    } catch (e, stackTrace) {
      Logger.endTimer('getSajuFortune - Total', stopwatch);
      Logger.error('❌ [FortuneApiService] Unexpected error in getSajuFortune',
          e, stackTrace);
      rethrow;
    }
  }

  // Tojeong Fortune - delegates to generic getFortune
  Future<Fortune> getTojeongFortune(
      {required String userId,
      required Future<Fortune> Function(
              {required String fortuneType, required String userId})
          getFortune}) async {
    return getFortune(fortuneType: 'tojeong', userId: userId);
  }

  // Helper methods
  bool _isNetworkError(DioException error) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout;
  }

  int? _getStatusCode(dynamic response) {
    if (response is Response) {
      return response.statusCode;
    } else if (response is Map<String, dynamic>) {
      return 200;
    }
    return null;
  }

  dynamic _getResponseData(dynamic response) {
    if (response is Response) {
      return response.data;
    } else if (response is Map<String, dynamic>) {
      return response;
    }
    return response;
  }

  FortuneModel _entityToFortuneModel(Fortune fortune, String type) {
    return FortuneModel(
        id: fortune.id,
        userId: fortune.userId,
        type: type,
        content: fortune.content,
        createdAt: fortune.createdAt,
        metadata: fortune.metadata,
        tokenCost: fortune.tokenCost);
  }

  Fortune _fortuneModelToEntity(FortuneModel model) {
    return model.toEntity();
  }
}
