// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AdminStatsModelImpl _$$AdminStatsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AdminStatsModelImpl(
      totalUsers: (json['totalUsers'] as num).toInt(),
      activeUsers: (json['activeUsers'] as num).toInt(),
      totalFortunes: (json['totalFortunes'] as num).toInt(),
      todayFortunes: (json['todayFortunes'] as num).toInt(),
      totalTokensUsed: (json['totalTokensUsed'] as num).toInt(),
      totalRevenue: (json['totalRevenue'] as num).toInt(),
      fortuneTypeStats: Map<String, int>.from(json['fortuneTypeStats'] as Map),
      dailyStats: (json['dailyStats'] as List<dynamic>)
          .map((e) => DailyStatModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      tokenUsageStats: (json['tokenUsageStats'] as List<dynamic>)
          .map((e) => TokenUsageModel.fromJson(e as Map<String, dynamic>))
          .toList());

Map<String, dynamic> _$$AdminStatsModelImplToJson(
        _$AdminStatsModelImpl instance) =>
    <String, dynamic>{
      'totalUsers': instance.totalUsers,
      'activeUsers': instance.activeUsers,
      'totalFortunes': instance.totalFortunes,
      'todayFortunes': instance.todayFortunes,
      'totalTokensUsed': instance.totalTokensUsed,
      'totalRevenue': instance.totalRevenue,
      'fortuneTypeStats': instance.fortuneTypeStats,
      'dailyStats': instance.dailyStats,
      'tokenUsageStats': instance.tokenUsageStats};

_$DailyStatModelImpl _$$DailyStatModelImplFromJson(Map<String, dynamic> json) =>
    _$DailyStatModelImpl(
      date: DateTime.parse(json['date'] as String),
      fortunes: (json['fortunes'] as num).toInt(),
      users: (json['users'] as num).toInt(),
      tokens: (json['tokens'] as num).toInt(),
      revenue: (json['revenue'] as num).toInt());

Map<String, dynamic> _$$DailyStatModelImplToJson(
        _$DailyStatModelImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'fortunes': instance.fortunes,
      'users': instance.users,
      'tokens': instance.tokens,
      'revenue': instance.revenue};

_$TokenUsageModelImpl _$$TokenUsageModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TokenUsageModelImpl(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      tokensUsed: (json['tokensUsed'] as num).toInt(),
      fortuneCount: (json['fortuneCount'] as num).toInt(),
      lastActivity: DateTime.parse(json['lastActivity'] as String),
      isSubscribed: json['isSubscribed'] as bool);

Map<String, dynamic> _$$TokenUsageModelImplToJson(
        _$TokenUsageModelImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'userName': instance.userName,
      'tokensUsed': instance.tokensUsed,
      'fortuneCount': instance.fortuneCount,
      'lastActivity': instance.lastActivity.toIso8601String(),
      'isSubscribed': instance.isSubscribed};
