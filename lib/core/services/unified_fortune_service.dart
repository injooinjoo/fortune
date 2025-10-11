import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';
import '../models/fortune_result.dart';
import 'fortune_generators/tarot_generator.dart';
import 'fortune_generators/moving_generator.dart';
import 'fortune_generators/time_based_generator.dart';

/// 통합 운세 서비스
///
/// 모든 운세를 표준화된 프로세스로 관리:
/// 1. 중복 체크: 오늘 + 유저 + 운세타입 + 조건 일치 시 기존 결과 반환
/// 2. 운세 생성: API 또는 로컬 데이터 소스에서 생성
/// 3. DB 저장: fortune_history 테이블에 영구 저장
/// 4. 결과 반환: FortuneResult 객체로 반환
class UnifiedFortuneService {
  final SupabaseClient _supabase;

  UnifiedFortuneService(this._supabase);

  /// ==================== 메인 엔트리포인트 ====================

  /// 운세 조회 (통합 플로우)
  ///
  /// 표준 프로세스:
  /// 1. 기존 결과 확인 (중복 방지)
  /// 2. 없으면 새로 생성 (API 또는 로컬)
  /// 3. DB에 저장
  /// 4. 결과 반환
  Future<FortuneResult> getFortune({
    required String fortuneType,
    required FortuneDataSource dataSource,
    required Map<String, dynamic> inputConditions,
  }) async {
    try {
      // Step 1: 기존 결과 확인 (중복 방지)
      Logger.info('[UnifiedFortune] 기존 결과 확인: $fortuneType');
      final existing = await checkExistingFortune(
        fortuneType: fortuneType,
        inputConditions: inputConditions,
      );

      if (existing != null) {
        Logger.info('[UnifiedFortune] ✅ 기존 결과 반환: $fortuneType (ID: ${existing.id})');
        return existing;
      }

      // Step 2: 새로 생성
      Logger.info('[UnifiedFortune] 새 운세 생성 시작: $fortuneType (Source: $dataSource)');
      final result = await generateFortune(
        fortuneType: fortuneType,
        dataSource: dataSource,
        inputConditions: inputConditions,
      );

      // Step 3: DB 저장
      Logger.info('[UnifiedFortune] DB 저장 시작: $fortuneType');
      await saveFortune(
        result: result,
        fortuneType: fortuneType,
        inputConditions: inputConditions,
      );

      Logger.info('[UnifiedFortune] ✅ 새 결과 생성 및 저장 완료: $fortuneType (Score: ${result.score})');
      return result;

    } catch (error, stackTrace) {
      Logger.error('[UnifiedFortune] 운세 조회 실패: $fortuneType', error, stackTrace);
      rethrow;
    }
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

      // JSONB 조건을 정규화 (키 정렬)
      final normalizedConditions = _normalizeJsonb(inputConditions);

      Logger.debug('[UnifiedFortune] 중복 체크 - userId: $userId, type: $fortuneType, date: $today');

      final response = await _supabase
        .from('fortune_history')
        .select('*, id')
        .eq('user_id', userId)
        .eq('fortune_type', fortuneType)
        .eq('fortune_date', today)
        .eq('input_conditions', normalizedConditions)
        .maybeSingle();

      if (response == null) {
        Logger.debug('[UnifiedFortune] 기존 결과 없음');
        return null;
      }

      Logger.debug('[UnifiedFortune] 기존 결과 발견: ${response['id']}');
      return FortuneResult.fromJson(response);

    } catch (error, stackTrace) {
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

        // TODO: 다른 API 운세 Generator 추가
        // case 'compatibility':
        //   return await CompatibilityGenerator.generate(inputConditions, _supabase);
        // case 'career':
        //   return await CareerGenerator.generate(inputConditions, _supabase);

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

        // TODO: 다른 운세 Generator 추가
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

      // JSONB 조건을 정규화
      final normalizedConditions = _normalizeJsonb(inputConditions);

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

  /// JSONB를 안전하게 문자열로 변환
  String _jsonbToString(Map<String, dynamic> json) {
    try {
      return jsonEncode(_normalizeJsonb(json));
    } catch (e) {
      Logger.warning('[UnifiedFortune] JSONB 변환 실패: $e');
      return '{}';
    }
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
