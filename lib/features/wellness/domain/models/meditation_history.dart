// 명상 히스토리 엔트리
class MeditationHistoryEntry {
  final String id;
  final DateTime date;
  final int durationMinutes;
  final int completedCycles;
  final String patternName;

  const MeditationHistoryEntry({
    required this.id,
    required this.date,
    required this.durationMinutes,
    required this.completedCycles,
    required this.patternName,
  });

  factory MeditationHistoryEntry.fromJson(Map<String, dynamic> json) {
    return MeditationHistoryEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      durationMinutes: json['durationMinutes'] as int,
      completedCycles: json['completedCycles'] as int,
      patternName: json['patternName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'durationMinutes': durationMinutes,
      'completedCycles': completedCycles,
      'patternName': patternName,
    };
  }
}

/// 명상 통계
class MeditationStatistics {
  final int totalSessions;
  final int totalMinutes;
  final int consecutiveDays;
  final DateTime? lastMeditationDate;
  final int currentGemLevel; // 0-4 (새싹, 성장, 개화, 결실, 완성)

  const MeditationStatistics({
    this.totalSessions = 0,
    this.totalMinutes = 0,
    this.consecutiveDays = 0,
    this.lastMeditationDate,
    this.currentGemLevel = 0,
  });

  factory MeditationStatistics.fromJson(Map<String, dynamic> json) {
    return MeditationStatistics(
      totalSessions: json['totalSessions'] as int? ?? 0,
      totalMinutes: json['totalMinutes'] as int? ?? 0,
      consecutiveDays: json['consecutiveDays'] as int? ?? 0,
      lastMeditationDate: json['lastMeditationDate'] != null
          ? DateTime.parse(json['lastMeditationDate'] as String)
          : null,
      currentGemLevel: json['currentGemLevel'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSessions': totalSessions,
      'totalMinutes': totalMinutes,
      'consecutiveDays': consecutiveDays,
      'lastMeditationDate': lastMeditationDate?.toIso8601String(),
      'currentGemLevel': currentGemLevel,
    };
  }

  MeditationStatistics copyWith({
    int? totalSessions,
    int? totalMinutes,
    int? consecutiveDays,
    DateTime? lastMeditationDate,
    int? currentGemLevel,
  }) {
    return MeditationStatistics(
      totalSessions: totalSessions ?? this.totalSessions,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      lastMeditationDate: lastMeditationDate ?? this.lastMeditationDate,
      currentGemLevel: currentGemLevel ?? this.currentGemLevel,
    );
  }

  /// 원석 레벨에 따른 이름
  String get gemLevelName {
    switch (currentGemLevel) {
      case 0:
        return '원석의 씨앗';
      case 1:
        return '싹트는 원석';
      case 2:
        return '자라는 원석';
      case 3:
        return '빛나는 원석';
      case 4:
        return '완성된 보석';
      default:
        return '원석의 씨앗';
    }
  }

  /// 연속 일수에 따른 격려 메시지
  String get streakMessage {
    if (consecutiveDays == 0) {
      return '오늘 첫 명상을 시작해보세요';
    } else if (consecutiveDays == 1) {
      return '오늘 첫 발걸음을 내딛었어요';
    } else if (consecutiveDays < 7) {
      return '연속 $consecutiveDays일째 마음을 다스리고 계시네요';
    } else if (consecutiveDays < 14) {
      return '연속 $consecutiveDays일째! 평온한 하루가 쌓이고 있어요';
    } else if (consecutiveDays < 30) {
      return '연속 $consecutiveDays일째 명상 중! 내면의 힘이 자라고 있어요';
    } else {
      return '연속 $consecutiveDays일! 당신의 마음은 맑은 호수 같아요';
    }
  }

  /// 다음 레벨까지 필요한 세션 수
  int get sessionsToNextLevel {
    final thresholds = [3, 10, 25, 50]; // 각 레벨 업 기준
    if (currentGemLevel >= 4) return 0;
    return thresholds[currentGemLevel] - totalSessions;
  }
}
