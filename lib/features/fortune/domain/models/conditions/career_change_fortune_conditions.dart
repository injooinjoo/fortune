import '../fortune_conditions.dart';

/// 커리어 전환 운세 조건
class CareerChangeFortuneConditions extends FortuneConditions {
  final String currentJob;
  final String targetJob;
  final int experienceYears;
  final String motivation;
  final DateTime date;

  CareerChangeFortuneConditions({
    required this.currentJob,
    required this.targetJob,
    required this.experienceYears,
    required this.motivation,
    required this.date,
  });

  @override
  String generateHash() {
    final parts = <String>[
      'current:${currentJob.hashCode}',
      'target:${targetJob.hashCode}',
      'exp:$experienceYears',
      'motivation:${motivation.hashCode}',
      'date:${_formatDate(date)}',
    ];
    return parts.join('|');
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'current_job': currentJob,
      'target_job': targetJob,
      'experience_years': experienceYears,
      'motivation': motivation,
      'date': date.toIso8601String(),
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      'current_job': currentJob,
      'target_job': targetJob,
      'experience_years': experienceYears,
      'date': _formatDate(date),
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      'current_job': currentJob,
      'target_job': targetJob,
      'experience_years': experienceYears,
      'motivation': motivation,
      'date': date.toIso8601String(),
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CareerChangeFortuneConditions &&
          runtimeType == other.runtimeType &&
          currentJob == other.currentJob &&
          targetJob == other.targetJob &&
          experienceYears == other.experienceYears &&
          motivation == other.motivation &&
          date == other.date;

  @override
  int get hashCode =>
      currentJob.hashCode ^
      targetJob.hashCode ^
      experienceYears.hashCode ^
      motivation.hashCode ^
      date.hashCode;
}
