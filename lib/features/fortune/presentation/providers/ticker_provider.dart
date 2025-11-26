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
  Future<void> selectCategory(String category) async {
    state = state.copyWith(
      isLoading: true,
      selectedCategory: category,
      searchQuery: null,
      errorMessage: null,
    );

    try {
      final tickers = await _repository.getTickersByCategory(category);
      final popular = await _repository.getPopularTickers(category: category);

      state = state.copyWith(
        isLoading: false,
        tickers: tickers,
        popularTickers: popular,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 티커 검색
  Future<void> search(String query) async {
    state = state.copyWith(
      isLoading: true,
      searchQuery: query,
      errorMessage: null,
    );

    try {
      final tickers = await _repository.searchTickers(
        query,
        category: state.selectedCategory,
      );

      state = state.copyWith(
        isLoading: false,
        tickers: tickers,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 인기 종목 로드
  Future<void> loadPopularTickers({String? category}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final popular = await _repository.getPopularTickers(category: category);

      state = state.copyWith(
        isLoading: false,
        popularTickers: popular,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 전체 티커 로드 (카테고리별)
  Future<void> loadAllTickers() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final tickersByCategory = await _repository.getAllTickersByCategory();
      final popular = await _repository.getPopularTickers();

      state = state.copyWith(
        isLoading: false,
        tickersByCategory: tickersByCategory,
        popularTickers: popular,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
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
