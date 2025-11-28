import '../fortune_conditions.dart';

/// 성격 DNA 운세 조건
class PersonalityDnaFortuneConditions extends FortuneConditions {
  final String? mbti;
  final String? bloodType;
  final String? zodiac;
  final String? animal;
  final DateTime date;

  PersonalityDnaFortuneConditions({
    this.mbti,
    this.bloodType,
    this.zodiac,
    this.animal,
    required this.date,
  });

  @override
  String generateHash() {
    // 날짜 제거로 DB 풀 누적 가능 → API 비용 절감
    // 개인 캐시는 date 컬럼에서 오늘 날짜 체크
    final parts = <String>[
      if (mbti != null) 'mbti:${mbti!.hashCode}',
      if (bloodType != null) 'blood:${bloodType!.hashCode}',
      if (zodiac != null) 'zodiac:${zodiac!.hashCode}',
      if (animal != null) 'animal:${animal!.hashCode}',
    ];
    return parts.join('|');
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (mbti != null) 'mbti': mbti,
      if (bloodType != null) 'blood_type': bloodType,
      if (zodiac != null) 'zodiac': zodiac,
      if (animal != null) 'animal': animal,
      'date': date.toIso8601String(),
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      'mbti': mbti,
      'blood_type': bloodType,
      'zodiac': zodiac,
      'animal': animal,
      'date': _formatDate(date),
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      if (mbti != null) 'mbti': mbti,
      if (bloodType != null) 'blood_type': bloodType,
      if (zodiac != null) 'zodiac': zodiac,
      if (animal != null) 'animal': animal,
      'date': date.toIso8601String(),
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalityDnaFortuneConditions &&
          runtimeType == other.runtimeType &&
          mbti == other.mbti &&
          bloodType == other.bloodType &&
          zodiac == other.zodiac &&
          animal == other.animal &&
          date == other.date;

  @override
  int get hashCode =>
      mbti.hashCode ^
      bloodType.hashCode ^
      zodiac.hashCode ^
      animal.hashCode ^
      date.hashCode;
}
