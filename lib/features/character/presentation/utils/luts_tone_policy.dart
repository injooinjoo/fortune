import '../../domain/models/character_chat_message.dart';

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

/// 러츠 톤 정책에 필요한 사용자 말투 컨텍스트
class LutsToneProfile {
  final LutsLanguage language;
  final LutsSpeechLevel speechLevel;
  final bool nicknameAllowed;
  final LutsTurnIntent turnIntent;

  const LutsToneProfile({
    required this.language,
    required this.speechLevel,
    required this.nicknameAllowed,
    required this.turnIntent,
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
    r'(안녕|해\?|했어|할래|줘|먹었어|뭐해|뭐해\?|했냐|하냐|야\?|니\?|ㅋㅋ+|ㅎㅎ+|ㅠㅠ+|ㅜㅜ+)',
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

  static LutsToneProfile fromConversation({
    required List<CharacterChatMessage> messages,
    String? currentUserMessage,
  }) {
    final userTexts = <String>[
      ...messages
          .where((m) => m.type == CharacterChatMessageType.user)
          .map((m) => m.text.trim())
          .where((text) => text.isNotEmpty),
      if (currentUserMessage != null && currentUserMessage.trim().isNotEmpty)
        currentUserMessage.trim(),
    ];

    if (userTexts.isEmpty) return LutsToneProfile.neutral;

    final latest = userTexts.last;
    final recentJoined = userTexts.reversed.take(3).join(' ');

    final language = detectLanguage(latest);
    final speechLevel =
        detectSpeechLevel(language: language, text: recentJoined);
    final turnIntent = detectTurnIntent(text: latest, language: language);
    final nicknameAllowed = userTexts.any(_containsNickname);

    return LutsToneProfile(
      language: language,
      speechLevel: speechLevel,
      nicknameAllowed: nicknameAllowed,
      turnIntent: turnIntent,
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

  static String buildStyleGuidePrompt(LutsToneProfile profile) {
    final languageGuide = switch (profile.language) {
      LutsLanguage.ko => '한국어로 답하고, 사용자 말투의 존댓말/반말을 그대로 미러링하세요.',
      LutsLanguage.en =>
        'Respond in English and mirror the user tone (polite or casual).',
      LutsLanguage.ja => '日本語で返答し、ユーザーの丁寧さ（丁寧語/カジュアル）を合わせてください。',
      LutsLanguage.unknown => '사용자 최근 메시지 언어와 톤을 우선 추정해 맞춰주세요.',
    };

    final speechGuide = switch (profile.speechLevel) {
      LutsSpeechLevel.formal => '현재 톤: formal. 정중하고 차분한 어조를 유지하세요.',
      LutsSpeechLevel.casual => '현재 톤: casual. 과장 없이 자연스러운 구어체를 사용하세요.',
      LutsSpeechLevel.neutral => '현재 톤: neutral. 과한 격식/과한 친밀 표현을 모두 피하세요.',
    };

    final nicknameGuide = profile.nicknameAllowed
        ? '애칭 사용 가능: 사용자가 먼저 애칭을 사용했으므로, 필요할 때만 제한적으로 사용하세요.'
        : '애칭 사용 금지: "여보", "자기", "honey", "darling" 같은 호칭을 쓰지 마세요.';

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
- $languageGuide
- $speechGuide
- $nicknameGuide
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
    LutsToneProfile profile,
  ) {
    var result = message.trim();
    if (result.isEmpty) return result;

    if (!profile.nicknameAllowed) {
      result = _removeNicknames(result);
    }
    result = _sanitizeServiceTone(result);

    if (profile.language == LutsLanguage.ko &&
        profile.speechLevel == LutsSpeechLevel.formal) {
      result = _toKoreanFormal(result);
    }
    if (profile.language == LutsLanguage.ko &&
        profile.speechLevel == LutsSpeechLevel.casual) {
      result = _toKoreanCasual(result);
    }

    result = _applyTurnIntentShaping(result, profile);
    result = enforceKakaoSingleBubble(result);
    return result.isEmpty ? _defaultReplyForIntent(profile) : result;
  }

  static String applyGeneratedTone(
    String message,
    LutsToneProfile profile, {
    bool encourageContinuity = false,
  }) {
    var result = message.trim();
    if (result.isEmpty) return result;

    if (!profile.nicknameAllowed) {
      result = _removeNicknames(result);
    }
    result = _sanitizeServiceTone(result);
    result = _applyTurnIntentShaping(result, profile);
    result = enforceKakaoSingleBubble(result);
    if (encourageContinuity) {
      result = _ensureConversationalBridge(result, profile);
      result = enforceKakaoSingleBubble(result);
    }
    return result.isEmpty ? _defaultReplyForIntent(profile) : result;
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

  static String _applyTurnIntentShaping(String text, LutsToneProfile profile) {
    var result = text.trim();
    if (result.isEmpty) return result;

    if (_serviceTonePattern.hasMatch(result)) {
      return _defaultReplyForIntent(profile);
    }

    if (profile.turnIntent == LutsTurnIntent.greeting) {
      result = _normalizeGreetingEcho(result, profile);
    }

    if (profile.turnIntent == LutsTurnIntent.gratitude &&
        _serviceTonePattern.hasMatch(result)) {
      return _defaultReplyForIntent(profile);
    }

    return result;
  }

  static String _ensureConversationalBridge(
    String text,
    LutsToneProfile profile,
  ) {
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return _defaultReplyForIntent(profile);

    final hasQuestion = normalized.contains('?') || normalized.contains('？');
    if (hasQuestion || profile.turnIntent == LutsTurnIntent.question) {
      return normalized;
    }

    final shouldBridge = profile.turnIntent == LutsTurnIntent.greeting ||
        profile.turnIntent == LutsTurnIntent.shortReply ||
        profile.turnIntent == LutsTurnIntent.sharing;
    if (!shouldBridge) return normalized;

    final bridge = _bridgeSentence(profile);
    if (bridge.isEmpty) return normalized;

    final needsPunctuation = !RegExp(r'[.!?。！？]$').hasMatch(normalized);
    final base = needsPunctuation ? '$normalized.' : normalized;
    return '$base $bridge'.trim();
  }

  static String _bridgeSentence(LutsToneProfile profile) {
    switch (profile.language) {
      case LutsLanguage.en:
        return profile.speechLevel == LutsSpeechLevel.casual
            ? 'What are you curious about these days?'
            : 'What are you most curious about these days?';
      case LutsLanguage.ja:
        return profile.speechLevel == LutsSpeechLevel.casual
            ? '最近いちばん気になってることって何？'
            : '最近いちばん気になっていることは何ですか？';
      case LutsLanguage.ko:
      case LutsLanguage.unknown:
        return profile.speechLevel == LutsSpeechLevel.casual
            ? '요즘 제일 궁금한 게 뭐야?'
            : '요즘 가장 궁금한 건 뭐예요?';
    }
  }

  static String _normalizeGreetingEcho(String text, LutsToneProfile profile) {
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return _defaultReplyForIntent(profile);

    final greetingEchoPattern = RegExp(
      r'^(네[, ]*)?(저도[, ]*)?(반갑(?:습니다|네요|다|아요)|만나서 반갑)',
      caseSensitive: false,
    );

    if (greetingEchoPattern.hasMatch(normalized)) {
      return _defaultReplyForIntent(profile);
    }

    return normalized;
  }

  static String _defaultReplyForIntent(LutsToneProfile profile) {
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
        final isCasual = profile.speechLevel == LutsSpeechLevel.casual;
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
