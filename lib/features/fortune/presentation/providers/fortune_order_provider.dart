import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/fortune_list_page.dart';

/// 정렬 옵션 Enum
enum SortOption {
  custom,           // 사용자 지정 순서 (드래그 앤 드롭)
  recentlyViewed,   // 최근 조회순
  availableFirst,   // 조회 가능순 (오늘 아직 안 본 것)
  favoriteFirst,    // 즐겨찾기 우선
}

/// 운세 순서 관리 상태
class FortuneOrderState {
  final List<String> customOrder;        // 사용자가 드래그로 정한 순서 (운세 type)
  final Set<String> favorites;           // 즐겨찾기 운세 타입들
  final SortOption currentSort;          // 현재 정렬 옵션
  final Map<String, DateTime> lastViewed; // 마지막 조회 시간

  FortuneOrderState({
    List<String>? customOrder,
    Set<String>? favorites,
    this.currentSort = SortOption.custom,
    Map<String, DateTime>? lastViewed,
  })  : customOrder = customOrder ?? [],
        favorites = favorites ?? {},
        lastViewed = lastViewed ?? {};

  FortuneOrderState copyWith({
    List<String>? customOrder,
    Set<String>? favorites,
    SortOption? currentSort,
    Map<String, DateTime>? lastViewed,
  }) {
    return FortuneOrderState(
      customOrder: customOrder ?? this.customOrder,
      favorites: favorites ?? this.favorites,
      currentSort: currentSort ?? this.currentSort,
      lastViewed: lastViewed ?? this.lastViewed,
    );
  }
}

/// 운세 순서 관리 Provider
class FortuneOrderNotifier extends StateNotifier<FortuneOrderState> {
  static const String _prefKeyCustomOrder = 'fortune_custom_order';
  static const String _prefKeyFavorites = 'fortune_favorites';
  static const String _prefKeySortOption = 'fortune_sort_option';
  static const String _prefKeyLastViewed = 'fortune_last_viewed';

  FortuneOrderNotifier() : super(FortuneOrderState()) {
    _loadFromPreferences();
  }

  /// SharedPreferences에서 데이터 로드
  Future<void> _loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // 사용자 지정 순서
    final customOrderJson = prefs.getStringList(_prefKeyCustomOrder);

    // 즐겨찾기
    final favoritesJson = prefs.getStringList(_prefKeyFavorites);

    // 정렬 옵션
    final sortOptionIndex = prefs.getInt(_prefKeySortOption) ?? 0;
    final sortOption = SortOption.values[sortOptionIndex];

    // 마지막 조회 시간
    final lastViewedJson = prefs.getString(_prefKeyLastViewed);
    final lastViewed = <String, DateTime>{};
    if (lastViewedJson != null) {
      final map = Uri.splitQueryString(lastViewedJson);
      map.forEach((key, value) {
        lastViewed[key] = DateTime.parse(value);
      });
    }

    state = FortuneOrderState(
      customOrder: customOrderJson,
      favorites: favoritesJson?.toSet() ?? {},
      currentSort: sortOption,
      lastViewed: lastViewed,
    );
  }

  /// SharedPreferences에 저장
  Future<void> _saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // 사용자 지정 순서
    await prefs.setStringList(_prefKeyCustomOrder, state.customOrder);

    // 즐겨찾기
    await prefs.setStringList(_prefKeyFavorites, state.favorites.toList());

    // 정렬 옵션
    await prefs.setInt(_prefKeySortOption, state.currentSort.index);

    // 마지막 조회 시간
    final lastViewedString = state.lastViewed.entries
        .map((e) => '${e.key}=${e.value.toIso8601String()}')
        .join('&');
    await prefs.setString(_prefKeyLastViewed, lastViewedString);
  }

  /// 즐겨찾기 토글
  Future<void> toggleFavorite(String fortuneType) async {
    final newFavorites = Set<String>.from(state.favorites);
    if (newFavorites.contains(fortuneType)) {
      newFavorites.remove(fortuneType);
    } else {
      newFavorites.add(fortuneType);
    }

    state = state.copyWith(favorites: newFavorites);
    await _saveToPreferences();
  }

  /// 사용자 지정 순서 업데이트 (드래그 앤 드롭)
  Future<void> updateCustomOrder(List<String> newOrder) async {
    state = state.copyWith(customOrder: newOrder);
    await _saveToPreferences();
  }

  /// 정렬 옵션 변경
  Future<void> changeSortOption(SortOption option) async {
    state = state.copyWith(currentSort: option);
    await _saveToPreferences();
  }

  /// 운세 조회 기록
  Future<void> recordView(String fortuneType) async {
    final newLastViewed = Map<String, DateTime>.from(state.lastViewed);
    newLastViewed[fortuneType] = DateTime.now();

    state = state.copyWith(lastViewed: newLastViewed);
    await _saveToPreferences();
  }

  /// 오늘 조회 가능 여부 확인
  bool isAvailableToday(String fortuneType) {
    final lastView = state.lastViewed[fortuneType];
    if (lastView == null) return true;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastViewDate = DateTime(lastView.year, lastView.month, lastView.day);

    return today.isAfter(lastViewDate);
  }

  /// 정렬된 운세 리스트 반환
  List<FortuneCategory> getSortedCategories(List<FortuneCategory> categories) {
    switch (state.currentSort) {
      case SortOption.custom:
        return _sortByCustomOrder(categories);
      case SortOption.recentlyViewed:
        return _sortByRecentlyViewed(categories);
      case SortOption.availableFirst:
        return _sortByAvailableFirst(categories);
      case SortOption.favoriteFirst:
        return _sortByFavoriteFirst(categories);
    }
  }

  /// 사용자 지정 순서로 정렬
  List<FortuneCategory> _sortByCustomOrder(List<FortuneCategory> categories) {
    if (state.customOrder.isEmpty) {
      return categories;
    }

    final sorted = <FortuneCategory>[];
    final remaining = List<FortuneCategory>.from(categories);

    // 사용자 순서대로 먼저 추가
    for (final type in state.customOrder) {
      final category = remaining.firstWhere(
        (c) => c.type == type,
        orElse: () => categories.first, // 기본값
      );
      if (remaining.contains(category)) {
        sorted.add(category);
        remaining.remove(category);
      }
    }

    // 나머지 추가
    sorted.addAll(remaining);

    return sorted;
  }

  /// 최근 조회순 정렬
  List<FortuneCategory> _sortByRecentlyViewed(List<FortuneCategory> categories) {
    final sorted = List<FortuneCategory>.from(categories);
    sorted.sort((a, b) {
      final aTime = state.lastViewed[a.type];
      final bTime = state.lastViewed[b.type];

      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;

      return bTime.compareTo(aTime); // 최근이 먼저
    });

    return sorted;
  }

  /// 조회 가능순 정렬 (오늘 아직 안 본 것이 먼저)
  List<FortuneCategory> _sortByAvailableFirst(List<FortuneCategory> categories) {
    final sorted = List<FortuneCategory>.from(categories);
    sorted.sort((a, b) {
      final aAvailable = isAvailableToday(a.type);
      final bAvailable = isAvailableToday(b.type);

      if (aAvailable && !bAvailable) return -1;
      if (!aAvailable && bAvailable) return 1;
      return 0;
    });

    return sorted;
  }

  /// 즐겨찾기 우선 정렬
  List<FortuneCategory> _sortByFavoriteFirst(List<FortuneCategory> categories) {
    final favorites = categories.where((c) => state.favorites.contains(c.type)).toList();
    final others = categories.where((c) => !state.favorites.contains(c.type)).toList();

    return [...favorites, ...others];
  }
}

/// Provider 정의
final fortuneOrderProvider = StateNotifierProvider<FortuneOrderNotifier, FortuneOrderState>((ref) {
  return FortuneOrderNotifier();
});
