class ChatInsightResult {
  final AnalysisMeta analysisMeta;
  final InsightScores scores;
  final InsightHighlights highlights;
  final InsightTimeline timeline;
  final InsightPatterns patterns;
  final InsightTriggers triggers;
  final InsightGuidance guidance;
  final FollowupMemory followupMemory;

  const ChatInsightResult({
    required this.analysisMeta,
    required this.scores,
    required this.highlights,
    required this.timeline,
    required this.patterns,
    required this.triggers,
    required this.guidance,
    required this.followupMemory,
  });

  factory ChatInsightResult.fromJson(Map<String, dynamic> json) {
    return ChatInsightResult(
      analysisMeta:
          AnalysisMeta.fromJson(json['analysis_meta'] as Map<String, dynamic>),
      scores: InsightScores.fromJson(json['scores'] as Map<String, dynamic>),
      highlights: InsightHighlights.fromJson(
          json['highlights'] as Map<String, dynamic>),
      timeline:
          InsightTimeline.fromJson(json['timeline'] as Map<String, dynamic>),
      patterns:
          InsightPatterns.fromJson(json['patterns'] as Map<String, dynamic>),
      triggers:
          InsightTriggers.fromJson(json['triggers'] as Map<String, dynamic>),
      guidance:
          InsightGuidance.fromJson(json['guidance'] as Map<String, dynamic>),
      followupMemory: FollowupMemory.fromJson(
          json['followup_memory'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'analysis_meta': analysisMeta.toJson(),
        'scores': scores.toJson(),
        'highlights': highlights.toJson(),
        'timeline': timeline.toJson(),
        'patterns': patterns.toJson(),
        'triggers': triggers.toJson(),
        'guidance': guidance.toJson(),
        'followup_memory': followupMemory.toJson(),
      };
}

// --- Analysis Meta ---

enum RelationType { lover, crush, friend, family, boss, other }

enum DateRange { all, days7, days30 }

enum AnalysisIntensity { light, standard, deep }

class PrivacyConfig {
  final bool localOnly;
  final bool serverSent;
  final bool originalStored;

  const PrivacyConfig({
    this.localOnly = true,
    this.serverSent = false,
    this.originalStored = false,
  });

  factory PrivacyConfig.fromJson(Map<String, dynamic> json) {
    return PrivacyConfig(
      localOnly: json['local_only'] as bool? ?? true,
      serverSent: json['server_sent'] as bool? ?? false,
      originalStored: json['original_stored'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'local_only': localOnly,
        'server_sent': serverSent,
        'original_stored': originalStored,
      };

  PrivacyConfig copyWith({
    bool? localOnly,
    bool? serverSent,
    bool? originalStored,
  }) {
    return PrivacyConfig(
      localOnly: localOnly ?? this.localOnly,
      serverSent: serverSent ?? this.serverSent,
      originalStored: originalStored ?? this.originalStored,
    );
  }
}

class AnalysisMeta {
  final String id;
  final DateTime createdAt;
  final RelationType relationType;
  final DateRange range;
  final AnalysisIntensity intensity;
  final PrivacyConfig privacy;
  final int messageCount;
  final DateTime dateFrom;
  final DateTime dateTo;

  const AnalysisMeta({
    required this.id,
    required this.createdAt,
    required this.relationType,
    required this.range,
    required this.intensity,
    required this.privacy,
    required this.messageCount,
    required this.dateFrom,
    required this.dateTo,
  });

  factory AnalysisMeta.fromJson(Map<String, dynamic> json) {
    final dateRange = json['date_range_actual'] as Map<String, dynamic>? ?? {};
    return AnalysisMeta(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      relationType: _parseRelationType(json['relation_type'] as String),
      range: _parseDateRange(json['range'] as String),
      intensity: _parseIntensity(json['intensity'] as String),
      privacy: PrivacyConfig.fromJson(
          json['privacy'] as Map<String, dynamic>? ?? {}),
      messageCount: json['message_count'] as int,
      dateFrom: DateTime.parse(
          dateRange['from'] as String? ?? DateTime.now().toIso8601String()),
      dateTo: DateTime.parse(
          dateRange['to'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'created_at': createdAt.toIso8601String(),
        'relation_type': relationType.name,
        'range': _dateRangeToString(range),
        'intensity': intensity.name,
        'privacy': privacy.toJson(),
        'message_count': messageCount,
        'date_range_actual': {
          'from': dateFrom.toIso8601String().split('T').first,
          'to': dateTo.toIso8601String().split('T').first,
        },
      };

  static RelationType _parseRelationType(String value) {
    return RelationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RelationType.other,
    );
  }

  static DateRange _parseDateRange(String value) {
    switch (value) {
      case '7d':
        return DateRange.days7;
      case '30d':
        return DateRange.days30;
      default:
        return DateRange.all;
    }
  }

  static String _dateRangeToString(DateRange range) {
    switch (range) {
      case DateRange.days7:
        return '7d';
      case DateRange.days30:
        return '30d';
      case DateRange.all:
        return 'all';
    }
  }

  static AnalysisIntensity _parseIntensity(String value) {
    return AnalysisIntensity.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AnalysisIntensity.standard,
    );
  }
}

// --- Scores ---

enum ScoreTrend { up, down, stable }

class ScoreItem {
  final int value;
  final String label;
  final ScoreTrend trend;

  const ScoreItem({
    required this.value,
    required this.label,
    required this.trend,
  });

  factory ScoreItem.fromJson(Map<String, dynamic> json) {
    return ScoreItem(
      value: json['value'] as int,
      label: json['label'] as String,
      trend: ScoreTrend.values.firstWhere(
        (e) => e.name == (json['trend'] as String),
        orElse: () => ScoreTrend.stable,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'value': value,
        'label': label,
        'trend': trend.name,
      };
}

class InsightScores {
  final ScoreItem temperature;
  final ScoreItem stability;
  final ScoreItem initiative;
  final ScoreItem risk;

  const InsightScores({
    required this.temperature,
    required this.stability,
    required this.initiative,
    required this.risk,
  });

  factory InsightScores.fromJson(Map<String, dynamic> json) {
    return InsightScores(
      temperature:
          ScoreItem.fromJson(json['temperature'] as Map<String, dynamic>),
      stability: ScoreItem.fromJson(json['stability'] as Map<String, dynamic>),
      initiative:
          ScoreItem.fromJson(json['initiative'] as Map<String, dynamic>),
      risk: ScoreItem.fromJson(json['risk'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'temperature': temperature.toJson(),
        'stability': stability.toJson(),
        'initiative': initiative.toJson(),
        'risk': risk.toJson(),
      };

  List<MapEntry<String, ScoreItem>> get entries => [
        MapEntry('온도', temperature),
        MapEntry('안정성', stability),
        MapEntry('주도권', initiative),
        MapEntry('위험도', risk),
      ];
}

// --- Highlights ---

enum Severity { low, medium, high }

class RedFlag {
  final String text;
  final Severity severity;

  const RedFlag({required this.text, required this.severity});

  factory RedFlag.fromJson(Map<String, dynamic> json) {
    return RedFlag(
      text: json['text'] as String,
      severity: Severity.values.firstWhere(
        (e) => e.name == (json['severity'] as String),
        orElse: () => Severity.low,
      ),
    );
  }

  Map<String, dynamic> toJson() => {'text': text, 'severity': severity.name};
}

class GreenFlag {
  final String text;
  final Severity strength;

  const GreenFlag({required this.text, required this.strength});

  factory GreenFlag.fromJson(Map<String, dynamic> json) {
    return GreenFlag(
      text: json['text'] as String,
      strength: Severity.values.firstWhere(
        (e) => e.name == (json['strength'] as String),
        orElse: () => Severity.medium,
      ),
    );
  }

  Map<String, dynamic> toJson() => {'text': text, 'strength': strength.name};
}

class InsightHighlights {
  final List<String> summaryBullets;
  final List<RedFlag> redFlags;
  final List<GreenFlag> greenFlags;

  const InsightHighlights({
    required this.summaryBullets,
    required this.redFlags,
    required this.greenFlags,
  });

  factory InsightHighlights.fromJson(Map<String, dynamic> json) {
    return InsightHighlights(
      summaryBullets: (json['summary_bullets'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      redFlags: (json['red_flags'] as List<dynamic>?)
              ?.map((e) => RedFlag.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      greenFlags: (json['green_flags'] as List<dynamic>?)
              ?.map((e) => GreenFlag.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'summary_bullets': summaryBullets,
        'red_flags': redFlags.map((e) => e.toJson()).toList(),
        'green_flags': greenFlags.map((e) => e.toJson()).toList(),
      };
}

// --- Timeline ---

class TimelinePoint {
  final DateTime time;
  final double sentiment;

  const TimelinePoint({required this.time, required this.sentiment});

  factory TimelinePoint.fromJson(Map<String, dynamic> json) {
    return TimelinePoint(
      time: DateTime.parse(json['t'] as String),
      sentiment: (json['sentiment'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        't': time.toIso8601String().split('T').first,
        'sentiment': sentiment,
      };
}

class TimelineEvent {
  final DateTime time;
  final String label;

  const TimelineEvent({required this.time, required this.label});

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      time: DateTime.parse(json['t'] as String),
      label: json['label'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        't': time.toIso8601String().split('T').first,
        'label': label,
      };
}

class InsightTimeline {
  final List<TimelinePoint> points;
  final List<TimelineEvent> dips;
  final List<TimelineEvent> spikes;

  const InsightTimeline({
    required this.points,
    required this.dips,
    required this.spikes,
  });

  factory InsightTimeline.fromJson(Map<String, dynamic> json) {
    return InsightTimeline(
      points: (json['points'] as List<dynamic>?)
              ?.map((e) => TimelinePoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dips: (json['dips'] as List<dynamic>?)
              ?.map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      spikes: (json['spikes'] as List<dynamic>?)
              ?.map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'points': points.map((e) => e.toJson()).toList(),
        'dips': dips.map((e) => e.toJson()).toList(),
        'spikes': spikes.map((e) => e.toJson()).toList(),
      };
}

// --- Patterns ---

class PatternItem {
  final String tag;
  final int evidenceCount;
  final String description;

  const PatternItem({
    required this.tag,
    required this.evidenceCount,
    required this.description,
  });

  factory PatternItem.fromJson(Map<String, dynamic> json) {
    return PatternItem(
      tag: json['tag'] as String,
      evidenceCount: json['evidence_count'] as int,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'tag': tag,
        'evidence_count': evidenceCount,
        'description': description,
      };
}

class InsightPatterns {
  final List<PatternItem> items;

  const InsightPatterns({required this.items});

  factory InsightPatterns.fromJson(Map<String, dynamic> json) {
    return InsightPatterns(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => PatternItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'items': items.map((e) => e.toJson()).toList(),
      };
}

// --- Triggers ---

class TriggerItem {
  final String maskedQuote;
  final String whyItMatters;
  final DateTime? time;

  const TriggerItem({
    required this.maskedQuote,
    required this.whyItMatters,
    this.time,
  });

  factory TriggerItem.fromJson(Map<String, dynamic> json) {
    return TriggerItem(
      maskedQuote: json['masked_quote'] as String,
      whyItMatters: json['why_it_matters'] as String,
      time:
          json['time'] != null ? DateTime.parse(json['time'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'masked_quote': maskedQuote,
        'why_it_matters': whyItMatters,
        if (time != null) 'time': time!.toIso8601String(),
      };
}

class InsightTriggers {
  final List<TriggerItem> items;

  const InsightTriggers({required this.items});

  factory InsightTriggers.fromJson(Map<String, dynamic> json) {
    return InsightTriggers(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => TriggerItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'items': items.map((e) => e.toJson()).toList(),
      };
}

// --- Guidance ---

class GuidanceItem {
  final String text;
  final String expectedEffect;

  const GuidanceItem({required this.text, required this.expectedEffect});

  factory GuidanceItem.fromJson(Map<String, dynamic> json) {
    return GuidanceItem(
      text: json['text'] as String,
      expectedEffect: json['expected_effect'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'expected_effect': expectedEffect,
      };
}

class InsightGuidance {
  final List<GuidanceItem> doList;
  final List<GuidanceItem> dontList;

  const InsightGuidance({required this.doList, required this.dontList});

  factory InsightGuidance.fromJson(Map<String, dynamic> json) {
    return InsightGuidance(
      doList: (json['do'] as List<dynamic>?)
              ?.map((e) => GuidanceItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dontList: (json['dont'] as List<dynamic>?)
              ?.map((e) => GuidanceItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'do': doList.map((e) => e.toJson()).toList(),
        'dont': dontList.map((e) => e.toJson()).toList(),
      };
}

// --- Followup Memory ---

class FollowupMemory {
  final String safeNotes;
  final List<String> userQuestions;

  const FollowupMemory({required this.safeNotes, required this.userQuestions});

  factory FollowupMemory.fromJson(Map<String, dynamic> json) {
    return FollowupMemory(
      safeNotes: json['safe_notes'] as String? ?? '',
      userQuestions: (json['user_questions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'safe_notes': safeNotes,
        'user_questions': userQuestions,
      };
}

// --- Analysis Config (UI에서 사용) ---

class AnalysisConfig {
  final RelationType relationType;
  final DateRange dateRange;
  final AnalysisIntensity intensity;

  const AnalysisConfig({
    required this.relationType,
    required this.dateRange,
    required this.intensity,
  });
}
