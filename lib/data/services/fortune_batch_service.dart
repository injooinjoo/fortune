import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/edge_functions_endpoints.dart';
import '../../core/config/feature_flags.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/fortune.dart';
import '../models/fortune_response_model.dart';
import '../../presentation/providers/providers.dart';
import 'package:fortune/services/cache_service.dart';
import 'package:fortune/models/fortune_model.dart';

/// 배치 운세 패키지 타입
enum BatchPackageType {
  onboarding('onboarding', '온보딩 완료 패키지', 5),
  dailyRefresh('daily_refresh', '일일 갱신 패키지', 3),
  loveSingle('love_single', '연애운 패키지 (솔로)', 4),
  loveCouple('love_couple', '연애운 패키지 (커플)', 4),
  career('career', '커리어 패키지', 5),
  luckyItems('lucky_items', '행운 아이템 패키지', 2),
  premiumComplete('premium_complete', '프리미엄 종합 패키지', 15);

  final String key;
  final String description;
  final int tokenCost;

  const BatchPackageType(this.key, this.description, this.tokenCost);
}

/// 배치 운세 결과
class BatchFortuneResult {
  final String type;
  final Fortune fortune;
  final bool fromCache;

  BatchFortuneResult(
      {required this.type, required this.fortune, required this.fromCache});
}

/// 배치 운세 생성을 위한 서비스
class FortuneBatchService {
  final ApiClient _apiClient;
  final CacheService _cacheService;
  final FeatureFlags _featureFlags = FeatureFlags.instance;

  FortuneBatchService(this._apiClient) : _cacheService = CacheService();

  /// 패키지 타입으로 배치 운세 생성
  Future<List<BatchFortuneResult>> generateBatchFortunesByPackage(
      {required String userId,
      required BatchPackageType packageType,
      Map<String, dynamic>? userProfile}) async {
    debugPrint('package: ${packageType.key}');

    try {
      // Edge Functions 사용 여부 확인
      if (_featureFlags.isEdgeFunctionsEnabled()) {
        return await _generateBatchWithEdgeFunctions(
            userId: userId, packageType: packageType, userProfile: userProfile);
      }

      // 기존 API 사용
      return await _generateBatchWithTraditionalAPI(
          userId: userId, packageType: packageType, userProfile: userProfile);
    } catch (e) {
      debugPrint('Error generating batch fortunes: $e');
      // 폴백: 캐시된 데이터 반환
      return await _getCachedBatchFortunes(userId, packageType);
    }
  }

  /// 커스텀 운세 타입으로 배치 운세 생성
  Future<List<BatchFortuneResult>> generateBatchFortunesByTypes(
      {required String userId,
      required List<String> fortuneTypes,
      Map<String, dynamic>? userProfile}) async {
    debugPrint('types: ${fortuneTypes.join('), ')}');

    try {
      // Edge Functions 사용 여부 확인
      if (_featureFlags.isEdgeFunctionsEnabled()) {
        return await _generateCustomBatchWithEdgeFunctions(
            userId: userId,
            fortuneTypes: fortuneTypes,
            userProfile: userProfile);
      }

      // 기존 API 사용
      return await _generateCustomBatchWithTraditionalAPI(
          userId: userId, fortuneTypes: fortuneTypes, userProfile: userProfile);
    } catch (e) {
      debugPrint('Error generating batch fortunes: $e');
      // 폴백: 개별 운세 생성
      return await _generateIndividualFortunes(userId, fortuneTypes);
    }
  }

  /// Edge Functions를 사용한 배치 생성
  Future<List<BatchFortuneResult>> _generateBatchWithEdgeFunctions(
      {required String userId,
      required BatchPackageType packageType,
      Map<String, dynamic>? userProfile}) async {
    final edgeFunctionsDio = Dio(BaseOptions(
        baseUrl: EdgeFunctionsEndpoints.currentBaseUrl,
        headers: {'Content-Type': 'application/json', 'apikey': null}));

    // 인증 토큰 추가
    final authToken = _apiClient.dio.options.headers['Authorization'];
    if (authToken != null) {
      edgeFunctionsDio.options.headers['Authorization'] = authToken;
    }

    final response = await edgeFunctionsDio.post(
        EdgeFunctionsEndpoints.fortuneBatch,
        data: {'package_type': packageType.key, 'user_profile': null});

    return _processBatchResponse(response.data, userId);
  }

  /// Edge Functions를 사용한 커스텀 배치 생성
  Future<List<BatchFortuneResult>> _generateCustomBatchWithEdgeFunctions(
      {required String userId,
      required List<String> fortuneTypes,
      Map<String, dynamic>? userProfile}) async {
    final edgeFunctionsDio = Dio(BaseOptions(
        baseUrl: EdgeFunctionsEndpoints.currentBaseUrl,
        headers: {'Content-Type': 'application/json', 'apikey': null}));

    // 인증 토큰 추가
    final authToken = _apiClient.dio.options.headers['Authorization'];
    if (authToken != null) {
      edgeFunctionsDio.options.headers['Authorization'] = authToken;
    }

    final response = await edgeFunctionsDio.post(
        EdgeFunctionsEndpoints.fortuneBatch,
        data: {'custom_fortune_types': fortuneTypes, 'user_profile': null});

    return _processBatchResponse(response.data, userId);
  }

  /// 기존 API를 사용한 배치 생성
  Future<List<BatchFortuneResult>> _generateBatchWithTraditionalAPI(
      {required String userId,
      required BatchPackageType packageType,
      Map<String, dynamic>? userProfile}) async {
    final response =
        await _apiClient.post('/api/fortune/generate-batch', data: {
      'request_type': packageType.key,
      'user_profile': userProfile,
      'fortune_categories': null
    });

    return _processBatchResponse(response.data, userId);
  }

  /// 기존 API를 사용한 커스텀 배치 생성
  Future<List<BatchFortuneResult>> _generateCustomBatchWithTraditionalAPI(
      {required String userId,
      required List<String> fortuneTypes,
      Map<String, dynamic>? userProfile}) async {
    final response =
        await _apiClient.post('/api/fortune/generate-batch', data: {
      'request_type': 'custom',
      'user_profile': userProfile,
      'fortune_categories': null
    });

    return _processBatchResponse(response.data, userId);
  }

  /// 배치 응답 처리
  List<BatchFortuneResult> _processBatchResponse(
      Map<String, dynamic> data, String userId) {
    final fortunes = data['fortunes'] as List;
    final results = <BatchFortuneResult>[];

    for (final fortuneData in fortunes) {
      final type = fortuneData['type'] as String;
      final fromCache = fortuneData['cached'] ?? false;
      final fortuneInfo = fortuneData['data'];

      // Fortune 엔티티 생성
      final fortune = Fortune(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          type: type,
          content: fortuneInfo['description'] ?? '',
          createdAt: DateTime.now(),
          metadata: fortuneInfo,
          overallScore: fortuneInfo['overall_score'],
          summary: fortuneInfo['summary'],
          additionalInfo: {
            if (fortuneInfo['lucky_items']?['color'] != null)
              'luckyColor': fortuneInfo['lucky_items']['color'],
            if (fortuneInfo['lucky_items']?['number'] != null)
              'luckyNumber': fortuneInfo['lucky_items']['number'],
            if (fortuneInfo['advice'] != null) 'advice': fortuneInfo['advice']
          },
          tokenCost: fromCache ? 0 : 1);

      // 캐시에 저장
      if (!fromCache) {
        _cacheService.cacheFortune(
            type,
            {'userId': userId},
            FortuneModel(
                id: fortune.id,
                userId: fortune.userId,
                type: type,
                content: fortune.content,
                createdAt: fortune.createdAt,
                metadata: fortune.metadata,
                tokenCost: fortune.tokenCost));
      }

      results.add(BatchFortuneResult(
          type: type, fortune: fortune, fromCache: fromCache));
    }

    return results;
  }

  /// 패키지 타입에 따른 운세 타입 반환
  List<String> _getFortuneTypesForPackage(BatchPackageType packageType) {
    switch (packageType) {
      case BatchPackageType.onboarding:
        return ['saju', 'personality', 'talent', 'daily', 'yearly'];
      case BatchPackageType.dailyRefresh:
        return ['daily', 'hourly', 'biorhythm', 'lucky-color'];
      case BatchPackageType.loveSingle:
        return ['love', 'destiny', 'blind-date', 'celebrity-match'];
      case BatchPackageType.loveCouple:
        return ['love', 'couple-match', 'chemistry', 'marriage'];
      case BatchPackageType.career:
        return ['career', 'wealth', 'business', 'talent'];
      case BatchPackageType.luckyItems:
        return [
          'lucky-color',
          'lucky-number',
          'lucky-items',
          'lucky-food',
          'lucky-outfit'
        ];
      case BatchPackageType.premiumComplete:
        return [
          'saju',
          'traditional-saju',
          'tojeong',
          'destiny',
          'past-life',
          'daily',
          'weekly',
          'monthly',
          'yearly',
          'love',
          'career',
          'wealth',
          'health',
          'lucky-items',
          'biorhythm'
        ];
    }
  }

  /// 캐시된 배치 운세 가져오기
  Future<List<BatchFortuneResult>> _getCachedBatchFortunes(
      String userId, BatchPackageType packageType) async {
    final fortuneTypes = _getFortuneTypesForPackage(packageType);
    final results = <BatchFortuneResult>[];

    for (final type in fortuneTypes) {
      final cachedFortune =
          await _cacheService.getCachedFortune(type, {'userId': userId});

      if (cachedFortune != null) {
        results.add(BatchFortuneResult(
            type: type, fortune: cachedFortune.toEntity(), fromCache: true));
      }
    }

    return results;
  }

  /// 개별 운세 생성 (폴백)
  Future<List<BatchFortuneResult>> _generateIndividualFortunes(
      String userId, List<String> fortuneTypes) async {
    final results = <BatchFortuneResult>[];

    for (final type in fortuneTypes) {
      try {
        // 캐시 확인
        final cachedFortune =
            await _cacheService.getCachedFortune(type, {'userId': userId});

        if (cachedFortune != null) {
          results.add(BatchFortuneResult(
              type: type, fortune: cachedFortune.toEntity(), fromCache: true));
          continue;
        }

        // 개별 API 호출
        final response = await _apiClient.get('Fortune cached');
        final fortuneResponse = FortuneResponseModel.fromJson(response.data);

        results.add(BatchFortuneResult(
            type: type, fortune: fortuneResponse.toEntity(), fromCache: false));
      } catch (e) {
        debugPrint('Error generating batch fortunes: $e');
      }
    }

    return results;
  }

  /// 시스템 레벨 운세 생성 (MBTI, 혈액형 등)
  Future<Map<String, dynamic>> generateSystemFortunes(
      {required String fortuneType,
      String period = 'monthly',
      bool forceRegenerate = false}) async {
    debugPrint('Generating system fortunes for type: $fortuneType');

    if (_featureFlags.isEdgeFunctionsEnabled()) {
      final edgeFunctionsDio = Dio(BaseOptions(
          baseUrl: EdgeFunctionsEndpoints.currentBaseUrl,
          headers: {'Content-Type': 'application/json', 'apikey': null}));

      final response = await edgeFunctionsDio
          .post(EdgeFunctionsEndpoints.fortuneSystem, data: {
        'fortune_type': fortuneType,
        'period': period,
        'force_regenerate': null
      });

      return response.data;
    }

    // 기존 API 폴백
    throw UnimplementedError(
        'System fortune generation not available in traditional API');
  }

  /// 온보딩 완료 시 호출
  Future<List<BatchFortuneResult>> generateOnboardingFortunes(
      {required String userId,
      required Map<String, dynamic> userProfile}) async {
    return generateBatchFortunesByPackage(
        userId: userId,
        packageType: BatchPackageType.onboarding,
        userProfile: userProfile);
  }

  /// 일일 자동 갱신
  Future<List<BatchFortuneResult>> refreshDailyFortunes(
      {required String userId, Map<String, dynamic>? userProfile}) async {
    return generateBatchFortunesByPackage(
        userId: userId,
        packageType: BatchPackageType.dailyRefresh,
        userProfile: userProfile);
  }

  /// 패키지별 토큰 절약률 계산
  double calculateTokenSavings(BatchPackageType packageType) {
    final fortuneTypes = _getFortuneTypesForPackage(packageType);

    // 개별 토큰 비용 (가정,
    const individualCosts = {
      'saju': 5,
      'traditional-saju': 5,
      'tojeong': 4,
      'destiny': 4,
      'past-life': 3,
      'personality': 3,
      'talent': 3,
      'daily': 1,
      'today': 1,
      'tomorrow': 1,
      'hourly': 1,
      'weekly': 2,
      'monthly': 2,
      'yearly': 3,
      'love': 2,
      'marriage': 3,
      'blind-date': 2,
      'celebrity-match': 2,
      'couple-match': 3,
      'chemistry': 3,
      'career': 3,
      'wealth': 3,
      'business': 4,
      'lucky-color': 1,
      'lucky-number': 1,
      'lucky-items': 2,
      'lucky-food': 1,
      'lucky-outfit': 2,
      'biorhythm': 2,
      'health': 2,
      'pet': 2,
      'pet-dog': 2,
      'pet-cat': 2,
      'pet-compatibility': 3,
      'children': 3,
      'parenting': 3,
      'pregnancy': 3,
      'family-harmony': 3
    };

    final individualTotal = fortuneTypes.fold<int>(
        0, (sum, type) => sum + (individualCosts[type] ?? 2));

    final savings =
        (individualTotal - packageType.tokenCost) / individualTotal * 100;
    return savings;
  }

  /// 패키지에 포함된 운세 타입 목록 반환
  List<String> getPackageFortuneTypes(BatchPackageType packageType) {
    return _getFortuneTypesForPackage(packageType);
  }
}

// Provider
final fortuneBatchServiceProvider = Provider<FortuneBatchService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FortuneBatchService(apiClient);
});
