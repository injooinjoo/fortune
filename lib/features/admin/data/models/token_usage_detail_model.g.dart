// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_usage_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TokenUsageDetailModelImpl _$$TokenUsageDetailModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TokenUsageDetailModelImpl(
      summary:
          TokenUsageSummary.fromJson(json['summary'] as Map<String, dynamic>),
      dailyUsage: (json['dailyUsage'] as List<dynamic>)
          .map((e) => DailyTokenUsage.fromJson(e as Map<String, dynamic>))
          .toList(),
      usageByType: (json['usageByType'] as List<dynamic>)
          .map((e) => TokenUsageByType.fromJson(e as Map<String, dynamic>))
          .toList(),
      topUsers: (json['topUsers'] as List<dynamic>)
          .map((e) => TopUserUsage.fromJson(e as Map<String, dynamic>))
          .toList(),
      packageEfficiency: PackageEfficiency.fromJson(
          json['packageEfficiency'] as Map<String, dynamic>),
      trend: TokenUsageTrend.fromJson(json['trend'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$TokenUsageDetailModelImplToJson(
        _$TokenUsageDetailModelImpl instance) =>
    <String, dynamic>{
      'summary': instance.summary,
      'dailyUsage': instance.dailyUsage,
      'usageByType': instance.usageByType,
      'topUsers': instance.topUsers,
      'packageEfficiency': instance.packageEfficiency,
      'trend': instance.trend,
    };

_$TokenUsageSummaryImpl _$$TokenUsageSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$TokenUsageSummaryImpl(
      totalTokensUsed: (json['totalTokensUsed'] as num).toInt(),
      totalTokensPurchased: (json['totalTokensPurchased'] as num).toInt(),
      activeUsers: (json['activeUsers'] as num).toInt(),
      averageUsagePerUser: (json['averageUsagePerUser'] as num).toDouble(),
      period: json['period'] as String,
    );

Map<String, dynamic> _$$TokenUsageSummaryImplToJson(
        _$TokenUsageSummaryImpl instance) =>
    <String, dynamic>{
      'totalTokensUsed': instance.totalTokensUsed,
      'totalTokensPurchased': instance.totalTokensPurchased,
      'activeUsers': instance.activeUsers,
      'averageUsagePerUser': instance.averageUsagePerUser,
      'period': instance.period,
    };

_$DailyTokenUsageImpl _$$DailyTokenUsageImplFromJson(
        Map<String, dynamic> json) =>
    _$DailyTokenUsageImpl(
      date: DateTime.parse(json['date'] as String),
      tokensUsed: (json['tokensUsed'] as num).toInt(),
      tokensPurchased: (json['tokensPurchased'] as num).toInt(),
      uniqueUsers: (json['uniqueUsers'] as num).toInt(),
      transactions: (json['transactions'] as num).toInt(),
    );

Map<String, dynamic> _$$DailyTokenUsageImplToJson(
        _$DailyTokenUsageImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'tokensUsed': instance.tokensUsed,
      'tokensPurchased': instance.tokensPurchased,
      'uniqueUsers': instance.uniqueUsers,
      'transactions': instance.transactions,
    };

_$TokenUsageByTypeImpl _$$TokenUsageByTypeImplFromJson(
        Map<String, dynamic> json) =>
    _$TokenUsageByTypeImpl(
      fortuneType: json['fortuneType'] as String,
      fortuneCategory: json['fortuneCategory'] as String,
      tokensUsed: (json['tokensUsed'] as num).toInt(),
      usageCount: (json['usageCount'] as num).toInt(),
      percentage: (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$$TokenUsageByTypeImplToJson(
        _$TokenUsageByTypeImpl instance) =>
    <String, dynamic>{
      'fortuneType': instance.fortuneType,
      'fortuneCategory': instance.fortuneCategory,
      'tokensUsed': instance.tokensUsed,
      'usageCount': instance.usageCount,
      'percentage': instance.percentage,
    };

_$TopUserUsageImpl _$$TopUserUsageImplFromJson(Map<String, dynamic> json) =>
    _$TopUserUsageImpl(
      userId: json['userId'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      tokensUsed: (json['tokensUsed'] as num).toInt(),
      tokensPurchased: (json['tokensPurchased'] as num).toInt(),
      fortuneCount: (json['fortuneCount'] as num).toInt(),
      lastActivity: DateTime.parse(json['lastActivity'] as String),
      isUnlimited: json['isUnlimited'] as bool,
    );

Map<String, dynamic> _$$TopUserUsageImplToJson(_$TopUserUsageImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'email': instance.email,
      'displayName': instance.displayName,
      'tokensUsed': instance.tokensUsed,
      'tokensPurchased': instance.tokensPurchased,
      'fortuneCount': instance.fortuneCount,
      'lastActivity': instance.lastActivity.toIso8601String(),
      'isUnlimited': instance.isUnlimited,
    };

_$PackageEfficiencyImpl _$$PackageEfficiencyImplFromJson(
        Map<String, dynamic> json) =>
    _$PackageEfficiencyImpl(
      packages: (json['packages'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, PackageStats.fromJson(e as Map<String, dynamic>)),
      ),
      mostPopular: json['mostPopular'] as String,
      bestValue: json['bestValue'] as String,
    );

Map<String, dynamic> _$$PackageEfficiencyImplToJson(
        _$PackageEfficiencyImpl instance) =>
    <String, dynamic>{
      'packages': instance.packages,
      'mostPopular': instance.mostPopular,
      'bestValue': instance.bestValue,
    };

_$PackageStatsImpl _$$PackageStatsImplFromJson(Map<String, dynamic> json) =>
    _$PackageStatsImpl(
      packageName: json['packageName'] as String,
      purchaseCount: (json['purchaseCount'] as num).toInt(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      conversionRate: (json['conversionRate'] as num).toDouble(),
    );

Map<String, dynamic> _$$PackageStatsImplToJson(_$PackageStatsImpl instance) =>
    <String, dynamic>{
      'packageName': instance.packageName,
      'purchaseCount': instance.purchaseCount,
      'totalRevenue': instance.totalRevenue,
      'conversionRate': instance.conversionRate,
    };

_$TokenUsageTrendImpl _$$TokenUsageTrendImplFromJson(
        Map<String, dynamic> json) =>
    _$TokenUsageTrendImpl(
      dailyGrowth: (json['dailyGrowth'] as num).toDouble(),
      weeklyGrowth: (json['weeklyGrowth'] as num).toDouble(),
      monthlyGrowth: (json['monthlyGrowth'] as num).toDouble(),
      trendDirection: json['trendDirection'] as String,
      peakTimes: (json['peakTimes'] as List<dynamic>)
          .map((e) => PeakUsageTime.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$TokenUsageTrendImplToJson(
        _$TokenUsageTrendImpl instance) =>
    <String, dynamic>{
      'dailyGrowth': instance.dailyGrowth,
      'weeklyGrowth': instance.weeklyGrowth,
      'monthlyGrowth': instance.monthlyGrowth,
      'trendDirection': instance.trendDirection,
      'peakTimes': instance.peakTimes,
    };

_$PeakUsageTimeImpl _$$PeakUsageTimeImplFromJson(Map<String, dynamic> json) =>
    _$PeakUsageTimeImpl(
      hour: (json['hour'] as num).toInt(),
      dayOfWeek: json['dayOfWeek'] as String,
      averageTokens: (json['averageTokens'] as num).toDouble(),
      userCount: (json['userCount'] as num).toInt(),
    );

Map<String, dynamic> _$$PeakUsageTimeImplToJson(_$PeakUsageTimeImpl instance) =>
    <String, dynamic>{
      'hour': instance.hour,
      'dayOfWeek': instance.dayOfWeek,
      'averageTokens': instance.averageTokens,
      'userCount': instance.userCount,
    };
