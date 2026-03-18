import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';
import '../../services/storage_service.dart';
import '../models/fortune_result.dart';
import '../models/cached_fortune_result.dart';
import '../../data/services/token_api_service.dart';
import 'fortune_optimization_service.dart';
import 'generator_factory.dart';
import '../../features/fortune/domain/models/fortune_conditions.dart';

/// 통합 운세 서비스 (최적화 시스템 통합)
///
/// 표준 프로세스 (API 비용 72% 절감):
/// 1. 최적화 시스템 (FortuneOptimizationService):
///    - 개인 캐시 확인 (20% 절감)
///    - DB 풀 랜덤 선택 (50% 절감)
///    - 30% 확률 랜덤 선택 (30% 절감)
/// 2. API 호출 (28%만 실행)
/// 3. DB 저장 (fortune_history + fortune_results)
/// 4. 결과 반환
class UnifiedFortuneService {
  final SupabaseClient _supabase;
  final TokenApiService? _tokenService;
  late final FortuneOptimizationService _optimizationService;
  late final GeneratorFactory _generatorFactory;
  final StorageService _storageService;

  // 최적화 시스템 활성화 플래그 (기본값: true)
  final bool enableOptimization;

  // 토큰 검증 활성화 플래그 (기본값: true)
  final bool enableTokenValidation;

  UnifiedFortuneService(
    this._supabase, {
    TokenApiService? tokenService,
    this.enableOptimization = true, // 최적화 기본 활성화
    this.enableTokenValidation = true, // 토큰 검증 기본 활성화
    FortuneOptimizationService? optimizationService,
    GeneratorFactory? generatorFactory,
    StorageService? storageService,
  })  : _tokenService = tokenService,
        _storageService = storageService ?? StorageService() {
    _optimizationService =
        optimizationService ?? FortuneOptimizationService(supabase: _supabase);
    _generatorFactory = generatorFactory ?? GeneratorFactory(_supabase);
  }

  /// 사용자 ID 조회 (로그인 사용자 또는 게스트 ID)
  ///
  /// 로그인된 경우: Supabase UUID 반환
  /// 비로그인 경우: guest_XXXXXXXX 형식의 게스트 ID 생성/반환
  Future<String> _getUserId() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      return user.id;
    }

    // 게스트 ID 사용
    return await _storageService.getOrCreateGuestId();
  }

  /// ==================== 메인 엔트리포인트 ====================

  /// 운세 조회 (통합 플로우 + 최적화)
  ///
  /// 최적화 프로세스 (enableOptimization = true):
  /// 1. FortuneOptimizationService 사용 (5단계 프로세스)
  ///    - 개인 캐시 확인 (20% 절감)
  ///    - Cohort Pool 조회 (90% 절감)
  ///    - DB 풀 랜덤 선택 (50% 절감)
  ///    - 30% 확률 랜덤 (30% 절감)
  ///    - API 호출 (28%만 실행)
  /// 2. fortune_results + fortune_history 양쪽 저장
  /// 3. 결과 반환
  ///
  /// 레거시 프로세스 (enableOptimization = false):
  /// 1. checkExistingFortune (기존 방식)
  /// 2. API 호출 (100%)
  /// 3. fortune_history 저장
  /// 4. 결과 반환
  Future<FortuneResult> getFortune({
    required String fortuneType,
    required FortuneDataSource dataSource,
    required Map<String, dynamic> inputConditions,
    FortuneConditions? conditions, // 최적화용 조건 객체 (선택)
    bool isPremium = false,
  }) async {
    try {
      final userId = await _getUserId();
      final today = DateTime.now().toIso8601String().split('T')[0];

      // 🎯 운세 요청 시작
      Logger.info('[$fortuneType] 🎯 운세 요청 시작 (최적화: $enableOptimization)');
      Logger.info('[$fortuneType] 📅 날짜: $today');
      Logger.info('[$fortuneType] 👤 사용자: $userId');
      Logger.info('[$fortuneType] 📋 입력 조건: ${jsonEncode(inputConditions)}');
      Logger.info('[$fortuneType] 📡 데이터 소스: $dataSource');

      // ===== 토큰 검증 (API 호출 전) =====
      final soulAmount = 0;
      Logger.info(
          '[$fortuneType] 💰 영혼 비용: $soulAmount (${soulAmount < 0 ? "프리미엄" : "무료"})');

      // 게스트 사용자는 토큰 검증 건너뜀 (guest_ 접두사로 시작)
      final isGuestUser = userId.startsWith('guest_');
      if (enableTokenValidation && _tokenService != null && !isGuestUser) {
        Logger.info(
            '[$fortuneType] ⏭️ 토큰 검증 비활성화: surviving chat flow is unlimited');
      }

      // ===== 최적화 시스템 사용 (조건 객체가 있고 활성화된 경우) =====
      if (isGuestUser && enableOptimization && conditions != null) {
        Logger.info('[$fortuneType] ⏭️ 게스트 사용자 - 최적화/DB 캐시 경로 건너뜀');
      }

      if (enableOptimization &&
          !isGuestUser &&
          conditions != null &&
          dataSource == FortuneDataSource.api) {
        Logger.info('[$fortuneType] 🚀 최적화 시스템 사용');

        try {
          final cachedResult = await _optimizationService.getFortune(
            userId: userId,
            fortuneType: fortuneType,
            conditions: conditions,
            onAPICall: (payload) async {
              // ✅ payload와 inputConditions 머지 (이미지 데이터 등 포함)
              Logger.info('[$fortuneType] 🔄 API 호출');

              // buildAPIPayload()에 없는 inputConditions 데이터를 병합
              final mergedPayload = {
                ...payload, // conditions.buildAPIPayload() 결과
                ...inputConditions, // 이미지 데이터 등 추가 조건
                'isPremium':
                    isPremium, // ✅ Premium 상태 전달 (Edge Function에서 블러 처리용)
              };

              final result = await _generatorFactory.generate(
                fortuneType: fortuneType,
                inputConditions: mergedPayload,
                dataSource: GeneratorDataSource.api,
              );

              // ✅ DB 저장용 conditions에서 대용량 필드 제거 (image는 API 호출에만 필요)
              final conditionsForDB =
                  Map<String, dynamic>.from(inputConditions);
              conditionsForDB.remove('image'); // 214KB base64 제거

              return result.data;
            },
          );

          Logger.info(
              '[$fortuneType] ✅ 최적화 시스템 완료 (소스: ${cachedResult.source})');

          // CachedFortuneResult → FortuneResult 변환
          final fortuneResult = _convertCachedToFortuneResult(cachedResult);

          // fortune_history에도 저장 (기존 시스템과 호환성)
          if (cachedResult.apiCall) {
            // API 호출한 경우만 fortune_history에 저장
            await saveFortune(
              result: fortuneResult,
              fortuneType: fortuneType,
              inputConditions: inputConditions,
            );
          }

          // ===== API 호출 성공 후 토큰 처리 =====
          await _processSoulTransaction(userId, fortuneType, soulAmount);

          // 최종 반환 (블러 상태 또는 블러 해제 상태)
          return fortuneResult;
        } catch (e, stackTrace) {
          // ⚠️ 레거시 폴백 제거: 에러 발생 시 즉시 throw
          // 이유: 폴백으로 인한 중복 API 호출 방지 (2배 비용 절감)
          Logger.error('[$fortuneType] ❌ 최적화 시스템 실패', e, stackTrace);
          rethrow;
        }
      }

      // ===== 최적화 비활성화 시: 기본 API 호출 =====
      Logger.info('[$fortuneType] 📦 최적화 비활성화 → 직접 API 호출');

      final result = await generateFortune(
        fortuneType: fortuneType,
        dataSource: dataSource,
        inputConditions: inputConditions,
      );

      Logger.info('[$fortuneType] ✅ 운세 생성 완료');
      Logger.info('[$fortuneType] 🆔 ID: ${result.id}');
      Logger.info('[$fortuneType] 📝 제목: ${result.title}');
      Logger.info(
          '[$fortuneType] 📊 데이터 크기: ${result.data.toString().length}자');
      Logger.info('[$fortuneType] ⭐ 점수: ${result.score}');

      // DB 저장 시도 (실패해도 결과는 반환)
      try {
        Logger.info('[$fortuneType] 💾 DB 저장 시도 (fortune_history)');
        await saveFortune(
          result: result,
          fortuneType: fortuneType,
          inputConditions: inputConditions,
        );
        Logger.info('[$fortuneType] ✅ fortune_history 저장 완료');
      } catch (saveError) {
        // DB 저장 실패해도 API 결과는 사용자에게 반환
        Logger.error(
            '[$fortuneType] ❌ fortune_history 저장 실패 (결과는 반환됨): $saveError');
      }

      // ===== API 호출 성공 후 토큰 처리 =====
      await _processSoulTransaction(userId, fortuneType, soulAmount);

      return result;
    } catch (error, stackTrace) {
      Logger.error('[$fortuneType] ❌ 운세 조회 실패', error, stackTrace);
      rethrow;
    }
  }

  /// CachedFortuneResult → FortuneResult 변환
  FortuneResult _convertCachedToFortuneResult(CachedFortuneResult cached) {
    final normalizedData = _normalizeCachedResultData(cached.resultData);

    // Edge Function 응답 구조에 따라 필드명이 다를 수 있음
    // - score 또는 overallScore
    // - title이 없을 수 있음
    final score = normalizedData['score'] ??
        normalizedData['overallScore'] ??
        normalizedData['overall_score'] ??
        cached.resultData['score'] ??
        cached.resultData['overallScore'];
    final title = normalizedData['title'] as String? ??
        cached.resultData['title'] as String? ??
        _getDefaultTitle(cached.fortuneType);
    final summary = normalizedData['summary'] ?? cached.resultData['summary'];

    return FortuneResult.fromJson({
      'id': cached.id,
      'type': cached.fortuneType,
      'data': normalizedData,
      'score': score is num ? score.toInt() : null,
      'title': title,
      'summary': summary,
      'created_at': cached.createdAt.toIso8601String(),
    });
  }

  Map<String, dynamic> _normalizeCachedResultData(Map<String, dynamic> source) {
    if (_hasRichFortuneFields(source)) {
      return source;
    }

    final candidates = <Map<String, dynamic>>[
      if (source['fortune'] is Map)
        Map<String, dynamic>.from(source['fortune'] as Map),
      if (source['data'] is Map)
        Map<String, dynamic>.from(source['data'] as Map),
      if (source['fortune_data'] is Map)
        Map<String, dynamic>.from(source['fortune_data'] as Map),
      if (source['result'] is Map)
        Map<String, dynamic>.from(source['result'] as Map),
    ];

    for (final candidate in candidates) {
      if (_hasRichFortuneFields(candidate)) {
        return candidate;
      }
    }

    return source;
  }

  bool _hasRichFortuneFields(Map<String, dynamic> payload) {
    const richKeys = <String>[
      'content',
      'overallReading',
      'overall_reading',
      'mainMessage',
      'main_message',
      'greeting',
      'description',
      'categories',
      'timeSlots',
      'time_slots',
      'goalFortune',
      'monthlyHighlights',
      'actionPlan',
      'luckyItems',
      'lucky_items',
    ];

    for (final key in richKeys) {
      final value = payload[key];
      if (value is String && value.trim().isNotEmpty) {
        return true;
      }
      if (value is List && value.isNotEmpty) {
        return true;
      }
      if (value is Map && value.isNotEmpty) {
        return true;
      }
    }

    return false;
  }

  /// 운세 타입별 기본 제목
  String _getDefaultTitle(String fortuneType) {
    const titles = {
      'avoid-people': '피해야 할 사람',
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
      'pet-compatibility': '반려동물 가이드',
      // baby-nickname은 naming으로 통합됨
    };
    return titles[fortuneType] ?? '분석 결과';
  }

  /// ==================== Step 1: 중복 체크 ====================

  /// 기존 운세 결과 확인 (중복 방지)
  ///
  /// 조건:
  /// - 오늘 날짜
  /// - 현재 유저
  /// - 같은 운세 타입
  /// - 같은 입력 조건 (JSONB 비교)
  Future<FortuneResult?> checkExistingFortune({
    required String fortuneType,
    required Map<String, dynamic> inputConditions,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        Logger.warning('[UnifiedFortune] 사용자 미인증');
        return null;
      }

      final today =
          DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD

      // JSONB 조건을 정규화 (키 정렬) - DB에서는 text로 캐스팅해서 비교
      final normalizedConditions = _normalizeJsonb(inputConditions);

      Logger.debug(
          '[UnifiedFortune] 중복 체크 - userId: $userId, type: $fortuneType, date: $today');
      Logger.debug(
          '[UnifiedFortune] Normalized conditions: ${jsonEncode(normalizedConditions)}');

      // 잠깐! input_conditions 비교를 빼고 일단 모든 레코드를 가져온 후 메모리에서 비교
      // 이유: DB에 잘못된 JSONB 데이터가 있으면 쿼리 자체가 실패함
      final results = await _supabase
          .from('fortune_history')
          .select('*, id')
          .eq('user_id', userId)
          .eq('fortune_type', fortuneType)
          .eq('fortune_date', today);

      if ((results.isEmpty)) {
        Logger.debug('[UnifiedFortune] 기존 결과 없음');
        return null;
      }

      // 결과가 여러 개일 수 있으므로 input_conditions를 메모리에서 비교
      final targetJson = jsonEncode(normalizedConditions);

      for (final record in results) {
        try {
          final recordConditions = record['input_conditions'];
          final recordJson = jsonEncode(_normalizeJsonb(recordConditions));

          if (recordJson == targetJson) {
            Logger.debug('[UnifiedFortune] 기존 결과 발견: ${record['id']}');
            return FortuneResult.fromJson(record);
          }
        } catch (e) {
          Logger.debug('[UnifiedFortune] 레코드 비교 실패 (건너뜀): $e');
          continue;
        }
      }

      Logger.debug('[UnifiedFortune] 조건 일치하는 기존 결과 없음');
      return null;
    } catch (error, stack) {
      Logger.error('[UnifiedFortune] 기존 결과 확인 실패 (무시하고 계속)', error, stack);
      return null; // 실패 시 null 반환하여 새로 생성하도록
    }
  }

  /// ==================== Step 2: 운세 생성 ====================

  /// 운세 생성 (API 또는 로컬)
  ///
  /// GeneratorFactory를 통해 운세 생성 로직을 위임
  /// (40+ switch-case → GeneratorFactory로 분리)
  Future<FortuneResult> generateFortune({
    required String fortuneType,
    required FortuneDataSource dataSource,
    required Map<String, dynamic> inputConditions,
  }) async {
    final generatorDataSource = dataSource == FortuneDataSource.api
        ? GeneratorDataSource.api
        : GeneratorDataSource.local;

    return await _generatorFactory.generate(
      fortuneType: fortuneType,
      inputConditions: inputConditions,
      dataSource: generatorDataSource,
    );
  }

  /// ==================== Step 3: DB 저장 ====================

  /// 운세 결과 저장 (fortune_history 테이블)
  ///
  /// 게스트 사용자(비로그인)는 DB 저장을 건너뜁니다.
  Future<void> saveFortune({
    required FortuneResult result,
    required String fortuneType,
    required Map<String, dynamic> inputConditions,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        // 게스트 사용자는 DB 저장 건너뜀 (로컬에만 결과 표시)
        Logger.info('[UnifiedFortune] ⏭️ 게스트 사용자 - DB 저장 건너뜀');
        return;
      }

      final now = DateTime.now();
      final today = now.toIso8601String().split('T')[0]; // YYYY-MM-DD

      // ✅ DB 저장용 조건 생성 (대용량 필드 제거)
      Map<String, dynamic> conditionsForDB;

      // simplified_for_db가 있으면 그것만 저장 (전통사주 등 대용량 데이터)
      if (inputConditions.containsKey('simplified_for_db')) {
        conditionsForDB = {
          'question': inputConditions['question'],
          ...inputConditions['simplified_for_db'] as Map<String, dynamic>,
        };
        Logger.debug('[UnifiedFortune] Using simplified_for_db for storage');
      } else {
        conditionsForDB = Map<String, dynamic>.from(inputConditions);
        conditionsForDB.remove('image'); // 214KB base64 제거 - DB 인덱스 크기 제한 (8KB)
      }

      // JSONB 조건을 정규화 (키 정렬)
      final normalizedConditions = _normalizeJsonb(conditionsForDB);

      Logger.debug(
          '[UnifiedFortune] Saving conditions (${normalizedConditions.length} fields, image excluded)');

      final data = {
        'user_id': userId,
        'fortune_type': fortuneType,
        'fortune_date': today,
        'input_conditions': normalizedConditions,
        'fortune_data': result.toJson(),
        'score': result.score,
        'title': result.title,
        'summary': result.summary,
        'created_at': now.toIso8601String(),
        'last_viewed_at': now.toIso8601String(),
        'view_count': 1,
      };

      await _supabase.from('fortune_history').insert(data);

      Logger.info('[UnifiedFortune] ✅ DB 저장 완료: $fortuneType (User: $userId)');
    } catch (error, stackTrace) {
      // 중복 키 에러는 정상 (FortuneOptimizationService가 이미 저장함)
      if (error is PostgrestException && error.code == '23505') {
        Logger.info('[UnifiedFortune] ✅ 이미 저장된 운세 (최적화 서비스에서 저장됨)');
        return; // 중복 키 에러는 무시
      }

      Logger.error(
          '[UnifiedFortune] DB 저장 실패: $fortuneType', error, stackTrace);
      // 저장 실패해도 결과는 반환할 수 있도록 throw하지 않음
      // 대신 경고 로그만 남김
      Logger.warning('[UnifiedFortune] ⚠️ DB 저장 실패했지만 운세 결과는 반환됩니다');
    }
  }

  /// ==================== 유틸리티 메서드 ====================

  /// 토큰(영혼) 트랜잭션 처리
  ///
  /// API 호출 성공 후 토큰 차감(프리미엄) 또는 획득(무료)
  Future<void> _processSoulTransaction(
    String userId,
    String fortuneType,
    int soulAmount,
  ) async {
    Logger.info('[$fortuneType] ⏭️ 토큰 처리 비활성화: 서버 통합 경로 사용');
  }

  /// JSONB 정규화 (키 정렬)
  ///
  /// 동일한 내용이지만 키 순서가 다른 JSON을 같은 것으로 인식하기 위함
  /// 예: {"a": 1, "b": 2} === {"b": 2, "a": 1}
  Map<String, dynamic> _normalizeJsonb(Map<String, dynamic> json) {
    final sortedKeys = json.keys.toList()..sort();
    final normalized = <String, dynamic>{};

    for (final key in sortedKeys) {
      final value = json[key];
      if (value is Map<String, dynamic>) {
        normalized[key] = _normalizeJsonb(value);
      } else if (value is List) {
        normalized[key] = value;
      } else {
        normalized[key] = value;
      }
    }

    return normalized;
  }
}

/// ==================== 데이터 모델 ====================

/// 운세 데이터 소스
enum FortuneDataSource {
  /// API 방식 (Edge Function 호출)
  api,

  /// 로컬 방식 (계산 또는 로컬 데이터)
  local,
}
