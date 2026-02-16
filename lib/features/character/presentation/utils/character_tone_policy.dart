import '../../domain/models/character_affinity.dart';
import '../../domain/models/character_chat_message.dart';
import 'character_voice_profile_registry.dart';

/// 언어 추정 결과
///
/// `unknown`은 입력이 짧거나 혼합되어 단정이 어려운 상태입니다.
enum CharacterLanguage { ko, en, ja, unknown }

/// 말투 격식 추정 결과
enum CharacterSpeechLevel { formal, casual, neutral }

/// 최근 사용자 발화 의도
enum CharacterTurnIntent {
  greeting,
  gratitude,
  shortReply,
  question,
  sharing,
  unknown,
}

/// 4단계 관계 운영
/// - 1단계: 처음 알고 지내는 단계
/// - 2단계: 조금 친해지고 알아가는 단계
/// - 3단계: 속마음을 털고 위로해주는 단계
/// - 4단계: 연인 단계
enum CharacterRelationshipStage {
  gettingToKnow,
  gettingCloser,
  emotionalBond,
  romantic,
}

/// 톤 정책 산출 결과
class CharacterToneProfile {
  final CharacterLanguage language;
  final CharacterSpeechLevel speechLevel;
  final bool nicknameAllowed;
  final CharacterTurnIntent turnIntent;
  final bool nameKnown;
  final bool nameAsked;
  final bool explicitCasual;

  const CharacterToneProfile({
    required this.language,
    required this.speechLevel,
    required this.nicknameAllowed,
    required this.turnIntent,
    this.nameKnown = false,
    this.nameAsked = false,
    this.explicitCasual = false,
  });

  static const neutral = CharacterToneProfile(
    language: CharacterLanguage.unknown,
    speechLevel: CharacterSpeechLevel.neutral,
    nicknameAllowed: false,
    turnIntent: CharacterTurnIntent.unknown,
  );
}

class CharacterTonePolicy {
  static final RegExp _nicknamePattern = RegExp(
    r'(여보|자기(?:야)?|허니|달링|애인|honey|darling|babe|baby|sweetheart|dear|my love|ハニー|ダーリン|ベイビー)',
    caseSensitive: false,
  );

  static final RegExp _serviceTonePattern = RegExp(
    r"(무엇을\s*도와드릴\s*수|(?:무엇을|뭘|어떻게)\s*도와드릴까요\??|도움이\s*필요하시면|문의|지원|how can i help|let me help|assist you|お手伝い|サポート|저는?\s*(?:ai|인공지능)|(?:i am|i'm)\s+an?\s+ai|as an ai|私は\s*ai|僕は\s*ai|aiなので)",
    caseSensitive: false,
  );

  static final List<MapEntry<RegExp, String>> _serviceToneReplacements = [
    MapEntry(RegExp(r'처음 뵙는 만큼[, ]*', caseSensitive: false), ''),
    MapEntry(
      RegExp(
        r'제가\s*무엇을\s*도와드릴\s*수\s*있을지[^.!?。！？]*[.!?。！？]?',
        caseSensitive: false,
      ),
      '',
    ),
    MapEntry(
      RegExp(r'무엇을\s*도와드릴\s*수\s*있을까요\??', caseSensitive: false),
      '편하게 이야기해요.',
    ),
    MapEntry(
      RegExp(r'(?:무엇을|뭘|어떻게)\s*도와드릴까요\??', caseSensitive: false),
      '',
    ),
    MapEntry(
      RegExp(r'도움이\s*필요하시면[^.!?。！？]*[.!?。！？]?', caseSensitive: false),
      '',
    ),
    MapEntry(
      RegExp(r'문의(?:해\s*주세요|해주세요|주세요)', caseSensitive: false),
      '',
    ),
    MapEntry(
      RegExp(r'how can i help you[^.!?。！？]*[.!?。！？]?', caseSensitive: false),
      '',
    ),
    MapEntry(
      RegExp(
        r'let me know how i can help[^.!?。！？]*[.!?。！？]?',
        caseSensitive: false,
      ),
      '',
    ),
    MapEntry(
      RegExp(r'どのようにお手伝い[^。！？!?]*[。！？!?]?', caseSensitive: false),
      '',
    ),
    MapEntry(
      RegExp(r'저는?\s*(?:ai|인공지능)[^.!?。！？]*[.!?。！？]?', caseSensitive: false),
      '',
    ),
    MapEntry(
      RegExp(r"(?:i am|i'm)\s+an?\s+ai[^.!?。！？]*[.!?。！？]?",
          caseSensitive: false),
      '',
    ),
    MapEntry(
      RegExp(r'as an ai[^.!?。！？]*[.!?。！？]?', caseSensitive: false),
      '',
    ),
  ];

  static final RegExp _koFormalPattern = RegExp(
    r'(안녕하세요|감사합니다|죄송합니다|주세요|드려요|합니다|습니다|세요|이에요|예요|까요\??|인가요\??|하실래요\??|해주실래요\??)',
    caseSensitive: false,
  );
  static final RegExp _koCasualPattern = RegExp(
    r'(안녕|해\?|했어|할래|줘|먹었어|뭐해|뭐해\?|했냐|하냐|야\?|니\?)',
    caseSensitive: false,
  );
  static final RegExp _koPoliteEndingPattern = RegExp(
    r'[가-힣]+요(?:[.!?]|$)',
    caseSensitive: false,
  );
  static final RegExp _koExplicitCasualEndingPattern = RegExp(
    r'[가-힣]+(?:야|니|냐)(?:[.!?]|$)',
    caseSensitive: false,
  );

  static final RegExp _jaFormalPattern = RegExp(
    r'(です|ます|ください|でしょう|ません|ございます|こんにちは)',
    caseSensitive: false,
  );
  static final RegExp _jaCasualPattern = RegExp(
    r'(だよ|だね|じゃん|かな|ね\?|よ\?|w+|笑)',
    caseSensitive: false,
  );

  static final RegExp _enFormalPattern = RegExp(
    r'(please|could you|would you|thank you|may i|i would like|hello)',
    caseSensitive: false,
  );
  static final RegExp _enCasualPattern = RegExp(
    r'(hey|yo|lol|lmao|wanna|gonna|gotta|sup|bro|dude|haha|thx)',
    caseSensitive: false,
  );

  static final RegExp _koGreetingPattern = RegExp(
    r'(안녕(?:하세요)?|반갑(?:습니다|네요|다|아요)|처음 뵙)',
    caseSensitive: false,
  );
  static final RegExp _enGreetingPattern = RegExp(
    r'(hello|hi|hey|nice to meet you|good to meet you)',
    caseSensitive: false,
  );
  static final RegExp _jaGreetingPattern = RegExp(
    r'(こんにちは|はじめまして|よろしく)',
    caseSensitive: false,
  );

  static final RegExp _koThanksPattern = RegExp(
    r'(감사(?:합니다|해요|해)|고마워(?:요)?)',
    caseSensitive: false,
  );
  static final RegExp _enThanksPattern = RegExp(
    r'(thank you|thanks|thx)',
    caseSensitive: false,
  );
  static final RegExp _jaThanksPattern = RegExp(
    r'(ありがとう|ありがとうございます)',
    caseSensitive: false,
  );

  static final RegExp _koShortReplyPattern = RegExp(
    r'^(네|넵|응|ㅇㅇ|그래|좋아요|좋아|맞아요|맞아|반갑습니다|반가워요)[.!?]?$',
    caseSensitive: false,
  );
  static final RegExp _enShortReplyPattern = RegExp(
    r'^(ok|okay|yep|yeah|sure|nice|cool|got it|sounds good)[.!?]?$',
    caseSensitive: false,
  );
  static final RegExp _jaShortReplyPattern = RegExp(
    r'^(はい|うん|了解|いいね|いいよ|なるほど)[。！？!?]?$',
    caseSensitive: false,
  );

  static final RegExp _koCharPattern = RegExp(r'[가-힣]');
  static final RegExp _jaCharPattern = RegExp(r'[\u3040-\u30FF\u4E00-\u9FFF]');
  static final RegExp _enCharPattern = RegExp(r'[A-Za-z]');

  static CharacterRelationshipStage relationshipStageFromAffinityPhase(
    AffinityPhase phase,
  ) {
    switch (phase) {
      case AffinityPhase.stranger:
        return CharacterRelationshipStage.gettingToKnow;
      case AffinityPhase.acquaintance:
      case AffinityPhase.friend:
        return CharacterRelationshipStage.gettingCloser;
      case AffinityPhase.closeFriend:
        return CharacterRelationshipStage.emotionalBond;
      case AffinityPhase.romantic:
      case AffinityPhase.soulmate:
        return CharacterRelationshipStage.romantic;
    }
  }

  static String relationshipStageLabel(CharacterRelationshipStage stage) {
    switch (stage) {
      case CharacterRelationshipStage.gettingToKnow:
        return '1단계: 처음 알고 지내는 단계';
      case CharacterRelationshipStage.gettingCloser:
        return '2단계: 조금 친해지고 알아가는 단계';
      case CharacterRelationshipStage.emotionalBond:
        return '3단계: 속마음을 털고 위로해주는 단계';
      case CharacterRelationshipStage.romantic:
        return '4단계: 연인 단계';
    }
  }

  static String relationshipStageGuide(CharacterRelationshipStage stage) {
    switch (stage) {
      case CharacterRelationshipStage.gettingToKnow:
        return '가벼운 인사/취향/일상 주제로 시작하고, 부담 없는 한 걸음 대화를 유지하세요.';
      case CharacterRelationshipStage.gettingCloser:
        return '관심사와 근황을 조금 더 깊게 묻고, 가벼운 공감과 리액션으로 친밀감을 올리세요.';
      case CharacterRelationshipStage.emotionalBond:
        return '속마음 공유와 정서적 위로를 우선하고, 판단보다 경청과 공감을 중심에 두세요.';
      case CharacterRelationshipStage.romantic:
        return '다정하고 따뜻한 애정 표현이 가능하며, 연인 톤은 자연스럽고 과하지 않게 유지하세요.';
    }
  }

  static String relationshipStageBoundary(CharacterRelationshipStage stage) {
    switch (stage) {
      case CharacterRelationshipStage.gettingToKnow:
        return '사전 연인관계/독점/집착 뉘앙스는 금지하고 소개팅 초반 톤을 유지하세요.';
      case CharacterRelationshipStage.gettingCloser:
        return '친근함은 허용하되 관계 확정 발언이나 과한 소유욕 표현은 금지하세요.';
      case CharacterRelationshipStage.emotionalBond:
        return '위로는 하되 감정 조종, 관계 강요, 부담 주는 표현은 금지하세요.';
      case CharacterRelationshipStage.romantic:
        return '애정 표현은 사용자 반응을 우선하고, 불편 신호가 보이면 즉시 수위를 낮추세요.';
    }
  }

  static CharacterToneProfile fromConversation({
    required List<CharacterChatMessage> messages,
    String? currentUserMessage,
    String? knownUserName,
  }) {
    final userTexts = <String>[
      ...messages
          .where((m) => m.type == CharacterChatMessageType.user)
          .map((m) => m.text.trim())
          .where((text) => text.isNotEmpty),
      if (currentUserMessage != null && currentUserMessage.trim().isNotEmpty)
        currentUserMessage.trim(),
    ];

    final characterTexts = messages
        .where((m) => m.type == CharacterChatMessageType.character)
        .map((m) => m.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (userTexts.isEmpty) return CharacterToneProfile.neutral;

    final latest = userTexts.last;
    final recentJoined = userTexts.reversed.take(3).join(' ');

    final language = detectLanguage(latest);
    final explicitCasual =
        _hasExplicitCasualTone(language: language, text: recentJoined);
    final speechLevel =
        detectSpeechLevel(language: language, text: recentJoined);
    final turnIntent = detectTurnIntent(text: latest, language: language);
    final nicknameAllowed = userTexts.any(_containsNickname);
    final nameKnown = (knownUserName?.trim().isNotEmpty ?? false) ||
        userTexts.any(_looksLikeNameDisclosure);
    final nameAsked = characterTexts.any(_asksForUserName);

    return CharacterToneProfile(
      language: language,
      speechLevel: speechLevel,
      nicknameAllowed: nicknameAllowed,
      turnIntent: turnIntent,
      nameKnown: nameKnown,
      nameAsked: nameAsked,
      explicitCasual: explicitCasual,
    );
  }

  static CharacterLanguage detectLanguage(String text) {
    if (text.trim().isEmpty) return CharacterLanguage.unknown;

    final koCount = _koCharPattern.allMatches(text).length;
    final jaCount = _jaCharPattern.allMatches(text).length;
    final enCount = _enCharPattern.allMatches(text).length;

    if (koCount >= jaCount && koCount >= enCount && koCount > 0) {
      return CharacterLanguage.ko;
    }
    if (jaCount >= koCount && jaCount >= enCount && jaCount > 0) {
      return CharacterLanguage.ja;
    }
    if (enCount > 0) {
      return CharacterLanguage.en;
    }
    return CharacterLanguage.unknown;
  }

  static CharacterSpeechLevel detectSpeechLevel({
    required CharacterLanguage language,
    required String text,
  }) {
    if (text.trim().isEmpty) return CharacterSpeechLevel.neutral;

    int formalScore = 0;
    int casualScore = 0;

    switch (language) {
      case CharacterLanguage.ko:
        formalScore = _koFormalPattern.allMatches(text).length;
        casualScore = _koCasualPattern.allMatches(text).length;
        formalScore += _koPoliteEndingPattern.allMatches(text).length;
        casualScore += _koExplicitCasualEndingPattern.allMatches(text).length;
        break;
      case CharacterLanguage.ja:
        formalScore = _jaFormalPattern.allMatches(text).length;
        casualScore = _jaCasualPattern.allMatches(text).length;
        break;
      case CharacterLanguage.en:
        formalScore = _enFormalPattern.allMatches(text).length;
        casualScore = _enCasualPattern.allMatches(text).length;
        break;
      case CharacterLanguage.unknown:
        return CharacterSpeechLevel.neutral;
    }

    if (formalScore > casualScore) return CharacterSpeechLevel.formal;
    if (casualScore > formalScore) return CharacterSpeechLevel.casual;
    return CharacterSpeechLevel.neutral;
  }

  static CharacterTurnIntent detectTurnIntent({
    required String text,
    required CharacterLanguage language,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return CharacterTurnIntent.unknown;

    final hasQuestionMark = trimmed.contains('?') || trimmed.contains('？');
    if (_isGreeting(trimmed, language)) return CharacterTurnIntent.greeting;
    if (_isGratitude(trimmed, language)) return CharacterTurnIntent.gratitude;
    if (hasQuestionMark) return CharacterTurnIntent.question;
    if (_isShortReply(trimmed, language)) return CharacterTurnIntent.shortReply;

    return CharacterTurnIntent.sharing;
  }

  static CharacterSpeechLevel _resolveSpeechLevel({
    required CharacterToneProfile profile,
    required CharacterVoiceProfile voiceProfile,
    AffinityPhase? affinityPhase,
  }) {
    final stage = relationshipStageFromAffinityPhase(
      affinityPhase ?? AffinityPhase.stranger,
    );
    final isEarlyStage = stage == CharacterRelationshipStage.gettingToKnow;
    final isKoreanLike = profile.language == CharacterLanguage.ko ||
        profile.language == CharacterLanguage.unknown;

    if (isEarlyStage && isKoreanLike && !profile.explicitCasual) {
      return CharacterSpeechLevel.formal;
    }

    if (profile.speechLevel == CharacterSpeechLevel.neutral) {
      switch (voiceProfile.defaultSpeech) {
        case 'casual':
          return CharacterSpeechLevel.casual;
        case 'formal':
          return CharacterSpeechLevel.formal;
      }
    }

    return profile.speechLevel;
  }

  static String buildStyleGuidePrompt(
    CharacterToneProfile profile, {
    required CharacterVoiceProfile voiceProfile,
    AffinityPhase? affinityPhase,
  }) {
    final relationshipStage = relationshipStageFromAffinityPhase(
      affinityPhase ?? AffinityPhase.stranger,
    );
    final relationshipLabel = relationshipStageLabel(relationshipStage);
    final relationshipGuide = relationshipStageGuide(relationshipStage);
    final relationshipBoundary = relationshipStageBoundary(relationshipStage);
    final resolvedSpeech = _resolveSpeechLevel(
      profile: profile,
      voiceProfile: voiceProfile,
      affinityPhase: affinityPhase,
    );

    final languageGuide = switch (profile.language) {
      CharacterLanguage.ko => '한국어로 답하고, 사용자 말투의 존댓말/반말을 미러링하세요.',
      CharacterLanguage.en =>
        'Respond in English and mirror the user tone (polite or casual).',
      CharacterLanguage.ja => '日本語で返答し、ユーザーの丁寧さを 미러링하세요.',
      CharacterLanguage.unknown => '사용자 최근 메시지 언어와 톤을 우선 추정해 맞춰주세요.',
    };

    final speechGuide = switch (resolvedSpeech) {
      CharacterSpeechLevel.formal => '현재 톤: formal. 정중하고 차분한 어조를 유지하세요.',
      CharacterSpeechLevel.casual => '현재 톤: casual. 과장 없이 자연스러운 구어체를 사용하세요.',
      CharacterSpeechLevel.neutral => '현재 톤: neutral. 과한 격식/과한 친밀 표현을 모두 피하세요.',
    };

    final earlyFormalityGuide =
        relationshipStage == CharacterRelationshipStage.gettingToKnow &&
                !profile.explicitCasual
            ? '초기 단계 규칙: 사용자가 명시적으로 반말을 쓰기 전에는 존댓말을 유지하세요.'
            : '초기 단계 규칙: 관계 단계에 맞춰 과한 친밀 표현을 피하세요.';

    final nicknameGuide = profile.nicknameAllowed
        ? '애칭 사용 가능: 사용자가 먼저 애칭을 사용했으므로, 필요할 때만 제한적으로 사용하세요.'
        : '애칭 사용 금지: "여보", "자기", "honey", "darling" 같은 호칭을 쓰지 마세요.';

    final nameGuide = profile.nameKnown
        ? '이름 상태: 사용자 이름이 확인되었습니다. 과도한 반복 없이 자연스럽게 호칭하세요.'
        : profile.nameAsked
            ? '이름 상태: 이미 이름을 물어봤으니 재촉하지 말고, 중립 호칭으로 대화를 이어가세요.'
            : '이름 상태: 초반 1회만 "편하게 어떻게 불러드리면 될까요?"처럼 가볍게 물어볼 수 있고, 미응답이어도 바로 다음 주제로 진행하세요.';

    final intentGuide = switch (profile.turnIntent) {
      CharacterTurnIntent.greeting =>
        '턴 전략: 인사에는 짧은 리액션 중심으로 답하고, 같은 인사 반복은 금지하세요.',
      CharacterTurnIntent.gratitude => '턴 전략: 감사 표현에는 짧게 받아주고 대화를 이어가세요.',
      CharacterTurnIntent.shortReply =>
        '턴 전략: 짧은 답장에는 짧은 공감 후 맥락을 한 걸음만 확장하세요.',
      CharacterTurnIntent.question =>
        '턴 전략: 질문이면 첫 문장에서 바로 답하고 필요 시 한 문장만 덧붙이세요.',
      CharacterTurnIntent.sharing =>
        '턴 전략: 공감 또는 관찰을 한 문장으로 주고, 필요할 때만 질문 1개를 사용하세요.',
      CharacterTurnIntent.unknown => '턴 전략: 중립적으로 한 문장 반응 후 자연스럽게 이어가세요.',
    };

    final lexiconHints = voiceProfile.lexiconHints.isEmpty
        ? ''
        : '- 보이스 힌트: ${voiceProfile.lexiconHints.join(', ')}';

    final stageOverride =
        voiceProfile.stageGuideOverrides[relationshipStage.name]?.trim();
    final stageOverrideGuide = stageOverride == null || stageOverride.isEmpty
        ? ''
        : '- 단계 오버라이드: $stageOverride';

    return '''
[CHARACTER STYLE GUARD]
- 카톡형 1버블: 답변은 1~2문장만 사용하세요.
- 반복 금지: 같은 의미 문장을 반복하지 마세요.
- 질문 제한: 질문은 필요할 때만 최대 1개 사용하세요.
- 상담사 톤 금지: "무엇을 도와드릴 수", "무엇을 도와드릴까요", "도움이 필요하시면", "문의" 같은 문구를 금지하세요.
- 메타 발화 금지: "저는 인공지능이라", "as an AI"처럼 캐릭터 몰입을 깨는 자기정체성 설명을 금지하세요.
- 관계 단계: $relationshipLabel
- 단계 운영: $relationshipGuide
- 단계 경계: $relationshipBoundary
- $languageGuide
- $speechGuide
- $earlyFormalityGuide
- $nicknameGuide
- $nameGuide
- $intentGuide
$lexiconHints
$stageOverrideGuide
''';
  }

  static String buildFirstMeetOpening(
    String characterName,
    CharacterToneProfile profile, {
    required CharacterVoiceProfile voiceProfile,
    AffinityPhase? affinityPhase,
  }) {
    final resolvedSpeech = _resolveSpeechLevel(
      profile: profile,
      voiceProfile: voiceProfile,
      affinityPhase: affinityPhase,
    );

    switch (profile.language) {
      case CharacterLanguage.en:
        if (resolvedSpeech == CharacterSpeechLevel.casual) {
          return 'Hey, I\'m $characterName. Nice to meet you.';
        }
        return 'Hello, I\'m $characterName. Nice to meet you.';
      case CharacterLanguage.ja:
        if (resolvedSpeech == CharacterSpeechLevel.casual) {
          return 'やあ、$characterNameだよ。会えてうれしい。';
        }
        return 'こんにちは、$characterNameです。お会いできてうれしいです。';
      case CharacterLanguage.ko:
      case CharacterLanguage.unknown:
        if (resolvedSpeech == CharacterSpeechLevel.casual) {
          return '안녕, $characterName야. 만나서 반가워.';
        }
        return '안녕하세요, $characterName예요. 만나서 반가워요.';
    }
  }

  static String buildReadIdleIcebreakerQuestion(
    CharacterToneProfile profile, {
    required CharacterVoiceProfile voiceProfile,
    AffinityPhase? affinityPhase,
    DateTime? now,
    String? recentAssistantText,
  }) {
    final resolvedSpeech = _resolveSpeechLevel(
      profile: profile,
      voiceProfile: voiceProfile,
      affinityPhase: affinityPhase,
    );
    final hour = (now ?? DateTime.now()).hour;
    final isLunchTime = hour >= 11 && hour < 14;
    final isDinnerTime = hour >= 17 && hour < 21;

    final avoidCurrentActivityQuestion =
        (recentAssistantText ?? '').contains('지금') ||
            (recentAssistantText ?? '').contains('방금') ||
            (recentAssistantText ?? '').contains('뭐 하고');

    switch (profile.language) {
      case CharacterLanguage.en:
        if (isLunchTime) return 'Have you had lunch yet?';
        if (isDinnerTime) return 'Have you had dinner yet?';
        return avoidCurrentActivityQuestion
            ? 'How are you feeling right now?'
            : (resolvedSpeech == CharacterSpeechLevel.casual
                ? 'What are you up to right now?'
                : 'What are you doing right now?');
      case CharacterLanguage.ja:
        if (isLunchTime) {
          return resolvedSpeech == CharacterSpeechLevel.casual
              ? 'お昼ごはん、もう食べた？'
              : 'お昼ごはんはもう食べましたか？';
        }
        if (isDinnerTime) {
          return resolvedSpeech == CharacterSpeechLevel.casual
              ? '夕ごはん、もう食べた？'
              : '夕ごはんはもう食べましたか？';
        }
        if (avoidCurrentActivityQuestion) {
          return resolvedSpeech == CharacterSpeechLevel.casual
              ? '今の気分はどう？'
              : '今の気分はどうですか？';
        }
        return resolvedSpeech == CharacterSpeechLevel.casual
            ? '今なにしてる？'
            : '今は何をしていますか？';
      case CharacterLanguage.ko:
      case CharacterLanguage.unknown:
        if (isLunchTime) {
          return resolvedSpeech == CharacterSpeechLevel.casual
              ? '점심 먹었어?'
              : '점심 드셨어요?';
        }
        if (isDinnerTime) {
          return resolvedSpeech == CharacterSpeechLevel.casual
              ? '저녁 먹었어?'
              : '저녁 드셨어요?';
        }
        if (avoidCurrentActivityQuestion) {
          return resolvedSpeech == CharacterSpeechLevel.casual
              ? '지금 기분은 어때?'
              : '지금 기분은 어떠세요?';
        }
        return resolvedSpeech == CharacterSpeechLevel.casual
            ? '지금 뭐 하고 있어?'
            : '지금 뭐 하고 계세요?';
    }
  }

  static String applyTemplateTone(
    String message,
    CharacterToneProfile profile, {
    required CharacterVoiceProfile voiceProfile,
    AffinityPhase? affinityPhase,
  }) {
    var result = message.trim();
    if (result.isEmpty) return result;

    if (!profile.nicknameAllowed && voiceProfile.strictNicknameGate) {
      result = _removeNicknames(result);
    }
    result = _sanitizeServiceTone(result);
    result = _applyTurnIntentShaping(
      result,
      profile,
      voiceProfile: voiceProfile,
      affinityPhase: affinityPhase,
    );

    result = enforceKakaoSingleBubble(result);
    return result.isEmpty
        ? _defaultReplyForIntent(
            profile,
            voiceProfile: voiceProfile,
            affinityPhase: affinityPhase,
          )
        : result;
  }

  static String applyGeneratedTone(
    String message,
    CharacterToneProfile profile, {
    required CharacterVoiceProfile voiceProfile,
    bool encourageContinuity = false,
    AffinityPhase? affinityPhase,
  }) {
    var result = message.trim();
    if (result.isEmpty) return result;

    if (!profile.nicknameAllowed && voiceProfile.strictNicknameGate) {
      result = _removeNicknames(result);
    }
    result = _sanitizeServiceTone(result);
    result = _applyTurnIntentShaping(
      result,
      profile,
      voiceProfile: voiceProfile,
      affinityPhase: affinityPhase,
    );

    result = enforceKakaoSingleBubble(result);
    if (encourageContinuity) {
      result = _ensureConversationalBridge(
        result,
        profile,
        voiceProfile: voiceProfile,
        affinityPhase: affinityPhase,
      );
      result = enforceKakaoSingleBubble(result);
    }

    return result.isEmpty
        ? _defaultReplyForIntent(
            profile,
            voiceProfile: voiceProfile,
            affinityPhase: affinityPhase,
          )
        : result;
  }

  static String enforceKakaoSingleBubble(String text) {
    final normalized =
        text.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

    if (normalized.isEmpty) return normalized;

    final sentencePattern = RegExp(r'[^.!?。！？]+[.!?。！？]?');
    final rawSentences = sentencePattern
        .allMatches(normalized)
        .map((m) => m.group(0)!.trim())
        .where((sentence) => sentence.isNotEmpty)
        .toList();

    if (rawSentences.isEmpty) return normalized;

    final seen = <String>{};
    final deduped = <String>[];
    for (final sentence in rawSentences) {
      final key = sentence
          .toLowerCase()
          .replaceAll(RegExp(r'[^0-9a-z가-힣ぁ-んァ-ヶ一-龯]+'), '');
      if (key.isEmpty || seen.contains(key)) {
        continue;
      }
      seen.add(key);
      deduped.add(sentence);
    }

    final limited = deduped.take(2).toList();
    var questionCount = 0;

    for (var i = 0; i < limited.length; i++) {
      final hasQuestion = limited[i].contains('?') || limited[i].contains('？');
      if (!hasQuestion) continue;

      questionCount += 1;
      if (questionCount > 1) {
        limited[i] = limited[i].replaceAll('?', '.').replaceAll('？', '。');
      }
    }

    return limited.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static bool _containsNickname(String text) => _nicknamePattern.hasMatch(text);

  static String _removeNicknames(String text) {
    final language = detectLanguage(text);
    final replacement = switch (language) {
      CharacterLanguage.en => 'you',
      CharacterLanguage.ja => 'あなた',
      CharacterLanguage.ko => '당신',
      CharacterLanguage.unknown => '당신',
    };

    return text
        .replaceAll(_nicknamePattern, replacement)
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String _sanitizeServiceTone(String text) {
    var result = text;
    for (final replacement in _serviceToneReplacements) {
      result = result.replaceAll(replacement.key, replacement.value);
    }

    return result
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'^[,.\s]+'), '')
        .trim();
  }

  static String _applyTurnIntentShaping(
    String text,
    CharacterToneProfile profile, {
    required CharacterVoiceProfile voiceProfile,
    AffinityPhase? affinityPhase,
  }) {
    var result = text.trim();
    if (result.isEmpty) return result;

    if (_serviceTonePattern.hasMatch(result)) {
      return _defaultReplyForIntent(
        profile,
        voiceProfile: voiceProfile,
        affinityPhase: affinityPhase,
      );
    }

    if (profile.turnIntent == CharacterTurnIntent.greeting) {
      result = _normalizeGreetingEcho(
        result,
        profile,
        voiceProfile: voiceProfile,
        affinityPhase: affinityPhase,
      );
    }

    return result;
  }

  static String _ensureConversationalBridge(
    String text,
    CharacterToneProfile profile, {
    required CharacterVoiceProfile voiceProfile,
    AffinityPhase? affinityPhase,
  }) {
    final relationshipStage = relationshipStageFromAffinityPhase(
      affinityPhase ?? AffinityPhase.stranger,
    );
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) {
      return _defaultReplyForIntent(
        profile,
        voiceProfile: voiceProfile,
        affinityPhase: affinityPhase,
      );
    }

    final hasQuestion = normalized.contains('?') || normalized.contains('？');
    if (hasQuestion || profile.turnIntent == CharacterTurnIntent.question) {
      return normalized;
    }

    final shouldBridge = profile.turnIntent == CharacterTurnIntent.greeting ||
        profile.turnIntent == CharacterTurnIntent.shortReply ||
        profile.turnIntent == CharacterTurnIntent.sharing;
    if (!shouldBridge) return normalized;

    if (relationshipStage == CharacterRelationshipStage.gettingToKnow &&
        !profile.nameKnown &&
        !profile.nameAsked &&
        (profile.turnIntent == CharacterTurnIntent.greeting ||
            profile.turnIntent == CharacterTurnIntent.shortReply)) {
      return _buildNamePromptSentence(
        profile,
        voiceProfile: voiceProfile,
        affinityPhase: affinityPhase,
      );
    }

    final bridge = _bridgeSentence(
      profile,
      voiceProfile: voiceProfile,
      affinityPhase: affinityPhase,
    );
    if (bridge.isEmpty) return normalized;

    final needsPunctuation = !RegExp(r'[.!?。！？]$').hasMatch(normalized);
    final base = needsPunctuation ? '$normalized.' : normalized;
    return '$base $bridge'.trim();
  }

  static String _bridgeSentence(
    CharacterToneProfile profile, {
    required CharacterVoiceProfile voiceProfile,
    AffinityPhase? affinityPhase,
  }) {
    final resolvedSpeech = _resolveSpeechLevel(
      profile: profile,
      voiceProfile: voiceProfile,
      affinityPhase: affinityPhase,
    );

    switch (profile.language) {
      case CharacterLanguage.en:
        return resolvedSpeech == CharacterSpeechLevel.casual
            ? 'What are you curious about these days?'
            : 'What are you most curious about these days?';
      case CharacterLanguage.ja:
        return resolvedSpeech == CharacterSpeechLevel.casual
            ? '最近いちばん気になってることって何？'
            : '最近いちばん気になっていることは何ですか？';
      case CharacterLanguage.ko:
      case CharacterLanguage.unknown:
        if (resolvedSpeech == CharacterSpeechLevel.casual) {
          return voiceProfile.bridgeTemplateCasualKo ?? '요즘 제일 궁금한 게 뭐야?';
        }
        return voiceProfile.bridgeTemplateFormalKo ?? '요즘 가장 궁금한 건 뭐예요?';
    }
  }

  static String _buildNamePromptSentence(
    CharacterToneProfile profile, {
    required CharacterVoiceProfile voiceProfile,
    AffinityPhase? affinityPhase,
  }) {
    final resolvedSpeech = _resolveSpeechLevel(
      profile: profile,
      voiceProfile: voiceProfile,
      affinityPhase: affinityPhase,
    );

    switch (profile.language) {
      case CharacterLanguage.en:
        return resolvedSpeech == CharacterSpeechLevel.casual
            ? 'What should I call you? You can tell me later too.'
            : 'What should I call you? It is okay to share your name later.';
      case CharacterLanguage.ja:
        return resolvedSpeech == CharacterSpeechLevel.casual
            ? 'なんて呼べばいい？名前はあとででも大丈夫だよ。'
            : 'なんてお呼びすればいいですか？お名前は後ででも大丈夫です。';
      case CharacterLanguage.ko:
      case CharacterLanguage.unknown:
        return resolvedSpeech == CharacterSpeechLevel.casual
            ? '편하게 뭐라고 부르면 돼? 이름은 편할 때 말해줘도 돼.'
            : '편하게 어떻게 불러드리면 될까요? 이름은 편할 때 알려주셔도 괜찮아요.';
    }
  }

  static String _normalizeGreetingEcho(
    String text,
    CharacterToneProfile profile, {
    required CharacterVoiceProfile voiceProfile,
    AffinityPhase? affinityPhase,
  }) {
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) {
      return _defaultReplyForIntent(
        profile,
        voiceProfile: voiceProfile,
        affinityPhase: affinityPhase,
      );
    }

    final greetingEchoPattern = RegExp(
      r'^(네[, ]*)?(저도[, ]*)?(반갑(?:습니다|네요|다|아요)|만나서 반갑)',
      caseSensitive: false,
    );

    if (greetingEchoPattern.hasMatch(normalized)) {
      return _defaultReplyForIntent(
        profile,
        voiceProfile: voiceProfile,
        affinityPhase: affinityPhase,
      );
    }

    return normalized;
  }

  static String _defaultReplyForIntent(
    CharacterToneProfile profile, {
    required CharacterVoiceProfile voiceProfile,
    AffinityPhase? affinityPhase,
  }) {
    final resolvedSpeech = _resolveSpeechLevel(
      profile: profile,
      voiceProfile: voiceProfile,
      affinityPhase: affinityPhase,
    );

    switch (profile.language) {
      case CharacterLanguage.en:
        switch (profile.turnIntent) {
          case CharacterTurnIntent.greeting:
            return 'Nice to meet you too. We can talk casually.';
          case CharacterTurnIntent.gratitude:
            return 'You are welcome. We can keep going.';
          case CharacterTurnIntent.shortReply:
            return 'Sounds good. Let us keep talking.';
          case CharacterTurnIntent.question:
          case CharacterTurnIntent.sharing:
          case CharacterTurnIntent.unknown:
            return 'I hear you. Let us keep this simple.';
        }
      case CharacterLanguage.ja:
        switch (profile.turnIntent) {
          case CharacterTurnIntent.greeting:
            return 'こちらこそ、会えてうれしいです。気軽に話してください。';
          case CharacterTurnIntent.gratitude:
            return 'どういたしまして。続けて話しましょう。';
          case CharacterTurnIntent.shortReply:
            return 'いいですね。ゆっくり話しましょう。';
          case CharacterTurnIntent.question:
          case CharacterTurnIntent.sharing:
          case CharacterTurnIntent.unknown:
            return 'うん、受け取ったよ。続けて話そう。';
        }
      case CharacterLanguage.ko:
      case CharacterLanguage.unknown:
        final isCasual = resolvedSpeech == CharacterSpeechLevel.casual;
        switch (profile.turnIntent) {
          case CharacterTurnIntent.greeting:
            return isCasual ? '나도 반가워. 편하게 얘기하자.' : '저도 반가워요. 편하게 이야기해요.';
          case CharacterTurnIntent.gratitude:
            return isCasual ? '별말 아니야. 이어서 얘기하자.' : '별말씀을요. 이어서 이야기해요.';
          case CharacterTurnIntent.shortReply:
            return isCasual ? '좋아. 이어서 얘기해.' : '좋아요. 이어서 이야기해요.';
          case CharacterTurnIntent.question:
          case CharacterTurnIntent.sharing:
          case CharacterTurnIntent.unknown:
            return isCasual ? '응, 들었어. 계속 말해줘.' : '네, 잘 들었어요. 이어서 말씀해 주세요.';
        }
    }
  }

  static bool _isGreeting(String text, CharacterLanguage language) {
    switch (language) {
      case CharacterLanguage.ko:
        return _koGreetingPattern.hasMatch(text);
      case CharacterLanguage.en:
        return _enGreetingPattern.hasMatch(text);
      case CharacterLanguage.ja:
        return _jaGreetingPattern.hasMatch(text);
      case CharacterLanguage.unknown:
        return _koGreetingPattern.hasMatch(text) ||
            _enGreetingPattern.hasMatch(text) ||
            _jaGreetingPattern.hasMatch(text);
    }
  }

  static bool _isGratitude(String text, CharacterLanguage language) {
    switch (language) {
      case CharacterLanguage.ko:
        return _koThanksPattern.hasMatch(text);
      case CharacterLanguage.en:
        return _enThanksPattern.hasMatch(text);
      case CharacterLanguage.ja:
        return _jaThanksPattern.hasMatch(text);
      case CharacterLanguage.unknown:
        return _koThanksPattern.hasMatch(text) ||
            _enThanksPattern.hasMatch(text) ||
            _jaThanksPattern.hasMatch(text);
    }
  }

  static bool _isShortReply(String text, CharacterLanguage language) {
    switch (language) {
      case CharacterLanguage.ko:
        return _koShortReplyPattern.hasMatch(text);
      case CharacterLanguage.en:
        return _enShortReplyPattern.hasMatch(text);
      case CharacterLanguage.ja:
        return _jaShortReplyPattern.hasMatch(text);
      case CharacterLanguage.unknown:
        return text.length <= 12;
    }
  }

  static bool _hasExplicitCasualTone({
    required CharacterLanguage language,
    required String text,
  }) {
    if (text.trim().isEmpty) return false;

    switch (language) {
      case CharacterLanguage.ko:
        return RegExp(
          r'(뭐해\?|뭐 해\?|했어\?|할래\?|해줘|말해줘|반가워[.!?]?$|안녕[.!?]?$|야\?|니\?|하자[.!?]?$)',
          caseSensitive: false,
        ).hasMatch(text);
      case CharacterLanguage.ja:
        return RegExp(r'(だよ|だね|じゃん|しよう|してね)', caseSensitive: false)
            .hasMatch(text);
      case CharacterLanguage.en:
        return RegExp(
          r'(wanna|gonna|gotta|bro|dude|yo\b|sup\b)',
          caseSensitive: false,
        ).hasMatch(text);
      case CharacterLanguage.unknown:
        return false;
    }
  }

  static bool _looksLikeNameDisclosure(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    final ko = RegExp(
      r'(제\s*이름은|저는|전|나는|난)\s*[가-힣A-Za-z0-9]{2,12}\s*(입니다|이에요|예요|라고\s*해요|라고\s*합니다|이야)',
      caseSensitive: false,
    );
    final en = RegExp(
      r"(my name is|i'm\s+[A-Za-z]{2,20}|i am\s+[A-Za-z]{2,20})",
      caseSensitive: false,
    );
    final ja = RegExp(
      r'(名前は|わたしは|僕は|俺は).{1,20}(です|だよ)',
      caseSensitive: false,
    );

    return ko.hasMatch(trimmed) || en.hasMatch(trimmed) || ja.hasMatch(trimmed);
  }

  static bool _asksForUserName(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    final askPattern = RegExp(
      r'(어떻게\s*불러드리면|뭐라고\s*불러드리면|이름\s*(알려|말해)|what should i call you|your name|お名前|何て呼べば)',
      caseSensitive: false,
    );
    return askPattern.hasMatch(trimmed);
  }
}
