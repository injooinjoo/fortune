import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/fortune_result.dart';
import '../../../features/fortune/domain/models/conditions/health_fortune_conditions.dart';
import '../../utils/logger.dart';

/// 건강운세 생성기
///
/// Edge Function을 직접 호출하여 건강운세를 생성
class HealthGenerator {
  /// 건강운세 생성
  ///
  /// [conditions]: 건강운세 조건
  /// [supabase]: Supabase 클라이언트
  /// [isPremium]: 프리미엄 사용자 여부
  static Future<FortuneResult> generate({
    required HealthFortuneConditions conditions,
    required SupabaseClient supabase,
    required bool isPremium,
  }) async {
    Logger.info('[HealthGenerator] 건강운세 생성 시작');
    Logger.info('   - isPremium: $isPremium');

    try {
      // 사용자 ID 가져오기
      final userId = supabase.auth.currentUser?.id ?? 'anonymous';

      // API Payload 구성
      final payload = {
        ...conditions.buildAPIPayload(),
        'isPremium': isPremium,
      };

      Logger.info('[HealthGenerator] API 호출 시작');
      Logger.info('   - userId: $userId');

      // Edge Function 호출
      final response = await supabase.functions.invoke(
        'fortune-health',
        body: payload,
      );

      if (response.status != 200) {
        throw Exception('API 호출 실패: ${response.status}');
      }

      // Null Safety: 응답 데이터 검증
      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) {
        throw Exception('API 응답 데이터가 없습니다');
      }
      final data = responseData['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('API 응답에서 data 필드를 찾을 수 없습니다');
      }

      // 프리미엄이 아니면 블러 섹션 설정
      final blurredSections = isPremium
          ? <String>[]
          : [
              'body_part_advice',
              'cautions',
              'recommended_activities',
              'diet_advice',
              'exercise_advice',
              'health_keyword',
            ];

      // 점수 및 메시지 추출 (안전한 타입 처리)
      final healthScore = data['score'] as int? ?? 75;

      // overall_health가 String 또는 Map일 수 있음
      String overallHealth;
      final overallHealthRaw = data['overall_health'];
      if (overallHealthRaw is String) {
        overallHealth = overallHealthRaw;
      } else if (overallHealthRaw is Map) {
        // Map인 경우 첫 번째 값 사용 또는 전체 내용 조합
        overallHealth = (overallHealthRaw as Map<String, dynamic>).values.join(' ');
      } else {
        overallHealth = '건강하십니다.';
      }

      final result = FortuneResult(
        id: 'health-${DateTime.now().millisecondsSinceEpoch}',
        type: 'health',
        title: '건강운세',
        summary: {
          'score': healthScore,
          'message': overallHealth,
          'emoji': healthScore >= 80 ? '💚' : healthScore >= 60 ? '💛' : '🧡',
        },
        data: data,
        score: healthScore,
        createdAt: DateTime.now(),
        isBlurred: !isPremium,
        blurredSections: blurredSections,
      );

      Logger.info('[HealthGenerator] 건강운세 생성 완료');
      Logger.info('   - fortuneId: ${result.id}');
      Logger.info('   - isBlurred: ${result.isBlurred}');

      return result;
    } catch (e, stackTrace) {
      Logger.error('[HealthGenerator] 건강운세 생성 실패', e, stackTrace);
      rethrow;
    }
  }
}
