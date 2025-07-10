import '../../domain/entities/fortune.dart';
import '../../domain/entities/detailed_fortune.dart';

class FortuneResponseModel {
  final bool success;
  final String? message;
  final FortuneData? data;
  final int? tokensUsed;
  final int? remainingTokens;

  FortuneResponseModel({
    required this.success,
    this.message,
    this.data,
    this.tokensUsed,
    this.remainingTokens,
  });

  factory FortuneResponseModel.fromJson(Map<String, dynamic> json) {
    return FortuneResponseModel(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? FortuneData.fromJson(json['data']) : null,
      tokensUsed: json['tokensUsed'],
      remainingTokens: json['remainingTokens'],
    );
  }

  Fortune toEntity() {
    if (data == null) {
      throw Exception('No fortune data available');
    }

    // Extract common fields
    final overallScore = data!.score ?? 
        data!.compatibilityScore ?? 
        data!.energyLevel ?? 
        75;

    // Build score breakdown based on type
    final scoreBreakdown = <String, dynamic>{};
    if (data!.elements != null) {
      scoreBreakdown.addAll(data!.elements!);
    }
    if (data!.compatibilityScore != null) {
      scoreBreakdown['compatibility'] = data!.compatibilityScore!;
    }
    if (data!.energyLevel != null) {
      scoreBreakdown['energy'] = data!.energyLevel!;
    }
    if (data!.stressLevel != null) {
      scoreBreakdown['stress'] = data!.stressLevel!;
    }

    // Build lucky items
    final luckyItems = <String, dynamic>{};
    if (data!.luckyColor != null) {
      luckyItems['color'] = data!.luckyColor!;
    }
    if (data!.luckyNumber != null) {
      luckyItems['number'] = data!.luckyNumber!;
    }
    if (data!.bestTime != null) {
      luckyItems['time'] = data!.bestTime!;
    }

    // Build recommendations
    final recommendations = <String>[];
    if (data!.advice != null) {
      recommendations.add(data!.advice!);
    }
    if (data!.caution != null) {
      recommendations.add('주의: ${data!.caution!}');
    }
    recommendations.addAll(data!.strengthsList ?? []);

    return DetailedFortune(
      id: data!.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: data!.userId ?? '',
      type: data!.type,
      content: data!.content ?? data!.summary ?? '',
      createdAt: data!.createdAt ?? DateTime.now(),
      metadata: data!.metadata,
      tokenCost: tokensUsed ?? 1,
      category: data!.type,
      overallScore: overallScore,
      description: data!.summary ?? data!.content ?? '',
      scoreBreakdown: scoreBreakdown.map((key, value) => 
          MapEntry(key, value is int ? value : int.tryParse(value.toString()) ?? 0)),
      luckyItems: luckyItems,
      recommendations: recommendations,
    );
  }
}

class FortuneData {
  final String? id;
  final String? userId;
  final String type;
  final String? content;
  final DateTime? createdAt;
  final Map<String, dynamic>? metadata;
  
  // Daily fortune fields
  final int? score;
  final List<String>? keywords;
  final String? summary;
  final String? luckyColor;
  final int? luckyNumber;
  final int? energy;
  final String? mood;
  final String? advice;
  final String? caution;
  final String? bestTime;
  final String? compatibility;
  final Map<String, int>? elements;
  
  // Saju fortune fields
  final String? fourPillars;
  final String? element;
  final String? personality;
  final String? career;
  final String? wealth;
  final String? health;
  final String? relationship;
  final String? yearlyFortune;
  final String? monthlyFortune;
  final Map<String, dynamic>? detailedAnalysis;
  
  // MBTI fortune fields
  final String? mbtiType;
  final String? todayMood;
  final String? strengths;
  final String? weaknesses;
  final String? careerAdvice;
  final String? relationshipAdvice;
  final int? energyLevel;
  final int? stressLevel;
  
  // Compatibility fortune fields
  final int? compatibilityScore;
  final String? emotionalCompatibility;
  final String? communicationStyle;
  final String? conflictResolution;
  final String? longTermPotential;
  final List<String>? strengthsList;
  final List<String>? challenges;

  FortuneData({
    this.id,
    this.userId,
    required this.type,
    this.content,
    this.createdAt,
    this.metadata,
    this.score,
    this.keywords,
    this.summary,
    this.luckyColor,
    this.luckyNumber,
    this.energy,
    this.mood,
    this.advice,
    this.caution,
    this.bestTime,
    this.compatibility,
    this.elements,
    this.fourPillars,
    this.element,
    this.personality,
    this.career,
    this.wealth,
    this.health,
    this.relationship,
    this.yearlyFortune,
    this.monthlyFortune,
    this.detailedAnalysis,
    this.mbtiType,
    this.todayMood,
    this.strengths,
    this.weaknesses,
    this.careerAdvice,
    this.relationshipAdvice,
    this.energyLevel,
    this.stressLevel,
    this.compatibilityScore,
    this.emotionalCompatibility,
    this.communicationStyle,
    this.conflictResolution,
    this.longTermPotential,
    this.strengthsList,
    this.challenges,
  });

  factory FortuneData.fromJson(Map<String, dynamic> json) {
    return FortuneData(
      id: json['id'],
      userId: json['userId'],
      type: json['type'] ?? 'general',
      content: json['content'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      metadata: json['metadata'],
      
      // Daily fortune fields
      score: json['score'],
      keywords: json['keywords'] != null 
          ? List<String>.from(json['keywords']) 
          : null,
      summary: json['summary'],
      luckyColor: json['luckyColor'],
      luckyNumber: json['luckyNumber'],
      energy: json['energy'],
      mood: json['mood'],
      advice: json['advice'],
      caution: json['caution'],
      bestTime: json['bestTime'],
      compatibility: json['compatibility'],
      elements: json['elements'] != null 
          ? Map<String, int>.from(json['elements']) 
          : null,
      
      // Saju fortune fields
      fourPillars: json['fourPillars'],
      element: json['element'],
      personality: json['personality'],
      career: json['career'],
      wealth: json['wealth'],
      health: json['health'],
      relationship: json['relationship'],
      yearlyFortune: json['yearlyFortune'],
      monthlyFortune: json['monthlyFortune'],
      detailedAnalysis: json['detailedAnalysis'],
      
      // MBTI fortune fields
      mbtiType: json['mbtiType'],
      todayMood: json['todayMood'],
      strengths: json['strengths'],
      weaknesses: json['weaknesses'],
      careerAdvice: json['careerAdvice'],
      relationshipAdvice: json['relationshipAdvice'],
      energyLevel: json['energyLevel'],
      stressLevel: json['stressLevel'],
      
      // Compatibility fortune fields
      compatibilityScore: json['compatibilityScore'],
      emotionalCompatibility: json['emotionalCompatibility'],
      communicationStyle: json['communicationStyle'],
      conflictResolution: json['conflictResolution'],
      longTermPotential: json['longTermPotential'],
      strengthsList: json['strengthsList'] != null 
          ? List<String>.from(json['strengthsList']) 
          : null,
      challenges: json['challenges'] != null 
          ? List<String>.from(json['challenges']) 
          : null,
    );
  }

  // Convert to domain entities
  DailyFortune? toDailyFortune() {
    if (type != 'daily' && type != 'today' && type != 'tomorrow') return null;
    
    return DailyFortune(
      score: score ?? 75,
      keywords: keywords ?? ['행운', '기회', '성장'],
      summary: summary ?? content ?? '',
      luckyColor: luckyColor ?? '#8B5CF6',
      luckyNumber: luckyNumber ?? 7,
      energy: energy ?? 80,
      mood: mood ?? '평온함',
      advice: advice ?? '',
      caution: caution ?? '',
      bestTime: bestTime ?? '오후 2시-4시',
      compatibility: compatibility ?? '',
      elements: FortuneElements(
        love: elements?['love'] ?? 75,
        career: elements?['career'] ?? 80,
        money: elements?['money'] ?? 70,
        health: elements?['health'] ?? 85,
      ),
    );
  }

  SajuFortune? toSajuFortune() {
    if (type != 'saju' && type != 'traditional-saju') return null;
    
    return SajuFortune(
      fourPillars: fourPillars ?? '',
      element: element ?? '',
      personality: personality ?? '',
      career: career ?? '',
      wealth: wealth ?? '',
      health: health ?? '',
      relationship: relationship ?? '',
      yearlyFortune: yearlyFortune ?? '',
      monthlyFortune: monthlyFortune ?? '',
      advice: advice ?? '',
      detailedAnalysis: detailedAnalysis ?? {},
    );
  }

  MBTIFortune? toMBTIFortune() {
    if (type != 'mbti') return null;
    
    return MBTIFortune(
      mbtiType: mbtiType ?? '',
      todayMood: todayMood ?? '',
      strengths: strengths ?? '',
      weaknesses: weaknesses ?? '',
      advice: advice ?? '',
      compatibility: compatibility ?? '',
      careerAdvice: careerAdvice ?? '',
      relationshipAdvice: relationshipAdvice ?? '',
      energyLevel: energyLevel ?? 70,
      stressLevel: stressLevel ?? 30,
    );
  }

  CompatibilityFortune? toCompatibilityFortune() {
    if (type != 'compatibility' && type != 'traditional-compatibility') return null;
    
    return CompatibilityFortune(
      compatibilityScore: compatibilityScore ?? 0,
      summary: summary ?? content ?? '',
      emotionalCompatibility: emotionalCompatibility ?? '',
      communicationStyle: communicationStyle ?? '',
      conflictResolution: conflictResolution ?? '',
      longTermPotential: longTermPotential ?? '',
      strengths: strengthsList ?? [],
      challenges: challenges ?? [],
      advice: advice ?? '',
    );
  }

  Fortune toGeneralFortune() {
    return Fortune(
      id: id ?? '',
      userId: userId ?? '',
      type: type,
      content: content ?? '',
      createdAt: createdAt ?? DateTime.now(),
      metadata: metadata,
      tokenCost: 1, // 기본값, 실제로는 타입별로 다름
    );
  }
}