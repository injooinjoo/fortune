import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/fortune_result.dart';
import '../../utils/logger.dart';

/// 시험 운세 생성기
///
/// Edge Function을 통해 시험 운세를 생성합니다.
/// - 시험 종류, 예정일
/// - 준비 기간, 자신감, 난이도 평가
class ExamGenerator {
  /// 시험 운세 생성
  ///
  /// **input_conditions 형식**:
  /// ```json
  /// {
  ///   "exam_type": "수능",  // 수능, 토익, 토플, 공무원, 자격증 등
  ///   "exam_date": "2025-03-15",
  ///   "study_period": "3개월",  // 1주일, 2주일, 1개월, 3개월, 6개월, 1년 이상
  ///   "confidence": "보통",  // 매우 불안, 불안, 보통, 자신있음, 매우 자신있음
  ///   "difficulty": "보통"  // 매우 쉬움, 쉬움, 보통, 어려움, 매우 어려움
  /// }
  /// ```
  static Future<FortuneResult> generate(
    Map<String, dynamic> inputConditions,
    SupabaseClient supabase, {
    bool isPremium = false,
  }) async {
    final userId = supabase.auth.currentUser?.id ?? 'unknown';

    // camelCase 또는 snake_case 지원 (설문 매핑 호환성)
    final examType =
        inputConditions['exam_type'] ?? inputConditions['examType'] ?? '';
    final examDate =
        inputConditions['exam_date'] ?? inputConditions['examDate'] ?? '';
    final studyPeriod =
        inputConditions['study_period'] ?? inputConditions['studyPeriod'] ?? '';
    final confidence =
        inputConditions['confidence'] ?? inputConditions['preparation'] ?? '보통';
    final difficulty = inputConditions['difficulty'] ?? '보통';
    final examCategory = inputConditions['exam_category'] ??
        inputConditions['examCategory'] ??
        '';
    final preparationStatus = inputConditions['preparation_status'] ??
        inputConditions['preparationStatus'] ??
        inputConditions['preparation'] ??
        '';

    // 📤 API 요청 준비
    Logger.info('[ExamGenerator] 📤 API 요청 준비');
    Logger.info('[ExamGenerator]   🌐 Edge Function: fortune-exam');
    Logger.info('[ExamGenerator]   👤 user_id: $userId');
    Logger.info('[ExamGenerator]   📝 exam_type: $examType');
    Logger.info('[ExamGenerator]   📅 exam_date: $examDate');
    Logger.info('[ExamGenerator]   📚 study_period: $studyPeriod');
    Logger.info('[ExamGenerator]   💪 confidence: $confidence');

    try {
      final requestBody = {
        'fortune_type': 'exam',
        'exam_type': examType,
        'exam_date': examDate,
        'study_period': studyPeriod,
        'confidence': confidence,
        'difficulty': difficulty,
        // 리뉴얼 필드
        'exam_category': examCategory,
        if (inputConditions['exam_sub_type'] != null)
          'exam_sub_type': inputConditions['exam_sub_type'],
        if (inputConditions['target_score'] != null)
          'target_score': inputConditions['target_score'],
        'preparation_status': preparationStatus,
        'time_point': inputConditions['time_point'],
        'isPremium': isPremium,
      };

      Logger.info('[ExamGenerator] 📡 API 호출 중...');

      // Edge Function 호출
      final response = await supabase.functions.invoke(
        'fortune-exam',
        body: requestBody,
      );

      // 📥 응답 수신
      Logger.info('[ExamGenerator] 📥 API 응답 수신');
      Logger.info('[ExamGenerator]   ✅ Status: ${response.status}');

      if (response.status != 200) {
        Logger.error('[ExamGenerator] ❌ API 호출 실패: ${response.data}');
        throw Exception('Failed to generate exam fortune: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      Logger.info(
          '[ExamGenerator]   📦 Response data keys: ${data.keys.toList()}');

      // 🔍 응답 데이터 상세 로깅
      final fortuneData = data['data'] as Map<String, dynamic>? ?? {};
      Logger.info(
          '[ExamGenerator]   📋 Fortune data keys: ${fortuneData.keys.toList()}');
      Logger.info(
          '[ExamGenerator]   🔍 pass_possibility: ${fortuneData['pass_possibility']}');
      Logger.info(
          '[ExamGenerator]   🔍 focus_subject: ${fortuneData['focus_subject']}');
      Logger.info(
          '[ExamGenerator]   🔍 study_methods: ${fortuneData['study_methods']}');
      Logger.info('[ExamGenerator]   🔍 cautions: ${fortuneData['cautions']}');
      Logger.info(
          '[ExamGenerator]   🔍 dday_advice: ${fortuneData['dday_advice']}');
      Logger.info(
          '[ExamGenerator]   🔍 positive_message: ${fortuneData['positive_message']}');

      // 🔄 파싱
      Logger.info('[ExamGenerator] 🔄 응답 데이터 파싱 중...');
      final result = _convertToFortuneResult(data, inputConditions, isPremium);

      Logger.info('[ExamGenerator] ✅ 파싱 완료');
      Logger.info('[ExamGenerator]   📝 Title: ${result.title}');
      Logger.info('[ExamGenerator]   ⭐ Score: ${result.score}');

      return result;
    } catch (e, stackTrace) {
      Logger.error('[ExamGenerator] ❌ 시험운 생성 실패', e, stackTrace);
      rethrow;
    }
  }

  /// Edge Function 응답을 FortuneResult로 변환
  static FortuneResult _convertToFortuneResult(
    Map<String, dynamic> data,
    Map<String, dynamic> inputConditions,
    bool isPremium,
  ) {
    final fortuneData = data['data'] as Map<String, dynamic>? ?? {};
    final score = (fortuneData['score'] as num?)?.toInt();

    // 🎯 토큰 소비형 모델: 블러 처리 제거

    return FortuneResult(
      type: 'exam',
      title: fortuneData['title'] as String? ?? '시험 운세',
      summary: {
        'score': score,
        'overall_fortune': fortuneData['overall_fortune'],
        'exam_info': {
          'category': inputConditions['exam_category'],
          'type': inputConditions['exam_type'],
          'date': inputConditions['exam_date'],
          'time_point': inputConditions['time_point'],
        },
      },
      data: fortuneData,
      score: score,
      createdAt: DateTime.now(),
    );
  }
}
