import '../models/recommendation_chip.dart';
import '../constants/category_affinity.dart';
import '../constants/chip_category_map.dart';

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
}

/// 점수가 매겨진 칩 (내부용)
class _ScoredChip {
  final RecommendationChip chip;
  final double score;

  _ScoredChip(this.chip, this.score);
}
