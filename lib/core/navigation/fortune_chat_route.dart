enum ChatCatalogPreviewState {
  generalHome,
  curiosityHome,
  curiositySurvey,
  curiosityResult,
}

class ChatCatalogPreview {
  final ChatCatalogPreviewState state;
  final String? fortuneType;

  const ChatCatalogPreview({
    required this.state,
    this.fortuneType,
  });

  bool get showsHomeShell =>
      state == ChatCatalogPreviewState.generalHome ||
      state == ChatCatalogPreviewState.curiosityHome;

  bool get showsChatOverlay =>
      state == ChatCatalogPreviewState.curiositySurvey ||
      state == ChatCatalogPreviewState.curiosityResult;

  bool get isGeneralHome => state == ChatCatalogPreviewState.generalHome;

  bool get isCuriosityPreview => state != ChatCatalogPreviewState.generalHome;

  static ChatCatalogPreview? fromUri(Uri uri) {
    final rawState = _emptyToNull(uri.queryParameters['catalogState']);
    if (rawState == null) {
      return null;
    }

    final state = _catalogStateFromQuery(rawState);
    if (state == null) {
      return null;
    }

    final fortuneType = _emptyToNull(
      normalizeFortuneTypeForChat(uri.queryParameters['fortuneType']),
    );

    return ChatCatalogPreview(
      state: state,
      fortuneType: fortuneType,
    );
  }

  static ChatCatalogPreviewState? _catalogStateFromQuery(String rawState) {
    switch (rawState.trim().toLowerCase()) {
      case 'general-home':
        return ChatCatalogPreviewState.generalHome;
      case 'curiosity-home':
        return ChatCatalogPreviewState.curiosityHome;
      case 'curiosity-survey':
        return ChatCatalogPreviewState.curiositySurvey;
      case 'curiosity-result':
        return ChatCatalogPreviewState.curiosityResult;
      default:
        return null;
    }
  }
}

class FortuneChatLaunchRequest {
  final bool openCharacterChat;
  final String? characterId;
  final String? fortuneType;
  final bool autoStartFortune;
  final String? entrySource;

  const FortuneChatLaunchRequest({
    required this.openCharacterChat,
    this.characterId,
    this.fortuneType,
    required this.autoStartFortune,
    this.entrySource,
  });

  bool get shouldOpenChat =>
      openCharacterChat || characterId != null || fortuneType != null;

  String get launchSignature => [
        openCharacterChat ? 'open' : 'closed',
        characterId ?? '-',
        fortuneType ?? '-',
        autoStartFortune ? 'auto' : 'manual',
        entrySource ?? '-',
      ].join('|');

  FortuneChatLaunchRequest copyWith({
    bool? openCharacterChat,
    String? characterId,
    bool clearCharacterId = false,
    String? fortuneType,
    bool clearFortuneType = false,
    bool? autoStartFortune,
    String? entrySource,
    bool clearEntrySource = false,
  }) {
    return FortuneChatLaunchRequest(
      openCharacterChat: openCharacterChat ?? this.openCharacterChat,
      characterId: clearCharacterId ? null : (characterId ?? this.characterId),
      fortuneType: clearFortuneType ? null : (fortuneType ?? this.fortuneType),
      autoStartFortune: autoStartFortune ?? this.autoStartFortune,
      entrySource: clearEntrySource ? null : (entrySource ?? this.entrySource),
    );
  }

  static FortuneChatLaunchRequest fromUri(Uri uri) {
    final query = uri.queryParameters;
    final fortuneType = _emptyToNull(
      normalizeFortuneTypeForChat(
        query['fortuneType'] ?? query['fortune_type'],
      ),
    );

    return FortuneChatLaunchRequest(
      openCharacterChat: query['openCharacterChat'] == 'true',
      characterId: _emptyToNull(query['characterId']),
      fortuneType: fortuneType,
      autoStartFortune: query['autoStartFortune'] == 'true',
      entrySource: _emptyToNull(query['entrySource']),
    );
  }
}

String buildFortuneChatRoute(
  String fortuneType, {
  String? characterId,
  String? entrySource,
  bool autoStartFortune = true,
}) {
  final normalizedType = normalizeFortuneTypeForChat(fortuneType);
  final queryParameters = <String, String>{
    'openCharacterChat': 'true',
    'fortuneType': normalizedType,
    'autoStartFortune': autoStartFortune ? 'true' : 'false',
  };

  if (characterId != null && characterId.isNotEmpty) {
    queryParameters['characterId'] = characterId;
  }

  if (entrySource != null && entrySource.isNotEmpty) {
    queryParameters['entrySource'] = entrySource;
  }

  return Uri(
    path: '/chat',
    queryParameters: queryParameters,
  ).toString();
}

String normalizeFortuneTypeForChat(String? rawFortuneType) {
  final sanitized = _emptyToNull(rawFortuneType);
  if (sanitized == null) {
    return '';
  }

  final normalized =
      sanitized.trim().replaceAll('/', '').replaceAll('_', '-').toLowerCase();

  const aliasMap = <String, String>{
    'time': 'daily',
    'daily-calendar': 'daily',
    'health': 'daily',
    'saju': 'traditional-saju',
    'traditional': 'traditional-saju',
    'yearly': 'new-year',
    'investment': 'wealth',
    'sports-game': 'match-insight',
    'lucky-lottery': 'lotto',
    'pet': 'pet-compatibility',
    'ex-lover-simple': 'ex-lover',
    'baby-nickname': 'naming',
  };

  return aliasMap[normalized] ?? normalized;
}

String? _emptyToNull(String? value) {
  if (value == null) {
    return null;
  }

  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
