import '../models/recommendation_chip.dart';
import '../models/life_category.dart';
import '../constants/category_affinity.dart';
import '../constants/chip_category_map.dart';
import '../constants/life_category_fortune_map.dart';

/// 스마트 추천 칩 서비스
/// 현재 운세 컨텍스트 기반으로 연관성 있는 칩 추천
class SmartChipRecommender {
  /// 스마트 추천 칩 반환
  ///
  /// [currentFortuneType] - 방금 본 운세 타입
  /// [todayViewed] - 오늘 이미 본 운세 타입 Set
  /// [minCount] - 최소 추천 개수 (기본: 3)
  /// [maxCount] - 최대 추천 개수 (기본: 4)
  List<RecommendationChip> getSmartRecommendations({
    required String currentFortuneType,
    required Set<String> todayViewed,
    int minCount = 3,
    int maxCount = 4,
  }) {
    // 1. 현재 운세의 카테고리 확인
    final currentCategory = getCategoryForChip(currentFortuneType);

    // 2. 이미 본 운세 + 현재 운세 제외
    final excludeSet = {...todayViewed, currentFortuneType};
    final availableChips = defaultChips
        .where((chip) => !excludeSet.contains(chip.fortuneType))
        .toList();

    if (availableChips.isEmpty) {
      return []; // 모든 칩을 다 봄
    }

    // 3. 연관성 점수 계산
    final scoredChips = availableChips.map((chip) {
      final chipCategory = getCategoryForChip(chip.fortuneType);
      final score = getAffinityScore(currentCategory, chipCategory);
      return _ScoredChip(chip, score);
    }).toList();

    // 4. 점수순 정렬 (높은 순)
    scoredChips.sort((a, b) => b.score.compareTo(a.score));

    // 5. 동적 개수 결정: 고연관(≥0.6) 칩이 4개 이상이면 4개, 아니면 3개
    final highAffinityCount = scoredChips.where((s) => s.score >= 0.6).length;
    final targetCount = highAffinityCount >= maxCount ? maxCount : minCount;

    // 6. 상위 N개 반환
    return scoredChips.take(targetCount).map((s) => s.chip).toList();
  }

  /// 특정 카테고리의 칩만 필터링
  List<RecommendationChip> getChipsByCategory(String category) {
    return defaultChips.where((chip) {
      final chipCategory = getCategoryForChip(chip.fortuneType);
      return chipCategory == category;
    }).toList();
  }

  /// 인생 컨설팅 카테고리 기반 추천 칩 반환
  ///
  /// [lifeCategory] - 사용자가 선택한 인생 컨설팅 대분류
  /// [subConcern] - 사용자가 선택한 세부 고민 ID (선택적)
  /// [todayViewed] - 오늘 이미 본 운세 타입 Set
  /// [maxCount] - 최대 추천 개수 (기본: 4)
  List<RecommendationChip> getLifeCategoryRecommendations({
    required LifeCategory? lifeCategory,
    String? subConcern,
    Set<String> todayViewed = const {},
    int maxCount = 4,
  }) {
    if (lifeCategory == null) {
      // 카테고리가 없으면 기본 추천
      return defaultChips.take(maxCount).toList();
    }

    // 1. 세부 고민 또는 대분류 기반 추천 칩 ID 가져오기
    final recommendedIds = getRecommendedChipsForSubConcern(
      subConcern,
      lifeCategory,
    );

    // 2. 대분류에 속하는 모든 칩 ID 가져오기
    final allCategoryChipIds = getAllChipsForCategory(lifeCategory);

    // 3. 우선순위: 세부고민 추천 > 대분류 추천 > 기타
    final result = <RecommendationChip>[];

    // 세부고민/대분류 추천 칩 추가 (오늘 본 것 제외)
    for (final chipId in recommendedIds) {
      if (todayViewed.contains(chipId)) continue;
      final chip = defaultChips.where((c) => c.id == chipId).firstOrNull;
      if (chip != null && result.length < maxCount) {
        result.add(chip);
      }
    }

    // 대분류 내 다른 칩들로 채우기
    for (final chipId in allCategoryChipIds) {
      if (todayViewed.contains(chipId)) continue;
      if (result.any((c) => c.id == chipId)) continue; // 이미 추가됨
      final chip = defaultChips.where((c) => c.id == chipId).firstOrNull;
      if (chip != null && result.length < maxCount) {
        result.add(chip);
      }
    }

    // 그래도 부족하면 다른 칩들로 채우기
    if (result.length < maxCount) {
      for (final chip in defaultChips) {
        if (todayViewed.contains(chip.id)) continue;
        if (result.any((c) => c.id == chip.id)) continue;
        if (result.length < maxCount) {
          result.add(chip);
        }
      }
    }

    return result;
  }

  /// 인생 컨설팅 카테고리 기반 초기 추천 칩 (온보딩 완료 직후)
  ///
  /// [lifeCategory] - 사용자가 선택한 인생 컨설팅 대분류
  /// [subConcern] - 사용자가 선택한 세부 고민 ID (선택적)
  List<RecommendationChip> getInitialChipsForLifeCategory({
    required LifeCategory? lifeCategory,
    String? subConcern,
  }) {
    if (lifeCategory == null) {
      return initialChips;
    }

    // 세부 고민 또는 대분류 기반 추천 칩 ID 가져오기
    final recommendedIds = getRecommendedChipsForSubConcern(
      subConcern,
      lifeCategory,
    );

    // 최대 3개 + 전체보기 버튼
    final result = <RecommendationChip>[];
    for (final chipId in recommendedIds) {
      final chip = defaultChips.where((c) => c.id == chipId).firstOrNull;
      if (chip != null && result.length < 3) {
        result.add(chip);
      }
    }

    // 전체보기 버튼 추가
    final viewAllChip = initialChips.where((c) => c.id == 'viewAll').firstOrNull;
    if (viewAllChip != null) {
      result.add(viewAllChip);
    }

    return result;
  }
}

/// 점수가 매겨진 칩 (내부용)
class _ScoredChip {
  final RecommendationChip chip;
  final double score;

  _ScoredChip(this.chip, this.score);
}
