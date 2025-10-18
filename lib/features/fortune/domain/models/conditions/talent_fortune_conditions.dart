import '../fortune_conditions.dart';

/// 재능 발견 운세 조건
class TalentFortuneConditions extends FortuneConditions {
  final List<String> interests;
  final String? currentJob;
  final int age;
  final DateTime date;

  TalentFortuneConditions({
    required this.interests,
    this.currentJob,
    required this.age,
    required this.date,
  });

  @override
  String generateHash() {
    final parts = <String>[
      'interests:${interests.join(',').hashCode}',
      if (currentJob != null) 'job:${currentJob!.hashCode}',
      'age:$age',
      'date:${_formatDate(date)}',
    ];
    return parts.join('|');
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'interests': interests,
      if (currentJob != null) 'current_job': currentJob,
      'age': age,
      'date': date.toIso8601String(),
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      'current_job': currentJob,
      'age': age,
      'date': _formatDate(date),
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      'interests': interests,
      if (currentJob != null) 'current_job': currentJob,
      'age': age,
      'date': date.toIso8601String(),
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TalentFortuneConditions &&
          runtimeType == other.runtimeType &&
          _listEquals(interests, other.interests) &&
          currentJob == other.currentJob &&
          age == other.age &&
          date == other.date;

  @override
  int get hashCode =>
      interests.hashCode ^ currentJob.hashCode ^ age.hashCode ^ date.hashCode;

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
