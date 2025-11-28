import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/fortune.dart';
import '../../models/fortune_response_model.dart';
import 'package:fortune/services/cache_service.dart';
import '../../../models/fortune_model.dart';

class RelationshipFortuneApi {
  final ApiClient _apiClient;
  final CacheService _cacheService;

  RelationshipFortuneApi(this._apiClient, this._cacheService);

  // Compatibility Fortune
  Future<Fortune> getCompatibilityFortune({
    required Map<String, dynamic> person1,
    required Map<String, dynamic> person2}) async {
    final stopwatch = Logger.startTimer('getCompatibilityFortune - Total');

    Logger.info('🔍 [FortuneApiService] getCompatibilityFortune called', {
      'person1Name': person1['name'],
      'person2Name': person2['name'],
      'person1Keys': person1.keys.toList(),
      'person2Keys': person2.keys.toList()});

    try {
      Logger.debug('🔍 [FortuneApiService] Making API call', {
        'endpoint': ApiEndpoints.compatibilityFortune});

      final apiStopwatch = Logger.startTimer('API Call - compatibility');
      final response = await _apiClient.post(
        ApiEndpoints.compatibilityFortune,
        data: {
          'person1': person1,
          'person2': person2});
      Logger.endTimer('API Call - compatibility', apiStopwatch);

      Logger.info('🔍 [FortuneApiService] API response received', {
        'statusCode': _getStatusCode(response),
        'apiTime': '${apiStopwatch.elapsedMilliseconds}ms'});

      final fortuneResponse = FortuneResponseModel.fromJson(_getResponseData(response));
      final fortune = fortuneResponse.toEntity();

      Logger.endTimer('getCompatibilityFortune - Total', stopwatch);
      Logger.info('✅ [FortuneApiService] getCompatibilityFortune completed', {
        'fortuneId': fortune.id,
        'overallScore': fortune.overallScore,
        'totalTime': '${stopwatch.elapsedMilliseconds}ms'});

      return fortune;
    } on DioException catch (e) {
      Logger.endTimer('getCompatibilityFortune - Total', stopwatch);
      Logger.error('❌ [FortuneApiService] DioException in getCompatibilityFortune', {
        'type': e.type.toString(),
        'message': e.message,
        'statusCode': e.response?.statusCode});
      rethrow;
    } catch (e, stackTrace) {
      Logger.endTimer('getCompatibilityFortune - Total', stopwatch);
      Logger.error('❌ [FortuneApiService] Unexpected error in getCompatibilityFortune', e, stackTrace);
      rethrow;
    }
  }

  // Love Fortune
  Future<Fortune> getLoveFortune({
    required String userId}) async {
    final stopwatch = Logger.startTimer('getLoveFortune - Total');

    Logger.info('🔍 [FortuneApiService] getLoveFortune called', {
      'userId': userId});

    final params = {
      'userId': userId};

    // Check cache first
    Logger.debug('🔍 [FortuneApiService] Checking cache for love fortune...');
    final cacheStopwatch = Logger.startTimer('Cache Check - love');
    final cachedFortune = await _cacheService.getCachedFortune('love', params);
    Logger.endTimer('Cache Check - love', cacheStopwatch);

    if (cachedFortune != null) {
      Logger.info('💾 [FortuneApiService] Cache hit! Returning cached love fortune', {
        'cacheTime': '${cacheStopwatch.elapsedMilliseconds}ms'});
      Logger.endTimer('getLoveFortune - Total', stopwatch);
      return _fortuneModelToEntity(cachedFortune);
    }
    Logger.debug('🔍 [FortuneApiService] Cache miss - fetching from API');

    try {
      Logger.debug('🔍 [FortuneApiService] Making API call', {
        'endpoint': ApiEndpoints.loveFortune});

      final apiStopwatch = Logger.startTimer('API Call - love');
      final response = await _apiClient.get(ApiEndpoints.loveFortune);
      Logger.endTimer('API Call - love', apiStopwatch);

      Logger.info('🔍 [FortuneApiService] API response received', {
        'statusCode': _getStatusCode(response),
        'apiTime': '${apiStopwatch.elapsedMilliseconds}ms'});

      final fortuneResponse = FortuneResponseModel.fromJson(_getResponseData(response));
      final fortune = fortuneResponse.toEntity();

      Logger.info('🔍 [FortuneApiService] Love fortune processed successfully', {
        'fortuneId': fortune.id,
        'overallScore': fortune.overallScore});

      // Cache the result
      Logger.debug('🔍 [FortuneApiService] Caching fortune result...');
      final cacheWriteStopwatch = Logger.startTimer('Cache Write - love');
      await _cacheService.cacheFortune(
        'love',
        params,
        _entityToFortuneModel(fortune, 'love'));
      Logger.endTimer('Cache Write - love', cacheWriteStopwatch);

      Logger.endTimer('getLoveFortune - Total', stopwatch);
      Logger.info('✅ [FortuneApiService] getLoveFortune completed', {
        'totalTime': '${stopwatch.elapsedMilliseconds}ms',
        'fromCache': false});

      return fortune;
    } on DioException catch (e) {
      Logger.error('❌ [FortuneApiService] DioException in getLoveFortune', {
        'type': e.type.toString(),
        'message': e.message,
        'statusCode': e.response?.statusCode});

      // If network error and cache exists, return cached data
      if (_isNetworkError(e)) {
        Logger.warning('🔍 [FortuneApiService] Network error detected, checking offline cache...');
        final cachedFortune = await _cacheService.getCachedFortune('love', params);
        if (cachedFortune != null) {
          Logger.info('Network error: returning cached love fortune');
          Logger.endTimer('getLoveFortune - Total', stopwatch);
          return _fortuneModelToEntity(cachedFortune);
        }
      }
      Logger.endTimer('getLoveFortune - Total', stopwatch);
      rethrow;
    } catch (e, stackTrace) {
      Logger.endTimer('getLoveFortune - Total', stopwatch);
      Logger.error('❌ [FortuneApiService] Unexpected error in getLoveFortune', e, stackTrace);
      rethrow;
    }
  }

  // Marriage Fortune - delegates to generic getFortune
  Future<Fortune> getMarriageFortune({
    required String userId,
    required Future<Fortune> Function({required String fortuneType, required String userId}) getFortune}) async {
    return getFortune(fortuneType: 'marriage', userId: userId);
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
