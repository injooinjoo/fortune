import '../fortune_conditions.dart';

/// 전애인 운세 조건
class ExLoverFortuneConditions extends FortuneConditions {
  final String timeSinceBreakup; // 'recent', 'short', 'medium', 'long', 'verylong'
  final String currentEmotion; // 'miss', 'anger', 'sadness', 'relief', 'acceptance'
  final String mainCuriosity; // 'theirFeelings', 'reunionChance', 'newLove', 'healing'
  final DateTime? exBirthDate; // 선택사항
  final String? breakupReason; // 'differentValues', 'timing', 'communication', 'trust', 'other'
  final DateTime date; // 조회 날짜

  ExLoverFortuneConditions({
    required this.timeSinceBreakup,
    required this.currentEmotion,
    required this.mainCuriosity,
    this.exBirthDate,
    this.breakupReason,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  @override
  String generateHash() {
    // 동일 조건 판단: 감정 + 시기 + 궁금증
    // 이별 이유와 생년월일은 제외 (너무 세분화되면 재사용 불가)
    return 'ex_lover:$currentEmotion|$timeSinceBreakup|$mainCuriosity';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'time_since_breakup': timeSinceBreakup,
      'current_emotion': currentEmotion,
      'main_curiosity': mainCuriosity,
      'ex_birth_date': exBirthDate?.toIso8601String(),
      'breakup_reason': breakupReason,
      'date': date.toIso8601String(),
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      'time_since_breakup': timeSinceBreakup,
      'current_emotion': currentEmotion,
      'main_curiosity': mainCuriosity,
      'date': _formatDate(date),
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      'timeSinceBreakup': timeSinceBreakup,
      'currentEmotion': currentEmotion,
      'mainCuriosity': mainCuriosity,
      if (exBirthDate != null) 'exBirthDate': exBirthDate!.toIso8601String(),
      if (breakupReason != null) 'breakupReason': breakupReason,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExLoverFortuneConditions &&
          runtimeType == other.runtimeType &&
          timeSinceBreakup == other.timeSinceBreakup &&
          currentEmotion == other.currentEmotion &&
          mainCuriosity == other.mainCuriosity;

  @override
  int get hashCode =>
      timeSinceBreakup.hashCode ^
      currentEmotion.hashCode ^
      mainCuriosity.hashCode;
}
