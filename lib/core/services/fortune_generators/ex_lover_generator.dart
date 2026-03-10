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
    final userName = userProfile?['name'] as String? ??
        user?.userMetadata?['name'] as String? ??
        inputConditions['name'] as String? ??
        'Guest';

    // 📤 API 요청 준비
    Logger.info('[ExLoverGenerator] 📤 API 요청 준비');
    Logger.info('[ExLoverGenerator]   🌐 Edge Function: fortune-ex-lover');
    Logger.info('[ExLoverGenerator]   👤 user_id: $userId');
    Logger.info('[ExLoverGenerator]   💔 name: $userName');

    // ✅ Flutter 입력 필드명 → Edge Function 필드명 매핑
    final timeSinceBreakup = inputConditions['time_since_breakup'] ??
        inputConditions['breakupTime'] ??
        '';
    final exName =
        inputConditions['ex_name'] ?? inputConditions['exPartnerName'] ?? '';
    final exMbti =
        inputConditions['ex_mbti'] ?? inputConditions['exPartnerMbti'] ?? '';
    final exBirthDate = inputConditions['ex_birth_date'] ??
        inputConditions['exPartnerBirthYear'] ??
        '';
    final breakupDetail = inputConditions['breakup_detail'] ??
        inputConditions['detailedStory'] ??
        '';
    final contactStatus = inputConditions['contact_status'] ??
        inputConditions['contactStatus'] ??
        '';
    final breakupInitiator = inputConditions['breakup_initiator'] ??
        inputConditions['breakupInitiator'] ??
        '';
    final coreReason = inputConditions['breakup_reason'] ??
        inputConditions['coreReason'] ??
        '';
    final relationshipDepth = inputConditions['relationshipDepth'] ?? '';
    final primaryGoal = inputConditions['primaryGoal'] ?? 'healing';
    final currentState =
        inputConditions['currentState'] as List<dynamic>? ?? [];
    final goalSpecific =
        inputConditions['goalSpecific'] as Map<String, dynamic>?;

    Logger.info(
        '[ExLoverGenerator]   📅 time_since_breakup: $timeSinceBreakup');
    Logger.info('[ExLoverGenerator]   💭 breakup_detail: $breakupDetail');
    Logger.info('[ExLoverGenerator]   🎯 primaryGoal: $primaryGoal');

    try {
      final requestBody = {
        'fortune_type': 'ex_lover',
        'name': userName,
        // 상대방 정보
        'ex_name': exName,
        'ex_mbti': exMbti,
        'ex_birth_date': exBirthDate,
        // ✅ v2 필수 필드들 (Edge Function 요구사항)
        'primaryGoal': primaryGoal,
        'time_since_breakup': timeSinceBreakup,
        'breakup_initiator': breakupInitiator,
        'relationshipDepth': relationshipDepth,
        'coreReason': coreReason,
        'breakup_detail': breakupDetail,
        'currentState': currentState,
        'contact_status': contactStatus,
        'goalSpecific': goalSpecific,
        // 관계 정보 (하위 호환성)
        'relationship_duration': inputConditions['relationship_duration'],
        // 감정 정보 (하위 호환성)
        'current_emotion': inputConditions['current_emotion'],
        'main_curiosity': inputConditions['main_curiosity'],
        // 추가 정보
        'chat_history': inputConditions['chat_history'],
        // 프리미엄 상태
        'isPremium': inputConditions['isPremium'] ?? false,
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
        Logger.error(
            '[ExLoverGenerator] ❌ API 호출 실패: status ${response.status}');
        throw Exception('Edge Function 호출 실패: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;
      Logger.info(
          '[ExLoverGenerator]   📦 Response data keys: ${data.keys.toList()}');

      // 🔄 파싱
      Logger.info('[ExLoverGenerator] 🔄 응답 데이터 파싱 중...');
      final result = _convertToFortuneResult(data, inputConditions);

      Logger.info('[ExLoverGenerator] ✅ 파싱 완료');
      Logger.info('[ExLoverGenerator]   📝 Title: ${result.title}');
      Logger.info('[ExLoverGenerator]   ⭐ Score: ${result.score}');

      return result;
    } catch (e, stackTrace) {
      Logger.error('❌ [ExLoverGenerator] Failed to generate ex-lover fortune',
          e, stackTrace);
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
          (apiData['overallScore'] as num?)?.toInt() ??
          50,
    );
  }
}
