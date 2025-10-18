import '../fortune_conditions.dart';

/// 시험 운세 조건
class LuckyExamFortuneConditions extends FortuneConditions {
  final String examType; // 시험 종류
  final DateTime examDate; // 시험 날짜
  final String? subject; // 과목
  final int preparationLevel; // 준비 수준 (1-5)
  final int anxietyLevel; // 불안 수준 (1-5)

  LuckyExamFortuneConditions({
    required this.examType,
    required this.examDate,
    this.subject,
    required this.preparationLevel,
    required this.anxietyLevel,
  });

  @override
  String generateHash() {
    final parts = <String>[
      'type:${examType.hashCode}',
      'date:${_formatDate(examDate)}',
      if (subject != null) 'subject:${subject!.hashCode}',
      'prep:$preparationLevel',
      'anxiety:$anxietyLevel',
    ];
    return parts.join('|');
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'exam_type': examType,
      'exam_date': examDate.toIso8601String(),
      if (subject != null) 'subject': subject,
      'preparation_level': preparationLevel,
      'anxiety_level': anxietyLevel,
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      'exam_type': examType,
      'exam_date': _formatDate(examDate),
      'subject': subject,
      'preparation_level': preparationLevel,
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      'exam_type': examType,
      'exam_date': examDate.toIso8601String(),
      if (subject != null) 'subject': subject,
      'preparation_level': preparationLevel,
      'anxiety_level': anxietyLevel,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LuckyExamFortuneConditions &&
          runtimeType == other.runtimeType &&
          examType == other.examType &&
          examDate == other.examDate &&
          subject == other.subject &&
          preparationLevel == other.preparationLevel &&
          anxietyLevel == other.anxietyLevel;

  @override
  int get hashCode =>
      examType.hashCode ^
      examDate.hashCode ^
      subject.hashCode ^
      preparationLevel.hashCode ^
      anxietyLevel.hashCode;
}
