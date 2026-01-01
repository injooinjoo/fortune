import 'dart:math';

/// 단일 로또 세트 (6개 번호)
class LottoNumberSet {
  /// 6개의 로또 번호 (정렬됨, 1-45)
  final List<int> numbers;

  /// 각 번호별 오행 속성
  final List<String> numberElements;

  const LottoNumberSet({
    required this.numbers,
    required this.numberElements,
  });

  /// 공개된 번호들 (5개) - 광고 전
  List<int> get visibleNumbers => numbers.sublist(0, 5);

  /// 잠긴 번호 (1개 - 광고 후 공개)
  int get lockedNumber => numbers[5];
}

/// 로또 번호 결과 모델
///
/// 6개 번호 중 5개는 바로 공개, 1개는 광고 후 공개
class LottoResult {
  /// 6개의 로또 번호 (정렬됨, 1-45) - 하위 호환성을 위해 유지 (1세트일 때만)
  final List<int> numbers;

  /// 각 번호별 오행 속성 - 하위 호환성을 위해 유지
  final List<String> numberElements;

  /// 오늘의 운세 메시지
  final String fortuneMessage;

  /// 생성 시간
  final DateTime generatedAt;

  /// 여러 세트의 번호 (gameCount > 1일 때 사용)
  final List<LottoNumberSet> sets;

  const LottoResult({
    required this.numbers,
    required this.numberElements,
    required this.fortuneMessage,
    required this.generatedAt,
    this.sets = const [],
  });

  /// 공개된 번호들 (5개) - 하위 호환성 (1세트일 때)
  List<int> get visibleNumbers => numbers.sublist(0, 5);

  /// 잠긴 번호 (1개 - 광고 후 공개) - 하위 호환성 (1세트일 때)
  int get lockedNumber => numbers[5];

  /// 게임 수 (세트 수)
  int get gameCount => sets.isEmpty ? 1 : sets.length;
}

/// 행운의 구매 장소 추천
class LuckyLocation {
  /// 행운의 방위 (동/서/남/북)
  final String direction;

  /// 방위 설명
  final String directionDescription;

  /// 추천 판매점 유형
  final String shopType;

  /// 판매점 추천 이유
  final String shopReason;

  /// 행운의 색상 (판매점 근처 간판 색상)
  final String luckySignColor;

  /// 현재 위치 기준 추천 메시지
  final String locationMessage;

  const LuckyLocation({
    required this.direction,
    required this.directionDescription,
    required this.shopType,
    required this.shopReason,
    required this.luckySignColor,
    required this.locationMessage,
  });
}

/// 최적 구매 타이밍 추천
class LuckyTiming {
  /// 행운의 요일
  final String luckyDay;

  /// 요일 선택 이유
  final String dayReason;

  /// 행운의 시간대
  final String luckyTimeSlot;

  /// 시간대 선택 이유
  final String timeReason;

  /// 이번 주 추천 구매일
  final DateTime recommendedDate;

  /// 피해야 할 시간대
  final String avoidTimeSlot;

  const LuckyTiming({
    required this.luckyDay,
    required this.dayReason,
    required this.luckyTimeSlot,
    required this.timeReason,
    required this.recommendedDate,
    required this.avoidTimeSlot,
  });
}

/// 사주 기반 조언
class SajuAdvice {
  /// 주요 오행 속성
  final String dominantElement;

  /// 오행 설명
  final String elementDescription;

  /// 행운의 색상
  final String luckyColor;

  /// 행운의 숫자대 (1-10, 11-20 등)
  final String luckyNumberRange;

  /// 피해야 할 숫자대
  final String avoidNumberRange;

  /// 전체 조언 메시지
  final String adviceMessage;

  /// 오늘의 재물운 점수 (1-100)
  final int wealthScore;

  const SajuAdvice({
    required this.dominantElement,
    required this.elementDescription,
    required this.luckyColor,
    required this.luckyNumberRange,
    required this.avoidNumberRange,
    required this.adviceMessage,
    required this.wealthScore,
  });
}

/// 연금복권 720+ 결과 모델
///
/// 조 번호(1~5)는 블러 처리, 6자리 번호는 바로 공개
class PensionLotteryResult {
  /// 조 번호 (1-5) - 광고 후 공개
  final int groupNumber;

  /// 6자리 번호 (각 자리 0-9)
  final List<int> numbers;

  /// 연금복권 운세 메시지
  final String fortuneMessage;

  /// 생성 시간
  final DateTime generatedAt;

  const PensionLotteryResult({
    required this.groupNumber,
    required this.numbers,
    required this.fortuneMessage,
    required this.generatedAt,
  });

  /// 6자리 번호를 문자열로 변환
  String get numbersString => numbers.join('');
}

/// 전체 로또 운세 결과
class LottoFortuneResult {
  final LottoResult lottoResult;
  final PensionLotteryResult pensionResult;
  final LuckyLocation luckyLocation;
  final LuckyTiming luckyTiming;
  final SajuAdvice sajuAdvice;

  const LottoFortuneResult({
    required this.lottoResult,
    required this.pensionResult,
    required this.luckyLocation,
    required this.luckyTiming,
    required this.sajuAdvice,
  });
}

/// 로또 번호 자동 생성 서비스
///
/// 사주 정보를 기반으로 1세트(6개)의 로또 번호와
/// 구매 장소, 타이밍, 사주 조언을 생성합니다.
class LottoNumberGenerator {
  // 오행별 숫자 범위
  static const Map<String, List<int>> _elementNumbers = {
    '목(木)': [3, 8, 13, 18, 23, 28, 33, 38, 43], // 3, 8 계열
    '화(火)': [2, 7, 12, 17, 22, 27, 32, 37, 42], // 2, 7 계열
    '토(土)': [5, 10, 15, 20, 25, 30, 35, 40, 45], // 5, 10 계열
    '금(金)': [4, 9, 14, 19, 24, 29, 34, 39, 44], // 4, 9 계열
    '수(水)': [1, 6, 11, 16, 21, 26, 31, 36, 41], // 1, 6 계열
  };

  // 오행별 색상
  static const Map<String, String> _elementColors = {
    '목(木)': '청색/녹색',
    '화(火)': '적색/주황색',
    '토(土)': '황색/갈색',
    '금(金)': '백색/금색',
    '수(水)': '흑색/남색',
  };

  // 오행별 방위
  static const Map<String, String> _elementDirections = {
    '목(木)': '동쪽',
    '화(火)': '남쪽',
    '토(土)': '중앙',
    '금(金)': '서쪽',
    '수(水)': '북쪽',
  };

  // 운세 메시지
  static const List<String> _fortuneMessages = [
    '오늘은 재물운이 상승하는 날입니다. 직감을 믿어보세요.',
    '사주의 기운이 밝습니다. 작은 행운이 큰 행운으로 이어질 수 있습니다.',
    '오행의 조화가 좋은 날입니다. 긍정적인 마음으로 구매해보세요.',
    '인내심을 갖고 꾸준히 도전하면 좋은 결과가 있을 것입니다.',
    '오늘의 기운이 안정적입니다. 차분한 마음으로 번호를 선택하세요.',
  ];

  // 판매점 유형
  static const List<Map<String, String>> _shopTypes = [
    {'type': '편의점', 'reason': '빠른 기운이 도움됩니다'},
    {'type': '복권 전문점', 'reason': '집중된 복 기운이 모여 있습니다'},
    {'type': '마트', 'reason': '풍요로운 기운이 도움됩니다'},
    {'type': '주유소', 'reason': '활력 있는 기운이 도움됩니다'},
    {'type': '길가 판매점', 'reason': '유동적인 기운이 도움됩니다'},
  ];

  // 연금복권 운세 메시지
  static const List<String> _pensionMessages = [
    '매월 700만원의 연금이 당신을 기다리고 있습니다.',
    '안정적인 미래를 위한 행운의 번호입니다.',
    '꾸준한 행복을 가져다 줄 번호입니다.',
    '20년간의 풍요로운 삶이 기다립니다.',
    '사주의 기운이 연금복권에 유리합니다.',
  ];

  /// 사주 기반 로또 운세 전체 생성
  ///
  /// [gameCount]: 생성할 게임 수 (1-5, 기본값 1)
  static LottoFortuneResult generate({
    required DateTime birthDate,
    String? birthTime,
    String? gender,
    String? currentLocation,
    int gameCount = 1,
  }) {
    final now = DateTime.now();
    // gameCount 범위 제한 (1-5)
    final validGameCount = gameCount.clamp(1, 5);

    // 시드 계산
    final seed = _calculateSeed(
      birthDate: birthDate,
      birthTime: birthTime,
      gender: gender,
      date: now,
    );

    // 주요 오행 계산
    final dominantElement = _calculateDominantElement(birthDate, birthTime);

    // 로또 번호 생성 (여러 세트)
    final lottoResult = _generateLottoResult(
      seed,
      dominantElement,
      now,
      gameCount: validGameCount,
    );

    // 행운의 장소 생성
    final luckyLocation = _generateLuckyLocation(
      dominantElement,
      seed,
      currentLocation,
    );

    // 최적 타이밍 생성
    final luckyTiming = _generateLuckyTiming(dominantElement, now);

    // 사주 조언 생성
    final sajuAdvice = _generateSajuAdvice(dominantElement, seed);

    // 연금복권 생성
    final pensionResult = _generatePensionLottery(seed, now);

    return LottoFortuneResult(
      lottoResult: lottoResult,
      pensionResult: pensionResult,
      luckyLocation: luckyLocation,
      luckyTiming: luckyTiming,
      sajuAdvice: sajuAdvice,
    );
  }

  /// 꿈해석 결과 기반 로또 운세 생성
  ///
  /// [dreamResult]: 꿈해석 API 결과 (symbols, sentiment, luckyElements 포함)
  /// [birthDate]: 생년월일 (선택사항 - 더 정확한 번호 생성에 사용)
  static LottoFortuneResult generateFromDream({
    required Map<String, dynamic> dreamResult,
    DateTime? birthDate,
    String? birthTime,
    String? gender,
    String? currentLocation,
    int gameCount = 1,
  }) {
    final now = DateTime.now();
    final validGameCount = gameCount.clamp(1, 5);

    // 꿈 상징에서 시드 추출
    final dreamSeed = _calculateDreamSeed(dreamResult);

    // 꿈 감정에서 오행 매핑
    final dreamElement = _getDreamElement(dreamResult);

    // 사주 정보가 있으면 결합
    int combinedSeed = dreamSeed;
    String dominantElement = dreamElement;

    if (birthDate != null) {
      final sajuSeed = _calculateSeed(
        birthDate: birthDate,
        birthTime: birthTime,
        gender: gender,
        date: now,
      );
      // 꿈 시드와 사주 시드 결합
      combinedSeed = (dreamSeed * 31 + sajuSeed) % 1000000000;

      // 오행도 결합 (꿈 우선, 사주 보조)
      final sajuElement = _calculateDominantElement(birthDate, birthTime);
      dominantElement = _combineElements(dreamElement, sajuElement);
    }

    // 로또 번호 생성
    final lottoResult = _generateLottoResult(
      combinedSeed,
      dominantElement,
      now,
      gameCount: validGameCount,
    );

    // 꿈 기반 행운의 장소 생성
    final luckyLocation = _generateDreamLuckyLocation(
      dreamResult,
      dominantElement,
      combinedSeed,
      currentLocation,
    );

    // 최적 타이밍 생성
    final luckyTiming = _generateLuckyTiming(dominantElement, now);

    // 꿈 기반 조언 생성
    final sajuAdvice = _generateDreamAdvice(dreamResult, dominantElement);

    // 연금복권 생성
    final pensionResult = _generatePensionLottery(combinedSeed, now);

    return LottoFortuneResult(
      lottoResult: lottoResult,
      pensionResult: pensionResult,
      luckyLocation: luckyLocation,
      luckyTiming: luckyTiming,
      sajuAdvice: sajuAdvice,
    );
  }

  /// 꿈 상징에서 시드 계산
  static int _calculateDreamSeed(Map<String, dynamic> dreamResult) {
    int seed = DateTime.now().millisecondsSinceEpoch % 100000;

    // 꿈 내용에서 해시 생성
    final dream = dreamResult['dream']?.toString() ?? '';
    for (int i = 0; i < dream.length; i++) {
      seed = (seed * 31 + dream.codeUnitAt(i)) % 1000000000;
    }

    // 상징들에서 추가 시드
    final symbols = dreamResult['symbols'] as List? ?? [];
    for (final symbol in symbols) {
      final str = symbol.toString();
      for (int i = 0; i < str.length; i++) {
        seed = (seed * 17 + str.codeUnitAt(i)) % 1000000000;
      }
    }

    return seed;
  }

  /// 꿈 감정에서 오행 매핑
  static String _getDreamElement(Map<String, dynamic> dreamResult) {
    final sentiment = dreamResult['sentiment']?.toString() ?? 'neutral';
    final symbols = dreamResult['symbols'] as List? ?? [];

    // 상징 키워드로 오행 판단
    final symbolStr = symbols.join(' ').toLowerCase();

    if (symbolStr.contains('물') ||
        symbolStr.contains('바다') ||
        symbolStr.contains('강') ||
        symbolStr.contains('비')) {
      return '수(水)';
    }
    if (symbolStr.contains('불') ||
        symbolStr.contains('태양') ||
        symbolStr.contains('빛')) {
      return '화(火)';
    }
    if (symbolStr.contains('나무') ||
        symbolStr.contains('숲') ||
        symbolStr.contains('꽃') ||
        symbolStr.contains('초록')) {
      return '목(木)';
    }
    if (symbolStr.contains('금') ||
        symbolStr.contains('돈') ||
        symbolStr.contains('보석') ||
        symbolStr.contains('은')) {
      return '금(金)';
    }
    if (symbolStr.contains('땅') ||
        symbolStr.contains('산') ||
        symbolStr.contains('흙')) {
      return '토(土)';
    }

    // 감정으로 오행 매핑
    switch (sentiment) {
      case 'positive':
        return '목(木)'; // 성장, 발전
      case 'negative':
        return '수(水)'; // 정화, 흐름
      default:
        return '토(土)'; // 안정, 균형
    }
  }

  /// 두 오행 결합 (첫 번째 우선)
  static String _combineElements(String primary, String secondary) {
    // 상생 관계면 primary 유지, 상극이면 secondary 반영
    const shengMap = {
      '목(木)': '화(火)',
      '화(火)': '토(土)',
      '토(土)': '금(金)',
      '금(金)': '수(水)',
      '수(水)': '목(木)',
    };

    if (shengMap[primary] == secondary) {
      // 상생 - primary 강화
      return primary;
    }
    // 그 외는 primary 유지
    return primary;
  }

  /// 꿈 기반 행운의 장소 생성
  static LuckyLocation _generateDreamLuckyLocation(
    Map<String, dynamic> dreamResult,
    String element,
    int seed,
    String? currentLocation,
  ) {
    final symbols = dreamResult['symbols'] as List? ?? [];
    final symbolStr = symbols.join(' ');

    // 꿈 상징에 따른 장소 추천
    String placeType;
    String direction;

    if (symbolStr.contains('물') || symbolStr.contains('바다')) {
      placeType = '물가 근처 (강변, 호수, 분수대 근처)';
      direction = '북쪽';
    } else if (symbolStr.contains('산') || symbolStr.contains('숲')) {
      placeType = '자연 근처 (공원, 산책로, 녹지대)';
      direction = '동쪽';
    } else if (symbolStr.contains('금') || symbolStr.contains('돈')) {
      placeType = '금융가 근처 (은행, 증권사 인근)';
      direction = '서쪽';
    } else if (symbolStr.contains('불') || symbolStr.contains('태양')) {
      placeType = '밝고 활기찬 곳 (번화가, 대형마트)';
      direction = '남쪽';
    } else {
      // 기본: 오행 기반
      return _generateLuckyLocation(element, seed, currentLocation);
    }

    // 최적 구매처 추천
    final storeTypes = [
      {'type': '편의점', 'reason': '빠른 기운이 도움됩니다'},
      {'type': '복권 전문점', 'reason': '집중된 복 기운이 모여 있습니다'},
      {'type': '대형마트 복권 코너', 'reason': '풍요로운 기운이 도움됩니다'},
      {'type': '로또 명당', 'reason': '행운의 기운이 강합니다'},
    ];
    final storeIndex = seed % storeTypes.length;
    final store = storeTypes[storeIndex];

    // 꿈 상징 기반 방위 설명
    final symbolName = symbols.isNotEmpty ? symbols.first.toString() : '상징';
    final directionDesc = '꿈 속 "$symbolName"이(가) $direction 방향의 기운과 연결됩니다. $placeType에서 구매하세요.';

    // 오행 기반 간판 색상
    final luckyColor = _elementColors[element] ?? '황색';

    return LuckyLocation(
      direction: direction,
      directionDescription: directionDesc,
      shopType: store['type']!,
      shopReason: store['reason']!,
      luckySignColor: luckyColor,
      locationMessage: '$placeType의 $direction 방향이 유리합니다',
    );
  }

  /// 꿈 기반 조언 생성
  static SajuAdvice _generateDreamAdvice(
    Map<String, dynamic> dreamResult,
    String element,
  ) {
    final sentiment = dreamResult['sentiment']?.toString() ?? 'neutral';
    final symbols = dreamResult['symbols'] as List? ?? [];

    String advice;
    String luckyColor;
    String luckyNumber;

    switch (sentiment) {
      case 'positive':
        advice = '길몽입니다! 꿈의 좋은 기운을 담아 복권을 구매하세요. '
            '${symbols.isNotEmpty ? '"${symbols.first}" 상징이 행운을 가져다줄 것입니다.' : ''}';
        luckyColor = '금색, 노란색';
        luckyNumber = '3, 8 계열';
        break;
      case 'negative':
        advice = '꿈의 경고를 긍정적으로 전환하세요. '
            '조심스럽게 접근하되, 새로운 시작의 기운으로 바꿀 수 있습니다.';
        luckyColor = '파란색, 검은색';
        luckyNumber = '1, 6 계열';
        break;
      default:
        advice = '평화로운 꿈입니다. 안정적인 마음으로 구매하면 좋은 결과가 있을 것입니다.';
        luckyColor = '노란색, 갈색';
        luckyNumber = '5, 10 계열';
    }

    // 꿈 감정에 따른 피해야 할 번호대와 재물운 점수
    String avoidNumber;
    int wealthScore;

    switch (sentiment) {
      case 'positive':
        avoidNumber = '4, 9 계열 (상극)';
        wealthScore = 75 + (DateTime.now().millisecondsSinceEpoch % 20); // 75-94
        break;
      case 'negative':
        avoidNumber = '2, 7 계열 (상극)';
        wealthScore = 50 + (DateTime.now().millisecondsSinceEpoch % 25); // 50-74
        break;
      default:
        avoidNumber = '없음 (균형 잡힌 상태)';
        wealthScore = 60 + (DateTime.now().millisecondsSinceEpoch % 20); // 60-79
    }

    // 오행 설명
    String elementDesc;
    switch (element) {
      case '목(木)':
        elementDesc = '꿈에서 성장과 발전의 기운을 받았습니다.';
        break;
      case '화(火)':
        elementDesc = '꿈에서 열정과 활력의 기운을 받았습니다.';
        break;
      case '토(土)':
        elementDesc = '꿈에서 안정과 균형의 기운을 받았습니다.';
        break;
      case '금(金)':
        elementDesc = '꿈에서 결실과 재물의 기운을 받았습니다.';
        break;
      case '수(水)':
        elementDesc = '꿈에서 지혜와 직관의 기운을 받았습니다.';
        break;
      default:
        elementDesc = '꿈에서 균형 잡힌 기운을 받았습니다.';
    }

    return SajuAdvice(
      dominantElement: element,
      elementDescription: elementDesc,
      luckyColor: luckyColor,
      luckyNumberRange: luckyNumber,
      avoidNumberRange: avoidNumber,
      adviceMessage: advice,
      wealthScore: wealthScore,
    );
  }

  /// 시드 계산
  static int _calculateSeed({
    required DateTime birthDate,
    String? birthTime,
    String? gender,
    required DateTime date,
  }) {
    int seed = 0;

    // 생년월일 기반
    seed += birthDate.year * 10000;
    seed += birthDate.month * 100;
    seed += birthDate.day;

    // 시간 기반
    if (birthTime != null) {
      final timeIndex = _getTimeIndex(birthTime);
      seed += timeIndex * 1000;
    }

    // 성별 기반
    if (gender != null) {
      seed += gender == 'male' ? 7777 : 8888;
    }

    // 오늘 날짜 기반 (매일 다른 번호)
    seed += date.year * 1000;
    seed += date.month * 100;
    seed += date.day;

    return seed;
  }

  /// 시간대 인덱스 추출
  static int _getTimeIndex(String birthTime) {
    const timeMap = {
      '자시': 0, '축시': 1, '인시': 2, '묘시': 3,
      '진시': 4, '사시': 5, '오시': 6, '미시': 7,
      '신시': 8, '유시': 9, '술시': 10, '해시': 11,
    };

    for (final entry in timeMap.entries) {
      if (birthTime.contains(entry.key)) {
        return entry.value;
      }
    }
    return 0;
  }

  /// 주요 오행 계산
  static String _calculateDominantElement(DateTime birthDate, String? birthTime) {
    // 간단한 오행 계산 (실제로는 더 복잡한 사주 계산 필요)
    final yearElement = birthDate.year % 5;
    final monthElement = birthDate.month % 5;
    final dayElement = birthDate.day % 5;

    int timeElement = 0;
    if (birthTime != null) {
      timeElement = _getTimeIndex(birthTime) % 5;
    }

    final totalElement = (yearElement + monthElement + dayElement + timeElement) % 5;

    const elements = ['목(木)', '화(火)', '토(土)', '금(金)', '수(水)'];
    return elements[totalElement];
  }

  /// 로또 번호 생성 (여러 세트 지원)
  static LottoResult _generateLottoResult(
    int seed,
    String dominantElement,
    DateTime now, {
    int gameCount = 1,
  }) {
    final sets = <LottoNumberSet>[];

    // gameCount 만큼 세트 생성
    for (int setIndex = 0; setIndex < gameCount; setIndex++) {
      // 각 세트마다 다른 시드 사용
      final setSeed = seed + (setIndex * 12345);
      final random = Random(setSeed);
      final numbers = <int>{};

      // 오행 기반 선호 번호에서 2개 선택
      final preferredNumbers = _elementNumbers[dominantElement] ?? [];
      while (numbers.length < 2 && preferredNumbers.isNotEmpty) {
        final num = preferredNumbers[random.nextInt(preferredNumbers.length)];
        if (num >= 1 && num <= 45) {
          numbers.add(num);
        }
      }

      // 나머지 번호 랜덤 선택
      while (numbers.length < 6) {
        final num = random.nextInt(45) + 1;
        numbers.add(num);
      }

      final sortedNumbers = numbers.toList()..sort();

      // 각 번호의 오행 속성 계산
      final numberElements = sortedNumbers.map((n) {
        for (final entry in _elementNumbers.entries) {
          if (entry.value.contains(n)) {
            return entry.key;
          }
        }
        return '토(土)'; // 기본값
      }).toList();

      sets.add(LottoNumberSet(
        numbers: sortedNumbers,
        numberElements: numberElements,
      ));
    }

    // 운세 메시지 선택
    final messageSeed = seed % _fortuneMessages.length;
    final fortuneMessage = _fortuneMessages[messageSeed];

    // 첫 번째 세트를 기본값으로 (하위 호환성)
    final firstSet = sets.first;

    return LottoResult(
      numbers: firstSet.numbers,
      numberElements: firstSet.numberElements,
      fortuneMessage: fortuneMessage,
      generatedAt: now,
      sets: sets,
    );
  }

  /// 행운의 장소 생성
  static LuckyLocation _generateLuckyLocation(
    String dominantElement,
    int seed,
    String? currentLocation,
  ) {
    final random = Random(seed + 1234);

    // 오행 기반 방위
    final direction = _elementDirections[dominantElement] ?? '동쪽';
    final directionDesc = _getDirectionDescription(direction, dominantElement);

    // 판매점 유형
    final shopIndex = random.nextInt(_shopTypes.length);
    final shop = _shopTypes[shopIndex];

    // 간판 색상 (오행 기반)
    final luckyColor = _elementColors[dominantElement] ?? '황색';

    // 위치 기반 메시지
    final locationMsg = currentLocation != null
        ? '$currentLocation 기준 $direction 방향이 유리합니다'
        : '$direction 방향으로 이동해서 구매하세요';

    return LuckyLocation(
      direction: direction,
      directionDescription: directionDesc,
      shopType: shop['type']!,
      shopReason: shop['reason']!,
      luckySignColor: luckyColor,
      locationMessage: locationMsg,
    );
  }

  /// 방위 설명 생성
  static String _getDirectionDescription(String direction, String element) {
    return '$element 기운이 강한 $direction 방향에서 복권을 구매하면 행운이 따릅니다.';
  }

  /// 최적 타이밍 생성
  static LuckyTiming _generateLuckyTiming(String dominantElement, DateTime now) {
    // 오행과 상생하는 요일 찾기
    String luckyDay;
    String dayReason;

    switch (dominantElement) {
      case '목(木)':
        luckyDay = '목요일';
        dayReason = '목(木) 기운이 가장 강한 날입니다';
        break;
      case '화(火)':
        luckyDay = '화요일';
        dayReason = '화(火) 기운이 가장 강한 날입니다';
        break;
      case '토(土)':
        luckyDay = '토요일';
        dayReason = '토(土) 기운이 가장 강한 날입니다';
        break;
      case '금(金)':
        luckyDay = '금요일';
        dayReason = '금(金) 기운이 가장 강한 날입니다';
        break;
      case '수(水)':
        luckyDay = '수요일';
        dayReason = '수(水) 기운이 가장 강한 날입니다';
        break;
      default:
        luckyDay = '토요일';
        dayReason = '주말의 여유로운 기운이 도움됩니다';
    }

    // 시간대 추천
    String timeSlot;
    String timeReason;
    String avoidTime;

    final hour = now.hour;
    if (hour < 12) {
      timeSlot = '오전 10시 ~ 12시';
      timeReason = '양의 기운이 상승하는 시간대입니다';
      avoidTime = '새벽 2시 ~ 5시';
    } else if (hour < 18) {
      timeSlot = '오후 2시 ~ 4시';
      timeReason = '안정적인 기운이 흐르는 시간대입니다';
      avoidTime = '자정 ~ 새벽 3시';
    } else {
      timeSlot = '저녁 7시 ~ 9시';
      timeReason = '하루의 기운이 정리되는 시간대입니다';
      avoidTime = '새벽 1시 ~ 4시';
    }

    // 이번 주 추천 구매일 계산
    final targetWeekday = _getTargetWeekday(luckyDay);
    var recommendedDate = now;
    while (recommendedDate.weekday != targetWeekday) {
      recommendedDate = recommendedDate.add(const Duration(days: 1));
    }

    return LuckyTiming(
      luckyDay: luckyDay,
      dayReason: dayReason,
      luckyTimeSlot: timeSlot,
      timeReason: timeReason,
      recommendedDate: recommendedDate,
      avoidTimeSlot: avoidTime,
    );
  }

  /// 요일 문자열을 weekday 숫자로 변환
  static int _getTargetWeekday(String dayName) {
    switch (dayName) {
      case '월요일': return 1;
      case '화요일': return 2;
      case '수요일': return 3;
      case '목요일': return 4;
      case '금요일': return 5;
      case '토요일': return 6;
      case '일요일': return 7;
      default: return 6;
    }
  }

  /// 사주 조언 생성
  static SajuAdvice _generateSajuAdvice(String dominantElement, int seed) {
    final random = Random(seed + 5678);

    // 오행 설명
    String elementDesc;
    String luckyRange;
    String avoidRange;

    switch (dominantElement) {
      case '목(木)':
        elementDesc = '성장과 발전의 기운이 강합니다. 새로운 시작에 유리한 사주입니다.';
        luckyRange = '3, 8번대 (3, 8, 13, 18, 23, 28, 33, 38, 43)';
        avoidRange = '4, 9번대';
        break;
      case '화(火)':
        elementDesc = '열정과 활력의 기운이 강합니다. 적극적인 행동이 유리합니다.';
        luckyRange = '2, 7번대 (2, 7, 12, 17, 22, 27, 32, 37, 42)';
        avoidRange = '1, 6번대';
        break;
      case '토(土)':
        elementDesc = '안정과 중용의 기운이 강합니다. 꾸준함이 행운을 부릅니다.';
        luckyRange = '5, 10번대 (5, 10, 15, 20, 25, 30, 35, 40, 45)';
        avoidRange = '3, 8번대';
        break;
      case '금(金)':
        elementDesc = '결실과 수확의 기운이 강합니다. 재물운이 상승하는 시기입니다.';
        luckyRange = '4, 9번대 (4, 9, 14, 19, 24, 29, 34, 39, 44)';
        avoidRange = '2, 7번대';
        break;
      case '수(水)':
        elementDesc = '지혜와 유연성의 기운이 강합니다. 직감을 믿으세요.';
        luckyRange = '1, 6번대 (1, 6, 11, 16, 21, 26, 31, 36, 41)';
        avoidRange = '5, 10번대';
        break;
      default:
        elementDesc = '균형 잡힌 기운입니다.';
        luckyRange = '모든 번호대';
        avoidRange = '없음';
    }

    // 행운 색상
    final luckyColor = _elementColors[dominantElement] ?? '황색';

    // 재물운 점수 (50-95 사이)
    final wealthScore = 50 + random.nextInt(46);

    // 조언 메시지
    final adviceMessage = '오늘의 $dominantElement 기운을 잘 활용하세요. '
        '$luckyColor 계열의 물건이나 옷을 착용하면 운이 상승합니다.';

    return SajuAdvice(
      dominantElement: dominantElement,
      elementDescription: elementDesc,
      luckyColor: luckyColor,
      luckyNumberRange: luckyRange,
      avoidNumberRange: avoidRange,
      adviceMessage: adviceMessage,
      wealthScore: wealthScore,
    );
  }

  /// 연금복권 720+ 번호 생성
  static PensionLotteryResult _generatePensionLottery(int seed, DateTime now) {
    final random = Random(seed + 720);

    // 조 번호 (1-5)
    final groupNumber = random.nextInt(5) + 1;

    // 6자리 번호 (각 자리 0-9)
    final numbers = List.generate(6, (_) => random.nextInt(10));

    // 운세 메시지
    final messageIndex = random.nextInt(_pensionMessages.length);
    final fortuneMessage = _pensionMessages[messageIndex];

    return PensionLotteryResult(
      groupNumber: groupNumber,
      numbers: numbers,
      fortuneMessage: fortuneMessage,
      generatedAt: now,
    );
  }

  /// 번호 색상 반환 (로또 공식 색상)
  static int getNumberColor(int number) {
    if (number <= 10) return 0xFFFFC107; // 1-10: 노랑
    if (number <= 20) return 0xFF2196F3; // 11-20: 파랑
    if (number <= 30) return 0xFFE91E63; // 21-30: 빨강
    if (number <= 40) return 0xFF9E9E9E; // 31-40: 회색
    return 0xFF4CAF50; // 41-45: 초록
  }

  /// 번호 색상 이름 반환
  static String getNumberColorName(int number) {
    if (number <= 10) return '노랑';
    if (number <= 20) return '파랑';
    if (number <= 30) return '빨강';
    if (number <= 40) return '회색';
    return '초록';
  }
}
