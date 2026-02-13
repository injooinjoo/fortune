import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/fortune_result.dart';
import '../../utils/logger.dart';

/// 전통사주팔자 Generator - API 기반 운세 생성
/// 사주 명식을 바탕으로 질문에 답변하는 전통 사주 상담
class TraditionalSajuGenerator {
  /// 전통사주 운세 생성 (Edge Function 호출)
  static Future<FortuneResult> generate(
    Map<String, dynamic> inputConditions,
    SupabaseClient supabase,
  ) async {
    final userId = supabase.auth.currentUser?.id ?? 'unknown';

    // 📤 API 요청 준비
    Logger.info('[TraditionalSajuGenerator] 📤 API 요청 준비');
    Logger.info(
        '[TraditionalSajuGenerator]   🌐 Edge Function: fortune-traditional-saju');
    Logger.info('[TraditionalSajuGenerator]   👤 user_id: $userId');
    Logger.info(
        '[TraditionalSajuGenerator]   ❓ question: ${inputConditions['question']}');
    Logger.info(
        '[TraditionalSajuGenerator]   💎 isPremium: ${inputConditions['isPremium'] ?? false}');

    try {
      final requestBody = {
        'userId': userId,
        'question': inputConditions['question'],
        'sajuData': inputConditions['sajuData'],
        'isPremium': inputConditions['isPremium'] ?? false,
      };

      Logger.info('[TraditionalSajuGenerator] 📡 API 호출 중...');

      // Edge Function 호출
      final response = await supabase.functions.invoke(
        'fortune-traditional-saju',
        body: utf8.encode(jsonEncode(requestBody)),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      // 📥 응답 수신
      Logger.info('[TraditionalSajuGenerator] 📥 API 응답 수신');
      Logger.info('[TraditionalSajuGenerator]   ✅ Status: ${response.status}');

      if (response.status != 200) {
        Logger.error(
            '[TraditionalSajuGenerator] ❌ API 호출 실패: status ${response.status}');
        throw Exception('Edge Function 호출 실패: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;
      Logger.info(
          '[TraditionalSajuGenerator]   📦 Response data keys: ${data.keys.toList()}');

      // 🔄 파싱
      Logger.info('[TraditionalSajuGenerator] 🔄 응답 데이터 파싱 중...');
      final result = _convertToFortuneResult(data, inputConditions);

      Logger.info('[TraditionalSajuGenerator] ✅ 파싱 완료');
      Logger.info(
          '[TraditionalSajuGenerator]   📝 Question: ${result.data['question']}');

      return result;
    } catch (e, stackTrace) {
      Logger.error('[TraditionalSajuGenerator] ❌ 전통사주 운세 생성 실패', e, stackTrace);
      rethrow;
    }
  }

  /// API 응답을 FortuneResult로 변환
  static FortuneResult _convertToFortuneResult(
    Map<String, dynamic> apiData,
    Map<String, dynamic> inputConditions,
  ) {
    return FortuneResult(
      type: 'traditional_saju',
      title: '전통사주팔자',
      summary: {
        'question': apiData['question'] as String? ?? '',
        'summary': apiData['summary'] as String? ?? '',
      },
      data: {
        'question': apiData['question'] as String? ?? '',
        'sections': apiData['sections'] as Map<String, dynamic>? ?? {},
        'summary': apiData['summary'] as String? ?? '',
      },
      score: null, // 전통사주는 점수 없음
    );
  }
}
