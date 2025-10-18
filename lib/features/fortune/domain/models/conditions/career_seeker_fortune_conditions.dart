import '../fortune_conditions.dart';

/// 취업 운세 조건
class CareerSeekerFortuneConditions extends FortuneConditions {
  final String targetIndustry;
  final String targetPosition;
  final int preparationMonths;
  final List<String> skills;
  final DateTime date;

  CareerSeekerFortuneConditions({
    required this.targetIndustry,
    required this.targetPosition,
    required this.preparationMonths,
    required this.skills,
    required this.date,
  });

  @override
  String generateHash() {
    final parts = <String>[
      'industry:${targetIndustry.hashCode}',
      'position:${targetPosition.hashCode}',
      'prep:$preparationMonths',
      'skills:${skills.join(',').hashCode}',
      'date:${_formatDate(date)}',
    ];
    return parts.join('|');
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'target_industry': targetIndustry,
      'target_position': targetPosition,
      'preparation_months': preparationMonths,
      'skills': skills,
      'date': date.toIso8601String(),
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      'target_industry': targetIndustry,
      'target_position': targetPosition,
      'preparation_months': preparationMonths,
      'date': _formatDate(date),
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      'target_industry': targetIndustry,
      'target_position': targetPosition,
      'preparation_months': preparationMonths,
      'skills': skills,
      'date': date.toIso8601String(),
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CareerSeekerFortuneConditions &&
          runtimeType == other.runtimeType &&
          targetIndustry == other.targetIndustry &&
          targetPosition == other.targetPosition &&
          preparationMonths == other.preparationMonths &&
          _listEquals(skills, other.skills) &&
          date == other.date;

  @override
  int get hashCode =>
      targetIndustry.hashCode ^
      targetPosition.hashCode ^
      preparationMonths.hashCode ^
      skills.hashCode ^
      date.hashCode;

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
