// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'talisman_effect.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TalismanEffectImpl _$$TalismanEffectImplFromJson(Map<String, dynamic> json) =>
    _$TalismanEffectImpl(
      id: json['id'] as String,
      talismanId: json['talismanId'] as String,
      userId: json['userId'] as String,
      trackingDate: DateTime.parse(json['trackingDate'] as String),
      dailyScore: (json['dailyScore'] as num?)?.toInt() ?? 0,
      positiveSigns: (json['positiveSigns'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      challenges: (json['challenges'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      userNote: json['userNote'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$TalismanEffectImplToJson(
        _$TalismanEffectImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'talismanId': instance.talismanId,
      'userId': instance.userId,
      'trackingDate': instance.trackingDate.toIso8601String(),
      'dailyScore': instance.dailyScore,
      'positiveSigns': instance.positiveSigns,
      'challenges': instance.challenges,
      'userNote': instance.userNote,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$TalismanStatsImpl _$$TalismanStatsImplFromJson(Map<String, dynamic> json) =>
    _$TalismanStatsImpl(
      talismanId: json['talismanId'] as String,
      totalDays: (json['totalDays'] as num?)?.toInt() ?? 0,
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
      bestStreak: (json['bestStreak'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      milestones: (json['milestones'] as List<dynamic>?)
              ?.map(
                  (e) => TalismanMilestone.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$TalismanStatsImplToJson(_$TalismanStatsImpl instance) =>
    <String, dynamic>{
      'talismanId': instance.talismanId,
      'totalDays': instance.totalDays,
      'averageScore': instance.averageScore,
      'bestStreak': instance.bestStreak,
      'currentStreak': instance.currentStreak,
      'milestones': instance.milestones,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };

_$TalismanMilestoneImpl _$$TalismanMilestoneImplFromJson(
        Map<String, dynamic> json) =>
    _$TalismanMilestoneImpl(
      title: json['title'] as String,
      description: json['description'] as String,
      achievedAt: DateTime.parse(json['achievedAt'] as String),
      type: json['type'] as String? ?? 'achievement',
    );

Map<String, dynamic> _$$TalismanMilestoneImplToJson(
        _$TalismanMilestoneImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'achievedAt': instance.achievedAt.toIso8601String(),
      'type': instance.type,
    };
