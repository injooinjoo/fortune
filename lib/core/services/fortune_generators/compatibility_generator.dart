import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/fortune_result.dart';
import '../../utils/logger.dart';

/// 궁합 Generator - API 기반 운세 생성
/// 두 사람의 생년월일을 비교하여 궁합 분석
class CompatibilityGenerator {
  /// 궁합 운세 생성 (Edge Function 호출)
  static Future<FortuneResult> generate(
    Map<String, dynamic> inputConditions,
    SupabaseClient supabase,
  ) async {
    Logger.info('💑 [CompatibilityGenerator] Generating compatibility fortune', {
      'inputConditions': inputConditions,
    });

    try {
      final person1 = inputConditions['person1'] as Map<String, dynamic>;
      final person2 = inputConditions['person2'] as Map<String, dynamic>;

      // Edge Function 호출
      final response = await supabase.functions.invoke(
        'generate-fortune',
        body: {
          'fortune_type': 'compatibility',
          'person1_name': person1['name'],
          'person1_birth_date': person1['birth_date'],
          'person2_name': person2['name'],
          'person2_birth_date': person2['birth_date'],
        },
      );

      if (response.status != 200) {
        throw Exception('Edge Function 호출 실패: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;

      Logger.info('✅ [CompatibilityGenerator] Compatibility fortune generated successfully');

      return _convertToFortuneResult(data, inputConditions);
    } catch (e, stackTrace) {
      Logger.error('❌ [CompatibilityGenerator] Failed to generate compatibility fortune', e, stackTrace);
      rethrow;
    }
  }

  /// API 응답을 FortuneResult로 변환
  static FortuneResult _convertToFortuneResult(
    Map<String, dynamic> apiData,
    Map<String, dynamic> inputConditions,
  ) {
    return FortuneResult(
      type: 'compatibility',
      title: apiData['title'] as String? ?? '궁합',
      summary: apiData['summary'] as Map<String, dynamic>? ?? {},
      data: apiData['data'] as Map<String, dynamic>? ?? apiData,
      score: (apiData['score'] as num?)?.toInt() ??
             (apiData['overallScore'] as num?)?.toInt() ?? 75,
    );
  }
}
