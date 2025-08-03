import '../../domain/entities/fortune.dart';
import '../../core/constants/fortune_detailed_metadata.dart';

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
      success: json['success'],
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
    if (data!.luckyDirection != null) {
      luckyItems['direction'] = data!.luckyDirection!;
    }
    if (data!.luckyFood != null) {
      luckyItems['food'] = data!.luckyFood!;
    }
    if (data!.luckyItem != null) {
      luckyItems['item'] = data!.luckyItem!;
    }

    // Build detailed lucky items
    final detailedLuckyItems = <String, List<DetailedLuckyItem>>{};
    if (data!.detailedLuckyNumbers != null) {
      detailedLuckyItems['numbers'] = (data!.detailedLuckyNumbers as List)
          .map((item) => DetailedLuckyItem.fromJson(item))
          .toList();
    }
    if (data!.detailedLuckyColors != null) {
      detailedLuckyItems['colors'] = (data!.detailedLuckyColors as List)
          .map((item) => DetailedLuckyItem.fromJson(item))
          .toList();
    }
    if (data!.detailedLuckyFoods != null) {
      detailedLuckyItems['foods'] = (data!.detailedLuckyFoods as List)
          .map((item) => DetailedLuckyItem.fromJson(item))
          .toList();
    }
    if (data!.detailedLuckyItems != null) {
      detailedLuckyItems['items'] = (data!.detailedLuckyItems as List)
          .map((item) => DetailedLuckyItem.fromJson(item))
          .toList();
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

    return Fortune(
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
      scoreBreakdown: scoreBreakdown.isNotEmpty ? scoreBreakdown : null,
      luckyItems: luckyItems.isNotEmpty ? luckyItems : null,
      recommendations: recommendations.isNotEmpty ? recommendations : null,
      warnings: data!.caution != null ? [data!.caution!] : null,
      summary: data!.summary,
      additionalInfo: {
        if (data!.advice != null) 'advice': null,
        if (data!.luckyColor != null) 'luckyColor': null,
        if (data!.luckyNumber != null) 'luckyNumber': null,
        if (data!.score != null) 'score': null,
      },
      detailedLuckyItems: detailedLuckyItems.isNotEmpty ? detailedLuckyItems : null,
      greeting: data!.greeting,
      hexagonScores: data!.hexagonScores,
      timeSpecificFortunes: data!.timeSpecificFortunes != null
          ? (data!.timeSpecificFortunes as List).map((item) => TimeSpecificFortune(
              time: item['time'] ?? '',
              title: item['title'] ?? '',
              score: item['score'],
              description: item['description'] ?? '',
              recommendation: item['recommendation'],
            )).toList()
          : null,
      birthYearFortunes: data!.birthYearFortunes != null
          ? (data!.birthYearFortunes as List).map((item) => BirthYearFortune(
              birthYear: item['birthYear'] ?? '',
              zodiacAnimal: item['zodiacAnimal'] ?? '',
              description: item['description'] ?? '',
              advice: item['advice'],
            )).toList()
          : null,
      fiveElements: data!.fiveElements,
      specialTip: data!.specialTip,
      period: data!.period
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
  
  // Additional lucky item fields
  final String? luckyDirection;
  final String? luckyFood;
  final String? luckyItem;
  
  // Detailed lucky items
  final List<dynamic>? detailedLuckyNumbers;
  final List<dynamic>? detailedLuckyColors;
  final List<dynamic>? detailedLuckyFoods;
  final List<dynamic>? detailedLuckyItems;
  
  // Enhanced fields for time-based fortunes
  final String? greeting;
  final Map<String, int>? hexagonScores;
  final List<dynamic>? timeSpecificFortunes;
  final List<dynamic>? birthYearFortunes;
  final Map<String, dynamic>? fiveElements;
  final String? specialTip;
  final String? period;

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
    this.luckyDirection,
    this.luckyFood,
    this.luckyItem,
    this.detailedLuckyNumbers,
    this.detailedLuckyColors,
    this.detailedLuckyFoods,
    this.detailedLuckyItems,
    this.greeting,
    this.hexagonScores,
    this.timeSpecificFortunes,
    this.birthYearFortunes,
    this.fiveElements,
    this.specialTip,
    this.period,
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
      
      // Daily fortune fields,
    score: json['score'] ?? json['overall_score'],
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
      
      // Saju fortune fields,
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
      
      // MBTI fortune fields,
    mbtiType: json['mbtiType'],
      todayMood: json['todayMood'],
      strengths: json['strengths'],
      weaknesses: json['weaknesses'],
      careerAdvice: json['careerAdvice'],
      relationshipAdvice: json['relationshipAdvice'],
      energyLevel: json['energyLevel'],
      stressLevel: json['stressLevel'],
      
      // Compatibility fortune fields,
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
      
      // Additional lucky items,
    luckyDirection: json['luckyDirection'],
      luckyFood: json['luckyFood'],
      luckyItem: json['luckyItem'],
      
      // Detailed lucky items,
    detailedLuckyNumbers: json['detailedLuckyNumbers'],
      detailedLuckyColors: json['detailedLuckyColors'],
      detailedLuckyFoods: json['detailedLuckyFoods'],
      detailedLuckyItems: json['detailedLuckyItems'],
      
      // Enhanced time-based fortune fields,
    greeting: json['greeting'],
      hexagonScores: json['hexagonScores'] != null 
          ? Map<String, int>.from(json['hexagonScores']) 
          : null,
      timeSpecificFortunes: json['timeSpecificFortunes'],
      birthYearFortunes: json['birthYearFortunes'],
      fiveElements: json['fiveElements'],
      specialTip: json['special_tip'] ?? json['specialTip'],
      period: json['period'],
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
        love: elements?['love'] ?? 50,
        career: elements?['career'] ?? 50,
        money: elements?['money'] ?? 50,
        health: elements?['health'] ?? 50,
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
      advice: advice ?? ''
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