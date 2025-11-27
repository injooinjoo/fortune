import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/models.dart';

/// 이상형 월드컵 Repository
class IdealWorldcupRepository {
  final SupabaseClient _supabase;

  IdealWorldcupRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// 월드컵 상세 조회 (후보자 포함)
  Future<IdealWorldcup?> getWorldcupById(String worldcupId) async {
    try {
      // 월드컵 기본 정보
      final worldcupResponse = await _supabase
          .from('ideal_worldcups')
          .select()
          .eq('id', worldcupId)
          .single();

      // 후보자 조회
      final candidatesResponse = await _supabase
          .from('worldcup_candidates')
          .select()
          .eq('worldcup_id', worldcupId)
          .order('created_at');

      final candidates = (candidatesResponse as List)
          .map((c) => WorldcupCandidate(
                id: c['id'],
                name: c['name'],
                imageUrl: c['image_url'],
                description: c['description'],
                winCount: c['win_count'] ?? 0,
                loseCount: c['lose_count'] ?? 0,
                finalWinCount: c['final_win_count'] ?? 0,
                createdAt: c['created_at'] != null
                    ? DateTime.parse(c['created_at'])
                    : null,
              ))
          .toList();

      return IdealWorldcup(
        id: worldcupResponse['id'],
        contentId: worldcupResponse['content_id'],
        description: worldcupResponse['description'],
        worldcupCategory: WorldcupCategory.values.firstWhere(
          (c) => c.name == worldcupResponse['worldcup_category'],
          orElse: () => WorldcupCategory.custom,
        ),
        totalRounds: worldcupResponse['total_rounds'] ?? 16,
        candidates: candidates,
        createdAt: worldcupResponse['created_at'] != null
            ? DateTime.parse(worldcupResponse['created_at'])
            : null,
      );
    } catch (e) {
      debugPrint('❌ [IdealWorldcupRepository] getWorldcupById error: $e');
      return null;
    }
  }

  /// content_id로 월드컵 조회
  Future<IdealWorldcup?> getWorldcupByContentId(String contentId) async {
    try {
      final worldcupResponse = await _supabase
          .from('ideal_worldcups')
          .select('id')
          .eq('content_id', contentId)
          .single();

      return getWorldcupById(worldcupResponse['id']);
    } catch (e) {
      debugPrint(
          '❌ [IdealWorldcupRepository] getWorldcupByContentId error: $e');
      return null;
    }
  }

  /// 월드컵 결과 제출
  Future<UserWorldcupResult?> submitResult({
    required String worldcupId,
    required String winnerId,
    String? secondPlaceId,
    String? thirdPlaceId,
    String? fourthPlaceId,
    required List<WorldcupMatchResult> matchHistory,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // 결과 저장
      final response = await _supabase
          .from('user_worldcup_results')
          .insert({
            'user_id': userId,
            'worldcup_id': worldcupId,
            'winner_id': winnerId,
            'second_place_id': secondPlaceId,
            'third_place_id': thirdPlaceId,
            'fourth_place_id': fourthPlaceId,
            'match_history': matchHistory
                .map((m) => {
                      'round': m.round,
                      'winner_id': m.winnerId,
                      'loser_id': m.loserId,
                    })
                .toList(),
          })
          .select()
          .single();

      // 후보자 통계 업데이트 (각 매치에서 승/패 기록)
      for (final match in matchHistory) {
        await _supabase.rpc('increment_worldcup_stats', params: {
          'p_winner_id': match.winnerId,
          'p_loser_id': match.loserId,
        });
      }

      // 최종 우승자 통계 업데이트
      await _supabase.rpc('increment_final_win', params: {
        'p_candidate_id': winnerId,
      });

      // 후보자 정보 조회
      final winnerData = await _supabase
          .from('worldcup_candidates')
          .select()
          .eq('id', winnerId)
          .single();

      final winner = WorldcupCandidate(
        id: winnerData['id'],
        name: winnerData['name'],
        imageUrl: winnerData['image_url'],
        description: winnerData['description'],
        winCount: winnerData['win_count'] ?? 0,
        loseCount: winnerData['lose_count'] ?? 0,
        finalWinCount: winnerData['final_win_count'] ?? 0,
      );

      return UserWorldcupResult(
        id: response['id'],
        worldcupId: worldcupId,
        winnerId: winnerId,
        secondPlaceId: secondPlaceId,
        thirdPlaceId: thirdPlaceId,
        fourthPlaceId: fourthPlaceId,
        winner: winner,
        matchHistory: matchHistory,
        isShared: false,
        completedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('❌ [IdealWorldcupRepository] submitResult error: $e');
      return null;
    }
  }

  /// 사용자의 월드컵 기록 조회
  Future<List<UserWorldcupResult>> getUserResults({
    String? worldcupId,
    int limit = 20,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      var query = _supabase.from('user_worldcup_results').select('''
            *,
            worldcup_candidates!user_worldcup_results_winner_id_fkey (*)
          ''').eq('user_id', userId);

      if (worldcupId != null) {
        query = query.eq('worldcup_id', worldcupId);
      }

      final response =
          await query.order('completed_at', ascending: false).limit(limit);

      return (response as List).map((json) {
        final winnerJson = json['worldcup_candidates'];
        final matchHistoryJson = json['match_history'] as List? ?? [];

        return UserWorldcupResult(
          id: json['id'],
          worldcupId: json['worldcup_id'],
          winnerId: json['winner_id'],
          secondPlaceId: json['second_place_id'],
          thirdPlaceId: json['third_place_id'],
          fourthPlaceId: json['fourth_place_id'],
          winner: WorldcupCandidate(
            id: winnerJson['id'],
            name: winnerJson['name'],
            imageUrl: winnerJson['image_url'],
            description: winnerJson['description'],
            winCount: winnerJson['win_count'] ?? 0,
            loseCount: winnerJson['lose_count'] ?? 0,
            finalWinCount: winnerJson['final_win_count'] ?? 0,
          ),
          matchHistory: matchHistoryJson
              .map((m) => WorldcupMatchResult(
                    round: m['round'],
                    winnerId: m['winner_id'],
                    loserId: m['loser_id'],
                  ))
              .toList(),
          isShared: json['is_shared'] ?? false,
          completedAt: json['completed_at'] != null
              ? DateTime.parse(json['completed_at'])
              : null,
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ [IdealWorldcupRepository] getUserResults error: $e');
      return [];
    }
  }

  /// 월드컵 랭킹 조회
  Future<List<WorldcupRanking>> getRankings(String worldcupId,
      {int limit = 20}) async {
    try {
      final response = await _supabase
          .from('worldcup_candidates')
          .select()
          .eq('worldcup_id', worldcupId)
          .order('final_win_count', ascending: false)
          .limit(limit);

      final rankings = <WorldcupRanking>[];
      int rank = 1;

      for (final c in response as List) {
        final winCount = c['win_count'] as int? ?? 0;
        final loseCount = c['lose_count'] as int? ?? 0;
        final totalGames = winCount + loseCount;

        rankings.add(WorldcupRanking(
          worldcupId: worldcupId,
          candidateId: c['id'],
          candidateName: c['name'],
          candidateImage: c['image_url'],
          winCount: winCount,
          loseCount: loseCount,
          finalWinCount: c['final_win_count'] ?? 0,
          winRate: totalGames > 0 ? (winCount / totalGames) * 100 : 0,
          rank: rank++,
        ));
      }

      return rankings;
    } catch (e) {
      debugPrint('❌ [IdealWorldcupRepository] getRankings error: $e');
      return [];
    }
  }

  /// 랜덤 후보자 셔플 (게임 시작용)
  List<WorldcupCandidate> shuffleCandidates(
      List<WorldcupCandidate> candidates, int targetCount) {
    final shuffled = List<WorldcupCandidate>.from(candidates)..shuffle();
    return shuffled.take(targetCount).toList();
  }
}
