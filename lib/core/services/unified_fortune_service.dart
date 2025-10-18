import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';
import '../models/fortune_result.dart';
import '../models/cached_fortune_result.dart';
import 'fortune_generators/tarot_generator.dart';
import 'fortune_generators/moving_generator.dart';
import 'fortune_generators/time_based_generator.dart';
import 'fortune_generators/compatibility_generator.dart';
import 'fortune_generators/avoid_people_generator.dart';
import 'fortune_generators/ex_lover_generator.dart';
import 'fortune_generators/blind_date_generator.dart';
import 'fortune_generators/career_generator.dart';
import 'fortune_generators/exam_generator.dart';
import 'fortune_generators/health_generator.dart';
import 'fortune_generators/fortune_cookie_generator.dart';
import 'fortune_optimization_service.dart';
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
  late final FortuneOptimizationService _optimizationService;

  // 최적화 시스템 활성화 플래그 (기본값: true)
  final bool enableOptimization;

  UnifiedFortuneService(
    this._supabase, {
    this.enableOptimization = true, // 최적화 기본 활성화
  }) {
    _optimizationService = FortuneOptimizationService(supabase: _supabase);
  }

  /// ==================== 메인 엔트리포인트 ====================

  /// 운세 조회 (통합 플로우 + 최적화)
  ///
  /// 최적화 프로세스 (enableOptimization = true):
  /// 1. FortuneOptimizationService 사용 (6단계 프로세스)
  ///    - 개인 캐시 확인 (20% 절감)
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
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id ?? 'unknown';
      final today = DateTime.now().toIso8601String().split('T')[0];

      // 🎯 운세 요청 시작
      Logger.info('[$fortuneType] 🎯 운세 요청 시작 (최적화: $enableOptimization)');
      Logger.info('[$fortuneType] 📅 날짜: $today');
      Logger.info('[$fortuneType] 👤 사용자: $userId');
      Logger.info('[$fortuneType] 📋 입력 조건: ${jsonEncode(inputConditions)}');
      Logger.info('[$fortuneType] 📡 데이터 소스: $dataSource');

      // ===== 최적화 시스템 사용 (조건 객체가 있고 활성화된 경우) =====
      if (enableOptimization && conditions != null && dataSource == FortuneDataSource.api) {
        Logger.info('[$fortuneType] 🚀 최적화 시스템 사용');

        try {
          final cachedResult = await _optimizationService.getFortune(
            userId: userId,
            fortuneType: fortuneType,
            conditions: conditions,
            onShowAd: () async {
              // TODO: 광고 표시 로직 (나중에 구현)
              Logger.info('[$fortuneType] 📺 광고 표시 (TODO)');
            },
            onAPICall: (payload) async {
              // API 호출
              Logger.info('[$fortuneType] 🔄 API 호출');
              final result = await _generateFromAPI(fortuneType, inputConditions);
              return result.data;
            },
          );

          Logger.info('[$fortuneType] ✅ 최적화 시스템 완료 (소스: ${cachedResult.source})');

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

          return fortuneResult;
        } catch (e) {
          Logger.warning('[$fortuneType] ⚠️ 최적화 시스템 실패, 레거시 방식으로 폴백: $e');
          // 폴백: 레거시 방식으로 진행
        }
      }

      // ===== 레거시 방식 (기존 로직) =====
      Logger.info('[$fortuneType] 📦 레거시 방식 사용');

      // Step 1: 기존 결과 확인 (중복 방지)
      Logger.info('[$fortuneType] 🔍 DB 기존 결과 확인 중...');
      final existing = await checkExistingFortune(
        fortuneType: fortuneType,
        inputConditions: inputConditions,
      );

      if (existing != null) {
        Logger.info('[$fortuneType] ✅ 기존 결과 발견 → 재사용');
        Logger.info('[$fortuneType] 🆔 ID: ${existing.id}');
        Logger.info('[$fortuneType] 📝 제목: ${existing.title}');
        Logger.info('[$fortuneType] ⭐ 점수: ${existing.score}');
        return existing;
      }

      // Step 2: 새로 생성
      Logger.info('[$fortuneType] ❌ DB에 없음 → 새로 생성');
      Logger.info('[$fortuneType] 📡 Generator 호출 시작');
      final result = await generateFortune(
        fortuneType: fortuneType,
        dataSource: dataSource,
        inputConditions: inputConditions,
      );

      Logger.info('[$fortuneType] ✅ 운세 생성 완료');
      Logger.info('[$fortuneType] 🆔 ID: ${result.id}');
      Logger.info('[$fortuneType] 📝 제목: ${result.title}');
      Logger.info('[$fortuneType] 📊 데이터 크기: ${result.data.toString().length}자');
      Logger.info('[$fortuneType] ⭐ 점수: ${result.score}');

      // Step 3: DB 저장
      Logger.info('[$fortuneType] 💾 DB 저장 시작');
      await saveFortune(
        result: result,
        fortuneType: fortuneType,
        inputConditions: inputConditions,
      );
      Logger.info('[$fortuneType] ✅ DB 저장 완료');

      return result;

    } catch (error, stackTrace) {
      Logger.error('[$fortuneType] ❌ 운세 조회 실패', error, stackTrace);
      rethrow;
    }
  }

  /// CachedFortuneResult → FortuneResult 변환
  FortuneResult _convertCachedToFortuneResult(CachedFortuneResult cached) {
    return FortuneResult.fromJson({
      'id': cached.id,
      'type': cached.fortuneType,
      'data': cached.resultData,
      'score': cached.resultData['score'],
      'title': cached.resultData['title'],
      'summary': cached.resultData['summary'],
      'created_at': cached.createdAt.toIso8601String(),
    });
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

      final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD

      // JSONB 조건을 정규화 (키 정렬) - DB에서는 text로 캐스팅해서 비교
      final normalizedConditions = _normalizeJsonb(inputConditions);

      Logger.debug('[UnifiedFortune] 중복 체크 - userId: $userId, type: $fortuneType, date: $today');
      Logger.debug('[UnifiedFortune] Normalized conditions: ${jsonEncode(normalizedConditions)}');

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

    } catch (error) {
      Logger.warning('[UnifiedFortune] 기존 결과 확인 실패 (무시하고 계속): $error', error);
      return null; // 실패 시 null 반환하여 새로 생성하도록
    }
  }

  /// ==================== Step 2: 운세 생성 ====================

  /// 운세 생성 (API 또는 로컬)
  Future<FortuneResult> generateFortune({
    required String fortuneType,
    required FortuneDataSource dataSource,
    required Map<String, dynamic> inputConditions,
  }) async {
    switch (dataSource) {
      case FortuneDataSource.api:
        return await _generateFromAPI(fortuneType, inputConditions);
      case FortuneDataSource.local:
        return await _generateFromLocal(fortuneType, inputConditions);
    }
  }

  /// API에서 운세 생성 (Edge Function 호출)
  Future<FortuneResult> _generateFromAPI(
    String fortuneType,
    Map<String, dynamic> inputConditions,
  ) async {
    try {
      Logger.info('[UnifiedFortune] API 호출 시작: $fortuneType');

      // 운세 타입별 Generator 클래스 호출
      switch (fortuneType.toLowerCase()) {
        case 'moving':
          return await MovingGenerator.generate(inputConditions, _supabase);

        case 'time_based':
        case 'daily':
        case 'daily_calendar':
          return await TimeBasedGenerator.generate(inputConditions, _supabase);

        case 'compatibility':
          return await CompatibilityGenerator.generate(inputConditions, _supabase);

        case 'avoid_people':
        case 'avoid-people':
          return await AvoidPeopleGenerator.generate(inputConditions, _supabase);

        case 'ex_lover':
        case 'ex-lover':
          return await ExLoverGenerator.generate(inputConditions, _supabase);

        case 'blind_date':
        case 'blind-date':
          return await BlindDateGenerator.generate(inputConditions, _supabase);

        case 'career':
        case 'career_future':
        case 'career-future':
        case 'career_seeker':
        case 'career-seeker':
        case 'career_change':
        case 'career-change':
        case 'startup_career':
        case 'startup-career':
          return await CareerGenerator.generate(inputConditions, _supabase);

        case 'exam':
        case 'lucky_exam':
        case 'lucky-exam':
          return await ExamGenerator.generate(inputConditions, _supabase);

        case 'health':
          return await HealthGenerator.generate(inputConditions, _supabase);

        case 'mbti':
          // MBTI Edge Function 직접 호출 (FortuneApiService 패턴 사용)
          final response = await _supabase.functions.invoke(
            'fortune-mbti',
            body: inputConditions,
          );

          if (response.data == null) {
            throw Exception('MBTI API 응답 데이터 없음');
          }

          // fortune-mbti returns {success: true, data: {...}}
          final responseData = response.data as Map<String, dynamic>;
          if (responseData['success'] == true && responseData.containsKey('data')) {
            final fortuneData = responseData['data'] as Map<String, dynamic>;
            Logger.info('[UnifiedFortune] ✅ MBTI API 호출 성공');
            return FortuneResult.fromJson(fortuneData);
          } else {
            throw Exception('MBTI API 응답 형식 오류');
          }

        default:
          // 기본 Edge Function 호출 (레거시)
          final response = await _supabase.functions.invoke(
            'generate-fortune',
            body: {
              'fortune_type': fortuneType,
              'input_conditions': inputConditions,
            },
          );

          if (response.data == null) {
            throw Exception('API 응답 데이터 없음');
          }

          Logger.info('[UnifiedFortune] ✅ API 호출 성공: $fortuneType');
          return FortuneResult.fromJson(response.data);
      }
    } catch (error, stackTrace) {
      Logger.error('[UnifiedFortune] API 호출 실패: $fortuneType', error, stackTrace);
      throw Exception('API 호출 실패: $error');
    }
  }

  /// 로컬에서 운세 생성 (계산 또는 로컬 데이터)
  Future<FortuneResult> _generateFromLocal(
    String fortuneType,
    Map<String, dynamic> inputConditions,
  ) async {
    try {
      Logger.info('[UnifiedFortune] 로컬 생성 시작: $fortuneType');

      // 운세 타입별 Generator 클래스 호출
      switch (fortuneType.toLowerCase()) {
        case 'tarot':
          return await TarotGenerator.generate(inputConditions);

        case 'fortune_cookie':
        case 'fortune-cookie':
          return await FortuneCookieGenerator.generate(inputConditions);

        // TODO: 다른 로컬 운세 Generator 추가
        // case 'mbti':
        //   return await MBTIGenerator.generate(inputConditions);
        // case 'biorhythm':
        //   return await BiorhythmGenerator.generate(inputConditions);

        default:
          throw UnimplementedError(
            '로컬 생성 로직 미구현: $fortuneType\n'
            '해당 운세의 Generator 클래스를 구현해야 합니다.'
          );
      }

    } catch (error, stackTrace) {
      Logger.error('[UnifiedFortune] 로컬 생성 실패: $fortuneType', error, stackTrace);
      rethrow;
    }
  }

  /// ==================== Step 3: DB 저장 ====================

  /// 운세 결과 저장 (fortune_history 테이블)
  Future<void> saveFortune({
    required FortuneResult result,
    required String fortuneType,
    required Map<String, dynamic> inputConditions,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('사용자 미인증');
      }

      final now = DateTime.now();
      final today = now.toIso8601String().split('T')[0]; // YYYY-MM-DD

      // JSONB 조건을 정규화 (키 정렬)
      final normalizedConditions = _normalizeJsonb(inputConditions);

      Logger.debug('[UnifiedFortune] Saving conditions: ${jsonEncode(normalizedConditions)}');

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
      Logger.error('[UnifiedFortune] DB 저장 실패: $fortuneType', error, stackTrace);
      // 저장 실패해도 결과는 반환할 수 있도록 throw하지 않음
      // 대신 경고 로그만 남김
      Logger.warning('[UnifiedFortune] ⚠️ DB 저장 실패했지만 운세 결과는 반환됩니다');
    }
  }

  /// ==================== 유틸리티 메서드 ====================

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
