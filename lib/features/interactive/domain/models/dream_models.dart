// Dream Models
//
// 꿈 관련 데이터 모델 정의

// ============================================================================
// Dream Entry Models (꿈 일기 - DreamPage)
// ============================================================================

class DreamEntry {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final List<String> tags;
  final int luckScore;
  final String? analysis;

  DreamEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.tags,
    required this.luckScore,
    this.analysis,
  });
}

class DreamAnalysis {
  final String dreamType;
  final int overallLuck;
  final String interpretation;
  final List<String> symbols;
  final String advice;

  DreamAnalysis({
    required this.dreamType,
    required this.overallLuck,
    required this.interpretation,
    required this.symbols,
    required this.advice,
  });

  factory DreamAnalysis.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return DreamAnalysis(
      dreamType: data['dream_type'] ?? '일반',
      overallLuck: data['overall_luck'],
      interpretation: data['interpretation'] ?? '',
      symbols: List<String>.from(data['symbols'] ?? []),
      advice: data['advice'] ?? '',
    );
  }
}

// ============================================================================
// Dream Interpretation Models (꿈 해몽 - DreamInterpretationPage)
// ============================================================================

class DreamInput {
  final String name;
  final DateTime birthDate;
  final String dreamContent;

  DreamInput({
    required this.name,
    required this.birthDate,
    required this.dreamContent,
  });
}

class DreamAnalysisResult {
  final int overallLuck;
  final String dreamSummary;
  final String dreamInterpretation;
  final List<String> luckyElements;
  final String advice;

  DreamAnalysisResult({
    required this.overallLuck,
    required this.dreamSummary,
    required this.dreamInterpretation,
    required this.luckyElements,
    required this.advice,
  });

  factory DreamAnalysisResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return DreamAnalysisResult(
      overallLuck: data['overall_luck'] ?? 70,
      dreamSummary: data['dream_summary'] ?? '',
      dreamInterpretation: data['dream_interpretation'] ?? '',
      luckyElements: List<String>.from(data['lucky_elements'] ?? []),
      advice: data['advice'] ?? '',
    );
  }
}
