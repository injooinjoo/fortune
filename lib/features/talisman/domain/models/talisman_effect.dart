import 'package:freezed_annotation/freezed_annotation.dart';

part 'talisman_effect.freezed.dart';
part 'talisman_effect.g.dart';

@freezed
class TalismanEffect with _$TalismanEffect {
  const factory TalismanEffect({
    required String id,
    required String talismanId,
    required String userId,
    required DateTime trackingDate,
    @Default(0) int dailyScore,
    @Default([]) List<String> positiveSigns,
    @Default([]) List<String> challenges,
    String? userNote,
    @Default({}) Map<String, dynamic> metadata,
    required DateTime createdAt,
  }) = _TalismanEffect;

  factory TalismanEffect.fromJson(Map<String, dynamic> json) =>
      _$TalismanEffectFromJson(json);
}

@freezed
class TalismanStats with _$TalismanStats {
  const factory TalismanStats({
    required String talismanId,
    @Default(0) int totalDays,
    @Default(0.0) double averageScore,
    @Default(0) int bestStreak,
    @Default(0) int currentStreak,
    @Default([]) List<TalismanMilestone> milestones,
    DateTime? lastUpdated,
  }) = _TalismanStats;

  factory TalismanStats.fromJson(Map<String, dynamic> json) =>
      _$TalismanStatsFromJson(json);
}

@freezed
class TalismanMilestone with _$TalismanMilestone {
  const factory TalismanMilestone({
    required String title,
    required String description,
    required DateTime achievedAt,
    @Default('achievement') String type,
  }) = _TalismanMilestone;

  factory TalismanMilestone.fromJson(Map<String, dynamic> json) =>
      _$TalismanMilestoneFromJson(json);
}