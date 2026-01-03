/// 소원 빌기 결과 데이터 모델 (용 테마 + 게이미피케이션)
class WishFortuneResult {
  // 기존 필드
  final String empathyMessage;    // 공감 메시지 (300자)
  final String hopeMessage;       // 희망과 격려 (400자)
  final List<String> advice;      // 구체적 조언 3개
  final String encouragement;     // 응원 메시지 (200자)
  final String specialWords;      // 신의 한마디 (50자)

  // 🆕 운의 흐름 (데이터 기반 느낌)
  final FortuneFlow? fortuneFlow;

  // 🆕 행운의 미션 (게이미피케이션)
  final LuckyMission? luckyMission;

  // 🆕 용의 메시지 (스토리텔링)
  final DragonMessage? dragonMessage;

  WishFortuneResult({
    required this.empathyMessage,
    required this.hopeMessage,
    required this.advice,
    required this.encouragement,
    required this.specialWords,
    this.fortuneFlow,
    this.luckyMission,
    this.dragonMessage,
  });

  factory WishFortuneResult.fromJson(Map<String, dynamic> json) {
    return WishFortuneResult(
      empathyMessage: json['empathy_message'] as String? ?? '',
      hopeMessage: json['hope_message'] as String? ?? '',
      advice: (json['advice'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      encouragement: json['encouragement'] as String? ?? '',
      specialWords: json['special_words'] as String? ?? '',
      fortuneFlow: json['fortune_flow'] != null
          ? FortuneFlow.fromJson(json['fortune_flow'] as Map<String, dynamic>)
          : null,
      luckyMission: json['lucky_mission'] != null
          ? LuckyMission.fromJson(json['lucky_mission'] as Map<String, dynamic>)
          : null,
      dragonMessage: json['dragon_message'] != null
          ? DragonMessage.fromJson(json['dragon_message'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'empathy_message': empathyMessage,
      'hope_message': hopeMessage,
      'advice': advice,
      'encouragement': encouragement,
      'special_words': specialWords,
      if (fortuneFlow != null) 'fortune_flow': fortuneFlow!.toJson(),
      if (luckyMission != null) 'lucky_mission': luckyMission!.toJson(),
      if (dragonMessage != null) 'dragon_message': dragonMessage!.toJson(),
    };
  }

  /// 새 필드가 있는지 확인
  bool get hasEnhancedData =>
      fortuneFlow != null || luckyMission != null || dragonMessage != null;
}

/// 운의 흐름 (데이터 기반 느낌)
class FortuneFlow {
  final String achievementLevel;   // "매우 높음" | "높음" | "보통" | "노력 필요"
  final String luckyTiming;        // "오후 2시~4시" 형식
  final List<String> keywords;     // 3개 해시태그 ["#인연", "#결단", "#기다림"]
  final String helper;             // 도움이 되는 사람/행동
  final String obstacle;           // 주의해야 할 행동

  FortuneFlow({
    required this.achievementLevel,
    required this.luckyTiming,
    required this.keywords,
    required this.helper,
    required this.obstacle,
  });

  factory FortuneFlow.fromJson(Map<String, dynamic> json) {
    return FortuneFlow(
      achievementLevel: json['achievement_level'] as String? ?? '보통',
      luckyTiming: json['lucky_timing'] as String? ?? '',
      keywords: (json['keywords'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      helper: json['helper'] as String? ?? '',
      obstacle: json['obstacle'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'achievement_level': achievementLevel,
      'lucky_timing': luckyTiming,
      'keywords': keywords,
      'helper': helper,
      'obstacle': obstacle,
    };
  }
}

/// 행운의 미션 (게이미피케이션)
class LuckyMission {
  final String item;           // "주머니에 동전 하나"
  final String itemReason;     // 왜 이 아이템인지
  final String place;          // "탁 트인 공원"
  final String placeReason;    // 왜 이 장소인지
  final String color;          // "파란색"
  final String colorReason;    // 왜 이 색상인지

  LuckyMission({
    required this.item,
    required this.itemReason,
    required this.place,
    required this.placeReason,
    required this.color,
    required this.colorReason,
  });

  factory LuckyMission.fromJson(Map<String, dynamic> json) {
    return LuckyMission(
      item: json['item'] as String? ?? '',
      itemReason: json['item_reason'] as String? ?? '',
      place: json['place'] as String? ?? '',
      placeReason: json['place_reason'] as String? ?? '',
      color: json['color'] as String? ?? '',
      colorReason: json['color_reason'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': item,
      'item_reason': itemReason,
      'place': place,
      'place_reason': placeReason,
      'color': color,
      'color_reason': colorReason,
    };
  }
}

/// 용의 메시지 (스토리텔링)
class DragonMessage {
  final String pearlMessage;   // 여의주 메시지
  final String wisdom;         // 용의 지혜
  final String powerLine;      // 짧고 강렬한 한마디 (소원 키워드 포함)

  DragonMessage({
    required this.pearlMessage,
    required this.wisdom,
    required this.powerLine,
  });

  factory DragonMessage.fromJson(Map<String, dynamic> json) {
    return DragonMessage(
      pearlMessage: json['pearl_message'] as String? ?? '',
      wisdom: json['wisdom'] as String? ?? '',
      powerLine: json['power_line'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pearl_message': pearlMessage,
      'wisdom': wisdom,
      'power_line': powerLine,
    };
  }
}
