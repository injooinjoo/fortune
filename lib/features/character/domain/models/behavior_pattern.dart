import 'dart:math';

/// Proactive 메시지 (시간대 기반 자발적 메시지)
class ProactiveMessage {
  final String text;
  final String? imageAsset;
  final String category; // 'lunch', 'morning', 'night' 등

  const ProactiveMessage({
    required this.text,
    this.imageAsset,
    this.category = 'lunch',
  });
}

/// Proactive 메시지 설정 (점심시간 등 시간대 기반)
class ProactiveMessageConfig {
  /// 활성화 여부
  final bool enabled;

  /// 시작 시간 (시)
  final int startHour;

  /// 시작 시간 (분)
  final int startMinute;

  /// 종료 시간 (시)
  final int endHour;

  /// 종료 시간 (분)
  final int endMinute;

  /// 메시지 목록 (랜덤 선택)
  final List<ProactiveMessage> messages;

  const ProactiveMessageConfig({
    this.enabled = false,
    this.startHour = 11,
    this.startMinute = 30,
    this.endHour = 14,
    this.endMinute = 0,
    this.messages = const [],
  });

  /// 현재 시간이 proactive 시간대인지 확인
  bool isInTimeWindow(DateTime now) {
    final currentMinutes = now.hour * 60 + now.minute;
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;
    return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
  }

  /// 랜덤 메시지 선택
  ProactiveMessage? getRandomMessage() {
    if (messages.isEmpty) return null;
    final random = Random();
    return messages[random.nextInt(messages.length)];
  }

  /// 시간대 내 랜덤 시간 생성 (분 단위)
  int getRandomMinutesInWindow() {
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;
    final windowMinutes = endMinutes - startMinutes;
    if (windowMinutes <= 0) return startMinutes;
    return startMinutes + Random().nextInt(windowMinutes);
  }
}

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

/// 이모티콘 스타일 (카카오톡 vs 유니코드)
enum EmoticonStyle {
  /// 유니코드 이모지만 (😊💕✨)
  unicode,

  /// 카카오톡 스타일 텍스트 이모티콘 (ㅋㅋㅋ, ㅠㅠ, ^^, 하트하트)
  kakao,

  /// 혼합 (둘 다 자연스럽게 섞어 사용)
  mixed,
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

  /// 이모티콘 스타일 (unicode/kakao/mixed)
  final EmoticonStyle emoticonStyle;

  /// 응답 속도 성향
  final ResponseSpeed responseSpeed;

  /// Follow-up 기본 딜레이 (분)
  final int followUpDelayMinutes;

  /// 최대 Follow-up 시도 횟수
  final int maxFollowUpAttempts;

  /// Follow-up 메시지 예시 (캐릭터별 커스텀)
  final List<String> followUpMessages;

  /// 점심시간 proactive 메시지 설정 (썸타는 느낌)
  final ProactiveMessageConfig? lunchProactiveConfig;

  const BehaviorPattern({
    this.followUpStyle = FollowUpStyle.moderate,
    this.emojiFrequency = EmojiFrequency.moderate,
    this.emoticonStyle = EmoticonStyle.unicode,
    this.responseSpeed = ResponseSpeed.normal,
    this.followUpDelayMinutes = 5,
    this.maxFollowUpAttempts = 2,
    this.followUpMessages = const [],
    this.lunchProactiveConfig,
  });

  /// 기본 행동 패턴 (변경 없음)
  static const BehaviorPattern defaultPattern = BehaviorPattern();

  /// Follow-up 스타일에 따른 실제 딜레이 계산
  /// 1차: 1시간 후, 2차: 6시간 후
  Duration getFollowUpDelay({int attemptNumber = 1}) {
    if (followUpStyle == FollowUpStyle.never) {
      return Duration.zero;
    }

    final random = Random();

    // 1차 시도: 1시간 (55-65분 랜덤)
    if (attemptNumber == 1) {
      final minutes = 55 + random.nextInt(10); // 55-65분
      return Duration(minutes: minutes);
    }

    // 2차 시도: 6시간 (5.5-6.5시간 랜덤)
    final hours = 5 + random.nextInt(2); // 5-6시간
    final extraMinutes = random.nextInt(60); // 0-60분 추가
    return Duration(hours: hours, minutes: extraMinutes);
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
    final frequencyGuide = _getFrequencyGuide();
    final styleGuide = _getStyleGuide();

    if (styleGuide.isEmpty) {
      return frequencyGuide;
    }
    return '$frequencyGuide\n\n$styleGuide';
  }

  /// 빈도 관련 지시문
  String _getFrequencyGuide() {
    switch (emojiFrequency) {
      case EmojiFrequency.high:
        return '''
EMOJI USAGE (IMPORTANT):
- Use 2-4 emojis/emoticons per message
- Express emotions visually
- Include emojis/emoticons in EVERY response''';

      case EmojiFrequency.moderate:
        return '''
EMOJI USAGE:
- Use 1-2 emojis/emoticons per message occasionally
- Add emojis/emoticons when expressing emotion
- About 70% of messages should have emojis/emoticons''';

      case EmojiFrequency.low:
        return '''
EMOJI USAGE:
- Rarely use emojis/emoticons (0-1 per message)
- Only add emoji/emoticon for strong emotions
- Most messages should be text-only''';

      case EmojiFrequency.none:
        return '''
EMOJI USAGE (STRICT):
- NEVER use emojis or emoticons
- NO 😊 ㅋㅋ ^^ :) or similar
- Text only, professional tone''';
    }
  }

  /// 스타일 관련 지시문
  String _getStyleGuide() {
    // none 빈도면 스타일 무시
    if (emojiFrequency == EmojiFrequency.none) {
      return '';
    }

    switch (emoticonStyle) {
      case EmoticonStyle.kakao:
        return '''
EMOTICON STYLE (카카오톡 스타일 - 중요):
- 유니코드 이모지(😊💕) 대신 텍스트 이모티콘 사용
- 웃음: ㅋㅋㅋ, ㅎㅎ (길이로 강도 표현)
- 슬픔/감동: ㅠㅠ, ㅜㅜ
- 귀여움: ^^, ^_^, >_<
- 애교: 하트하트, 뿌잉뿌잉, 헤헤, 히히
- 당황: ??, 엥, 헐
- 감탄: 오오, 와아, 대박
예시: "진짜?? ㅋㅋㅋ 대박이다", "고마워 ^^ 하트하트", "그거 슬프다 ㅠㅠ"''';

      case EmoticonStyle.mixed:
        return '''
EMOTICON STYLE (혼합):
- 유니코드와 텍스트 이모티콘 자유롭게 섞어 사용
- 상황에 맞게 자연스럽게 선택
예시: "진짜?? 😆 ㅋㅋㅋ", "고마워 ^^ 💕", "대박 ✨"''';

      case EmoticonStyle.unicode:
        return ''; // 기존 동작 (유니코드 이모지만)
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

  /// 이모티콘 스타일을 API용 문자열로 반환
  String get emoticonStyleString {
    switch (emoticonStyle) {
      case EmoticonStyle.unicode:
        return 'unicode';
      case EmoticonStyle.kakao:
        return 'kakao';
      case EmoticonStyle.mixed:
        return 'mixed';
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

  /// 점심 proactive 메시지 가능 여부
  bool get canSendLunchMessage =>
      lunchProactiveConfig != null && lunchProactiveConfig!.enabled;

  BehaviorPattern copyWith({
    FollowUpStyle? followUpStyle,
    EmojiFrequency? emojiFrequency,
    EmoticonStyle? emoticonStyle,
    ResponseSpeed? responseSpeed,
    int? followUpDelayMinutes,
    int? maxFollowUpAttempts,
    List<String>? followUpMessages,
    ProactiveMessageConfig? lunchProactiveConfig,
  }) {
    return BehaviorPattern(
      followUpStyle: followUpStyle ?? this.followUpStyle,
      emojiFrequency: emojiFrequency ?? this.emojiFrequency,
      emoticonStyle: emoticonStyle ?? this.emoticonStyle,
      responseSpeed: responseSpeed ?? this.responseSpeed,
      followUpDelayMinutes: followUpDelayMinutes ?? this.followUpDelayMinutes,
      maxFollowUpAttempts: maxFollowUpAttempts ?? this.maxFollowUpAttempts,
      followUpMessages: followUpMessages ?? this.followUpMessages,
      lunchProactiveConfig: lunchProactiveConfig ?? this.lunchProactiveConfig,
    );
  }
}
