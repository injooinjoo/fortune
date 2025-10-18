import '../fortune_conditions.dart';

/// 피해야 할 사람 운세 조건
///
/// 특징:
/// - 날짜는 제외 (매일 새로운 운세)
/// - 환경, 일정, 감정 상태, 상황으로 조건 구분
///
/// 예시:
/// ```dart
/// final conditions = AvoidPeopleFortuneConditions(
///   environment: '직장',
///   importantSchedule: '중요한 프레젠테이션',
///   moodLevel: 2,
///   stressLevel: 4,
///   socialFatigue: 3,
///   hasImportantDecision: true,
///   hasSensitiveConversation: false,
///   hasTeamProject: true,
/// );
/// ```
class AvoidPeopleFortuneConditions extends FortuneConditions {
  final String environment;
  final String importantSchedule;
  final int moodLevel; // 1~5
  final int stressLevel; // 1~5
  final int socialFatigue; // 1~5
  final bool hasImportantDecision;
  final bool hasSensitiveConversation;
  final bool hasTeamProject;

  AvoidPeopleFortuneConditions({
    required this.environment,
    required this.importantSchedule,
    required this.moodLevel,
    required this.stressLevel,
    required this.socialFatigue,
    this.hasImportantDecision = false,
    this.hasSensitiveConversation = false,
    this.hasTeamProject = false,
  });

  @override
  String generateHash() {
    final parts = <String>[
      'env:${environment.hashCode}',
      'schedule:${importantSchedule.hashCode}',
      'mood:$moodLevel',
      'stress:$stressLevel',
      'fatigue:$socialFatigue',
      if (hasImportantDecision) 'decision:true',
      if (hasSensitiveConversation) 'conversation:true',
      if (hasTeamProject) 'team:true',
    ];
    return parts.join('|');
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'environment': environment,
      'importantSchedule': importantSchedule,
      'moodLevel': moodLevel,
      'stressLevel': stressLevel,
      'socialFatigue': socialFatigue,
      'hasImportantDecision': hasImportantDecision,
      'hasSensitiveConversation': hasSensitiveConversation,
      'hasTeamProject': hasTeamProject,
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      // 개인정보 보호를 위해 해시만 저장
      'environment_hash': environment.hashCode.toString(),
      'schedule_hash': importantSchedule.hashCode.toString(),
      'mood_level': moodLevel.toString(),
      'stress_level': stressLevel.toString(),
      'social_fatigue': socialFatigue.toString(),
      'has_decision': hasImportantDecision.toString(),
      'has_conversation': hasSensitiveConversation.toString(),
      'has_team_project': hasTeamProject.toString(),
      // 날짜는 포함하지 않음 (매일 변경)
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      'fortune_type': 'avoid_people',
      'environment': environment,
      'important_schedule': importantSchedule,
      'mood_level': moodLevel,
      'stress_level': stressLevel,
      'social_fatigue': socialFatigue,
      'has_important_decision': hasImportantDecision,
      'has_sensitive_conversation': hasSensitiveConversation,
      'has_team_project': hasTeamProject,
      'date': _formatDate(DateTime.now()),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvoidPeopleFortuneConditions &&
          runtimeType == other.runtimeType &&
          environment == other.environment &&
          importantSchedule == other.importantSchedule &&
          moodLevel == other.moodLevel &&
          stressLevel == other.stressLevel &&
          socialFatigue == other.socialFatigue &&
          hasImportantDecision == other.hasImportantDecision &&
          hasSensitiveConversation == other.hasSensitiveConversation &&
          hasTeamProject == other.hasTeamProject;

  @override
  int get hashCode =>
      environment.hashCode ^
      importantSchedule.hashCode ^
      moodLevel.hashCode ^
      stressLevel.hashCode ^
      socialFatigue.hashCode ^
      hasImportantDecision.hashCode ^
      hasSensitiveConversation.hashCode ^
      hasTeamProject.hashCode;

  /// 날짜 포맷팅 (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
