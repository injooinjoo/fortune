/// 영혼 시스템 비율 정의
/// 무료 운세는 영혼을 획득하고, 프리미엄 운세는 영혼을 소비합니다.
class SoulRates {
  // 영혼을 획득하는 무료 운세 (양수)
  static const Map<String, int> earnRates = {
    // 기본 운세 (1-2 영혼 획득)
    'daily': 1,
    'daily_calendar': 1,  // DB 저장 값 alias
    'today': 1,
    'tomorrow': 1,
    'lucky-color': 1,
    'lucky-number': 1,
    'lucky-food': 1,
    'lucky-outfit': 1,
    'lucky-items': 1,
    'fortune-cookie': 1,
    'birthstone': 2,
    'blood-type': 2,
    'zodiac-animal': 2,
    'zodiac': 2,
    
    // 중급 운세 (3-5 영혼 획득)
    'love': 3,
    'career': 3,
    'wealth': 3,
    'health': 3,
    'compatibility': 4,
    'tarot': 4,
    'dream': 3,
    'biorhythm': 3,
    'mbti': 3,
    'personality': 3,
    'personality-dna': 4,
    'weekly': 4,
    'monthly': 5,
    'birth-season': 3,
    'birthdate': 3,
    'avoid-people': 2,
    'lucky-place': 2,
    'lucky-series': 3,
    'lucky-baseball': 2,
    'lucky-golf': 2,
    'lucky-tennis': 2,
    'lucky-cycling': 2,
    'lucky-running': 2,
    'lucky-hiking': 2,
    'lucky-fishing': 2,
    'lucky-swim': 2,
    'lucky-fitness': 2,
    'lucky-yoga': 2,
    'wish': 3,
    'talisman': 3,
    'talent': 2,
    'naming': 3,  // 작명 운세

    // 이사운 (무료로 변경됨)
    'moving': 3,
    'moving-date': 3};

  // 영혼을 소비하는 프리미엄 운세 (음수)
  static const Map<String, int> consumeRates = {
    // 프리미엄 운세 (10-20 영혼 소비)
    'saju': -15,
    'traditional-saju': -15,
    'traditional_saju': -15,  // DB 저장 값 alias
    'traditional-unified': -15,
    'saju-psychology': -12,
    'tojeong': -15,
    'past-life': -18,
    'destiny': -20,
    'marriage': -15,
    'couple-match': -12,
    'chemistry': -10,
    'ex-lover': -12,
    'ex_lover': -12,  // DB 저장 값 alias
    'blind-date': -10,
    'blind_date': -10,  // DB 저장 값 alias
    'celebrity-match': -10,
    'traditional-compatibility': -15,
    'palmistry': -12,
    'physiognomy': -15,
    'face-reading': -15,
    'timeline': -15,
    'lucky-exam': -10,
    'exam': -10,  // DB 저장 값 alias

    // 울트라 프리미엄 운세 (30-50 영혼 소비)
    'startup': -30,
    'business': -35,
    'lucky-investment': -40,
    'lucky-realestate': -35,
    'lucky-stock': -35,
    'lucky-crypto': -35,
    'lucky-sidejob': -30,
    'celebrity': -30,
    'network-report': -30,
    'five-blessings': -35,
    'yearly': -50,
    'new-year': -20,
    'lucky-lottery': -30,
    'employment': -25,
    'salpuli': -20,
    'health-document': -3};  // 건강검진표/처방전/진단서 분석

  // 특별 조건부 운세
  static const Map<String, dynamic> conditionalRates = {
    'hourly': {
      'freeCount': 3,
      'freeAmount': 1,
      'paidAmount': null}};

  /// 운세 타입에 따른 영혼 양 반환
  /// 양수: 획득, 음수: 소비, 0: 변화 없음
  static int getSoulAmount(String fortuneType) {
    // 먼저 획득 목록에서 확인
    if (earnRates.containsKey(fortuneType)) {
      return earnRates[fortuneType]!;
    }
    
    // 소비 목록에서 확인
    if (consumeRates.containsKey(fortuneType)) {
      return consumeRates[fortuneType]!;
    }
    
    // 조건부 운세는 별도 처리 필요
    if (conditionalRates.containsKey(fortuneType)) {
      return 0; // 조건부는 별도 로직으로 처리
    }
    
    // 정의되지 않은 운세는 기본값 1 획득
    return 1;
  }

  /// 프리미엄 운세인지 확인
  static bool isPremiumFortune(String fortuneType) {
    return consumeRates.containsKey(fortuneType);
  }

  /// 무료 운세인지 확인
  static bool isFreeFortune(String fortuneType) {
    return earnRates.containsKey(fortuneType);
  }

  /// 영혼 액션 타입
  static SoulActionType getSoulActionType(String fortuneType) {
    if (earnRates.containsKey(fortuneType)) {
      return SoulActionType.earn;
    } else if (consumeRates.containsKey(fortuneType)) {
      return SoulActionType.consume;
    } else if (conditionalRates.containsKey(fortuneType)) {
      return SoulActionType.conditional;
    }
    return SoulActionType.earn; // 기본값
  }

  /// 운세 설명 텍스트 생성
  static String getActionDescription(String fortuneType) {
    final amount = getSoulAmount(fortuneType);
    if (amount > 0) {
      return '+$amount 영혼 획득';
    } else if (amount < 0) {
      return '${-amount} 영혼 필요';
    } else {
      return '조건부 운세';
    }
  }

  /// 운세 카테고리별 평균 영혼
  static int getCategoryAverage(String category) {
    switch (category) {
      case 'basic':
        return 1;
      case 'intermediate':
        return 3;
      case 'premium':
        return -15;
      case 'ultra':
        return -35;
      default:
        return 0;
    }
  }
}

/// 영혼 액션 타입
enum SoulActionType {
  
  
  earn,       // 영혼 획득
  consume,    // 영혼 소비
  conditional // 조건부
  
  
}

/// 영혼 거래 결과
class SoulTransaction {
  final String fortuneType;
  final int amount;
  final SoulActionType actionType;
  final DateTime timestamp;
  final int balanceBefore;
  final int balanceAfter;

  SoulTransaction({
    required this.fortuneType,
    required this.amount,
    required this.actionType,
    required this.timestamp,
    required this.balanceBefore,
    required this.balanceAfter});

  bool get isSuccessful => balanceAfter >= 0;
}