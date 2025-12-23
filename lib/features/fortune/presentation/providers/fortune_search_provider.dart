import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/fortune_category.dart';

/// 검색 상태
class FortuneSearchState {
  final String query;
  final List<FortuneCategory> results;

  const FortuneSearchState({
    this.query = '',
    this.results = const [],
  });

  FortuneSearchState copyWith({
    String? query,
    List<FortuneCategory>? results,
  }) {
    return FortuneSearchState(
      query: query ?? this.query,
      results: results ?? this.results,
    );
  }
}

/// 검색 Notifier
class FortuneSearchNotifier extends StateNotifier<FortuneSearchState> {
  final List<FortuneCategory> _allCategories;

  FortuneSearchNotifier(this._allCategories)
      : super(FortuneSearchState(results: _allCategories));

  /// 검색 실행 (부분 일치 + 점수 기반 정렬)
  void search(String query) {
    if (query.isEmpty) {
      state = FortuneSearchState(query: '', results: _allCategories);
      return;
    }

    final lowerQuery = query.toLowerCase();
    final scored = <({FortuneCategory category, int score})>[];

    for (final category in _allCategories) {
      final score = _calculateScore(category, lowerQuery);
      if (score > 0) {
        scored.add((category: category, score: score));
      }
    }

    // 점수 내림차순 정렬
    scored.sort((a, b) => b.score.compareTo(a.score));

    state = FortuneSearchState(
      query: query,
      results: scored.map((e) => e.category).toList(),
    );
  }

  /// 검색 점수 계산
  int _calculateScore(FortuneCategory category, String query) {
    int score = 0;
    final title = category.title.toLowerCase();
    final description = category.description.toLowerCase();
    final type = category.type.toLowerCase();

    // title 시작 일치: +100
    if (title.startsWith(query)) score += 100;
    // title 포함: +30
    if (title.contains(query)) score += 30;
    // description 포함: +20
    if (description.contains(query)) score += 20;
    // type 포함 (영문 검색): +10
    if (type.contains(query)) score += 10;

    return score;
  }

  /// 검색 초기화
  void clear() {
    state = FortuneSearchState(query: '', results: _allCategories);
  }
}

/// 검색 Provider (autoDispose)
final fortuneSearchProvider = StateNotifierProvider.autoDispose
    .family<FortuneSearchNotifier, FortuneSearchState, List<FortuneCategory>>(
  (ref, categories) => FortuneSearchNotifier(categories),
);
