import 'tarot_metadata_data.dart';

class TarotCardCatalogEntry {
  final int index;
  final String cardId;
  final String arcana;
  final String? suit;
  final String rank;
  final String cardName;
  final String cardNameKr;
  final List<String> keywords;
  final String uprightMeaning;
  final String reversedMeaning;
  final String element;
  final String imagePath;
  final String loreSummary;
  final String advice;
  final List<String> reflectionQuestions;

  const TarotCardCatalogEntry({
    required this.index,
    required this.cardId,
    required this.arcana,
    required this.suit,
    required this.rank,
    required this.cardName,
    required this.cardNameKr,
    required this.keywords,
    required this.uprightMeaning,
    required this.reversedMeaning,
    required this.element,
    required this.imagePath,
    required this.loreSummary,
    required this.advice,
    required this.reflectionQuestions,
  });
}

class TarotCardCatalog {
  const TarotCardCatalog._();

  static const List<String> _majorSlugs = [
    'fool',
    'magician',
    'high_priestess',
    'empress',
    'emperor',
    'hierophant',
    'lovers',
    'chariot',
    'strength',
    'hermit',
    'wheel_of_fortune',
    'justice',
    'hanged_man',
    'death',
    'temperance',
    'devil',
    'tower',
    'star',
    'moon',
    'sun',
    'judgement',
    'world',
  ];

  static const List<String> _majorEnglishNames = [
    'The Fool',
    'The Magician',
    'The High Priestess',
    'The Empress',
    'The Emperor',
    'The Hierophant',
    'The Lovers',
    'The Chariot',
    'Strength',
    'The Hermit',
    'Wheel of Fortune',
    'Justice',
    'The Hanged Man',
    'Death',
    'Temperance',
    'The Devil',
    'The Tower',
    'The Star',
    'The Moon',
    'The Sun',
    'Judgement',
    'The World',
  ];

  static const List<String> _majorKoreanNames = [
    '바보',
    '마법사',
    '여사제',
    '여황제',
    '황제',
    '교황',
    '연인들',
    '전차',
    '힘',
    '은둔자',
    '운명의 수레바퀴',
    '정의',
    '매달린 사람',
    '죽음',
    '절제',
    '악마',
    '탑',
    '별',
    '달',
    '태양',
    '심판',
    '세계',
  ];

  static const List<String> _minorSuits = [
    'cups',
    'wands',
    'swords',
    'pentacles',
  ];

  static const Map<String, _MinorSuitData> _minorSuitData = {
    'cups': _MinorSuitData(
      englishName: 'Cups',
      koreanName: '컵',
      element: '물',
      keywords: ['감정', '관계', '공감'],
      uprightTheme: '감정의 흐름과 관계의 교류가 열려 있어요.',
      reversedTheme: '감정의 정리와 거리 조절이 필요한 흐름이에요.',
      lore: '컵 슈트는 감정, 애정, 친밀감, 직관의 물결을 다룹니다. 관계의 온도와 마음의 방향을 읽을 때 핵심이 됩니다.',
      advice: '감정이 올라오는 이유를 먼저 이해하고, 내 마음과 상대의 리듬을 함께 살펴보세요.',
    ),
    'wands': _MinorSuitData(
      englishName: 'Wands',
      koreanName: '완드',
      element: '불',
      keywords: ['열정', '추진력', '행동'],
      uprightTheme: '행동력과 추진력이 살아나는 국면이에요.',
      reversedTheme: '조급함을 낮추고 방향을 다시 맞출 때예요.',
      lore: '완드 슈트는 열정, 목표, 추진력, 창조적 에너지를 뜻합니다. 시작과 도전, 속도감 있는 변화를 강조합니다.',
      advice: '지금의 불꽃을 유지하되, 속도보다 방향을 먼저 확인하면 흐름이 더 좋아집니다.',
    ),
    'swords': _MinorSuitData(
      englishName: 'Swords',
      koreanName: '소드',
      element: '공기',
      keywords: ['사고', '판단', '소통'],
      uprightTheme: '판단과 결단, 명료한 시선이 필요한 때예요.',
      reversedTheme: '과한 생각을 덜고 핵심만 남겨야 할 흐름이에요.',
      lore: '소드 슈트는 생각, 언어, 갈등, 진실을 다룹니다. 현실 판단과 경계 설정, 중요한 결론과 연결됩니다.',
      advice: '복잡한 생각을 정리하고, 사실과 감정을 구분해 보면 더 분명한 답이 나옵니다.',
    ),
    'pentacles': _MinorSuitData(
      englishName: 'Pentacles',
      koreanName: '펜타클',
      element: '땅',
      keywords: ['현실', '안정', '자원'],
      uprightTheme: '현실 감각과 안정적인 기반이 중요한 흐름이에요.',
      reversedTheme: '지출과 에너지 배분을 다시 점검해야 할 시기예요.',
      lore: '펜타클 슈트는 일, 돈, 몸, 자원, 일상의 기반을 상징합니다. 실질적인 결과와 꾸준함을 다룹니다.',
      advice: '손에 잡히는 계획과 실행 단위를 작게 나누면 흐름을 안정적으로 이어갈 수 있습니다.',
    ),
  };

  static const Map<int, _MinorRankData> _minorRankData = {
    1: _MinorRankData(
      englishName: 'Ace',
      koreanName: '에이스',
      keywords: ['시작', '씨앗', '기회'],
      uprightMeaning: '새로운 가능성과 첫 신호가 열리는 카드예요.',
      reversedMeaning: '시작의 에너지가 막히거나 타이밍이 어긋날 수 있어요.',
    ),
    2: _MinorRankData(
      englishName: 'Two',
      koreanName: '2',
      keywords: ['균형', '선택', '조율'],
      uprightMeaning: '두 흐름을 조율하며 균형을 잡아야 하는 카드예요.',
      reversedMeaning: '우선순위가 흔들리거나 선택 피로가 커질 수 있어요.',
    ),
    3: _MinorRankData(
      englishName: 'Three',
      koreanName: '3',
      keywords: ['전개', '협력', '성장'],
      uprightMeaning: '흐름이 본격적으로 전개되고 협력이 붙는 카드예요.',
      reversedMeaning: '협업의 호흡이 어긋나거나 성장 속도가 더딜 수 있어요.',
    ),
    4: _MinorRankData(
      englishName: 'Four',
      koreanName: '4',
      keywords: ['안정', '보호', '유지'],
      uprightMeaning: '기반을 다지고 안정감을 확보해야 하는 카드예요.',
      reversedMeaning: '안정을 지키려는 마음이 흐름을 막을 수 있어요.',
    ),
    5: _MinorRankData(
      englishName: 'Five',
      koreanName: '5',
      keywords: ['변화', '긴장', '시험'],
      uprightMeaning: '불편함과 충돌 속에서 방향을 다시 잡아야 하는 카드예요.',
      reversedMeaning: '갈등이 잦아들지만 핵심 문제는 여전히 남아 있을 수 있어요.',
    ),
    6: _MinorRankData(
      englishName: 'Six',
      koreanName: '6',
      keywords: ['회복', '조화', '이동'],
      uprightMeaning: '흐름이 회복되고 부드럽게 연결되기 시작하는 카드예요.',
      reversedMeaning: '회복이 늦어지거나 정리되지 않은 감정이 남아 있을 수 있어요.',
    ),
    7: _MinorRankData(
      englishName: 'Seven',
      koreanName: '7',
      keywords: ['점검', '도전', '집중'],
      uprightMeaning: '지금까지의 흐름을 점검하고 버텨내야 하는 카드예요.',
      reversedMeaning: '불안과 분산으로 중심이 흔들릴 수 있어요.',
    ),
    8: _MinorRankData(
      englishName: 'Eight',
      koreanName: '8',
      keywords: ['가속', '숙련', '전환'],
      uprightMeaning: '속도가 붙거나 숙련도가 올라가는 카드예요.',
      reversedMeaning: '과속, 집착, 피로 누적으로 흐름이 꼬일 수 있어요.',
    ),
    9: _MinorRankData(
      englishName: 'Nine',
      koreanName: '9',
      keywords: ['완성 직전', '성숙', '수확'],
      uprightMeaning: '성과가 가까워졌고 자신감을 회복하는 카드예요.',
      reversedMeaning: '막바지 피로감이나 불안으로 힘이 빠질 수 있어요.',
    ),
    10: _MinorRankData(
      englishName: 'Ten',
      koreanName: '10',
      keywords: ['완결', '정점', '정리'],
      uprightMeaning: '한 흐름의 정점 또는 마무리를 보여주는 카드예요.',
      reversedMeaning: '끝내야 할 것을 놓지 못해 무게가 커질 수 있어요.',
    ),
    11: _MinorRankData(
      englishName: 'Page',
      koreanName: '시종',
      keywords: ['메시지', '호기심', '초심'],
      uprightMeaning: '새 소식, 배움, 작은 시도가 들어오는 카드예요.',
      reversedMeaning: '미숙함이나 소통 실수로 흐름이 어긋날 수 있어요.',
    ),
    12: _MinorRankData(
      englishName: 'Knight',
      koreanName: '기사',
      keywords: ['추진', '움직임', '집중'],
      uprightMeaning: '목표를 향해 강하게 움직이는 추진력이 들어오는 카드예요.',
      reversedMeaning: '성급함, 과열, 방향 상실을 경계해야 하는 카드예요.',
    ),
    13: _MinorRankData(
      englishName: 'Queen',
      koreanName: '여왕',
      keywords: ['성숙', '돌봄', '직관'],
      uprightMeaning: '내면의 안정과 성숙한 리더십이 드러나는 카드예요.',
      reversedMeaning: '예민함, 과보호, 감정 기복이 커질 수 있어요.',
    ),
    14: _MinorRankData(
      englishName: 'King',
      koreanName: '왕',
      keywords: ['통제', '책임', '완성도'],
      uprightMeaning: '구조를 잡고 결과를 이끌 힘이 커지는 카드예요.',
      reversedMeaning: '통제욕, 완고함, 책임 부담이 커질 수 있어요.',
    ),
  };

  static List<int> get orderedIndices =>
      List<int>.generate(78, (index) => index);

  static TarotCardCatalogEntry fromIndex(
    int index, {
    String deckId = 'rider_waite',
  }) {
    if (index < 22) {
      return _majorEntry(index, deckId: deckId);
    }

    final minorIndex = index - 22;
    final suit = _minorSuits[minorIndex ~/ 14];
    final rank = (minorIndex % 14) + 1;
    return _minorEntry(
      index,
      suit: suit,
      rank: rank,
      deckId: deckId,
    );
  }

  static TarotCardCatalogEntry fromCardMap(
    Map<String, dynamic> card, {
    String deckId = 'rider_waite',
  }) {
    final index = _intValue(card['index']);
    if (index != null) {
      return fromIndex(
        index,
        deckId: _stringValue(card['deckId']) ??
            _stringValue(card['deck']) ??
            deckId,
      );
    }

    final suit = _stringValue(card['suit']);
    final rank = _intValue(card['rank']);
    if (suit != null && rank != null) {
      final computedIndex = 22 + (_minorSuits.indexOf(suit) * 14) + (rank - 1);
      if (computedIndex >= 22) {
        return fromIndex(
          computedIndex,
          deckId: _stringValue(card['deckId']) ??
              _stringValue(card['deck']) ??
              deckId,
        );
      }
    }

    return fromIndex(0, deckId: deckId);
  }

  static String previewImagePath(String deckId, String previewSlug) {
    return 'assets/images/tarot/decks/$deckId/major/$previewSlug.webp';
  }

  static TarotCardCatalogEntry _majorEntry(
    int index, {
    required String deckId,
  }) {
    final info = TarotMetadata.getCard(index);
    return TarotCardCatalogEntry(
      index: index,
      cardId: 'major_${index.toString().padLeft(2, '0')}_${_majorSlugs[index]}',
      arcana: 'major',
      suit: null,
      rank: index.toString().padLeft(2, '0'),
      cardName: _majorEnglishNames[index],
      cardNameKr: _majorKoreanNames[index],
      keywords: List<String>.from(info?.keywords ?? const ['변화', '통찰', '흐름']),
      uprightMeaning: info?.uprightMeaning ?? '이 카드의 정방향 메시지를 따라가 보세요.',
      reversedMeaning: info?.reversedMeaning ?? '이 카드의 역방향 경고를 점검해 보세요.',
      element: info?.element ?? '공기',
      imagePath:
          'assets/images/tarot/decks/$deckId/major/${index.toString().padLeft(2, '0')}_${_majorSlugs[index]}.webp',
      loreSummary: info?.story ?? info?.imagery ?? '이 카드는 큰 흐름과 전환점을 상징합니다.',
      advice: info?.advice ?? '지금의 흐름에서 가장 중요한 메시지를 붙잡아 보세요.',
      reflectionQuestions: List<String>.from(
        info?.questions ?? const ['이 카드가 지금 내게 말하는 핵심은 무엇일까요?'],
      ),
    );
  }

  static TarotCardCatalogEntry _minorEntry(
    int index, {
    required String suit,
    required int rank,
    required String deckId,
  }) {
    final suitData = _minorSuitData[suit]!;
    final rankData = _minorRankData[rank]!;
    final englishRank = rankData.englishName;
    final koreanRank = rankData.koreanName;
    final englishSuit = suitData.englishName;
    final koreanSuit = suitData.koreanName;
    final isCourt = rank >= 11;
    final fileName = isCourt
        ? '${englishRank.toLowerCase()}_of_$suit.webp'
        : '${rank.toString().padLeft(2, '0')}_of_$suit.webp';

    return TarotCardCatalogEntry(
      index: index,
      cardId: '${suit}_${rank.toString().padLeft(2, '0')}',
      arcana: 'minor',
      suit: suit,
      rank: '$rank',
      cardName: '$englishRank of $englishSuit',
      cardNameKr: '$koreanSuit $koreanRank',
      keywords: {
        ...suitData.keywords,
        ...rankData.keywords,
      }.toList(growable: false),
      uprightMeaning: '${rankData.uprightMeaning} ${suitData.uprightTheme}',
      reversedMeaning: '${rankData.reversedMeaning} ${suitData.reversedTheme}',
      element: suitData.element,
      imagePath: 'assets/images/tarot/decks/$deckId/$suit/$fileName',
      loreSummary: '$koreanSuit 슈트의 $koreanRank는 ${suitData.lore}',
      advice: '${rankData.uprightMeaning} ${suitData.advice}',
      reflectionQuestions: [
        '$koreanSuit의 흐름이 지금 내 일상에 어떻게 드러나고 있나요?',
        '이 카드가 강조하는 우선순위는 무엇인가요?',
      ],
    );
  }

  static int? _intValue(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  static String? _stringValue(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}

class _MinorSuitData {
  final String englishName;
  final String koreanName;
  final String element;
  final List<String> keywords;
  final String uprightTheme;
  final String reversedTheme;
  final String lore;
  final String advice;

  const _MinorSuitData({
    required this.englishName,
    required this.koreanName,
    required this.element,
    required this.keywords,
    required this.uprightTheme,
    required this.reversedTheme,
    required this.lore,
    required this.advice,
  });
}

class _MinorRankData {
  final String englishName;
  final String koreanName;
  final List<String> keywords;
  final String uprightMeaning;
  final String reversedMeaning;

  const _MinorRankData({
    required this.englishName,
    required this.koreanName,
    required this.keywords,
    required this.uprightMeaning,
    required this.reversedMeaning,
  });
}
