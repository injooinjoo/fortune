/// Model class for fortune result data
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
  });

  // Getter for fortune object - returns self for compatibility
  FortuneResult get fortune => this;
  
  // Getter for fortune content text
  String get content => mainFortune ?? summary ?? '';
  
  // Getter for metadata - returns additionalInfo or details
  Map<String, dynamic>? get metadata => additionalInfo ?? details;

  factory FortuneResult.fromMap(Map<String, dynamic> map) {
    return FortuneResult(
      id: map['id'],
      type: map['type'],
      fortuneType: map['fortuneType'],
      date: map['date'],
      createdAt: map['createdAt'],
      mainFortune: map['mainFortune'],
      summary: map['summary'],
      details: map['details'] != null ? Map<String, dynamic>.from(map['details']) : null,
      result: map['result'] != null ? Map<String, dynamic>.from(map['result']) : null,
      sections: map['sections'] != null ? Map<String, String>.from(map['sections']) : null,
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
      'additionalInfo': additionalInfo,
    };
  }
}