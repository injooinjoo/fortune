import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/fortune_result.dart';
import '../../utils/logger.dart';

/// 피해야 할 사람 Generator - API 기반 운세 생성
class AvoidPeopleGenerator {
  /// 피해야 할 사람 운세 생성 (Edge Function 호출)
  static Future<FortuneResult> generate(
    Map<String, dynamic> inputConditions,
    SupabaseClient supabase,
  ) async {
    Logger.info('⚠️ [AvoidPeopleGenerator] Generating avoid people fortune', {
      'inputConditions': inputConditions,
    });

    try {
      // Edge Function 호출
      final response = await supabase.functions.invoke(
        'fortune-avoid-people',
        body: {
          'environment': inputConditions['environment'],
          'important_schedule': inputConditions['important_schedule'],
          'mood_level': inputConditions['mood_level'],
          'stress_level': inputConditions['stress_level'],
          'social_fatigue': inputConditions['social_fatigue'],
          'has_important_decision': inputConditions['has_important_decision'],
          'has_sensitive_conversation': inputConditions['has_sensitive_conversation'],
          'has_team_project': inputConditions['has_team_project'],
        },
      );

      if (response.status != 200) {
        throw Exception('Edge Function 호출 실패: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;

      Logger.info('✅ [AvoidPeopleGenerator] Avoid people fortune generated successfully');

      return _convertToFortuneResult(data, inputConditions);
    } catch (e, stackTrace) {
      Logger.error('❌ [AvoidPeopleGenerator] Failed to generate avoid people fortune', e, stackTrace);
      rethrow;
    }
  }

  /// API 응답을 FortuneResult로 변환
  static FortuneResult _convertToFortuneResult(
    Map<String, dynamic> apiData,
    Map<String, dynamic> inputConditions,
  ) {
    return FortuneResult(
      fortuneType: 'avoid_people',
      title: apiData['title'] as String? ?? '피해야 할 사람',
      summary: apiData['summary'] as Map<String, dynamic>? ?? {},
      data: apiData['data'] as Map<String, dynamic>? ?? apiData,
      score: (apiData['score'] as num?)?.toInt() ?? 50,
      inputConditions: inputConditions,
    );
  }
}
