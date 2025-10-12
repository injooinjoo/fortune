import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/fortune_result.dart';
import '../../utils/logger.dart';

/// 시간별 운세 Generator - API 기반 운세 생성
/// 오늘/내일/주간/월간/연간 운세
class TimeBasedGenerator {
  /// 시간별 운세 생성 (Edge Function 호출)
  static Future<FortuneResult> generate(
    Map<String, dynamic> inputConditions,
    SupabaseClient supabase,
  ) async {
    Logger.info('📅 [TimeBasedGenerator] Generating time-based fortune', {
      'inputConditions': inputConditions,
    });

    try {
      // Edge Function 호출
      final response = await supabase.functions.invoke(
        'fortune-daily',
        body: {
          'date': inputConditions['date'],
          'period': inputConditions['period'] ?? 'daily',
          'is_holiday': inputConditions['is_holiday'] ?? false,
          'holiday_name': inputConditions['holiday_name'],
          'special_name': inputConditions['special_name'],
        },
      );

      if (response.status != 200) {
        throw Exception('Edge Function 호출 실패: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;

      Logger.info('✅ [TimeBasedGenerator] Time-based fortune generated successfully');

      return _convertToFortuneResult(data, inputConditions);
    } catch (e, stackTrace) {
      Logger.error('❌ [TimeBasedGenerator] Failed to generate time-based fortune', e, stackTrace);
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
      title: apiData['title'] as String? ?? '시간별 운세',
      summary: apiData['summary'] as Map<String, dynamic>? ?? {},
      data: apiData['data'] as Map<String, dynamic>? ?? apiData,
      score: (apiData['score'] as num?)?.toInt() ??
             (apiData['overallScore'] as num?)?.toInt() ?? 50,
    );
  }
}
