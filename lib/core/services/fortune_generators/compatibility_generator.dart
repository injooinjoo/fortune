import 'dart:convert';
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
    final userId = supabase.auth.currentUser?.id ?? 'unknown';
    final person1 = inputConditions['person1'] as Map<String, dynamic>;
    final person2 = inputConditions['person2'] as Map<String, dynamic>;

    // 📤 API 요청 준비
    Logger.info('[CompatibilityGenerator] 📤 API 요청 준비');
    Logger.info('[CompatibilityGenerator]   🌐 Edge Function: fortune-compatibility');
    Logger.info('[CompatibilityGenerator]   👤 user_id: $userId');
    Logger.info('[CompatibilityGenerator]   👤 person1: ${person1['name']} (${person1['birth_date']})');
    Logger.info('[CompatibilityGenerator]   👤 person2: ${person2['name']} (${person2['birth_date']})');

    try {
      final requestBody = {
        'fortune_type': 'compatibility',
        'person1_name': person1['name'],
        'person1_birth_date': person1['birth_date'],
        'person2_name': person2['name'],
        'person2_birth_date': person2['birth_date'],
      };

      Logger.info('[CompatibilityGenerator] 📡 API 호출 중...');

      // ✅ UTF-8 인코딩을 위해 JSON 문자열로 변환
      final jsonBody = utf8.encode(jsonEncode(requestBody));

      // Edge Function 호출
      final response = await supabase.functions.invoke(
        'fortune-compatibility',
        body: jsonBody,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      // 📥 응답 수신
      Logger.info('[CompatibilityGenerator] 📥 API 응답 수신');
      Logger.info('[CompatibilityGenerator]   ✅ Status: ${response.status}');

      if (response.status != 200) {
        Logger.error('[CompatibilityGenerator] ❌ API 호출 실패: status ${response.status}');
        throw Exception('Edge Function 호출 실패: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;
      Logger.info('[CompatibilityGenerator]   📦 Response data keys: ${data.keys.toList()}');

      // 🔄 파싱
      Logger.info('[CompatibilityGenerator] 🔄 응답 데이터 파싱 중...');
      final result = _convertToFortuneResult(data, inputConditions);

      Logger.info('[CompatibilityGenerator] ✅ 파싱 완료');
      Logger.info('[CompatibilityGenerator]   📝 Title: ${result.title}');
      Logger.info('[CompatibilityGenerator]   ⭐ Score: ${result.score}');

      return result;
    } catch (e, stackTrace) {
      Logger.error('[CompatibilityGenerator] ❌ 궁합 운세 생성 실패', e, stackTrace);
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
