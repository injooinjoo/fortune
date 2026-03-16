import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../errors/exceptions.dart';
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
    Logger.info(
        '[WishGenerator]   ✨ wish_text: ${inputConditions['wish_text']}');
    Logger.info(
        '[WishGenerator]   📂 category: ${inputConditions['category']}');

    try {
      final requestBody = {
        'wish_text': inputConditions['wish_text'],
        'category': inputConditions['category'],
        'user_profile': inputConditions['user_profile'],
      };

      Logger.info('[WishGenerator] 📡 API 호출 중...');

      // Edge Function 호출
      final response = await supabase.functions.invoke(
        'analyze-wish',
        body: jsonEncode(requestBody),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
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
      Logger.info(
          '[WishGenerator]   📦 Response data keys: ${wishData.keys.toList()}');

      // ✅ 필수 필드 검증 (기존)
      const requiredFields = [
        'empathy_message',
        'hope_message',
        'advice',
        'encouragement',
        'special_words'
      ];
      for (final field in requiredFields) {
        if (!wishData.containsKey(field)) {
          Logger.error('[WishGenerator] ❌ 필수 필드 누락: $field');
          Logger.error('[WishGenerator]   수신된 필드: ${wishData.keys.toList()}');
          throw WishAnalysisException(
            message: '소원 분석 응답이 불완전합니다',
            code: 'MISSING_FIELD',
            missingField: field,
          );
        }
      }

      // 🆕 확장 필드 검증 (새 필드 - 경고만 로그)
      const enhancedFields = [
        'fortune_flow',
        'lucky_mission',
        'dragon_message'
      ];
      for (final field in enhancedFields) {
        if (!wishData.containsKey(field)) {
          Logger.warning('[WishGenerator] ⚠️ 확장 필드 누락: $field');
        }
      }

      // 🐉 용의 메시지 로깅
      if (wishData.containsKey('dragon_message')) {
        final dragonMsg = wishData['dragon_message'] as Map<String, dynamic>?;
        Logger.info(
            '[WishGenerator]   🐉 power_line: ${dragonMsg?['power_line'] ?? 'N/A'}');
      }

      // 🎯 행운 미션 로깅
      if (wishData.containsKey('lucky_mission')) {
        final mission = wishData['lucky_mission'] as Map<String, dynamic>?;
        Logger.info('[WishGenerator]   🍀 행운 미션: ${mission?['item'] ?? 'N/A'}');
      }

      // 🔄 파싱
      Logger.info('[WishGenerator] 🔄 응답 데이터 파싱 중...');
      final result = _convertToFortuneResult(wishData, inputConditions);

      Logger.info('[WishGenerator] ✅ 파싱 완료');
      Logger.info('[WishGenerator]   📝 Title: ${result.title}');

      return result;
    } on WishAnalysisException {
      rethrow;
    } on FormatException catch (e, stackTrace) {
      Logger.error('[WishGenerator] ❌ JSON 파싱 실패', e, stackTrace);
      throw WishAnalysisException(
        message: '소원 분석 응답을 처리할 수 없습니다',
        code: 'PARSE_ERROR',
        originalError: e,
      );
    } catch (e, stackTrace) {
      Logger.error('[WishGenerator] ❌ 소원 분석 실패', e, stackTrace);

      String userMessage = '소원 분석 중 오류가 발생했습니다';
      if (e.toString().contains('timeout')) {
        userMessage = '응답 시간이 초과되었습니다. 네트워크를 확인해주세요.';
      } else if (e.toString().contains('SocketException')) {
        userMessage = '네트워크 연결을 확인해주세요.';
      }

      throw WishAnalysisException(
        message: userMessage,
        code: 'UNKNOWN_ERROR',
        originalError: e,
      );
    }
  }

  /// Edge Function 응답을 FortuneResult로 변환
  static FortuneResult _convertToFortuneResult(
    Map<String, dynamic> wishData,
    Map<String, dynamic> inputConditions,
  ) {
    // ✅ 새 필드명 사용 (empathy_message)
    final empathyMessage = wishData['empathy_message'] as String? ?? '';

    return FortuneResult(
      type: 'wish',
      title: '소원 빌기 - ${inputConditions['category']}',
      summary: {
        'message': empathyMessage,
        'wish_text': inputConditions['wish_text'],
        'category': inputConditions['category'],
      },
      data: wishData, // 전체 응답을 data 필드에 저장
      score: null, // 소원은 점수가 없음
      createdAt: DateTime.now(),
    );
  }
}
