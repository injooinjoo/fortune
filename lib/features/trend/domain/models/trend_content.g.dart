// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trend_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrendContentImpl _$$TrendContentImplFromJson(Map<String, dynamic> json) =>
    _$TrendContentImpl(
      id: json['id'] as String,
      type: $enumDecode(_$TrendContentTypeEnumMap, json['type']),
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      category: $enumDecode(_$TrendCategoryEnumMap, json['category']),
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      participantCount: (json['participantCount'] as num?)?.toInt() ?? 0,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      isPremium: json['isPremium'] as bool? ?? false,
      tokenCost: (json['tokenCost'] as num?)?.toInt() ?? 0,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$TrendContentImplToJson(_$TrendContentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$TrendContentTypeEnumMap[instance.type]!,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'thumbnailUrl': instance.thumbnailUrl,
      'category': _$TrendCategoryEnumMap[instance.category]!,
      'viewCount': instance.viewCount,
      'participantCount': instance.participantCount,
      'likeCount': instance.likeCount,
      'shareCount': instance.shareCount,
      'isActive': instance.isActive,
      'isPremium': instance.isPremium,
      'tokenCost': instance.tokenCost,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'sortOrder': instance.sortOrder,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$TrendContentTypeEnumMap = {
  TrendContentType.psychologyTest: 'psychology_test',
  TrendContentType.idealWorldcup: 'ideal_worldcup',
  TrendContentType.balanceGame: 'balance_game',
};

const _$TrendCategoryEnumMap = {
  TrendCategory.love: 'love',
  TrendCategory.personality: 'personality',
  TrendCategory.lifestyle: 'lifestyle',
  TrendCategory.entertainment: 'entertainment',
  TrendCategory.food: 'food',
  TrendCategory.animal: 'animal',
  TrendCategory.work: 'work',
};

_$TrendContentListResponseImpl _$$TrendContentListResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$TrendContentListResponseImpl(
      contents: (json['contents'] as List<dynamic>)
          .map((e) => TrendContent.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      hasMore: json['hasMore'] as bool? ?? false,
    );

Map<String, dynamic> _$$TrendContentListResponseImplToJson(
        _$TrendContentListResponseImpl instance) =>
    <String, dynamic>{
      'contents': instance.contents,
      'totalCount': instance.totalCount,
      'hasMore': instance.hasMore,
    };
