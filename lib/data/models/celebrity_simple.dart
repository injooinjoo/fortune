// Simplified Celebrity model without JSON serialization for now
// This avoids the build_runner issues while keeping functionality

enum CelebrityType {
  proGamer('프로게이머'),
  streamer('스트리머'),
  politician('정치인'),
  business('기업인'),
  soloSinger('솔로 가수'),
  idolMember('아이돌 멤버'),
  actor('배우'),
  athlete('운동선수');

  final String displayName;
  const CelebrityType(this.displayName);

  String get name {
    switch (this) {
      case CelebrityType.proGamer:
        return 'pro_gamer';
      case CelebrityType.streamer:
        return 'streamer';
      case CelebrityType.politician:
        return 'politician';
      case CelebrityType.business:
        return 'business';
      case CelebrityType.soloSinger:
        return 'solo_singer';
      case CelebrityType.idolMember:
        return 'idol_member';
      case CelebrityType.actor:
        return 'actor';
      case CelebrityType.athlete:
        return 'athlete';
    }
  }

  static CelebrityType fromString(String value) {
    switch (value) {
      case 'pro_gamer':
        return CelebrityType.proGamer;
      case 'streamer':
        return CelebrityType.streamer;
      case 'politician':
        return CelebrityType.politician;
      case 'business':
        return CelebrityType.business;
      case 'solo_singer':
        return CelebrityType.soloSinger;
      case 'idol_member':
        return CelebrityType.idolMember;
      case 'actor':
        return CelebrityType.actor;
      case 'athlete':
        return CelebrityType.athlete;
      default:
        throw ArgumentError('Unknown celebrity type: $value');
    }
  }
}

enum Gender {
  male('남성'),
  female('여성'),
  other('기타');

  final String displayName;
  const Gender(this.displayName);

  String get name {
    switch (this) {
      case Gender.male:
        return 'male';
      case Gender.female:
        return 'female';
      case Gender.other:
        return 'other';
    }
  }

  static Gender fromString(String value) {
    switch (value) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      case 'other':
        return Gender.other;
      default:
        throw ArgumentError('Unknown gender: $value');
    }
  }
}

class ExternalIds {
  final String? wikipedia;
  final String? imdb;
  final String? youtube;
  final String? twitch;
  final String? instagram;
  final String? x;

  const ExternalIds({
    this.wikipedia,
    this.imdb,
    this.youtube,
    this.twitch,
    this.instagram,
    this.x,
  });

  factory ExternalIds.fromJson(Map<String, dynamic> json) {
    return ExternalIds(
      wikipedia: json['wikipedia'] as String?,
      imdb: json['imdb'] as String?,
      youtube: json['youtube'] as String?,
      twitch: json['twitch'] as String?,
      instagram: json['instagram'] as String?,
      x: json['x'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (wikipedia != null) 'wikipedia': wikipedia,
      if (imdb != null) 'imdb': imdb,
      if (youtube != null) 'youtube': youtube,
      if (twitch != null) 'twitch': twitch,
      if (instagram != null) 'instagram': instagram,
      if (x != null) 'x': x,
    };
  }
}

class Celebrity {
  final String id;
  final String name;
  final DateTime birthDate;
  final Gender gender;
  final CelebrityType celebrityType;

  // Optional fields
  final String? stageName;
  final String? legalName;
  final List<String> aliases;
  final String nationality;
  final String? birthPlace;
  final DateTime? birthTime;

  // Professional information
  final int? activeFrom;
  final String? agencyManagement;
  final List<String> languages;

  // External references
  final ExternalIds? externalIds;

  // Profession-specific data
  final Map<String, dynamic>? professionData;

  // General fields
  final String? notes;

  // Avatar image URL (Notion-style character)
  final String? characterImageUrl;

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
    this.characterImageUrl,
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

  String get displayName => stageName ?? name;

  List<String> get allNames => [
    name,
    if (stageName != null) stageName!,
    if (legalName != null) legalName!,
    ...aliases,
  ];

  // Manual JSON serialization
  factory Celebrity.fromJson(Map<String, dynamic> json) {
    return Celebrity(
      id: json['id'] as String,
      name: json['name'] as String,
      birthDate: DateTime.parse(json['birth_date'] as String),
      gender: Gender.fromString(json['gender'] as String),
      celebrityType: CelebrityType.fromString(json['celebrity_type'] as String),
      stageName: json['stage_name'] as String?,
      legalName: json['legal_name'] as String?,
      aliases: (json['aliases'] as List<dynamic>?)?.cast<String>() ?? [],
      nationality: json['nationality'] as String? ?? '한국',
      birthPlace: json['birth_place'] as String?,
      birthTime: json['birth_time'] != null ? _parseTime(json['birth_time'] as String) : null,
      activeFrom: json['active_from'] as int?,
      agencyManagement: json['agency_management'] as String?,
      languages: (json['languages'] as List<dynamic>?)?.cast<String>() ?? ['한국어'],
      externalIds: json['external_ids'] != null ? ExternalIds.fromJson(json['external_ids'] as Map<String, dynamic>) : null,
      professionData: json['profession_data'] as Map<String, dynamic>?,
      notes: json['notes'] as String?,
      characterImageUrl: json['character_image_url'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birth_date': birthDate.toIso8601String().split('T')[0],
      'gender': gender.name,
      'celebrity_type': celebrityType.name,
      if (stageName != null) 'stage_name': stageName,
      if (legalName != null) 'legal_name': legalName,
      'aliases': aliases,
      'nationality': nationality,
      if (birthPlace != null) 'birth_place': birthPlace,
      'birth_time': birthTime != null ? '${birthTime!.hour.toString().padLeft(2, '0')}:${birthTime!.minute.toString().padLeft(2, '0')}' : null,
      if (activeFrom != null) 'active_from': activeFrom,
      if (agencyManagement != null) 'agency_management': agencyManagement,
      'languages': languages,
      if (externalIds != null) 'external_ids': externalIds!.toJson(),
      if (professionData != null) 'profession_data': professionData,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  static DateTime? _parseTime(String timeString) {
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

// Celebrity filter for searches
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
}