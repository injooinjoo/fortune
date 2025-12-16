import '../fortune_conditions.dart';

/// 전애인 운세 조건
class ExLoverFortuneConditions extends FortuneConditions {
  // 상대방 정보
  final String? exName; // 상대방 이름/닉네임
  final String? exMbti; // 상대방 MBTI
  final DateTime? exBirthDate; // 선택사항

  // 관계 정보
  final String relationshipDuration; // 관계 기간
  final String timeSinceBreakup; // 'recent', 'short', 'medium', 'long', 'verylong'
  final String breakupInitiator; // 'me', 'them', 'mutual'
  final String contactStatus; // 'blocked', 'noContact', 'sometimes', 'often', 'stillMeeting'

  // 이별 상세
  final String? breakupReason; // 'differentValues', 'timing', 'communication', 'trust', 'other'
  final String? breakupDetail; // STT/타이핑 상세 이유

  // 감정 정보
  final String currentEmotion; // 'miss', 'anger', 'sadness', 'relief', 'acceptance'
  final String mainCuriosity; // 'theirFeelings', 'reunionChance', 'newLove', 'healing'

  // 추가 정보
  final String? chatHistory; // 카톡/대화 내용
  final DateTime date; // 조회 날짜

  ExLoverFortuneConditions({
    this.exName,
    this.exMbti,
    this.exBirthDate,
    required this.relationshipDuration,
    required this.timeSinceBreakup,
    required this.breakupInitiator,
    required this.contactStatus,
    this.breakupReason,
    this.breakupDetail,
    required this.currentEmotion,
    required this.mainCuriosity,
    this.chatHistory,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  @override
  String generateHash() {
    // 동일 조건 판단: 감정 + 시기 + 궁금증 + 이별통보자 + 연락상태
    // 이름, MBTI, 생년월일, 상세이유, 카톡내용은 제외 (너무 세분화되면 재사용 불가)
    return 'ex_lover:$currentEmotion|$timeSinceBreakup|$mainCuriosity|$breakupInitiator|$contactStatus';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'ex_name': exName,
      'ex_mbti': exMbti,
      'ex_birth_date': exBirthDate?.toIso8601String(),
      'relationship_duration': relationshipDuration,
      'time_since_breakup': timeSinceBreakup,
      'breakup_initiator': breakupInitiator,
      'contact_status': contactStatus,
      'breakup_reason': breakupReason,
      'breakup_detail': breakupDetail,
      'current_emotion': currentEmotion,
      'main_curiosity': mainCuriosity,
      'chat_history': chatHistory,
      'date': date.toIso8601String(),
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      'time_since_breakup': timeSinceBreakup,
      'current_emotion': currentEmotion,
      'main_curiosity': mainCuriosity,
      'breakup_initiator': breakupInitiator,
      'contact_status': contactStatus,
      'date': _formatDate(date),
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      if (exName != null) 'exName': exName,
      if (exMbti != null && exMbti != 'unknown') 'exMbti': exMbti,
      if (exBirthDate != null) 'exBirthDate': exBirthDate!.toIso8601String(),
      'relationshipDuration': relationshipDuration,
      'timeSinceBreakup': timeSinceBreakup,
      'breakupInitiator': breakupInitiator,
      'contactStatus': contactStatus,
      if (breakupReason != null) 'breakupReason': breakupReason,
      if (breakupDetail != null && breakupDetail!.isNotEmpty) 'breakupDetail': breakupDetail,
      'currentEmotion': currentEmotion,
      'mainCuriosity': mainCuriosity,
      if (chatHistory != null && chatHistory!.isNotEmpty) 'chatHistory': chatHistory,
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
          mainCuriosity == other.mainCuriosity &&
          breakupInitiator == other.breakupInitiator &&
          contactStatus == other.contactStatus;

  @override
  int get hashCode =>
      timeSinceBreakup.hashCode ^
      currentEmotion.hashCode ^
      mainCuriosity.hashCode ^
      breakupInitiator.hashCode ^
      contactStatus.hashCode;
}
