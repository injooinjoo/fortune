import '../../domain/models/character_chat_message.dart';

/// 언어 추정 결과
///
/// `unknown`은 입력이 너무 짧거나 문자가 섞여서 단정하기 어려운 경우입니다.
enum LutsLanguage { ko, en, ja, unknown }

/// 말투 격식 추정 결과
enum LutsSpeechLevel { formal, casual, neutral }

/// 러츠 톤 정책에 필요한 사용자 말투 컨텍스트
class LutsToneProfile {
  final LutsLanguage language;
  final LutsSpeechLevel speechLevel;
  final bool nicknameAllowed;

  const LutsToneProfile({
    required this.language,
    required this.speechLevel,
    required this.nicknameAllowed,
  });

  static const neutral = LutsToneProfile(
    language: LutsLanguage.unknown,
    speechLevel: LutsSpeechLevel.neutral,
    nicknameAllowed: false,
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
    final nicknameAllowed = userTexts.any(_containsNickname);

    return LutsToneProfile(
      language: language,
      speechLevel: speechLevel,
      nicknameAllowed: nicknameAllowed,
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
      LutsSpeechLevel.casual => '현재 톤: casual. 편한 구어체로 답하세요.',
      LutsSpeechLevel.neutral => '현재 톤: neutral. 과하게 딱딱하거나 과격하지 않게 답하세요.',
    };

    final nicknameGuide = profile.nicknameAllowed
        ? '애칭 사용 가능: 사용자가 먼저 애칭을 사용했으므로, 필요할 때만 자연스럽게 제한적으로 사용하세요.'
        : '애칭 사용 금지: "여보", "자기", "honey", "darling" 같은 호칭을 쓰지 마세요.';

    return '''
[LUTS STYLE GUARD]
- 직답 우선: 질문에는 첫 문장에서 직접 답하세요.
- 1버블 규칙: 답변은 1~2문장만 사용하세요.
- 질문 제한: 답변 내 질문은 필요할 때만 최대 1개.
- 반복 금지: 같은 의미 문장을 반복하지 마세요.
- $languageGuide
- $speechGuide
- $nicknameGuide
''';
  }

  static String applyTemplateTone(
    String message,
    LutsToneProfile profile,
  ) {
    var result = message.trim();

    if (!profile.nicknameAllowed) {
      result = _removeNicknames(result);
    }

    if (profile.language == LutsLanguage.ko &&
        profile.speechLevel == LutsSpeechLevel.formal) {
      result = _toKoreanFormal(result);
    }
    if (profile.language == LutsLanguage.ko &&
        profile.speechLevel == LutsSpeechLevel.casual) {
      result = _toKoreanCasual(result);
    }

    return enforceKakaoSingleBubble(result);
  }

  static String applyGeneratedTone(
    String message,
    LutsToneProfile profile,
  ) {
    var result = message.trim();
    if (!profile.nicknameAllowed) {
      result = _removeNicknames(result);
    }
    return enforceKakaoSingleBubble(result);
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
    ];

    for (final replacement in replacements) {
      result = result.replaceAll(replacement.key, replacement.value);
    }

    return result;
  }
}
