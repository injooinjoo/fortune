// 토큰 시스템 비율 정의
// 모든 운세가 토큰을 소비합니다. (획득형 없음, 블러 없음)
// API 비용 기반으로 토큰이 책정됩니다.
class SoulRates {
  // 모든 운세의 토큰 비용 (양수 = 소비량)
  static const Map<String, int> costs = {
    // === 기본 운세 (1-2 토큰) - Gemini Flash Lite ===
    'daily': 1,
    'daily_calendar': 1,
    'today': 1,
    'tomorrow': 1,
    'hourly': 1,
    'lucky-color': 2,
    'lucky-number': 2,
    'lucky-food': 2,
    'lucky-outfit': 2,
    'lucky-items': 2,
    'fortune-cookie': 1,
    'birthstone': 2,
    'blood-type': 2,
    'zodiac-animal': 2,
    'zodiac': 2,

    // === 중급 운세 (3-5 토큰) - Gemini Flash ===
    'love': 4,
    'career': 4,
    'wealth': 4,
    'health': 3,
    'compatibility': 5,
    'tarot': 5,
    'dream': 3,
    'biorhythm': 3,
    'mbti': 3,
    'personality': 3,
    'personality-dna': 4,
    'weekly': 4,
    'monthly': 5,
    'birth-season': 3,
    'birthdate': 3,
    'avoid-people': 3,
    'lucky-place': 3,
    'lucky-series': 3,
    'lucky-baseball': 3,
    'lucky-golf': 3,
    'lucky-tennis': 3,
    'lucky-cycling': 3,
    'lucky-running': 3,
    'lucky-hiking': 3,
    'lucky-fishing': 3,
    'lucky-swim': 3,
    'lucky-fitness': 3,
    'lucky-yoga': 3,
    'wish': 4,
    'talisman': 4,
    'talent': 4,
    'naming': 4,
    'baby-nickname': 4,
    'baby_nickname': 4,
    'babyNickname': 4,
    'moving': 4,
    'moving-date': 4,

    // === 프리미엄 운세 (8-15 토큰) - GPT/Claude ===
    'saju': 12,
    'traditional-saju': 12,
    'traditional_saju': 12,
    'traditional-unified': 12,
    'saju-psychology': 10,
    'tojeong': 12,
    'past-life': 10,
    'destiny': 15,
    'marriage': 12,
    'couple-match': 10,
    'chemistry': 8,
    'ex-lover': 10,
    'ex_lover': 10,
    'blind-date': 8,
    'blind_date': 8,
    'celebrity-match': 8,
    'traditional-compatibility': 12,
    'palmistry': 10,
    'physiognomy': 12,
    'face-reading': 15,
    'timeline': 12,
    'lucky-exam': 8,
    'exam': 8,
    'network': 10,
    'network-report': 15,

    // === 채팅/롤플레이 (1 토큰 per message) ===
    'free-chat': 1,
    'character-chat': 1,

    // === 울트라 프리미엄 (20-50 토큰) ===
    'startup': 30,
    'business': 30,
    'lucky-investment': 35,
    'lucky-realestate': 30,
    'lucky-stock': 30,
    'lucky-crypto': 30,
    'lucky-sidejob': 25,
    'celebrity': 25,
    'five-blessings': 30,
    'yearly': 50,
    'new-year': 20,
    'lucky-lottery': 25,
    'employment': 20,
    'salpuli': 15,
    'health-document': 10,
    'fashion-image': 35,
    'lucky-job': 8,
    'talent-resume': 15,
  };

  /// 운세 타입에 따른 토큰 비용 반환
  /// 항상 양수 (소비량) - 레거시 호환을 위해 음수로 반환
  static int getSoulAmount(String fortuneType) {
    final cost = costs[fortuneType] ?? 1;
    return -cost; // 소비형이므로 음수 반환 (레거시 호환)
  }

  /// 운세 타입에 따른 토큰 비용 반환 (양수)
  static int getTokenCost(String fortuneType) {
    return costs[fortuneType] ?? 1;
  }

  /// 토큰 이용 가능 여부 확인
  static bool canAfford(String fortuneType, int currentTokens) {
    return currentTokens >= getTokenCost(fortuneType);
  }

  /// 모든 운세가 프리미엄 (토큰 소비형)
  static bool isPremiumFortune(String fortuneType) {
    return true; // 모든 운세가 토큰 소비
  }

  /// 무료 운세 없음
  static bool isFreeFortune(String fortuneType) {
    return false; // 무료 운세 없음
  }

  /// 토큰 액션 타입 (모두 소비)
  static SoulActionType getSoulActionType(String fortuneType) {
    return SoulActionType.consume;
  }

  /// 운세 비용 설명 텍스트 생성
  static String getActionDescription(String fortuneType) {
    final cost = getTokenCost(fortuneType);
    return '$cost 토큰 필요';
  }

  /// 운세 카테고리 판별
  static TokenCategory getCategory(String fortuneType) {
    final cost = getTokenCost(fortuneType);
    if (cost <= 2) return TokenCategory.basic;
    if (cost <= 5) return TokenCategory.intermediate;
    if (cost <= 15) return TokenCategory.premium;
    return TokenCategory.ultra;
  }

  /// 카테고리별 평균 비용
  static int getCategoryAverage(String category) {
    switch (category) {
      case 'basic':
        return 1;
      case 'intermediate':
        return 4;
      case 'premium':
        return 12;
      case 'ultra':
        return 30;
      default:
        return 1;
    }
  }

  // 레거시 호환용 - 빈 맵 반환
  static const Map<String, int> earnRates = {};
  static const Map<String, int> consumeRates = costs;
}

/// 토큰 액션 타입
enum SoulActionType {
  consume, // 토큰 소비 (유일한 타입)
  // 레거시 호환용
  earn,
  conditional,
}

/// 토큰 카테고리
enum TokenCategory {
  basic,        // 기본 (1-2 토큰)
  intermediate, // 중급 (3-5 토큰)
  premium,      // 프리미엄 (8-15 토큰)
  ultra,        // 울트라 (20-50 토큰)
}

/// 토큰 거래 결과
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
    required this.balanceAfter,
  });

  bool get isSuccessful => balanceAfter >= 0;
}
