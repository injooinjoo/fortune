// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'celebrity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExternalIds _$ExternalIdsFromJson(Map<String, dynamic> json) => ExternalIds(
      wikipedia: json['wikipedia'] as String?,
      imdb: json['imdb'] as String?,
      youtube: json['youtube'] as String?,
      twitch: json['twitch'] as String?,
      instagram: json['instagram'] as String?,
      x: json['x'] as String?,
    );

Map<String, dynamic> _$ExternalIdsToJson(ExternalIds instance) =>
    <String, dynamic>{
      'wikipedia': instance.wikipedia,
      'imdb': instance.imdb,
      'youtube': instance.youtube,
      'twitch': instance.twitch,
      'instagram': instance.instagram,
      'x': instance.x,
    };

ProGamerData _$ProGamerDataFromJson(Map<String, dynamic> json) => ProGamerData(
      gameTitle: json['gameTitle'] as String?,
      primaryRole: json['primaryRole'] as String?,
      team: json['team'] as String?,
      leagueRegion: json['leagueRegion'] as String?,
      jerseyNumber: json['jerseyNumber'] as String?,
      careerHighlights: (json['careerHighlights'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      ign: json['ign'] as String?,
      proDebut: json['proDebut'] as String?,
      retired: json['retired'] as bool? ?? false,
    );

Map<String, dynamic> _$ProGamerDataToJson(ProGamerData instance) =>
    <String, dynamic>{
      'gameTitle': instance.gameTitle,
      'primaryRole': instance.primaryRole,
      'team': instance.team,
      'leagueRegion': instance.leagueRegion,
      'jerseyNumber': instance.jerseyNumber,
      'careerHighlights': instance.careerHighlights,
      'ign': instance.ign,
      'proDebut': instance.proDebut,
      'retired': instance.retired,
    };

StreamerData _$StreamerDataFromJson(Map<String, dynamic> json) => StreamerData(
      mainPlatform: json['mainPlatform'] as String?,
      channelUrl: json['channelUrl'] as String?,
      affiliation: json['affiliation'] as String?,
      contentGenres: (json['contentGenres'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      streamSchedule: json['streamSchedule'] as String?,
      firstStreamDate: json['firstStreamDate'] as String?,
      avgViewersBucket: json['avgViewersBucket'] as String?,
    );

Map<String, dynamic> _$StreamerDataToJson(StreamerData instance) =>
    <String, dynamic>{
      'mainPlatform': instance.mainPlatform,
      'channelUrl': instance.channelUrl,
      'affiliation': instance.affiliation,
      'contentGenres': instance.contentGenres,
      'streamSchedule': instance.streamSchedule,
      'firstStreamDate': instance.firstStreamDate,
      'avgViewersBucket': instance.avgViewersBucket,
    };

PoliticianData _$PoliticianDataFromJson(Map<String, dynamic> json) =>
    PoliticianData(
      party: json['party'] as String?,
      currentOffice: json['currentOffice'] as String?,
      constituency: json['constituency'] as String?,
      termStart: json['termStart'] as String?,
      termEnd: json['termEnd'] as String?,
      previousOffices: (json['previousOffices'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      ideologyTags: (json['ideologyTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$PoliticianDataToJson(PoliticianData instance) =>
    <String, dynamic>{
      'party': instance.party,
      'currentOffice': instance.currentOffice,
      'constituency': instance.constituency,
      'termStart': instance.termStart,
      'termEnd': instance.termEnd,
      'previousOffices': instance.previousOffices,
      'ideologyTags': instance.ideologyTags,
    };

BusinessData _$BusinessDataFromJson(Map<String, dynamic> json) => BusinessData(
      companyName: json['companyName'] as String?,
      title: json['title'] as String?,
      industry: json['industry'] as String?,
      foundedYear: json['foundedYear'] as String?,
      boardMemberships: (json['boardMemberships'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      notableVentures: (json['notableVentures'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$BusinessDataToJson(BusinessData instance) =>
    <String, dynamic>{
      'companyName': instance.companyName,
      'title': instance.title,
      'industry': instance.industry,
      'foundedYear': instance.foundedYear,
      'boardMemberships': instance.boardMemberships,
      'notableVentures': instance.notableVentures,
    };

SoloSingerData _$SoloSingerDataFromJson(Map<String, dynamic> json) =>
    SoloSingerData(
      debutDate: json['debutDate'] as String?,
      label: json['label'] as String?,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      fandomName: json['fandomName'] as String?,
      vocalRange: json['vocalRange'] as String?,
      notableTracks: (json['notableTracks'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SoloSingerDataToJson(SoloSingerData instance) =>
    <String, dynamic>{
      'debutDate': instance.debutDate,
      'label': instance.label,
      'genres': instance.genres,
      'fandomName': instance.fandomName,
      'vocalRange': instance.vocalRange,
      'notableTracks': instance.notableTracks,
    };

IdolMemberData _$IdolMemberDataFromJson(Map<String, dynamic> json) =>
    IdolMemberData(
      groupName: json['groupName'] as String?,
      position: (json['position'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      debutDate: json['debutDate'] as String?,
      label: json['label'] as String?,
      fandomName: json['fandomName'] as String?,
      subUnits: (json['subUnits'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      soloActivities: (json['soloActivities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$IdolMemberDataToJson(IdolMemberData instance) =>
    <String, dynamic>{
      'groupName': instance.groupName,
      'position': instance.position,
      'debutDate': instance.debutDate,
      'label': instance.label,
      'fandomName': instance.fandomName,
      'subUnits': instance.subUnits,
      'soloActivities': instance.soloActivities,
    };

ActorData _$ActorDataFromJson(Map<String, dynamic> json) => ActorData(
      actingDebut: json['actingDebut'] as String?,
      agency: json['agency'] as String?,
      specialties: (json['specialties'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      notableWorks: (json['notableWorks'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      awards: (json['awards'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ActorDataToJson(ActorData instance) => <String, dynamic>{
      'actingDebut': instance.actingDebut,
      'agency': instance.agency,
      'specialties': instance.specialties,
      'notableWorks': instance.notableWorks,
      'awards': instance.awards,
    };

AthleteData _$AthleteDataFromJson(Map<String, dynamic> json) => AthleteData(
      sport: json['sport'] as String?,
      positionRole: json['positionRole'] as String?,
      team: json['team'] as String?,
      league: json['league'] as String?,
      dominantHandFoot: json['dominantHandFoot'] as String?,
      proDebut: json['proDebut'] as String?,
      careerHighlights: (json['careerHighlights'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      recordsPersonalBests: (json['recordsPersonalBests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$AthleteDataToJson(AthleteData instance) =>
    <String, dynamic>{
      'sport': instance.sport,
      'positionRole': instance.positionRole,
      'team': instance.team,
      'league': instance.league,
      'dominantHandFoot': instance.dominantHandFoot,
      'proDebut': instance.proDebut,
      'careerHighlights': instance.careerHighlights,
      'recordsPersonalBests': instance.recordsPersonalBests,
    };

Celebrity _$CelebrityFromJson(Map<String, dynamic> json) => Celebrity(
      id: json['id'] as String,
      name: json['name'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      celebrityType: $enumDecode(_$CelebrityTypeEnumMap, json['celebrityType']),
      stageName: json['stageName'] as String?,
      legalName: json['legalName'] as String?,
      aliases: (json['aliases'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      nationality: json['nationality'] as String? ?? '한국',
      birthPlace: json['birthPlace'] as String?,
      birthTime: _timeFromJson(json['birthTime'] as String?),
      mbti: $enumDecodeNullable(_$MbtiTypeEnumMap, json['mbti']),
      bloodType: $enumDecodeNullable(_$BloodTypeEnumMap, json['bloodType']),
      isGroupMember: json['isGroupMember'] as bool? ?? false,
      groupName: json['groupName'] as String?,
      activeFrom: (json['activeFrom'] as num?)?.toInt(),
      agencyManagement: json['agencyManagement'] as String?,
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['한국어'],
      externalIds: json['externalIds'] == null
          ? null
          : ExternalIds.fromJson(json['externalIds'] as Map<String, dynamic>),
      professionData: json['professionData'] as Map<String, dynamic>?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CelebrityToJson(Celebrity instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'birthDate': instance.birthDate.toIso8601String(),
      'gender': _$GenderEnumMap[instance.gender]!,
      'celebrityType': _$CelebrityTypeEnumMap[instance.celebrityType]!,
      'stageName': instance.stageName,
      'legalName': instance.legalName,
      'aliases': instance.aliases,
      'nationality': instance.nationality,
      'birthPlace': instance.birthPlace,
      'birthTime': _timeToJson(instance.birthTime),
      'mbti': _$MbtiTypeEnumMap[instance.mbti],
      'bloodType': _$BloodTypeEnumMap[instance.bloodType],
      'isGroupMember': instance.isGroupMember,
      'groupName': instance.groupName,
      'activeFrom': instance.activeFrom,
      'agencyManagement': instance.agencyManagement,
      'languages': instance.languages,
      'externalIds': instance.externalIds,
      'professionData': instance.professionData,
      'notes': instance.notes,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.other: 'other',
};

const _$CelebrityTypeEnumMap = {
  CelebrityType.proGamer: 'pro_gamer',
  CelebrityType.streamer: 'streamer',
  CelebrityType.youtuber: 'youtuber',
  CelebrityType.politician: 'politician',
  CelebrityType.business: 'business',
  CelebrityType.businessLeader: 'business_leader',
  CelebrityType.entertainer: 'entertainer',
  CelebrityType.singer: 'singer',
  CelebrityType.soloSinger: 'solo_singer',
  CelebrityType.idolMember: 'idol_member',
  CelebrityType.actor: 'actor',
  CelebrityType.athlete: 'athlete',
};

const _$MbtiTypeEnumMap = {
  MbtiType.intj: 'INTJ',
  MbtiType.intp: 'INTP',
  MbtiType.entj: 'ENTJ',
  MbtiType.entp: 'ENTP',
  MbtiType.infj: 'INFJ',
  MbtiType.infp: 'INFP',
  MbtiType.enfj: 'ENFJ',
  MbtiType.enfp: 'ENFP',
  MbtiType.istj: 'ISTJ',
  MbtiType.isfj: 'ISFJ',
  MbtiType.estj: 'ESTJ',
  MbtiType.esfj: 'ESFJ',
  MbtiType.istp: 'ISTP',
  MbtiType.isfp: 'ISFP',
  MbtiType.estp: 'ESTP',
  MbtiType.esfp: 'ESFP',
};

const _$BloodTypeEnumMap = {
  BloodType.a: 'A',
  BloodType.b: 'B',
  BloodType.o: 'O',
  BloodType.ab: 'AB',
};

CelebrityFilter _$CelebrityFilterFromJson(Map<String, dynamic> json) =>
    CelebrityFilter(
      celebrityType:
          $enumDecodeNullable(_$CelebrityTypeEnumMap, json['celebrityType']),
      gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
      minAge: (json['minAge'] as num?)?.toInt(),
      maxAge: (json['maxAge'] as num?)?.toInt(),
      searchQuery: json['searchQuery'] as String?,
      nationality: json['nationality'] as String?,
      zodiacSign: json['zodiacSign'] as String?,
      chineseZodiac: json['chineseZodiac'] as String?,
      mbti: $enumDecodeNullable(_$MbtiTypeEnumMap, json['mbti']),
      bloodType: $enumDecodeNullable(_$BloodTypeEnumMap, json['bloodType']),
      isGroupMember: json['isGroupMember'] as bool?,
      groupName: json['groupName'] as String?,
    );

Map<String, dynamic> _$CelebrityFilterToJson(CelebrityFilter instance) =>
    <String, dynamic>{
      'celebrityType': _$CelebrityTypeEnumMap[instance.celebrityType],
      'gender': _$GenderEnumMap[instance.gender],
      'minAge': instance.minAge,
      'maxAge': instance.maxAge,
      'searchQuery': instance.searchQuery,
      'nationality': instance.nationality,
      'zodiacSign': instance.zodiacSign,
      'chineseZodiac': instance.chineseZodiac,
      'mbti': _$MbtiTypeEnumMap[instance.mbti],
      'bloodType': _$BloodTypeEnumMap[instance.bloodType],
      'isGroupMember': instance.isGroupMember,
      'groupName': instance.groupName,
    };
