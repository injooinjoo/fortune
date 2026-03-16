class TarotChatPayloadUtils {
  const TarotChatPayloadUtils._();

  static String resolveSpreadType(String? purpose) {
    switch (purpose) {
      case 'love':
        return 'relationship';
      case 'career':
      case 'decision':
      case 'guidance':
      default:
        return 'threeCard';
    }
  }

  static int resolveCardCount(String? purpose) {
    return resolveSpreadType(purpose) == 'relationship' ? 5 : 3;
  }

  static List<String> positionNamesForPurpose(String? purpose) {
    switch (resolveSpreadType(purpose)) {
      case 'relationship':
        return const [
          '나의 마음',
          '상대의 마음',
          '과거의 연결',
          '현재 관계',
          '미래 전망',
        ];
      case 'threeCard':
      default:
        return const ['과거', '현재', '미래'];
    }
  }

  static String spreadDisplayName(String spreadType) {
    switch (spreadType) {
      case 'relationship':
        return '관계 스프레드';
      case 'threeCard':
      default:
        return '3카드 스프레드';
    }
  }

  static String purposeLabel(String? purpose) {
    switch (purpose) {
      case 'love':
        return '연애/관계';
      case 'career':
        return '일/커리어';
      case 'decision':
        return '결정/선택';
      case 'guidance':
      default:
        return '조언/가이드';
    }
  }

  static String buildQuestion({
    required String? purpose,
    required String? questionText,
  }) {
    final trimmed = questionText?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }

    switch (purpose) {
      case 'love':
        return '연애와 관계의 흐름이 궁금해요.';
      case 'career':
        return '일과 커리어의 방향이 궁금해요.';
      case 'decision':
        return '지금 앞에 놓인 선택의 흐름이 궁금해요.';
      case 'guidance':
      default:
        return '지금 제게 필요한 조언이 궁금해요.';
    }
  }

  static Map<String, dynamic> buildSelectionPayload({
    required String deckId,
    required String? purpose,
    required String? questionText,
    required List<int> selectedCardIndices,
  }) {
    final spreadType = resolveSpreadType(purpose);
    final question = buildQuestion(
      purpose: purpose,
      questionText: questionText,
    );
    final selectedCards = selectedCardIndices
        .map(
          (index) => <String, dynamic>{
            'index': index,
            'isReversed': false,
          },
        )
        .toList(growable: false);

    return {
      'deck': deckId,
      'spreadType': spreadType,
      'selectedCards': selectedCards,
      'selectedCardIndices': selectedCardIndices,
      'cardCount': selectedCardIndices.length,
      'question': question,
      'displayText':
          '🃏 ${selectedCardIndices.length}장 선택 완료 · ${spreadDisplayName(spreadType)}',
    };
  }

  static Map<String, dynamic> normalizeAnswers(Map<String, dynamic> answers) {
    final normalized = Map<String, dynamic>.from(answers);
    final deckId = _stringValue(normalized['deckId']) ?? 'rider_waite';
    final purpose = _stringValue(normalized['purpose']) ?? 'guidance';
    final questionText = _stringValue(normalized['questionText']);
    final selection =
        _asMap(normalized['tarotSelection']) ?? <String, dynamic>{};
    final spreadType =
        _stringValue(selection['spreadType']) ?? resolveSpreadType(purpose);
    final selectedCardIndices =
        _extractCardIndices(selection['selectedCardIndices']) ??
            _extractCardIndices(selection['selectedCards']) ??
            const <int>[];
    final selectedCards = _extractSelectedCards(selection['selectedCards']) ??
        selectedCardIndices
            .map(
              (index) => <String, dynamic>{
                'index': index,
                'isReversed': false,
              },
            )
            .toList(growable: false);
    final question = buildQuestion(
      purpose: purpose,
      questionText: questionText,
    );

    final tarotSelection = <String, dynamic>{
      'deck': deckId,
      'spreadType': spreadType,
      'selectedCards': selectedCards,
      'selectedCardIndices': selectedCardIndices,
      'cardCount': selectedCardIndices.length,
      'question': question,
      'displayText': _stringValue(selection['displayText']) ??
          '🃏 ${selectedCardIndices.length}장 선택 완료 · ${spreadDisplayName(spreadType)}',
    };

    normalized
      ..['deckId'] = deckId
      ..['purpose'] = purpose
      ..['questionText'] = questionText ?? ''
      ..['question'] = question
      ..['deck'] = deckId
      ..['spreadType'] = spreadType
      ..['selectedCards'] = selectedCards
      ..['selectedCardIndices'] = selectedCardIndices
      ..['tarotSelection'] = tarotSelection;

    return normalized;
  }

  static List<Map<String, dynamic>>? _extractSelectedCards(dynamic value) {
    if (value is! List) {
      return null;
    }

    final cards = value
        .map(_asMap)
        .whereType<Map<String, dynamic>>()
        .map(
          (card) => <String, dynamic>{
            'index':
                _intValue(card['index']) ?? _intValue(card['cardIndex']) ?? 0,
            'isReversed': card['isReversed'] == true,
          },
        )
        .toList(growable: false);

    return cards.isEmpty ? null : cards;
  }

  static List<int>? _extractCardIndices(dynamic value) {
    if (value is! List) {
      return null;
    }

    final indices = value
        .map((item) {
          if (item is num) {
            return item.toInt();
          }
          if (item is Map<String, dynamic>) {
            return _intValue(item['index']) ?? _intValue(item['cardIndex']);
          }
          if (item is Map) {
            return _intValue(item['index']) ?? _intValue(item['cardIndex']);
          }
          return _intValue(item);
        })
        .whereType<int>()
        .toList(growable: false);

    return indices.isEmpty ? null : indices;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return null;
  }

  static String? _stringValue(dynamic value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int? _intValue(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }
}
