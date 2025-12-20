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
    // 🚀 전체 통합 해시 → 300개 후 DB 풀 재사용 (API 비용 99.99% 절감)
    // 기존: 9,216 조합 (16×4×12×12) → 2,764,800회 API 필요
    // 개선: 1 조합 → 300회 API 후 완전 캐시
    //
    // 품질 트레이드오프: 다른 MBTI/혈액형 조합의 결과를 받을 수 있음
    // 하지만 모든 결과가 "성격 DNA" 맥락에서 생성되므로 일관성 유지
    return 'personality_dna';
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
