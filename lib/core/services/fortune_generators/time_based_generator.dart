import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/fortune_result.dart';
import '../../utils/logger.dart';
import '../location_manager.dart';

/// 일일운세 Generator - API 기반 운세 생성
/// 오늘/내일/주간/월간/연간 운세
class TimeBasedGenerator {
  /// 일일운세 생성 (Edge Function 호출)
  static Future<FortuneResult> generate(
      Map<String, dynamic> inputConditions, SupabaseClient supabase,
      {String fortuneType = 'daily'}) async {
    final userId = supabase.auth.currentUser?.id ?? 'unknown';
    final endpoint = _endpointFor(fortuneType);
    final period = inputConditions['period'] ?? _defaultPeriodFor(fortuneType);

    // 📤 API 요청 준비
    Logger.info('[TimeBasedGenerator] 📤 API 요청 준비');
    Logger.info('[TimeBasedGenerator]   🌐 Edge Function: $endpoint');
    Logger.info('[TimeBasedGenerator]   👤 user_id: $userId');
    Logger.info('[TimeBasedGenerator]   📅 date: ${inputConditions['date']}');
    Logger.info('[TimeBasedGenerator]   ⏰ period: $period');
    Logger.info(
        '[TimeBasedGenerator]   🎉 is_holiday: ${inputConditions['is_holiday'] ?? false}');
    Logger.info(
        '[TimeBasedGenerator]   🏷️ holiday_name: ${inputConditions['holiday_name']}');

    try {
      // ✅ LocationManager에서 현재 위치 가져오기
      final location = await LocationManager.instance.getCurrentLocation();
      final userLocation = location.cityName; // 예: "강남구", "도쿄"

      Logger.info('[TimeBasedGenerator] 📍 사용자 위치: $userLocation');

      final requestBody = {
        ...inputConditions,
        'date': inputConditions['date'],
        'period': period,
        'is_holiday': inputConditions['is_holiday'] ?? false,
        'holiday_name': inputConditions['holiday_name'],
        'special_name': inputConditions['special_name'],

        // ✅ LocationManager에서 가져온 실제 사용자 위치 추가
        'userLocation': userLocation,

        // ✨ 이벤트 기반 운세 정보 추가 (Phase 3)
        'has_event_details': inputConditions['category'] != null,
        'event_category': inputConditions['category'],
        'event_category_type': inputConditions['categoryType'],
        'user_question': inputConditions['question'],
        'user_emotion': inputConditions['emotion'],
        'user_emotion_type': inputConditions['emotionType'],
      };

      Logger.info('[TimeBasedGenerator] 📡 API 호출 중...');
      if (inputConditions['category'] != null) {
        Logger.info(
            '[TimeBasedGenerator]   🎯 이벤트 카테고리: ${inputConditions['category']}');
        Logger.info(
            '[TimeBasedGenerator]   💭 사용자 질문: ${inputConditions['question'] ?? '없음'}');
        Logger.info(
            '[TimeBasedGenerator]   😊 감정 상태: ${inputConditions['emotion'] ?? '없음'}');
      }

      // Edge Function 호출
      final response = await supabase.functions.invoke(
        endpoint,
        body: jsonEncode(requestBody),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      // 📥 응답 수신
      Logger.info('[TimeBasedGenerator] 📥 API 응답 수신');
      Logger.info('[TimeBasedGenerator]   ✅ Status: ${response.status}');

      if (response.status != 200) {
        Logger.error(
            '[TimeBasedGenerator] ❌ API 호출 실패: status ${response.status}');
        throw Exception('Edge Function 호출 실패: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;
      Logger.info(
          '[TimeBasedGenerator]   📦 Response data keys: ${data.keys.toList()}');

      // 🔄 파싱
      Logger.info('[TimeBasedGenerator] 🔄 응답 데이터 파싱 중...');
      final result = convertApiResponseForTesting(
        data,
        inputConditions,
        fortuneType: fortuneType,
      );

      Logger.info('[TimeBasedGenerator] ✅ 파싱 완료');
      Logger.info('[TimeBasedGenerator]   📝 Title: ${result.title}');
      Logger.info('[TimeBasedGenerator]   ⭐ Score: ${result.score}');

      return result;
    } catch (e, stackTrace) {
      Logger.error('[TimeBasedGenerator] ❌ 일일운세 생성 실패', e, stackTrace);
      rethrow;
    }
  }

  @visibleForTesting
  static FortuneResult convertApiResponseForTesting(
    Map<String, dynamic> apiData,
    Map<String, dynamic> inputConditions, {
    String fortuneType = 'daily',
  }) {
    return _convertToFortuneResult(
      apiData,
      inputConditions,
      fortuneType: fortuneType,
    );
  }

  /// API 응답을 FortuneResult로 변환
  static FortuneResult _convertToFortuneResult(
    Map<String, dynamic> apiData,
    Map<String, dynamic> inputConditions, {
    required String fortuneType,
  }) {
    final canonicalType = _canonicalFortuneType(fortuneType);
    final fortune =
        _asMap(apiData['fortune']) ?? _asMap(apiData['data']) ?? apiData;
    final summaryText = _asString(fortune['summary']) ??
        _asString(fortune['content']) ??
        _asString(fortune['description']) ??
        _asString(fortune['greeting']);

    return FortuneResult(
      type: canonicalType,
      title: _asString(fortune['title']) ?? _defaultTitleFor(canonicalType),
      summary: summaryText == null ? {} : {'message': summaryText},
      data: fortune,
      score: _asInt(fortune['score']) ??
          _asInt(fortune['overallScore']) ??
          _asInt(fortune['overall_score']) ??
          _asInt(apiData['score']) ??
          _asInt(apiData['overallScore']) ??
          50,
      createdAt: DateTime.now(),
    );
  }

  static String _endpointFor(String fortuneType) {
    switch (_canonicalFortuneType(fortuneType)) {
      case 'daily-calendar':
      case 'time-based':
        return 'fortune-time';
      case 'daily':
      default:
        return 'fortune-daily';
    }
  }

  static String _defaultPeriodFor(String fortuneType) {
    switch (_canonicalFortuneType(fortuneType)) {
      case 'daily-calendar':
      case 'time-based':
        return 'today';
      case 'daily':
      default:
        return 'daily';
    }
  }

  static String _canonicalFortuneType(String fortuneType) {
    switch (fortuneType) {
      case 'daily_calendar':
        return 'daily-calendar';
      case 'time_based':
        return 'time-based';
      default:
        return fortuneType;
    }
  }

  static String _defaultTitleFor(String fortuneType) {
    switch (fortuneType) {
      case 'daily-calendar':
        return '오늘 일정 흐름';
      case 'time-based':
        return '시간 인사이트';
      case 'daily':
      default:
        return '오늘의 운세';
    }
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (key, mapValue) => MapEntry(key.toString(), mapValue),
      );
    }
    return null;
  }

  static String? _asString(dynamic value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.toString().trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static int? _asInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    return null;
  }
}
