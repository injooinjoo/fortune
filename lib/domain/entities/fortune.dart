import 'package:equatable/equatable.dart';
import '../../core/constants/fortune_detailed_metadata.dart';

// 기본 운세 엔티티
class Fortune extends Equatable {
  final String id;
  final String userId;
  final String type;
  final String content;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;
  final int tokenCost;
  // Extended properties for detailed fortunes
  final String? category;
  final int? overallScore;
  final String? description;
  final Map<String, dynamic>? scoreBreakdown;
  final Map<String, dynamic>? luckyItems;
  final List<String>? recommendations;
  final List<String>? warnings;
  final String? summary;
  final Map<String, dynamic>? additionalInfo;
  // New field for detailed lucky items
  final Map<String, List<DetailedLuckyItem>>? detailedLuckyItems;
  // Enhanced fields for time-based fortunes
  final String? greeting;
  final Map<String, int>? hexagonScores; // 총운, 학업운, 재물운, 건강운, 연애운, 사업운
  final List<TimeSpecificFortune>? timeSpecificFortunes;
  final List<BirthYearFortune>? birthYearFortunes;
  final Map<String, dynamic>? fiveElements;
  final String? specialTip;
  final String? period; // today, tomorrow, weekly, monthly, yearly
  
  // Enhanced fields for comprehensive fortune output
  final Map<String, dynamic>? meta; // date, weekday, timezone, city
  final Map<String, dynamic>? weatherSummary; // weather integration
  final Map<String, dynamic>? overall; // overall score, grade, trend, summary
  final Map<String, dynamic>? categories; // love, money, work, health, social
  final Map<String, dynamic>? sajuInsight; // saju-based insights
  final List<Map<String, dynamic>>? personalActions; // recommended actions
  final Map<String, dynamic>? notification; // push notification data
  final Map<String, dynamic>? shareCard; // social sharing data
  final List<String>? uiBlocks; // UI block ordering
  final Map<String, dynamic>? explain; // debugging/explanation data

  const Fortune({
    required this.id,
    required this.userId,
    required this.type,
    required this.content,
    required this.createdAt,
    this.metadata,
    this.tokenCost = 1,
    this.category,
    this.overallScore,
    this.description,
    this.scoreBreakdown,
    this.luckyItems,
    this.recommendations,
    this.warnings,
    this.summary,
    this.additionalInfo,
    this.detailedLuckyItems,
    this.greeting,
    this.hexagonScores,
    this.timeSpecificFortunes,
    this.birthYearFortunes,
    this.fiveElements,
    this.specialTip,
    this.period,
    this.meta,
    this.weatherSummary,
    this.overall,
    this.categories,
    this.sajuInsight,
    this.personalActions,
    this.notification,
    this.shareCard,
    this.uiBlocks,
    this.explain});

  // Getter for backwards compatibility
  int get score => overallScore ?? 80;
  String get message => content;
  Map<String, dynamic>? get details => additionalInfo;
  
  // Getters for lucky items
  String? get luckyColor => luckyItems?['color'] as String?;
  int? get luckyNumber => luckyItems?['number'] as int?;
  String? get luckyDirection => luckyItems?['direction'] as String?;
  String? get bestTime => luckyItems?['time'] as String?;
  
  // Getters for common fields
  String? get advice => metadata?['advice'] as String? ?? recommendations?.firstOrNull;
  String? get caution => metadata?['caution'] as String? ?? warnings?.firstOrNull;

  @override
  List<Object?> get props => [
    id, userId, type, content, createdAt, metadata, tokenCost,
    category, overallScore, description, scoreBreakdown, luckyItems, recommendations,
    warnings, summary, additionalInfo, detailedLuckyItems, greeting, hexagonScores,
    timeSpecificFortunes, birthYearFortunes, fiveElements, specialTip, period,
    meta, weatherSummary, overall, categories, sajuInsight, personalActions,
    notification, shareCard, uiBlocks, explain
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
      'tokenCost': tokenCost,
      if (category != null) 'category': category,
      if (overallScore != null) 'overallScore': overallScore,
      if (description != null) 'description': description,
      if (scoreBreakdown != null) 'scoreBreakdown': scoreBreakdown,
      if (luckyItems != null) 'luckyItems': luckyItems,
      if (recommendations != null) 'recommendations': recommendations,
      if (warnings != null) 'warnings': warnings,
      if (summary != null) 'summary': summary,
      if (additionalInfo != null) 'additionalInfo': additionalInfo,
      if (detailedLuckyItems != null) 'detailedLuckyItems': detailedLuckyItems,
      if (greeting != null) 'greeting': greeting,
      if (hexagonScores != null) 'hexagonScores': hexagonScores,
      if (timeSpecificFortunes != null) 'timeSpecificFortunes': timeSpecificFortunes?.map((e) => e.toJson()).toList(),
      if (birthYearFortunes != null) 'birthYearFortunes': birthYearFortunes?.map((e) => e.toJson()).toList(),
      if (fiveElements != null) 'fiveElements': fiveElements,
      if (specialTip != null) 'specialTip': specialTip,
      if (period != null) 'period': period};
  }
}

// 일일 운세 엔티티
class DailyFortune extends Equatable {
  final int score;
  final List<String> keywords;
  final String summary;
  final String luckyColor;
  final int luckyNumber;
  final int energy;
  final String mood;
  final String advice;
  final String caution;
  final String bestTime;
  final String compatibility;
  final FortuneElements elements;

  const DailyFortune({
    required this.score,
    required this.keywords,
    required this.summary,
    required this.luckyColor,
    required this.luckyNumber,
    required this.energy,
    required this.mood,
    required this.advice,
    required this.caution,
    required this.bestTime,
    required this.compatibility,
    required this.elements});

  @override
  List<Object?> get props => [
    score, keywords, summary, luckyColor, luckyNumber, 
    energy, mood, advice, caution, bestTime, compatibility, elements
  ];
}

// 운세 요소별 점수
class FortuneElements extends Equatable {
  final int love;
  final int career;
  final int money;
  final int health;

  const FortuneElements({
    required this.love,
    required this.career,
    required this.money,
    required this.health});

  @override
  List<Object?> get props => [love, career, money, health];
}

// 사주 운세 엔티티
class SajuFortune extends Equatable {
  final String fourPillars;
  final String element;
  final String personality;
  final String career;
  final String wealth;
  final String health;
  final String relationship;
  final String yearlyFortune;
  final String monthlyFortune;
  final String advice;
  final Map<String, dynamic> detailedAnalysis;

  const SajuFortune({
    required this.fourPillars,
    required this.element,
    required this.personality,
    required this.career,
    required this.wealth,
    required this.health,
    required this.relationship,
    required this.yearlyFortune,
    required this.monthlyFortune,
    required this.advice,
    required this.detailedAnalysis});

  @override
  List<Object?> get props => [
    fourPillars, element, personality, career, wealth, 
    health, relationship, yearlyFortune, monthlyFortune, advice, detailedAnalysis
  ];
}

// MBTI 운세 엔티티
class MBTIFortune extends Equatable {
  final String mbtiType;
  final String todayMood;
  final String strengths;
  final String weaknesses;
  final String advice;
  final String compatibility;
  final String careerAdvice;
  final String relationshipAdvice;
  final int energyLevel;
  final int stressLevel;

  const MBTIFortune({
    required this.mbtiType,
    required this.todayMood,
    required this.strengths,
    required this.weaknesses,
    required this.advice,
    required this.compatibility,
    required this.careerAdvice,
    required this.relationshipAdvice,
    required this.energyLevel,
    required this.stressLevel});

  @override
  List<Object?> get props => [
    mbtiType, todayMood, strengths, weaknesses, advice,
    compatibility, careerAdvice, relationshipAdvice, energyLevel, stressLevel
  ];
}

// 궁합 운세 엔티티
class CompatibilityFortune extends Equatable {
  final int compatibilityScore;
  final String summary;
  final String emotionalCompatibility;
  final String communicationStyle;
  final String conflictResolution;
  final String longTermPotential;
  final List<String> strengths;
  final List<String> challenges;
  final String advice;

  const CompatibilityFortune({
    required this.compatibilityScore,
    required this.summary,
    required this.emotionalCompatibility,
    required this.communicationStyle,
    required this.conflictResolution,
    required this.longTermPotential,
    required this.strengths,
    required this.challenges,
    required this.advice});

  @override
  List<Object?> get props => [
    compatibilityScore, summary, emotionalCompatibility, communicationStyle,
    conflictResolution, longTermPotential, strengths, challenges, advice
  ];
}

// 운세 카테고리
enum FortuneCategory {
  
  
  daily,        // 일일/시간별
  traditional,  // 전통 운세
  personality,  // 성격/심리
  love,         // 연애/결혼
  career,       // 직업/사업
  wealth,       // 재물/투자
  lifestyle,    // 생활/건강
  sports,       // 스포츠
  lucky,        // 행운 아이템
  special,      // 특별 운세
  
  
}

// 운세 타입 정보
class FortuneTypeInfo extends Equatable {
  final String id;
  final String title;
  final String description;
  final FortuneCategory category;
  final int tokenCost;
  final String iconName;
  final String color;
  final String gradient;
  final bool isPremium;
  final bool isNew;
  final bool isPopular;

  const FortuneTypeInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.tokenCost,
    required this.iconName,
    required this.color,
    required this.gradient,
    this.isPremium = false,
    this.isNew = false,
    this.isPopular = false});

  @override
  List<Object?> get props => [
    id, title, description, category, tokenCost, 
    iconName, color, gradient, isPremium, isNew, isPopular
  ];
}

// Time-specific fortune for hourly/daily/weekly breakdowns
class TimeSpecificFortune extends Equatable {
  final String time; // e.g., "06:00-09:00", "월요일", "첫째 주"
  final String title;
  final int score;
  final String description;
  final String? recommendation;

  const TimeSpecificFortune({
    required this.time,
    required this.title,
    required this.score,
    required this.description,
    this.recommendation});

  @override
  List<Object?> get props => [time, title, score, description, recommendation];

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'title': title,
      'score': score,
      'description': null,
      if (recommendation != null) 'recommendation': null};
  }
}

// Birth year specific fortune
class BirthYearFortune extends Equatable {
  final String birthYear; // e.g., "1988", "용띠"
  final String zodiacAnimal;
  final String description;
  final String? advice;

  const BirthYearFortune({
    required this.birthYear,
    required this.zodiacAnimal,
    required this.description,
    this.advice});

  @override
  List<Object?> get props => [birthYear, zodiacAnimal, description, advice];

  Map<String, dynamic> toJson() {
    return {
      'birthYear': birthYear,
      'zodiacAnimal': zodiacAnimal,
      'description': null,
      if (advice != null) 'advice': null};
  }
}