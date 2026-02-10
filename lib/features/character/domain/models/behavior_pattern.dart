import 'dart:math';

/// Follow-up 메시지 스타일
enum FollowUpStyle {
  /// 적극적: 1-3분 내 재연락, 최대 3회
  aggressive,

  /// 보통: 5-10분 내 재연락, 최대 2회
  moderate,

  /// 소극적: 15-30분 내 재연락, 1회
  passive,

  /// 없음: 절대 먼저 연락 안함
  never,
}

/// 이모티콘 사용 빈도
enum EmojiFrequency {
  /// 많음: 메시지당 2-4개, 매번 사용
  high,

  /// 보통: 메시지당 1-2개, 70% 확률
  moderate,

  /// 적음: 메시지당 0-1개, 30% 확률
  low,

  /// 없음: 절대 이모티콘 사용 안함
  none,
}

/// 응답 속도 성향
enum ResponseSpeed {
  /// 즉시: 0.5-2초 (항상 온라인)
  instant,

  /// 빠름: 2-5초 (관심 많음)
  fast,

  /// 보통: 5-15초 (현실적)
  normal,

  /// 느림: 15-45초 (바쁨/신중함)
  slow,

  /// 불규칙: 랜덤 (예측 불가)
  erratic,
}

/// 캐릭터 행동 패턴 설정
class BehaviorPattern {
  /// Follow-up 메시지 스타일
  final FollowUpStyle followUpStyle;

  /// 이모티콘 사용 빈도
  final EmojiFrequency emojiFrequency;

  /// 응답 속도 성향
  final ResponseSpeed responseSpeed;

  /// Follow-up 기본 딜레이 (분)
  final int followUpDelayMinutes;

  /// 최대 Follow-up 시도 횟수
  final int maxFollowUpAttempts;

  /// Follow-up 메시지 예시 (캐릭터별 커스텀)
  final List<String> followUpMessages;

  const BehaviorPattern({
    this.followUpStyle = FollowUpStyle.moderate,
    this.emojiFrequency = EmojiFrequency.moderate,
    this.responseSpeed = ResponseSpeed.normal,
    this.followUpDelayMinutes = 5,
    this.maxFollowUpAttempts = 2,
    this.followUpMessages = const [],
  });

  /// 기본 행동 패턴 (변경 없음)
  static const BehaviorPattern defaultPattern = BehaviorPattern();

  /// Follow-up 스타일에 따른 실제 딜레이 계산
  Duration getFollowUpDelay({int attemptNumber = 1}) {
    final random = Random();

    switch (followUpStyle) {
      case FollowUpStyle.aggressive:
        // 1-3분, 시도할수록 짧아짐
        final baseMinutes = 3 - attemptNumber.clamp(0, 2);
        final variance = random.nextInt(60); // 0-60초 랜덤
        return Duration(minutes: baseMinutes, seconds: variance);

      case FollowUpStyle.moderate:
        // 5-10분
        final minutes = followUpDelayMinutes + random.nextInt(5);
        return Duration(minutes: minutes);

      case FollowUpStyle.passive:
        // 15-30분
        final minutes = 15 + random.nextInt(15);
        return Duration(minutes: minutes);

      case FollowUpStyle.never:
        return Duration.zero;
    }
  }

  /// 응답 속도에 따른 추가 타이핑 딜레이 계산
  Duration getTypingDelay() {
    final random = Random();

    switch (responseSpeed) {
      case ResponseSpeed.instant:
        return Duration(milliseconds: 500 + random.nextInt(1500));

      case ResponseSpeed.fast:
        return Duration(seconds: 2 + random.nextInt(3));

      case ResponseSpeed.normal:
        return Duration(seconds: 5 + random.nextInt(10));

      case ResponseSpeed.slow:
        return Duration(seconds: 15 + random.nextInt(30));

      case ResponseSpeed.erratic:
        // 불규칙: 1초 ~ 40초 랜덤
        return Duration(seconds: 1 + random.nextInt(39));
    }
  }

  /// 이모티콘 프롬프트 지시문 생성
  String getEmojiInstruction() {
    switch (emojiFrequency) {
      case EmojiFrequency.high:
        return '''
EMOJI USAGE (IMPORTANT):
- Use 2-4 emojis per message
- Express emotions visually with emojis
- Include emojis in EVERY response
- Examples: "정말요?! 😆✨ 너무 좋아요! 💕"''';

      case EmojiFrequency.moderate:
        return '''
EMOJI USAGE:
- Use 1-2 emojis per message occasionally
- Add emojis when expressing emotion
- About 70% of messages should have emojis''';

      case EmojiFrequency.low:
        return '''
EMOJI USAGE:
- Rarely use emojis (0-1 per message)
- Only add emoji for strong emotions
- Most messages should be text-only''';

      case EmojiFrequency.none:
        return '''
EMOJI USAGE (STRICT):
- NEVER use emojis or emoticons
- NO 😊 ㅋㅋ ^^ :) or similar
- Text only, professional tone''';
    }
  }

  /// Follow-up 가능 여부
  bool get canFollowUp => followUpStyle != FollowUpStyle.never;

  /// 이모티콘 빈도를 API용 문자열로 반환
  String get emojiFrequencyString {
    switch (emojiFrequency) {
      case EmojiFrequency.high:
        return 'high';
      case EmojiFrequency.moderate:
        return 'moderate';
      case EmojiFrequency.low:
        return 'low';
      case EmojiFrequency.none:
        return 'none';
    }
  }

  /// 시도 횟수 내인지 확인
  bool canAttemptFollowUp(int currentAttempt) {
    if (followUpStyle == FollowUpStyle.never) return false;
    return currentAttempt <= maxFollowUpAttempts;
  }

  /// Follow-up 메시지 랜덤 선택 (다양성 확보)
  String? getFollowUpMessage(int attemptNumber) {
    if (followUpMessages.isEmpty) return null;
    // 랜덤 선택으로 매번 다른 메시지 제공
    final random = Random();
    final index = random.nextInt(followUpMessages.length);
    return followUpMessages[index];
  }

  BehaviorPattern copyWith({
    FollowUpStyle? followUpStyle,
    EmojiFrequency? emojiFrequency,
    ResponseSpeed? responseSpeed,
    int? followUpDelayMinutes,
    int? maxFollowUpAttempts,
    List<String>? followUpMessages,
  }) {
    return BehaviorPattern(
      followUpStyle: followUpStyle ?? this.followUpStyle,
      emojiFrequency: emojiFrequency ?? this.emojiFrequency,
      responseSpeed: responseSpeed ?? this.responseSpeed,
      followUpDelayMinutes: followUpDelayMinutes ?? this.followUpDelayMinutes,
      maxFollowUpAttempts: maxFollowUpAttempts ?? this.maxFollowUpAttempts,
      followUpMessages: followUpMessages ?? this.followUpMessages,
    );
  }
}
