import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/investment_ticker.dart';
import '../../data/repositories/ticker_repository.dart';

part 'ticker_provider.freezed.dart';

/// 티커 상태
@freezed
class TickerState with _$TickerState {
  const factory TickerState({
    @Default(false) bool isLoading,
    @Default([]) List<InvestmentTicker> tickers,
    @Default([]) List<InvestmentTicker> popularTickers,
    @Default({}) Map<String, List<InvestmentTicker>> tickersByCategory,
    String? selectedCategory,
    String? searchQuery,
    String? errorMessage,
  }) = _TickerState;
}

/// 티커 Repository Provider
final tickerRepositoryProvider = Provider<TickerRepository>((ref) {
  return TickerRepository();
});

/// 티커 상태 관리 Notifier
class TickerNotifier extends StateNotifier<TickerState> {
  final TickerRepository _repository;

  TickerNotifier(this._repository) : super(const TickerState());

  /// 카테고리 선택 및 해당 카테고리 티커 로드
  void selectCategory(String category) {
    state = state.copyWith(
      selectedCategory: category,
      searchQuery: null,
      errorMessage: null,
    );

    final tickers = _repository.getTickersByCategory(category);
    final popular = _repository.getPopularTickers(category: category);

    state = state.copyWith(
      tickers: tickers,
      popularTickers: popular,
    );
  }

  /// 티커 검색 (전체 카테고리에서 검색)
  void search(String query) {
    state = state.copyWith(
      searchQuery: query,
      errorMessage: null,
    );

    // 검색 시 전체 카테고리에서 검색 (카테고리 필터 제거)
    final tickers = _repository.searchTickers(query);

    state = state.copyWith(
      tickers: tickers,
    );
  }

  /// 인기 종목 로드
  void loadPopularTickers({String? category}) {
    final popular = _repository.getPopularTickers(category: category);

    state = state.copyWith(
      popularTickers: popular,
    );
  }

  /// 전체 티커 로드 (카테고리별)
  void loadAllTickers() {
    final tickersByCategory = _repository.getAllTickersByCategory();
    final popular = _repository.getPopularTickers();

    state = state.copyWith(
      tickersByCategory: tickersByCategory,
      popularTickers: popular,
    );
  }

  /// 검색 초기화
  void clearSearch() {
    state = state.copyWith(searchQuery: null);
    if (state.selectedCategory != null) {
      selectCategory(state.selectedCategory!);
    }
  }

  /// 카테고리 초기화
  void clearCategory() {
    state = state.copyWith(
      selectedCategory: null,
      tickers: [],
      searchQuery: null,
    );
  }
}

/// 티커 상태 Provider
final tickerProvider =
    StateNotifierProvider<TickerNotifier, TickerState>((ref) {
  final repository = ref.watch(tickerRepositoryProvider);
  return TickerNotifier(repository);
});

/// 현재 카테고리의 티커 목록
final currentCategoryTickersProvider = Provider<List<InvestmentTicker>>((ref) {
  final state = ref.watch(tickerProvider);
  return state.tickers;
});

/// 인기 티커 목록
final popularTickersProvider = Provider<List<InvestmentTicker>>((ref) {
  final state = ref.watch(tickerProvider);
  return state.popularTickers;
});

/// 로딩 상태
final tickerLoadingProvider = Provider<bool>((ref) {
  return ref.watch(tickerProvider).isLoading;
});
