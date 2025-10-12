import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/fortune_result.dart';
import '../../utils/logger.dart';

/// 건강 운세 생성기
///
/// Edge Function을 통해 건강 운세를 생성합니다.
/// - 현재 건강 상태
/// - 관심 신체 부위
class HealthGenerator {
  /// 건강 운세 생성
  ///
  /// **input_conditions 형식**:
  /// ```json
  /// {
  ///   "current_condition": "good",  // excellent, good, normal, tired, exhausted
  ///   "concerned_body_parts": ["head", "neck", "shoulders"],  // 선택적
  ///   // 신체 부위: head, neck, shoulders, chest, stomach, back, waist,
  ///   //           arms, wrists, legs, knees, ankles, feet, eyes, ears
  /// }
  /// ```
  static Future<FortuneResult> generate(
    Map<String, dynamic> inputConditions,
    SupabaseClient supabase,
  ) async {
    final userId = supabase.auth.currentUser?.id ?? 'unknown';

    // 📤 API 요청 준비
    Logger.info('[HealthGenerator] 📤 API 요청 준비');
    Logger.info('[HealthGenerator]   🌐 Edge Function: fortune-health');
    Logger.info('[HealthGenerator]   👤 user_id: $userId');
    Logger.info('[HealthGenerator]   💊 current_condition: ${inputConditions['current_condition']}');
    Logger.info('[HealthGenerator]   🩺 concerned_body_parts: ${inputConditions['concerned_body_parts']}');

    try {
      final requestBody = {
        'fortune_type': 'health',
        'current_condition': inputConditions['current_condition'],
        'concerned_body_parts': inputConditions['concerned_body_parts'],
      };

      Logger.info('[HealthGenerator] 📡 API 호출 중...');

      // Edge Function 호출
      final response = await supabase.functions.invoke(
        'fortune-health',
        body: requestBody,
      );

      // 📥 응답 수신
      Logger.info('[HealthGenerator] 📥 API 응답 수신');
      Logger.info('[HealthGenerator]   ✅ Status: ${response.status}');

      if (response.status != 200) {
        Logger.error('[HealthGenerator] ❌ API 호출 실패: ${response.data}');
        throw Exception('Failed to generate health fortune: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      Logger.info('[HealthGenerator]   📦 Response data keys: ${data.keys.toList()}');

      // 🔄 파싱
      Logger.info('[HealthGenerator] 🔄 응답 데이터 파싱 중...');
      final result = _convertToFortuneResult(data, inputConditions);

      Logger.info('[HealthGenerator] ✅ 파싱 완료');
      Logger.info('[HealthGenerator]   📝 Title: ${result.title}');
      Logger.info('[HealthGenerator]   ⭐ Score: ${result.score}');

      return result;
    } catch (e, stackTrace) {
      Logger.error('[HealthGenerator] ❌ 건강운 생성 실패', e, stackTrace);
      rethrow;
    }
  }

  /// Edge Function 응답을 FortuneResult로 변환
  static FortuneResult _convertToFortuneResult(
    Map<String, dynamic> data,
    Map<String, dynamic> inputConditions,
  ) {
    final fortuneData = data['fortune_data'] as Map<String, dynamic>? ?? {};
    final content = data['content'] as String? ?? '';
    final summary = data['summary'] as String? ?? '';
    final score = data['score'] as int?;

    return FortuneResult(
      type: 'health',
      title: '건강 운세',
      summary: {
        'message': summary,
        'score': score,
        'health_info': {
          'condition': inputConditions['current_condition'],
          'body_parts': inputConditions['concerned_body_parts'],
        },
      },
      data: {
        'content': content,
        'fortune_data': fortuneData,
        'current_condition': inputConditions['current_condition'],
        'concerned_body_parts': inputConditions['concerned_body_parts'],
      },
      score: score,
      createdAt: DateTime.now(),
    );
  }
}
