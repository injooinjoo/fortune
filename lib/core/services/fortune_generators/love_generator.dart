import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/fortune_result.dart';
import '../../../features/fortune/domain/models/conditions/love_fortune_conditions.dart';
import '../../utils/logger.dart';

/// 연애운 생성기
///
/// Edge Function을 직접 호출하여 연애운을 생성
class LoveGenerator {
  /// 연애운 생성
  ///
  /// [conditions]: 연애운 조건
  /// [supabase]: Supabase 클라이언트
  /// [isPremium]: 프리미엄 사용자 여부
  static Future<FortuneResult> generate({
    required LoveFortuneConditions conditions,
    required SupabaseClient supabase,
    required bool isPremium,
  }) async {
    Logger.info('[LoveGenerator] 연애운 생성 시작');
    Logger.info('   - isPremium: $isPremium');

    try {
      // 사용자 ID 가져오기
      final userId = supabase.auth.currentUser?.id ?? 'anonymous';

      // API Payload 구성
      final payload = {
        ...conditions.buildAPIPayload(),
        'userId': userId, // ✅ userId 추가
        'isPremium': isPremium,
      };

      Logger.info('[LoveGenerator] API 호출 시작');
      Logger.info('   - userId: $userId');

      // Edge Function 호출
      final response = await supabase.functions.invoke(
        'fortune-love',
        body: payload,
      );

      if (response.status != 200) {
        throw Exception('API 호출 실패: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;

      // 🎯 토큰 소비형 모델: 블러 처리 제거
      // 점수 및 메시지 추출
      final loveScore = data['loveScore'] as int? ?? 70;
      final mainMessage = data['mainMessage'] as String? ?? '새로운 사랑의 기회가 찾아올 것입니다.';

      final result = FortuneResult(
        id: 'love-${DateTime.now().millisecondsSinceEpoch}',
        type: 'love',
        title: '연애운세',
        summary: {
          'score': loveScore,
          'message': mainMessage,
          'emoji': loveScore >= 80 ? '💕' : loveScore >= 60 ? '💖' : '💗',
        },
        data: data,
        score: loveScore,
        createdAt: DateTime.now(),
      );

      Logger.info('[LoveGenerator] 연애운 생성 완료');
      Logger.info('   - fortuneId: ${result.id}');

      return result;
    } catch (e, stackTrace) {
      Logger.error('[LoveGenerator] 연애운 생성 실패', e, stackTrace);
      rethrow;
    }
  }
}
