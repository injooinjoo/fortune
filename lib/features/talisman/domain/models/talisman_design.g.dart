// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'talisman_design.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TalismanDesignImpl _$$TalismanDesignImplFromJson(Map<String, dynamic> json) =>
    _$TalismanDesignImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      designType: $enumDecode(_$TalismanDesignTypeEnumMap, json['designType']),
      category: $enumDecode(_$TalismanCategoryEnumMap, json['category']),
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      colors: json['colors'] as Map<String, dynamic>? ?? const {},
      symbols: json['symbols'] as Map<String, dynamic>? ?? const {},
      mantraText: json['mantraText'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      isPremium: json['isPremium'] as bool? ?? false,
      effectScore: (json['effectScore'] as num?)?.toInt() ?? 0,
      blessings: (json['blessings'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$TalismanDesignImplToJson(
        _$TalismanDesignImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'designType': _$TalismanDesignTypeEnumMap[instance.designType]!,
      'category': _$TalismanCategoryEnumMap[instance.category]!,
      'title': instance.title,
      'imageUrl': instance.imageUrl,
      'colors': instance.colors,
      'symbols': instance.symbols,
      'mantraText': instance.mantraText,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'isPremium': instance.isPremium,
      'effectScore': instance.effectScore,
      'blessings': instance.blessings,
    };

const _$TalismanDesignTypeEnumMap = {
  TalismanDesignType.traditional: 'traditional',
  TalismanDesignType.modern: 'modern',
  TalismanDesignType.geometric: 'geometric',
  TalismanDesignType.nature: 'nature',
};

const _$TalismanCategoryEnumMap = {
  TalismanCategory.relationship: 'relationship',
  TalismanCategory.wealth: 'wealth',
  TalismanCategory.career: 'career',
  TalismanCategory.love: 'love',
  TalismanCategory.study: 'study',
  TalismanCategory.health: 'health',
  TalismanCategory.goal: 'goal',
};
