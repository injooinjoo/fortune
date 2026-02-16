import '../../domain/models/character_chat_message.dart';
import '../../domain/models/character_affinity.dart';

/// 언어 추정 결과
///
/// `unknown`은 입력이 너무 짧거나 문자가 섞여 단정하기 어려운 경우입니다.
enum LutsLanguage { ko, en, ja, unknown }

/// 말투 격식 추정 결과
enum LutsSpeechLevel { formal, casual, neutral }

/// 최근 사용자 발화의 의도 분류
enum LutsTurnIntent {
  greeting,
  gratitude,
  shortReply,
  question,
  sharing,
  unknown
}

/// 러츠 관계형 대화 4단계
enum LutsRelationshipStage {
  gettingToKnow,
  gettingCloser,
  emotionalBond,
  romantic
}

/// 러츠 톤 정책에 필요한 사용자 말투 컨텍스트
class LutsToneProfile {
  final LutsLanguage language;
  final LutsSpeechLevel speechLevel;
  final bool nicknameAllowed;
  final LutsTurnIntent turnIntent;
  final bool nameKnown;
  final bool nameAsked;
  final bool explicitCasual;

  const LutsToneProfile({
    required this.language,
    required this.speechLevel,
    required this.nicknameAllowed,
    required this.turnIntent,
    this.nameKnown = false,
    this.nameAsked = false,
    this.explicitCasual = false,
  });

  static const neutral = LutsToneProfile(
    language: LutsLanguage.unknown,
    speechLevel: LutsSpeechLevel.neutral,
    nicknameAllowed: false,
    turnIntent: LutsTurnIntent.unknown,
  );
}

class LutsTonePolicy {
  static const String characterId = 'luts';

  static final RegExp _nicknamePattern = RegExp(
    r'(여보|자기(?:야)?|허니|달링|애인|honey|darling|babe|baby|sweetheart|dear|my love|ハニー|ダーリン|ベイビー)',
    caseSensitive: false,
  );

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

  static final RegExp _serviceTonePattern = RegExp(
    r'(무엇을\s*도와드릴\s*수|(?:무엇을|뭘|어떻게)\s*도와드릴까요\??|도움이\s*필요하시면|문의|지원|how can i help|let me help|assist you|お手伝い|サポート)',
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
      RegExp(
        r'(?:무엇을|뭘|어떻게)\s*도와드릴까요\??',
        caseSensitive: false,
      ),
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
  ];

  static final RegExp _koCharPattern = RegExp(r'[가-힣]');
  static final RegExp _jaCharPattern = RegExp(r'[\u3040-\u30FF\u4E00-\u9FFF]');
  static final RegExp _enCharPattern = RegExp(r'[A-Za-z]');

  static bool isLuts(String inputCharacterId) =>
      inputCharacterId == characterId;

  static LutsRelationshipStage relationshipStageFromAffinityPhase(
    AffinityPhase phase,
  ) {
    switch (phase) {
      case AffinityPhase.stranger:
        return LutsRelationshipStage.gettingToKnow;
      case AffinityPhase.acquaintance:
      case AffinityPhase.friend:
        return LutsRelationshipStage.gettingCloser;
      case AffinityPhase.closeFriend:
        return LutsRelationshipStage.emotionalBond;
      case AffinityPhase.romantic:
      case AffinityPhase.soulmate:
        return LutsRelationshipStage.romantic;
    }
  }

  static String relationshipStageLabel(LutsRelationshipStage stage) {
    switch (stage) {
      case LutsRelationshipStage.gettingToKnow:
        return '1단계: 처음 알고 지내는 단계';
      case LutsRelationshipStage.gettingCloser:
        return '2단계: 조금 친해지고 알아가는 단계';
      case LutsRelationshipStage.emotionalBond:
        return '3단계: 속마음을 털고 위로해주는 단계';
      case LutsRelationshipStage.romantic:
        return '4단계: 연인 단계';
    }
  }

  static String relationshipStageGuide(LutsRelationshipStage stage) {
    switch (stage) {
      case LutsRelationshipStage.gettingToKnow:
        return '가벼운 인사/취향/일상 주제로 시작하고, 부담 없는 한 걸음 대화를 유지하세요.';
      case LutsRelationshipStage.gettingCloser:
        return '관심사와 근황을 조금 더 깊게 묻고, 가벼운 공감과 리액션으로 친밀감을 올리세요.';
      case LutsRelationshipStage.emotionalBond:
        return '속마음 공유와 정서적 위로를 우선하고, 판단보다 경청과 공감을 중심에 두세요.';
      case LutsRelationshipStage.romantic:
        return '다정하고 따뜻한 애정 표현이 가능하며, 연인 톤은 자연스럽고 과하지 않게 유지하세요.';
    }
  }

  static String relationshipStageBoundary(LutsRelationshipStage stage) {
    switch (stage) {
      case LutsRelationshipStage.gettingToKnow:
        return '사전 연인관계/독점/집착 뉘앙스는 금지하고 소개팅 초반 톤을 유지하세요.';
      case LutsRelationshipStage.gettingCloser:
        return '친근함은 허용하되 관계 확정 발언이나 과한 소유욕 표현은 금지하세요.';
      case LutsRelationshipStage.emotionalBond:
        return '위로는 하되 감정 조종, 관계 강요, 부담 주는 표현은 금지하세요.';
      case LutsRelationshipStage.romantic:
        return '애정 표현은 사용자 반응을 우선하고, 불편 신호가 보이면 즉시 수위를 낮추세요.';
    }
  }

  static LutsToneProfile fromConversation({
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

    if (userTexts.isEmpty) return LutsToneProfile.neutral;

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

    return LutsToneProfile(
      language: language,
      speechLevel: speechLevel,
      nicknameAllowed: nicknameAllowed,
      turnIntent: turnIntent,
      nameKnown: nameKnown,
      nameAsked: nameAsked,
      explicitCasual: explicitCasual,
    );
  }

  static LutsLanguage detectLanguage(String text) {
    if (text.trim().isEmpty) return LutsLanguage.unknown;

    final koCount = _koCharPattern.allMatches(text).length;
    final jaCount = _jaCharPattern.allMatches(text).length;
    final enCount = _enCharPattern.allMatches(text).length;

    if (koCount >= jaCount && koCount >= enCount && koCount > 0) {
      return LutsLanguage.ko;
    }
    if (jaCount >= koCount && jaCount >= enCount && jaCount > 0) {
      return LutsLanguage.ja;
    }
    if (enCount > 0) {
      return LutsLanguage.en;
    }
    return LutsLanguage.unknown;
  }

  static LutsSpeechLevel detectSpeechLevel({
    required LutsLanguage language,
    required String text,
  }) {
    if (text.trim().isEmpty) return LutsSpeechLevel.neutral;

    int formalScore = 0;
    int casualScore = 0;

    switch (language) {
      case LutsLanguage.ko:
        formalScore = _koFormalPattern.allMatches(text).length;
        casualScore = _koCasualPattern.allMatches(text).length;
        formalScore += _koPoliteEndingPattern.allMatches(text).length;
        casualScore += _koExplicitCasualEndingPattern.allMatches(text).length;
        break;
      case LutsLanguage.ja:
        formalScore = _jaFormalPattern.allMatches(text).length;
        casualScore = _jaCasualPattern.allMatches(text).length;
        break;
      case LutsLanguage.en:
        formalScore = _enFormalPattern.allMatches(text).length;
        casualScore = _enCasualPattern.allMatches(text).length;
        break;
      case LutsLanguage.unknown:
        return LutsSpeechLevel.neutral;
    }

    if (formalScore > casualScore) return LutsSpeechLevel.formal;
    if (casualScore > formalScore) return LutsSpeechLevel.casual;
    return LutsSpeechLevel.neutral;
  }

  static LutsTurnIntent detectTurnIntent({
    required String text,
    required LutsLanguage language,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return LutsTurnIntent.unknown;

    final hasQuestionMark = trimmed.contains('?') || trimmed.contains('？');
    if (_isGreeting(trimmed, language)) return LutsTurnIntent.greeting;
    if (_isGratitude(trimmed, language)) return LutsTurnIntent.gratitude;
    if (hasQuestionMark) return LutsTurnIntent.question;
    if (_isShortReply(trimmed, language)) return LutsTurnIntent.shortReply;

    return LutsTurnIntent.sharing;
  }

  static LutsSpeechLevel _resolveSpeechLevel({
    required LutsToneProfile profile,
    AffinityPhase? affinityPhase,
  }) {
    final stage = relationshipStageFromAffinityPhase(
        affinityPhase ?? AffinityPhase.stranger);
    final isEarlyStage = stage == LutsRelationshipStage.gettingToKnow;
    final isKoreanLike = profile.language == LutsLanguage.ko ||
        profile.language == LutsLanguage.unknown;

    if (isEarlyStage && isKoreanLike && !profile.explicitCasual) {
      return LutsSpeechLevel.formal;
    }
    return profile.speechLevel;
  }

  static bool _hasExplicitCasualTone({
    required LutsLanguage language,
    required String text,
  }) {
    if (text.trim().isEmpty) return false;

    switch (language) {
      case LutsLanguage.ko:
        return RegExp(
          r'(뭐해\?|뭐 해\?|했어\?|할래\?|해줘|말해줘|반가워[.!?]?$|안녕[.!?]?$|야\?|니\?|하자[.!?]?$)',
          caseSensitive: false,
        ).hasMatch(text);
      case LutsLanguage.ja:
        return RegExp(r'(だよ|だね|じゃん|しよう|してね)', caseSensitive: false)
            .hasMatch(text);
      case LutsLanguage.en:
        return RegExp(
          r'(wanna|gonna|gotta|bro|dude|yo\b|sup\b)',
          caseSensitive: false,
        ).hasMatch(text);
      case LutsLanguage.unknown:
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

  static String buildStyleGuidePrompt(
    LutsToneProfile profile, {
    AffinityPhase? affinityPhase,
  }) {
    final relationshipStage = relationshipStageFromAffinityPhase(
        affinityPhase ?? AffinityPhase.stranger);
    final relationshipLabel = relationshipStageLabel(relationshipStage);
    final relationshipGuide = relationshipStageGuide(relationshipStage);
    final relationshipBoundary = relationshipStageBoundary(relationshipStage);
    final resolvedSpeech =
        _resolveSpeechLevel(profile: profile, affinityPhase: affinityPhase);

    final languageGuide = switch (profile.language) {
      LutsLanguage.ko => '한국어로 답하고, 사용자 말투의 존댓말/반말을 그대로 미러링하세요.',
      LutsLanguage.en =>
        'Respond in English and mirror the user tone (polite or casual).',
      LutsLanguage.ja => '日本語で返答し、ユーザーの丁寧さ（丁寧語/カジュアル）を合わせてください。',
      LutsLanguage.unknown => '사용자 최근 메시지 언어와 톤을 우선 추정해 맞춰주세요.',
    };

    final speechGuide = switch (resolvedSpeech) {
      LutsSpeechLevel.formal => '현재 톤: formal. 정중하고 차분한 어조를 유지하세요.',
      LutsSpeechLevel.casual => '현재 톤: casual. 과장 없이 자연스러운 구어체를 사용하세요.',
      LutsSpeechLevel.neutral => '현재 톤: neutral. 과한 격식/과한 친밀 표현을 모두 피하세요.',
    };

    final earlyFormalityGuide =
        relationshipStage == LutsRelationshipStage.gettingToKnow &&
                !profile.explicitCasual
            ? '초기 단계 규칙: 사용자가 명시적으로 반말을 쓰기 전에는 존댓말을 유지하세요.'
            : null;

    final nicknameGuide = profile.nicknameAllowed
        ? '애칭 사용 가능: 사용자가 먼저 애칭을 사용했으므로, 필요할 때만 제한적으로 사용하세요.'
        : '애칭 사용 금지: "여보", "자기", "honey", "darling" 같은 호칭을 쓰지 마세요.';

    final nameGuide = profile.nameKnown
        ? '이름 상태: 사용자 이름이 확인되었습니다. 과도한 반복 없이 자연스럽게 호칭하세요.'
        : profile.nameAsked
            ? '이름 상태: 이미 이름을 물어봤으니 재촉하지 말고, 중립 호칭으로 대화를 이어가세요.'
            : '이름 상태: 초반 1회만 "편하게 어떻게 불러드리면 될까요?"처럼 가볍게 물어볼 수 있고, 미응답이어도 바로 다음 주제로 진행하세요.';

    final intentGuide = switch (profile.turnIntent) {
      LutsTurnIntent.greeting => '턴 전략: 인사에는 짧은 리액션 중심으로 답하고, 같은 인사 반복은 금지하세요.',
      LutsTurnIntent.gratitude => '턴 전략: 감사 표현에는 짧게 받아주고 대화를 이어가세요.',
      LutsTurnIntent.shortReply => '턴 전략: 짧은 답장에는 짧은 공감 후 맥락을 한 걸음만 확장하세요.',
      LutsTurnIntent.question => '턴 전략: 질문이면 첫 문장에서 바로 답하고 필요 시 한 문장만 덧붙이세요.',
      LutsTurnIntent.sharing =>
        '턴 전략: 공감 또는 관찰을 한 문장으로 주고, 필요할 때만 질문 1개를 사용하세요.',
      LutsTurnIntent.unknown => '턴 전략: 중립적으로 한 문장 반응 후 자연스럽게 이어가세요.',
    };

    return '''
[LUTS STYLE GUARD]
- 카톡형 1버블: 답변은 1~2문장만 사용하세요.
- 반복 금지: 같은 의미 문장을 반복하지 마세요.
- 질문 제한: 질문은 필요할 때만 최대 1개 사용하세요.
- 상담사 톤 금지: "무엇을 도와드릴 수", "무엇을 도와드릴까요", "도움이 필요하시면", "문의" 같은 문구를 금지하세요.
- 관계 단계: $relationshipLabel
- 단계 운영: $relationshipGuide
- 단계 경계: $relationshipBoundary
- $languageGuide
- $speechGuide
- ${earlyFormalityGuide ?? '초기 단계 규칙: 관계 단계에 맞춰 과한 친밀 표현을 피하세요.'}
- $nicknameGuide
- $nameGuide
- $intentGuide
''';
  }

  static String buildFirstMeetOpening(LutsToneProfile profile) {
    switch (profile.language) {
      case LutsLanguage.en:
        if (profile.speechLevel == LutsSpeechLevel.casual) {
          return 'Hey, I\'m Luts. Nice to meet you.';
        }
        return 'Hello, I\'m Luts. Nice to meet you.';
      case LutsLanguage.ja:
        if (profile.speechLevel == LutsSpeechLevel.casual) {
          return 'やあ、ルツだよ。会えてうれしい。';
        }
        return 'こんにちは、ルツです。お会いできてうれしいです。';
      case LutsLanguage.ko:
      case LutsLanguage.unknown:
        if (profile.speechLevel == LutsSpeechLevel.casual) {
          return '안녕, 러츠야. 만나서 반가워.';
        }
        return '안녕하세요, 러츠예요. 만나서 반가워요.';
    }
  }

  static String applyTemplateTone(
    String message,
    LutsToneProfile profile, {
    AffinityPhase? affinityPhase,
  }) {
    var result = message.trim();
    if (result.isEmpty) return result;
    final resolvedSpeech =
        _resolveSpeechLevel(profile: profile, affinityPhase: affinityPhase);

    if (!profile.nicknameAllowed) {
      result = _removeNicknames(result);
    }
    result = _sanitizeServiceTone(result);

    if (profile.language == LutsLanguage.ko &&
        resolvedSpeech == LutsSpeechLevel.formal) {
      result = _toKoreanFormal(result);
    }
    if (profile.language == LutsLanguage.ko &&
        resolvedSpeech == LutsSpeechLevel.casual) {
      result = _toKoreanCasual(result);
    }

    result = _applyTurnIntentShaping(
      result,
      profile,
      affinityPhase: affinityPhase,
    );
    result = enforceKakaoSingleBubble(result);
    return result.isEmpty
        ? _defaultReplyForIntent(profile, affinityPhase: affinityPhase)
        : result;
  }

  static String applyGeneratedTone(
    String message,
    LutsToneProfile profile, {
    bool encourageContinuity = false,
    AffinityPhase? affinityPhase,
  }) {
    var result = message.trim();
    if (result.isEmpty) return result;

    if (!profile.nicknameAllowed) {
      result = _removeNicknames(result);
    }
    result = _sanitizeServiceTone(result);
    result = _applyTurnIntentShaping(
      result,
      profile,
      affinityPhase: affinityPhase,
    );
    result = enforceKakaoSingleBubble(result);
    if (encourageContinuity) {
      result = _ensureConversationalBridge(
        result,
        profile,
        affinityPhase: affinityPhase,
      );
      result = enforceKakaoSingleBubble(result);
    }
    return result.isEmpty
        ? _defaultReplyForIntent(profile, affinityPhase: affinityPhase)
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

  static bool _containsNickname(String text) {
    return _nicknamePattern.hasMatch(text);
  }

  static String _removeNicknames(String text) {
    final language = detectLanguage(text);
    final replacement = switch (language) {
      LutsLanguage.en => 'you',
      LutsLanguage.ja => 'あなた',
      LutsLanguage.ko => '당신',
      LutsLanguage.unknown => '당신',
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
    LutsToneProfile profile, {
    AffinityPhase? affinityPhase,
  }) {
    var result = text.trim();
    if (result.isEmpty) return result;

    if (_serviceTonePattern.hasMatch(result)) {
      return _defaultReplyForIntent(profile, affinityPhase: affinityPhase);
    }

    if (profile.turnIntent == LutsTurnIntent.greeting) {
      result = _normalizeGreetingEcho(
        result,
        profile,
        affinityPhase: affinityPhase,
      );
    }

    if (profile.turnIntent == LutsTurnIntent.gratitude &&
        _serviceTonePattern.hasMatch(result)) {
      return _defaultReplyForIntent(profile, affinityPhase: affinityPhase);
    }

    return result;
  }

  static String _ensureConversationalBridge(
    String text,
    LutsToneProfile profile, {
    AffinityPhase? affinityPhase,
  }) {
    final relationshipStage = relationshipStageFromAffinityPhase(
        affinityPhase ?? AffinityPhase.stranger);
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) {
      return _defaultReplyForIntent(profile, affinityPhase: affinityPhase);
    }

    final hasQuestion = normalized.contains('?') || normalized.contains('？');
    if (hasQuestion || profile.turnIntent == LutsTurnIntent.question) {
      return normalized;
    }

    final shouldBridge = profile.turnIntent == LutsTurnIntent.greeting ||
        profile.turnIntent == LutsTurnIntent.shortReply ||
        profile.turnIntent == LutsTurnIntent.sharing;
    if (!shouldBridge) return normalized;

    if (relationshipStage == LutsRelationshipStage.gettingToKnow &&
        !profile.nameKnown &&
        !profile.nameAsked &&
        (profile.turnIntent == LutsTurnIntent.greeting ||
            profile.turnIntent == LutsTurnIntent.shortReply)) {
      return _buildNamePromptSentence(profile, affinityPhase: affinityPhase);
    }

    final bridge = _bridgeSentence(profile, affinityPhase: affinityPhase);
    if (bridge.isEmpty) return normalized;

    final needsPunctuation = !RegExp(r'[.!?。！？]$').hasMatch(normalized);
    final base = needsPunctuation ? '$normalized.' : normalized;
    return '$base $bridge'.trim();
  }

  static String _bridgeSentence(
    LutsToneProfile profile, {
    AffinityPhase? affinityPhase,
  }) {
    final resolvedSpeech =
        _resolveSpeechLevel(profile: profile, affinityPhase: affinityPhase);

    switch (profile.language) {
      case LutsLanguage.en:
        return resolvedSpeech == LutsSpeechLevel.casual
            ? 'What are you curious about these days?'
            : 'What are you most curious about these days?';
      case LutsLanguage.ja:
        return resolvedSpeech == LutsSpeechLevel.casual
            ? '最近いちばん気になってることって何？'
            : '最近いちばん気になっていることは何ですか？';
      case LutsLanguage.ko:
      case LutsLanguage.unknown:
        return resolvedSpeech == LutsSpeechLevel.casual
            ? '요즘 제일 궁금한 게 뭐야?'
            : '요즘 가장 궁금한 건 뭐예요?';
    }
  }

  static String _buildNamePromptSentence(
    LutsToneProfile profile, {
    AffinityPhase? affinityPhase,
  }) {
    final resolvedSpeech =
        _resolveSpeechLevel(profile: profile, affinityPhase: affinityPhase);

    switch (profile.language) {
      case LutsLanguage.en:
        return resolvedSpeech == LutsSpeechLevel.casual
            ? 'What should I call you? It is okay if you want to share later.'
            : 'What should I call you? It is okay if you want to share your name later.';
      case LutsLanguage.ja:
        return resolvedSpeech == LutsSpeechLevel.casual
            ? 'なんて呼べばいい？名前はあとででも大丈夫だよ。'
            : 'なんてお呼びすればいいですか？お名前は後ででも大丈夫です。';
      case LutsLanguage.ko:
      case LutsLanguage.unknown:
        return resolvedSpeech == LutsSpeechLevel.casual
            ? '편하게 뭐라고 부르면 돼? 이름은 편할 때 말해줘도 돼.'
            : '편하게 어떻게 불러드리면 될까요? 이름은 편할 때 알려주셔도 괜찮아요.';
    }
  }

  static String _normalizeGreetingEcho(
    String text,
    LutsToneProfile profile, {
    AffinityPhase? affinityPhase,
  }) {
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) {
      return _defaultReplyForIntent(profile, affinityPhase: affinityPhase);
    }

    final greetingEchoPattern = RegExp(
      r'^(네[, ]*)?(저도[, ]*)?(반갑(?:습니다|네요|다|아요)|만나서 반갑)',
      caseSensitive: false,
    );

    if (greetingEchoPattern.hasMatch(normalized)) {
      return _defaultReplyForIntent(profile, affinityPhase: affinityPhase);
    }

    return normalized;
  }

  static String _defaultReplyForIntent(
    LutsToneProfile profile, {
    AffinityPhase? affinityPhase,
  }) {
    final resolvedSpeech =
        _resolveSpeechLevel(profile: profile, affinityPhase: affinityPhase);

    switch (profile.language) {
      case LutsLanguage.en:
        switch (profile.turnIntent) {
          case LutsTurnIntent.greeting:
            return 'Nice to meet you too. We can chat casually.';
          case LutsTurnIntent.gratitude:
            return 'You are welcome. We can keep going.';
          case LutsTurnIntent.shortReply:
            return 'Sounds good. Let us keep talking.';
          case LutsTurnIntent.question:
          case LutsTurnIntent.sharing:
          case LutsTurnIntent.unknown:
            return 'I hear you. Let us keep this simple.';
        }
      case LutsLanguage.ja:
        switch (profile.turnIntent) {
          case LutsTurnIntent.greeting:
            return 'こちらこそ、会えてうれしいです。気軽に話してください。';
          case LutsTurnIntent.gratitude:
            return 'どういたしまして。続けて話しましょう。';
          case LutsTurnIntent.shortReply:
            return 'いいですね。ゆっくり話しましょう。';
          case LutsTurnIntent.question:
          case LutsTurnIntent.sharing:
          case LutsTurnIntent.unknown:
            return 'うん、受け取ったよ。続けて話そう。';
        }
      case LutsLanguage.ko:
      case LutsLanguage.unknown:
        final isCasual = resolvedSpeech == LutsSpeechLevel.casual;
        switch (profile.turnIntent) {
          case LutsTurnIntent.greeting:
            return isCasual ? '나도 반가워. 편하게 얘기하자.' : '저도 반가워요. 편하게 이야기해요.';
          case LutsTurnIntent.gratitude:
            return isCasual ? '별말 아니야. 이어서 얘기하자.' : '별말씀을요. 이어서 이야기해요.';
          case LutsTurnIntent.shortReply:
            return isCasual ? '좋아. 이어서 얘기해.' : '좋아요. 이어서 이야기해요.';
          case LutsTurnIntent.question:
          case LutsTurnIntent.sharing:
          case LutsTurnIntent.unknown:
            return isCasual ? '응, 들었어. 계속 말해줘.' : '네, 잘 들었어요. 이어서 말씀해 주세요.';
        }
    }
  }

  static bool _isGreeting(String text, LutsLanguage language) {
    switch (language) {
      case LutsLanguage.ko:
        return _koGreetingPattern.hasMatch(text);
      case LutsLanguage.en:
        return _enGreetingPattern.hasMatch(text);
      case LutsLanguage.ja:
        return _jaGreetingPattern.hasMatch(text);
      case LutsLanguage.unknown:
        return _koGreetingPattern.hasMatch(text) ||
            _enGreetingPattern.hasMatch(text) ||
            _jaGreetingPattern.hasMatch(text);
    }
  }

  static bool _isGratitude(String text, LutsLanguage language) {
    switch (language) {
      case LutsLanguage.ko:
        return _koThanksPattern.hasMatch(text);
      case LutsLanguage.en:
        return _enThanksPattern.hasMatch(text);
      case LutsLanguage.ja:
        return _jaThanksPattern.hasMatch(text);
      case LutsLanguage.unknown:
        return _koThanksPattern.hasMatch(text) ||
            _enThanksPattern.hasMatch(text) ||
            _jaThanksPattern.hasMatch(text);
    }
  }

  static bool _isShortReply(String text, LutsLanguage language) {
    switch (language) {
      case LutsLanguage.ko:
        return _koShortReplyPattern.hasMatch(text);
      case LutsLanguage.en:
        return _enShortReplyPattern.hasMatch(text);
      case LutsLanguage.ja:
        return _jaShortReplyPattern.hasMatch(text);
      case LutsLanguage.unknown:
        return text.runes.length <= 10;
    }
  }

  static String _toKoreanFormal(String text) {
    var result = text;

    const replacements = <MapEntry<String, String>>[
      MapEntry('안녕,', '안녕하세요,'),
      MapEntry('안녕.', '안녕하세요.'),
      MapEntry('뭐해?', '무엇을 하고 계세요?'),
      MapEntry('뭐 해?', '무엇을 하고 계세요?'),
      MapEntry('먹었어?', '식사는 하셨어요?'),
      MapEntry('괜찮아?', '괜찮으세요?'),
      MapEntry('기다릴게.', '기다리고 있을게요.'),
      MapEntry('해줄래?', '해주실래요?'),
      MapEntry('알려줘.', '알려주세요.'),
      MapEntry('같이 뭐 먹을까?', '같이 무엇을 드실래요?'),
      MapEntry('궁금한데', '궁금해요'),
      MapEntry('보고 싶어서 그래.', '보고 싶어서 그랬어요.'),
      MapEntry('빨리 와.', '시간 되실 때 와주세요.'),
      MapEntry('얘기하자.', '이야기해요.'),
    ];

    for (final replacement in replacements) {
      result = result.replaceAll(replacement.key, replacement.value);
    }

    return result;
  }

  static String _toKoreanCasual(String text) {
    var result = text;

    const replacements = <MapEntry<String, String>>[
      MapEntry('안녕하세요', '안녕'),
      MapEntry('계세요?', '있어?'),
      MapEntry('하셨어요?', '했어?'),
      MapEntry('괜찮으세요?', '괜찮아?'),
      MapEntry('남겨요.', '남길게.'),
      MapEntry('드실래요?', '먹을래?'),
      MapEntry('해주세요.', '해줘.'),
      MapEntry('와주세요.', '와줘.'),
      MapEntry('고생 많았어요.', '고생 많았어.'),
      MapEntry('해주세요?', '해줄래?'),
      MapEntry('이어서 이야기해요.', '이어서 얘기해.'),
      MapEntry('편하게 이야기해요.', '편하게 얘기하자.'),
    ];

    for (final replacement in replacements) {
      result = result.replaceAll(replacement.key, replacement.value);
    }

    return result;
  }
}
