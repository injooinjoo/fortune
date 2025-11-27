import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/models.dart';

/// 심리테스트 Repository
class PsychologyTestRepository {
  final SupabaseClient _supabase;

  PsychologyTestRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// 심리테스트 상세 조회 (질문, 선택지, 결과 포함)
  Future<TrendPsychologyTest?> getTestById(String testId) async {
    try {
      // 테스트 기본 정보
      final testResponse = await _supabase
          .from('psychology_tests')
          .select()
          .eq('id', testId)
          .single();

      // 질문 조회
      final questionsResponse = await _supabase
          .from('psychology_test_questions')
          .select()
          .eq('test_id', testId)
          .order('question_order');

      // 각 질문의 선택지 조회
      final questions = <TrendPsychologyQuestion>[];
      for (final qJson in questionsResponse) {
        final optionsResponse = await _supabase
            .from('psychology_test_options')
            .select()
            .eq('question_id', qJson['id'])
            .order('option_order');

        final options = (optionsResponse as List)
            .map((o) => TrendPsychologyOption(
                  id: o['id'],
                  label: o['label'],
                  imageUrl: o['image_url'],
                  scoreMap: Map<String, int>.from(o['score_map'] ?? {}),
                  optionOrder: o['option_order'] ?? 0,
                ))
            .toList();

        questions.add(TrendPsychologyQuestion(
          id: qJson['id'],
          questionOrder: qJson['question_order'],
          questionText: qJson['question_text'],
          imageUrl: qJson['image_url'],
          options: options,
        ));
      }

      // 결과 유형 조회
      final resultsResponse = await _supabase
          .from('psychology_test_results')
          .select()
          .eq('test_id', testId);

      final possibleResults = (resultsResponse as List)
          .map((r) => TrendPsychologyResult(
                id: r['id'],
                resultCode: r['result_code'],
                title: r['title'],
                description: r['description'],
                imageUrl: r['image_url'],
                characteristics:
                    List<String>.from(r['characteristics'] ?? []),
                compatibleWith: r['compatible_with'],
                incompatibleWith: r['incompatible_with'],
                additionalInfo:
                    Map<String, dynamic>.from(r['additional_info'] ?? {}),
                selectionCount: r['selection_count'] ?? 0,
              ))
          .toList();

      return TrendPsychologyTest(
        id: testResponse['id'],
        contentId: testResponse['content_id'],
        resultType: PsychologyResultType.values.firstWhere(
          (t) => t.name == testResponse['result_type'],
          orElse: () => PsychologyResultType.custom,
        ),
        description: testResponse['description'],
        questionCount: testResponse['question_count'] ?? questions.length,
        estimatedMinutes: testResponse['estimated_minutes'] ?? 5,
        useLlmAnalysis: testResponse['use_llm_analysis'] ?? false,
        questions: questions,
        possibleResults: possibleResults,
        createdAt: testResponse['created_at'] != null
            ? DateTime.parse(testResponse['created_at'])
            : null,
      );
    } catch (e) {
      debugPrint('❌ [PsychologyTestRepository] getTestById error: $e');
      return null;
    }
  }

  /// content_id로 테스트 조회
  Future<TrendPsychologyTest?> getTestByContentId(String contentId) async {
    try {
      final testResponse = await _supabase
          .from('psychology_tests')
          .select('id')
          .eq('content_id', contentId)
          .single();

      return getTestById(testResponse['id']);
    } catch (e) {
      debugPrint('❌ [PsychologyTestRepository] getTestByContentId error: $e');
      return null;
    }
  }

  /// 테스트 결과 계산
  TrendPsychologyResult calculateResult(
    TrendPsychologyTest test,
    Map<String, String> answers,
  ) {
    // 각 결과 유형별 점수 집계
    final scores = <String, int>{};

    for (final question in test.questions) {
      final selectedOptionId = answers[question.id];
      if (selectedOptionId == null) continue;

      final selectedOption = question.options.firstWhere(
        (o) => o.id == selectedOptionId,
        orElse: () => question.options.first,
      );

      for (final entry in selectedOption.scoreMap.entries) {
        scores[entry.key] = (scores[entry.key] ?? 0) + entry.value;
      }
    }

    // 최고 점수 결과 찾기
    String? winningResultId;
    int maxScore = -1;

    for (final entry in scores.entries) {
      if (entry.value > maxScore) {
        maxScore = entry.value;
        winningResultId = entry.key;
      }
    }

    // 해당 결과 반환
    return test.possibleResults.firstWhere(
      (r) => r.id == winningResultId,
      orElse: () => test.possibleResults.first,
    );
  }

  /// 테스트 결과 제출
  Future<UserPsychologyTestResult?> submitResult({
    required String testId,
    required String resultId,
    required Map<String, String> answers,
    required Map<String, int> scoreBreakdown,
    String? llmAnalysis,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('user_psychology_results')
          .insert({
            'user_id': userId,
            'test_id': testId,
            'result_id': resultId,
            'answers': answers,
            'score_breakdown': scoreBreakdown,
            'llm_analysis': llmAnalysis,
          })
          .select()
          .single();

      // 결과 정보 조회
      final resultResponse = await _supabase
          .from('psychology_test_results')
          .select()
          .eq('id', resultId)
          .single();

      return UserPsychologyTestResult(
        id: response['id'],
        testId: testId,
        resultId: resultId,
        result: TrendPsychologyResult(
          id: resultResponse['id'],
          resultCode: resultResponse['result_code'],
          title: resultResponse['title'],
          description: resultResponse['description'],
          imageUrl: resultResponse['image_url'],
          characteristics:
              List<String>.from(resultResponse['characteristics'] ?? []),
          compatibleWith: resultResponse['compatible_with'],
          incompatibleWith: resultResponse['incompatible_with'],
          additionalInfo:
              Map<String, dynamic>.from(resultResponse['additional_info'] ?? {}),
          selectionCount: resultResponse['selection_count'] ?? 0,
        ),
        answers: answers,
        scoreBreakdown: scoreBreakdown,
        llmAnalysis: llmAnalysis,
        isShared: false,
        completedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('❌ [PsychologyTestRepository] submitResult error: $e');
      return null;
    }
  }

  /// 사용자의 테스트 기록 조회
  Future<List<UserPsychologyTestResult>> getUserResults({
    String? testId,
    int limit = 20,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      var query = _supabase
          .from('user_psychology_results')
          .select('''
            *,
            psychology_test_results (*)
          ''')
          .eq('user_id', userId);

      if (testId != null) {
        query = query.eq('test_id', testId);
      }

      final response = await query
          .order('completed_at', ascending: false)
          .limit(limit);

      return (response as List).map((json) {
        final resultJson = json['psychology_test_results'];
        return UserPsychologyTestResult(
          id: json['id'],
          testId: json['test_id'],
          resultId: json['result_id'],
          result: TrendPsychologyResult(
            id: resultJson['id'],
            resultCode: resultJson['result_code'],
            title: resultJson['title'],
            description: resultJson['description'],
            imageUrl: resultJson['image_url'],
            characteristics:
                List<String>.from(resultJson['characteristics'] ?? []),
            compatibleWith: resultJson['compatible_with'],
            incompatibleWith: resultJson['incompatible_with'],
            additionalInfo:
                Map<String, dynamic>.from(resultJson['additional_info'] ?? {}),
            selectionCount: resultJson['selection_count'] ?? 0,
          ),
          answers: Map<String, String>.from(json['answers'] ?? {}),
          scoreBreakdown: Map<String, int>.from(json['score_breakdown'] ?? {}),
          llmAnalysis: json['llm_analysis'],
          isShared: json['is_shared'] ?? false,
          completedAt: json['completed_at'] != null
              ? DateTime.parse(json['completed_at'])
              : null,
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ [PsychologyTestRepository] getUserResults error: $e');
      return [];
    }
  }

  /// 테스트 통계 조회
  Future<PsychologyTestStats?> getTestStats(String testId) async {
    try {
      // 총 참여자 수 - 결과 합계로 계산
      final resultsResponse = await _supabase
          .from('psychology_test_results')
          .select('id, title, selection_count')
          .eq('test_id', testId);

      final resultsList = resultsResponse as List;
      final totalParticipants = resultsList.fold<int>(
        0,
        (sum, r) => sum + (r['selection_count'] as int? ?? 0),
      );

      // 결과별 분포
      final distribution = resultsList.map((r) {
        final count = r['selection_count'] as int? ?? 0;
        return ResultDistribution(
          resultId: r['id'],
          resultTitle: r['title'],
          count: count,
          percentage: totalParticipants > 0
              ? (count / totalParticipants) * 100
              : 0,
        );
      }).toList();

      return PsychologyTestStats(
        testId: testId,
        totalParticipants: totalParticipants,
        resultDistribution: distribution,
      );
    } catch (e) {
      debugPrint('❌ [PsychologyTestRepository] getTestStats error: $e');
      return null;
    }
  }
}
