import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/fortune_result.dart';
import '../../utils/logger.dart';

/// 커리어 운세 생성기
///
/// Edge Function을 통해 커리어 운세를 생성합니다.
/// - 다양한 커리어 타입: career-future, career-seeker, career-change, startup-career
/// - 현재 직무, 목표, 경력 경로, 기술 분석
class CareerGenerator {
  /// 커리어 운세 생성
  ///
  /// **input_conditions 형식**:
  /// ```json
  /// {
  ///   "career_type": "career-future",  // career-future, career-seeker, career-change, startup-career
  ///   "current_role": "프론트엔드 개발자",
  ///   "goal": "시니어 개발자",
  ///   "time_horizon": "3년 후",  // 1년 후, 3년 후, 5년 후, 10년 후
  ///   "career_path": "전문가 (기술 심화)",  // 전문가, 관리자, 창업가, 컨설턴트, 임원
  ///   "selected_skills": ["기술 전문성", "리더십", "커뮤니케이션"],
  ///
  ///   // career-seeker 추가 필드
  ///   "desired_industry": "IT/소프트웨어",
  ///   "experience_level": "신입",  // 신입, 경력 1-3년, 경력 3-5년, 경력 5년+
  ///   "education": "대졸",
  ///
  ///   // career-change 추가 필드
  ///   "current_industry": "금융",
  ///   "target_industry": "IT",
  ///   "change_reason": "더 나은 성장 기회",
  ///
  ///   // startup-career 추가 필드
  ///   "startup_stage": "초기 단계",  // 아이디어, 초기, 성장, 확장
  ///   "team_size": "5명 미만",
  ///   "funding_status": "자금 없음",  // 자금 없음, 시드, 시리즈 A, 시리즈 B+
  /// }
  /// ```
  static Future<FortuneResult> generate(
    Map<String, dynamic> inputConditions,
    SupabaseClient supabase,
  ) async {
    final userId = supabase.auth.currentUser?.id ?? 'unknown';
    final careerType = inputConditions['career_type'] as String? ?? 'career-future';

    // 📤 API 요청 준비
    Logger.info('[CareerGenerator] 📤 API 요청 준비');
    Logger.info('[CareerGenerator]   🌐 Edge Function: fortune-career');
    Logger.info('[CareerGenerator]   👤 user_id: $userId');
    Logger.info('[CareerGenerator]   💼 career_type: $careerType');
    Logger.info('[CareerGenerator]   🎯 goal: ${inputConditions['goal']}');
    Logger.info('[CareerGenerator]   📅 time_horizon: ${inputConditions['time_horizon']}');

    try {
      final requestBody = {
        'fortune_type': careerType.replaceAll('-', '_'),
        'current_role': inputConditions['current_role'],
        'goal': inputConditions['goal'],
        'time_horizon': inputConditions['time_horizon'],
        'career_path': inputConditions['career_path'],
        'selected_skills': inputConditions['selected_skills'],
        // career-seeker 관련
        if (inputConditions['desired_industry'] != null)
          'desired_industry': inputConditions['desired_industry'],
        if (inputConditions['experience_level'] != null)
          'experience_level': inputConditions['experience_level'],
        if (inputConditions['education'] != null)
          'education': inputConditions['education'],
        // career-change 관련
        if (inputConditions['current_industry'] != null)
          'current_industry': inputConditions['current_industry'],
        if (inputConditions['target_industry'] != null)
          'target_industry': inputConditions['target_industry'],
        if (inputConditions['change_reason'] != null)
          'change_reason': inputConditions['change_reason'],
        // startup-career 관련
        if (inputConditions['startup_stage'] != null)
          'startup_stage': inputConditions['startup_stage'],
        if (inputConditions['team_size'] != null)
          'team_size': inputConditions['team_size'],
        if (inputConditions['funding_status'] != null)
          'funding_status': inputConditions['funding_status'],
      };

      Logger.info('[CareerGenerator] 📡 API 호출 중...');

      // Edge Function 호출
      final response = await supabase.functions.invoke(
        'fortune-career',
        body: requestBody,
      );

      // 📥 응답 수신
      Logger.info('[CareerGenerator] 📥 API 응답 수신');
      Logger.info('[CareerGenerator]   ✅ Status: ${response.status}');

      if (response.status != 200) {
        Logger.error('[CareerGenerator] ❌ API 호출 실패: ${response.data}');
        throw Exception('Failed to generate career fortune: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      Logger.info('[CareerGenerator]   📦 Response data keys: ${data.keys.toList()}');

      // 🔄 파싱
      Logger.info('[CareerGenerator] 🔄 응답 데이터 파싱 중...');
      final result = _convertToFortuneResult(data, inputConditions, careerType);

      Logger.info('[CareerGenerator] ✅ 파싱 완료');
      Logger.info('[CareerGenerator]   📝 Title: ${result.title}');
      Logger.info('[CareerGenerator]   ⭐ Score: ${result.score}');

      return result;
    } catch (e, stackTrace) {
      Logger.error('[CareerGenerator] ❌ 직업운 생성 실패', e, stackTrace);
      rethrow;
    }
  }

  /// Edge Function 응답을 FortuneResult로 변환
  static FortuneResult _convertToFortuneResult(
    Map<String, dynamic> data,
    Map<String, dynamic> inputConditions,
    String careerType,
  ) {
    final fortuneData = data['fortune_data'] as Map<String, dynamic>? ?? {};
    final content = data['content'] as String? ?? '';
    final summary = data['summary'] as String? ?? '';
    final score = data['score'] as int?;

    return FortuneResult(
      type: careerType,
      title: _getCareerTitle(careerType),
      summary: {
        'message': summary,
        'score': score,
        'career_info': {
          'current_role': inputConditions['current_role'],
          'goal': inputConditions['goal'],
          'time_horizon': inputConditions['time_horizon'],
        },
      },
      data: {
        'content': content,
        'fortune_data': fortuneData,
        'current_role': inputConditions['current_role'],
        'goal': inputConditions['goal'],
        'time_horizon': inputConditions['time_horizon'],
        'career_path': inputConditions['career_path'],
        'selected_skills': inputConditions['selected_skills'],
      },
      score: score,
      createdAt: DateTime.now(),
    );
  }

  /// 커리어 타입별 제목
  static String _getCareerTitle(String careerType) {
    switch (careerType) {
      case 'career-future':
        return '커리어 미래 운세';
      case 'career-seeker':
        return '구직자 커리어 운세';
      case 'career-change':
        return '이직 커리어 운세';
      case 'startup-career':
        return '스타트업 커리어 운세';
      default:
        return '커리어 운세';
    }
  }
}
