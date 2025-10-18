import '../fortune_conditions.dart';

/// 궁합 운세 조건
class CompatibilityFortuneConditions extends FortuneConditions {
  final String person1Name;
  final DateTime person1BirthDate;
  final String person2Name;
  final DateTime person2BirthDate;

  CompatibilityFortuneConditions({
    required this.person1Name,
    required this.person1BirthDate,
    required this.person2Name,
    required this.person2BirthDate,
  });

  @override
  String generateHash() {
    return 'p1:${person1Name.hashCode}|bd1:${_formatDate(person1BirthDate)}|p2:${person2Name.hashCode}|bd2:${_formatDate(person2BirthDate)}';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'person1': {
        'name': person1Name,
        'birth_date': person1BirthDate.toIso8601String(),
      },
      'person2': {
        'name': person2Name,
        'birth_date': person2BirthDate.toIso8601String(),
      },
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      'person1_name_hash': person1Name.hashCode.toString(),
      'person1_birth_date': _formatDate(person1BirthDate),
      'person2_name_hash': person2Name.hashCode.toString(),
      'person2_birth_date': _formatDate(person2BirthDate),
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      'fortune_type': 'compatibility',
      'person1': {
        'name': person1Name,
        'birth_date': person1BirthDate.toIso8601String(),
      },
      'person2': {
        'name': person2Name,
        'birth_date': person2BirthDate.toIso8601String(),
      },
      'date': _formatDate(DateTime.now()),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompatibilityFortuneConditions &&
          person1Name == other.person1Name &&
          person1BirthDate == other.person1BirthDate &&
          person2Name == other.person2Name &&
          person2BirthDate == other.person2BirthDate;

  @override
  int get hashCode =>
      person1Name.hashCode ^
      person1BirthDate.hashCode ^
      person2Name.hashCode ^
      person2BirthDate.hashCode;

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
