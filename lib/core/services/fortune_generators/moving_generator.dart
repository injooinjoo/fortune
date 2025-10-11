import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/fortune_result.dart';
import '../../utils/logger.dart';

/// 이사운 Generator - API 기반 운세 생성
class MovingGenerator {
  /// 이사운 생성 (Edge Function 호출)
  static Future<FortuneResult> generate(
    Map<String, dynamic> inputConditions,
    SupabaseClient supabase,
  ) async {
    Logger.info('🏠 [MovingGenerator] Generating moving fortune', {
      'inputConditions': inputConditions,
    });

    try {
      // Edge Function 호출
      final response = await supabase.functions.invoke(
        'generate-fortune',
        body: {
          'fortune_type': 'moving',
          'current_area': inputConditions['current_area'],
          'target_area': inputConditions['target_area'],
          'moving_period': inputConditions['moving_period'],
          'purpose': inputConditions['purpose'],
        },
      );

      if (response.status != 200) {
        throw Exception('Edge Function 호출 실패: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;

      Logger.info('✅ [MovingGenerator] Moving fortune generated successfully');

      return _convertToFortuneResult(data, inputConditions);
    } catch (e, stackTrace) {
      Logger.error('❌ [MovingGenerator] Failed to generate moving fortune', e, stackTrace);
      rethrow;
    }
  }

  /// API 응답을 FortuneResult로 변환
  static FortuneResult _convertToFortuneResult(
    Map<String, dynamic> apiData,
    Map<String, dynamic> inputConditions,
  ) {
    return FortuneResult(
      fortuneType: 'moving',
      title: apiData['title'] as String? ?? '이사운',
      summary: apiData['summary'] as Map<String, dynamic>? ?? {},
      data: apiData['data'] as Map<String, dynamic>? ?? apiData,
      score: (apiData['score'] as num?)?.toInt() ?? 50,
      inputConditions: inputConditions,
    );
  }
}
