import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/fortune_result.dart';
import '../../utils/logger.dart';

/// 재능 발견 운세 생성기
///
/// Edge Function을 통해 재능 발견 운세를 생성합니다.
class TalentGenerator {
  /// 재능 발견 운세 생성
  ///
  /// **input_conditions 형식**:
  /// ```json
  /// {
  ///   "birth_date": "1988-09-05",
  ///   "birth_time": "12:00",
  ///   "gender": "male",
  ///   "birth_city": "서울",  // 선택
  ///   "current_occupation": "프론트엔드 개발자",  // 선택
  ///   "concern_areas": ["커리어 발전", "창업"],
  ///   "interest_areas": ["기술", "디자인"],
  ///   "self_strengths": "빠른 실행력",  // 선택
  ///   "self_weaknesses": "우유부단함",  // 선택
  ///   "work_style": "혼자 집중해서",
  ///   "energy_source": "혼자 있기",
  ///   "problem_solving": "논리적으로 분석",
  ///   "preferred_role": "창의적 기획"
  /// }
  /// ```
  static Future<FortuneResult> generate(
    Map<String, dynamic> inputConditions,
    SupabaseClient supabase,
  ) async {
    final userId = supabase.auth.currentUser?.id ?? 'unknown';

    // 📤 API 요청 준비
    Logger.info('[TalentGenerator] 📤 API 요청 준비');
    Logger.info('[TalentGenerator]   🌐 Edge Function: fortune-talent');
    Logger.info('[TalentGenerator]   👤 user_id: $userId');
    Logger.info(
        '[TalentGenerator]   🎯 concern_areas: ${inputConditions['concern_areas']}');
    Logger.info(
        '[TalentGenerator]   💡 interest_areas: ${inputConditions['interest_areas']}');

    try {
      // TalentInputData를 Edge Function 형식으로 변환
      final requestBody = {
        'talentArea':
            (inputConditions['concern_areas'] as List<dynamic>?)?.first ??
                '커리어 발전',
        'currentSkills': [
          if (inputConditions['current_occupation'] != null)
            inputConditions['current_occupation'],
          if (inputConditions['self_strengths'] != null)
            inputConditions['self_strengths'],
          ...?inputConditions['interest_areas'],
        ],
        'goals':
            (inputConditions['concern_areas'] as List<dynamic>?)?.join(', ') ??
                '재능 발견',
        'experience': inputConditions['current_occupation'] ?? '경험 없음',
        'timeAvailable': inputConditions['work_style'] ?? '보통',
        'challenges': [
          if (inputConditions['self_weaknesses'] != null)
            inputConditions['self_weaknesses'],
          ...?inputConditions['concern_areas'],
        ],
        'userId': userId,
        'isPremium': inputConditions['isPremium'] ?? false,
      };

      Logger.info('[TalentGenerator] 📡 API 호출 중...');

      // Edge Function 호출
      final response = await supabase.functions.invoke(
        'fortune-talent',
        body: jsonEncode(requestBody),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      // 📥 응답 수신
      Logger.info('[TalentGenerator] 📥 API 응답 수신');
      Logger.info('[TalentGenerator]   ✅ Status: ${response.status}');

      if (response.status != 200) {
        Logger.error('[TalentGenerator] ❌ API 호출 실패: ${response.data}');
        throw Exception('Failed to generate talent fortune: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      Logger.info(
          '[TalentGenerator]   📦 Response data keys: ${data.keys.toList()}');

      // 🔄 파싱
      Logger.info('[TalentGenerator] 🔄 응답 데이터 파싱 중...');
      final result = _convertToFortuneResult(data, inputConditions);

      Logger.info('[TalentGenerator] ✅ 파싱 완료');
      Logger.info('[TalentGenerator]   📝 Title: ${result.title}');
      Logger.info('[TalentGenerator]   ⭐ Score: ${result.score}');

      return result;
    } catch (e, stackTrace) {
      Logger.error('[TalentGenerator] ❌ 재능 발견 운세 생성 실패', e, stackTrace);
      rethrow;
    }
  }

  /// Edge Function 응답을 FortuneResult로 변환
  static FortuneResult _convertToFortuneResult(
    Map<String, dynamic> data,
    Map<String, dynamic> inputConditions,
  ) {
    final fortuneData = data['fortune'] as Map<String, dynamic>? ?? {};
    final overallScore = fortuneData['overallScore'] as int? ?? 70;
    final content = fortuneData['content'] as String? ?? '';
    final description = fortuneData['description'] as String? ?? '';

    return FortuneResult(
      type: 'talent',
      title: '재능 발견 운세',
      summary: {
        'message': content,
        'score': overallScore,
        'talent_info': {
          'concern_areas': inputConditions['concern_areas'],
          'interest_areas': inputConditions['interest_areas'],
          'work_style': inputConditions['work_style'],
        },
      },
      data: {
        'content': content,
        'description': description,
        'fortune_data': fortuneData,
        'hexagonScores': fortuneData['hexagonScores'] ?? {},
        'talentInsights': fortuneData['talentInsights'] ?? [],
        'weeklyPlan': fortuneData['weeklyPlan'] ?? [],
        'luckyItems': fortuneData['luckyItems'] ?? {},
        'cached': data['cached'] ?? false,
        'tokensUsed': data['tokensUsed'] ?? 0,
      },
      score: overallScore,
      createdAt: DateTime.now(),
    );
  }
}
