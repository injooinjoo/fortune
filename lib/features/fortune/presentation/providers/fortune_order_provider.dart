import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/domain/entities/fortune.dart' show Fortune;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/fortune_category.dart';

/// 정렬 옵션 Enum
enum SortOption {
  recommended, // 추천순 (인기 + 조회수 + 즐겨찾기 복합)
  recentlyViewed, // 최근 조회순
  availableFirst, // 조회 가능순 (오늘 아직 안 본 것)
  favoriteFirst, // 즐겨찾기 우선
}

/// 운세 순서 관리 상태
class FortuneOrderState {
  final List<String> customOrder; // 사용자가 드래그로 정한 순서 (운세 type)
  final Set<String> favorites; // 즐겨찾기 운세 타입들
  final SortOption currentSort; // 현재 정렬 옵션
  final Map<String, DateTime> lastViewed; // 마지막 조회 시간
  final Map<String, int> viewCount; // 누적 조회수 (인기순 정렬용)

  FortuneOrderState({
    List<String>? customOrder,
    Set<String>? favorites,
    this.currentSort = SortOption.recommended, // 기본값: 추천순
    Map<String, DateTime>? lastViewed,
    Map<String, int>? viewCount,
  })  : customOrder = customOrder ?? [],
        favorites = favorites ?? {},
        lastViewed = lastViewed ?? {},
        viewCount = viewCount ?? {};

  FortuneOrderState copyWith({
    List<String>? customOrder,
    Set<String>? favorites,
    SortOption? currentSort,
    Map<String, DateTime>? lastViewed,
    Map<String, int>? viewCount,
  }) {
    return FortuneOrderState(
      customOrder: customOrder ?? this.customOrder,
      favorites: favorites ?? this.favorites,
      currentSort: currentSort ?? this.currentSort,
      lastViewed: lastViewed ?? this.lastViewed,
      viewCount: viewCount ?? this.viewCount,
    );
  }
}

/// 운세 순서 관리 Provider
class FortuneOrderNotifier extends StateNotifier<FortuneOrderState> {
  static const String _prefKeyCustomOrder = 'fortune_custom_order';
  static const String _prefKeyFavorites = 'fortune_favorites';
  static const String _prefKeySortOption = 'fortune_sort_option';
  static const String _prefKeyLastViewed = 'fortune_last_viewed';
  static const String _prefKeyViewCount = 'fortune_view_count';

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

    // 정렬 옵션 (기본값: recommended = 0)
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

    // 누적 조회수
    final viewCountJson = prefs.getString(_prefKeyViewCount);
    final viewCount = <String, int>{};
    if (viewCountJson != null) {
      final map = Uri.splitQueryString(viewCountJson);
      map.forEach((key, value) {
        viewCount[key] = int.tryParse(value) ?? 0;
      });
    }

    state = FortuneOrderState(
      customOrder: customOrderJson,
      favorites: favoritesJson?.toSet() ?? {},
      currentSort: sortOption,
      lastViewed: lastViewed,
      viewCount: viewCount,
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

    // 누적 조회수
    final viewCountString =
        state.viewCount.entries.map((e) => '${e.key}=${e.value}').join('&');
    await prefs.setString(_prefKeyViewCount, viewCountString);
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

    // 위젯 데이터 동기화
    await _syncWidgetFavorites(newFavorites);
  }

  /// 위젯 즐겨찾기 동기화 (새 위젯 시스템에서는 fortune-daily 기반이므로 별도 동기화 불필요)
  Future<void> _syncWidgetFavorites(Set<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('fortune_favorites', favorites.toList());
    // 새 위젯 시스템은 fortune-daily 기반이므로 별도 동기화 불필요
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

    // 누적 조회수 증가
    final newViewCount = Map<String, int>.from(state.viewCount);
    newViewCount[fortuneType] = (newViewCount[fortuneType] ?? 0) + 1;

    state = state.copyWith(
      lastViewed: newLastViewed,
      viewCount: newViewCount,
    );
    await _saveToPreferences();
  }

  /// 운세 데이터를 위젯에 캐시
  /// 새 위젯 시스템에서는 fortune-daily 기반이므로 별도 캐시 불필요
  /// daily fortune 조회 시 WidgetDataService.fetchAndSaveForWidget() 호출
  Future<void> cacheFortuneForWidget(
      String fortuneType, Fortune fortune) async {
    // 새 위젯 시스템은 fortune-daily 기반이므로
    // daily fortune 조회 시점에 WidgetDataService에서 처리
    // 이 메서드는 호환성을 위해 유지하되 동작하지 않음
  }

  /// 위젯 업데이트 트리거
  /// 새 위젯 시스템에서는 백그라운드 갱신으로 대체
  Future<void> triggerWidgetRolling() async {
    // 새 위젯 시스템은 1분 롤링이 아닌 백그라운드 갱신 방식
    // 수동 업데이트가 필요한 경우에만 호출
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
      case SortOption.recommended:
        return _sortByRecommended(categories);
      case SortOption.recentlyViewed:
        return _sortByRecentlyViewed(categories);
      case SortOption.availableFirst:
        return _sortByAvailableFirst(categories);
      case SortOption.favoriteFirst:
        return _sortByFavoriteFirst(categories);
    }
  }

  /// 추천순 정렬 (인기 + 조회수 + 즐겨찾기 복합)
  List<FortuneCategory> _sortByRecommended(List<FortuneCategory> categories) {
    final sorted = List<FortuneCategory>.from(categories);
    sorted.sort((a, b) {
      final aScore = _calculateRecommendScore(a);
      final bScore = _calculateRecommendScore(b);
      return bScore.compareTo(aScore); // 높은 점수 먼저
    });
    return sorted;
  }

  /// 추천 점수 계산
  /// 점수 = (조회수 × 10) + (즐겨찾기 ? 100 : 0) + (isNew ? 50 : 0) + (오늘 안봄 ? 30 : 0)
  int _calculateRecommendScore(FortuneCategory category) {
    final views = state.viewCount[category.type] ?? 0;
    final isFavorite = state.favorites.contains(category.type);
    final isNewCategory = category.isNew;
    final notViewedToday = !category.hasViewedToday;

    return (views * 10) +
        (isFavorite ? 100 : 0) +
        (isNewCategory ? 50 : 0) +
        (notViewedToday ? 30 : 0);
  }

  /// 최근 조회순 정렬
  List<FortuneCategory> _sortByRecentlyViewed(
      List<FortuneCategory> categories) {
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
  List<FortuneCategory> _sortByAvailableFirst(
      List<FortuneCategory> categories) {
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
    final favorites =
        categories.where((c) => state.favorites.contains(c.type)).toList();
    final others =
        categories.where((c) => !state.favorites.contains(c.type)).toList();

    return [...favorites, ...others];
  }
}

/// Provider 정의
final fortuneOrderProvider =
    StateNotifierProvider<FortuneOrderNotifier, FortuneOrderState>((ref) {
  return FortuneOrderNotifier();
});
