import 'dart:math' as math;
import 'mbti_cognitive_functions_service.dart';

/// MBTI 운세 강화 서비스 - 특별한 MBTI 운세 기능
class MbtiFortuneEnhancedService {
  
  // ==========================================
  // 1. 오늘의 에너지 레벨 계산
  // ==========================================
  
  /// MBTI 에너지 레벨 계산 (외향/내향 에너지)
  static Map<String, dynamic> calculateDailyEnergy(String mbtiType, DateTime date) {
    final isExtrovert = mbtiType[0] == 'E';
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final random = math.Random(seed + mbtiType.hashCode);
    
    // 바이오리듬 패턴 (28일 주기)
    final dayInCycle = date.difference(DateTime(date.year, 1, 1)).inDays % 28;
    final biorhythm = math.sin(2 * math.pi * dayInCycle / 28);
    
    // 기본 에너지 레벨
    double socialEnergy = isExtrovert ? 
        0.7 + biorhythm * 0.2 + random.nextDouble() * 0.1 :
        0.3 + biorhythm * 0.2 + random.nextDouble() * 0.1;
        
    double aloneEnergy = !isExtrovert ?
        0.7 + biorhythm * 0.2 + random.nextDouble() * 0.1 :
        0.3 + biorhythm * 0.2 + random.nextDouble() * 0.1;
    
    // 요일별 보정
    final weekday = date.weekday;
    if (weekday >= 6) { // 주말
      aloneEnergy *= 1.1;
      socialEnergy *= 0.9;
    } else { // 평일
      socialEnergy *= 1.1;
      aloneEnergy *= 0.9;
    }
    
    // 전체 에너지 레벨
    final totalEnergy = (socialEnergy + aloneEnergy) / 2;
    
    // 최적 활동 시간대 계산
    final peakTime = _calculatePeakTime(mbtiType, date);
    
    // 번아웃 위험도
    final burnoutRisk = _calculateBurnoutRisk(mbtiType, totalEnergy, date);
    
    return {
      'socialBattery': (socialEnergy * 100).round(),
      'aloneBattery': (aloneEnergy * 100).round(),
      'totalEnergy': (totalEnergy * 100).round(),
      'peakTime': peakTime,
      'burnoutRisk': burnoutRisk,
      'energyAdvice': _getEnergyAdvice(isExtrovert, socialEnergy, aloneEnergy),
    };
  }
  
  /// 최적 활동 시간대 계산
  static Map<String, dynamic> _calculatePeakTime(String mbtiType, DateTime date) {
    final seed = date.hashCode + mbtiType.hashCode;
    final random = math.Random(seed);
    
    // MBTI 유형별 기본 패턴
    final patterns = {
      'INTJ': {'morning': 0.7, 'afternoon': 0.8, 'evening': 0.9, 'night': 0.6},
      'INTP': {'morning': 0.5, 'afternoon': 0.7, 'evening': 0.8, 'night': 0.9},
      'ENTJ': {'morning': 0.9, 'afternoon': 0.8, 'evening': 0.6, 'night': 0.4},
      'ENTP': {'morning': 0.6, 'afternoon': 0.8, 'evening': 0.9, 'night': 0.7},
      'INFJ': {'morning': 0.8, 'afternoon': 0.6, 'evening': 0.7, 'night': 0.5},
      'INFP': {'morning': 0.6, 'afternoon': 0.7, 'evening': 0.8, 'night': 0.7},
      'ENFJ': {'morning': 0.8, 'afternoon': 0.9, 'evening': 0.7, 'night': 0.5},
      'ENFP': {'morning': 0.7, 'afternoon': 0.8, 'evening': 0.9, 'night': 0.6},
      'ISTJ': {'morning': 0.9, 'afternoon': 0.8, 'evening': 0.6, 'night': 0.4},
      'ISFJ': {'morning': 0.8, 'afternoon': 0.7, 'evening': 0.6, 'night': 0.4},
      'ESTJ': {'morning': 0.9, 'afternoon': 0.8, 'evening': 0.6, 'night': 0.3},
      'ESFJ': {'morning': 0.8, 'afternoon': 0.9, 'evening': 0.7, 'night': 0.4},
      'ISTP': {'morning': 0.7, 'afternoon': 0.8, 'evening': 0.7, 'night': 0.6},
      'ISFP': {'morning': 0.6, 'afternoon': 0.7, 'evening': 0.8, 'night': 0.6},
      'ESTP': {'morning': 0.7, 'afternoon': 0.9, 'evening': 0.8, 'night': 0.6},
      'ESFP': {'morning': 0.7, 'afternoon': 0.8, 'evening': 0.9, 'night': 0.7},
    };
    
    final pattern = patterns[mbtiType] ?? patterns['INFP']!;
    
    // 오늘의 변동 적용
    final todayPattern = <String, int>{};
    pattern.forEach((time, baseValue) {
      final variation = random.nextDouble() * 0.2 - 0.1; // ±10% 변동
      todayPattern[time] = ((baseValue + variation) * 100).clamp(0, 100).round();
    });
    
    // 최고 시간대 찾기
    final bestTime = todayPattern.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    
    return {
      'pattern': todayPattern,
      'bestTime': bestTime.key,
      'bestValue': bestTime.value,
      'schedule': _generateScheduleAdvice(bestTime.key, mbtiType),
    };
  }
  
  /// 번아웃 위험도 계산
  static Map<String, dynamic> _calculateBurnoutRisk(
      String mbtiType, double totalEnergy, DateTime date) {
    final seed = date.hashCode;
    final random = math.Random(seed);
    
    // 기본 위험도 (에너지 레벨 반비례)
    double risk = (1 - totalEnergy) * 50;
    
    // MBTI별 번아웃 취약성
    final vulnerabilities = {
      'INTJ': 0.7, 'INTP': 0.6, 'ENTJ': 0.8, 'ENTP': 0.5,
      'INFJ': 0.9, 'INFP': 0.8, 'ENFJ': 0.7, 'ENFP': 0.6,
      'ISTJ': 0.7, 'ISFJ': 0.8, 'ESTJ': 0.7, 'ESFJ': 0.6,
      'ISTP': 0.5, 'ISFP': 0.6, 'ESTP': 0.4, 'ESFP': 0.5,
    };
    
    risk += vulnerabilities[mbtiType]! * 20;
    
    // 요일별 스트레스 (월요일 높음, 주말 낮음)
    final weekday = date.weekday;
    if (weekday == 1) risk += 15; // 월요일
    else if (weekday >= 6) risk -= 10; // 주말
    
    // 랜덤 변동
    risk += random.nextDouble() * 20 - 10;
    
    risk = risk.clamp(0, 100);
    
    String level;
    String advice;
    
    if (risk < 30) {
      level = '안전';
      advice = '에너지가 충분합니다. 도전적인 과제에 집중하세요.';
    } else if (risk < 50) {
      level = '주의';
      advice = '적절한 휴식을 취하며 페이스를 조절하세요.';
    } else if (risk < 70) {
      level = '경고';
      advice = '스트레스 관리가 필요합니다. 명상이나 운동을 추천합니다.';
    } else {
      level = '위험';
      advice = '충분한 휴식이 필수입니다. 일정을 조정하고 재충전하세요.';
    }
    
    return {
      'percentage': risk.round(),
      'level': level,
      'advice': advice,
      'rechargeMethod': _getRechargeMethod(mbtiType),
    };
  }
  
  // ==========================================
  // 2. 인지기능 퀘스트 시스템
  // ==========================================
  
  /// 오늘의 인지기능 퀘스트 생성
  static List<Map<String, dynamic>> generateCognitiveQuests(
      String mbtiType, DateTime date) {
    final stack = MbtiCognitiveFunctionsService.mbtiStacks[mbtiType]!;
    final seed = date.hashCode + mbtiType.hashCode;
    final random = math.Random(seed);
    
    final quests = <Map<String, dynamic>>[];
    
    // 주기능 강화 퀘스트
    quests.add(_createQuest(
      function: stack[0],
      type: '주기능 강화',
      difficulty: 'easy',
      points: 100,
      random: random,
    ));
    
    // 보조기능 활용 퀘스트
    quests.add(_createQuest(
      function: stack[1],
      type: '보조기능 활용',
      difficulty: 'medium',
      points: 150,
      random: random,
    ));
    
    // 열등기능 도전 퀘스트
    quests.add(_createQuest(
      function: stack[3],
      type: '열등기능 도전',
      difficulty: 'hard',
      points: 300,
      random: random,
    ));
    
    // 그림자 기능 탐험 (선택)
    if (random.nextDouble() > 0.5) {
      final shadowIndex = 4 + random.nextInt(4);
      quests.add(_createQuest(
        function: stack[shadowIndex],
        type: '그림자 기능 탐험',
        difficulty: 'legendary',
        points: 500,
        random: random,
      ));
    }
    
    return quests;
  }
  
  /// 퀘스트 생성 헬퍼
  static Map<String, dynamic> _createQuest({
    required String function,
    required String type,
    required String difficulty,
    required int points,
    required math.Random random,
  }) {
    final questTemplates = {
      'Te': [
        '오늘 할 일 목록을 작성하고 우선순위를 정하세요',
        '프로젝트 일정을 체계적으로 정리하세요',
        '비효율적인 프로세스 하나를 개선하세요',
      ],
      'Ti': [
        '복잡한 문제를 논리적으로 분석해보세요',
        '관심 분야의 새로운 개념을 깊이 있게 학습하세요',
        '기존 시스템의 논리적 오류를 찾아보세요',
      ],
      'Fe': [
        '주변 사람들의 감정을 파악하고 공감해주세요',
        '팀원들과 조화로운 분위기를 만들어보세요',
        '누군가를 진심으로 칭찬하거나 격려하세요',
      ],
      'Fi': [
        '자신의 가치관을 돌아보는 시간을 가지세요',
        '진정으로 원하는 것이 무엇인지 생각해보세요',
        '감정 일기를 작성해보세요',
      ],
      'Ne': [
        '평소와 다른 새로운 방법을 시도해보세요',
        '브레인스토밍으로 창의적인 아이디어를 내보세요',
        '서로 다른 개념을 연결해 새로운 통찰을 얻으세요',
      ],
      'Ni': [
        '미래 비전을 구체적으로 그려보세요',
        '복잡한 패턴 속에서 핵심을 찾아보세요',
        '직관을 믿고 중요한 결정을 내려보세요',
      ],
      'Se': [
        '오감을 활용한 새로운 경험을 해보세요',
        '야외 활동이나 운동을 즐겨보세요',
        '현재 순간에 온전히 집중해보세요',
      ],
      'Si': [
        '과거의 좋은 경험을 떠올리며 감사해보세요',
        '일상 루틴을 개선해보세요',
        '건강한 습관을 하나 실천해보세요',
      ],
    };
    
    final templates = questTemplates[function] ?? ['자기 개발 활동을 해보세요'];
    final questText = templates[random.nextInt(templates.length)];
    
    final difficultyColors = {
      'easy': '#10B981',
      'medium': '#3182F6',
      'hard': '#F59E0B',
      'legendary': '#8B5CF6',
    };
    
    return {
      'id': '${function}_${type}_${DateTime.now().millisecondsSinceEpoch}',
      'function': function,
      'type': type,
      'difficulty': difficulty,
      'color': difficultyColors[difficulty],
      'quest': questText,
      'points': points,
      'completed': false,
      'icon': MbtiCognitiveFunctionsService.functionDescriptions[function]!['icon'],
    };
  }
  
  // ==========================================
  // 3. MBTI 시너지 분석
  // ==========================================
  
  /// 오늘의 MBTI 시너지 계산
  static Map<String, dynamic> analyzeDailySynergy(String myType, DateTime date) {
    final seed = date.hashCode + myType.hashCode;
    final random = math.Random(seed);
    
    final allTypes = MbtiCognitiveFunctionsService.mbtiDescriptions.keys.toList();
    final synergyScores = <String, double>{};
    
    // 각 타입과의 오늘 시너지 계산
    for (final otherType in allTypes) {
      if (otherType == myType) continue;
      
      final baseCompatibility = MbtiCognitiveFunctionsService
          .calculateCompatibility(myType, otherType);
      
      // 오늘의 변동 (±20%)
      final todayVariation = random.nextDouble() * 0.4 - 0.2;
      final todayScore = (baseCompatibility + todayVariation).clamp(0.0, 1.0);
      
      synergyScores[otherType] = todayScore;
    }
    
    // 정렬
    final sortedScores = synergyScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // 최고/최저 3개씩
    final best = sortedScores.take(3).toList();
    final worst = sortedScores.reversed.take(3).toList();
    
    // 오늘의 특별 시너지 (랜덤하게 하나 선택)
    final specialIndex = random.nextInt(sortedScores.length ~/ 2);
    final special = sortedScores[specialIndex];
    
    return {
      'bestMatches': best.map((e) => {
        'type': e.key,
        'score': (e.value * 100).round(),
        'reason': _getSynergyReason(myType, e.key, true),
      }).toList(),
      'worstMatches': worst.map((e) => {
        'type': e.key,
        'score': (e.value * 100).round(),
        'reason': _getSynergyReason(myType, e.key, false),
      }).toList(),
      'todaySpecial': {
        'type': special.key,
        'score': (special.value * 100).round(),
        'message': _getSpecialSynergyMessage(myType, special.key),
      },
      'communicationTip': _getCommunicationTip(myType, date),
    };
  }
  
  // ==========================================
  // 4. 인지기능 날씨 시스템
  // ==========================================
  
  /// 인지기능 날씨 예보
  static Map<String, dynamic> getCognitiveFunctionWeather(
      String mbtiType, DateTime date) {
    final functions = MbtiCognitiveFunctionsService
        .calculateDailyCognitiveFunctions(mbtiType, date);
    
    final weather = <String, Map<String, dynamic>>{};
    
    functions.forEach((function, level) {
      String condition;
      String icon;
      String advice;
      
      if (level >= 0.8) {
        condition = '맑음';
        icon = '☀️';
        advice = '최상의 컨디션! 적극 활용하세요.';
      } else if (level >= 0.6) {
        condition = '구름 조금';
        icon = '⛅';
        advice = '양호한 상태입니다.';
      } else if (level >= 0.4) {
        condition = '흐림';
        icon = '☁️';
        advice = '평균적인 상태입니다.';
      } else if (level >= 0.2) {
        condition = '비';
        icon = '🌧️';
        advice = '저조한 상태, 무리하지 마세요.';
      } else {
        condition = '폭풍';
        icon = '⛈️';
        advice = '매우 약한 상태, 휴식이 필요합니다.';
      }
      
      weather[function] = {
        'level': (level * 100).round(),
        'condition': condition,
        'icon': icon,
        'advice': advice,
        'name': MbtiCognitiveFunctionsService
            .functionDescriptions[function]!['name'],
      };
    });
    
    // 전체 날씨 요약
    final avgLevel = functions.values.reduce((a, b) => a + b) / functions.length;
    String overallCondition;
    String overallAdvice;
    
    if (avgLevel >= 0.7) {
      overallCondition = '화창한 날';
      overallAdvice = '모든 활동에 적합한 최고의 날입니다!';
    } else if (avgLevel >= 0.5) {
      overallCondition = '맑은 날';
      overallAdvice = '대부분의 활동을 무리 없이 수행할 수 있습니다.';
    } else if (avgLevel >= 0.3) {
      overallCondition = '흐린 날';
      overallAdvice = '중요한 결정은 신중하게, 충분한 휴식을 취하세요.';
    } else {
      overallCondition = '궂은 날';
      overallAdvice = '오늘은 무리하지 말고 재충전에 집중하세요.';
    }
    
    return {
      'functions': weather,
      'overall': {
        'condition': overallCondition,
        'advice': overallAdvice,
        'average': (avgLevel * 100).round(),
      },
    };
  }
  
  // ==========================================
  // Helper 메서드들
  // ==========================================
  
  static String _getEnergyAdvice(bool isExtrovert, double social, double alone) {
    if (isExtrovert) {
      if (social < 0.3) {
        return '사회적 에너지가 부족합니다. 사람들과 교류하세요.';
      } else if (social > 0.8) {
        return '사회적 에너지가 충만합니다! 네트워킹에 최적입니다.';
      }
    } else {
      if (alone < 0.3) {
        return '혼자만의 시간이 필요합니다. 재충전하세요.';
      } else if (alone > 0.8) {
        return '내적 에너지가 충만합니다! 깊은 사고가 가능합니다.';
      }
    }
    return '에너지 밸런스가 적절합니다.';
  }
  
  static String _generateScheduleAdvice(String bestTime, String mbtiType) {
    final advice = {
      'morning': '오전에 중요한 업무를 처리하세요.',
      'afternoon': '오후에 핵심 과제에 집중하세요.',
      'evening': '저녁 시간을 활용해 창의적인 작업을 하세요.',
      'night': '밤 시간의 집중력을 활용하세요.',
    };
    return advice[bestTime] ?? '자신의 리듬에 맞춰 일정을 조정하세요.';
  }
  
  static String _getRechargeMethod(String mbtiType) {
    final methods = {
      'INTJ': '혼자만의 전략 수립 시간',
      'INTP': '지적 호기심을 충족시키는 연구',
      'ENTJ': '목표 달성을 위한 계획 수립',
      'ENTP': '새로운 아이디어 탐색',
      'INFJ': '명상과 내적 성찰',
      'INFP': '창의적인 활동과 상상',
      'ENFJ': '의미 있는 대화와 교류',
      'ENFP': '새로운 경험과 모험',
      'ISTJ': '체계적인 정리 정돈',
      'ISFJ': '소중한 사람들과의 시간',
      'ESTJ': '생산적인 활동과 성취',
      'ESFJ': '따뜻한 사교 활동',
      'ISTP': '손으로 하는 작업이나 취미',
      'ISFP': '예술적 활동과 자연 감상',
      'ESTP': '신체 활동과 스포츠',
      'ESFP': '즐거운 사교 활동과 엔터테인먼트',
    };
    return methods[mbtiType] ?? '자신만의 방식으로 휴식';
  }
  
  static String _getSynergyReason(String type1, String type2, bool isGood) {
    if (isGood) {
      return '서로의 강점을 보완하며 시너지를 발휘합니다.';
    } else {
      return '소통 방식의 차이로 오해가 생길 수 있습니다.';
    }
  }
  
  static String _getSpecialSynergyMessage(String type1, String type2) {
    return '오늘은 $type2 유형과 특별한 인연이 있는 날입니다. 평소와 다른 관점을 배울 수 있는 기회!';
  }
  
  static String _getCommunicationTip(String mbtiType, DateTime date) {
    final tips = [
      '상대방의 관점을 먼저 이해하려 노력하세요.',
      '논리와 감정의 균형을 맞춰 소통하세요.',
      '구체적인 예시를 들어 설명하면 효과적입니다.',
      '경청하는 자세로 대화에 임하세요.',
      '비언어적 신호에도 주의를 기울이세요.',
    ];
    
    final index = (date.day + mbtiType.hashCode) % tips.length;
    return tips[index];
  }
}