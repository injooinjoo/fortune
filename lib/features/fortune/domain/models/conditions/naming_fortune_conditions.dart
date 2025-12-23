import '../fortune_conditions.dart';

/// 작명 운세 조건
///
/// 특징:
/// - 엄마 정보 (생년월일, 출생시간)
/// - 아기 정보 (출산예정일, 성별)
/// - 성씨 정보 (한글, 한자)
/// - 이름 스타일 선호도
///
/// 예시:
/// ```dart
/// final conditions = NamingFortuneConditions(
///   motherBirthDate: DateTime(1990, 5, 15),
///   motherBirthTime: '오시 (11:00-13:00)',
///   expectedBirthDate: DateTime(2025, 3, 20),
///   babyGender: 'female',
///   familyName: '김',
///   familyNameHanja: '金',
///   nameStyle: 'modern',
///   desiredMeanings: ['건강', '행복'],
/// );
/// ```
class NamingFortuneConditions extends FortuneConditions {
  final DateTime motherBirthDate;
  final String? motherBirthTime;
  final DateTime expectedBirthDate;
  final String babyGender; // 'male', 'female', 'unknown'
  final String familyName;
  final String? familyNameHanja;
  final String? nameStyle; // 'traditional', 'modern', 'korean'
  final List<String>? avoidSounds;
  final List<String>? desiredMeanings;

  NamingFortuneConditions({
    required this.motherBirthDate,
    this.motherBirthTime,
    required this.expectedBirthDate,
    required this.babyGender,
    required this.familyName,
    this.familyNameHanja,
    this.nameStyle,
    this.avoidSounds,
    this.desiredMeanings,
  });

  @override
  String generateHash() {
    final parts = <String>[
      'mother:${_formatDate(motherBirthDate)}',
      if (motherBirthTime != null) 'time:${motherBirthTime.hashCode}',
      'expected:${_formatDate(expectedBirthDate)}',
      'gender:$babyGender',
      'family:${familyName.hashCode}',
      if (familyNameHanja != null) 'hanja:${familyNameHanja.hashCode}',
      if (nameStyle != null) 'style:$nameStyle',
    ];
    return parts.join('|');
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'motherBirthDate': _formatDate(motherBirthDate),
      'motherBirthTime': motherBirthTime,
      'expectedBirthDate': _formatDate(expectedBirthDate),
      'babyGender': babyGender,
      'familyName': familyName,
      'familyNameHanja': familyNameHanja,
      'nameStyle': nameStyle,
      'avoidSounds': avoidSounds,
      'desiredMeanings': desiredMeanings,
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      'mother_birth_date': _formatDate(motherBirthDate),
      'expected_birth_date': _formatDate(expectedBirthDate),
      'baby_gender': babyGender,
      'family_name_hash': familyName.hashCode.toString(),
      'name_style': nameStyle ?? 'default',
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      'fortune_type': 'naming',
      'motherBirthDate': _formatDate(motherBirthDate),
      'motherBirthTime': motherBirthTime,
      'expectedBirthDate': _formatDate(expectedBirthDate),
      'babyGender': babyGender,
      'familyName': familyName,
      'familyNameHanja': familyNameHanja,
      'nameStyle': nameStyle,
      'avoidSounds': avoidSounds,
      'desiredMeanings': desiredMeanings,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NamingFortuneConditions &&
          runtimeType == other.runtimeType &&
          motherBirthDate == other.motherBirthDate &&
          motherBirthTime == other.motherBirthTime &&
          expectedBirthDate == other.expectedBirthDate &&
          babyGender == other.babyGender &&
          familyName == other.familyName &&
          familyNameHanja == other.familyNameHanja &&
          nameStyle == other.nameStyle;

  @override
  int get hashCode =>
      motherBirthDate.hashCode ^
      motherBirthTime.hashCode ^
      expectedBirthDate.hashCode ^
      babyGender.hashCode ^
      familyName.hashCode ^
      familyNameHanja.hashCode ^
      nameStyle.hashCode;

  /// 날짜 포맷팅 (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
