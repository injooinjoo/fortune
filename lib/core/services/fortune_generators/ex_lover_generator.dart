import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/fortune_result.dart';
import '../../utils/logger.dart';

/// 헤어진 애인 Generator - API 기반 운세 생성
/// 재회 가능성 분석
class ExLoverGenerator {
  /// 헤어진 애인 운세 생성 (Edge Function 호출)
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
    final userName = userProfile?['name'] as String? ?? user?.userMetadata?['name'] as String? ?? inputConditions['name'] as String? ?? 'Guest';

    // 📤 API 요청 준비
    Logger.info('[ExLoverGenerator] 📤 API 요청 준비');
    Logger.info('[ExLoverGenerator]   🌐 Edge Function: fortune-ex-lover');
    Logger.info('[ExLoverGenerator]   👤 user_id: $userId');
    Logger.info('[ExLoverGenerator]   💔 name: $userName');
    Logger.info('[ExLoverGenerator]   📅 relationship_duration: ${inputConditions['relationship_duration']}');
    Logger.info('[ExLoverGenerator]   💭 breakup_reason: ${inputConditions['breakup_reason']}');

    try {
      final requestBody = {
        'fortune_type': 'ex_lover',
        'name': userName,
        'birth_date': inputConditions['birth_date'],
        'gender': inputConditions['gender'],
        'mbti': inputConditions['mbti'],
        'relationship_duration': inputConditions['relationship_duration'],
        'breakup_reason': inputConditions['breakup_reason'],
        'time_since_breakup': inputConditions['time_since_breakup'],
        'current_feeling': inputConditions['current_feeling'],
        'still_in_contact': inputConditions['still_in_contact'],
        'has_unresolved_feelings': inputConditions['has_unresolved_feelings'],
      };

      Logger.info('[ExLoverGenerator] 📡 API 호출 중...');

      // Edge Function 호출
      final response = await supabase.functions.invoke(
        'fortune-ex-lover',
        body: utf8.encode(jsonEncode(requestBody)),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      // 📥 응답 수신
      Logger.info('[ExLoverGenerator] 📥 API 응답 수신');
      Logger.info('[ExLoverGenerator]   ✅ Status: ${response.status}');

      if (response.status != 200) {
        Logger.error('[ExLoverGenerator] ❌ API 호출 실패: status ${response.status}');
        throw Exception('Edge Function 호출 실패: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;
      Logger.info('[ExLoverGenerator]   📦 Response data keys: ${data.keys.toList()}');

      // 🔄 파싱
      Logger.info('[ExLoverGenerator] 🔄 응답 데이터 파싱 중...');
      final result = _convertToFortuneResult(data, inputConditions);

      Logger.info('[ExLoverGenerator] ✅ 파싱 완료');
      Logger.info('[ExLoverGenerator]   📝 Title: ${result.title}');
      Logger.info('[ExLoverGenerator]   ⭐ Score: ${result.score}');

      return result;
    } catch (e, stackTrace) {
      Logger.error('❌ [ExLoverGenerator] Failed to generate ex-lover fortune', e, stackTrace);
      rethrow;
    }
  }

  /// API 응답을 FortuneResult로 변환
  static FortuneResult _convertToFortuneResult(
    Map<String, dynamic> apiData,
    Map<String, dynamic> inputConditions,
  ) {
    return FortuneResult(
      type: 'ex_lover',
      title: apiData['title'] as String? ?? '헤어진 애인',
      summary: apiData['summary'] as Map<String, dynamic>? ?? {},
      data: apiData['data'] as Map<String, dynamic>? ?? apiData,
      score: (apiData['score'] as num?)?.toInt() ??
             (apiData['overallScore'] as num?)?.toInt() ?? 50,
    );
  }
}
