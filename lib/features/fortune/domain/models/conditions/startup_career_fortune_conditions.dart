import '../fortune_conditions.dart';

/// 스타트업 커리어 운세 조건
class StartupCareerFortuneConditions extends FortuneConditions {
  final String startupStage; // 시드, 시리즈A, etc
  final String role;
  final int teamSize;
  final String industry;
  final DateTime date;

  StartupCareerFortuneConditions({
    required this.startupStage,
    required this.role,
    required this.teamSize,
    required this.industry,
    required this.date,
  });

  @override
  String generateHash() {
    final parts = <String>[
      'stage:${startupStage.hashCode}',
      'role:${role.hashCode}',
      'team:$teamSize',
      'industry:${industry.hashCode}',
      'date:${_formatDate(date)}',
    ];
    return parts.join('|');
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'startup_stage': startupStage,
      'role': role,
      'team_size': teamSize,
      'industry': industry,
      'date': date.toIso8601String(),
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      'startup_stage': startupStage,
      'role': role,
      'team_size': teamSize,
      'industry': industry,
      'date': _formatDate(date),
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      'startup_stage': startupStage,
      'role': role,
      'team_size': teamSize,
      'industry': industry,
      'date': date.toIso8601String(),
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StartupCareerFortuneConditions &&
          runtimeType == other.runtimeType &&
          startupStage == other.startupStage &&
          role == other.role &&
          teamSize == other.teamSize &&
          industry == other.industry &&
          date == other.date;

  @override
  int get hashCode =>
      startupStage.hashCode ^
      role.hashCode ^
      teamSize.hashCode ^
      industry.hashCode ^
      date.hashCode;
}
