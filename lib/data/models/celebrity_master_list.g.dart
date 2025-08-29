// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'celebrity_master_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CelebrityMasterListItem _$CelebrityMasterListItemFromJson(
        Map<String, dynamic> json) =>
    CelebrityMasterListItem(
      id: json['id'] as String,
      name: json['name'] as String,
      nameEn: json['nameEn'] as String?,
      category: $enumDecode(_$CelebrityMasterCategoryEnumMap, json['category']),
      subcategory: $enumDecodeNullable(
          _$CelebritySubcategoryEnumMap, json['subcategory']),
      popularityRank: (json['popularityRank'] as num).toInt(),
      searchVolume: (json['searchVolume'] as num?)?.toInt(),
      lastActive: json['lastActive'] as String?,
      isCrawled: json['isCrawled'] as bool? ?? false,
      crawlPriority: (json['crawlPriority'] as num?)?.toInt() ?? 0,
      description: json['description'] as String?,
      keywords: (json['keywords'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      platform: json['platform'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CelebrityMasterListItemToJson(
        CelebrityMasterListItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nameEn': instance.nameEn,
      'category': _$CelebrityMasterCategoryEnumMap[instance.category]!,
      'subcategory': _$CelebritySubcategoryEnumMap[instance.subcategory],
      'popularityRank': instance.popularityRank,
      'searchVolume': instance.searchVolume,
      'lastActive': instance.lastActive,
      'isCrawled': instance.isCrawled,
      'crawlPriority': instance.crawlPriority,
      'description': instance.description,
      'keywords': instance.keywords,
      'platform': instance.platform,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$CelebrityMasterCategoryEnumMap = {
  CelebrityMasterCategory.singer: 'singer',
  CelebrityMasterCategory.actor: 'actor',
  CelebrityMasterCategory.streamer: 'streamer',
  CelebrityMasterCategory.youtuber: 'youtuber',
  CelebrityMasterCategory.politician: 'politician',
  CelebrityMasterCategory.business: 'business',
  CelebrityMasterCategory.comedian: 'comedian',
  CelebrityMasterCategory.athlete: 'athlete',
  CelebrityMasterCategory.influencer: 'influencer',
  CelebrityMasterCategory.broadcaster: 'broadcaster',
  CelebrityMasterCategory.model: 'model',
  CelebrityMasterCategory.author: 'author',
  CelebrityMasterCategory.musician: 'musician',
  CelebrityMasterCategory.professor: 'professor',
  CelebrityMasterCategory.chef: 'chef',
  CelebrityMasterCategory.proGamer: 'proGamer',
  CelebrityMasterCategory.other: 'other',
};

const _$CelebritySubcategoryEnumMap = {
  CelebritySubcategory.soloSinger: 'soloSinger',
  CelebritySubcategory.idolGroup: 'idolGroup',
  CelebritySubcategory.hiphopRapper: 'hiphopRapper',
  CelebritySubcategory.ballad: 'ballad',
  CelebritySubcategory.trot: 'trot',
  CelebritySubcategory.rock: 'rock',
  CelebritySubcategory.indie: 'indie',
  CelebritySubcategory.movieActor: 'movieActor',
  CelebritySubcategory.dramaActor: 'dramaActor',
  CelebritySubcategory.musicalActor: 'musicalActor',
  CelebritySubcategory.voiceActor: 'voiceActor',
  CelebritySubcategory.childActor: 'childActor',
  CelebritySubcategory.twitchStreamer: 'twitchStreamer',
  CelebritySubcategory.afreecaTVStreamer: 'afreecaTVStreamer',
  CelebritySubcategory.chzzkStreamer: 'chzzkStreamer',
  CelebritySubcategory.gameStreamer: 'gameStreamer',
  CelebritySubcategory.talkStreamer: 'talkStreamer',
  CelebritySubcategory.entertainmentYoutuber: 'entertainmentYoutuber',
  CelebritySubcategory.gameYoutuber: 'gameYoutuber',
  CelebritySubcategory.mukbangYoutuber: 'mukbangYoutuber',
  CelebritySubcategory.educationYoutuber: 'educationYoutuber',
  CelebritySubcategory.beautyYoutuber: 'beautyYoutuber',
  CelebritySubcategory.fashionYoutuber: 'fashionYoutuber',
  CelebritySubcategory.techYoutuber: 'techYoutuber',
  CelebritySubcategory.president: 'president',
  CelebritySubcategory.primeMinister: 'primeMinister',
  CelebritySubcategory.minister: 'minister',
  CelebritySubcategory.assemblyman: 'assemblyman',
  CelebritySubcategory.partyLeader: 'partyLeader',
  CelebritySubcategory.governor: 'governor',
  CelebritySubcategory.mayor: 'mayor',
  CelebritySubcategory.chaeboCEO: 'chaeboCEO',
  CelebritySubcategory.startupFounder: 'startupFounder',
  CelebritySubcategory.techCEO: 'techCEO',
  CelebritySubcategory.footballPlayer: 'footballPlayer',
  CelebritySubcategory.baseballPlayer: 'baseballPlayer',
  CelebritySubcategory.basketballPlayer: 'basketballPlayer',
  CelebritySubcategory.golfPlayer: 'golfPlayer',
  CelebritySubcategory.tennisPlayer: 'tennisPlayer',
  CelebritySubcategory.figureSkater: 'figureSkater',
  CelebritySubcategory.swimmer: 'swimmer',
  CelebritySubcategory.trackAthlete: 'trackAthlete',
  CelebritySubcategory.martialArtist: 'martialArtist',
  CelebritySubcategory.esportsPlayer: 'esportsPlayer',
  CelebritySubcategory.none: 'none',
};

CelebrityCategoryList _$CelebrityCategoryListFromJson(
        Map<String, dynamic> json) =>
    CelebrityCategoryList(
      category: $enumDecode(_$CelebrityMasterCategoryEnumMap, json['category']),
      categoryDisplayName: json['categoryDisplayName'] as String,
      totalCount: (json['totalCount'] as num).toInt(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      celebrities: (json['celebrities'] as List<dynamic>)
          .map((e) =>
              CelebrityMasterListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CelebrityCategoryListToJson(
        CelebrityCategoryList instance) =>
    <String, dynamic>{
      'category': _$CelebrityMasterCategoryEnumMap[instance.category]!,
      'categoryDisplayName': instance.categoryDisplayName,
      'totalCount': instance.totalCount,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'celebrities': instance.celebrities,
    };
