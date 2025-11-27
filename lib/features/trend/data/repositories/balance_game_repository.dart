import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/models.dart';

/// 밸런스 게임 Repository
class BalanceGameRepository {
  final SupabaseClient _supabase;

  BalanceGameRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// 밸런스 게임 세트 상세 조회 (질문 포함)
  Future<BalanceGameSet?> getGameSetById(String gameSetId) async {
    try {
      // 게임 세트 기본 정보
      final gameSetResponse = await _supabase
          .from('balance_game_sets')
          .select()
          .eq('id', gameSetId)
          .single();

      // 질문 조회
      final questionsResponse = await _supabase
          .from('balance_game_questions')
          .select()
          .eq('game_set_id', gameSetId)
          .order('question_order');

      final questions = (questionsResponse as List)
          .map((q) => BalanceGameQuestion(
                id: q['id'],
                questionOrder: q['question_order'],
                choiceA: BalanceGameChoice(
                  text: q['choice_a_text'],
                  imageUrl: q['choice_a_image'],
                  emoji: q['choice_a_emoji'],
                ),
                choiceB: BalanceGameChoice(
                  text: q['choice_b_text'],
                  imageUrl: q['choice_b_image'],
                  emoji: q['choice_b_emoji'],
                ),
                totalVotes: q['total_votes'] ?? 0,
                votesA: q['votes_a'] ?? 0,
                votesB: q['votes_b'] ?? 0,
                createdAt: q['created_at'] != null
                    ? DateTime.parse(q['created_at'])
                    : null,
              ))
          .toList();

      return BalanceGameSet(
        id: gameSetResponse['id'],
        contentId: gameSetResponse['content_id'],
        description: gameSetResponse['description'],
        questionCount: gameSetResponse['question_count'] ?? questions.length,
        questions: questions,
        createdAt: gameSetResponse['created_at'] != null
            ? DateTime.parse(gameSetResponse['created_at'])
            : null,
      );
    } catch (e) {
      debugPrint('❌ [BalanceGameRepository] getGameSetById error: $e');
      return null;
    }
  }

  /// content_id로 게임 세트 조회
  Future<BalanceGameSet?> getGameSetByContentId(String contentId) async {
    try {
      final gameSetResponse = await _supabase
          .from('balance_game_sets')
          .select('id')
          .eq('content_id', contentId)
          .single();

      return getGameSetById(gameSetResponse['id']);
    } catch (e) {
      debugPrint(
          '❌ [BalanceGameRepository] getGameSetByContentId error: $e');
      return null;
    }
  }

  /// 투표 제출 (단일 질문)
  Future<BalanceQuestionStats?> submitVote({
    required String questionId,
    required String choice, // 'A' or 'B'
  }) async {
    try {
      // 투표 업데이트
      if (choice == 'A') {
        await _supabase.rpc('increment_balance_vote_a', params: {
          'p_question_id': questionId,
        });
      } else {
        await _supabase.rpc('increment_balance_vote_b', params: {
          'p_question_id': questionId,
        });
      }

      // 최신 통계 조회
      final statsResponse = await _supabase
          .from('balance_game_questions')
          .select('total_votes, votes_a, votes_b')
          .eq('id', questionId)
          .single();

      return BalanceQuestionStats(
        questionId: questionId,
        totalVotes: statsResponse['total_votes'] ?? 0,
        votesA: statsResponse['votes_a'] ?? 0,
        votesB: statsResponse['votes_b'] ?? 0,
      );
    } catch (e) {
      debugPrint('❌ [BalanceGameRepository] submitVote error: $e');
      return null;
    }
  }

  /// 게임 결과 제출
  Future<UserBalanceResult?> submitResult({
    required String gameSetId,
    required Map<String, String> answers,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // 각 답변에 대해 투표 업데이트
      for (final entry in answers.entries) {
        await submitVote(questionId: entry.key, choice: entry.value);
      }

      // 다수파 매칭 카운트 계산
      int majorityMatchCount = 0;

      for (final entry in answers.entries) {
        final statsResponse = await _supabase
            .from('balance_game_questions')
            .select('votes_a, votes_b')
            .eq('id', entry.key)
            .single();

        final votesA = statsResponse['votes_a'] as int? ?? 0;
        final votesB = statsResponse['votes_b'] as int? ?? 0;
        final majorityChoice = votesA >= votesB ? 'A' : 'B';

        if (entry.value == majorityChoice) {
          majorityMatchCount++;
        }
      }

      // 결과 저장
      final response = await _supabase
          .from('user_balance_results')
          .insert({
            'user_id': userId,
            'game_set_id': gameSetId,
            'answers': answers,
            'majority_match_count': majorityMatchCount,
          })
          .select()
          .single();

      return UserBalanceResult(
        id: response['id'],
        gameSetId: gameSetId,
        answers: answers,
        majorityMatchCount: majorityMatchCount,
        isShared: false,
        completedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('❌ [BalanceGameRepository] submitResult error: $e');
      return null;
    }
  }

  /// 게임 결과 요약 생성
  Future<BalanceGameSummary?> getGameSummary({
    required String gameSetId,
    required Map<String, String> answers,
  }) async {
    try {
      final gameSet = await getGameSetById(gameSetId);
      if (gameSet == null) return null;

      int majorityMatchCount = 0;
      final questionSummaries = <BalanceQuestionSummary>[];

      for (final question in gameSet.questions) {
        final userChoice = answers[question.id];
        if (userChoice == null) continue;

        final majorityChoice =
            question.votesA >= question.votesB ? 'A' : 'B';
        final isMajority = userChoice == majorityChoice;
        if (isMajority) majorityMatchCount++;

        final userChoicePercentage = userChoice == 'A'
            ? (question.totalVotes > 0
                ? (question.votesA / question.totalVotes) * 100
                : 50.0)
            : (question.totalVotes > 0
                ? (question.votesB / question.totalVotes) * 100
                : 50.0);

        questionSummaries.add(BalanceQuestionSummary(
          questionId: question.id,
          userChoice: userChoice,
          majorityChoice: majorityChoice,
          isMajority: isMajority,
          userChoicePercentage: userChoicePercentage,
          choiceAText: question.choiceA.text,
          choiceBText: question.choiceB.text,
          percentageA: question.totalVotes > 0
              ? (question.votesA / question.totalVotes) * 100
              : 50.0,
          percentageB: question.totalVotes > 0
              ? (question.votesB / question.totalVotes) * 100
              : 50.0,
        ));
      }

      final minorityCount = gameSet.questions.length - majorityMatchCount;

      return BalanceGameSummary(
        gameSetId: gameSetId,
        totalQuestions: gameSet.questions.length,
        majorityMatchCount: majorityMatchCount,
        minorityCount: minorityCount,
        questionSummaries: questionSummaries,
      );
    } catch (e) {
      debugPrint('❌ [BalanceGameRepository] getGameSummary error: $e');
      return null;
    }
  }

  /// 사용자의 게임 기록 조회
  Future<List<UserBalanceResult>> getUserResults({
    String? gameSetId,
    int limit = 20,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      var query = _supabase
          .from('user_balance_results')
          .select()
          .eq('user_id', userId);

      if (gameSetId != null) {
        query = query.eq('game_set_id', gameSetId);
      }

      final response = await query
          .order('completed_at', ascending: false)
          .limit(limit);

      return (response as List).map((json) {
        return UserBalanceResult(
          id: json['id'],
          gameSetId: json['game_set_id'],
          answers: Map<String, String>.from(json['answers'] ?? {}),
          majorityMatchCount: json['majority_match_count'] ?? 0,
          isShared: json['is_shared'] ?? false,
          completedAt: json['completed_at'] != null
              ? DateTime.parse(json['completed_at'])
              : null,
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ [BalanceGameRepository] getUserResults error: $e');
      return [];
    }
  }

  /// 질문별 통계 조회
  Future<List<BalanceQuestionStats>> getQuestionStats(
      String gameSetId) async {
    try {
      final response = await _supabase
          .from('balance_game_questions')
          .select('id, total_votes, votes_a, votes_b')
          .eq('game_set_id', gameSetId)
          .order('question_order');

      return (response as List)
          .map((q) => BalanceQuestionStats(
                questionId: q['id'],
                totalVotes: q['total_votes'] ?? 0,
                votesA: q['votes_a'] ?? 0,
                votesB: q['votes_b'] ?? 0,
              ))
          .toList();
    } catch (e) {
      debugPrint('❌ [BalanceGameRepository] getQuestionStats error: $e');
      return [];
    }
  }
}
