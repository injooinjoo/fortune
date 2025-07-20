import 'dart:math' as math;

class BloodTypeAnalysisService {
  // 혈액형 정보
  static const List<String> bloodTypes = ['A', 'B', 'O', 'AB'];
  static const List<String> rhTypes = ['+', '-'];
  
  // 혈액형별 기본 특성
  static const Map<String, Map<String, dynamic>> bloodTypeCharacteristics = {
    'A': {
      'positive_traits': ['신중함', '책임감', '완벽주의', '배려심', '계획적'],
      'negative_traits': ['소심함', '고집', '걱정 많음', '내성적', '보수적'],
      'personality': '꼼꼼하고 신중하며 책임감이 강합니다. 규칙을 잘 지키고 타인을 배려하지만, 때로는 지나치게 신경을 쓰는 경향이 있습니다.',
      'love_style': '진지하고 헌신적인 사랑을 추구합니다. 안정적인 관계를 원하며 상대방을 깊이 이해하려 노력합니다.',
      'work_style': '체계적이고 계획적으로 일을 처리합니다. 세부사항에 신경을 쓰며 완성도 높은 결과물을 만들어냅니다.',
      'stress_response': '스트레스를 내면화하는 경향이 있어 혼자 고민하는 시간이 많습니다.',
      'health_tips': '스트레스 관리가 중요합니다. 규칙적인 운동과 명상이 도움이 됩니다.',
      'lucky_colors': ['파란색', '초록색', '흰색'],
      'element': '물',
      'compatibility_best': ['A', 'AB'],
      'compatibility_good': ['O'],
      'compatibility_challenging': ['B'],
    },
    'B': {
      'positive_traits': ['창의적', '자유로움', '열정적', '독창적', '유연함'],
      'negative_traits': ['변덕스러움', '자기중심적', '규칙 무시', '충동적', '무책임'],
      'personality': '자유분방하고 창의적이며 독특한 개성을 가지고 있습니다. 틀에 박힌 것을 싫어하고 자신만의 방식을 추구합니다.',
      'love_style': '자유로운 사랑을 추구하며 서로의 개성을 존중하는 관계를 원합니다. 구속을 싫어합니다.',
      'work_style': '창의성이 요구되는 일에서 능력을 발휘합니다. 자율성이 보장될 때 최고의 성과를 냅니다.',
      'stress_response': '스트레스를 받으면 충동적으로 행동하거나 현실도피를 하는 경향이 있습니다.',
      'health_tips': '규칙적인 생활 리듬을 유지하는 것이 중요합니다. 취미 생활로 스트레스를 해소하세요.',
      'lucky_colors': ['주황색', '빨간색', '보라색'],
      'element': '불',
      'compatibility_best': ['B', 'AB'],
      'compatibility_good': ['O'],
      'compatibility_challenging': ['A'],
    },
    'O': {
      'positive_traits': ['리더십', '사교적', '낙천적', '도전적', '현실적'],
      'negative_traits': ['고집', '경쟁심', '단순함', '융통성 부족', '독선적'],
      'personality': '리더십이 강하고 사교적이며 목표 지향적입니다. 현실적이고 실용적인 사고를 하며 도전을 즐깁니다.',
      'love_style': '적극적이고 열정적인 사랑을 합니다. 주도적인 역할을 하며 상대방을 보호하려는 성향이 강합니다.',
      'work_style': '목표를 향해 직진하는 스타일입니다. 리더 역할을 잘 수행하며 결과 중심적으로 일합니다.',
      'stress_response': '스트레스를 받으면 공격적이 되거나 무모한 행동을 할 수 있습니다.',
      'health_tips': '과로에 주의하고 충분한 휴식을 취하세요. 팀 스포츠가 스트레스 해소에 좋습니다.',
      'lucky_colors': ['빨간색', '검은색', '금색'],
      'element': '땅',
      'compatibility_best': ['O', 'A'],
      'compatibility_good': ['B', 'AB'],
      'compatibility_challenging': [],
    },
    'AB': {
      'positive_traits': ['합리적', '분석적', '다재다능', '공정함', '독특함'],
      'negative_traits': ['이중적', '복잡함', '비판적', '거리감', '우유부단'],
      'personality': '합리적이고 분석적이며 다면적인 성격을 가지고 있습니다. 상황에 따라 유연하게 대처하며 독특한 관점을 제시합니다.',
      'love_style': '이성적이면서도 로맨틱한 사랑을 추구합니다. 정신적인 교감을 중요시하며 깊이 있는 관계를 원합니다.',
      'work_style': '분석적이고 전략적으로 일을 처리합니다. 다양한 관점에서 문제를 바라보며 창의적인 해결책을 제시합니다.',
      'stress_response': '스트레스를 받으면 감정 기복이 심해지거나 현실과 거리를 두려 합니다.',
      'health_tips': '감정 관리가 중요합니다. 예술 활동이나 문화생활이 정서적 안정에 도움이 됩니다.',
      'lucky_colors': ['보라색', '은색', '파란색'],
      'element': '공기',
      'compatibility_best': ['AB', 'A', 'B'],
      'compatibility_good': ['O'],
      'compatibility_challenging': [],
    },
  };
  
  // Rh 인자별 특성
  static const Map<String, Map<String, dynamic>> rhCharacteristics = {
    '+': {
      'traits': ['적극적', '외향적', '활동적', '사교적'],
      'description': 'Rh+ 혈액형은 일반적으로 더 외향적이고 활동적인 성향을 보입니다.',
      'energy_level': 0.8,
    },
    '-': {
      'traits': ['신중함', '직관적', '민감함', '독립적'],
      'description': 'Rh- 혈액형은 더 신중하고 직관적이며 독립적인 성향을 보입니다.',
      'energy_level': 0.6,
      'special_note': 'Rh- 혈액형은 전체 인구의 약 15%로 희귀한 편입니다.',
    },
  };
  
  // 혈액형 궁합 점수 계산
  static double calculateCompatibility(String bloodType1, String rh1, String bloodType2, String rh2) {
    // 기본 혈액형 궁합
    double baseScore = _getBaseCompatibilityScore(bloodType1, bloodType2);
    
    // Rh 인자 고려
    double rhBonus = 0;
    if (rh1 == rh2) {
      rhBonus = 0.1; // 같은 Rh는 약간의 보너스
    } else if (rh1 == '-' || rh2 == '-') {
      rhBonus = 0.05; // Rh-가 포함된 경우 특별한 이해 필요
    }
    
    return math.min(baseScore + rhBonus, 1.0);
  }
  
  static double _getBaseCompatibilityScore(String type1, String type2) {
    final characteristics1 = bloodTypeCharacteristics[type1]!;
    
    if (characteristics1['compatibility_best'].contains(type2)) {
      return 0.9;
    } else if (characteristics1['compatibility_good'].contains(type2)) {
      return 0.7;
    } else if (characteristics1['compatibility_challenging'].contains(type2)) {
      return 0.4;
    }
    
    return 0.6; // 기본 점수
  }
  
  // 혈액형 조합별 특별한 시너지
  static Map<String, dynamic> getSpecialSynergy(String type1, String rh1, String type2, String rh2) {
    final key = '${type1}${rh1}-${type2}${rh2}';
    final reverseKey = '${type2}${rh2}-${type1}${rh1}';
    
    final synergies = {
      'A+-A+': {
        'type': '완벽한 조화',
        'description': '서로를 깊이 이해하고 안정적인 관계를 유지합니다.',
        'strength': '상호 이해와 배려',
        'challenge': '변화와 모험이 부족할 수 있음',
      },
      'A+-B+': {
        'type': '보완적 관계',
        'description': 'A형의 안정성과 B형의 창의성이 균형을 이룹니다.',
        'strength': '서로의 부족한 부분을 채워줌',
        'challenge': '가치관 차이로 인한 갈등 가능',
      },
      'O+-AB+': {
        'type': '흥미로운 조합',
        'description': 'O형의 추진력과 AB형의 전략이 시너지를 만듭니다.',
        'strength': '목표 달성에 효과적',
        'challenge': '감정적 교류가 부족할 수 있음',
      },
      'B+-B-': {
        'type': '자유로운 영혼들',
        'description': '서로의 자유를 존중하며 창의적인 관계를 만듭니다.',
        'strength': '개성 존중과 창의성',
        'challenge': '책임감이 부족할 수 있음',
      },
    };
    
    return synergies[key] ?? synergies[reverseKey] ?? {
      'type': '일반적인 조합',
      'description': '서로를 이해하고 노력하면 좋은 관계를 만들 수 있습니다.',
      'strength': '노력하면 발전 가능',
      'challenge': '서로의 차이를 인정하는 것이 중요',
    };
  }
  
  // 혈액형별 일일 바이오리듬 계산
  static Map<String, double> calculateDailyBiorhythm(String bloodType, String rh, DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    final characteristics = bloodTypeCharacteristics[bloodType]!;
    final rhData = rhCharacteristics[rh]!;
    
    // 기본 에너지 레벨
    final baseEnergy = rhData['energy_level'] as double;
    
    // 각 요소별 주기와 위상
    final physical = 0.5 + 0.5 * math.sin(2 * math.pi * dayOfYear / 23);
    final emotional = 0.5 + 0.5 * math.sin(2 * math.pi * dayOfYear / 28);
    final intellectual = 0.5 + 0.5 * math.sin(2 * math.pi * dayOfYear / 33);
    
    // 혈액형별 가중치
    final weights = _getBloodTypeWeights(bloodType);
    
    return {
      '체력': physical * baseEnergy * weights['physical']!,
      '감정': emotional * baseEnergy * weights['emotional']!,
      '지성': intellectual * baseEnergy * weights['intellectual']!,
      '직관': (physical + emotional + intellectual) / 3 * baseEnergy * weights['intuition']!,
      '사회성': (emotional * 0.6 + intellectual * 0.4) * baseEnergy * weights['social']!,
    };
  }
  
  static Map<String, double> _getBloodTypeWeights(String bloodType) {
    switch (bloodType) {
      case 'A':
        return {
          'physical': 0.8,
          'emotional': 1.0,
          'intellectual': 0.9,
          'intuition': 0.7,
          'social': 0.8,
        };
      case 'B':
        return {
          'physical': 0.9,
          'emotional': 0.8,
          'intellectual': 0.7,
          'intuition': 1.0,
          'social': 0.9,
        };
      case 'O':
        return {
          'physical': 1.0,
          'emotional': 0.7,
          'intellectual': 0.8,
          'intuition': 0.8,
          'social': 1.0,
        };
      case 'AB':
        return {
          'physical': 0.7,
          'emotional': 0.9,
          'intellectual': 1.0,
          'intuition': 0.9,
          'social': 0.7,
        };
      default:
        return {
          'physical': 0.8,
          'emotional': 0.8,
          'intellectual': 0.8,
          'intuition': 0.8,
          'social': 0.8,
        };
    }
  }
  
  // 혈액형별 성격 강도 분석
  static Map<String, double> analyzePersonalityStrengths(String bloodType, String rh) {
    final characteristics = bloodTypeCharacteristics[bloodType]!;
    final positiveTraits = characteristics['positive_traits'] as List<String>;
    
    // 기본 강도 맵
    final strengths = {
      '리더십': 0.5,
      '창의성': 0.5,
      '사교성': 0.5,
      '분석력': 0.5,
      '공감능력': 0.5,
      '실행력': 0.5,
      '인내심': 0.5,
      '적응력': 0.5,
    };
    
    // 혈액형별 강도 조정
    switch (bloodType) {
      case 'A':
        strengths['인내심'] = 0.9;
        strengths['공감능력'] = 0.85;
        strengths['분석력'] = 0.8;
        strengths['리더십'] = 0.6;
        break;
      case 'B':
        strengths['창의성'] = 0.95;
        strengths['적응력'] = 0.85;
        strengths['사교성'] = 0.7;
        strengths['인내심'] = 0.5;
        break;
      case 'O':
        strengths['리더십'] = 0.95;
        strengths['실행력'] = 0.9;
        strengths['사교성'] = 0.85;
        strengths['창의성'] = 0.6;
        break;
      case 'AB':
        strengths['분석력'] = 0.95;
        strengths['창의성'] = 0.8;
        strengths['적응력'] = 0.85;
        strengths['실행력'] = 0.6;
        break;
    }
    
    // Rh 인자 보정
    if (rh == '-') {
      strengths['분석력'] = math.min(strengths['분석력']! + 0.1, 1.0);
      strengths['창의성'] = math.min(strengths['창의성']! + 0.05, 1.0);
    } else {
      strengths['사교성'] = math.min(strengths['사교성']! + 0.1, 1.0);
      strengths['실행력'] = math.min(strengths['실행력']! + 0.05, 1.0);
    }
    
    return strengths;
  }
  
  // 혈액형 조합의 관계 다이나믹스 분석
  static Map<String, dynamic> analyzeRelationshipDynamics(
    String type1, String rh1, String type2, String rh2
  ) {
    final compatibility = calculateCompatibility(type1, rh1, type2, rh2);
    final synergy = getSpecialSynergy(type1, rh1, type2, rh2);
    
    // 관계의 각 측면 분석
    final communication = _analyzeCommunication(type1, type2);
    final conflict = _analyzeConflictStyle(type1, type2);
    final growth = _analyzeGrowthPotential(type1, type2);
    
    return {
      'overall_score': compatibility,
      'synergy': synergy,
      'communication': communication,
      'conflict_resolution': conflict,
      'growth_potential': growth,
      'advice': _getRelationshipAdvice(type1, rh1, type2, rh2),
    };
  }
  
  static Map<String, dynamic> _analyzeCommunication(String type1, String type2) {
    final communicationStyles = {
      'A': {'style': '신중하고 배려깊은', 'speed': 0.6, 'depth': 0.9},
      'B': {'style': '자유롭고 창의적인', 'speed': 0.8, 'depth': 0.6},
      'O': {'style': '직설적이고 명확한', 'speed': 0.9, 'depth': 0.7},
      'AB': {'style': '논리적이고 분석적인', 'speed': 0.7, 'depth': 0.8},
    };
    
    final style1 = communicationStyles[type1]!;
    final style2 = communicationStyles[type2]!;
    
    final speedDiff = ((style1['speed'] as double) - (style2['speed'] as double)).abs();
    final depthDiff = ((style1['depth'] as double) - (style2['depth'] as double)).abs();
    
    return {
      'compatibility': 1.0 - (speedDiff + depthDiff) / 2,
      'style1': style1['style'],
      'style2': style2['style'],
      'advice': speedDiff > 0.3 
        ? '소통 속도의 차이를 인정하고 서로 맞춰주는 노력이 필요합니다.'
        : '소통 스타일이 잘 맞아 원활한 대화가 가능합니다.',
    };
  }
  
  static Map<String, dynamic> _analyzeConflictStyle(String type1, String type2) {
    final conflictStyles = {
      'A': {'approach': '회피형', 'resolution': '타협'},
      'B': {'approach': '직면형', 'resolution': '창의적 해결'},
      'O': {'approach': '주도형', 'resolution': '빠른 해결'},
      'AB': {'approach': '분석형', 'resolution': '논리적 해결'},
    };
    
    return {
      'type1_style': conflictStyles[type1],
      'type2_style': conflictStyles[type2],
      'compatibility': type1 == type2 ? 0.8 : 0.6,
    };
  }
  
  static Map<String, dynamic> _analyzeGrowthPotential(String type1, String type2) {
    // 서로 다른 혈액형일수록 성장 가능성이 높음
    final diversity = type1 != type2 ? 0.8 : 0.6;
    
    return {
      'score': diversity,
      'areas': _getGrowthAreas(type1, type2),
    };
  }
  
  static List<String> _getGrowthAreas(String type1, String type2) {
    final areas = <String>[];
    
    if ((type1 == 'A' && type2 == 'B') || (type1 == 'B' && type2 == 'A')) {
      areas.addAll(['유연성 향상', '창의성과 안정성의 균형']);
    }
    if ((type1 == 'O' && type2 == 'AB') || (type1 == 'AB' && type2 == 'O')) {
      areas.addAll(['실행력과 전략의 조화', '리더십 개발']);
    }
    
    return areas.isEmpty ? ['상호 이해와 존중'] : areas;
  }
  
  static String _getRelationshipAdvice(String type1, String rh1, String type2, String rh2) {
    final compatibility = calculateCompatibility(type1, rh1, type2, rh2);
    
    if (compatibility >= 0.8) {
      return '매우 좋은 궁합입니다. 서로의 장점을 살리고 단점을 보완해주세요.';
    } else if (compatibility >= 0.6) {
      return '노력하면 좋은 관계를 만들 수 있습니다. 서로의 차이를 인정하고 존중하세요.';
    } else {
      return '도전적인 관계입니다. 더 많은 이해와 인내가 필요하지만, 큰 성장의 기회가 될 수 있습니다.';
    }
  }
}