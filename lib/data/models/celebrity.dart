import 'package:json_annotation/json_annotation.dart';

part 'celebrity.g.dart';

// Celebrity type enum
enum CelebrityType {
  @JsonValue('pro_gamer')
  proGamer('프로게이머'),

  @JsonValue('streamer')
  streamer('스트리머'),

  @JsonValue('politician')
  politician('정치인'),

  @JsonValue('business')
  business('기업인'),

  @JsonValue('solo_singer')
  soloSinger('솔로 가수'),

  @JsonValue('idol_member')
  idolMember('아이돌 멤버'),

  @JsonValue('actor')
  actor('배우'),

  @JsonValue('athlete')
  athlete('운동선수');

  final String displayName;
  const CelebrityType(this.displayName);
}

// Gender enum
enum Gender {
  @JsonValue('male')
  male('남성'),

  @JsonValue('female')
  female('여성'),

  @JsonValue('other')
  other('기타');

  final String displayName;
  const Gender(this.displayName);
}

// External IDs structure
@JsonSerializable()
class ExternalIds {
  final String? wikipedia;
  final String? imdb;
  final String? youtube;
  final String? twitch;
  final String? instagram;
  final String? x; // formerly Twitter

  const ExternalIds({
    this.wikipedia,
    this.imdb,
    this.youtube,
    this.twitch,
    this.instagram,
    this.x,
  });

  factory ExternalIds.fromJson(Map<String, dynamic> json) => _$ExternalIdsFromJson(json);
  Map<String, dynamic> toJson() => _$ExternalIdsToJson(this);
}

// Base profession data interface
abstract class ProfessionData {
  Map<String, dynamic> toJson();
}

// Pro Gamer specific data
@JsonSerializable()
class ProGamerData implements ProfessionData {
  final String? gameTitle;
  final String? primaryRole;
  final String? team;
  final String? leagueRegion;
  final String? jerseyNumber;
  final List<String> careerHighlights;
  final String? ign; // In-game name
  final String? proDebut;
  final bool retired;

  const ProGamerData({
    this.gameTitle,
    this.primaryRole,
    this.team,
    this.leagueRegion,
    this.jerseyNumber,
    this.careerHighlights = const [],
    this.ign,
    this.proDebut,
    this.retired = false,
  });

  factory ProGamerData.fromJson(Map<String, dynamic> json) => _$ProGamerDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ProGamerDataToJson(this);
}

// Streamer specific data
@JsonSerializable()
class StreamerData implements ProfessionData {
  final String? mainPlatform;
  final String? channelUrl;
  final String? affiliation;
  final List<String> contentGenres;
  final String? streamSchedule;
  final String? firstStreamDate;
  final String? avgViewersBucket; // small, mid, large, top

  const StreamerData({
    this.mainPlatform,
    this.channelUrl,
    this.affiliation,
    this.contentGenres = const [],
    this.streamSchedule,
    this.firstStreamDate,
    this.avgViewersBucket,
  });

  factory StreamerData.fromJson(Map<String, dynamic> json) => _$StreamerDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$StreamerDataToJson(this);
}

// Politician specific data
@JsonSerializable()
class PoliticianData implements ProfessionData {
  final String? party;
  final String? currentOffice;
  final String? constituency;
  final String? termStart;
  final String? termEnd;
  final List<String> previousOffices;
  final List<String> ideologyTags;

  const PoliticianData({
    this.party,
    this.currentOffice,
    this.constituency,
    this.termStart,
    this.termEnd,
    this.previousOffices = const [],
    this.ideologyTags = const [],
  });

  factory PoliticianData.fromJson(Map<String, dynamic> json) => _$PoliticianDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$PoliticianDataToJson(this);
}

// Business leader specific data
@JsonSerializable()
class BusinessData implements ProfessionData {
  final String? companyName;
  final String? title;
  final String? industry;
  final String? foundedYear;
  final List<String> boardMemberships;
  final List<String> notableVentures;

  const BusinessData({
    this.companyName,
    this.title,
    this.industry,
    this.foundedYear,
    this.boardMemberships = const [],
    this.notableVentures = const [],
  });

  factory BusinessData.fromJson(Map<String, dynamic> json) => _$BusinessDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$BusinessDataToJson(this);
}

// Solo singer specific data
@JsonSerializable()
class SoloSingerData implements ProfessionData {
  final String? debutDate;
  final String? label;
  final List<String> genres;
  final String? fandomName;
  final String? vocalRange;
  final List<String> notableTracks;

  const SoloSingerData({
    this.debutDate,
    this.label,
    this.genres = const [],
    this.fandomName,
    this.vocalRange,
    this.notableTracks = const [],
  });

  factory SoloSingerData.fromJson(Map<String, dynamic> json) => _$SoloSingerDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$SoloSingerDataToJson(this);
}

// Idol member specific data
@JsonSerializable()
class IdolMemberData implements ProfessionData {
  final String? groupName;
  final List<String> position; // vocal, rap, dance, center, leader, maknae, visual
  final String? debutDate;
  final String? label;
  final String? fandomName;
  final List<String> subUnits;
  final List<String> soloActivities;

  const IdolMemberData({
    this.groupName,
    this.position = const [],
    this.debutDate,
    this.label,
    this.fandomName,
    this.subUnits = const [],
    this.soloActivities = const [],
  });

  factory IdolMemberData.fromJson(Map<String, dynamic> json) => _$IdolMemberDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$IdolMemberDataToJson(this);
}

// Actor specific data
@JsonSerializable()
class ActorData implements ProfessionData {
  final String? actingDebut;
  final String? agency;
  final List<String> specialties; // film, tv, theater, musical
  final List<String> notableWorks;
  final List<String> awards;

  const ActorData({
    this.actingDebut,
    this.agency,
    this.specialties = const [],
    this.notableWorks = const [],
    this.awards = const [],
  });

  factory ActorData.fromJson(Map<String, dynamic> json) => _$ActorDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ActorDataToJson(this);
}

// Athlete specific data
@JsonSerializable()
class AthleteData implements ProfessionData {
  final String? sport;
  final String? positionRole;
  final String? team;
  final String? league;
  final String? dominantHandFoot; // left, right, ambi
  final String? proDebut;
  final List<String> careerHighlights;
  final List<String> recordsPersonalBests;

  const AthleteData({
    this.sport,
    this.positionRole,
    this.team,
    this.league,
    this.dominantHandFoot,
    this.proDebut,
    this.careerHighlights = const [],
    this.recordsPersonalBests = const [],
  });

  factory AthleteData.fromJson(Map<String, dynamic> json) => _$AthleteDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$AthleteDataToJson(this);
}

// Main Celebrity class
@JsonSerializable()
class Celebrity {
  final String id;
  final String name; // 활동명
  final DateTime birthDate;
  final Gender gender;
  final CelebrityType celebrityType;

  // Optional identity fields
  final String? stageName; // 예명
  final String? legalName; // 본명
  final List<String> aliases; // 다른 표기/닉네임
  final String nationality; // 국적
  final String? birthPlace; // 출생지
  @JsonKey(fromJson: _timeFromJson, toJson: _timeToJson)
  final DateTime? birthTime; // 출생시각

  // Professional information
  final int? activeFrom; // 데뷔/프로 전향 연도
  final String? agencyManagement; // 소속
  final List<String> languages; // 사용 언어

  // External references
  final ExternalIds? externalIds;

  // Profession-specific data (as raw JSON for now)
  final Map<String, dynamic>? professionData;

  // General fields
  final String? notes; // 비고

  // System fields
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Celebrity({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.celebrityType,
    this.stageName,
    this.legalName,
    this.aliases = const [],
    this.nationality = '한국',
    this.birthPlace,
    this.birthTime,
    this.activeFrom,
    this.agencyManagement,
    this.languages = const ['한국어'],
    this.externalIds,
    this.professionData,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  // Helper methods
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String get zodiacSign {
    final month = birthDate.month;
    final day = birthDate.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return '양자리';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return '황소자리';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return '쌍둥이자리';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return '게자리';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return '사자자리';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return '처녀자리';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return '천칭자리';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return '전갈자리';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return '사수자리';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return '염소자리';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return '물병자리';
    return '물고기자리';
  }

  String get chineseZodiac {
    final zodiacAnimals = ['원숭이', '닭', '개', '돼지', '쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양'];
    return zodiacAnimals[birthDate.year % 12];
  }

  // Get display name (prefer stage name over name)
  String get displayName => stageName ?? name;

  // Get all possible names for search
  List<String> get allNames => [
    name,
    if (stageName != null) stageName!,
    if (legalName != null) legalName!,
    ...aliases,
  ];

  factory Celebrity.fromJson(Map<String, dynamic> json) => _$CelebrityFromJson(json);
  Map<String, dynamic> toJson() => _$CelebrityToJson(this);

  Celebrity copyWith({
    String? id,
    String? name,
    DateTime? birthDate,
    Gender? gender,
    CelebrityType? celebrityType,
    String? stageName,
    String? legalName,
    List<String>? aliases,
    String? nationality,
    String? birthPlace,
    DateTime? birthTime,
    int? activeFrom,
    String? agencyManagement,
    List<String>? languages,
    ExternalIds? externalIds,
    Map<String, dynamic>? professionData,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Celebrity(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      celebrityType: celebrityType ?? this.celebrityType,
      stageName: stageName ?? this.stageName,
      legalName: legalName ?? this.legalName,
      aliases: aliases ?? this.aliases,
      nationality: nationality ?? this.nationality,
      birthPlace: birthPlace ?? this.birthPlace,
      birthTime: birthTime ?? this.birthTime,
      activeFrom: activeFrom ?? this.activeFrom,
      agencyManagement: agencyManagement ?? this.agencyManagement,
      languages: languages ?? this.languages,
      externalIds: externalIds ?? this.externalIds,
      professionData: professionData ?? this.professionData,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Helper functions for JSON serialization
DateTime? _timeFromJson(String? timeString) {
  if (timeString == null) return null;
  try {
    final parts = timeString.split(':');
    if (parts.length == 2) {
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return DateTime(1970, 1, 1, hour, minute);
    }
  } catch (e) {
    return null;
  }
  return null;
}

String? _timeToJson(DateTime? time) {
  if (time == null) return null;
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

// Celebrity filter for searches
@JsonSerializable()
class CelebrityFilter {
  final CelebrityType? celebrityType;
  final Gender? gender;
  final int? minAge;
  final int? maxAge;
  final String? searchQuery;
  final String? nationality;
  final String? zodiacSign;
  final String? chineseZodiac;

  const CelebrityFilter({
    this.celebrityType,
    this.gender,
    this.minAge,
    this.maxAge,
    this.searchQuery,
    this.nationality,
    this.zodiacSign,
    this.chineseZodiac,
  });

  factory CelebrityFilter.fromJson(Map<String, dynamic> json) => _$CelebrityFilterFromJson(json);
  Map<String, dynamic> toJson() => _$CelebrityFilterToJson(this);
}