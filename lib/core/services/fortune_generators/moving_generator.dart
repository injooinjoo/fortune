import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/fortune_result.dart';
import '../../utils/logger.dart';
import '../../utils/moving_fortune_input_mapper.dart';

/// 이사운 Generator - API 기반 운세 생성
class MovingGenerator {
  /// 이사운 생성 (Edge Function 호출)
  static Future<FortuneResult> generate(
    Map<String, dynamic> inputConditions,
    SupabaseClient supabase,
  ) async {
    final userId = supabase.auth.currentUser?.id ?? 'unknown';
    final normalizedInputConditions =
        MovingFortuneInputMapper.normalize(inputConditions);

    // 📤 API 요청 준비
    Logger.info('[MovingGenerator] 📤 API 요청 준비');
    Logger.info('[MovingGenerator]   🌐 Edge Function: fortune-moving');
    Logger.info('[MovingGenerator]   👤 user_id: $userId');
    Logger.info(
        '[MovingGenerator]   📍 current_area: ${normalizedInputConditions['current_area']}');
    Logger.info(
        '[MovingGenerator]   📍 target_area: ${normalizedInputConditions['target_area']}');
    Logger.info(
        '[MovingGenerator]   📅 moving_period: ${normalizedInputConditions['moving_period']}');
    Logger.info(
        '[MovingGenerator]   🎯 purpose: ${normalizedInputConditions['purpose']}');

    try {
      final requestBody = {
        'fortune_type': 'moving',
        'current_area': normalizedInputConditions['current_area'],
        'target_area': normalizedInputConditions['target_area'],
        'moving_period': normalizedInputConditions['moving_period'],
        'movingDate': normalizedInputConditions['movingDate'],
        'purpose': normalizedInputConditions['purpose'],
        'purposeCategory': normalizedInputConditions['purposeCategory'],
        'concerns': normalizedInputConditions['concerns'],
        'direction': normalizedInputConditions['direction'],
      };

      Logger.info('[MovingGenerator] 📡 API 호출 중...');
      Logger.debug('[MovingGenerator] Request body: $requestBody');

      // Edge Function 호출
      final response = await supabase.functions.invoke(
        'fortune-moving',
        body: jsonEncode(requestBody),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      // 📥 응답 수신
      Logger.info('[MovingGenerator] 📥 API 응답 수신');
      Logger.info('[MovingGenerator]   ✅ Status: ${response.status}');

      if (response.status != 200) {
        Logger.error(
            '[MovingGenerator] ❌ API 호출 실패: status ${response.status}');
        throw Exception('Edge Function 호출 실패: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;
      Logger.info('[MovingGenerator]   📦 Response data: $data');

      // 🔄 파싱
      Logger.info('[MovingGenerator] 🔄 응답 데이터 파싱 중...');
      final result = _convertToFortuneResult(data, normalizedInputConditions);

      Logger.info('[MovingGenerator] ✅ 파싱 완료');
      Logger.info('[MovingGenerator]   📝 Title: ${result.title}');
      Logger.info('[MovingGenerator]   ⭐ Score: ${result.score}');

      return result;
    } catch (e, stackTrace) {
      Logger.error('[MovingGenerator] ❌ 이사운 생성 실패', e, stackTrace);
      rethrow;
    }
  }

  /// API 응답을 FortuneResult로 변환
  static FortuneResult _convertToFortuneResult(
    Map<String, dynamic> apiData,
    Map<String, dynamic> inputConditions,
  ) {
    return FortuneResult(
      type: 'moving',
      title: apiData['title'] as String? ?? '이사운',
      summary: apiData['summary'] as Map<String, dynamic>? ?? {},
      data: apiData['data'] as Map<String, dynamic>? ?? apiData,
      score: (apiData['score'] as num?)?.toInt() ?? 50,
    );
  }
}
