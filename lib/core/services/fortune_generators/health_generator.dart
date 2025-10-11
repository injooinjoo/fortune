import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/fortune_result.dart';

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
    try {
      // Edge Function 호출
      final response = await supabase.functions.invoke(
        'generate-fortune',
        body: {
          'fortune_type': 'health',
          'current_condition': inputConditions['current_condition'],
          'concerned_body_parts': inputConditions['concerned_body_parts'],
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to generate health fortune: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      return _convertToFortuneResult(data, inputConditions);
    } catch (e) {
      throw Exception('HealthGenerator error: $e');
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
