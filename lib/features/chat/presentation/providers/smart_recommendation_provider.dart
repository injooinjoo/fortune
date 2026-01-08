import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/providers/fortune_gauge_provider.dart';
import '../../domain/models/recommendation_chip.dart';
import '../../domain/services/smart_chip_recommender.dart';

/// 스마트 추천 칩 Provider
/// 현재 운세 타입을 받아 연관성 있는 추천 칩 반환
final smartRecommendationProvider =
    Provider.family<List<RecommendationChip>, String>((ref, currentFortuneType) {
  final gaugeState = ref.watch(fortuneGaugeProvider);
  final recommender = SmartChipRecommender();

  return recommender.getSmartRecommendations(
    currentFortuneType: currentFortuneType,
    todayViewed: gaugeState.todayViewed,
  );
});

/// SmartChipRecommender 인스턴스 Provider
final smartChipRecommenderProvider = Provider<SmartChipRecommender>((ref) {
  return SmartChipRecommender();
});
