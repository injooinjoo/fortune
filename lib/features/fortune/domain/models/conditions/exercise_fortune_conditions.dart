import '../fortune_conditions.dart';

/// 운동 운세 조건
///
/// 특징:
/// - 운동 목표, 종목, 경력, 체력, 부상 이력으로 조건 구분
/// - 날짜는 제외 (매일 새로운 운세)
///
/// 예시:
/// ```dart
/// final conditions = ExerciseFortuneConditions(
///   exerciseGoal: 'strength',
///   sportType: 'gym',
///   weeklyFrequency: 4,
///   experienceLevel: 'intermediate',
///   fitnessLevel: 3,
///   injuryHistory: ['knee'],
///   preferredTime: 'evening',
/// );
/// ```
class ExerciseFortuneConditions extends FortuneConditions {
  final String exerciseGoal;
  final String sportType;
  final int weeklyFrequency;
  final String experienceLevel;
  final int fitnessLevel;
  final List<String> injuryHistory;
  final String preferredTime;

  ExerciseFortuneConditions({
    required this.exerciseGoal,
    required this.sportType,
    required this.weeklyFrequency,
    required this.experienceLevel,
    required this.fitnessLevel,
    required this.injuryHistory,
    required this.preferredTime,
  });

  /// inputConditions Map에서 ExerciseFortuneConditions 생성
  factory ExerciseFortuneConditions.fromInputData(Map<String, dynamic> data) {
    return ExerciseFortuneConditions(
      exerciseGoal: data['exerciseGoal'] as String? ?? data['exercise_goal'] as String? ?? 'strength',
      sportType: data['sportType'] as String? ?? data['sport_type'] as String? ?? 'gym',
      weeklyFrequency: data['weeklyFrequency'] as int? ?? data['weekly_frequency'] as int? ?? 3,
      experienceLevel: data['experienceLevel'] as String? ?? data['experience_level'] as String? ?? 'intermediate',
      fitnessLevel: data['fitnessLevel'] as int? ?? data['fitness_level'] as int? ?? 3,
      injuryHistory: data['injuryHistory'] != null
          ? List<String>.from(data['injuryHistory'] as List)
          : data['injury_history'] != null
              ? List<String>.from(data['injury_history'] as List)
              : [],
      preferredTime: data['preferredTime'] as String? ?? data['preferred_time'] as String? ?? 'evening',
    );
  }

  @override
  String generateHash() {
    final parts = <String>[
      'goal:$exerciseGoal',
      'sport:$sportType',
      'freq:$weeklyFrequency',
      'exp:$experienceLevel',
      'fit:$fitnessLevel',
      'injury:${injuryHistory.join(',')}',
      'time:$preferredTime',
    ];
    return parts.join('|');
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'exerciseGoal': exerciseGoal,
      'sportType': sportType,
      'weeklyFrequency': weeklyFrequency,
      'experienceLevel': experienceLevel,
      'fitnessLevel': fitnessLevel,
      'injuryHistory': injuryHistory,
      'preferredTime': preferredTime,
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      'exercise_goal': exerciseGoal,
      'sport_type': sportType,
      'weekly_frequency': weeklyFrequency.toString(),
      'experience_level': experienceLevel,
      'fitness_level': fitnessLevel.toString(),
      'injury_history': injuryHistory.join(','),
      'preferred_time': preferredTime,
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      'fortune_type': 'exercise',
      'exerciseGoal': exerciseGoal,
      'sportType': sportType,
      'weeklyFrequency': weeklyFrequency,
      'experienceLevel': experienceLevel,
      'fitnessLevel': fitnessLevel,
      'injuryHistory': injuryHistory,
      'preferredTime': preferredTime,
      'date': _formatDate(DateTime.now()),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseFortuneConditions &&
          runtimeType == other.runtimeType &&
          exerciseGoal == other.exerciseGoal &&
          sportType == other.sportType &&
          weeklyFrequency == other.weeklyFrequency &&
          experienceLevel == other.experienceLevel &&
          fitnessLevel == other.fitnessLevel &&
          _listEquals(injuryHistory, other.injuryHistory) &&
          preferredTime == other.preferredTime;

  @override
  int get hashCode =>
      exerciseGoal.hashCode ^
      sportType.hashCode ^
      weeklyFrequency.hashCode ^
      experienceLevel.hashCode ^
      fitnessLevel.hashCode ^
      injuryHistory.join(',').hashCode ^
      preferredTime.hashCode;

  /// 리스트 비교 헬퍼
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  /// 날짜 포맷팅 (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
