import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/fortune_result.dart';
import '../../utils/logger.dart';

/// 헤어진 애인 Generator - API 기반 운세 생성
/// 재회 가능성 분석
class ExLoverGenerator {
  /// 헤어진 애인 운세 생성 (Edge Function 호출)
  static Future<FortuneResult> generate(
    Map<String, dynamic> inputConditions,
    SupabaseClient supabase,
  ) async {
    Logger.info('💔 [ExLoverGenerator] Generating ex-lover fortune', {
      'inputConditions': inputConditions,
    });

    try {
      // Edge Function 호출
      final response = await supabase.functions.invoke(
        'generate-fortune',
        body: {
          'fortune_type': 'ex_lover',
          'name': inputConditions['name'],
          'birth_date': inputConditions['birth_date'],
          'gender': inputConditions['gender'],
          'mbti': inputConditions['mbti'],
          'relationship_duration': inputConditions['relationship_duration'],
          'breakup_reason': inputConditions['breakup_reason'],
          'time_since_breakup': inputConditions['time_since_breakup'],
          'current_feeling': inputConditions['current_feeling'],
          'still_in_contact': inputConditions['still_in_contact'],
          'has_unresolved_feelings': inputConditions['has_unresolved_feelings'],
        },
      );

      if (response.status != 200) {
        throw Exception('Edge Function 호출 실패: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;

      Logger.info('✅ [ExLoverGenerator] Ex-lover fortune generated successfully');

      return _convertToFortuneResult(data, inputConditions);
    } catch (e, stackTrace) {
      Logger.error('❌ [ExLoverGenerator] Failed to generate ex-lover fortune', e, stackTrace);
      rethrow;
    }
  }

  /// API 응답을 FortuneResult로 변환
  static FortuneResult _convertToFortuneResult(
    Map<String, dynamic> apiData,
    Map<String, dynamic> inputConditions,
  ) {
    return FortuneResult(
      fortuneType: 'ex_lover',
      title: apiData['title'] as String? ?? '헤어진 애인',
      summary: apiData['summary'] as Map<String, dynamic>? ?? {},
      data: apiData['data'] as Map<String, dynamic>? ?? apiData,
      score: (apiData['score'] as num?)?.toInt() ??
             (apiData['overallScore'] as num?)?.toInt() ?? 50,
      inputConditions: inputConditions,
    );
  }
}
