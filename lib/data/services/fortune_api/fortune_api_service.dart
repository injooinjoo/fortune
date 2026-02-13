import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/edge_functions_endpoints.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/utils/logger.dart';
import '../../../core/config/feature_flags.dart';
import '../../../domain/entities/fortune.dart';
import '../../models/fortune_response_model.dart';
import '../../../presentation/providers/providers.dart';
import 'package:fortune/services/cache_service.dart';
import '../../../models/fortune_model.dart';
import '../fortune_api_service_edge_functions.dart';
import '../fortune_api_decision_service.dart';

// Import sub-services
import 'daily_fortune_api.dart';
import 'relationship_fortune_api.dart';
import 'career_fortune_api.dart';
import 'saju_fortune_api.dart';
import 'zodiac_fortune_api.dart';
import 'lucky_fortune_api.dart';
import 'misc_fortune_api.dart';

class FortuneApiService {
  final ApiClient _apiClient;
  final CacheService _cacheService;
  final FortuneApiDecisionService _decisionService;

  // Sub-services
  late final DailyFortuneApi _dailyApi;
  late final RelationshipFortuneApi _relationshipApi;
  late final CareerFortuneApi _careerApi;
  late final SajuFortuneApi _sajuApi;
  late final ZodiacFortuneApi _zodiacApi;
  late final LuckyFortuneApi _luckyApi;
  late final MiscFortuneApi _miscApi;

  FortuneApiService(this._apiClient)
      : _cacheService = CacheService(),
        _decisionService = FortuneApiDecisionService() {
    // Initialize sub-services
    _dailyApi = DailyFortuneApi(_apiClient, _cacheService);
    _relationshipApi = RelationshipFortuneApi(_apiClient, _cacheService);
    _careerApi = CareerFortuneApi();
    _sajuApi = SajuFortuneApi(_apiClient, _cacheService);
    _zodiacApi = ZodiacFortuneApi();
    _luckyApi = LuckyFortuneApi();
    _miscApi = MiscFortuneApi(_apiClient, _cacheService);
  }

  // ============================================
  // Daily Fortune Methods
  // ============================================

  Future<Fortune> getDailyFortune({required String userId, DateTime? date}) =>
      _dailyApi.getDailyFortune(userId: userId, date: date);

  Future<Fortune> generateDailyFortune(
          {required String userId, DateTime? date}) =>
      _dailyApi.generateDailyFortune(userId: userId, date: date);

  Future<Fortune> getTodayFortune({required String userId}) =>
      _dailyApi.getTodayFortune(userId: userId);

  Future<Fortune> getTomorrowFortune({required String userId}) =>
      _dailyApi.getTomorrowFortune(userId: userId);

  Future<Fortune> getWeeklyFortune({required String userId}) =>
      _dailyApi.getWeeklyFortune(userId: userId, getFortune: getFortune);

  Future<Fortune> getMonthlyFortune({required String userId}) =>
      _dailyApi.getMonthlyFortune(userId: userId, getFortune: getFortune);

  Future<Fortune> getYearlyFortune({required String userId}) =>
      _dailyApi.getYearlyFortune(userId: userId, getFortune: getFortune);

  Future<Fortune> getHourlyFortune(
          {required String userId, required DateTime targetTime}) =>
      _dailyApi.getHourlyFortune(
          userId: userId, targetTime: targetTime, getFortune: getFortune);

  // ============================================
  // Relationship Fortune Methods
  // ============================================

  Future<Fortune> getCompatibilityFortune(
          {required Map<String, dynamic> person1,
          required Map<String, dynamic> person2}) =>
      _relationshipApi.getCompatibilityFortune(
          person1: person1, person2: person2);

  Future<Fortune> getLoveFortune({required String userId}) =>
      _relationshipApi.getLoveFortune(userId: userId);

  Future<Fortune> getMarriageFortune({required String userId}) =>
      _relationshipApi.getMarriageFortune(
          userId: userId, getFortune: getFortune);

  // ============================================
  // Career Fortune Methods
  // ============================================

  Future<Fortune> getCareerFortune({required String userId}) =>
      _careerApi.getCareerFortune(userId: userId, getFortune: getFortune);

  Future<Fortune> getBusinessFortune({required String userId}) =>
      _careerApi.getBusinessFortune(userId: userId, getFortune: getFortune);

  Future<Fortune> getEmploymentFortune({required String userId}) =>
      _careerApi.getEmploymentFortune(userId: userId, getFortune: getFortune);

  Future<Fortune> getStartupFortune({required String userId}) =>
      _careerApi.getStartupFortune(userId: userId, getFortune: getFortune);

  Future<Fortune> getCareerCoachingFortune(
          {required String userId, Map<String, dynamic>? careerData}) =>
      _careerApi.getCareerCoachingFortune(
          userId: userId, careerData: careerData, getFortune: getFortune);

  // ============================================
  // Saju Fortune Methods
  // ============================================

  Future<Fortune> getSajuFortune(
          {required String userId, required DateTime birthDate}) =>
      _sajuApi.getSajuFortune(userId: userId, birthDate: birthDate);

  Future<Fortune> getTojeongFortune({required String userId}) =>
      _sajuApi.getTojeongFortune(userId: userId, getFortune: getFortune);

  // ============================================
  // Zodiac Fortune Methods
  // ============================================

  Future<Fortune> getZodiacFortune(
          {required String userId, required String zodiacSign}) =>
      _zodiacApi.getZodiacFortune(
          userId: userId, zodiacSign: zodiacSign, getFortune: getFortune);

  Future<Fortune> getZodiacAnimalFortune(
          {required String userId, required String zodiacAnimal}) =>
      _zodiacApi.getZodiacAnimalFortune(
          userId: userId, zodiacAnimal: zodiacAnimal, getFortune: getFortune);

  Future<Fortune> getBloodTypeFortune(
          {required String userId, required String bloodType}) =>
      _zodiacApi.getBloodTypeFortune(
          userId: userId, bloodType: bloodType, getFortune: getFortune);

  // ============================================
  // Lucky Fortune Methods
  // ============================================

  Future<Fortune> getLuckyColorFortune({required String userId}) =>
      _luckyApi.getLuckyColorFortune(userId: userId, getFortune: getFortune);

  Future<Fortune> getLuckyNumberFortune({required String userId}) =>
      _luckyApi.getLuckyNumberFortune(userId: userId, getFortune: getFortune);

  Future<Fortune> getLuckyFoodFortune({required String userId}) =>
      _luckyApi.getLuckyFoodFortune(userId: userId, getFortune: getFortune);

  Future<Fortune> getLuckyBaseballFortune({required String userId}) =>
      _luckyApi.getLuckyBaseballFortune(userId: userId, getFortune: getFortune);

  Future<Fortune> getLuckyGolfFortune({required String userId}) =>
      _luckyApi.getLuckyGolfFortune(userId: userId, getFortune: getFortune);

  Future<Fortune> getLuckyTennisFortune({required String userId}) =>
      _luckyApi.getLuckyTennisFortune(userId: userId, getFortune: getFortune);

  Future<Fortune> getLuckyRunningFortune({required String userId}) =>
      _luckyApi.getLuckyRunningFortune(userId: userId, getFortune: getFortune);

  Future<Fortune> getLuckyCyclingFortune({required String userId}) =>
      _luckyApi.getLuckyCyclingFortune(userId: userId, getFortune: getFortune);

  Future<Fortune> getLuckySwimFortune({required String userId}) =>
      _luckyApi.getLuckySwimFortune(userId: userId, getFortune: getFortune);

  Future<Fortune> getLuckyHikingFortune({required String userId}) =>
      _luckyApi.getLuckyHikingFortune(userId: userId, getFortune: getFortune);

  Future<Fortune> getLuckyFishingFortune({required String userId}) =>
      _luckyApi.getLuckyFishingFortune(userId: userId, getFortune: getFortune);

  Future<Fortune> getLuckyExamFortune(
          {required String userId, Map<String, dynamic>? examData}) =>
      _luckyApi.getLuckyExamFortune(
          userId: userId, examData: examData, getFortune: getFortune);

  // ============================================
  // Misc Fortune Methods
  // ============================================

  Future<Fortune> getWealthFortune(
          {required String userId, Map<String, dynamic>? financialData}) =>
      _miscApi.getWealthFortune(userId: userId, financialData: financialData);

  Future<Fortune> getInvestmentEnhancedFortune(
          {required String userId, Map<String, dynamic>? investmentData}) =>
      _miscApi.getInvestmentEnhancedFortune(
          userId: userId, investmentData: investmentData);

  Future<Fortune> getMbtiFortune(
          {required String userId,
          required String mbtiType,
          List<String>? categories,
          String? name,
          String? birthDate}) =>
      _miscApi.getMbtiFortune(
          userId: userId,
          mbtiType: mbtiType,
          categories: categories,
          name: name,
          birthDate: birthDate);

  Future<Fortune> getHealthFortune({required String userId}) =>
      _miscApi.getHealthFortune(userId: userId, getFortune: getFortune);

  Future<Fortune> getMovingFortune({required String userId}) =>
      _miscApi.getMovingFortune(userId: userId, getFortune: getFortune);

  Future<Fortune> getWishFortune(
          {required String userId, required String wish}) =>
      _miscApi.getWishFortune(
          userId: userId, wish: wish, getFortune: getFortune);

  Future<Fortune> getTalentFortune({required String userId}) =>
      _miscApi.getTalentFortune(userId: userId, getFortune: getFortune);

  Future<Fortune> getPalmistryFortune({required String userId}) =>
      _miscApi.getPalmistryFortune(userId: userId, getFortune: getFortune);

  Future<Fortune> getPhysiognomyFortune({required String userId}) =>
      _miscApi.getPhysiognomyFortune(userId: userId, getFortune: getFortune);

  Future<Fortune> getBiorhythmFortune({required String userId}) =>
      _miscApi.getBiorhythmFortune(userId: userId, getFortune: getFortune);

  Future<Fortune> getPastLifeFortune({required String userId}) =>
      _miscApi.getPastLifeFortune(userId: userId, getFortune: getFortune);

  Future<Fortune> getNewYearFortune({required String userId}) =>
      _miscApi.getNewYearFortune(userId: userId, getFortune: getFortune);

  Future<Fortune> getSameBirthdayCelebrityFortune(
          {required String userId,
          required DateTime birthDate,
          required String lunarSolar}) =>
      _miscApi.getSameBirthdayCelebrityFortune(
          userId: userId,
          birthDate: birthDate,
          lunarSolar: lunarSolar,
          getFortune: getFortune);

  // ============================================
  // Generic Fortune Method (core logic)
  // ============================================

  Future<Fortune> getFortune(
      {required String fortuneType,
      required String userId,
      Map<String, dynamic>? params}) async {
    final stopwatch = Logger.startTimer('getFortune - $fortuneType');

    Logger.info('🔍 [FortuneApiService] getFortune called', {
      'fortuneType': fortuneType,
      'userId': userId,
      'hasParams': params != null,
      'paramKeys': params?.keys.toList()
    });

    final cacheParams = {'userId': userId, ...?params};

    // Check cache first
    Logger.debug(
        '🔍 [FortuneApiService] Checking cache for $fortuneType fortune...');
    final cacheStopwatch = Logger.startTimer('Cache Check - $fortuneType');
    final cachedFortune =
        await _cacheService.getCachedFortune(fortuneType, cacheParams);
    Logger.endTimer('Cache Check - $fortuneType', cacheStopwatch);

    if (cachedFortune != null) {
      Logger.info(
          '💾 [FortuneApiService] Cache hit! Returning cached $fortuneType fortune',
          {'cacheTime': '${cacheStopwatch.elapsedMilliseconds}ms'});
      Logger.endTimer('getFortune - $fortuneType', stopwatch);
      return _fortuneModelToEntity(cachedFortune);
    }
    Logger.debug('🔍 [FortuneApiService] Cache miss - making decision...');

    // API call decision logic
    final supabase = Supabase.instance.client;
    final userProfile = await supabase
        .from('user_profiles')
        .select('name, birth_date, gender, mbti')
        .eq('id', userId)
        .maybeSingle();

    // Exception types that always call API
    const alwaysCallApiTypes = [
      'wish',
      'dream',
      'face-reading',
      'ex-lover',
      'blind-date'
    ];
    final shouldCallApi = alwaysCallApiTypes.contains(fortuneType)
        ? true
        : await _decisionService.shouldCallApi(
            userId: userId,
            fortuneType: fortuneType,
            userProfile: userProfile ?? {},
          );

    // Reuse similar fortune if decision says no API call
    if (!shouldCallApi) {
      Logger.info('💡 [API Decision] Reusing similar fortune to save cost');

      final similarFortune = await _decisionService.getSimilarFortune(
        fortuneType: fortuneType,
        userProfile: userProfile ?? {},
      );

      if (similarFortune != null) {
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

        await _cacheService.cacheFortune(
          fortuneType,
          cacheParams,
          _entityToFortuneModel(personalizedFortune, fortuneType),
        );

        Logger.endTimer('getFortune - $fortuneType', stopwatch);
        return personalizedFortune;
      }

      Logger.warning(
          '⚠️ [API Decision] No similar fortune found, fallback to API');
    }

    // Make API call
    try {
      // Edge Function 엔드포인트 사용 (일관된 경로)
      final endpoint = EdgeFunctionsEndpoints.getEndpointForType(fortuneType);
      Logger.debug('🔍 [FortuneApiService] Making API call', {
        'endpoint': endpoint,
        'method': params != null ? 'POST' : 'GET',
        'fortuneType': fortuneType,
        'decision': shouldCallApi ? 'API' : 'FALLBACK',
      });

      if (fortuneType == 'face-reading') {
        Logger.info('🎯 [FortuneApiService] Processing face-reading fortune', {
          'hasImage': params?.containsKey('image') ?? false,
          'hasInstagramUrl': params?.containsKey('instagram_url') ?? false,
          'analysisSource': params?['analysis_source'],
          'paramKeys': params?.keys.toList()
        });
      }

      // userId를 params에 병합하여 Edge Function 호출
      final apiParams = {
        'userId': userId,
        ...?params,
      };

      final apiStopwatch = Logger.startTimer('API Call - $fortuneType');
      final response = await _apiClient.post(endpoint, data: apiParams);
      Logger.endTimer('API Call - $fortuneType', apiStopwatch);

      Logger.info('🔍 [FortuneApiService] API response received', {
        'fortuneType': fortuneType,
        'statusCode': _getStatusCode(response),
        'apiTime': '${apiStopwatch.elapsedMilliseconds}ms'
      });

      final fortuneResponse =
          FortuneResponseModel.fromJson(_getResponseData(response));
      final fortune = fortuneResponse.toEntity();

      Logger.info('🔍 [FortuneApiService] Fortune processed successfully', {
        'fortuneType': fortuneType,
        'fortuneId': fortune.id,
        'overallScore': fortune.overallScore,
        'contentLength': fortune.content.length
      });

      // Cache the result
      Logger.debug('🔍 [FortuneApiService] Caching fortune result...');
      final cacheWriteStopwatch =
          Logger.startTimer('Cache Write - $fortuneType');
      await _cacheService.cacheFortune(fortuneType, cacheParams,
          _entityToFortuneModel(fortune, fortuneType));
      Logger.endTimer('Cache Write - $fortuneType', cacheWriteStopwatch);

      Logger.endTimer('getFortune - $fortuneType', stopwatch);
      Logger.info('✅ [FortuneApiService] getFortune completed', {
        'fortuneType': fortuneType,
        'totalTime': '${stopwatch.elapsedMilliseconds}ms',
        'fromCache': false
      });

      return fortune;
    } on DioException catch (e) {
      Logger.error('❌ [FortuneApiService] DioException caught', {
        'fortuneType': fortuneType,
        'type': e.type.toString(),
        'message': e.message,
        'statusCode': e.response?.statusCode
      });

      if (_isNetworkError(e)) {
        Logger.warning(
            '🔍 [FortuneApiService] Network error detected, checking offline cache...');
        final cachedFortune =
            await _cacheService.getCachedFortune(fortuneType, cacheParams);
        if (cachedFortune != null) {
          Logger.info('Network error: returning cached $fortuneType fortune');
          Logger.endTimer('getFortune - $fortuneType', stopwatch);
          return _fortuneModelToEntity(cachedFortune);
        }
      }
      Logger.endTimer('getFortune - $fortuneType', stopwatch);
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      Logger.endTimer('getFortune - $fortuneType', stopwatch);
      Logger.error('❌ [FortuneApiService] Unexpected error in getFortune', e,
          stackTrace);
      rethrow;
    }
  }

  // ============================================
  // Batch Operations & History
  // ============================================

  Future<List<Fortune>> generateBatchFortunes(
      {required String userId, required List<String> fortuneTypes}) async {
    final stopwatch = Logger.startTimer('generateBatchFortunes - Total');

    Logger.info('🔍 [FortuneApiService] generateBatchFortunes called', {
      'userId': userId,
      'fortuneTypesCount': fortuneTypes.length,
      'fortuneTypes': fortuneTypes
    });

    try {
      Logger.debug('🔍 [FortuneApiService] Making batch API call', {
        'endpoint': ApiEndpoints.batchFortune,
        'typesCount': fortuneTypes.length
      });

      final apiStopwatch = Logger.startTimer('API Call - batch');
      final response = await _apiClient.post(ApiEndpoints.batchFortune,
          data: {'fortuneTypes': fortuneTypes});
      Logger.endTimer('API Call - batch', apiStopwatch);

      Logger.info('🔍 [FortuneApiService] Batch API response received', {
        'statusCode': _getStatusCode(response),
        'apiTime': '${apiStopwatch.elapsedMilliseconds}ms'
      });

      final responseData = _getResponseData(response);
      final fortunes = (responseData['fortunes'] as List)
          .map((json) => FortuneResponseModel.fromJson(json).toEntity())
          .toList();

      Logger.endTimer('generateBatchFortunes - Total', stopwatch);
      Logger.info('✅ [FortuneApiService] generateBatchFortunes completed', {
        'fortunesReturned': fortunes.length,
        'totalTime': '${stopwatch.elapsedMilliseconds}ms'
      });

      return fortunes;
    } on DioException catch (e) {
      Logger.endTimer('generateBatchFortunes - Total', stopwatch);
      Logger.error(
          '❌ [FortuneApiService] DioException in generateBatchFortunes', {
        'type': e.type.toString(),
        'message': e.message,
        'statusCode': e.response?.statusCode
      });
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      Logger.endTimer('generateBatchFortunes - Total', stopwatch);
      Logger.error(
          '❌ [FortuneApiService] Unexpected error in generateBatchFortunes',
          e,
          stackTrace);
      rethrow;
    }
  }

  Future<List<Fortune>> getFortuneHistory(
      {required String userId, int? limit, int? offset}) async {
    final stopwatch = Logger.startTimer('getFortuneHistory - Total');

    Logger.info('🔍 [FortuneApiService] getFortuneHistory called',
        {'userId': userId, 'limit': limit, 'offset': offset});

    try {
      final queryParams = {
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset
      };

      Logger.debug('🔍 [FortuneApiService] Making API call', {
        'endpoint': ApiEndpoints.fortuneHistory,
        'queryParams': queryParams
      });

      final apiStopwatch = Logger.startTimer('API Call - history');
      final response = await _apiClient.get(ApiEndpoints.fortuneHistory,
          queryParameters: queryParams);
      Logger.endTimer('API Call - history', apiStopwatch);

      Logger.info('🔍 [FortuneApiService] History API response received', {
        'statusCode': _getStatusCode(response),
        'apiTime': '${apiStopwatch.elapsedMilliseconds}ms'
      });

      final responseData = _getResponseData(response);
      final fortunes = (responseData['history'] as List)
          .map((json) => FortuneResponseModel.fromJson(json).toEntity())
          .toList();

      Logger.endTimer('getFortuneHistory - Total', stopwatch);
      Logger.info('✅ [FortuneApiService] getFortuneHistory completed', {
        'fortunesReturned': fortunes.length,
        'totalTime': '${stopwatch.elapsedMilliseconds}ms'
      });

      return fortunes;
    } on DioException catch (e) {
      Logger.endTimer('getFortuneHistory - Total', stopwatch);
      Logger.error('❌ [FortuneApiService] DioException in getFortuneHistory', {
        'type': e.type.toString(),
        'message': e.message,
        'statusCode': e.response?.statusCode
      });
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      Logger.endTimer('getFortuneHistory - Total', stopwatch);
      Logger.error(
          '❌ [FortuneApiService] Unexpected error in getFortuneHistory',
          e,
          stackTrace);
      rethrow;
    }
  }

  Future<List<int>> getUserFortuneHistory(
      {required String userId, int days = 7}) async {
    try {
      final supabase = Supabase.instance.client;
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days - 1));

      final response = await supabase
          .from('fortunes')
          .select('score, created_at')
          .eq('user_id', userId)
          .gte('created_at', startDate.toIso8601String())
          .order('created_at', ascending: true);

      final scoreMap = <String, int>{};
      for (final fortune in response as List) {
        final date = DateTime.parse(fortune['created_at']).toLocal();
        final dateKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        if (scoreMap.containsKey(dateKey)) {
          scoreMap[dateKey] =
              ((scoreMap[dateKey]! + (fortune['score'] as int)) / 2).round();
        } else {
          scoreMap[dateKey] = fortune['score'] as int;
        }
      }

      final scores = <int>[];
      int lastScore = 0;
      for (int i = 0; i < days; i++) {
        final date = now.subtract(Duration(days: days - 1 - i));
        final dateKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        if (scoreMap.containsKey(dateKey)) {
          lastScore = scoreMap[dateKey]!;
          scores.add(lastScore);
        } else {
          scores.add(lastScore);
        }
      }

      return scores;
    } catch (e) {
      debugPrint('Error fetching fortune history: $e');
      return List.filled(days, 0);
    }
  }

  // ============================================
  // Cache Management
  // ============================================

  Future<void> clearFortuneCache(String fortuneType, String userId) async {
    Logger.info('🗑️ [FortuneApiService] Clearing cache',
        {'fortuneType': fortuneType, 'userId': userId});

    final params = {'userId': userId};
    await _cacheService.removeCachedFortune(fortuneType, params);

    Logger.debug('✅ [FortuneApiService] Cache cleared successfully');
  }

  Future<void> clearAllCache() async {
    Logger.info('🗑️ [FortuneApiService] Clearing all cache');

    final stopwatch = Logger.startTimer('Clear All Cache');
    await _cacheService.clearAllCache();
    Logger.endTimer('Clear All Cache', stopwatch);

    Logger.debug('✅ [FortuneApiService] All cache cleared successfully',
        {'clearTime': '${stopwatch.elapsedMilliseconds}ms'});
  }

  Future<Map<String, dynamic>> getCacheStats() async {
    return await _cacheService.getCacheStats();
  }

  Future<List<Fortune>> getOfflineFortunes(String fortuneType) async {
    final cachedModels =
        await _cacheService.getCachedFortunesByType(fortuneType);
    return cachedModels.map(_fortuneModelToEntity).toList();
  }

  Future<List<Fortune>> getAllCachedFortunes(String userId,
      {bool includeExpired = false}) async {
    final cachedModels = await _cacheService.getAllCachedFortunesForUser(userId,
        includeExpired: includeExpired);
    return cachedModels.map(_fortuneModelToEntity).toList();
  }

  Future<bool> isOfflineMode() async {
    return await _cacheService.shouldUseOfflineMode();
  }

  Future<Fortune?> getMostRecentCachedFortune(
      String fortuneType, String userId) async {
    final cachedModel =
        await _cacheService.getMostRecentCachedFortune(fortuneType, userId);
    return cachedModel != null ? _fortuneModelToEntity(cachedModel) : null;
  }

  Future<void> preloadForOfflineUse(String userId) async {
    final stopwatch = Logger.startTimer('Preload Fortunes - Total');
    final essentialFortuneTypes = [
      'daily',
      'weekly',
      'monthly',
      'zodiac',
      'personality'
    ];

    Logger.info('📦 [FortuneApiService] Starting offline preload',
        {'userId': userId, 'typesToPreload': essentialFortuneTypes});

    final preloadResults = <String, bool>{};

    for (final type in essentialFortuneTypes) {
      try {
        Logger.debug('📥 [FortuneApiService] Preloading $type fortune...');
        final typeStopwatch = Logger.startTimer('Preload - $type');

        await getFortune(fortuneType: type, userId: userId, params: {});

        Logger.endTimer('Preload - $type', typeStopwatch);
        Logger.info('✅ [FortuneApiService] Preloaded $type fortune',
            {'preloadTime': '${typeStopwatch.elapsedMilliseconds}ms'});
        preloadResults[type] = true;
      } catch (e) {
        Logger.error('❌ [FortuneApiService] Failed to preload $type fortune',
            {'error': e.toString()});
        preloadResults[type] = false;
      }
    }

    Logger.endTimer('Preload Fortunes - Total', stopwatch);
    Logger.info('📦 [FortuneApiService] Preload completed', {
      'totalTime': '${stopwatch.elapsedMilliseconds}ms',
      'results': preloadResults,
      'successCount': preloadResults.values.where((v) => v).length,
      'failureCount': preloadResults.values.where((v) => !v).length
    });
  }

  // ============================================
  // Unified Fortune Methods
  // ============================================

  Future<Fortune> getTimeFortune(
      {required String userId,
      String fortuneType = 'time',
      Map<String, dynamic>? params}) async {
    return getFortune(fortuneType: fortuneType, userId: userId, params: params);
  }

  Future<Fortune> getInvestmentFortune(
      {required String userId,
      String fortuneType = 'investment',
      Map<String, dynamic>? params}) async {
    return getFortune(fortuneType: fortuneType, userId: userId, params: params);
  }

  Future<Fortune> getSportsFortune(
      {required String userId,
      String fortuneType = 'sports',
      Map<String, dynamic>? params}) async {
    return getFortune(fortuneType: fortuneType, userId: userId, params: params);
  }

  Future<Fortune> getRelationshipFortune(
      {required String userId,
      String fortuneType = 'relationship',
      Map<String, dynamic>? params}) async {
    final relationType = params?['relationshipType'] ?? 'love';
    final actualFortuneType = _getRelationshipMappingType(relationType);

    return getFortune(
        fortuneType: actualFortuneType, userId: userId, params: params);
  }

  Future<Fortune> getTraditionalFortune(
      {required String userId,
      String fortuneType = 'traditional',
      Map<String, dynamic>? params}) async {
    final traditionalType = params?['traditionalType'] ?? 'saju';
    final actualFortuneType = _getTraditionalMappingType(traditionalType);

    return getFortune(
        fortuneType: actualFortuneType, userId: userId, params: params);
  }

  Future<Fortune> getPersonalityFortune(
      {required String userId,
      String fortuneType = 'personality',
      Map<String, dynamic>? params}) async {
    final personalityType = params?['personalityType'] ?? 'personality';
    final actualFortuneType = _getPersonalityMappingType(personalityType);

    return getFortune(
        fortuneType: actualFortuneType, userId: userId, params: params);
  }

  Future<Fortune> getLuckyItemsFortune(
      {required String userId,
      String fortuneType = 'lucky_items',
      Map<String, dynamic>? params}) async {
    final itemType = params?['luckyItemType'] ?? 'lucky_items';
    final actualFortuneType = _getLuckyItemsMappingType(itemType);

    return getFortune(
        fortuneType: actualFortuneType, userId: userId, params: params);
  }

  Future<Fortune> getLifestyleFortune(
      {required String userId,
      String fortuneType = 'lifestyle',
      Map<String, dynamic>? params}) async {
    final lifestyleType = params?['lifestyleType'] ?? 'health';
    final actualFortuneType = _getLifestyleMappingType(lifestyleType);

    return getFortune(
        fortuneType: actualFortuneType, userId: userId, params: params);
  }

  // ============================================
  // Helper Methods
  // ============================================

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

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await _apiClient.post(endpoint, data: data);
      return _getResponseData(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException error) {
    Logger.error('🚑 [FortuneApiService] Handling DioError', {
      'type': error.type.toString(),
      'message': error.message,
      'statusCode': error.response?.statusCode,
      'responseData': error.response?.data,
      'requestPath': error.requestOptions.path,
      'requestMethod': error.requestOptions.method
    });

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        Logger.warning('⏱️ [FortuneApiService] Timeout error');
        return const NetworkException('연결 시간이 초과되었습니다');

      case DioExceptionType.connectionError:
        Logger.warning('🌐 [FortuneApiService] Connection error');
        return const NetworkException('네트워크 연결을 확인해주세요');

      case DioExceptionType.cancel:
        Logger.warning('❌ [FortuneApiService] Request cancelled');
        return const NetworkException('요청이 취소되었습니다');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? '오류가 발생했습니다';

        Logger.error('🔴 [FortuneApiService] Bad response',
            {'statusCode': statusCode, 'message': message});

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
            return const TooManyRequestsException(
                '요청이 너무 많습니다. 잠시 후 다시 시도해주세요');
          case 500:
            Logger.error('💥 [FortuneApiService] Server error');
            return const ServerException(
                message: '서버 오류가 발생했습니다', statusCode: 500);
          default:
            Logger.error('❓ [FortuneApiService] Unknown error');
            return ServerException(message: message, statusCode: statusCode);
        }

      default:
        Logger.error('❓ [FortuneApiService] Unknown error type');
        return const UnknownException();
    }
  }

  // Mapping helpers
  String _getRelationshipMappingType(String type) {
    final mapping = {
      'love': 'love',
      'compatibility': 'compatibility',
      'marriage': 'marriage',
      'ex_lover': 'ex-lover',
      'blind_date': 'blind-date',
      'chemistry': 'chemistry',
      'couple_match': 'couple-match'
    };
    return mapping[type] ?? 'love';
  }

  String _getTraditionalMappingType(String type) {
    final mapping = {
      'saju': 'saju',
      'traditional_saju': 'traditional-saju',
      'tojeong': 'tojeong',
      'salpuli': 'salpuli',
      'five_blessings': 'five-blessings'
    };
    return mapping[type] ?? 'saju';
  }

  String _getPersonalityMappingType(String type) {
    final mapping = {
      'mbti': 'mbti',
      'personality': 'personality',
      'saju_psychology': 'saju-psychology',
      'talent': 'talent',
      'blood_type': 'blood-type'
    };
    return mapping[type] ?? 'personality';
  }

  String _getLuckyItemsMappingType(String type) {
    final mapping = {
      'lucky_color': 'lucky-color',
      'lucky_number': 'lucky-number',
      'lucky_items': 'lucky-items',
      'lucky_food': 'lucky-food',
      'lucky_outfit': 'lucky-outfit',
      'lucky_place': 'lucky-place'
    };
    return mapping[type] ?? 'lucky-items';
  }

  String _getLifestyleMappingType(String type) {
    final mapping = {
      'health': 'health',
      'biorhythm': 'biorhythm',
      'moving': 'moving',
      'moving_date': 'moving-date'
    };
    return mapping[type] ?? 'health';
  }
}

// Provider
final fortuneApiServiceProvider = Provider<FortuneApiService>((ref) {
  final featureFlags = FeatureFlags();
  Logger.info('🔧 [fortuneApiServiceProvider] Creating fortune API service', {
    'edgeFunctionsEnabled': featureFlags.isEdgeFunctionsEnabled(),
    'featureFlags': 'enabled'
  });

  if (featureFlags.isEdgeFunctionsEnabled()) {
    Logger.info(
        '⚡ [fortuneApiServiceProvider] Using Edge Functions for fortune API');
    return FortuneApiServiceWithEdgeFunctions(ref);
  }

  Logger.info('🌐 [fortuneApiServiceProvider] Using traditional API service');
  final apiClient = ref.watch(apiClientProvider);
  return FortuneApiService(apiClient);
});

// Exceptions moved to lib/core/errors/exceptions.dart
// - InsufficientTokensException
// - TooManyRequestsException
