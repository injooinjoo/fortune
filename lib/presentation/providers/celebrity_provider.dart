import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/celebrity_service_new.dart';
import '../../services/celebrity_crawling_service.dart';
import '../../data/models/celebrity_simple.dart';

// Celebrity service providers
final celebrityServiceProvider = Provider<CelebrityService>((ref) {
  return CelebrityService();
});

final celebrityCrawlingServiceProvider = Provider<CelebrityCrawlingService>((ref) {
  return CelebrityCrawlingService();
});

// All celebrities provider
final allCelebritiesProvider = FutureProvider<List<Celebrity>>((ref) async {
  final service = ref.watch(celebrityServiceProvider);
  return await service.getAllCelebrities();
});

// Celebrity by category provider
final celebritiesByCategoryProvider = FutureProvider.family<List<Celebrity>, CelebrityType>((ref, type) async {
  final service = ref.watch(celebrityServiceProvider);
  return await service.getCelebritiesByType(type);
});

// Celebrity search provider
final celebritySearchProvider = StateNotifierProvider<CelebritySearchNotifier, AsyncValue<List<Celebrity>>>((ref) {
  final service = ref.watch(celebrityServiceProvider);
  return CelebritySearchNotifier(service);
});

// Celebrity search notifier
class CelebritySearchNotifier extends StateNotifier<AsyncValue<List<Celebrity>>> {
  final CelebrityService _service;

  CelebritySearchNotifier(this._service) : super(const AsyncValue.data([]));

  Future<void> search({
    String? query,
    CelebrityType? type,
    Gender? gender,
    String? nationality,
    int? limit,
  }) async {
    if (query == null || query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final results = await _service.searchCelebrities(
        query,
        type: type,
        gender: gender,
        nationality: nationality,
        limit: limit ?? 50,
      );
      state = AsyncValue.data(results);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  void clear() {
    state = const AsyncValue.data([]);
  }
}

// Selected celebrity provider
final selectedCelebrityProvider = StateProvider<Celebrity?>((ref) => null);

// Celebrity suggestions provider (for autocomplete)
final celebritySuggestionsProvider = FutureProvider.family<List<Celebrity>, String>((ref, query) async {
  if (query.isEmpty) return [];

  final service = ref.watch(celebrityServiceProvider);
  return await service.searchCelebrities(query, limit: 10);
});

// Popular celebrities provider
final popularCelebritiesProvider = FutureProvider.family<List<Celebrity>, CelebrityType?>((ref, type) async {
  final service = ref.watch(celebrityServiceProvider);
  if (type != null) {
    return await service.getCelebritiesByType(type, limit: 10);
  } else {
    return await service.getAllCelebrities(limit: 10);
  }
});

// Random celebrities provider
final randomCelebritiesProvider = FutureProvider.family<List<Celebrity>, CelebrityType?>((ref, type) async {
  final service = ref.watch(celebrityServiceProvider);
  return await service.getRandomCelebrities(type: type, count: 10);
});

// Celebrities with birthday provider
final celebritiesWithBirthdayProvider = FutureProvider.family<List<Celebrity>, DateTime>((ref, date) async {
  final service = ref.watch(celebrityServiceProvider);
  return await service.getCelebritiesWithSameBirthday(date);
});

// Celebrity by ID provider
final celebrityByIdProvider = FutureProvider.family<Celebrity?, String>((ref, id) async {
  final service = ref.watch(celebrityServiceProvider);
  return await service.getCelebrityById(id);
});

// Celebrity statistics provider
final celebrityStatisticsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(celebrityServiceProvider);
  return await service.getCelebrityStatistics();
});

// Celebrity filter state
final celebrityFilterProvider = StateNotifierProvider<CelebrityFilterNotifier, CelebrityFilter>((ref) {
  return CelebrityFilterNotifier();
});

class CelebrityFilterNotifier extends StateNotifier<CelebrityFilter> {
  CelebrityFilterNotifier() : super(const CelebrityFilter());

  void updateCelebrityType(CelebrityType? celebrityType) {
    state = CelebrityFilter(
      celebrityType: celebrityType,
      gender: state.gender,
      minAge: state.minAge,
      maxAge: state.maxAge,
      searchQuery: state.searchQuery,
      nationality: state.nationality,
      zodiacSign: state.zodiacSign,
      chineseZodiac: state.chineseZodiac);
  }

  void updateGender(Gender? gender) {
    state = CelebrityFilter(
      celebrityType: state.celebrityType,
      gender: gender,
      minAge: state.minAge,
      maxAge: state.maxAge,
      searchQuery: state.searchQuery,
      nationality: state.nationality,
      zodiacSign: state.zodiacSign,
      chineseZodiac: state.chineseZodiac);
  }

  void updateAgeRange(int? minAge, int? maxAge) {
    state = CelebrityFilter(
      celebrityType: state.celebrityType,
      gender: state.gender,
      minAge: minAge,
      maxAge: maxAge,
      searchQuery: state.searchQuery,
      nationality: state.nationality,
      zodiacSign: state.zodiacSign,
      chineseZodiac: state.chineseZodiac);
  }

  void updateSearchQuery(String? query) {
    state = CelebrityFilter(
      celebrityType: state.celebrityType,
      gender: state.gender,
      minAge: state.minAge,
      maxAge: state.maxAge,
      searchQuery: query,
      nationality: state.nationality,
      zodiacSign: state.zodiacSign,
      chineseZodiac: state.chineseZodiac);
  }

  void updateNationality(String? nationality) {
    state = CelebrityFilter(
      celebrityType: state.celebrityType,
      gender: state.gender,
      minAge: state.minAge,
      maxAge: state.maxAge,
      searchQuery: state.searchQuery,
      nationality: nationality,
      zodiacSign: state.zodiacSign,
      chineseZodiac: state.chineseZodiac);
  }

  void reset() {
    state = const CelebrityFilter();
  }
}

// Crawling providers
final crawlingStatsProvider = FutureProvider<CrawlingStats>((ref) async {
  final service = ref.watch(celebrityCrawlingServiceProvider);
  return await service.getCrawlingStats();
});

final crawlingResultProvider = StateNotifierProvider<CrawlingResultNotifier, CrawlingState>((ref) {
  final service = ref.watch(celebrityCrawlingServiceProvider);
  return CrawlingResultNotifier(service);
});

enum CrawlingStatus { idle, crawling, completed, error }

class CrawlingState {
  final CrawlingStatus status;
  final String? message;
  final int? current;
  final int? total;
  final String? currentName;
  final BatchCrawlingResult? result;
  
  const CrawlingState({
    this.status = CrawlingStatus.idle,
    this.message,
    this.current,
    this.total,
    this.currentName,
    this.result,
  });
  
  CrawlingState copyWith({
    CrawlingStatus? status,
    String? message,
    int? current,
    int? total,
    String? currentName,
    BatchCrawlingResult? result,
  }) {
    return CrawlingState(
      status: status ?? this.status,
      message: message ?? this.message,
      current: current ?? this.current,
      total: total ?? this.total,
      currentName: currentName ?? this.currentName,
      result: result ?? this.result,
    );
  }
}

class CrawlingResultNotifier extends StateNotifier<CrawlingState> {
  final CelebrityCrawlingService _service;
  
  CrawlingResultNotifier(this._service) : super(const CrawlingState());
  
  Future<void> crawlSingleCelebrity(String name, {bool forceUpdate = false}) async {
    state = state.copyWith(
      status: CrawlingStatus.crawling,
      message: '크롤링 중...',
      currentName: name,
    );
    
    try {
      final result = await _service.crawlCelebrityInfo(
        name: name,
        forceUpdate: forceUpdate,
      );
      
      if (result.success) {
        state = state.copyWith(
          status: CrawlingStatus.completed,
          message: result.message,
        );
      } else {
        state = state.copyWith(
          status: CrawlingStatus.error,
          message: result.message,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: CrawlingStatus.error,
        message: '오류: ${e.toString()}',
      );
    }
  }
  
  Future<void> crawlMultipleCelebrities(List<String> names, {bool forceUpdate = false}) async {
    state = state.copyWith(
      status: CrawlingStatus.crawling,
      message: '일괄 크롤링 시작...',
      current: 0,
      total: names.length,
    );
    
    try {
      final result = await _service.crawlMultipleCelebrities(
        names: names,
        forceUpdate: forceUpdate,
        onProgress: (current, total, currentName) {
          state = state.copyWith(
            current: current,
            total: total,
            currentName: currentName,
            message: '$currentName 크롤링 중... ($current/$total)',
          );
        },
      );
      
      state = state.copyWith(
        status: CrawlingStatus.completed,
        message: '완료: 성공 ${result.successCount}개, 실패 ${result.failureCount}개',
        result: result,
      );
    } catch (e) {
      state = state.copyWith(
        status: CrawlingStatus.error,
        message: '오류: ${e.toString()}',
      );
    }
  }
  
  void reset() {
    state = const CrawlingState();
  }
}