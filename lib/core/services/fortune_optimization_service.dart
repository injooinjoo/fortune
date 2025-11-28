import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cached_fortune_result.dart';
import '../../features/fortune/domain/models/fortune_conditions.dart';
import '../utils/logger.dart';

/// 운세 조회 최적화 서비스 (API 비용 72% 절감)
///
/// 6단계 프로세스:
/// 1️⃣ 개인 캐시 확인 (오늘 이미 조회?)
/// 2️⃣ DB 풀 크기 확인 (300개 이상?)
/// 3️⃣ 30% 랜덤 선택
/// 4️⃣ API 호출 준비
/// 5️⃣ 광고 표시
/// 6️⃣ 결과 저장 & 표시
class FortuneOptimizationService {
  final SupabaseClient _supabase;

  // 상수
  static const int dbPoolThreshold = 300; // DB 풀 최소 크기 (1000 → 300 최적화)
  static const double randomSelectionProbability = 0.3; // 30% 확률
  static const double personalCacheAdProbability = 0.5; // 개인 캐시 50% 광고 확률
  static const Duration delayDuration = Duration(seconds: 5); // 5초 대기

  FortuneOptimizationService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// 운세 조회 메인 메서드 (6단계 프로세스 총괄)
  ///
  /// [userId] 사용자 ID
  /// [fortuneType] 운세 종류 (예: 'daily', 'love', 'tarot')
  /// [conditions] 운세별 조건 객체
  /// [onShowAd] 광고 표시 콜백 (5단계)
  /// [onAPICall] API 호출 콜백 (6단계)
  ///
  /// Returns: [CachedFortuneResult] 운세 결과
  Future<CachedFortuneResult> getFortune({
    required String userId,
    required String fortuneType,
    required FortuneConditions conditions,
    required Future<void> Function() onShowAd,
    required Future<Map<String, dynamic>> Function(Map<String, dynamic>) onAPICall,
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
        // 50% 확률로 광고 표시
        final showAd = Random().nextDouble() < personalCacheAdProbability;
        if (showAd) {
          Logger.debug('[FortuneOptimization] ✅ [1단계] 개인 캐시 히트 - 50% 광고 표시');
          await onShowAd();
          await Future.delayed(delayDuration);
        } else {
          Logger.debug('[FortuneOptimization] ✅ [1단계] 개인 캐시 히트 - 즉시 반환 (광고 생략)');
        }
        return personalCache.copyWith(source: 'personal_cache');
      }

      // 2️⃣ DB 풀 크기 확인
      final dbPoolResult = await _checkDBPoolSize(
        userId: userId,
        fortuneType: fortuneType,
        conditionsHash: conditionsHash,
        conditions: conditions,
      );
      if (dbPoolResult != null) {
        Logger.debug('[FortuneOptimization] ✅ [2단계] DB 풀 사용 - 랜덤 선택 완료');
        return dbPoolResult.copyWith(source: 'db_pool');
      }

      // 3️⃣ 30% 랜덤 선택
      final randomResult = await _randomSelection(
        userId: userId,
        fortuneType: fortuneType,
        conditionsHash: conditionsHash,
        conditions: conditions,
      );
      if (randomResult != null) {
        Logger.debug('[FortuneOptimization] ✅ [3단계] 랜덤 선택 - DB에서 가져옴');
        return randomResult.copyWith(source: 'random_selection');
      }

      // 4️⃣-6️⃣ API 호출
      Logger.debug('[FortuneOptimization] 🔄 [4-6단계] API 호출 진행');
      return await _callAPIAndSave(
        userId: userId,
        fortuneType: fortuneType,
        conditionsHash: conditionsHash,
        conditions: conditions,
        onShowAd: onShowAd,
        onAPICall: onAPICall,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ 운세 조회 실패: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
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
      // ✅ Date 컬럼으로 조회 (unique constraint와 일치)
      final today = DateTime.now();
      final todayDate = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final result = await _supabase
          .from('fortune_results')
          .select()
          .eq('user_id', userId)
          .eq('fortune_type', fortuneType)
          .eq('conditions_hash', conditionsHash)
          .eq('date', todayDate)  // ✅ FIXED: Use date column (not created_at)
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

  /// 2단계: DB 풀 크기 확인
  ///
  /// 동일 조건의 전체 데이터가 1000개 이상이면 랜덤 선택
  Future<CachedFortuneResult?> _checkDBPoolSize({
    required String userId,
    required String fortuneType,
    required String conditionsHash,
    required FortuneConditions conditions,
  }) async {
    try {
      // 2-1. DB 풀 크기 확인
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

      // 2-2. 랜덤 선택
      final randomOffset = Random().nextInt(count);
      final randomResult = await _supabase
          .from('fortune_results')
          .select()
          .eq('fortune_type', fortuneType)
          .eq('conditions_hash', conditionsHash)
          .limit(1)
          .range(randomOffset, randomOffset)
          .single();

      // 2-3. 5초 대기
      debugPrint('  ⏳ 5초 대기 중...');
      await Future.delayed(delayDuration);

      // 2-4. 사용자 히스토리에 저장
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

  /// 3단계: 30% 랜덤 선택
  ///
  /// 30% 확률로 기존 DB에서 랜덤 선택
  Future<CachedFortuneResult?> _randomSelection({
    required String userId,
    required String fortuneType,
    required String conditionsHash,
    required FortuneConditions conditions,
  }) async {
    try {
      // 3-1. 30% 확률 체크
      final random = Random().nextDouble();
      if (random >= randomSelectionProbability) {
        debugPrint('  ✗ 랜덤 미선택 (${(random * 100).toStringAsFixed(1)}% > 30%)');
        return null;
      }

      debugPrint('  ✓ 랜덤 선택 (${(random * 100).toStringAsFixed(1)}% < 30%)');

      // 3-2. DB에서 최근 100개 중 랜덤 선택
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

      // 3-3. 5초 대기
      debugPrint('  ⏳ 5초 대기 중...');
      await Future.delayed(delayDuration);

      // 3-4. 사용자 히스토리에 저장
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

  /// 4-6단계: API 호출 & 저장
  ///
  /// API 호출하여 새로운 운세 생성
  Future<CachedFortuneResult> _callAPIAndSave({
    required String userId,
    required String fortuneType,
    required String conditionsHash,
    required FortuneConditions conditions,
    required Future<void> Function() onShowAd,
    required Future<Map<String, dynamic>> Function(Map<String, dynamic>) onAPICall,
  }) async {
    debugPrint('  🔄 API 호출 준비');

    try {
      // 4. API 페이로드 생성
      final payload = conditions.buildAPIPayload();
      debugPrint('  ✓ 페이로드 생성 완료');

      // 5. 광고 표시 (5초)
      debugPrint('  📺 광고 표시 중...');
      await onShowAd();
      await Future.delayed(delayDuration);

      // 6. API 호출
      debugPrint('  🔄 API 호출 중...');
      final resultData = await onAPICall(payload);
      debugPrint('  ✓ API 응답 수신');

      // 6-2. DB 저장
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
        // 인덱싱용 필드 추가 (DB 컬럼이 없으면 무시됨)
        // ...conditions.toIndexableFields(), // ← 주석 처리 (DB에 해당 컬럼 없음)
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
      // ⚠️ 주의: 저장 실패 시 다음 실행에서 캐시를 찾을 수 없음!
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
