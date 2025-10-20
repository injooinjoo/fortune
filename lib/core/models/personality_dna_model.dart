import 'package:flutter/material.dart';

/// 새로운 궁합 정보 모델 (Edge Function 응답 구조에 맞춤)
class CompatibilityType {
  final String mbti;
  final String description;

  const CompatibilityType({
    required this.mbti,
    required this.description,
  });

  factory CompatibilityType.fromJson(Map<String, dynamic> json) {
    return CompatibilityType(
      mbti: json['mbti'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mbti': mbti,
      'description': description,
    };
  }
}

/// 새로운 궁합 데이터 모델
class Compatibility {
  final CompatibilityType friend;
  final CompatibilityType lover;
  final CompatibilityType colleague;

  const Compatibility({
    required this.friend,
    required this.lover,
    required this.colleague,
  });

  factory Compatibility.fromJson(Map<String, dynamic> json) {
    return Compatibility(
      friend: CompatibilityType.fromJson(json['friend'] as Map<String, dynamic>? ?? {}),
      lover: CompatibilityType.fromJson(json['lover'] as Map<String, dynamic>? ?? {}),
      colleague: CompatibilityType.fromJson(json['colleague'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'friend': friend.toJson(),
      'lover': lover.toJson(),
      'colleague': colleague.toJson(),
    };
  }
}

/// 연애 스타일 모델
class LoveStyle {
  final String title;
  final String description;
  final String whenDating;
  final String afterBreakup;

  const LoveStyle({
    required this.title,
    required this.description,
    required this.whenDating,
    required this.afterBreakup,
  });

  factory LoveStyle.fromJson(Map<String, dynamic> json) {
    return LoveStyle(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      whenDating: json['when_dating'] as String? ?? '',
      afterBreakup: json['after_breakup'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'when_dating': whenDating,
      'after_breakup': afterBreakup,
    };
  }
}

/// 업무 스타일 모델
class WorkStyle {
  final String title;
  final String asBoss;
  final String atCompanyDinner;
  final String workHabit;

  const WorkStyle({
    required this.title,
    required this.asBoss,
    required this.atCompanyDinner,
    required this.workHabit,
  });

  factory WorkStyle.fromJson(Map<String, dynamic> json) {
    return WorkStyle(
      title: json['title'] as String? ?? '',
      asBoss: json['as_boss'] as String? ?? '',
      atCompanyDinner: json['at_company_dinner'] as String? ?? '',
      workHabit: json['work_habit'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'as_boss': asBoss,
      'at_company_dinner': atCompanyDinner,
      'work_habit': workHabit,
    };
  }
}

/// 일상 매칭 모델
class DailyMatching {
  final String cafeMenu;
  final String netflixGenre;
  final String weekendActivity;

  const DailyMatching({
    required this.cafeMenu,
    required this.netflixGenre,
    required this.weekendActivity,
  });

  factory DailyMatching.fromJson(Map<String, dynamic> json) {
    return DailyMatching(
      cafeMenu: json['cafe_menu'] as String? ?? '',
      netflixGenre: json['netflix_genre'] as String? ?? '',
      weekendActivity: json['weekend_activity'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cafe_menu': cafeMenu,
      'netflix_genre': netflixGenre,
      'weekend_activity': weekendActivity,
    };
  }
}

/// 파워 컬러 모델
class PowerColor {
  final String name;
  final String hex;

  const PowerColor({
    required this.name,
    required this.hex,
  });

  factory PowerColor.fromJson(Map<String, dynamic> json) {
    return PowerColor(
      name: json['name'] as String,
      hex: json['hex'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hex': hex,
    };
  }

  Color get color => Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
}

/// 능력치 모델
class PersonalityStats {
  final int charisma;
  final int intelligence;
  final int creativity;
  final int leadership;
  final int empathy;

  const PersonalityStats({
    required this.charisma,
    required this.intelligence,
    required this.creativity,
    required this.leadership,
    required this.empathy,
  });

  factory PersonalityStats.fromJson(Map<String, dynamic> json) {
    return PersonalityStats(
      charisma: json['charisma'] as int,
      intelligence: json['intelligence'] as int,
      creativity: json['creativity'] as int,
      leadership: json['leadership'] as int,
      empathy: json['empathy'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'charisma': charisma,
      'intelligence': intelligence,
      'creativity': creativity,
      'leadership': leadership,
      'empathy': empathy,
    };
  }

  List<int> get values => [charisma, intelligence, creativity, leadership, empathy];
  List<String> get labels => ['카리스마', '지능', '창의력', '리더십', '공감력'];
}

/// 유명인 모델
class Celebrity {
  final String name;
  final String reason;

  const Celebrity({
    required this.name,
    required this.reason,
  });

  factory Celebrity.fromJson(Map<String, dynamic> json) {
    return Celebrity(
      name: json['name'] as String,
      reason: json['reason'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'reason': reason,
    };
  }
}

/// 성격 DNA 정보를 담는 모델 (확장)
class PersonalityDNA {
  final String mbti;
  final String bloodType;
  final String zodiac;
  final String zodiacAnimal;
  final String dnaCode;
  final String title;
  final String emoji;
  final String description;
  final List<String> traits;
  final List<Color> gradientColors;
  final Map<String, int> scores;
  final String todaysFortune;
  
  // 새로운 재미있는 필드들 (Edge Function 응답 구조)
  final String? todayHighlight;
  final LoveStyle? loveStyle;
  final WorkStyle? workStyle;
  final DailyMatching? dailyMatching;
  final Compatibility? compatibility;
  final PowerColor? powerColor;
  final PersonalityStats? stats;
  final Celebrity? celebrity;
  final String? funnyFact;
  final int? popularityRank;

  const PersonalityDNA({
    required this.mbti,
    required this.bloodType,
    required this.zodiac,
    required this.zodiacAnimal,
    required this.dnaCode,
    required this.title,
    required this.emoji,
    required this.description,
    required this.traits,
    required this.gradientColors,
    required this.scores,
    required this.todaysFortune,
    this.todayHighlight,
    this.loveStyle,
    this.workStyle,
    this.dailyMatching,
    this.compatibility,
    this.powerColor,
    this.stats,
    this.celebrity,
    this.funnyFact,
    this.popularityRank,
  });

  /// 조합 키 생성
  String get combinationKey => '$mbti-$bloodType-$zodiacAnimal';

  /// DNA 코드 생성
  static String generateDNACode({
    required String mbti,
    required String bloodType,
    required String zodiac,
    required String zodiacAnimal,
  }) {
    return '$mbti-$bloodType-${zodiac.substring(0, 2)}-$zodiacAnimal';
  }

  /// 인기 순위에 따른 색상 반환 (토스 블루 계열)
  Color get popularityColor {
    if (popularityRank == null) return const Color(0xFF9E9E9E);
    
    if (popularityRank! <= 10) {
      return const Color(0xFF1F4EF5); // 토스 블루
    } else if (popularityRank! <= 50) {
      return const Color(0xFF4A90E2); // 밝은 블루
    } else {
      return const Color(0xFF9E9E9E); // 그레이
    }
  }

  /// 인기 순위 텍스트 반환
  String get popularityText {
    if (popularityRank == null) return '순위 미정';
    
    if (popularityRank! <= 10) {
      return 'TOP ${popularityRank!}위';
    } else if (popularityRank! <= 50) {
      return '${popularityRank!}위';
    } else {
      return '일반';
    }
  }

  /// API 응답에서 PersonalityDNA 생성
  factory PersonalityDNA.fromApiResponse(Map<String, dynamic> json, {
    required String mbti,
    required String bloodType,
    required String zodiac,
    required String zodiacAnimal,
    required List<Color> gradientColors,
    required Map<String, int> scores,
  }) {
    return PersonalityDNA(
      mbti: mbti,
      bloodType: bloodType,
      zodiac: zodiac,
      zodiacAnimal: zodiacAnimal,
      dnaCode: json['dnaCode'] as String,
      title: json['title'] as String,
      emoji: json['emoji'] as String,
      description: json['description'] as String,
      traits: List<String>.from(json['traits'] ?? []),
      gradientColors: gradientColors,
      scores: scores,
      todaysFortune: json['todaysFortune'] ?? '',
      todayHighlight: json['todayHighlight'] as String?,
      loveStyle: json['loveStyle'] != null 
          ? LoveStyle.fromJson(json['loveStyle'])
          : null,
      workStyle: json['workStyle'] != null 
          ? WorkStyle.fromJson(json['workStyle'])
          : null,
      dailyMatching: json['dailyMatching'] != null 
          ? DailyMatching.fromJson(json['dailyMatching'])
          : null,
      compatibility: json['compatibility'] != null 
          ? Compatibility.fromJson(json['compatibility'])
          : null,
      powerColor: json['powerColor'] != null 
          ? PowerColor.fromJson(json['powerColor'])
          : null,
      stats: json['stats'] != null 
          ? PersonalityStats.fromJson(json['stats'])
          : null,
      celebrity: json['celebrity'] != null 
          ? Celebrity.fromJson(json['celebrity'])
          : null,
      funnyFact: json['funnyFact'] as String?,
      popularityRank: json['popularityRank'] as int?,
    );
  }

  /// copyWith 메서드
  PersonalityDNA copyWith({
    String? mbti,
    String? bloodType,
    String? zodiac,
    String? zodiacAnimal,
    String? dnaCode,
    String? title,
    String? emoji,
    String? description,
    List<String>? traits,
    List<Color>? gradientColors,
    Map<String, int>? scores,
    String? todaysFortune,
    String? todayHighlight,
    LoveStyle? loveStyle,
    WorkStyle? workStyle,
    DailyMatching? dailyMatching,
    Compatibility? compatibility,
    PowerColor? powerColor,
    PersonalityStats? stats,
    Celebrity? celebrity,
    String? funnyFact,
    int? popularityRank,
  }) {
    return PersonalityDNA(
      mbti: mbti ?? this.mbti,
      bloodType: bloodType ?? this.bloodType,
      zodiac: zodiac ?? this.zodiac,
      zodiacAnimal: zodiacAnimal ?? this.zodiacAnimal,
      dnaCode: dnaCode ?? this.dnaCode,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      description: description ?? this.description,
      traits: traits ?? this.traits,
      gradientColors: gradientColors ?? this.gradientColors,
      scores: scores ?? this.scores,
      todaysFortune: todaysFortune ?? this.todaysFortune,
      todayHighlight: todayHighlight ?? this.todayHighlight,
      loveStyle: loveStyle ?? this.loveStyle,
      workStyle: workStyle ?? this.workStyle,
      dailyMatching: dailyMatching ?? this.dailyMatching,
      compatibility: compatibility ?? this.compatibility,
      powerColor: powerColor ?? this.powerColor,
      stats: stats ?? this.stats,
      celebrity: celebrity ?? this.celebrity,
      funnyFact: funnyFact ?? this.funnyFact,
      popularityRank: popularityRank ?? this.popularityRank,
    );
  }

  @override
  String toString() {
    return 'PersonalityDNA(dnaCode: $dnaCode, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PersonalityDNA && other.dnaCode == dnaCode;
  }

  @override
  int get hashCode => dnaCode.hashCode;
}