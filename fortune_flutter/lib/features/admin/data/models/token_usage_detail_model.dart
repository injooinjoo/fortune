import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_usage_detail_model.freezed.dart';
part 'token_usage_detail_model.g.dart';

@freezed
class TokenUsageDetailModel with _$TokenUsageDetailModel {
  const factory TokenUsageDetailModel({
    required TokenUsageSummary summary,
    required List<DailyTokenUsage> dailyUsage,
    required List<TokenUsageByType> usageByType,
    required List<TopUserUsage> topUsers,
    required PackageEfficiency packageEfficiency,
    required TokenUsageTrend trend,
  }) = _TokenUsageDetailModel;

  factory TokenUsageDetailModel.fromJson(Map<String, dynamic> json) =>
      _$TokenUsageDetailModelFromJson(json);
}

@freezed
class TokenUsageSummary with _$TokenUsageSummary {
  const factory TokenUsageSummary({
    required int totalTokensUsed,
    required int totalTokensPurchased,
    required int activeUsers,
    required double averageUsagePerUser,
    required String period,
  }) = _TokenUsageSummary;

  factory TokenUsageSummary.fromJson(Map<String, dynamic> json) =>
      _$TokenUsageSummaryFromJson(json);
}

@freezed
class DailyTokenUsage with _$DailyTokenUsage {
  const factory DailyTokenUsage({
    required DateTime date,
    required int tokensUsed,
    required int tokensPurchased,
    required int uniqueUsers,
    required int transactions,
  }) = _DailyTokenUsage;

  factory DailyTokenUsage.fromJson(Map<String, dynamic> json) =>
      _$DailyTokenUsageFromJson(json);
}

@freezed
class TokenUsageByType with _$TokenUsageByType {
  const factory TokenUsageByType({
    required String fortuneType,
    required String fortuneCategory,
    required int tokensUsed,
    required int usageCount,
    required double percentage,
  }) = _TokenUsageByType;

  factory TokenUsageByType.fromJson(Map<String, dynamic> json) =>
      _$TokenUsageByTypeFromJson(json);
}

@freezed
class TopUserUsage with _$TopUserUsage {
  const factory TopUserUsage({
    required String userId,
    required String email,
    required String? displayName,
    required int tokensUsed,
    required int tokensPurchased,
    required int fortuneCount,
    required DateTime lastActivity,
    required bool isUnlimited,
  }) = _TopUserUsage;

  factory TopUserUsage.fromJson(Map<String, dynamic> json) =>
      _$TopUserUsageFromJson(json);
}

@freezed
class PackageEfficiency with _$PackageEfficiency {
  const factory PackageEfficiency({
    required Map<String, PackageStats> packages,
    required String mostPopular,
    required String bestValue,
  }) = _PackageEfficiency;

  factory PackageEfficiency.fromJson(Map<String, dynamic> json) =>
      _$PackageEfficiencyFromJson(json);
}

@freezed
class PackageStats with _$PackageStats {
  const factory PackageStats({
    required String packageName,
    required int purchaseCount,
    required double totalRevenue,
    required double conversionRate,
  }) = _PackageStats;

  factory PackageStats.fromJson(Map<String, dynamic> json) =>
      _$PackageStatsFromJson(json);
}

@freezed
class TokenUsageTrend with _$TokenUsageTrend {
  const factory TokenUsageTrend({
    required double dailyGrowth,
    required double weeklyGrowth,
    required double monthlyGrowth,
    required String trendDirection,
    required List<PeakUsageTime> peakTimes,
  }) = _TokenUsageTrend;

  factory TokenUsageTrend.fromJson(Map<String, dynamic> json) =>
      _$TokenUsageTrendFromJson(json);
}

@freezed
class PeakUsageTime with _$PeakUsageTime {
  const factory PeakUsageTime({
    required int hour,
    required String dayOfWeek,
    required double averageTokens,
    required int userCount,
  }) = _PeakUsageTime;

  factory PeakUsageTime.fromJson(Map<String, dynamic> json) =>
      _$PeakUsageTimeFromJson(json);
}