import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cached_fortune_result.dart';
import '../../features/fortune/domain/models/fortune_conditions.dart';

/// 운세 조회 최적화 서비스 (API 비용 72% 절감)
///
/// 6단계 프로세스:
/// 1️⃣ 개인 캐시 확인 (오늘 이미 조회?)
/// 2️⃣ DB 풀 크기 확인 (1000개 이상?)
/// 3️⃣ 30% 랜덤 선택
/// 4️⃣ API 호출 준비
/// 5️⃣ 광고 표시
/// 6️⃣ 결과 저장 & 표시
class FortuneOptimizationService {
  final SupabaseClient _supabase;

  // 상수
  static const int DB_POOL_THRESHOLD = 1000; // DB 풀 최소 크기
  static const double RANDOM_SELECTION_PROBABILITY = 0.3; // 30% 확률
  static const Duration DELAY_DURATION = Duration(seconds: 5); // 5초 대기

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

    print('🔮 운세 조회 시작: $fortuneType (hash: $conditionsHash)');

    try {
      // 1️⃣ 개인 캐시 확인
      final personalCache = await _checkPersonalCache(
        userId: userId,
        fortuneType: fortuneType,
        conditionsHash: conditionsHash,
      );
      if (personalCache != null) {
        print('✅ [1단계] 개인 캐시 히트 - 즉시 반환');
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
        print('✅ [2단계] DB 풀 사용 - 랜덤 선택 완료');
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
        print('✅ [3단계] 랜덤 선택 - DB에서 가져옴');
        return randomResult.copyWith(source: 'random_selection');
      }

      // 4️⃣-6️⃣ API 호출
      print('🔄 [4-6단계] API 호출 진행');
      return await _callAPIAndSave(
        userId: userId,
        fortuneType: fortuneType,
        conditionsHash: conditionsHash,
        conditions: conditions,
        onShowAd: onShowAd,
        onAPICall: onAPICall,
      );
    } catch (e, stackTrace) {
      print('❌ 운세 조회 실패: $e');
      print('Stack trace: $stackTrace');
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
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final result = await _supabase
          .from('fortune_results')
          .select()
          .eq('user_id', userId)
          .eq('fortune_type', fortuneType)
          .eq('conditions_hash', conditionsHash)
          .gte('created_at', todayStart.toIso8601String())
          .lt('created_at', todayEnd.toIso8601String())
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (result != null) {
        print('  ✓ 개인 캐시 발견');
        return CachedFortuneResult.fromJson(result);
      }

      print('  ✗ 개인 캐시 없음');
      return null;
    } catch (e) {
      print('  ⚠️ 개인 캐시 조회 실패: $e');
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

      final count = countResponse.count ?? 0;

      if (count < DB_POOL_THRESHOLD) {
        print('  ✗ DB 풀 부족 ($count/$DB_POOL_THRESHOLD)');
        return null;
      }

      print('  ✓ DB 풀 충분 ($count개)');

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
      print('  ⏳ 5초 대기 중...');
      await Future.delayed(DELAY_DURATION);

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
      print('  ⚠️ DB 풀 조회 실패: $e');
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
      if (random >= RANDOM_SELECTION_PROBABILITY) {
        print('  ✗ 랜덤 미선택 (${(random * 100).toStringAsFixed(1)}% > 30%)');
        return null;
      }

      print('  ✓ 랜덤 선택 (${(random * 100).toStringAsFixed(1)}% < 30%)');

      // 3-2. DB에서 최근 100개 중 랜덤 선택
      final results = await _supabase
          .from('fortune_results')
          .select()
          .eq('fortune_type', fortuneType)
          .eq('conditions_hash', conditionsHash)
          .order('created_at', ascending: false)
          .limit(100);

      if (results.isEmpty) {
        print('  ✗ DB에 데이터 없음');
        return null;
      }

      final selectedResult = results[Random().nextInt(results.length)];
      print('  ✓ ${results.length}개 중 하나 선택');

      // 3-3. 5초 대기
      print('  ⏳ 5초 대기 중...');
      await Future.delayed(DELAY_DURATION);

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
      print('  ⚠️ 랜덤 선택 실패: $e');
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
    print('  🔄 API 호출 준비');

    try {
      // 4. API 페이로드 생성
      final payload = conditions.buildAPIPayload();
      print('  ✓ 페이로드 생성 완료');

      // 5. 광고 표시 (5초)
      print('  📺 광고 표시 중...');
      await onShowAd();
      await Future.delayed(DELAY_DURATION);

      // 6. API 호출
      print('  🔄 API 호출 중...');
      final resultData = await onAPICall(payload);
      print('  ✓ API 응답 수신');

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

      print('  ✅ DB 저장 완료');
      return savedResult;
    } catch (e) {
      print('  ❌ API 호출 실패: $e');
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
        // 인덱싱용 필드 추가
        ...conditions.toIndexableFields(),
      };

      final response = await _supabase
          .from('fortune_results')
          .insert(data)
          .select()
          .single();

      return CachedFortuneResult.fromJson(response);
    } catch (e) {
      print('  ⚠️ DB 저장 실패: $e');

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
      print('⚠️ Pool size 조회 실패: $e');
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
      print('⚠️ API stats 조회 실패: $e');
      return [];
    }
  }
}
