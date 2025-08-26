// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'talisman_wish.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TalismanWishImpl _$$TalismanWishImplFromJson(Map<String, dynamic> json) =>
    _$TalismanWishImpl(
      id: json['id'] as String,
      category: $enumDecode(_$TalismanCategoryEnumMap, json['category']),
      specificWish: json['specificWish'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: json['userId'] as String?,
    );

Map<String, dynamic> _$$TalismanWishImplToJson(_$TalismanWishImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': _$TalismanCategoryEnumMap[instance.category]!,
      'specificWish': instance.specificWish,
      'createdAt': instance.createdAt.toIso8601String(),
      'userId': instance.userId,
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
