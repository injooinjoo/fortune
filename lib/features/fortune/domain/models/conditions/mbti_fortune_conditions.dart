import '../fortune_conditions.dart';

/// MBTI 운세 조건
class MbtiFortuneConditions extends FortuneConditions {
  final String mbtiType;
  final DateTime date;
  final String name;
  final String birthDate;

  MbtiFortuneConditions({
    required this.mbtiType,
    required this.date,
    required this.name,
    required this.birthDate,
  });

  @override
  String generateHash() {
    return 'mbti:${mbtiType.hashCode}|date:${_formatDate(date)}';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'mbti_type': mbtiType,
      'date': date.toIso8601String(),
      'name': name,
      'birth_date': birthDate,
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      'mbti_type': mbtiType,
      'date': _formatDate(date),
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      'mbti': mbtiType,
      'name': name,
      'birthDate': birthDate,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MbtiFortuneConditions &&
          runtimeType == other.runtimeType &&
          mbtiType == other.mbtiType &&
          date == other.date;

  @override
  int get hashCode => mbtiType.hashCode ^ date.hashCode;
}
