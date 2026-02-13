// Model class for fortune result data
class FortuneResult {
  final String? id;
  final String? type;
  final String? fortuneType;
  final String? date;
  final String? createdAt;
  final String? mainFortune;
  final String? summary;
  final Map<String, dynamic>? details;
  final Map<String, dynamic>? result;
  final Map<String, String>? sections;
  final int? overallScore;
  final Map<String, int>? scoreBreakdown;
  final Map<String, dynamic>? luckyItems;
  final List<String>? recommendations;
  final Map<String, dynamic>? additionalInfo;
  final int? percentile; // ✅ 상위 퍼센타일 (예: 15 = 상위 15%)
  final int? totalTodayViewers; // ✅ 오늘 해당 운세를 본 총 인원수
  final bool isPercentileValid; // ✅ 퍼센타일 데이터 유효 여부

  FortuneResult({
    this.id,
    this.type,
    this.fortuneType,
    this.date,
    this.createdAt,
    this.mainFortune,
    this.summary,
    this.details,
    this.result,
    this.sections,
    this.overallScore,
    this.scoreBreakdown,
    this.luckyItems,
    this.recommendations,
    this.additionalInfo,
    this.percentile,
    this.totalTodayViewers,
    this.isPercentileValid = false,
  });

  // Getter for fortune object - returns self for compatibility
  FortuneResult get fortune => this;

  // Getter for fortune content text
  String get content => mainFortune ?? summary ?? '';

  // Getter for metadata - returns additionalInfo or details
  Map<String, dynamic>? get metadata => additionalInfo ?? details;

  // ✅ copyWith 메서드 추가
  FortuneResult copyWith({
    String? id,
    String? type,
    String? fortuneType,
    String? date,
    String? createdAt,
    String? mainFortune,
    String? summary,
    Map<String, dynamic>? details,
    Map<String, dynamic>? result,
    Map<String, String>? sections,
    int? overallScore,
    Map<String, int>? scoreBreakdown,
    Map<String, dynamic>? luckyItems,
    List<String>? recommendations,
    Map<String, dynamic>? additionalInfo,
    int? percentile,
    int? totalTodayViewers,
    bool? isPercentileValid,
  }) {
    return FortuneResult(
      id: id ?? this.id,
      type: type ?? this.type,
      fortuneType: fortuneType ?? this.fortuneType,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      mainFortune: mainFortune ?? this.mainFortune,
      summary: summary ?? this.summary,
      details: details ?? this.details,
      result: result ?? this.result,
      sections: sections ?? this.sections,
      overallScore: overallScore ?? this.overallScore,
      scoreBreakdown: scoreBreakdown ?? this.scoreBreakdown,
      luckyItems: luckyItems ?? this.luckyItems,
      recommendations: recommendations ?? this.recommendations,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      percentile: percentile ?? this.percentile,
      totalTodayViewers: totalTodayViewers ?? this.totalTodayViewers,
      isPercentileValid: isPercentileValid ?? this.isPercentileValid,
    );
  }

  factory FortuneResult.fromMap(Map<String, dynamic> map) {
    return FortuneResult(
      id: map['id'],
      type: map['type'],
      fortuneType: map['fortuneType'],
      date: map['date'],
      createdAt: map['createdAt'],
      mainFortune: map['mainFortune'],
      summary: map['summary'],
      details: map['details'] != null
          ? Map<String, dynamic>.from(map['details'])
          : null,
      result: map['result'] != null
          ? Map<String, dynamic>.from(map['result'])
          : null,
      sections: map['sections'] != null
          ? Map<String, String>.from(map['sections'])
          : null,
      overallScore: map['overallScore'],
      scoreBreakdown: map['scoreBreakdown'] != null
          ? Map<String, int>.from(map['scoreBreakdown'])
          : null,
      luckyItems: map['luckyItems'] != null
          ? Map<String, dynamic>.from(map['luckyItems'])
          : null,
      recommendations: map['recommendations'] != null
          ? List<String>.from(map['recommendations'])
          : null,
      additionalInfo: map['additionalInfo'] != null
          ? Map<String, dynamic>.from(map['additionalInfo'])
          : null,
      percentile: map['percentile'] as int?,
      totalTodayViewers: map['totalTodayViewers'] as int?,
      isPercentileValid: map['isPercentileValid'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'fortuneType': fortuneType,
      'date': date,
      'createdAt': createdAt,
      'mainFortune': mainFortune,
      'summary': summary,
      'details': details,
      'result': result,
      'sections': sections,
      'overallScore': overallScore,
      'scoreBreakdown': scoreBreakdown,
      'luckyItems': luckyItems,
      'recommendations': recommendations,
      'additionalInfo': null,
      'percentile': percentile, // ✅ Added
      'totalTodayViewers': totalTodayViewers, // ✅ Added
      'isPercentileValid': isPercentileValid, // ✅ Added
    };
  }
}
