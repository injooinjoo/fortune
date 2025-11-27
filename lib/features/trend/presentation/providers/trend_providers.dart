import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/repositories.dart';
import '../../domain/models/models.dart';

/// Repository Providers
final trendContentRepositoryProvider = Provider((ref) => TrendContentRepository());
final psychologyTestRepositoryProvider = Provider((ref) => PsychologyTestRepository());
final idealWorldcupRepositoryProvider = Provider((ref) => IdealWorldcupRepository());
final balanceGameRepositoryProvider = Provider((ref) => BalanceGameRepository());
final trendSocialRepositoryProvider = Provider((ref) => TrendSocialRepository());

/// 트렌드 콘텐츠 목록 State
class TrendListState {
  final List<TrendContent> contents;
  final bool isLoading;
  final String? error;
  final TrendContentType? selectedType;
  final TrendCategory? selectedCategory;
  final bool hasMore;
  final int page;

  const TrendListState({
    this.contents = const [],
    this.isLoading = false,
    this.error,
    this.selectedType,
    this.selectedCategory,
    this.hasMore = true,
    this.page = 0,
  });

  TrendListState copyWith({
    List<TrendContent>? contents,
    bool? isLoading,
    String? error,
    TrendContentType? selectedType,
    TrendCategory? selectedCategory,
    bool? hasMore,
    int? page,
    bool clearError = false,
    bool clearType = false,
    bool clearCategory = false,
  }) {
    return TrendListState(
      contents: contents ?? this.contents,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedType: clearType ? null : (selectedType ?? this.selectedType),
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }
}

/// 트렌드 목록 StateNotifier
class TrendListNotifier extends StateNotifier<TrendListState> {
  final TrendContentRepository _repository;

  TrendListNotifier(this._repository) : super(const TrendListState()) {
    loadContents();
  }

  Future<void> loadContents({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = state.copyWith(isLoading: true, page: 0, clearError: true);
    } else {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      const limit = 20;
      final response = await _repository.getContents(
        type: state.selectedType,
        category: state.selectedCategory,
        offset: refresh ? 0 : state.page * limit,
        limit: limit,
      );

      final newContents = refresh ? response.contents : [...state.contents, ...response.contents];

      state = state.copyWith(
        contents: newContents,
        isLoading: false,
        hasMore: response.hasMore,
        page: refresh ? 1 : state.page + 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void setTypeFilter(TrendContentType? type) {
    if (state.selectedType == type) {
      state = state.copyWith(clearType: true);
    } else {
      state = state.copyWith(selectedType: type);
    }
    loadContents(refresh: true);
  }

  void setCategoryFilter(TrendCategory? category) {
    if (state.selectedCategory == category) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
    loadContents(refresh: true);
  }

  void clearFilters() {
    state = state.copyWith(clearType: true, clearCategory: true);
    loadContents(refresh: true);
  }

  Future<void> refresh() => loadContents(refresh: true);

  Future<void> loadMore() {
    if (!state.hasMore || state.isLoading) return Future.value();
    return loadContents();
  }
}

final trendListProvider =
    StateNotifierProvider<TrendListNotifier, TrendListState>((ref) {
  final repository = ref.watch(trendContentRepositoryProvider);
  return TrendListNotifier(repository);
});

/// 인기 콘텐츠 Provider
final popularContentsProvider = FutureProvider<List<TrendContent>>((ref) async {
  final repository = ref.watch(trendContentRepositoryProvider);
  return repository.getPopularContents(limit: 5);
});

/// 콘텐츠 상세 조회 Provider Family
final trendContentDetailProvider =
    FutureProvider.family<TrendContent?, String>((ref, contentId) async {
  final repository = ref.watch(trendContentRepositoryProvider);
  return repository.getContentById(contentId);
});

/// 좋아요 상태 Provider Family
final trendLikeStateProvider =
    FutureProvider.family<LikeState, String>((ref, contentId) async {
  final repository = ref.watch(trendSocialRepositoryProvider);
  return repository.getLikeState(contentId);
});
