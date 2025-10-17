import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/fortune.dart';
import '../models/fortune_response_model.dart';
import '../../presentation/providers/providers.dart';
import 'package:fortune/services/cache_service.dart';
import 'package:fortune/models/fortune_model.dart';
import 'package:flutter/foundation.dart';
import '../../core/config/feature_flags.dart';
import 'fortune_api_service_edge_functions.dart';
import 'fortune_api_decision_service.dart';

class FortuneApiService {
  final ApiClient _apiClient;
  final CacheService _cacheService;
  final FortuneApiDecisionService _decisionService;

  FortuneApiService(this._apiClient)
      : _cacheService = CacheService(),
        _decisionService = FortuneApiDecisionService();

  // Daily Fortune
  Future<Fortune> getDailyFortune({
    required String userId,
    DateTime? date}) async {
    final stopwatch = Logger.startTimer('getDailyFortune - Total');
    
    Logger.info('🔍 [FortuneApiService] getDailyFortune called', {
      'userId': userId,
      'date': null});
    
    // Get user profile for saju information
    final supabase = Supabase.instance.client;
    final userProfileResponse = await supabase
        .from('user_profiles')
        .select('name, birth_date, birth_time, gender, mbti, blood_type, zodiac_sign, chinese_zodiac')
        .eq('id', userId)
        .maybeSingle();
    
    final params = {
      'userId': userId,  // Fixed: was null, now properly set
      if (date != null) 'date': null,
      if (userProfileResponse != null) ...{
        'birthDate': userProfileResponse['birth_date'],
        'birthTime': userProfileResponse['birth_time'],
        'gender': userProfileResponse['gender'],
        'isLunar': false,  // Default to false as column doesn't exist yet
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
        if (date != null) 'date': null};

      Logger.debug('🔍 [FortuneApiService] Making API call', {
        'endpoint': ApiEndpoints.dailyFortune,
        'queryParams': null,
        'hasSajuData': userProfileResponse != null});
      
      final apiStopwatch = Logger.startTimer('API Call - daily');
      final response = userProfileResponse != null 
        ? await _apiClient.post(
            ApiEndpoints.dailyFortune,
            data: {
              ...queryParams,
              'birthDate': userProfileResponse['birth_date'],
              'birthTime': userProfileResponse['birth_time'],
              'gender': userProfileResponse['gender'],
              'isLunar': false,  // Default to false as column doesn't exist yet
              'zodiacSign': userProfileResponse['zodiac_sign'],
              'zodiacAnimal': userProfileResponse['chinese_zodiac']
            })
        : await _apiClient.get(
            ApiEndpoints.dailyFortune,
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
        'tokensUsed': null});

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
        'fromCache': null});

      return fortune;
    } on DioException catch (e) {
      Logger.error('❌ [FortuneApiService] DioException caught', {
        'type': e.type.toString(),
        'message': e.message,
        'statusCode': e.response?.statusCode,
        'responseData': null});
      
      // If network error and cache exists, return cached data
      if (_isNetworkError(e)) {
        Logger.warning('🔍 [FortuneApiService] Network error detected, checking offline cache...');
        final cachedFortune = await _cacheService.getCachedFortune('daily', params);
        if (cachedFortune != null) {
          Logger.info('error: returning cached daily fortune');
          Logger.endTimer('getDailyFortune - Total', stopwatch);
          return _fortuneModelToEntity(cachedFortune);
        }
      }
      Logger.endTimer('getDailyFortune - Total', stopwatch);
      throw _handleDioError(e);
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

  // Saju Fortune
  Future<Fortune> getSajuFortune({
    required String userId,
    required DateTime birthDate}) async {
    final stopwatch = Logger.startTimer('getSajuFortune - Total');
    
    Logger.info('🔍 [FortuneApiService] getSajuFortune called', {
      'userId': userId,
      'birthDate': birthDate.toIso8601String(),
      'age': null});
    
    final params = {
      'userId': userId,
      'birthDate': null};

    // Check cache first
    Logger.debug('🔍 [FortuneApiService] Checking cache for saju fortune...');
    final cacheStopwatch = Logger.startTimer('Cache Check - saju');
    final cachedFortune = await _cacheService.getCachedFortune('saju', params);
    Logger.endTimer('Cache Check - saju', cacheStopwatch);
    
    if (cachedFortune != null) {
      Logger.info('💾 [FortuneApiService] Cache hit! Returning cached saju fortune', {
        'cacheTime': '${cacheStopwatch.elapsedMilliseconds}ms'});
      Logger.endTimer('getSajuFortune - Total', stopwatch);
      return _fortuneModelToEntity(cachedFortune);
    }
    Logger.debug('🔍 [FortuneApiService] Cache miss - fetching from API');

    try {
      Logger.debug('🔍 [FortuneApiService] Making API call', {
        'endpoint': ApiEndpoints.sajuFortune,
        'birthDate': null});
      
      final apiStopwatch = Logger.startTimer('API Call - saju');
      final response = await _apiClient.post(
        ApiEndpoints.sajuFortune,
        data: {
          'birthDate': birthDate});
      Logger.endTimer('API Call - saju', apiStopwatch);
      
      Logger.info('🔍 [FortuneApiService] API response received', {
        'statusCode': _getStatusCode(response),
        'apiTime': '${apiStopwatch.elapsedMilliseconds}ms'});

      final fortuneResponse = FortuneResponseModel.fromJson(_getResponseData(response));
      final fortune = fortuneResponse.toEntity();
      
      Logger.info('🔍 [FortuneApiService] Saju fortune processed successfully', {
        'fortuneId': fortune.id,
        'overallScore': fortune.overallScore,
        'tokensUsed': null});

      // Cache the result
      Logger.debug('🔍 [FortuneApiService] Caching fortune result...');
      final cacheWriteStopwatch = Logger.startTimer('Cache Write - saju');
      await _cacheService.cacheFortune(
        'saju',
        params,
        _entityToFortuneModel(fortune, 'saju'));
      Logger.endTimer('Cache Write - saju', cacheWriteStopwatch);

      Logger.endTimer('getSajuFortune - Total', stopwatch);
      Logger.info('✅ [FortuneApiService] getSajuFortune completed', {
        'totalTime': '${stopwatch.elapsedMilliseconds}ms',
        'fromCache': null});

      return fortune;
    } on DioException catch (e) {
      Logger.error('❌ [FortuneApiService] DioException in getSajuFortune', {
        'type': e.type.toString(),
        'message': e.message,
        'statusCode': null});
      
      // If network error and cache exists, return cached data
      if (_isNetworkError(e)) {
        Logger.warning('🔍 [FortuneApiService] Network error detected, checking offline cache...');
        final cachedFortune = await _cacheService.getCachedFortune('saju', params);
        if (cachedFortune != null) {
          Logger.info('error: returning cached saju fortune');
          Logger.endTimer('getSajuFortune - Total', stopwatch);
          return _fortuneModelToEntity(cachedFortune);
        }
      }
      Logger.endTimer('getSajuFortune - Total', stopwatch);
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      Logger.endTimer('getSajuFortune - Total', stopwatch);
      Logger.error('❌ [FortuneApiService] Unexpected error in getSajuFortune', e, stackTrace);
      rethrow;
    }
  }

  // Compatibility Fortune
  Future<Fortune> getCompatibilityFortune({
    required Map<String, dynamic> person1,
    required Map<String, dynamic> person2}) async {
    final stopwatch = Logger.startTimer('getCompatibilityFortune - Total');
    
    Logger.info('🔍 [FortuneApiService] getCompatibilityFortune called', {
      'person1Name': person1['name'],
      'person2Name': person2['name'],
      'person1Keys': person1.keys.toList(),
      'person2Keys': null});
    
    try {
      Logger.debug('🔍 [FortuneApiService] Making API call', {
        'endpoint'});
      
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
        'statusCode': null});
      throw _handleDioError(e);
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
      'userId'});
    
    final params = {
      'userId': null};

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
        'endpoint'});
      
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
        'overallScore': null});

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
        'fromCache': null});

      return fortune;
    } on DioException catch (e) {
      Logger.error('❌ [FortuneApiService] DioException in getLoveFortune', {
        'type': e.type.toString(),
        'message': e.message,
        'statusCode': null});
      
      // If network error and cache exists, return cached data
      if (_isNetworkError(e)) {
        Logger.warning('🔍 [FortuneApiService] Network error detected, checking offline cache...');
        final cachedFortune = await _cacheService.getCachedFortune('love', params);
        if (cachedFortune != null) {
          Logger.info('error: returning cached love fortune');
          Logger.endTimer('getLoveFortune - Total', stopwatch);
          return _fortuneModelToEntity(cachedFortune);
        }
      }
      Logger.endTimer('getLoveFortune - Total', stopwatch);
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      Logger.endTimer('getLoveFortune - Total', stopwatch);
      Logger.error('❌ [FortuneApiService] Unexpected error in getLoveFortune', e, stackTrace);
      rethrow;
    }
  }

  // Wealth Fortune
  Future<Fortune> getWealthFortune({
    required String userId,
    Map<String, dynamic>? financialData}) async {
    final stopwatch = Logger.startTimer('getWealthFortune - Total');
    
    Logger.info('🔍 [FortuneApiService] getWealthFortune called', {
      'userId': userId,
      'hasFinancialData': financialData != null,
      'dataKeys': null});
    
    try {
      Logger.debug('🔍 [FortuneApiService] Making API call', {
        'endpoint': ApiEndpoints.wealthFortune,
        'hasData': null});
      
      final apiStopwatch = Logger.startTimer('API Call - wealth');
      final response = await _apiClient.post(
        ApiEndpoints.wealthFortune,
        data: financialData ?? {});
      Logger.endTimer('API Call - wealth', apiStopwatch);
      
      Logger.info('🔍 [FortuneApiService] API response received', {
        'statusCode': _getStatusCode(response),
        'apiTime': '${apiStopwatch.elapsedMilliseconds}ms'});

      final fortuneResponse = FortuneResponseModel.fromJson(_getResponseData(response));
      final fortune = fortuneResponse.toEntity();
      
      Logger.endTimer('getWealthFortune - Total', stopwatch);
      Logger.info('✅ [FortuneApiService] getWealthFortune completed', {
        'fortuneId': fortune.id,
        'overallScore': fortune.overallScore,
        'totalTime': '${stopwatch.elapsedMilliseconds}ms'});
      
      return fortune;
    } on DioException catch (e) {
      Logger.endTimer('getWealthFortune - Total', stopwatch);
      Logger.error('❌ [FortuneApiService] DioException in getWealthFortune', {
        'type': e.type.toString(),
        'message': e.message,
        'statusCode': null});
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      Logger.endTimer('getWealthFortune - Total', stopwatch);
      Logger.error('❌ [FortuneApiService] Unexpected error in getWealthFortune', e, stackTrace);
      rethrow;
    }
  }

  // Investment Enhanced Fortune
  Future<Fortune> getInvestmentEnhancedFortune({
    required String userId,
    Map<String, dynamic>? investmentData}) async {
    final stopwatch = Logger.startTimer('getInvestmentEnhancedFortune - Total');

    Logger.info('🔍 [FortuneApiService] getInvestmentEnhancedFortune called', {
      'userId': userId,
      'hasInvestmentData': investmentData != null,
      'dataKeys': investmentData?.keys.toList()});

    try {
      Logger.debug('🔍 [FortuneApiService] Making API call', {
        'endpoint': ApiEndpoints.investmentEnhanced,
        'method': 'POST'});

      final apiStopwatch = Logger.startTimer('API Call - investment-enhanced');
      final response = await _apiClient.post(
        ApiEndpoints.investmentEnhanced,
        data: {
          'userId': userId,
          ...?investmentData,
        });
      Logger.endTimer('API Call - investment-enhanced', apiStopwatch);

      Logger.info('🔍 [FortuneApiService] API response received', {
        'statusCode': _getStatusCode(response),
        'apiTime': '${apiStopwatch.elapsedMilliseconds}ms'});

      final fortuneResponse = FortuneResponseModel.fromJson(_getResponseData(response));
      final fortune = fortuneResponse.toEntity();

      Logger.endTimer('getInvestmentEnhancedFortune - Total', stopwatch);
      Logger.info('✅ [FortuneApiService] getInvestmentEnhancedFortune completed', {
        'fortuneId': fortune.id,
        'overallScore': fortune.overallScore,
        'totalTime': '${stopwatch.elapsedMilliseconds}ms'});

      return fortune;
    } on DioException catch (e) {
      Logger.endTimer('getInvestmentEnhancedFortune - Total', stopwatch);
      Logger.error('❌ [FortuneApiService] DioException in getInvestmentEnhancedFortune', {
        'type': e.type.toString(),
        'message': e.message,
        'statusCode': e.response?.statusCode});
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      Logger.endTimer('getInvestmentEnhancedFortune - Total', stopwatch);
      Logger.error('❌ [FortuneApiService] Unexpected error in getInvestmentEnhancedFortune', e, stackTrace);
      rethrow;
    }
  }

  // MBTI Fortune
  Future<Fortune> getMbtiFortune({
    required String userId,
    required String mbtiType,
    List<String>? categories,
    String? name,
    String? birthDate}) async {
    final stopwatch = Logger.startTimer('getMbtiFortune - Total');

    // Enhanced parameter validation
    if (userId.isEmpty) {
      Logger.error('❌ [FortuneApiService] Invalid userId for MBTI fortune', {
        'userId': userId,
        'mbtiType': mbtiType
      });
      throw const ValidationException(message: '유효하지 않은 사용자 ID입니다');
    }

    if (mbtiType.isEmpty || mbtiType.length != 4) {
      Logger.error('❌ [FortuneApiService] Invalid MBTI type format', {
        'userId': userId,
        'mbtiType': mbtiType,
        'length': mbtiType.length
      });
      throw const ValidationException(message: '유효하지 않은 MBTI 타입입니다');
    }

    if (categories?.isEmpty == true) {
      Logger.error('❌ [FortuneApiService] Empty categories provided', {
        'userId': userId,
        'mbtiType': mbtiType
      });
      throw const ValidationException(message: '카테고리를 선택해주세요');
    }

    Logger.info('🔍 [FortuneApiService] getMbtiFortune called', {
      'userId': userId,
      'mbtiType': mbtiType,
      'categoriesCount': categories?.length ?? 0,
      'categories': categories,
      'name': name,
      'birthDate': birthDate});

    try {
      Logger.debug('🔍 [FortuneApiService] Making API call', {
        'endpoint': ApiEndpoints.mbtiFortune,
        'mbtiType': mbtiType,
        'hasCategories': categories != null,
        'hasName': name != null,
        'hasBirthDate': birthDate != null});

      final requestData = {
        'mbti': mbtiType,
        'userId': userId,
        'name': name ?? 'Unknown',
        'birthDate': birthDate ?? DateTime.now().toIso8601String().split('T')[0],
        if (categories != null && categories.isNotEmpty) 'categories': categories,
      };

      Logger.debug('🔍 [FortuneApiService] Request data prepared', {
        'dataKeys': requestData.keys.toList(),
        'requestSize': requestData.toString().length
      });

      final apiStopwatch = Logger.startTimer('API Call - mbti');
      final response = await _apiClient.post(
        ApiEndpoints.mbtiFortune,
        data: requestData);
      Logger.endTimer('API Call - mbti', apiStopwatch);

      Logger.info('🔍 [FortuneApiService] API response received', {
        'statusCode': _getStatusCode(response),
        'apiTime': '${apiStopwatch.elapsedMilliseconds}ms'});

      final responseData = _getResponseData(response);
      Logger.debug('🔍 [FortuneApiService] Processing response data', {
        'responseType': responseData.runtimeType.toString(),
        'hasSuccessKey': responseData is Map ? responseData.containsKey('success') : false,
        'hasDataKey': responseData is Map ? responseData.containsKey('data') : false
      });

      // MBTI Edge Function returns {success: true, data: {...}}
      Map<String, dynamic> fortuneData;
      if (responseData is Map && responseData.containsKey('success') && responseData['success'] == true) {
        fortuneData = responseData['data'] as Map<String, dynamic>;
      } else {
        fortuneData = responseData as Map<String, dynamic>;
      }

      final fortuneResponse = FortuneResponseModel.fromJson(fortuneData);
      final fortune = fortuneResponse.toEntity();

      Logger.endTimer('getMbtiFortune - Total', stopwatch);
      Logger.info('✅ [FortuneApiService] getMbtiFortune completed', {
        'fortuneId': fortune.id,
        'overallScore': fortune.overallScore,
        'totalTime': '${stopwatch.elapsedMilliseconds}ms'});

      return fortune;
    } on DioException catch (e) {
      Logger.endTimer('getMbtiFortune - Total', stopwatch);
      Logger.error('❌ [FortuneApiService] DioException in getMbtiFortune', {
        'type': e.type.toString(),
        'message': e.message,
        'statusCode': e.response?.statusCode,
        'responseData': e.response?.data,
        'mbtiType': mbtiType,
        'userId': userId});
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      Logger.endTimer('getMbtiFortune - Total', stopwatch);
      Logger.error('❌ [FortuneApiService] Unexpected error in getMbtiFortune', {
        'error': e.toString(),
        'mbtiType': mbtiType,
        'userId': userId,
        'categoriesCount': categories?.length ?? 0
      }, stackTrace);
      rethrow;
    }
  }

  // Today Fortune
  Future<Fortune> getTodayFortune({required String userId}) async {
    Logger.debug('📅 [FortuneApiService] getTodayFortune delegating to getDailyFortune', {
      'userId': userId,
      'date': null});
    return getDailyFortune(userId: userId, date: DateTime.now());
  }

  // Tomorrow Fortune
  Future<Fortune> getTomorrowFortune({required String userId}) async {
    final tomorrow = DateTime.now().add(Duration(days: 1));
    Logger.debug('📅 [FortuneApiService] getTomorrowFortune delegating to getDailyFortune', {
      'userId': userId,
      'date': null});
    return getDailyFortune(userId: userId, date: tomorrow);
  }

  // Weekly Fortune
  Future<Fortune> getWeeklyFortune({required String userId}) async {
    Logger.debug('📅 [FortuneApiService] getWeeklyFortune delegating to getFortune', {
      'userId': userId,
      'fortuneType': 'weekly'});
    return getFortune(fortuneType: 'weekly', userId: userId);
  }

  // Monthly Fortune
  Future<Fortune> getMonthlyFortune({required String userId}) async {
    Logger.debug('📅 [FortuneApiService] getMonthlyFortune delegating to getFortune', {
      'userId': userId,
      'fortuneType': 'monthly'});
    return getFortune(fortuneType: 'monthly', userId: userId);
  }

  // Yearly Fortune
  Future<Fortune> getYearlyFortune({required String userId}) async {
    Logger.debug('📅 [FortuneApiService] getYearlyFortune delegating to getFortune', {
      'userId': userId,
      'fortuneType': 'yearly'});
    return getFortune(fortuneType: 'yearly', userId: userId);
  }

  // Hourly Fortune
  Future<Fortune> getHourlyFortune({
    required String userId,
    required DateTime targetTime}) async {
    return getFortune(
      fortuneType: 'hourly',
      userId: userId,
      params: {'targetTime': targetTime});
  }

  // Zodiac Fortune
  Future<Fortune> getZodiacFortune({
    required String userId,
    required String zodiacSign}) async {
    return getFortune(
      fortuneType: 'zodiac',
      userId: userId,
      params: {'zodiacSign': zodiacSign});
  }

  // Zodiac Animal Fortune
  Future<Fortune> getZodiacAnimalFortune({
    required String userId,
    required String zodiacAnimal}) async {
    return getFortune(
      fortuneType: 'zodiac-animal',
      userId: userId,
      params: {'zodiacAnimal': zodiacAnimal});
  }

  // Blood Type Fortune
  Future<Fortune> getBloodTypeFortune({
    required String userId,
    required String bloodType}) async {
    return getFortune(
      fortuneType: 'blood-type',
      userId: userId,
      params: {'bloodType': bloodType});
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
    required String wish}) async {
    return getFortune(
      fortuneType: 'wish',
      userId: userId,
      params: {'wish': wish});
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

  // Same Birthday Celebrity Fortune
  Future<Fortune> getSameBirthdayCelebrityFortune({
    required String userId,
    required DateTime birthDate,
    required String lunarSolar}) async {
    return getFortune(
      fortuneType: 'same-birthday-celebrity',
      userId: userId,
      params: {
        'birth_date': birthDate.toIso8601String(),
        'lunar_solar': null});
  }

  // Generic Fortune
  Future<Fortune> getFortune({
    required String fortuneType,
    required String userId,
    Map<String, dynamic>? params}) async {
    final stopwatch = Logger.startTimer('Fortune cached');
    
    Logger.info('🔍 [FortuneApiService] getFortune called', {
      'fortuneType': fortuneType,
      'userId': userId,
      'hasParams': params != null,
      'paramKeys': null});
    
    final cacheParams = {
      'userId': null,
      ...?params};

    // Check cache first
    Logger.debug('🔍 [FortuneApiService] Checking cache for $fortuneType fortune...');
    final cacheStopwatch = Logger.startTimer('Fortune cached');
    final cachedFortune = await _cacheService.getCachedFortune(fortuneType, cacheParams);
    Logger.endTimer('Cache Check - $fortuneType', cacheStopwatch);
    
    if (cachedFortune != null) {
      Logger.info('💾 [FortuneApiService] Cache hit! Returning cached $fortuneType fortune', {
        'cacheTime': '${cacheStopwatch.elapsedMilliseconds}ms'});
      Logger.endTimer('getFortune - $fortuneType', stopwatch);
      return _fortuneModelToEntity(cachedFortune);
    }
    Logger.debug('🔍 [FortuneApiService] Cache miss - making decision...');

    // 🎯 API 호출 여부 결정 (비용 최적화)
    final supabase = Supabase.instance.client;
    final userProfile = await supabase
        .from('user_profiles')
        .select('name, birth_date, gender, mbti')
        .eq('id', userId)
        .maybeSingle();

    // 🚫 예외 운세: 항상 API 호출 (소원빌기, 꿈해몽, 관상, 헤어진 애인, 소개팅)
    const alwaysCallApiTypes = ['wish', 'dream', 'face-reading', 'ex-lover', 'blind-date'];
    final shouldCallApi = alwaysCallApiTypes.contains(fortuneType)
        ? true
        : await _decisionService.shouldCallApi(
            userId: userId,
            fortuneType: fortuneType,
            userProfile: userProfile ?? {},
          );

    // 💰 API 호출하지 않기로 결정 - 유사 운세 재사용
    if (!shouldCallApi) {
      Logger.info('💡 [API Decision] Reusing similar fortune to save cost');

      final similarFortune = await _decisionService.getSimilarFortune(
        fortuneType: fortuneType,
        userProfile: userProfile ?? {},
      );

      if (similarFortune != null) {
        // 개인화 적용 (이름, 날짜 교체)
        final userName = userProfile?['name'] as String? ?? '사용자';
        final personalizedFortune = _decisionService.personalizeFortune(
          similarFortune,
          userId,
          userName,
        );

        Logger.info('✅ [API Decision] Successfully reused similar fortune', {
          'originalId': similarFortune.id,
          'fortuneType': fortuneType,
        });

        // 캐시 저장
        await _cacheService.cacheFortune(
          fortuneType,
          cacheParams,
          _entityToFortuneModel(personalizedFortune, fortuneType),
        );

        Logger.endTimer('getFortune - $fortuneType', stopwatch);
        return personalizedFortune;
      }

      Logger.warning('⚠️ [API Decision] No similar fortune found, fallback to API');
    }

    // 🚀 API 호출 (새로운 운세 생성)
    try {
      final endpoint = '/api/fortune/$fortuneType';
      Logger.debug('🔍 [FortuneApiService] Making API call', {
        'endpoint': endpoint,
        'method': params != null ? 'POST' : 'GET',
        'fortuneType': fortuneType,
        'decision': shouldCallApi ? 'API' : 'FALLBACK',
      });

      // Add detailed logging for face-reading
      if (fortuneType == 'face-reading') {
        Logger.info('🎯 [FortuneApiService] Processing face-reading fortune', {
          'hasImage': params?.containsKey('image') ?? false,
          'hasInstagramUrl': params?.containsKey('instagram_url') ?? false,
          'analysisSource': params?['analysis_source'],
          'paramKeys': params?.keys.toList()});
      }

      final apiStopwatch = Logger.startTimer('Fortune cached');
      final response = params != null
          ? await _apiClient.post(endpoint, data: params)
          : await _apiClient.get(endpoint);
      Logger.endTimer('API Call - $fortuneType', apiStopwatch);

      Logger.info('🔍 [FortuneApiService] API response received', {
        'fortuneType': fortuneType,
        'statusCode': _getStatusCode(response),
        'apiTime': '${apiStopwatch.elapsedMilliseconds}ms'});

      final fortuneResponse = FortuneResponseModel.fromJson(_getResponseData(response));
      final fortune = fortuneResponse.toEntity();
      
      Logger.info('🔍 [FortuneApiService] Fortune processed successfully', {
        'fortuneType': fortuneType,
        'fortuneId': fortune.id,
        'overallScore': fortune.overallScore,
        'contentLength': null});

      // Cache the result
      Logger.debug('🔍 [FortuneApiService] Caching fortune result...');
      final cacheWriteStopwatch = Logger.startTimer('Fortune cached');
      await _cacheService.cacheFortune(
        fortuneType,
        cacheParams,
        _entityToFortuneModel(fortune, fortuneType));
      Logger.endTimer('Cache Write - $fortuneType', cacheWriteStopwatch);

      Logger.endTimer('getFortune - $fortuneType', stopwatch);
      Logger.info('✅ [FortuneApiService] getFortune completed', {
        'fortuneType': fortuneType,
        'totalTime': '${stopwatch.elapsedMilliseconds}ms',
        'fromCache': null});

      return fortune;
    } on DioException catch (e) {
      Logger.error('❌ [FortuneApiService] DioException caught', {
        'fortuneType': fortuneType,
        'type': e.type.toString(),
        'message': e.message,
        'statusCode': null});
      
      // If network error and cache exists, return cached data
      if (_isNetworkError(e)) {
        Logger.warning('🔍 [FortuneApiService] Network error detected, checking offline cache...');
        final cachedFortune = await _cacheService.getCachedFortune(fortuneType, cacheParams);
        if (cachedFortune != null) {
          Logger.info('Fortune cached \$3');
          Logger.endTimer('getFortune - $fortuneType', stopwatch);
          return _fortuneModelToEntity(cachedFortune);
        }
      }
      Logger.endTimer('getFortune - $fortuneType', stopwatch);
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      Logger.endTimer('getFortune - $fortuneType', stopwatch);
      Logger.error('❌ [FortuneApiService] Unexpected error in getFortune', e, stackTrace);
      rethrow;
    }
  }

  // Batch Fortune Generation
  Future<List<Fortune>> generateBatchFortunes({
    required String userId,
    required List<String> fortuneTypes}) async {
    final stopwatch = Logger.startTimer('generateBatchFortunes - Total');
    
    Logger.info('🔍 [FortuneApiService] generateBatchFortunes called', {
      'userId': userId,
      'fortuneTypesCount': fortuneTypes.length,
      'fortuneTypes': null});
    
    try {
      Logger.debug('🔍 [FortuneApiService] Making batch API call', {
        'endpoint': ApiEndpoints.batchFortune,
        'typesCount': null});
      
      final apiStopwatch = Logger.startTimer('API Call - batch');
      final response = await _apiClient.post(
        ApiEndpoints.batchFortune,
        data: {
          'fortuneTypes': fortuneTypes});
      Logger.endTimer('API Call - batch', apiStopwatch);
      
      Logger.info('🔍 [FortuneApiService] Batch API response received', {
        'statusCode': _getStatusCode(response),
        'apiTime': '${apiStopwatch.elapsedMilliseconds}ms'});

      final responseData = _getResponseData(response);
      final fortunes = (responseData['fortunes'] as List)
          .map((json) => FortuneResponseModel.fromJson(json).toEntity())
          .toList();
      
      Logger.endTimer('generateBatchFortunes - Total', stopwatch);
      Logger.info('✅ [FortuneApiService] generateBatchFortunes completed', {
        'fortunesReturned': fortunes.length,
        'totalTime': '${stopwatch.elapsedMilliseconds}ms'});

      return fortunes;
    } on DioException catch (e) {
      Logger.endTimer('generateBatchFortunes - Total', stopwatch);
      Logger.error('❌ [FortuneApiService] DioException in generateBatchFortunes', {
        'type': e.type.toString(),
        'message': e.message,
        'statusCode': null});
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      Logger.endTimer('generateBatchFortunes - Total', stopwatch);
      Logger.error('❌ [FortuneApiService] Unexpected error in generateBatchFortunes', e, stackTrace);
      rethrow;
    }
  }

  // Get Fortune History
  Future<List<Fortune>> getFortuneHistory({
    required String userId,
    int? limit,
    int? offset}) async {
    final stopwatch = Logger.startTimer('getFortuneHistory - Total');
    
    Logger.info('🔍 [FortuneApiService] getFortuneHistory called', {
      'userId': userId,
      'limit': limit,
      'offset': null});
    
    try {
      final queryParams = {
        if (limit != null) 'limit': null,
        if (offset != null) 'offset': null};

      Logger.debug('🔍 [FortuneApiService] Making API call', {
        'endpoint': ApiEndpoints.fortuneHistory,
        'queryParams': null});
      
      final apiStopwatch = Logger.startTimer('API Call - history');
      final response = await _apiClient.get(
        ApiEndpoints.fortuneHistory,
        queryParameters: queryParams);
      Logger.endTimer('API Call - history', apiStopwatch);
      
      Logger.info('🔍 [FortuneApiService] History API response received', {
        'statusCode': _getStatusCode(response),
        'apiTime': '${apiStopwatch.elapsedMilliseconds}ms'});

      final responseData = _getResponseData(response);
      final fortunes = (responseData['history'] as List)
          .map((json) => FortuneResponseModel.fromJson(json).toEntity())
          .toList();
      
      Logger.endTimer('getFortuneHistory - Total', stopwatch);
      Logger.info('✅ [FortuneApiService] getFortuneHistory completed', {
        'fortunesReturned': fortunes.length,
        'totalTime': '${stopwatch.elapsedMilliseconds}ms'});

      return fortunes;
    } on DioException catch (e) {
      Logger.endTimer('getFortuneHistory - Total', stopwatch);
      Logger.error('❌ [FortuneApiService] DioException in getFortuneHistory', {
        'type': e.type.toString(),
        'message': e.message,
        'statusCode': null});
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      Logger.endTimer('getFortuneHistory - Total', stopwatch);
      Logger.error('❌ [FortuneApiService] Unexpected error in getFortuneHistory', e, stackTrace);
      rethrow;
    }
  }

  // Get User Fortune History with Scores (for charts)
  Future<List<int>> getUserFortuneHistory({
    required String userId,
    int days = 7}) async {
    try {
      // For now, using Supabase directly to get fortune history
      // This should ideally be moved to a proper API endpoint
      final supabase = Supabase.instance.client;
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days - 1));
      
      final response = await supabase
          .from('fortunes')
          .select('score, created_at')
          .eq('user_id', userId)
          .gte('created_at', startDate.toIso8601String())
          .order('created_at', ascending: true);
      
      // Create a map of date to score
      final scoreMap = <String, int>{};
      for (final fortune in response as List) {
        final date = DateTime.parse(fortune['created_at']).toLocal();
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        // If multiple fortunes on same day, take the average
        if (scoreMap.containsKey(dateKey)) {
          scoreMap[dateKey] = ((scoreMap[dateKey]! + (fortune['score'] as int)) / 2).round();
        } else {
          scoreMap[dateKey] = fortune['score'] as int;
        }
      }
      
      // Fill in missing days with 0 or previous value
      final scores = <int>[];
      int lastScore = 0;
      for (int i = 0; i < days; i++) {
        final date = now.subtract(Duration(days: days - 1 - i));
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        if (scoreMap.containsKey(dateKey)) {
          lastScore = scoreMap[dateKey]!;
          scores.add(lastScore);
        } else {
          // Use previous score if available, otherwise 0
          scores.add(lastScore);
        }
      }
      
      return scores;
    } catch (e) {
      debugPrint('Error fetching fortune history: $e');
      // Return empty scores (0) for missing data
      return List.filled(days, 0);
    }
  }

  // Clear cache for specific fortune type
  Future<void> clearFortuneCache(String fortuneType, String userId) async {
    Logger.info('🗎 [FortuneApiService] Clearing cache', {
      'fortuneType': fortuneType,
      'userId': null});
    
    final params = {'userId': userId};
    await _cacheService.removeCachedFortune(fortuneType, params);
    
    Logger.debug('✅ [FortuneApiService] Cache cleared successfully');
  }

  // Clear all cache
  Future<void> clearAllCache() async {
    Logger.info('🗎 [FortuneApiService] Clearing all cache');
    
    final stopwatch = Logger.startTimer('Clear All Cache');
    await _cacheService.clearAllCache();
    Logger.endTimer('Clear All Cache', stopwatch);
    
    Logger.debug('✅ [FortuneApiService] All cache cleared successfully', {
      'clearTime': '${stopwatch.elapsedMilliseconds}ms'});
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
    final stopwatch = Logger.startTimer('Preload Fortunes - Total');
    final essentialFortuneTypes = ['daily', 'weekly', 'monthly', 'zodiac', 'personality'];
    
    Logger.info('📦 [FortuneApiService] Starting offline preload', {
      'userId': userId,
      'typesToPreload': essentialFortuneTypes});
    
    final preloadResults = <String, bool>{};
    
    for (final type in essentialFortuneTypes) {
      try {
        Logger.debug('📥 [FortuneApiService] Preloading $type fortune...');
        final typeStopwatch = Logger.startTimer('Fortune cached');
        
        // Try to fetch and cache each fortune type
        await getFortune(
          fortuneType: type,
          userId: userId,
          params: {});
        
        Logger.endTimer('Preload - $type', typeStopwatch);
        Logger.info('✅ [FortuneApiService] Preloaded $type fortune', {
          'preloadTime': '${typeStopwatch.elapsedMilliseconds}ms'});
        preloadResults[type] = true;
      } catch (e) {
        Logger.error('❌ [FortuneApiService] Failed to preload $type fortune', {
          'error'});
        preloadResults[type] = false;
      }
    }
    
    Logger.endTimer('Preload Fortunes - Total', stopwatch);
    Logger.info('📦 [FortuneApiService] Preload completed', {
      'totalTime': '${stopwatch.elapsedMilliseconds}ms',
      'results': preloadResults,
      'successCount': preloadResults.values.where((v) => v).length,
      'failureCount': null});
  }

  // Helper method to check if it's a network error
  bool _isNetworkError(DioException error) {
    return error.type == DioExceptionType.connectionError ||
           error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.sendTimeout ||
           error.type == DioExceptionType.receiveTimeout;
  }

  // Helper method to safely get status code from response
  int? _getStatusCode(dynamic response) {
    if (response is Response) {
      return response.statusCode;
    } else if (response is Map<String, dynamic>) {
      // Edge Functions return Map directly - assume success if we get data
      return 200;
    }
    return null;
  }

  // Helper method to safely get response data
  dynamic _getResponseData(dynamic response) {
    if (response is Response) {
      return response.data;
    } else if (response is Map<String, dynamic>) {
      // Edge Functions return Map directly
      return response;
    }
    return response;
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
      tokenCost: fortune.tokenCost);
  }

  // Convert FortuneModel to Fortune entity
  Fortune _fortuneModelToEntity(FortuneModel model) {
    return model.toEntity();
  }

  // Generic post method for API calls
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await _apiClient.post(endpoint, data: data);
      return _getResponseData(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Error Handler
  AppException _handleDioError(DioException error) {
    Logger.error('🚑 [FortuneApiService] Handling DioError', {
      'type': error.type.toString(),
      'message': error.message,
      'statusCode': error.response?.statusCode,
      'responseData': error.response?.data,
      'requestPath': error.requestOptions.path,
      'requestMethod': null});
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        Logger.warning('⏱️ [FortuneApiService] Timeout error');
        return NetworkException('연결 시간이 초과되었습니다');
        
      case DioExceptionType.connectionError:
        Logger.warning('🌐 [FortuneApiService] Connection error');
        return NetworkException('네트워크 연결을 확인해주세요');
        
      case DioExceptionType.cancel:
        Logger.warning('❌ [FortuneApiService] Request cancelled');
        return NetworkException('요청이 취소되었습니다');
        
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? '오류가 발생했습니다';
        
        Logger.error('🔴 [FortuneApiService] Bad response', {
          'statusCode': statusCode,
          'message': null});
        
        switch (statusCode) {
          case 401:
            Logger.warning('🔒 [FortuneApiService] Unauthorized');
            return const UnauthorizedException();
          case 403:
            Logger.warning('🚫 [FortuneApiService] Forbidden');
            return const ForbiddenException();
          case 404:
            Logger.warning('🔍 [FortuneApiService] Not found');
            return const NotFoundException();
          case 429:
            Logger.warning('🚦 [FortuneApiService] Too many requests');
            return const TooManyRequestsException('요청이 너무 많습니다. 잠시 후 다시 시도해주세요');
          case 500:
            Logger.error('💥 [FortuneApiService] Server error');
            return ServerException(message: '서버 오류가 발생했습니다', statusCode: 500);
          default:
            Logger.error('Fortune cached');
            return ServerException(message: message, statusCode: statusCode);
        }
        
      default:
        Logger.error('❓ [FortuneApiService] Unknown error type');
        return const UnknownException();
    }
  }

  // Time-based Fortune (for unified time fortune page)
  Future<Fortune> getTimeFortune({
    required String userId,
    String fortuneType = 'time',
    Map<String, dynamic>? params}) async {
    return getFortune(
      fortuneType: fortuneType,
      userId: userId,
      params: params);
  }

  // Investment Fortune (for unified investment fortune page)
  Future<Fortune> getInvestmentFortune({
    required String userId,
    String fortuneType = 'investment',
    Map<String, dynamic>? params}) async {
    return getFortune(
      fortuneType: fortuneType,
      userId: userId,
      params: params);
  }
  

  // Sports Fortune (for unified sports fortune page)
  Future<Fortune> getSportsFortune({
    required String userId,
    String fortuneType = 'sports',
    Map<String, dynamic>? params}) async {
    return getFortune(
      fortuneType: fortuneType,
      userId: userId,
      params: params);
  }

  // Relationship Fortune (통합)
  Future<Fortune> getRelationshipFortune({
    required String userId,
    String fortuneType = 'relationship',
    Map<String, dynamic>? params}) async {
    // Extract relationship type from params
    final relationType = params?['relationshipType'] ?? 'love';
    final actualFortuneType = _getRelationshipMappingType(relationType);
    
    return getFortune(
      fortuneType: actualFortuneType,
      userId: userId,
      params: params);
  }

  // Traditional Fortune (통합)
  Future<Fortune> getTraditionalFortune({
    required String userId,
    String fortuneType = 'traditional',
    Map<String, dynamic>? params}) async {
    // Extract traditional type from params
    final traditionalType = params?['traditionalType'] ?? 'saju';
    final actualFortuneType = _getTraditionalMappingType(traditionalType);
    
    return getFortune(
      fortuneType: actualFortuneType,
      userId: userId,
      params: params);
  }

  // Personality Fortune (통합)
  Future<Fortune> getPersonalityFortune({
    required String userId,
    String fortuneType = 'personality',
    Map<String, dynamic>? params}) async {
    // Extract personality type from params
    final personalityType = params?['personalityType'] ?? 'personality';
    final actualFortuneType = _getPersonalityMappingType(personalityType);
    
    return getFortune(
      fortuneType: actualFortuneType,
      userId: userId,
      params: params);
  }

  // Lucky Items Fortune (통합)
  Future<Fortune> getLuckyItemsFortune({
    required String userId,
    String fortuneType = 'lucky_items',
    Map<String, dynamic>? params}) async {
    // Extract lucky item type from params
    final itemType = params?['luckyItemType'] ?? 'lucky_items';
    final actualFortuneType = _getLuckyItemsMappingType(itemType);
    
    return getFortune(
      fortuneType: actualFortuneType,
      userId: userId,
      params: params);
  }

  // Lifestyle Fortune (통합)
  Future<Fortune> getLifestyleFortune({
    required String userId,
    String fortuneType = 'lifestyle',
    Map<String, dynamic>? params}) async {
    // Extract lifestyle type from params
    final lifestyleType = params?['lifestyleType'] ?? 'health';
    final actualFortuneType = _getLifestyleMappingType(lifestyleType);
    
    return getFortune(
      fortuneType: actualFortuneType,
      userId: userId,
      params: params);
  }

  // Helper methods for mapping
  String _getRelationshipMappingType(String type) {
    final mapping = {
      'love': 'love',
      'compatibility': 'compatibility',
      'marriage': 'marriage',
      'ex_lover': 'ex-lover',
      'blind_date': 'blind-date',
      'chemistry': 'chemistry',
      'couple_match': 'couple-match'};
    return mapping[type] ?? 'love';
  }

  String _getTraditionalMappingType(String type) {
    final mapping = {
      'saju': 'saju',
      'traditional_saju': 'traditional-saju',
      'tojeong': 'tojeong',
      'salpuli': 'salpuli',
      'five_blessings': 'five-blessings'};
    return mapping[type] ?? 'saju';
  }

  String _getPersonalityMappingType(String type) {
    final mapping = {
      'mbti': 'mbti',
      'personality': 'personality',
      'saju_psychology': 'saju-psychology',
      'talent': 'talent',
      'blood_type': 'blood-type'};
    return mapping[type] ?? 'personality';
  }

  String _getLuckyItemsMappingType(String type) {
    final mapping = {
      'lucky_color': 'lucky-color',
      'lucky_number': 'lucky-number',
      'lucky_items': 'lucky-items',
      'lucky_food': 'lucky-food',
      'lucky_outfit': 'lucky-outfit',
      'lucky_place': 'lucky-place'};
    return mapping[type] ?? 'lucky-items';
  }

  String _getLifestyleMappingType(String type) {
    final mapping = {
      'health': 'health',
      'biorhythm': 'biorhythm',
      'moving': 'moving',
      'moving_date': 'moving-date'};
    return mapping[type] ?? 'health';
  }

  // Exam Fortune
  Future<Fortune> getLuckyExamFortune({
    required String userId,
    Map<String, dynamic>? examData,
  }) async {
    return getFortune(
      fortuneType: 'lucky-exam',
      userId: userId,
      params: examData,
    );
  }

  // Career Coaching Fortune
  Future<Fortune> getCareerCoachingFortune({
    required String userId,
    Map<String, dynamic>? careerData,
  }) async {
    return getFortune(
      fortuneType: 'career-coaching',
      userId: userId,
      params: careerData,
    );
  }
}

// Provider
final fortuneApiServiceProvider = Provider<FortuneApiService>((ref) {
  // Check if Edge Functions are enabled
  final featureFlags = FeatureFlags();
  Logger.info('🔧 [fortuneApiServiceProvider] Creating fortune API service', {
    'edgeFunctionsEnabled': featureFlags.isEdgeFunctionsEnabled(),
    'featureFlags': null});
  
  if (featureFlags.isEdgeFunctionsEnabled()) {
    Logger.info('⚡ [fortuneApiServiceProvider] Using Edge Functions for fortune API');
    return FortuneApiServiceWithEdgeFunctions(ref);
  }
  
  // Use traditional API service
  Logger.info('🌐 [fortuneApiServiceProvider] Using traditional API service');
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