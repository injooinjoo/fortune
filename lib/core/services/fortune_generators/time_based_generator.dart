import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/fortune_result.dart';
import '../../utils/logger.dart';

/// 일일운세 Generator - API 기반 운세 생성
/// 오늘/내일/주간/월간/연간 운세
class TimeBasedGenerator {
  /// 일일운세 생성 (Edge Function 호출)
  static Future<FortuneResult> generate(
    Map<String, dynamic> inputConditions,
    SupabaseClient supabase,
  ) async {
    final userId = supabase.auth.currentUser?.id ?? 'unknown';

    // 📤 API 요청 준비
    Logger.info('[TimeBasedGenerator] 📤 API 요청 준비');
    Logger.info('[TimeBasedGenerator]   🌐 Edge Function: fortune-daily');
    Logger.info('[TimeBasedGenerator]   👤 user_id: $userId');
    Logger.info('[TimeBasedGenerator]   📅 date: ${inputConditions['date']}');
    Logger.info('[TimeBasedGenerator]   ⏰ period: ${inputConditions['period'] ?? 'daily'}');
    Logger.info('[TimeBasedGenerator]   🎉 is_holiday: ${inputConditions['is_holiday'] ?? false}');
    Logger.info('[TimeBasedGenerator]   🏷️ holiday_name: ${inputConditions['holiday_name']}');

    try {
      final requestBody = {
        'date': inputConditions['date'],
        'period': inputConditions['period'] ?? 'daily',
        'is_holiday': inputConditions['is_holiday'] ?? false,
        'holiday_name': inputConditions['holiday_name'],
        'special_name': inputConditions['special_name'],

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
        Logger.info('[TimeBasedGenerator]   🎯 이벤트 카테고리: ${inputConditions['category']}');
        Logger.info('[TimeBasedGenerator]   💭 사용자 질문: ${inputConditions['question'] ?? '없음'}');
        Logger.info('[TimeBasedGenerator]   😊 감정 상태: ${inputConditions['emotion'] ?? '없음'}');
      }

      // Edge Function 호출
      final response = await supabase.functions.invoke(
        'fortune-daily',
        body: requestBody,
      );

      // 📥 응답 수신
      Logger.info('[TimeBasedGenerator] 📥 API 응답 수신');
      Logger.info('[TimeBasedGenerator]   ✅ Status: ${response.status}');

      if (response.status != 200) {
        Logger.error('[TimeBasedGenerator] ❌ API 호출 실패: status ${response.status}');
        throw Exception('Edge Function 호출 실패: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;
      Logger.info('[TimeBasedGenerator]   📦 Response data keys: ${data.keys.toList()}');

      // 🔄 파싱
      Logger.info('[TimeBasedGenerator] 🔄 응답 데이터 파싱 중...');
      final result = _convertToFortuneResult(data, inputConditions);

      Logger.info('[TimeBasedGenerator] ✅ 파싱 완료');
      Logger.info('[TimeBasedGenerator]   📝 Title: ${result.title}');
      Logger.info('[TimeBasedGenerator]   ⭐ Score: ${result.score}');

      return result;
    } catch (e, stackTrace) {
      Logger.error('[TimeBasedGenerator] ❌ 일일운세 생성 실패', e, stackTrace);
      rethrow;
    }
  }

  /// API 응답을 FortuneResult로 변환
  static FortuneResult _convertToFortuneResult(
    Map<String, dynamic> apiData,
    Map<String, dynamic> inputConditions,
  ) {
    return FortuneResult(
      type: 'time_based',
      title: apiData['title'] as String? ?? '일일운세',
      summary: apiData['summary'] as Map<String, dynamic>? ?? {},
      data: apiData['data'] as Map<String, dynamic>? ?? apiData,
      score: (apiData['score'] as num?)?.toInt() ??
             (apiData['overallScore'] as num?)?.toInt() ?? 50,
    );
  }
}
