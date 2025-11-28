import '../fortune_conditions.dart';

/// 프리랜서 운세 조건
class FreelanceFortuneConditions extends FortuneConditions {
  final String field;
  final int experienceMonths;
  final String workStyle;
  final DateTime date;

  FreelanceFortuneConditions({
    required this.field,
    required this.experienceMonths,
    required this.workStyle,
    required this.date,
  });

  @override
  String generateHash() {
    // 날짜 제거로 DB 풀 누적 가능 → API 비용 절감
    // 개인 캐시는 date 컬럼에서 오늘 날짜 체크
    final parts = <String>[
      'field:${field.hashCode}',
      'exp:$experienceMonths',
      'style:${workStyle.hashCode}',
    ];
    return parts.join('|');
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'experience_months': experienceMonths,
      'work_style': workStyle,
      'date': date.toIso8601String(),
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      'field': field,
      'experience_months': experienceMonths,
      'work_style': workStyle,
      'date': _formatDate(date),
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      'field': field,
      'experience_months': experienceMonths,
      'work_style': workStyle,
      'date': date.toIso8601String(),
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FreelanceFortuneConditions &&
          runtimeType == other.runtimeType &&
          field == other.field &&
          experienceMonths == other.experienceMonths &&
          workStyle == other.workStyle &&
          date == other.date;

  @override
  int get hashCode =>
      field.hashCode ^
      experienceMonths.hashCode ^
      workStyle.hashCode ^
      date.hashCode;
}
