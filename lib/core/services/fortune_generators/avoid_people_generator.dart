import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/fortune_result.dart';
import '../../utils/logger.dart';

/// 피해야 할 사람 Generator - API 기반 운세 생성
class AvoidPeopleGenerator {
  /// 피해야 할 사람 운세 생성 (Edge Function 호출)
  static Future<FortuneResult> generate(
    Map<String, dynamic> inputConditions,
    SupabaseClient supabase,
  ) async {
    // userId와 name 가져오기
    final user = supabase.auth.currentUser;
    final userProfile = user != null
        ? await supabase
            .from('user_profiles')
            .select('name')
            .eq('id', user.id)
            .maybeSingle()
        : null;

    final userId = user?.id ?? 'anonymous';
    final userName = userProfile?['name'] as String? ??
        user?.userMetadata?['name'] as String? ??
        'Guest';

    // 📤 API 요청 준비
    Logger.info('[AvoidPeopleGenerator] 📤 API 요청 준비');
    Logger.info(
        '[AvoidPeopleGenerator]   🌐 Edge Function: fortune-avoid-people');
    Logger.info('[AvoidPeopleGenerator]   👤 user_id: $userId');
    Logger.info('[AvoidPeopleGenerator]   👤 name: $userName');
    Logger.info(
        '[AvoidPeopleGenerator]   🏢 environment: ${inputConditions['environment']}');
    Logger.info(
        '[AvoidPeopleGenerator]   📅 important_schedule: ${inputConditions['important_schedule']}');
    Logger.info(
        '[AvoidPeopleGenerator]   😊 mood_level: ${inputConditions['mood_level']}');
    Logger.info(
        '[AvoidPeopleGenerator]   😰 stress_level: ${inputConditions['stress_level']}');

    try {
      final requestBody = {
        'userId': userId,
        'name': userName,
        'environment': inputConditions['environment'],
        'important_schedule': inputConditions['important_schedule'],
        'mood_level': inputConditions['mood_level'],
        'stress_level': inputConditions['stress_level'],
        'social_fatigue': inputConditions['social_fatigue'],
        'has_important_decision': inputConditions['has_important_decision'],
        'has_sensitive_conversation':
            inputConditions['has_sensitive_conversation'],
        'has_team_project': inputConditions['has_team_project'],
      };

      Logger.info('[AvoidPeopleGenerator] 📡 API 호출 중...');

      // Edge Function 호출
      final response = await supabase.functions.invoke(
        'fortune-avoid-people',
        body: utf8.encode(jsonEncode(requestBody)),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      // 📥 응답 수신
      Logger.info('[AvoidPeopleGenerator] 📥 API 응답 수신');
      Logger.info('[AvoidPeopleGenerator]   ✅ Status: ${response.status}');

      if (response.status != 200) {
        Logger.error(
            '[AvoidPeopleGenerator] ❌ API 호출 실패: status ${response.status}');
        throw Exception('Edge Function 호출 실패: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;
      Logger.info(
          '[AvoidPeopleGenerator]   📦 Response data keys: ${data.keys.toList()}');

      // 🔄 파싱
      Logger.info('[AvoidPeopleGenerator] 🔄 응답 데이터 파싱 중...');
      final result = _convertToFortuneResult(data, inputConditions);

      Logger.info('[AvoidPeopleGenerator] ✅ 파싱 완료');
      Logger.info('[AvoidPeopleGenerator]   📝 Title: ${result.title}');
      Logger.info('[AvoidPeopleGenerator]   ⭐ Score: ${result.score}');

      return result;
    } catch (e, stackTrace) {
      Logger.error('[AvoidPeopleGenerator] ❌ 피해야할사람 운세 생성 실패', e, stackTrace);
      rethrow;
    }
  }

  /// API 응답을 FortuneResult로 변환
  static FortuneResult _convertToFortuneResult(
    Map<String, dynamic> apiData,
    Map<String, dynamic> inputConditions,
  ) {
    return FortuneResult(
      type: 'avoid_people',
      title: apiData['title'] as String? ?? '피해야 할 사람',
      summary: apiData['summary'] as Map<String, dynamic>? ?? {},
      data: apiData['data'] as Map<String, dynamic>? ?? apiData,
      score: (apiData['score'] as num?)?.toInt() ?? 50,
    );
  }
}
