/// 소원 빌기 결과 데이터 모델
class WishFortuneResult {
  final int overallScore;
  final String divineMessage;
  final WishAnalysis wishAnalysis;
  final Realization realization;
  final LuckyElements luckyElements;
  final List<String> warnings;
  final List<String> actionPlan;
  final String spiritualMessage;
  final Statistics statistics;

  WishFortuneResult({
    required this.overallScore,
    required this.divineMessage,
    required this.wishAnalysis,
    required this.realization,
    required this.luckyElements,
    required this.warnings,
    required this.actionPlan,
    required this.spiritualMessage,
    required this.statistics,
  });

  factory WishFortuneResult.fromJson(Map<String, dynamic> json) {
    return WishFortuneResult(
      overallScore: json['overall_score'] as int,
      divineMessage: json['divine_message'] as String,
      wishAnalysis: WishAnalysis.fromJson(json['wish_analysis'] as Map<String, dynamic>),
      realization: Realization.fromJson(json['realization'] as Map<String, dynamic>),
      luckyElements: LuckyElements.fromJson(json['lucky_elements'] as Map<String, dynamic>),
      warnings: List<String>.from(json['warnings'] ?? []),
      actionPlan: List<String>.from(json['action_plan'] ?? []),
      spiritualMessage: json['spiritual_message'] as String,
      statistics: Statistics.fromJson(json['statistics'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall_score': overallScore,
      'divine_message': divineMessage,
      'wish_analysis': wishAnalysis.toJson(),
      'realization': realization.toJson(),
      'lucky_elements': luckyElements.toJson(),
      'warnings': warnings,
      'action_plan': actionPlan,
      'spiritual_message': spiritualMessage,
      'statistics': statistics.toJson(),
    };
  }
}

class WishAnalysis {
  final List<String> keywords;
  final String emotionLevel;
  final int sincerityScore;

  WishAnalysis({
    required this.keywords,
    required this.emotionLevel,
    required this.sincerityScore,
  });

  factory WishAnalysis.fromJson(Map<String, dynamic> json) {
    return WishAnalysis(
      keywords: List<String>.from(json['keywords'] ?? []),
      emotionLevel: json['emotion_level'] as String,
      sincerityScore: json['sincerity_score'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keywords': keywords,
      'emotion_level': emotionLevel,
      'sincerity_score': sincerityScore,
    };
  }
}

class Realization {
  final int probability;
  final List<String> conditions;
  final String timeline;

  Realization({
    required this.probability,
    required this.conditions,
    required this.timeline,
  });

  factory Realization.fromJson(Map<String, dynamic> json) {
    return Realization(
      probability: json['probability'] as int,
      conditions: List<String>.from(json['conditions'] ?? []),
      timeline: json['timeline'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'probability': probability,
      'conditions': conditions,
      'timeline': timeline,
    };
  }
}

class LuckyElements {
  final String color;
  final String colorHex;
  final String direction;
  final String time;

  LuckyElements({
    required this.color,
    required this.colorHex,
    required this.direction,
    required this.time,
  });

  factory LuckyElements.fromJson(Map<String, dynamic> json) {
    return LuckyElements(
      color: json['color'] as String,
      colorHex: json['color_hex'] as String? ?? '#3182F6',
      direction: json['direction'] as String,
      time: json['time'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'color': color,
      'color_hex': colorHex,
      'direction': direction,
      'time': time,
    };
  }
}

class Statistics {
  final int similarWishes;
  final int successRate;

  Statistics({
    required this.similarWishes,
    required this.successRate,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      similarWishes: json['similar_wishes'] as int,
      successRate: json['success_rate'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'similar_wishes': similarWishes,
      'success_rate': successRate,
    };
  }
}
