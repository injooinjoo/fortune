// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'talisman_design.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TalismanDesignImpl _$$TalismanDesignImplFromJson(Map<String, dynamic> json) =>
    _$TalismanDesignImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      designType: $enumDecodeNullable(
              _$TalismanDesignTypeEnumMap, json['design_type']) ??
          TalismanDesignType.traditional,
      category: $enumDecode(_$TalismanCategoryEnumMap, json['category']),
      title: json['title'] as String,
      imageUrl: json['image_url'] as String,
      colors: json['colors'] as Map<String, dynamic>? ?? const {},
      symbols: json['symbols'] as Map<String, dynamic>? ?? const {},
      mantraText: json['mantra_text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      isPremium: json['is_premium'] as bool? ?? false,
      effectScore: (json['effect_score'] as num?)?.toInt() ?? 0,
      blessings: (json['blessings'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isAIGenerated: json['is_ai_generated'] as bool? ?? false,
      customCharacters: (json['custom_characters'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      generationPrompt: json['generation_prompt'] as String?,
    );

Map<String, dynamic> _$$TalismanDesignImplToJson(
        _$TalismanDesignImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'design_type': _$TalismanDesignTypeEnumMap[instance.designType]!,
      'category': _$TalismanCategoryEnumMap[instance.category]!,
      'title': instance.title,
      'image_url': instance.imageUrl,
      'colors': instance.colors,
      'symbols': instance.symbols,
      'mantra_text': instance.mantraText,
      'created_at': instance.createdAt.toIso8601String(),
      'expires_at': instance.expiresAt?.toIso8601String(),
      'is_premium': instance.isPremium,
      'effect_score': instance.effectScore,
      'blessings': instance.blessings,
      'is_ai_generated': instance.isAIGenerated,
      'custom_characters': instance.customCharacters,
      'generation_prompt': instance.generationPrompt,
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
