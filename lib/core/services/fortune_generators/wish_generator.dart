import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/fortune_result.dart';
import '../../utils/logger.dart';

/// 소원 빌기 생성기
///
/// Edge Function을 통해 소원을 분석하고 신의 응답을 생성합니다.
class WishGenerator {
  /// 소원 분석 및 응답 생성
  ///
  /// **input_conditions 형식**:
  /// ```json
  /// {
  ///   "wish_text": "원하는 소원 내용",
  ///   "category": "love" | "money" | "health" | "success" | "family" | "study" | "other",
  ///   "urgency": 1-5 (간절함 정도),
  ///   "user_profile": {
  ///     "birth_date": "1990-01-01",
  ///     "zodiac": "snake"
  ///   }
  /// }
  /// ```
  static Future<FortuneResult> generate(
    Map<String, dynamic> inputConditions,
    SupabaseClient supabase,
  ) async {
    final userId = supabase.auth.currentUser?.id ?? 'unknown';

    // 📤 API 요청 준비
    Logger.info('[WishGenerator] 📤 API 요청 준비');
    Logger.info('[WishGenerator]   🌐 Edge Function: analyze-wish');
    Logger.info('[WishGenerator]   👤 user_id: $userId');
    Logger.info('[WishGenerator]   ✨ wish_text: ${inputConditions['wish_text']}');
    Logger.info('[WishGenerator]   📂 category: ${inputConditions['category']}');
    Logger.info('[WishGenerator]   🔥 urgency: ${inputConditions['urgency']}');

    try {
      final requestBody = {
        'wish_text': inputConditions['wish_text'],
        'category': inputConditions['category'],
        'urgency': inputConditions['urgency'],
        'user_profile': inputConditions['user_profile'],
      };

      Logger.info('[WishGenerator] 📡 API 호출 중...');

      // Edge Function 호출
      final response = await supabase.functions.invoke(
        'analyze-wish',
        body: requestBody,
      );

      // 📥 응답 수신
      Logger.info('[WishGenerator] 📥 API 응답 수신');
      Logger.info('[WishGenerator]   ✅ Status: ${response.status}');

      if (response.status != 200) {
        Logger.error('[WishGenerator] ❌ API 호출 실패: ${response.data}');
        throw Exception('Failed to analyze wish: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;

      // analyze-wish returns {success: true, data: {...}}
      if (data['success'] != true || !data.containsKey('data')) {
        Logger.error('[WishGenerator] ❌ 응답 형식 오류: $data');
        throw Exception('Invalid response format from analyze-wish');
      }

      final wishData = data['data'] as Map<String, dynamic>;
      Logger.info('[WishGenerator]   📦 Response data keys: ${wishData.keys.toList()}');

      // 🔄 파싱
      Logger.info('[WishGenerator] 🔄 응답 데이터 파싱 중...');
      final result = _convertToFortuneResult(wishData, inputConditions);

      Logger.info('[WishGenerator] ✅ 파싱 완료');
      Logger.info('[WishGenerator]   📝 Title: ${result.title}');

      return result;
    } catch (e, stackTrace) {
      Logger.error('[WishGenerator] ❌ 소원 분석 실패', e, stackTrace);
      rethrow;
    }
  }

  /// Edge Function 응답을 FortuneResult로 변환
  static FortuneResult _convertToFortuneResult(
    Map<String, dynamic> wishData,
    Map<String, dynamic> inputConditions,
  ) {
    return FortuneResult(
      type: 'wish',
      title: '소원 빌기 - ${inputConditions['category']}',
      summary: {
        'message': wishData['divine_message'] ?? '',
        'wish_text': inputConditions['wish_text'],
        'category': inputConditions['category'],
        'urgency': inputConditions['urgency'],
      },
      data: wishData, // 전체 응답을 data 필드에 저장
      score: null, // 소원은 점수가 없음
      createdAt: DateTime.now(),
    );
  }
}
