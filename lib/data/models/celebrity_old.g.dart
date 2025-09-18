// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'celebrity_old.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Celebrity _$CelebrityFromJson(Map<String, dynamic> json) => Celebrity(
      id: json['id'] as String,
      name: json['name'] as String,
      nameEn: json['nameEn'] as String,
      category: $enumDecode(_$CelebrityCategoryEnumMap, json['category']),
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      birthDate: DateTime.parse(json['birthDate'] as String),
      birthTime: json['birthTime'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      description: json['description'] as String?,
      keywords: (json['keywords'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      nationality: json['nationality'] as String? ?? '한국',
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CelebrityToJson(Celebrity instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nameEn': instance.nameEn,
      'category': _$CelebrityCategoryEnumMap[instance.category]!,
      'gender': _$GenderEnumMap[instance.gender]!,
      'birthDate': instance.birthDate.toIso8601String(),
      'birthTime': instance.birthTime,
      'profileImageUrl': instance.profileImageUrl,
      'description': instance.description,
      'keywords': instance.keywords,
      'nationality': instance.nationality,
      'additionalInfo': instance.additionalInfo,
    };

const _$CelebrityCategoryEnumMap = {
  CelebrityCategory.politician: 'politician',
  CelebrityCategory.actor: 'actor',
  CelebrityCategory.sports: 'sports',
  CelebrityCategory.proGamer: 'proGamer',
  CelebrityCategory.streamer: 'streamer',
  CelebrityCategory.youtuber: 'youtuber',
  CelebrityCategory.singer: 'singer',
  CelebrityCategory.businessLeader: 'businessLeader',
};

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.other: 'other',
};
