import 'dart:convert';
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
    SupabaseClient supabase,
  ) async {
    final userId = supabase.auth.currentUser?.id ?? 'unknown';

    // 📤 API 요청 준비
    Logger.info('[ExamGenerator] 📤 API 요청 준비');
    Logger.info('[ExamGenerator]   🌐 Edge Function: generate-fortune');
    Logger.info('[ExamGenerator]   👤 user_id: $userId');
    Logger.info('[ExamGenerator]   📝 exam_type: ${inputConditions['exam_type']}');
    Logger.info('[ExamGenerator]   📅 exam_date: ${inputConditions['exam_date']}');
    Logger.info('[ExamGenerator]   📚 study_period: ${inputConditions['study_period']}');
    Logger.info('[ExamGenerator]   💪 confidence: ${inputConditions['confidence']}');

    try {
      final requestBody = {
        'fortune_type': 'exam',
        'exam_type': inputConditions['exam_type'],
        'exam_date': inputConditions['exam_date'],
        'study_period': inputConditions['study_period'],
        'confidence': inputConditions['confidence'],
        'difficulty': inputConditions['difficulty'],
      };

      Logger.info('[ExamGenerator] 📡 API 호출 중...');

      // Edge Function 호출
      final response = await supabase.functions.invoke(
        'generate-fortune',
        body: utf8.encode(jsonEncode(requestBody)),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      // 📥 응답 수신
      Logger.info('[ExamGenerator] 📥 API 응답 수신');
      Logger.info('[ExamGenerator]   ✅ Status: ${response.status}');

      if (response.status != 200) {
        Logger.error('[ExamGenerator] ❌ API 호출 실패: ${response.data}');
        throw Exception('Failed to generate exam fortune: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      Logger.info('[ExamGenerator]   📦 Response data keys: ${data.keys.toList()}');

      // 🔄 파싱
      Logger.info('[ExamGenerator] 🔄 응답 데이터 파싱 중...');
      final result = _convertToFortuneResult(data, inputConditions);

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
  ) {
    final fortuneData = data['fortune_data'] as Map<String, dynamic>? ?? {};
    final content = data['content'] as String? ?? '';
    final summary = data['summary'] as String? ?? '';
    final score = data['score'] as int?;

    return FortuneResult(
      type: 'exam',
      title: '시험 운세',
      summary: {
        'message': summary,
        'score': score,
        'exam_info': {
          'type': inputConditions['exam_type'],
          'date': inputConditions['exam_date'],
          'confidence': inputConditions['confidence'],
        },
      },
      data: {
        'content': content,
        'fortune_data': fortuneData,
        'exam_type': inputConditions['exam_type'],
        'exam_date': inputConditions['exam_date'],
        'study_period': inputConditions['study_period'],
        'confidence': inputConditions['confidence'],
        'difficulty': inputConditions['difficulty'],
      },
      score: score,
      createdAt: DateTime.now(),
    );
  }
}
