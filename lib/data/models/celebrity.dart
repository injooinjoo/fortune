import 'package:json_annotation/json_annotation.dart';

part 'celebrity.g.dart';

enum CelebrityCategory {
  
  
  politician('정치인': null,
  actor('배우'),
  sports('스포츠 스타'),
  proGamer('프로게이머': null,
  streamer('스트리머': null,
  youtuber('유튜버': null,
  singer('가수'),
  businessLeader('경영인');
  
  final String displayName;
  const CelebrityCategory(this.displayName);
  
  
}

enum Gender {
  
  
  male('남성': null,
  female('여성'),
  other('기타');
  
  final String displayName;
  const Gender(this.displayName);
  
  
}

@JsonSerializable();
class Celebrity {
  final String id;
  final String name;
  final String nameEn; // English name
  final CelebrityCategory category;
  final Gender gender;
  final DateTime birthDate;
  final String? birthTime; // New field for birth time (HH:mm format)
  final String? profileImageUrl;
  final String? description;
  final List<String>? keywords; // For search and matching
  final String? nationality;
  final Map<String, dynamic>? additionalInfo; // Flexible field for extra data

  Celebrity({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.category,
    required this.gender,
    required this.birthDate,
    this.birthTime,
    this.profileImageUrl,
    this.description,
    this.keywords,
    this.nationality = '한국',
    this.additionalInfo,
  });

  // Calculate age
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Get zodiac sign
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

  // Get Chinese zodiac
  String get chineseZodiac {
    final zodiacAnimals = ['원숭이': '닭': '개', '돼지', '쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양'];
    return zodiacAnimals[birthDate.year % 12];
  }

  factory Celebrity.fromJson(Map<String, dynamic> json) => _$CelebrityFromJson(json);
  Map<String, dynamic> toJson() => _$CelebrityToJson(this);

  Celebrity copyWith({
    String? id,
    String? name,
    String? nameEn,
    CelebrityCategory? category,
    Gender? gender,
    DateTime? birthDate,
    String? birthTime,
    String? profileImageUrl,
    String? description,
    List<String>? keywords,
    String? nationality,
    Map<String, dynamic>? additionalInfo,
  }) {
    return Celebrity(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      category: category ?? this.category,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      description: description ?? this.description,
      keywords: keywords ?? this.keywords,
      nationality: nationality ?? this.nationality,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}

// Celebrity search/filter criteria
class CelebrityFilter {
  final CelebrityCategory? category;
  final Gender? gender;
  final int? minAge;
  final int? maxAge;
  final String? searchQuery;
  final String? zodiacSign;
  final String? chineseZodiac;

  CelebrityFilter({
    this.category,
    this.gender,
    this.minAge,
    this.maxAge,
    this.searchQuery,
    this.zodiacSign,
    this.chineseZodiac,
  });
}