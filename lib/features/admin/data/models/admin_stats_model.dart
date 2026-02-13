import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_stats_model.freezed.dart';
part 'admin_stats_model.g.dart';

@freezed
class AdminStatsModel with _$AdminStatsModel {
  const factory AdminStatsModel(
      {required int totalUsers,
      required int activeUsers,
      required int totalFortunes,
      required int todayFortunes,
      required int totalTokensUsed,
      required int totalRevenue,
      required Map<String, int> fortuneTypeStats,
      required List<DailyStatModel> dailyStats,
      required List<TokenUsageModel> tokenUsageStats}) = _AdminStatsModel;

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) =>
      _$AdminStatsModelFromJson(json);
}

@freezed
class DailyStatModel with _$DailyStatModel {
  const factory DailyStatModel(
      {required DateTime date,
      required int fortunes,
      required int users,
      required int tokens,
      required int revenue}) = _DailyStatModel;

  factory DailyStatModel.fromJson(Map<String, dynamic> json) =>
      _$DailyStatModelFromJson(json);
}

@freezed
class TokenUsageModel with _$TokenUsageModel {
  const factory TokenUsageModel(
      {required String userId,
      required String userName,
      required int tokensUsed,
      required int fortuneCount,
      required DateTime lastActivity,
      required bool isSubscribed}) = _TokenUsageModel;

  factory TokenUsageModel.fromJson(Map<String, dynamic> json) =>
      _$TokenUsageModelFromJson(json);
}
