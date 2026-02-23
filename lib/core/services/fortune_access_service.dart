import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fortune_result.dart';
import '../models/cached_fortune_result.dart';
import '../constants/soul_rates.dart';
import '../utils/logger.dart';
import '../../features/fortune/domain/models/fortune_conditions.dart';
import 'fortune_optimization_service.dart';
import 'cohort_fortune_service.dart';

/// 운세 접근 결과
class FortuneAccessResult {
  /// 접근 가능 여부
  final bool canAccess;

  /// 프리미엄 사용자 여부
  final bool isPremium;

  /// 캐시된 결과 존재 여부
  final bool hasCached;

  /// 캐시된 결과 (있는 경우)
  final CachedFortuneResult? cachedResult;

  /// 필요한 토큰 수 (프리미엄 운세)
  final int requiredTokens;

  /// 획득할 토큰 수 (무료 운세)
  final int willEarnTokens;

  /// 결과 소스 (캐시/cohort/api)
  final String source;

  /// 접근 거부 사유 (canAccess = false 일 때)
  final String? denyReason;

  const FortuneAccessResult({
    required this.canAccess,
    required this.isPremium,
    required this.hasCached,
    this.cachedResult,
    required this.requiredTokens,
    required this.willEarnTokens,
    required this.source,
    this.denyReason,
  });

  /// 프리미엄 사용자용 결과
  factory FortuneAccessResult.premium() => const FortuneAccessResult(
        canAccess: true,
        isPremium: true,
        hasCached: false,
        requiredTokens: 0,
        willEarnTokens: 0,
        source: 'premium',
      );

  /// 캐시 히트 결과
  factory FortuneAccessResult.cached({
    required CachedFortuneResult cached,
    required bool isPremium,
  }) =>
      FortuneAccessResult(
        canAccess: true,
        isPremium: isPremium,
        hasCached: true,
        cachedResult: cached,
        requiredTokens: 0,
        willEarnTokens: 0,
        source: 'personal_cache',
      );

  /// 토큰 부족 결과
  factory FortuneAccessResult.insufficientTokens({
    required int required,
    required int available,
  }) =>
      FortuneAccessResult(
        canAccess: false,
        isPremium: false,
        hasCached: false,
        requiredTokens: required,
        willEarnTokens: 0,
        source: 'denied',
        denyReason: '토큰 부족: 필요 $required, 보유 $available',
      );
}

/// 운세 접근 통합 체크 서비스
///
/// 6단계 통합 플로우:
/// 1. 프리미엄 체크 (최우선)
/// 2. 개인 캐시 확인 (오늘 이미 조회?)
/// 3. Cohort Pool 조회 (90% API 절감)
/// 4. DB 풀 조회 (72% API 절감)
/// 5. 토큰 비용 확인 및 차감
/// 6. API 호출 & 결과 반환
class FortuneAccessService {
  final SupabaseClient _supabase;
  final FortuneOptimizationService _optimizationService;
  final CohortFortuneService _cohortService;
  // ignore: unused_field - Reserved for future TokenProvider/SubscriptionProvider access
  final Ref? _ref;

  // 상수
  static const int minCohortPoolSize = 25; // Cohort Pool 최소 크기

  FortuneAccessService({
    required SupabaseClient supabase,
    FortuneOptimizationService? optimizationService,
    CohortFortuneService? cohortService,
    Ref? ref,
  })  : _supabase = supabase,
        _optimizationService = optimizationService ??
            FortuneOptimizationService(supabase: supabase),
        _cohortService =
            cohortService ?? CohortFortuneService(supabase: supabase),
        _ref = ref;

  /// 운세 접근 가능 여부 확인 (통합)
  ///
  /// [userId] 사용자 ID
  /// [fortuneType] 운세 타입 (예: 'daily', 'love', 'tarot')
  /// [conditions] 운세 조건 객체
  /// [tokenBalance] 토큰 잔액 (Provider에서 주입)
  /// [hasUnlimitedTokens] 테스트 계정 무제한 토큰 여부
  Future<FortuneAccessResult> checkAccess({
    required String userId,
    required String fortuneType,
    required FortuneConditions conditions,
    required int tokenBalance,
    bool hasUnlimitedTokens = false,
  }) async {
    Logger.info('[FortuneAccess] 🎯 접근 체크 시작: $fortuneType (user: $userId)');

    // ===== STEP 1: 테스트 계정 체크 =====
    if (hasUnlimitedTokens) {
      Logger.info('[FortuneAccess] ✅ STEP 1: 테스트 계정 - 토큰 제한 우회');
      return FortuneAccessResult.premium();
    }

    // ===== STEP 2: 개인 캐시 확인 =====
    final conditionsHash = conditions.generateHash();
    final cached = await _checkPersonalCache(
      userId: userId,
      fortuneType: fortuneType,
      conditionsHash: conditionsHash,
    );

    if (cached != null) {
      Logger.info('[FortuneAccess] ✅ STEP 2: 개인 캐시 히트');
      return FortuneAccessResult.cached(
        cached: cached,
        isPremium: false,
      );
    }

    // ===== STEP 3: 토큰 비용 확인 =====
    final soulAmount = SoulRates.getSoulAmount(fortuneType);
    final isPremiumFortune = soulAmount < 0;
    final requiredTokens = isPremiumFortune ? -soulAmount : 0;
    final willEarnTokens = !isPremiumFortune ? soulAmount : 0;

    Logger.info(
        '[FortuneAccess] 📊 STEP 3: 토큰 비용 - ${isPremiumFortune ? "프리미엄 $requiredTokens 필요" : "무료 +$willEarnTokens 획득"}');

    // ===== STEP 4: 토큰 잔액 체크 (프리미엄 운세만) =====
    if (isPremiumFortune && tokenBalance < requiredTokens) {
      Logger.warning(
          '[FortuneAccess] ❌ STEP 4: 토큰 부족 (필요: $requiredTokens, 보유: $tokenBalance)');
      return FortuneAccessResult.insufficientTokens(
        required: requiredTokens,
        available: tokenBalance,
      );
    }

    // ===== 접근 허용 =====
    Logger.info('[FortuneAccess] ✅ 접근 허용 - API 호출 또는 Pool 사용 가능');

    return FortuneAccessResult(
      canAccess: true,
      isPremium: false,
      hasCached: false,
      requiredTokens: requiredTokens,
      willEarnTokens: willEarnTokens,
      source: 'pending', // 아직 소스 미정
    );
  }

  /// 운세 조회 실행 (6단계 통합 플로우)
  ///
  /// [userId] 사용자 ID
  /// [fortuneType] 운세 타입
  /// [conditions] 운세 조건 객체
  /// [inputConditions] API 호출용 입력 데이터
  /// [isPremium] 프리미엄 여부
  /// [onAPICall] API 호출 콜백
  Future<FortuneResult> execute({
    required String userId,
    required String fortuneType,
    required FortuneConditions conditions,
    required Map<String, dynamic> inputConditions,
    required bool isPremium,
    required Future<Map<String, dynamic>> Function(Map<String, dynamic>)
        onAPICall,
  }) async {
    final conditionsHash = conditions.generateHash();
    Logger.info(
        '[FortuneAccess] 🚀 운세 조회 실행: $fortuneType (hash: $conditionsHash)');

    // ===== STEP 1: 프리미엄 체크 =====
    // (이미 checkAccess에서 확인됨, isPremium 플래그로 전달)

    // ===== STEP 2: 개인 캐시 확인 =====
    final cached = await _checkPersonalCache(
      userId: userId,
      fortuneType: fortuneType,
      conditionsHash: conditionsHash,
    );

    if (cached != null) {
      Logger.info('[FortuneAccess] ✅ STEP 2: 개인 캐시 사용');
      return _convertCachedToFortuneResult(
        cached: cached,
        isPremium: isPremium,
        fortuneType: fortuneType,
      );
    }

    // ===== STEP 3: Cohort Pool 조회 (NEW - 90% 절감) =====
    final cohortResult = await _tryGetFromCohortPool(
      fortuneType: fortuneType,
      inputConditions: inputConditions,
      isPremium: isPremium,
    );

    if (cohortResult != null) {
      Logger.info('[FortuneAccess] ✅ STEP 3: Cohort Pool 히트');
      // 개인 캐시에 저장
      await _saveToPersonalCache(
        userId: userId,
        fortuneType: fortuneType,
        conditionsHash: conditionsHash,
        conditions: conditions,
        resultData: cohortResult.data,
        source: 'cohort_pool',
        apiCall: false,
      );
      return cohortResult;
    }

    // ===== STEP 4-6: 기존 최적화 서비스 사용 (DB Pool + API) =====
    Logger.info('[FortuneAccess] 🔄 STEP 4-6: 최적화 서비스 진입');

    final optimizedResult = await _optimizationService.getFortune(
      userId: userId,
      fortuneType: fortuneType,
      conditions: conditions,
      onAPICall: onAPICall,
    );

    // ===== STEP 7: API 호출 후 Cohort Pool에 저장 =====
    if (optimizedResult.apiCall) {
      Logger.info('[FortuneAccess] 💾 STEP 7: Cohort Pool에 저장');
      await _cohortService.saveToPool(
        fortuneType: fortuneType,
        input: inputConditions,
        result: optimizedResult.resultData,
      );
    }

    // ===== STEP 8-9: 결과 변환 및 반환 =====
    return _convertCachedToFortuneResult(
      cached: optimizedResult,
      isPremium: isPremium,
      fortuneType: fortuneType,
    );
  }

  /// 개인 캐시 확인 (STEP 2)
  Future<CachedFortuneResult?> _checkPersonalCache({
    required String userId,
    required String fortuneType,
    required String conditionsHash,
  }) async {
    try {
      final today = DateTime.now();
      final todayDate =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

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
        Logger.debug('[FortuneAccess] ✓ 개인 캐시 발견');
        return CachedFortuneResult.fromJson(result);
      }

      Logger.debug('[FortuneAccess] ✗ 개인 캐시 없음');
      return null;
    } catch (e) {
      Logger.warning('[FortuneAccess] ⚠️ 개인 캐시 조회 실패: $e');
      return null;
    }
  }

  /// Cohort Pool에서 결과 조회 시도 (STEP 3)
  Future<FortuneResult?> _tryGetFromCohortPool({
    required String fortuneType,
    required Map<String, dynamic> inputConditions,
    required bool isPremium,
  }) async {
    try {
      // Pool 크기 확인
      final poolSize = await _cohortService.getPoolSize(
        fortuneType: fortuneType,
        input: inputConditions,
      );

      if (poolSize < minCohortPoolSize) {
        Logger.debug(
            '[FortuneAccess] ✗ Cohort Pool 부족 ($poolSize < $minCohortPoolSize)');
        return null;
      }

      Logger.debug('[FortuneAccess] ✓ Cohort Pool 충분 ($poolSize개)');

      // Pool에서 결과 조회
      final result = await _cohortService.getFromCohortPool(
        fortuneType: fortuneType,
        input: inputConditions,
      );

      return result;
    } catch (e) {
      Logger.warning('[FortuneAccess] ⚠️ Cohort Pool 조회 실패: $e');
      return null;
    }
  }

  /// 개인 캐시에 저장
  Future<void> _saveToPersonalCache({
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
      final today =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      await _supabase.from('fortune_results').insert({
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
      });

      Logger.debug('[FortuneAccess] ✅ 개인 캐시 저장 완료');
    } catch (e) {
      // 중복 키 에러는 무시
      if (e is PostgrestException && e.code == '23505') {
        Logger.debug('[FortuneAccess] ✓ 이미 캐시됨 (중복 무시)');
        return;
      }
      Logger.warning('[FortuneAccess] ⚠️ 개인 캐시 저장 실패: $e');
    }
  }

  /// CachedFortuneResult → FortuneResult 변환
  FortuneResult _convertCachedToFortuneResult({
    required CachedFortuneResult cached,
    required bool isPremium,
    required String fortuneType,
  }) {
    final score =
        cached.resultData['score'] ?? cached.resultData['overallScore'];
    final title =
        cached.resultData['title'] as String? ?? _getDefaultTitle(fortuneType);

    final result = FortuneResult.fromJson({
      'id': cached.id,
      'type': cached.fortuneType,
      'data': cached.resultData,
      'score': score is num ? score.toInt() : null,
      'title': title,
      'summary': cached.resultData['summary'],
      'created_at': cached.createdAt.toIso8601String(),
    });

    return result;
  }

  /// 운세 타입별 기본 제목
  String _getDefaultTitle(String fortuneType) {
    const titles = {
      'avoid-people': '피해야 할 사람',
      'avoid_people': '피해야 할 사람',
      'daily': '오늘의 운세',
      'tarot': 'Insight Cards',
      'mbti': 'MBTI 분석',
      'love': '연애 분석',
      'career': '직장 분석',
      'health': '건강 체크',
      'exercise': '오늘의 운동',
      'investment': '투자 인사이트',
      'exam': '시험 가이드',
      'talent': '재능 발견',
      'dream': '꿈 분석',
      'face-reading': 'Face AI',
      'compatibility': '성향 매칭',
      'blind-date': '소개팅 가이드',
      'ex-lover': '재회 분석',
      'lucky-series': '럭키 시리즈',
      'fortune-celebrity': '연예인 분석',
      'fortune-pet': '반려동물 가이드',
      'baby-nickname': '태명 이야기',
    };
    return titles[fortuneType] ?? '분석 결과';
  }
}
