import '../fortune_conditions.dart';

/// 커리어 운세 조건
class CareerFutureFortuneConditions extends FortuneConditions {
  final String currentRole;
  final String careerGoal;
  final String timeHorizon;
  final String careerPath;
  final List<String> skills;

  CareerFutureFortuneConditions({
    required this.currentRole,
    required this.careerGoal,
    required this.timeHorizon,
    required this.careerPath,
    required this.skills,
  });

  @override
  String generateHash() {
    return 'role:${currentRole.hashCode}|goal:${careerGoal.hashCode}|time:${timeHorizon.hashCode}|path:${careerPath.hashCode}|skills:${skills.join(',').hashCode}';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'currentRole': currentRole,
      'careerGoal': careerGoal,
      'timeHorizon': timeHorizon,
      'careerPath': careerPath,
      'skills': skills,
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      'role_hash': currentRole.hashCode.toString(),
      'goal_hash': careerGoal.hashCode.toString(),
      'time_horizon': timeHorizon,
      'career_path': careerPath,
      'skills_hash': skills.join(',').hashCode.toString(),
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      'fortune_type': 'career_future',
      'current_role': currentRole,
      'goal': careerGoal,
      'time_horizon': timeHorizon,
      'career_path': careerPath,
      'selected_skills': skills,
      'date': _formatDate(DateTime.now()),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CareerFutureFortuneConditions &&
          currentRole == other.currentRole &&
          careerGoal == other.careerGoal &&
          timeHorizon == other.timeHorizon &&
          careerPath == other.careerPath &&
          _listEquals(skills, other.skills);

  @override
  int get hashCode =>
      currentRole.hashCode ^
      careerGoal.hashCode ^
      timeHorizon.hashCode ^
      careerPath.hashCode ^
      skills.join(',').hashCode;

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
