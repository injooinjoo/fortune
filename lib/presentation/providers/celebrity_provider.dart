import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/celebrity_service.dart';
import '../../data/models/celebrity_simple.dart';

// Celebrity service providers
final celebrityServiceProvider = Provider<CelebrityService>((ref) {
  return CelebrityService();
});

// All celebrities provider
final allCelebritiesProvider = FutureProvider<List<Celebrity>>((ref) async {
  final service = ref.watch(celebrityServiceProvider);
  return await service.getAllCelebrities();
});

// Celebrity by category provider
final celebritiesByCategoryProvider =
    FutureProvider.family<List<Celebrity>, CelebrityType>((ref, type) async {
  final service = ref.watch(celebrityServiceProvider);
  return await service.getCelebritiesByType(type);
});

// Celebrity search provider
final celebritySearchProvider =
    StateNotifierProvider<CelebritySearchNotifier, AsyncValue<List<Celebrity>>>(
        (ref) {
  final service = ref.watch(celebrityServiceProvider);
  return CelebritySearchNotifier(service);
});

// Celebrity search notifier
class CelebritySearchNotifier
    extends StateNotifier<AsyncValue<List<Celebrity>>> {
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
final celebritySuggestionsProvider =
    FutureProvider.family<List<Celebrity>, String>((ref, query) async {
  if (query.isEmpty) return [];

  final service = ref.watch(celebrityServiceProvider);
  return await service.searchCelebrities(query, limit: 10);
});

// Popular celebrities provider
final popularCelebritiesProvider =
    FutureProvider.family<List<Celebrity>, CelebrityType?>((ref, type) async {
  final service = ref.watch(celebrityServiceProvider);
  if (type != null) {
    return await service.getCelebritiesByType(type, limit: 10);
  } else {
    return await service.getAllCelebrities(limit: 10);
  }
});

// Random celebrities provider
final randomCelebritiesProvider =
    FutureProvider.family<List<Celebrity>, CelebrityType?>((ref, type) async {
  final service = ref.watch(celebrityServiceProvider);
  return await service.getRandomCelebrities(type: type, count: 10);
});

// Celebrities with birthday provider
final celebritiesWithBirthdayProvider =
    FutureProvider.family<List<Celebrity>, DateTime>((ref, date) async {
  final service = ref.watch(celebrityServiceProvider);
  return await service.getCelebritiesWithSameBirthday(date);
});

// Celebrity by ID provider
final celebrityByIdProvider =
    FutureProvider.family<Celebrity?, String>((ref, id) async {
  final service = ref.watch(celebrityServiceProvider);
  return await service.getCelebrityById(id);
});

// Celebrity statistics provider
final celebrityStatisticsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(celebrityServiceProvider);
  return await service.getCelebrityStatistics();
});

// Celebrity filter state
final celebrityFilterProvider =
    StateNotifierProvider<CelebrityFilterNotifier, CelebrityFilter>((ref) {
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
