import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/fortune_result.dart';
import '../../../features/fortune/domain/models/conditions/exercise_fortune_conditions.dart';
import '../../utils/logger.dart';

/// 운동운세 생성기
///
/// Edge Function을 직접 호출하여 운동 가이드를 생성
/// 종목별 전문 루틴 (헬스/요가/러닝/수영 등) 제공
class ExerciseGenerator {
  /// 운동운세 생성
  ///
  /// [conditions]: 운동운세 조건
  /// [supabase]: Supabase 클라이언트
  /// [isPremium]: 프리미엄 사용자 여부
  static Future<FortuneResult> generate({
    required ExerciseFortuneConditions conditions,
    required SupabaseClient supabase,
    required bool isPremium,
  }) async {
    Logger.info('[ExerciseGenerator] 운동운세 생성 시작');
    Logger.info('   - sportType: ${conditions.sportType}');
    Logger.info('   - exerciseGoal: ${conditions.exerciseGoal}');
    Logger.info('   - isPremium: $isPremium');

    try {
      // 사용자 ID 가져오기
      final userId = supabase.auth.currentUser?.id ?? 'anonymous';

      // 사용자 프로필에서 사주 정보 가져오기 (개인화용)
      Map<String, dynamic>? userProfile;
      if (userId != 'anonymous') {
        try {
          userProfile = await supabase
              .from('user_profiles')
              .select('birth_date, birth_time, gender, name')
              .eq('id', userId)
              .maybeSingle();
        } catch (e) {
          Logger.warning('[ExerciseGenerator] 사용자 프로필 조회 실패: $e');
        }
      }

      // API Payload 구성
      final payload = {
        ...conditions.buildAPIPayload(),
        'isPremium': isPremium,
        'userId': userId,
        // 개인화 데이터 (사주 기반 운동 추천용)
        if (userProfile != null) ...{
          if (userProfile['birth_date'] != null)
            'birthDate': userProfile['birth_date'],
          if (userProfile['birth_time'] != null)
            'birthTime': userProfile['birth_time'],
          if (userProfile['gender'] != null)
            'gender': userProfile['gender'],
          if (userProfile['name'] != null)
            'name': userProfile['name'],
        },
      };

      Logger.info('[ExerciseGenerator] API 호출 시작');
      Logger.info('   - userId: $userId');
      Logger.info('   - payload keys: ${payload.keys.join(', ')}');

      // Edge Function 호출
      final response = await supabase.functions.invoke(
        'fortune-exercise',
        body: payload,
      );

      if (response.status != 200) {
        throw Exception('API 호출 실패: ${response.status}');
      }

      // Null Safety: 응답 데이터 검증
      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) {
        throw Exception('API 응답 데이터가 없습니다');
      }

      // success 필드 확인
      if (responseData['success'] != true) {
        throw Exception(responseData['error'] ?? 'API 응답 실패');
      }

      final data = responseData['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('API 응답에서 data 필드를 찾을 수 없습니다');
      }

      // 프리미엄이 아니면 블러 섹션 설정
      // 무료: recommendedExercise (추천 운동)
      // 프리미엄: todayRoutine, weeklyPlan, injuryPrevention
      final blurredSections = isPremium
          ? <String>[]
          : [
              'todayRoutine',
              'weeklyPlan',
              'injuryPrevention',
            ];

      // 점수 추출 (추천 운동 적합도)
      final fitnessScore = data['fitnessScore'] as int? ?? 75;

      // 추천 운동 정보 추출
      final recommendedExercise = data['recommendedExercise'] as Map<String, dynamic>?;
      final exerciseName = recommendedExercise?['name'] as String? ?? '오늘의 운동';

      // 종목별 emoji 설정
      final sportEmoji = _getSportEmoji(conditions.sportType);

      final result = FortuneResult(
        id: 'exercise-${DateTime.now().millisecondsSinceEpoch}',
        type: 'exercise',
        title: '오늘의 운동 - $exerciseName',
        summary: {
          'score': fitnessScore,
          'message': recommendedExercise?['reason'] as String? ?? '오늘도 건강한 하루 되세요!',
          'emoji': sportEmoji,
          'sport_type': conditions.sportType,
          'exercise_goal': conditions.exerciseGoal,
        },
        data: data,
        score: fitnessScore,
        createdAt: DateTime.now(),
        isBlurred: !isPremium,
        blurredSections: blurredSections,
      );

      Logger.info('[ExerciseGenerator] 운동운세 생성 완료');
      Logger.info('   - fortuneId: ${result.id}');
      Logger.info('   - isBlurred: ${result.isBlurred}');
      Logger.info('   - sportType: ${conditions.sportType}');

      return result;
    } catch (e, stackTrace) {
      Logger.error('[ExerciseGenerator] 운동운세 생성 실패', e, stackTrace);
      rethrow;
    }
  }

  /// 종목별 Emoji 반환
  static String _getSportEmoji(String sportType) {
    switch (sportType.toLowerCase()) {
      case 'gym':
        return '💪';
      case 'yoga':
        return '🧘';
      case 'running':
        return '🏃';
      case 'swimming':
        return '🏊';
      case 'cycling':
        return '🚴';
      case 'climbing':
        return '🧗';
      case 'martial_arts':
        return '🥊';
      case 'tennis':
        return '🎾';
      case 'golf':
        return '⛳';
      case 'pilates':
        return '🤸';
      case 'crossfit':
        return '🏋️';
      case 'dance':
        return '💃';
      default:
        return '🏃';
    }
  }
}
