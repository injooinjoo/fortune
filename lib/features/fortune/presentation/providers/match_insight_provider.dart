import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/models/match_insight.dart';
import '../../domain/models/sports_schedule.dart';

/// 경기 인사이트 상태
class MatchInsightState {
  final bool isLoading;
  final MatchInsight? result;
  final String? error;

  const MatchInsightState({
    this.isLoading = false,
    this.result,
    this.error,
  });

  MatchInsightState copyWith({
    bool? isLoading,
    MatchInsight? result,
    String? error,
  }) {
    return MatchInsightState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      error: error,
    );
  }
}

/// 경기 인사이트 Notifier
class MatchInsightNotifier extends StateNotifier<MatchInsightState> {
  MatchInsightNotifier() : super(const MatchInsightState());

  final _supabase = Supabase.instance.client;

  /// 경기 인사이트 생성
  Future<MatchInsight?> generateInsight({
    required String userId,
    required SportType sport,
    required String homeTeam,
    required String awayTeam,
    required DateTime gameDate,
    String? favoriteTeam,
    String? birthDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      Logger.info(
          '[MatchInsight] Generating insight for $homeTeam vs $awayTeam');

      final response = await _supabase.functions.invoke(
        'fortune-match-insight',
        body: {
          'userId': userId,
          'sport': sport.name,
          'homeTeam': homeTeam,
          'awayTeam': awayTeam,
          'gameDate': gameDate.toIso8601String(),
          if (favoriteTeam != null) 'favoriteTeam': favoriteTeam,
          if (birthDate != null) 'birthDate': birthDate,
        },
      );

      if (response.status != 200) {
        throw Exception('API error: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;
      final insight = MatchInsight.fromJson(data);

      state = state.copyWith(isLoading: false, result: insight);
      Logger.info(
          '[MatchInsight] Successfully generated insight. Score: ${insight.score}');

      return insight;
    } catch (e, st) {
      Logger.error('[MatchInsight] Error generating insight', e, st);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// 상태 초기화
  void reset() {
    state = const MatchInsightState();
  }
}

/// 경기 인사이트 Provider
final matchInsightProvider =
    StateNotifierProvider<MatchInsightNotifier, MatchInsightState>(
  (ref) => MatchInsightNotifier(),
);

/// 경기 인사이트 캐시 Provider (fortuneType + gameId 기반)
final matchInsightCacheProvider = StateProvider<Map<String, MatchInsight>>(
  (ref) => {},
);
