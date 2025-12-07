import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/edge_functions_endpoints.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/fortune.dart';
import '../../models/fortune_response_model.dart';
import 'package:fortune/services/cache_service.dart';
import '../../../models/fortune_model.dart';

class DailyFortuneApi {
  final ApiClient _apiClient;
  final CacheService _cacheService;

  DailyFortuneApi(this._apiClient, this._cacheService);

  // Daily Fortune
  Future<Fortune> getDailyFortune({
    required String userId,
    DateTime? date}) async {
    final stopwatch = Logger.startTimer('getDailyFortune - Total');

    Logger.info('🔍 [FortuneApiService] getDailyFortune called', {
      'userId': userId,
      'date': date?.toIso8601String()});

    // Get user profile for saju information
    final supabase = Supabase.instance.client;
    final userProfileResponse = await supabase
        .from('user_profiles')
        .select('name, birth_date, birth_time, gender, mbti, blood_type, zodiac_sign, chinese_zodiac')
        .eq('id', userId)
        .maybeSingle();

    final params = {
      'userId': userId,
      if (date != null) 'date': date.toIso8601String(),
      if (userProfileResponse != null) ...{
        'birthDate': userProfileResponse['birth_date'],
        'birthTime': userProfileResponse['birth_time'],
        'gender': userProfileResponse['gender'],
        'isLunar': false,
        'zodiacSign': userProfileResponse['zodiac_sign'],
        'zodiacAnimal': userProfileResponse['chinese_zodiac']}};

    // Check cache first
    Logger.debug('🔍 [FortuneApiService] Checking cache for daily fortune...');
    final cacheStopwatch = Logger.startTimer('Cache Check - daily');
    final cachedFortune = await _cacheService.getCachedFortune('daily', params);
    Logger.endTimer('Cache Check - daily', cacheStopwatch);

    if (cachedFortune != null) {
      Logger.info('💾 [FortuneApiService] Cache hit! Returning cached daily fortune', {
        'cacheTime': '${cacheStopwatch.elapsedMilliseconds}ms'});
      Logger.endTimer('getDailyFortune - Total', stopwatch);
      return _fortuneModelToEntity(cachedFortune);
    }
    Logger.debug('🔍 [FortuneApiService] Cache miss - fetching from API');

    try {
      final queryParams = {
        if (date != null) 'date': date.toIso8601String()};

      final endpoint = EdgeFunctionsEndpoints.dailyFortune;
      Logger.debug('🔍 [FortuneApiService] Making API call', {
        'endpoint': endpoint,
        'queryParams': queryParams,
        'hasSajuData': userProfileResponse != null});

      final apiStopwatch = Logger.startTimer('API Call - daily');
      final response = userProfileResponse != null
        ? await _apiClient.post(
            endpoint,
            data: {
              ...queryParams,
              'birthDate': userProfileResponse['birth_date'],
              'birthTime': userProfileResponse['birth_time'],
              'gender': userProfileResponse['gender'],
              'isLunar': false,
              'zodiacSign': userProfileResponse['zodiac_sign'],
              'zodiacAnimal': userProfileResponse['chinese_zodiac']
            })
        : await _apiClient.get(
            endpoint,
            queryParameters: queryParams);
      Logger.endTimer('API Call - daily', apiStopwatch);

      Logger.info('🔍 [FortuneApiService] API response received', {
        'statusCode': _getStatusCode(response),
        'apiTime': '${apiStopwatch.elapsedMilliseconds}ms'});

      final responseData = _getResponseData(response);
      Logger.info('🔍 [FortuneApiService] Raw response data structure', {
        'responseKeys': responseData is Map ? responseData.keys.toList() : 'Not a map',
        'responseType': responseData.runtimeType.toString(),
        'hasFortuneKey': responseData is Map ? responseData.containsKey('fortune') : false,
        'hasDataKey': responseData is Map ? responseData.containsKey('data') : false,
        'hasStorySegmentsKey': responseData is Map ? responseData.containsKey('storySegments') : false,
      });

      final fortuneResponse = FortuneResponseModel.fromJson(responseData);
      final fortune = fortuneResponse.toEntity();

      Logger.info('🔍 [FortuneApiService] Fortune processed successfully', {
        'fortuneId': fortune.id,
        'fortuneType': fortune.type,
        'overallScore': fortune.overallScore,
        'contentLength': fortune.content.length,
        'tokensUsed': fortune.tokenCost});

      // Cache the result
      Logger.debug('🔍 [FortuneApiService] Caching fortune result...');
      final cacheWriteStopwatch = Logger.startTimer('Cache Write - daily');
      final cacheSuccess = await _cacheService.cacheFortune(
        'daily',
        params,
        _entityToFortuneModel(fortune, 'daily'));
      Logger.endTimer('Cache Write - daily', cacheWriteStopwatch);

      if (cacheSuccess) {
        Logger.debug('🔍 [FortuneApiService] Fortune cached successfully');
      } else {
        Logger.warning('⚠️ [FortuneApiService] Fortune cache save failed');
      }

      Logger.endTimer('getDailyFortune - Total', stopwatch);
      Logger.info('✅ [FortuneApiService] getDailyFortune completed', {
        'totalTime': '${stopwatch.elapsedMilliseconds}ms',
        'fromCache': false});

      return fortune;
    } on DioException catch (e) {
      Logger.error('❌ [FortuneApiService] DioException caught', {
        'type': e.type.toString(),
        'message': e.message,
        'statusCode': e.response?.statusCode,
        'responseData': e.response?.data});

      // If network error and cache exists, return cached data
      if (_isNetworkError(e)) {
        Logger.warning('🔍 [FortuneApiService] Network error detected, checking offline cache...');
        final cachedFortune = await _cacheService.getCachedFortune('daily', params);
        if (cachedFortune != null) {
          Logger.info('Network error: returning cached daily fortune');
          Logger.endTimer('getDailyFortune - Total', stopwatch);
          return _fortuneModelToEntity(cachedFortune);
        }
      }
      Logger.endTimer('getDailyFortune - Total', stopwatch);
      rethrow;
    } catch (e, stackTrace) {
      Logger.endTimer('getDailyFortune - Total', stopwatch);
      Logger.error('❌ [FortuneApiService] Unexpected error', e, stackTrace);
      rethrow;
    }
  }

  // Generate Daily Fortune (for compatibility)
  Future<Fortune> generateDailyFortune({
    required String userId,
    DateTime? date}) async {
    return getDailyFortune(userId: userId, date: date);
  }

  // Today Fortune
  Future<Fortune> getTodayFortune({required String userId}) async {
    Logger.debug('📅 [FortuneApiService] getTodayFortune delegating to getDailyFortune', {
      'userId': userId,
      'date': DateTime.now().toIso8601String()});
    return getDailyFortune(userId: userId, date: DateTime.now());
  }

  // Tomorrow Fortune
  Future<Fortune> getTomorrowFortune({required String userId}) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    Logger.debug('📅 [FortuneApiService] getTomorrowFortune delegating to getDailyFortune', {
      'userId': userId,
      'date': tomorrow.toIso8601String()});
    return getDailyFortune(userId: userId, date: tomorrow);
  }

  // Weekly Fortune - delegates to generic getFortune
  Future<Fortune> getWeeklyFortune({
    required String userId,
    required Future<Fortune> Function({required String fortuneType, required String userId}) getFortune}) async {
    Logger.debug('📅 [FortuneApiService] getWeeklyFortune delegating to getFortune', {
      'userId': userId,
      'fortuneType': 'weekly'});
    return getFortune(fortuneType: 'weekly', userId: userId);
  }

  // Monthly Fortune - delegates to generic getFortune
  Future<Fortune> getMonthlyFortune({
    required String userId,
    required Future<Fortune> Function({required String fortuneType, required String userId}) getFortune}) async {
    Logger.debug('📅 [FortuneApiService] getMonthlyFortune delegating to getFortune', {
      'userId': userId,
      'fortuneType': 'monthly'});
    return getFortune(fortuneType: 'monthly', userId: userId);
  }

  // Yearly Fortune - delegates to generic getFortune
  Future<Fortune> getYearlyFortune({
    required String userId,
    required Future<Fortune> Function({required String fortuneType, required String userId}) getFortune}) async {
    Logger.debug('📅 [FortuneApiService] getYearlyFortune delegating to getFortune', {
      'userId': userId,
      'fortuneType': 'yearly'});
    return getFortune(fortuneType: 'yearly', userId: userId);
  }

  // Hourly Fortune - delegates to generic getFortune
  Future<Fortune> getHourlyFortune({
    required String userId,
    required DateTime targetTime,
    required Future<Fortune> Function({required String fortuneType, required String userId, Map<String, dynamic>? params}) getFortune}) async {
    return getFortune(
      fortuneType: 'hourly',
      userId: userId,
      params: {'targetTime': targetTime});
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
