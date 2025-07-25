import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/celebrity_service.dart';
import '../../data/models/celebrity.dart';

// Celebrity service provider
final celebrityServiceProvider = Provider<CelebrityService>((ref) {
  return CelebrityService();
});

// All celebrities provider
final allCelebritiesProvider = Provider<List<Celebrity>>((ref) {
  final service = ref.watch(celebrityServiceProvider);
  return service.getAllCelebrities();
});

// Celebrity by category provider
final celebritiesByCategoryProvider = Provider.family<List<Celebrity>, CelebrityCategory>((ref, category) {
  final service = ref.watch(celebrityServiceProvider);
  return service.getCelebritiesByCategory(category);
});

// Celebrity search provider
final celebritySearchProvider = StateNotifierProvider<CelebritySearchNotifier, List<Celebrity>>((ref) {
  final service = ref.watch(celebrityServiceProvider);
  return CelebritySearchNotifier(service);
});

// Celebrity search notifier
class CelebritySearchNotifier extends StateNotifier<List<Celebrity>> {
  final CelebrityService _service;
  
  CelebritySearchNotifier(this._service) : super([]);
  
  void search({
    String? query,
    CelebrityFilter? filter,
  }) {
    if ((query == null || query.isEmpty) && filter == null) {
      state = [];
      return;
    }
    
    state = _service.searchCelebrities(
      query: query,
      filter: filter,
    );
  }
  
  void clear() {
    state = [];
  }
}

// Selected celebrity provider
final selectedCelebrityProvider = StateProvider<Celebrity?>((ref) => null);

// Celebrity suggestions provider (for autocomplete)
final celebritySuggestionsProvider = Provider.family<List<Celebrity>, String>((ref, query) {
  if (query.isEmpty) return [];
  
  final service = ref.watch(celebrityServiceProvider);
  return service.getSuggestions(query, limit: 10);
});

// Popular celebrities provider
final popularCelebritiesProvider = Provider.family<List<Celebrity>, CelebrityCategory?>((ref, category) {
  final service = ref.watch(celebrityServiceProvider);
  return service.getPopularCelebrities(category: category, limit: 10);
});

// Celebrities with birthday provider
final celebritiesWithBirthdayProvider = Provider.family<List<Celebrity>, DateTime>((ref, date) {
  final service = ref.watch(celebrityServiceProvider);
  return service.getCelebritiesWithBirthday(date);
});

// Celebrity match score provider
final celebrityMatchScoreProvider = Provider.family<double, (Celebrity, Celebrity)>((ref, pair) {
  final service = ref.watch(celebrityServiceProvider);
  return service.calculateMatchScore(pair.$1, pair.$2);
});

// Celebrity statistics provider
final celebrityStatisticsProvider = Provider<Map<String, dynamic>>((ref) {
  final service = ref.watch(celebrityServiceProvider);
  return service.getCelebrityStatistics();
});

// Celebrity filter state
final celebrityFilterProvider = StateNotifierProvider<CelebrityFilterNotifier, CelebrityFilter>((ref) {
  return CelebrityFilterNotifier();
});

class CelebrityFilterNotifier extends StateNotifier<CelebrityFilter> {
  CelebrityFilterNotifier() : super(CelebrityFilter());
  
  void updateCategory(CelebrityCategory? category) {
    state = CelebrityFilter(
      category: category,
      gender: state.gender,
      minAge: state.minAge,
      maxAge: state.maxAge,
      searchQuery: state.searchQuery,
      zodiacSign: state.zodiacSign,
      chineseZodiac: state.chineseZodiac,
    );
  }
  
  void updateGender(Gender? gender) {
    state = CelebrityFilter(
      category: state.category,
      gender: gender,
      minAge: state.minAge,
      maxAge: state.maxAge,
      searchQuery: state.searchQuery,
      zodiacSign: state.zodiacSign,
      chineseZodiac: state.chineseZodiac,
    );
  }
  
  void updateAgeRange(int? minAge, int? maxAge) {
    state = CelebrityFilter(
      category: state.category,
      gender: state.gender,
      minAge: minAge,
      maxAge: maxAge,
      searchQuery: state.searchQuery,
      zodiacSign: state.zodiacSign,
      chineseZodiac: state.chineseZodiac,
    );
  }
  
  void updateSearchQuery(String? query) {
    state = CelebrityFilter(
      category: state.category,
      gender: state.gender,
      minAge: state.minAge,
      maxAge: state.maxAge,
      searchQuery: query,
      zodiacSign: state.zodiacSign,
      chineseZodiac: state.chineseZodiac,
    );
  }
  
  void reset() {
    state = CelebrityFilter();
  }
}