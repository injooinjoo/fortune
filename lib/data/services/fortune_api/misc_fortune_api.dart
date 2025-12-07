import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/fortune.dart';
import '../../models/fortune_response_model.dart';
import 'package:fortune/services/cache_service.dart';
import '../../../core/errors/exceptions.dart';

class MiscFortuneApi {
  final ApiClient _apiClient;
  final CacheService _cacheService;

  MiscFortuneApi(this._apiClient, this._cacheService);

  // Wealth Fortune
  Future<Fortune> getWealthFortune({
    required String userId,
    Map<String, dynamic>? financialData}) async {
    final stopwatch = Logger.startTimer('getWealthFortune - Total');

    Logger.info('🔍 [FortuneApiService] getWealthFortune called', {
      'userId': userId,
      'hasFinancialData': financialData != null,
      'dataKeys': financialData?.keys.toList()});

    try {
      Logger.debug('🔍 [FortuneApiService] Making API call', {
        'endpoint': ApiEndpoints.wealthFortune,
        'hasData': financialData != null});

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
        'statusCode': e.response?.statusCode});
      rethrow;
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
      rethrow;
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
      rethrow;
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

  // Health Fortune - delegates to generic getFortune
  Future<Fortune> getHealthFortune({
    required String userId,
    required Future<Fortune> Function({required String fortuneType, required String userId}) getFortune}) async {
    return getFortune(fortuneType: 'health', userId: userId);
  }

  // Moving Fortune - delegates to generic getFortune
  Future<Fortune> getMovingFortune({
    required String userId,
    required Future<Fortune> Function({required String fortuneType, required String userId}) getFortune}) async {
    return getFortune(fortuneType: 'moving', userId: userId);
  }

  // Wish Fortune - delegates to generic getFortune
  Future<Fortune> getWishFortune({
    required String userId,
    required String wish,
    required Future<Fortune> Function({required String fortuneType, required String userId, Map<String, dynamic>? params}) getFortune}) async {
    return getFortune(
      fortuneType: 'wish',
      userId: userId,
      params: {'wish': wish});
  }

  // Talent Fortune - delegates to generic getFortune
  Future<Fortune> getTalentFortune({
    required String userId,
    required Future<Fortune> Function({required String fortuneType, required String userId}) getFortune}) async {
    return getFortune(fortuneType: 'talent', userId: userId);
  }

  // Palmistry Fortune - delegates to generic getFortune
  Future<Fortune> getPalmistryFortune({
    required String userId,
    required Future<Fortune> Function({required String fortuneType, required String userId}) getFortune}) async {
    return getFortune(fortuneType: 'palmistry', userId: userId);
  }

  // Physiognomy Fortune - delegates to generic getFortune
  Future<Fortune> getPhysiognomyFortune({
    required String userId,
    required Future<Fortune> Function({required String fortuneType, required String userId}) getFortune}) async {
    return getFortune(fortuneType: 'physiognomy', userId: userId);
  }

  // Biorhythm Fortune - delegates to generic getFortune
  Future<Fortune> getBiorhythmFortune({
    required String userId,
    required Future<Fortune> Function({required String fortuneType, required String userId}) getFortune}) async {
    return getFortune(fortuneType: 'biorhythm', userId: userId);
  }

  // Past Life Fortune - delegates to generic getFortune
  Future<Fortune> getPastLifeFortune({
    required String userId,
    required Future<Fortune> Function({required String fortuneType, required String userId}) getFortune}) async {
    return getFortune(fortuneType: 'past-life', userId: userId);
  }

  // New Year Fortune - delegates to generic getFortune
  Future<Fortune> getNewYearFortune({
    required String userId,
    required Future<Fortune> Function({required String fortuneType, required String userId}) getFortune}) async {
    return getFortune(fortuneType: 'new-year', userId: userId);
  }

  // Same Birthday Celebrity Fortune - delegates to generic getFortune
  Future<Fortune> getSameBirthdayCelebrityFortune({
    required String userId,
    required DateTime birthDate,
    required String lunarSolar,
    required Future<Fortune> Function({required String fortuneType, required String userId, Map<String, dynamic>? params}) getFortune}) async {
    return getFortune(
      fortuneType: 'same-birthday-celebrity',
      userId: userId,
      params: {
        'birth_date': birthDate.toIso8601String(),
        'lunar_solar': lunarSolar});
  }

  // Helper methods
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
}
