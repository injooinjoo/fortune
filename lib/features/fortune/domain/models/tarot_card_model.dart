// 타로 카드 데이터 모델

/// 타로 스프레드 타입
enum TarotSpreadType {
  single('단일 카드', '빠른 답변', 1),
  threeCard('3카드 스프레드', '과거-현재-미래', 3),
  relationship('관계 스프레드', '연애/관계 심화 분석', 5),
  celticCross('켈틱 크로스', '가장 상세한 분석', 10);

  final String displayName;
  final String description;
  final int cardCount;

  const TarotSpreadType(this.displayName, this.description, this.cardCount);
}

/// 3카드 스프레드 포지션
enum ThreeCardPosition {
  past('과거', '지나간 영향과 원인'),
  present('현재', '현재 상황과 에너지'),
  future('미래', '다가올 가능성');

  final String displayName;
  final String description;

  const ThreeCardPosition(this.displayName, this.description);
}

/// 관계 스프레드 포지션
enum RelationshipPosition {
  myFeelings('나의 마음', '당신의 진심'),
  theirFeelings('상대의 마음', '상대방의 감정'),
  pastConnection('과거의 연결', '함께한 역사'),
  currentDynamic('현재 관계', '지금의 에너지'),
  futureOutlook('미래 전망', '관계의 방향');

  final String displayName;
  final String description;

  const RelationshipPosition(this.displayName, this.description);
}

/// 켈틱 크로스 포지션
enum CelticCrossPosition {
  presentSituation('현재 상황', '지금 당신이 있는 곳'),
  challenge('도전/십자가', '극복해야 할 것'),
  distantPast('먼 과거', '상황의 뿌리'),
  recentPast('최근 과거', '최근의 영향'),
  possibleOutcome('가능한 미래', '현재 경로의 결과'),
  immediateFuture('가까운 미래', '곧 일어날 일'),
  yourApproach('당신의 접근', '당신의 태도와 행동'),
  externalInfluences('외부 영향', '주변 환경과 사람들'),
  hopesAndFears('희망과 두려움', '내면의 감정'),
  finalOutcome('최종 결과', '궁극적인 결과');

  final String displayName;
  final String description;

  const CelticCrossPosition(this.displayName, this.description);
}

/// 타로 덱 타입
enum TarotDeckType {
  riderWaite('rider_waite', 'Rider-Waite', '가장 전통적인 타로'),
  thoth('thoth', 'Thoth', '심리학적 접근'),
  ancientItalian('ancient_italian', 'Ancient Italian', '고전적 해석'),
  afterTarot('after_tarot', 'After Tarot', '미래 중심'),
  beforeTarot('before_tarot', 'Before Tarot', '과거 중심'),
  goldenDawnCicero('golden_dawn_cicero', 'Golden Dawn Cicero', '신비주의'),
  goldenDawnWang('golden_dawn_wang', 'Golden Dawn Wang', '동양적 해석'),
  grandEtteilla('grand_etteilla', 'Grand Etteilla', '프랑스 전통');

  final String path;
  final String displayName;
  final String description;

  const TarotDeckType(this.path, this.displayName, this.description);
}

/// 카드 카테고리
enum CardCategory {
  major('major', '메이저 아르카나'),
  cups('cups', '컵'),
  wands('wands', '완드'),
  swords('swords', '소드'),
  pentacles('pentacles', '펜타클');

  final String path;
  final String displayName;

  const CardCategory(this.path, this.displayName);
}

/// 타로 카드 모델
class TarotCard {
  final TarotDeckType deckType;
  final CardCategory category;
  final int number;
  final String cardName;
  final String cardNameKr;
  final bool isReversed;
  final String? positionKey; // 스프레드에서의 위치 키
  final String? positionMeaning; // 해당 위치에서의 의미

  TarotCard({
    required this.deckType,
    required this.category,
    required this.number,
    required this.cardName,
    required this.cardNameKr,
    required this.isReversed,
    this.positionKey,
    this.positionMeaning,
  });

  /// 카드 이미지 경로 생성
  String get imagePath {
    final basePath = 'assets/images/tarot/decks/${deckType.path}/${category.path}/';

    if (category == CardCategory.major) {
      // 메이저 아르카나: 00_fool.jpg, 01_magician.jpg 등
      final fileName = '${number.toString().padLeft(2, '0')}_${_getCardFileName()}.jpg';
      return basePath + fileName;
    } else {
      // 마이너 아르카나
      final suitName = category.path; // cups, wands, swords, pentacles

      // Court 카드 (11-14)는 이름으로 저장됨
      if (number >= 11 && number <= 14) {
        final courtName = _getCourtCardName(number);
        final fileName = '${courtName}_of_$suitName.jpg';
        return basePath + fileName;
      } else {
        // 숫자 카드 (1-10): 01_of_cups.jpg, 02_of_cups.jpg 등
        final fileName = '${number.toString().padLeft(2, '0')}_of_$suitName.jpg';
        return basePath + fileName;
      }
    }
  }

  /// Court 카드 이름 반환 (11=Page, 12=Knight, 13=Queen, 14=King)
  String _getCourtCardName(int courtNumber) {
    switch (courtNumber) {
      case 11:
        return 'page';
      case 12:
        return 'knight';
      case 13:
        return 'queen';
      case 14:
        return 'king';
      default:
        return 'unknown';
    }
  }

  /// 메이저 아르카나 파일명 생성
  String _getCardFileName() {
    final majorCardNames = {
      0: 'fool',
      1: 'magician',
      2: 'high_priestess',
      3: 'empress',
      4: 'emperor',
      5: 'hierophant',
      6: 'lovers',
      7: 'chariot',
      8: 'strength',
      9: 'hermit',
      10: 'wheel_of_fortune',
      11: 'justice',
      12: 'hanged_man',
      13: 'death',
      14: 'temperance',
      15: 'devil',
      16: 'tower',
      17: 'star',
      18: 'moon',
      19: 'sun',
      20: 'judgement',
      21: 'world',
    };
    return majorCardNames[number] ?? 'unknown';
  }

  /// 카드의 전체 이름 (정방향/역방향 포함)
  String get fullName {
    final reversed = isReversed ? ' (역방향)' : '';
    return '$cardNameKr$reversed';
  }

  /// JSON 변환
  Map<String, dynamic> toJson() => {
    'deckType': deckType.path,
    'category': category.path,
    'number': number,
    'cardName': cardName,
    'cardNameKr': cardNameKr,
    'isReversed': isReversed,
    'positionKey': positionKey,
    'positionMeaning': positionMeaning,
  };

  factory TarotCard.fromJson(Map<String, dynamic> json) {
    return TarotCard(
      deckType: TarotDeckType.values.firstWhere(
        (e) => e.path == json['deckType'],
        orElse: () => TarotDeckType.riderWaite,
      ),
      category: CardCategory.values.firstWhere(
        (e) => e.path == json['category'],
        orElse: () => CardCategory.major,
      ),
      number: json['number'] as int,
      cardName: json['cardName'] as String,
      cardNameKr: json['cardNameKr'] as String,
      isReversed: json['isReversed'] as bool,
      positionKey: json['positionKey'] as String?,
      positionMeaning: json['positionMeaning'] as String?,
    );
  }
}

/// 타로 스프레드 결과
class TarotSpreadResult {
  final TarotSpreadType spreadType;
  final List<TarotCard> cards;
  final String question;
  final DateTime timestamp;
  final String overallInterpretation;
  final Map<String, String> positionInterpretations;
  final bool isBlurred;  // ✅ 블러 상태
  final List<String> blurredSections;  // ✅ 블러 처리된 섹션 목록

  TarotSpreadResult({
    required this.spreadType,
    required this.cards,
    required this.question,
    required this.timestamp,
    required this.overallInterpretation,
    required this.positionInterpretations,
    this.isBlurred = false,  // ✅ 기본값: false
    this.blurredSections = const [],  // ✅ 기본값: 빈 배열
  });

  /// copyWith 메서드 (블러 해제용)
  TarotSpreadResult copyWith({
    TarotSpreadType? spreadType,
    List<TarotCard>? cards,
    String? question,
    DateTime? timestamp,
    String? overallInterpretation,
    Map<String, String>? positionInterpretations,
    bool? isBlurred,
    List<String>? blurredSections,
  }) {
    return TarotSpreadResult(
      spreadType: spreadType ?? this.spreadType,
      cards: cards ?? this.cards,
      question: question ?? this.question,
      timestamp: timestamp ?? this.timestamp,
      overallInterpretation: overallInterpretation ?? this.overallInterpretation,
      positionInterpretations: positionInterpretations ?? this.positionInterpretations,
      isBlurred: isBlurred ?? this.isBlurred,
      blurredSections: blurredSections ?? this.blurredSections,
    );
  }

  /// JSON 변환
  Map<String, dynamic> toJson() => {
    'spreadType': spreadType.name,
    'cards': cards.map((c) => c.toJson()).toList(),
    'question': question,
    'timestamp': timestamp.toIso8601String(),
    'overallInterpretation': overallInterpretation,
    'positionInterpretations': positionInterpretations,
    'isBlurred': isBlurred,  // ✅ 블러 상태
    'blurredSections': blurredSections,  // ✅ 블러 섹션
  };

  factory TarotSpreadResult.fromJson(Map<String, dynamic> json) {
    return TarotSpreadResult(
      spreadType: TarotSpreadType.values.firstWhere(
        (e) => e.name == json['spreadType'],
        orElse: () => TarotSpreadType.single,
      ),
      cards: (json['cards'] as List)
          .map((c) => TarotCard.fromJson(c as Map<String, dynamic>))
          .toList(),
      question: json['question'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      overallInterpretation: json['overallInterpretation'] as String,
      positionInterpretations: Map<String, String>.from(
        json['positionInterpretations'] as Map,
      ),
      isBlurred: json['isBlurred'] as bool? ?? false,  // ✅ 블러 상태
      blurredSections: (json['blurredSections'] as List?)?.cast<String>() ?? [],  // ✅ 블러 섹션
    );
  }
}