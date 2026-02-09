import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cached_fortune_result.dart';
import '../../features/fortune/domain/models/fortune_conditions.dart';
import '../utils/logger.dart';
import 'cohort_fortune_service.dart';

/// 운세 조회 최적화 서비스 (API 비용 90% 절감)
///
/// 5단계 프로세스:
/// 1️⃣ 개인 캐시 확인 (오늘 이미 조회?)
/// 2️⃣ Cohort Pool 조회 (90% 절감)
/// 3️⃣ DB 풀 크기 확인 (300개 이상?)
/// 4️⃣ 30% 랜덤 선택
/// 5️⃣ API 호출 & 결과 저장
class FortuneOptimizationService {
  final SupabaseClient _supabase;
  late final CohortFortuneService _cohortService;

  // 상수
  static const int dbPoolThreshold = 300; // DB 풀 최소 크기
  static const int cohortPoolThreshold = 25; // Cohort Pool 최소 크기
  static const double randomSelectionProbability = 0.3; // 30% 확률

  FortuneOptimizationService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client {
    _cohortService = CohortFortuneService(supabase: _supabase);
  }

  /// 운세 조회 메인 메서드
  ///
  /// [userId] 사용자 ID
  /// [fortuneType] 운세 종류 (예: 'daily', 'love', 'tarot')
  /// [conditions] 운세별 조건 객체
  /// [onAPICall] API 호출 콜백
  /// [inputConditions] Cohort Pool 조회용 원본 입력 (선택)
  ///
  /// Returns: [CachedFortuneResult] 운세 결과
  Future<CachedFortuneResult> getFortune({
    required String userId,
    required String fortuneType,
    required FortuneConditions conditions,
    required Future<Map<String, dynamic>> Function(Map<String, dynamic>) onAPICall,
    Map<String, dynamic>? inputConditions,
  }) async {
    final conditionsHash = conditions.generateHash();

    Logger.info('[FortuneOptimization] 🔮 운세 조회 시작: $fortuneType (hash: $conditionsHash)');

    try {
      // 1️⃣ 개인 캐시 확인
      final personalCache = await _checkPersonalCache(
        userId: userId,
        fortuneType: fortuneType,
        conditionsHash: conditionsHash,
      );
      if (personalCache != null) {
        Logger.debug('[FortuneOptimization] ✅ [1단계] 개인 캐시 히트 - 즉시 반환');
        return personalCache.copyWith(source: 'personal_cache');
      }

      // 2️⃣ Cohort Pool 조회 (90% API 절감)
      final cohortResult = await _checkCohortPool(
        userId: userId,
        fortuneType: fortuneType,
        conditionsHash: conditionsHash,
        conditions: conditions,
        inputConditions: inputConditions ?? conditions.buildAPIPayload(),
      );
      if (cohortResult != null) {
        Logger.debug('[FortuneOptimization] ✅ [2단계] Cohort Pool 히트 - 즉시 반환');
        return cohortResult.copyWith(source: 'cohort_pool');
      }

      // 3️⃣ DB 풀 크기 확인
      final dbPoolResult = await _checkDBPoolSize(
        userId: userId,
        fortuneType: fortuneType,
        conditionsHash: conditionsHash,
        conditions: conditions,
      );
      if (dbPoolResult != null) {
        Logger.debug('[FortuneOptimization] ✅ [3단계] DB 풀 사용 - 랜덤 선택 완료');
        return dbPoolResult.copyWith(source: 'db_pool');
      }

      // 4️⃣ 30% 랜덤 선택
      final randomResult = await _randomSelection(
        userId: userId,
        fortuneType: fortuneType,
        conditionsHash: conditionsHash,
        conditions: conditions,
      );
      if (randomResult != null) {
        Logger.debug('[FortuneOptimization] ✅ [4단계] 랜덤 선택 - DB에서 가져옴');
        return randomResult.copyWith(source: 'random_selection');
      }

      // 5️⃣ API 호출
      Logger.debug('[FortuneOptimization] 🔄 [5단계] API 호출 진행');
      final apiResult = await _callAPIAndSave(
        userId: userId,
        fortuneType: fortuneType,
        conditionsHash: conditionsHash,
        conditions: conditions,
        onAPICall: onAPICall,
      );

      // API 호출 후 Cohort Pool에 저장 (다음 사용자를 위해)
      if (apiResult.apiCall) {
        await _saveToCohortPool(
          fortuneType: fortuneType,
          inputConditions: inputConditions ?? conditions.buildAPIPayload(),
          resultData: apiResult.resultData,
        );
      }

      return apiResult;
    } catch (e, stackTrace) {
      debugPrint('❌ 운세 조회 실패: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// 2단계: Cohort Pool 조회
  ///
  /// 동일 Cohort(나잇대, 띠, 오행 등)의 기존 결과 활용
  Future<CachedFortuneResult?> _checkCohortPool({
    required String userId,
    required String fortuneType,
    required String conditionsHash,
    required FortuneConditions conditions,
    required Map<String, dynamic> inputConditions,
  }) async {
    try {
      // Cohort Pool 크기 확인
      final poolSize = await _cohortService.getPoolSize(
        fortuneType: fortuneType,
        input: inputConditions,
      );

      if (poolSize < cohortPoolThreshold) {
        debugPrint('  ✗ Cohort Pool 부족 ($poolSize/$cohortPoolThreshold)');
        return null;
      }

      debugPrint('  ✓ Cohort Pool 충분 ($poolSize개)');

      // Cohort Pool에서 결과 조회
      final cohortResult = await _cohortService.getFromCohortPool(
        fortuneType: fortuneType,
        input: inputConditions,
      );

      if (cohortResult == null) {
        debugPrint('  ✗ Cohort Pool 조회 실패');
        return null;
      }

      debugPrint('  ✓ Cohort Pool에서 결과 조회 성공');

      // 사용자 히스토리에 저장
      return await _saveToUserHistory(
        userId: userId,
        fortuneType: fortuneType,
        conditionsHash: conditionsHash,
        conditions: conditions,
        resultData: cohortResult.data,
        source: 'cohort_pool',
        apiCall: false,
      );
    } catch (e) {
      debugPrint('  ⚠️ Cohort Pool 조회 실패: $e');
      return null; // 에러 시 다음 단계로 진행
    }
  }

  /// Cohort Pool에 결과 저장 (API 호출 후)
  Future<void> _saveToCohortPool({
    required String fortuneType,
    required Map<String, dynamic> inputConditions,
    required Map<String, dynamic> resultData,
  }) async {
    try {
      await _cohortService.saveToPool(
        fortuneType: fortuneType,
        input: inputConditions,
        result: resultData,
      );
      debugPrint('  ✅ Cohort Pool 저장 완료');
    } catch (e) {
      debugPrint('  ⚠️ Cohort Pool 저장 실패 (무시): $e');
    }
  }

  /// 1단계: 개인 캐시 확인
  ///
  /// 오늘 동일 조건으로 이미 조회한 이력이 있는지 확인
  Future<CachedFortuneResult?> _checkPersonalCache({
    required String userId,
    required String fortuneType,
    required String conditionsHash,
  }) async {
    try {
      // Date 컬럼으로 조회 (unique constraint와 일치)
      final today = DateTime.now();
      final todayDate = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final result = await _supabase
          .from('fortune_results')
          .select()
          .eq('user_id', userId)
          .eq('fortune_type', fortuneType)
          .eq('conditions_hash', conditionsHash)
          .eq('date', todayDate)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (result != null) {
        debugPrint('  ✓ 개인 캐시 발견');
        return CachedFortuneResult.fromJson(result);
      }

      debugPrint('  ✗ 개인 캐시 없음');
      return null;
    } catch (e) {
      debugPrint('  ⚠️ 개인 캐시 조회 실패: $e');
      return null; // 에러 시 다음 단계로 진행
    }
  }

  /// 3단계: DB 풀 크기 확인
  ///
  /// 동일 조건의 전체 데이터가 300개 이상이면 랜덤 선택
  Future<CachedFortuneResult?> _checkDBPoolSize({
    required String userId,
    required String fortuneType,
    required String conditionsHash,
    required FortuneConditions conditions,
  }) async {
    try {
      // DB 풀 크기 확인
      final countResponse = await _supabase
          .from('fortune_results')
          .select('id')
          .eq('fortune_type', fortuneType)
          .eq('conditions_hash', conditionsHash)
          .count();

      final count = countResponse.count;

      if (count < dbPoolThreshold) {
        debugPrint('  ✗ DB 풀 부족 ($count/$dbPoolThreshold)');
        return null;
      }

      debugPrint('  ✓ DB 풀 충분 ($count개)');

      // 랜덤 선택
      final randomOffset = Random().nextInt(count);
      final randomResult = await _supabase
          .from('fortune_results')
          .select()
          .eq('fortune_type', fortuneType)
          .eq('conditions_hash', conditionsHash)
          .limit(1)
          .range(randomOffset, randomOffset)
          .single();

      // 사용자 히스토리에 저장
      await _saveToUserHistory(
        userId: userId,
        fortuneType: fortuneType,
        conditionsHash: conditionsHash,
        conditions: conditions,
        resultData: randomResult['result_data'] as Map<String, dynamic>,
        source: 'db_pool',
        apiCall: false,
      );

      return CachedFortuneResult.fromJson(randomResult);
    } catch (e) {
      debugPrint('  ⚠️ DB 풀 조회 실패: $e');
      return null; // 에러 시 다음 단계로 진행
    }
  }

  /// 4단계: 30% 랜덤 선택
  ///
  /// 30% 확률로 기존 DB에서 랜덤 선택
  Future<CachedFortuneResult?> _randomSelection({
    required String userId,
    required String fortuneType,
    required String conditionsHash,
    required FortuneConditions conditions,
  }) async {
    try {
      // 30% 확률 체크
      final random = Random().nextDouble();
      if (random >= randomSelectionProbability) {
        debugPrint('  ✗ 랜덤 미선택 (${(random * 100).toStringAsFixed(1)}% > 30%)');
        return null;
      }

      debugPrint('  ✓ 랜덤 선택 (${(random * 100).toStringAsFixed(1)}% < 30%)');

      // DB에서 최근 100개 중 랜덤 선택
      final results = await _supabase
          .from('fortune_results')
          .select()
          .eq('fortune_type', fortuneType)
          .eq('conditions_hash', conditionsHash)
          .order('created_at', ascending: false)
          .limit(100);

      if (results.isEmpty) {
        debugPrint('  ✗ DB에 데이터 없음');
        return null;
      }

      final selectedResult = results[Random().nextInt(results.length)];
      debugPrint('  ✓ ${results.length}개 중 하나 선택');

      // 사용자 히스토리에 저장
      await _saveToUserHistory(
        userId: userId,
        fortuneType: fortuneType,
        conditionsHash: conditionsHash,
        conditions: conditions,
        resultData: selectedResult['result_data'] as Map<String, dynamic>,
        source: 'random_selection',
        apiCall: false,
      );

      return CachedFortuneResult.fromJson(selectedResult);
    } catch (e) {
      debugPrint('  ⚠️ 랜덤 선택 실패: $e');
      return null; // 에러 시 API 호출로 진행
    }
  }

  /// 5단계: API 호출 & 저장
  ///
  /// API 호출하여 새로운 운세 생성
  Future<CachedFortuneResult> _callAPIAndSave({
    required String userId,
    required String fortuneType,
    required String conditionsHash,
    required FortuneConditions conditions,
    required Future<Map<String, dynamic>> Function(Map<String, dynamic>) onAPICall,
  }) async {
    debugPrint('  🔄 API 호출 준비');

    try {
      // API 페이로드 생성
      final payload = conditions.buildAPIPayload();
      debugPrint('  ✓ 페이로드 생성 완료');

      // API 호출
      debugPrint('  🔄 API 호출 중...');
      final resultData = await onAPICall(payload);
      debugPrint('  ✓ API 응답 수신');

      // DB 저장
      final savedResult = await _saveToUserHistory(
        userId: userId,
        fortuneType: fortuneType,
        conditionsHash: conditionsHash,
        conditions: conditions,
        resultData: resultData,
        source: 'api',
        apiCall: true,
      );

      debugPrint('  ✅ API 호출 성공 및 fortune_results 저장 완료');
      return savedResult;
    } catch (e) {
      debugPrint('  ❌ API 호출 실패: $e');
      rethrow;
    }
  }

  /// 사용자 히스토리에 저장
  ///
  /// fortune_results 테이블에 INSERT
  Future<CachedFortuneResult> _saveToUserHistory({
    required String userId,
    required String fortuneType,
    required String conditionsHash,
    required FortuneConditions conditions,
    required Map<String, dynamic> resultData,
    required String source,
    required bool apiCall,
  }) async {
    try {
      final now = DateTime.now();
      final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final data = {
        'user_id': userId,
        'fortune_type': fortuneType,
        'conditions_hash': conditionsHash,
        'conditions_data': conditions.toJson(),
        'result_data': resultData,
        'source': source,
        'api_call': apiCall,
        'date': today,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final response = await _supabase
          .from('fortune_results')
          .insert(data)
          .select()
          .single();

      debugPrint('  ✅ fortune_results 저장 완료');
      return CachedFortuneResult.fromJson(response);
    } catch (e) {
      debugPrint('  ❌ fortune_results 저장 실패: $e');

      // DB 저장 실패해도 결과는 반환 (메모리에서 생성)
      final now = DateTime.now();
      return CachedFortuneResult(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        fortuneType: fortuneType,
        resultData: resultData,
        conditionsHash: conditionsHash,
        conditionsData: conditions.toJson(),
        createdAt: now,
        updatedAt: now,
        source: source,
        apiCall: apiCall,
      );
    }
  }

  /// DB 풀 크기 확인 (헬퍼 함수 사용)
  ///
  /// Supabase Function: get_fortune_pool_size() 호출
  Future<int> getPoolSize({
    required String fortuneType,
    required String conditionsHash,
  }) async {
    try {
      final response = await _supabase
          .rpc('get_fortune_pool_size', params: {
        'p_fortune_type': fortuneType,
        'p_conditions_hash': conditionsHash,
      });

      return response as int;
    } catch (e) {
      debugPrint('⚠️ Pool size 조회 실패: $e');
      return 0;
    }
  }

  /// API 호출 통계 조회
  ///
  /// Supabase Function: get_fortune_api_stats() 호출
  Future<List<Map<String, dynamic>>> getAPIStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final start = startDate ?? DateTime.now().subtract(const Duration(days: 7));
      final end = endDate ?? DateTime.now();

      final response = await _supabase
          .rpc('get_fortune_api_stats', params: {
        'p_start_date': start.toIso8601String().split('T')[0],
        'p_end_date': end.toIso8601String().split('T')[0],
      });

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('⚠️ API stats 조회 실패: $e');
      return [];
    }
  }
}
