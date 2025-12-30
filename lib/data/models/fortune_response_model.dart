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
    this.remainingTokens});

  factory FortuneResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle three cases:
    // 1. Traditional API response: { success: bool, data: {...}, tokensUsed: int }
    // 2. Edge Functions response: { fortune: {...}, storySegments: [...], tokensUsed: int }
    // 3. Direct fortune data format (no wrapper)

    FortuneData? fortuneData;

    if (json['data'] != null) {
      // Traditional API format
      fortuneData = FortuneData.fromJson(json['data']);
    } else if (json['fortune'] != null) {
      // Edge Functions format - fortune field contains the actual fortune data
      fortuneData = FortuneData.fromJson(json['fortune']);
    } else if (json.containsKey('overall_score') || json.containsKey('summary') || json.containsKey('advice')) {
      // Direct fortune data format (Edge Functions fortune object)
      fortuneData = FortuneData.fromJson(json);
    }

    return FortuneResponseModel(
      success: json['success'] ?? true,  // Default to true if not provided
      message: json['message'],
      data: fortuneData,
      tokensUsed: json['tokensUsed'],
      remainingTokens: json['remainingTokens']);
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
      // ✅ additionalInfo: metadata 전체를 전달하여 커리어/기타 운세 상세 데이터 접근 가능
      additionalInfo: data!.metadata ?? {
        if (data!.advice != null) 'advice': data!.advice,
        if (data!.luckyColor != null) 'luckyColor': data!.luckyColor,
        if (data!.luckyNumber != null) 'luckyNumber': data!.luckyNumber,
        if (data!.score != null) 'score': data!.score,
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
              recommendation: item['recommendation'])).toList()
          : null,
      birthYearFortunes: data!.birthYearFortunes != null
          ? (data!.birthYearFortunes as List).map((item) => BirthYearFortune(
              birthYear: item['birthYear'] ?? '',
              zodiacAnimal: item['zodiacAnimal'] ?? '',
              description: item['description'] ?? '',
              advice: item['advice'])).toList()
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
  final List<String>? compatibility;
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
  final List<String>? cognitiveStrengths;
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
    this.cognitiveStrengths,
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
    this.period});

  factory FortuneData.fromJson(Map<String, dynamic> json) {
    // Handle fortune-specific content mapping
    String? content = json['content'];
    String? summary = json['summary'];
    String? advice = json['advice'];
    int? score = json['score'] ?? json['overall_score'] ?? json['overallScore'];

    // Career fortune: map careerScore and overallOutlook
    if (json['fortuneType'] == 'career' || json['type'] == 'career' ||
        json['fortune_type'] == 'career' ||
        json['fortuneType']?.toString().startsWith('career') == true ||
        json['fortune_type']?.toString().startsWith('career') == true) {
      score ??= json['careerScore'] as int?;
      summary ??= json['overallOutlook'] as String?;

      final actionPlan = json['actionPlan'] as Map<String, dynamic>?;

      // Build content from career sections
      final contentParts = <String>[];
      if (json['overallOutlook'] != null) contentParts.add(json['overallOutlook'] as String);

      if (actionPlan != null) {
        if (actionPlan['immediate'] != null) {
          final immediate = (actionPlan['immediate'] as List).join('\n• ');
          contentParts.add('\n\n⚡ 즉시 실행\n• $immediate');
        }
        if (actionPlan['shortTerm'] != null) {
          final shortTerm = (actionPlan['shortTerm'] as List).join('\n• ');
          contentParts.add('\n\n📅 단기 목표\n• $shortTerm');
        }
        if (actionPlan['longTerm'] != null) {
          final longTerm = (actionPlan['longTerm'] as List).join('\n• ');
          contentParts.add('\n\n🎯 장기 목표\n• $longTerm');
        }
      }

      if (json['industryInsights'] != null) {
        contentParts.add('\n\n💼 업계 인사이트\n${json['industryInsights']}');
      }

      if (json['networkingAdvice'] != null) {
        final networking = (json['networkingAdvice'] as List).join('\n• ');
        contentParts.add('\n\n🤝 네트워킹 조언\n• $networking');
      }

      if (json['mentorshipAdvice'] != null) {
        advice ??= json['mentorshipAdvice'] as String?;
        contentParts.add('\n\n👨‍🏫 멘토링 조언\n${json['mentorshipAdvice']}');
      }

      if (contentParts.isNotEmpty) {
        content = contentParts.join('');
      }
    }

    // Love fortune: extract content from detailed fields
    if (json['fortuneType'] == 'love' || json['type'] == 'love' ||
        json['fortune_type'] == 'love') {
      score ??= json['loveScore'] as int?;
      // Build comprehensive content from love fortune fields
      final mainMessage = json['mainMessage'] as String?;
      final loveProfile = json['loveProfile'] as Map<String, dynamic>?;
      final detailedAnalysis = json['detailedAnalysis'] as Map<String, dynamic>?;
      final todaysAdvice = json['todaysAdvice'] as Map<String, dynamic>?;
      final predictions = json['predictions'] as Map<String, dynamic>?;
      final actionPlan = json['actionPlan'] as Map<String, dynamic>?;

      summary ??= mainMessage;

      // Build content from all sections
      final contentParts = <String>[];
      if (mainMessage != null) contentParts.add(mainMessage);

      if (loveProfile != null) {
        if (loveProfile['currentState'] != null) contentParts.add('\n\n💕 현재 연애 상태\n${loveProfile['currentState']}');
        if (loveProfile['attractionPoints'] != null) contentParts.add('\n\n✨ 매력 포인트\n${loveProfile['attractionPoints']}');
        if (loveProfile['loveStyle'] != null) contentParts.add('\n\n💝 연애 스타일\n${loveProfile['loveStyle']}');
      }

      if (detailedAnalysis != null) {
        if (detailedAnalysis['emotionalState'] != null) contentParts.add('\n\n🌸 감정 상태\n${detailedAnalysis['emotionalState']}');
        if (detailedAnalysis['relationshipDynamics'] != null) contentParts.add('\n\n💑 관계 역학\n${detailedAnalysis['relationshipDynamics']}');
        if (detailedAnalysis['growthOpportunities'] != null) contentParts.add('\n\n🌱 성장 기회\n${detailedAnalysis['growthOpportunities']}');
      }

      if (todaysAdvice != null) {
        if (todaysAdvice['mainAdvice'] != null) {
          advice ??= todaysAdvice['mainAdvice'] as String?;
          contentParts.add('\n\n💡 오늘의 조언\n${todaysAdvice['mainAdvice']}');
        }
        if (todaysAdvice['doList'] != null) {
          final doList = (todaysAdvice['doList'] as List).join('\n• ');
          contentParts.add('\n\n✅ 해야 할 것\n• $doList');
        }
        if (todaysAdvice['dontList'] != null) {
          final dontList = (todaysAdvice['dontList'] as List).join('\n• ');
          contentParts.add('\n\n❌ 피해야 할 것\n• $dontList');
        }
      }

      if (predictions != null) {
        if (predictions['shortTerm'] != null) contentParts.add('\n\n📅 단기 예측\n${predictions['shortTerm']}');
        if (predictions['longTerm'] != null) contentParts.add('\n\n🔮 장기 예측\n${predictions['longTerm']}');
      }

      if (actionPlan != null) {
        if (actionPlan['immediateAction'] != null) contentParts.add('\n\n⚡ 즉시 행동\n${actionPlan['immediateAction']}');
        if (actionPlan['weeklyGoal'] != null) contentParts.add('\n\n🎯 이번 주 목표\n${actionPlan['weeklyGoal']}');
      }

      if (contentParts.isNotEmpty) {
        content = contentParts.join('');
      }
    }

    // Compatibility fortune: map compatibility-specific fields
    if (json['fortuneType'] == 'compatibility' ||
        json['type'] == 'compatibility' ||
        json['fortune_type'] == 'compatibility') {
      score ??= json['score'] as int?;

      // Extract compatibility data
      final overallCompatibility = json['overall_compatibility'] as String?;
      final personalityMatch = json['personality_match'] as String?;
      final loveMatch = json['love_match'] as String?;
      final marriageMatch = json['marriage_match'] as String?;
      final communicationMatch = json['communication_match'] as String?;
      final strengths = json['strengths'] as List?;
      final cautions = json['cautions'] as List?;
      final detailedAdvice = json['detailed_advice'] as String?;
      final compatibilityKeyword = json['compatibility_keyword'] as String?;
      final zodiacAnimal = json['zodiac_animal'] as Map<String, dynamic>?;
      final starSign = json['star_sign'] as Map<String, dynamic>?;
      final destinyNumber = json['destiny_number'] as Map<String, dynamic>?;
      final ageDifference = json['age_difference'] as Map<String, dynamic>?;
      final loveStyle = json['love_style'] as Map<String, dynamic>?;

      summary ??= overallCompatibility ?? compatibilityKeyword;

      // Build content from all compatibility sections
      final contentParts = <String>[];

      if (overallCompatibility != null) {
        contentParts.add('💕 전반적인 궁합\n$overallCompatibility');
      }

      if (zodiacAnimal != null) {
        contentParts.add('\n\n🐉 띠 궁합\n${zodiacAnimal['person1']} ♥ ${zodiacAnimal['person2']}: ${zodiacAnimal['message']} (${zodiacAnimal['score']}점)');
      }

      if (starSign != null) {
        contentParts.add('\n\n⭐ 별자리 궁합\n${starSign['person1']} ♥ ${starSign['person2']}: ${starSign['message']} (${starSign['score']}점)');
      }

      if (destinyNumber != null) {
        contentParts.add('\n\n🔮 운명수: ${destinyNumber['number']} - ${destinyNumber['meaning']}');
      }

      if (ageDifference != null) {
        contentParts.add('\n\n👫 나이 차이: ${ageDifference['years']}살 - ${ageDifference['message']}');
      }

      if (personalityMatch != null) {
        contentParts.add('\n\n💜 성격 궁합\n$personalityMatch');
      }

      if (loveMatch != null) {
        contentParts.add('\n\n💘 애정 궁합\n$loveMatch');
      }

      if (marriageMatch != null) {
        contentParts.add('\n\n💍 결혼 궁합\n$marriageMatch');
      }

      if (communicationMatch != null) {
        contentParts.add('\n\n💬 소통 궁합\n$communicationMatch');
      }

      if (loveStyle != null) {
        contentParts.add('\n\n💝 연애 스타일\n${loveStyle['person1']} × ${loveStyle['person2']}\n${loveStyle['조합분석'] ?? ''}');
      }

      if (strengths != null && strengths.isNotEmpty) {
        final strengthsStr = strengths.join('\n• ');
        contentParts.add('\n\n✨ 강점\n• $strengthsStr');
      }

      if (cautions != null && cautions.isNotEmpty) {
        final cautionsStr = cautions.join('\n• ');
        contentParts.add('\n\n⚠️ 주의점\n• $cautionsStr');
      }

      if (detailedAdvice != null) {
        advice ??= detailedAdvice;
        contentParts.add('\n\n💡 조언\n$detailedAdvice');
      }

      if (contentParts.isNotEmpty) {
        content = contentParts.join('');
      }
    }

    // Avoid-people fortune: map caution-specific fields to metadata
    Map<String, dynamic>? metadata = json['metadata'];
    if (json['fortuneType'] == 'avoid-people' || json['type'] == 'avoid-people' ||
        json['fortune_type'] == 'avoid-people') {
      score ??= json['score'] as int?;
      summary ??= (json['summary'] is Map)
          ? json['summary']['text'] as String?
          : json['summary'] as String?;

      // Store all caution data in metadata for ChatFortuneResultCard access
      metadata = {
        ...?metadata,
        if (json['cautionPeople'] != null) 'cautionPeople': json['cautionPeople'],
        if (json['cautionObjects'] != null) 'cautionObjects': json['cautionObjects'],
        if (json['cautionColors'] != null) 'cautionColors': json['cautionColors'],
        if (json['cautionNumbers'] != null) 'cautionNumbers': json['cautionNumbers'],
        if (json['cautionAnimals'] != null) 'cautionAnimals': json['cautionAnimals'],
        if (json['cautionPlaces'] != null) 'cautionPlaces': json['cautionPlaces'],
        if (json['cautionTimes'] != null) 'cautionTimes': json['cautionTimes'],
        if (json['cautionDirections'] != null) 'cautionDirections': json['cautionDirections'],
        if (json['luckyElements'] != null) 'luckyElements': json['luckyElements'],
        if (json['timeStrategy'] != null) 'timeStrategy': json['timeStrategy'],
        'fortuneType': 'avoid-people',
      };

      // Build content preview from caution items
      final contentParts = <String>[];
      if (summary != null) contentParts.add(summary);

      // Add first caution person as preview (API uses 'type' and 'reason')
      if (json['cautionPeople'] != null && (json['cautionPeople'] as List).isNotEmpty) {
        final firstPerson = json['cautionPeople'][0];
        contentParts.add('\n\n👤 주요 경계 인물: ${firstPerson['type'] ?? ''}');
        if (firstPerson['reason'] != null) {
          contentParts.add('\n${firstPerson['reason']}');
        }
      }

      // Add first caution object as preview (API uses 'item' and 'reason')
      if (json['cautionObjects'] != null && (json['cautionObjects'] as List).isNotEmpty) {
        final firstObject = json['cautionObjects'][0];
        contentParts.add('\n\n📦 주요 경계 사물: ${firstObject['item'] ?? ''}');
        if (firstObject['reason'] != null) {
          contentParts.add('\n${firstObject['reason']}');
        }
      }

      if (contentParts.isNotEmpty) {
        content = contentParts.join('');
      }
    }

    // Time fortune: map time-specific fields to metadata (경계대상 패턴 적용)
    if (json['fortuneType'] == 'time' || json['type'] == 'time' ||
        json['fortune_type'] == 'time' || json['type'] == 'time_based') {
      score ??= json['score'] as int?;
      summary ??= json['summary'] as String?;
      advice ??= json['advice'] as String?;

      // Store all time fortune data in metadata for UI access
      metadata = {
        ...?metadata,
        if (json['timeSlots'] != null) 'timeSlots': json['timeSlots'],
        if (json['cautionTimes'] != null) 'cautionTimes': json['cautionTimes'],
        if (json['cautionActivities'] != null) 'cautionActivities': json['cautionActivities'],
        if (json['cautionPeople'] != null) 'cautionPeople': json['cautionPeople'],
        if (json['cautionDirections'] != null) 'cautionDirections': json['cautionDirections'],
        if (json['luckyElements'] != null) 'luckyElements': json['luckyElements'],
        if (json['timeStrategy'] != null) 'timeStrategy': json['timeStrategy'],
        if (json['traditionalElements'] != null) 'traditionalElements': json['traditionalElements'],
        if (json['bestTime'] != null) 'bestTime': json['bestTime'],
        if (json['worstTime'] != null) 'worstTime': json['worstTime'],
        'fortuneType': 'time',
      };

      // Build content from time fortune sections
      final contentParts = <String>[];
      if (summary != null) contentParts.add(summary);

      // Add time strategy preview
      final timeStrategy = json['timeStrategy'] as Map<String, dynamic>?;
      if (timeStrategy != null) {
        final morning = timeStrategy['morning'] as Map<String, dynamic>?;
        if (morning?['advice'] != null) {
          contentParts.add('\n\n🌅 오전: ${morning!['advice']}');
        }
        final afternoon = timeStrategy['afternoon'] as Map<String, dynamic>?;
        if (afternoon?['advice'] != null) {
          contentParts.add('\n🌤️ 오후: ${afternoon!['advice']}');
        }
        final evening = timeStrategy['evening'] as Map<String, dynamic>?;
        if (evening?['advice'] != null) {
          contentParts.add('\n🌙 저녁: ${evening!['advice']}');
        }
      }

      // Add best/worst time preview
      final bestTime = json['bestTime'] as Map<String, dynamic>?;
      if (bestTime?['period'] != null) {
        contentParts.add('\n\n⭐ 최고 시간: ${bestTime!['period']}');
      }
      final worstTime = json['worstTime'] as Map<String, dynamic>?;
      if (worstTime?['period'] != null) {
        contentParts.add('\n⚠️ 주의 시간: ${worstTime!['period']}');
      }

      if (contentParts.isNotEmpty) {
        content = contentParts.join('');
      }
    }

    return FortuneData(
      id: json['id'],
      userId: json['userId'],
      type: json['type'] ?? json['fortuneType'] ?? json['fortune_type'] ?? 'daily',
      content: content,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      metadata: metadata,

      // Daily fortune fields - with fortune-specific mapping
      score: score,
      keywords: json['keywords'] != null
          ? List<String>.from(json['keywords'])
          : null,
      summary: summary,
      luckyColor: json['luckyColor'] ?? json['lucky_items']?['color'],
      luckyNumber: json['luckyNumber'] ?? json['lucky_items']?['number'],
      energy: json['energy'],
      mood: json['mood'],
      advice: advice ?? json['advice'],
      caution: json['caution'],
      bestTime: json['bestTime'] ?? json['lucky_items']?['time'],
      compatibility: json['compatibility'] != null
          ? (json['compatibility'] is List
              ? List<String>.from(json['compatibility'])
              : [json['compatibility'].toString()])
          : null,
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
      cognitiveStrengths: json['cognitiveStrengths'] != null
          ? List<String>.from(json['cognitiveStrengths'])
          : null,
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
    luckyDirection: json['luckyDirection'] ?? json['lucky_items']?['direction'],
      luckyFood: json['luckyFood'] ?? json['lucky_items']?['food'],
      luckyItem: json['luckyItem'] ?? json['lucky_items']?['item'],
      
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
      period: json['period']);
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
      compatibility: compatibility?.join(', ') ?? '',
      elements: FortuneElements(
        love: elements?['love'] ?? 50,
        career: elements?['career'] ?? 50,
        money: elements?['money'] ?? 50,
        health: elements?['health'] ?? 50));
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
      detailedAnalysis: detailedAnalysis ?? {});
  }

  MBTIFortune? toMBTIFortune() {
    if (type != 'mbti') return null;
    
    return MBTIFortune(
      mbtiType: mbtiType ?? '',
      todayMood: todayMood ?? '',
      strengths: strengths ?? '',
      weaknesses: weaknesses ?? '',
      advice: advice ?? '',
      compatibility: compatibility?.join(', ') ?? '',
      careerAdvice: careerAdvice ?? '',
      relationshipAdvice: relationshipAdvice ?? '',
      energyLevel: energyLevel ?? 70,
      stressLevel: stressLevel ?? 30);
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