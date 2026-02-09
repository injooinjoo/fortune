import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/fortune_result.dart';
import '../../../features/fortune/domain/models/conditions/health_fortune_conditions.dart';
import '../../../features/chat/data/services/survey_storage_service.dart';
import '../../utils/logger.dart';

/// 건강운세 생성기
///
/// Edge Function을 직접 호출하여 건강운세를 생성
/// 사주 오행 분석 + 이전 설문 비교를 통한 개인화된 건강 조언 제공
class HealthGenerator {
  /// 건강운세 생성
  ///
  /// [conditions]: 건강운세 조건
  /// [supabase]: Supabase 클라이언트
  /// [isPremium]: 프리미엄 사용자 여부
  static Future<FortuneResult> generate({
    required HealthFortuneConditions conditions,
    required SupabaseClient supabase,
    required bool isPremium,
  }) async {
    Logger.info('[HealthGenerator] 건강운세 생성 시작');
    Logger.info('   - isPremium: $isPremium');

    try {
      // 사용자 ID 가져오기
      final userId = supabase.auth.currentUser?.id ?? 'anonymous';

      // ✅ 사주/설문 데이터 조회 (개인화용)
      final surveyService = SurveyStorageService(supabase: supabase);
      final healthContext = await surveyService.getHealthFortuneContext();
      Logger.info('[HealthGenerator] 개인화 컨텍스트 로드');
      Logger.info('   - birthDate: ${healthContext['birthDate']}');
      Logger.info('   - sajuData: ${healthContext['sajuData'] != null ? '있음' : '없음'}');
      Logger.info('   - previousSurvey: ${healthContext['previousSurvey'] != null ? '있음' : '없음'}');

      // API Payload 구성 (기존 + 개인화 데이터)
      final payload = {
        ...conditions.buildAPIPayload(),
        'isPremium': isPremium,
        // ✅ 신규: 사주 오행 분석용
        if (healthContext['birthDate'] != null)
          'birthDate': healthContext['birthDate'],
        if (healthContext['birthTime'] != null)
          'birthTime': healthContext['birthTime'],
        if (healthContext['sajuData'] != null)
          'sajuData': healthContext['sajuData'],
        // ✅ 신규: 이전 설문 비교용
        if (healthContext['previousSurvey'] != null)
          'previousSurvey': healthContext['previousSurvey'],
      };

      Logger.info('[HealthGenerator] API 호출 시작');
      Logger.info('   - userId: $userId');

      // Edge Function 호출
      final response = await supabase.functions.invoke(
        'fortune-health',
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
      final data = responseData['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('API 응답에서 data 필드를 찾을 수 없습니다');
      }

      // 🎯 토큰 소비형 모델: 블러 처리 제거

      // 점수 및 메시지 추출 (안전한 타입 처리)
      final healthScore = data['score'] as int? ?? 75;

      // overall_health가 String 또는 Map일 수 있음
      String overallHealth;
      final overallHealthRaw = data['overall_health'];
      if (overallHealthRaw is String) {
        overallHealth = overallHealthRaw;
      } else if (overallHealthRaw is Map) {
        // Map인 경우 첫 번째 값 사용 또는 전체 내용 조합
        overallHealth = (overallHealthRaw as Map<String, dynamic>).values.join(' ');
      } else {
        overallHealth = '건강하십니다.';
      }

      // ✅ 오행 조언 데이터 로깅
      final elementAdvice = data['element_advice'] as Map<String, dynamic>?;
      final personalizedFeedback = data['personalized_feedback'] as Map<String, dynamic>?;
      if (elementAdvice != null) {
        Logger.info('[HealthGenerator] 오행 조언: 부족=${elementAdvice['lacking_element']}, 강함=${elementAdvice['dominant_element']}');
      }
      if (personalizedFeedback != null) {
        final improvements = (personalizedFeedback['improvements'] as List?)?.length ?? 0;
        final concerns = (personalizedFeedback['concerns'] as List?)?.length ?? 0;
        Logger.info('[HealthGenerator] 개인화 피드백: 개선 $improvements개, 주의 $concerns개');
      }

      final result = FortuneResult(
        id: 'health-${DateTime.now().millisecondsSinceEpoch}',
        type: 'health',
        title: '건강운세',
        summary: {
          'score': healthScore,
          'message': overallHealth,
          'emoji': healthScore >= 80 ? '💚' : healthScore >= 60 ? '💛' : '🧡',
          // ✅ 오행 정보 요약 추가
          if (elementAdvice != null) ...{
            'lacking_element': elementAdvice['lacking_element'],
            'dominant_element': elementAdvice['dominant_element'],
          },
        },
        data: data,
        score: healthScore,
        createdAt: DateTime.now(),
      );

      // ✅ 현재 설문 저장 (다음 비교용)
      _saveCurrentSurvey(surveyService, conditions, userId);

      Logger.info('[HealthGenerator] 건강운세 생성 완료');
      Logger.info('   - fortuneId: ${result.id}');

      return result;
    } catch (e, stackTrace) {
      Logger.error('[HealthGenerator] 건강운세 생성 실패', e, stackTrace);
      rethrow;
    }
  }

  /// 현재 설문 저장 (비동기, 실패해도 운세 결과에 영향 없음)
  static void _saveCurrentSurvey(
    SurveyStorageService surveyService,
    HealthFortuneConditions conditions,
    String userId,
  ) {
    // 비동기로 저장 (await 없이 fire-and-forget)
    surveyService
        .saveSurvey(HealthSurveyData(
          userId: userId,
          currentCondition: conditions.healthConcern,
          concernedBodyParts: conditions.symptoms,
          sleepQuality: conditions.sleepQuality,
          exerciseFrequency: conditions.exerciseFrequency,
          stressLevel: conditions.stressLevel,
          mealRegularity: conditions.mealRegularity,
          hasChronicCondition: conditions.hasChronicCondition,
          chronicCondition: conditions.chronicCondition,
        ))
        .then((_) => Logger.info('[HealthGenerator] 설문 저장 완료'))
        .catchError((e) => Logger.warning('[HealthGenerator] 설문 저장 실패 (무시): $e'));
  }
}
