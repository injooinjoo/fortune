import 'dart:math' as math;

class MbtiCognitiveFunctionsService {
  // 8가지 인지기능
  static const List<String> cognitiveFunctions = [
    'Te', // Extraverted Thinking (외향 사고)
    'Ti', // Introverted Thinking (내향 사고)
    'Fe', // Extraverted Feeling (외향 감정)
    'Fi', // Introverted Feeling (내향 감정)
    'Ne', // Extraverted Intuition (외향 직관)
    'Ni', // Introverted Intuition (내향 직관)
    'Se', // Extraverted Sensing (외향 감각)
    'Si', // Introverted Sensing (내향 감각)
  ];

  // MBTI 타입별 인지기능 스택
  static const Map<String, List<String>> mbtiStacks = {
    // Analysts
    'INTJ': ['Ni', 'Te', 'Fi', 'Se', 'Ne', 'Ti', 'Fe', 'Si'],
    'INTP': ['Ti', 'Ne', 'Si', 'Fe', 'Te', 'Ni', 'Se', 'Fi'],
    'ENTJ': ['Te', 'Ni', 'Se', 'Fi', 'Ti', 'Ne', 'Si', 'Fe'],
    'ENTP': ['Ne', 'Ti', 'Fe', 'Si', 'Ni', 'Te', 'Fi', 'Se'],

    // Diplomats
    'INFJ': ['Ni', 'Fe', 'Ti', 'Se', 'Ne', 'Fi', 'Te', 'Si'],
    'INFP': ['Fi', 'Ne', 'Si', 'Te', 'Fe', 'Ni', 'Se', 'Ti'],
    'ENFJ': ['Fe', 'Ni', 'Se', 'Ti', 'Fi', 'Ne', 'Si', 'Te'],
    'ENFP': ['Ne', 'Fi', 'Te', 'Si', 'Ni', 'Fe', 'Ti', 'Se'],

    // Sentinels
    'ISTJ': ['Si', 'Te', 'Fi', 'Ne', 'Se', 'Ti', 'Fe', 'Ni'],
    'ISFJ': ['Si', 'Fe', 'Ti', 'Ne', 'Se', 'Fi', 'Te', 'Ni'],
    'ESTJ': ['Te', 'Si', 'Ne', 'Fi', 'Ti', 'Se', 'Ni', 'Fe'],
    'ESFJ': ['Fe', 'Si', 'Ne', 'Ti', 'Fi', 'Se', 'Ni', 'Te'],

    // Explorers
    'ISTP': ['Ti', 'Se', 'Ni', 'Fe', 'Te', 'Si', 'Ne', 'Fi'],
    'ISFP': ['Fi', 'Se', 'Ni', 'Te', 'Fe', 'Si', 'Ne', 'Ti'],
    'ESTP': ['Se', 'Ti', 'Fe', 'Ni', 'Si', 'Te', 'Fi', 'Ne'],
    'ESFP': ['Se', 'Fi', 'Te', 'Ni', 'Si', 'Fe', 'Ti', 'Ne']
  };

  // 인지기능 설명
  static const Map<String, Map<String, dynamic>> functionDescriptions = {
    'Te': {
      'name': '외향 사고',
      'nameEn': 'Extraverted Thinking',
      'description': '효율성과 논리적 시스템을 중시하며, 외부 세계를 조직화하고 구조화합니다.',
      'strengths': ['목표 달성', '효율적 계획', '논리적 의사결정', '리더십'],
      'weaknesses': ['감정 무시', '경직성', '비인간적', '통제욕'],
      'color': '#FF6B6B',
      'icon': '🎯'
    },
    'Ti': {
      'name': '내향 사고',
      'nameEn': 'Introverted Thinking',
      'description': '내적 논리와 일관성을 추구하며, 정확한 분석과 이해를 중요시합니다.',
      'strengths': ['논리적 분석', '객관성', '문제 해결', '독립적 사고'],
      'weaknesses': ['과도한 분석', '감정 배제', '완벽주의', '의사소통 어려움'],
      'color': '#4ECDC4',
      'icon': '🧩'
    },
    'Fe': {
      'name': '외향 감정',
      'nameEn': 'Extraverted Feeling',
      'description': '타인의 감정과 사회적 조화를 중시하며, 그룹의 화합을 추구합니다.',
      'strengths': ['공감 능력', '사회적 조화', '타인 배려', '협력'],
      'weaknesses': ['자기 희생', '갈등 회피', '타인 의존', '경계선 모호'],
      'color': '#FFE66D',
      'icon': '💝'
    },
    'Fi': {
      'name': '내향 감정',
      'nameEn': 'Introverted Feeling',
      'description': '개인의 가치관과 진정성을 중시하며, 내적 일치를 추구합니다.',
      'strengths': ['진정성', '깊은 가치관', '개인적 신념', '창의성'],
      'weaknesses': ['주관성', '타협 어려움', '감정 표현 어려움', '고립'],
      'color': '#A8E6CF',
      'icon': '🌟'
    },
    'Ne': {
      'name': '외향 직관',
      'nameEn': 'Extraverted Intuition',
      'description': '가능성과 연결을 탐색하며, 새로운 아이디어와 패턴을 발견합니다.',
      'strengths': ['창의성', '가능성 탐색', '유연성', '혁신'],
      'weaknesses': ['산만함', '실행력 부족', '현실 무시', '결정 장애'],
      'color': '#C7CEEA',
      'icon': '💡'
    },
    'Ni': {
      'name': '내향 직관',
      'nameEn': 'Introverted Intuition',
      'description': '내적 통찰과 미래 비전을 추구하며, 심층적 이해를 중요시합니다.',
      'strengths': ['통찰력', '장기 비전', '패턴 인식', '직관적 이해'],
      'weaknesses': ['설명 어려움', '고집', '현실 간과', '과도한 확신'],
      'color': '#FFDAB9',
      'icon': '🔮'
    },
    'Se': {
      'name': '외향 감각',
      'nameEn': 'Extraverted Sensing',
      'description': '현재 순간과 물리적 경험을 중시하며, 즉각적인 행동을 선호합니다.',
      'strengths': ['현재 집중', '실용성', '행동력', '감각적 즐거움'],
      'weaknesses': ['충동성', '장기 계획 부족', '위험 추구', '인내심 부족'],
      'color': '#FF8B94',
      'icon': '🎭'
    },
    'Si': {
      'name': '내향 감각',
      'nameEn': 'Introverted Sensing',
      'description': '과거 경험과 전통을 중시하며, 안정성과 일관성을 추구합니다.',
      'strengths': ['세부사항 기억', '신뢰성', '전통 존중', '안정성'],
      'weaknesses': ['변화 저항', '과거 집착', '새로운 시도 회피', '경직성'],
      'color': '#B4E7CE',
      'icon': '📚'
    }
  };

  // MBTI 타입 설명
  static const Map<String, Map<String, dynamic>> mbtiDescriptions = {
    // Analysts
    'INTJ': {
      'title': '전략가',
      'subtitle': 'The Architect',
      'description': '독립적이고 결단력 있으며, 높은 기준을 가진 전략적 사고를 하는 타입',
      'group': 'Analysts',
      'color': '#88619A'
    },
    'INTP': {
      'title': '논리술사',
      'subtitle': 'The Thinker',
      'description': '혁신적이고 논리적이며, 지적 호기심이 강한 분석적 타입',
      'group': 'Analysts',
      'color': '#5A9FD4'
    },
    'ENTJ': {
      'title': '통솔자',
      'subtitle': 'The Commander',
      'description': '대담하고 상상력이 풍부하며, 강한 의지를 가진 리더 타입',
      'group': 'Analysts',
      'color': '#E74C3C'
    },
    'ENTP': {
      'title': '변론가',
      'subtitle': 'The Debater',
      'description': '똑똑하고 호기심이 많으며, 지적 도전을 즐기는 타입',
      'group': 'Analysts',
      'color': '#F39C12'
    },

    // Diplomats
    'INFJ': {
      'title': '옹호자',
      'subtitle': 'The Advocate',
      'description': '선의의 옹호자로 조용하고 신비로우며 샘솟는 영감을 가진 타입',
      'group': 'Diplomats',
      'color': '#16A085'
    },
    'INFP': {
      'title': '중재자',
      'subtitle': 'The Mediator',
      'description': '시적이고 친절하며 이타적이고, 선을 위해 열정적인 타입',
      'group': 'Diplomats',
      'color': '#27AE60'
    },
    'ENFJ': {
      'title': '선도자',
      'subtitle': 'The Protagonist',
      'description': '카리스마 있고 영감을 주며, 청중을 사로잡는 리더 타입',
      'group': 'Diplomats',
      'color': '#2ECC71'
    },
    'ENFP': {
      'title': '활동가',
      'subtitle': 'The Campaigner',
      'description': '열정적이고 창의적이며 사교적이고 자유로운 영혼을 가진 타입',
      'group': 'Diplomats',
      'color': '#3498DB'
    },

    // Sentinels
    'ISTJ': {
      'title': '현실주의자',
      'subtitle': 'The Logistician',
      'description': '실용적이고 사실적이며, 신뢰성 있고 헌신적인 전통주의자 타입',
      'group': 'Sentinels',
      'color': '#34495E'
    },
    'ISFJ': {
      'title': '수호자',
      'subtitle': 'The Defender',
      'description': '헌신적이고 따뜻하며, 주변 사람들을 보호하는 수호자 타입',
      'group': 'Sentinels',
      'color': '#9B59B6'
    },
    'ESTJ': {
      'title': '경영자',
      'subtitle': 'The Executive',
      'description': '뛰어난 관리자로 사물과 사람을 관리하는 데 탁월한 타입',
      'group': 'Sentinels',
      'color': '#8E44AD'
    },
    'ESFJ': {
      'title': '집정관',
      'subtitle': 'The Consul',
      'description': '배려심이 많고 사교적이며, 인기 있고 협력적인 타입',
      'group': 'Sentinels',
      'color': '#E67E22'
    },

    // Explorers
    'ISTP': {
      'title': '장인',
      'subtitle': 'The Virtuoso',
      'description': '대담하고 실용적인 실험가로 모든 도구의 달인인 타입',
      'group': 'Explorers',
      'color': '#D35400'
    },
    'ISFP': {
      'title': '모험가',
      'subtitle': 'The Adventurer',
      'description': '유연하고 매력적이며, 새로운 것을 시도하는 예술가 타입',
      'group': 'Explorers',
      'color': '#C0392B'
    },
    'ESTP': {
      'title': '사업가',
      'subtitle': 'The Entrepreneur',
      'description': '똑똑하고 에너지 넘치며, 위험을 감수하는 행동파 타입',
      'group': 'Explorers',
      'color': '#E74C3C'
    },
    'ESFP': {
      'title': '연예인',
      'subtitle': 'The Entertainer',
      'description': '자발적이고 활기차며, 열정적으로 인생을 즐기는 타입',
      'group': 'Explorers',
      'color': '#F1C40F'
    }
  };

  // Combined MBTI data with functions for compatibility matrix
  static Map<String, Map<String, dynamic>> get mbtiData {
    final Map<String, Map<String, dynamic>> data = {};

    for (final type in mbtiDescriptions.keys) {
      data[type] = {...mbtiDescriptions[type]!, 'functions': null};
    }

    return data;
  }

  // 오늘의 인지기능 활성도 계산
  static Map<String, double> calculateDailyCognitiveFunctions(
      String mbtiType, DateTime date) {
    final stack = mbtiStacks[mbtiType] ?? mbtiStacks['INFP']!;
    final functions = <String, double>{};

    // 날짜 기반 시드값
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final random = math.Random(seed);

    // 각 기능별 활성도 계산
    for (int i = 0; i < stack.length; i++) {
      final function = stack[i];
      double baseValue;

      // 스택 위치에 따른 기본값
      if (i == 0) {
        baseValue = 0.9 + random.nextDouble() * 0.1; // 주기능: 90-100%
      } else if (i == 1) {
        baseValue = 0.7 + random.nextDouble() * 0.2; // 부기능: 70-90%
      } else if (i == 2) {
        baseValue = 0.5 + random.nextDouble() * 0.2; // 3차기능: 50-70%
      } else if (i == 3) {
        baseValue = 0.3 + random.nextDouble() * 0.2; // 열등기능: 30-50%
      } else {
        baseValue = 0.1 + random.nextDouble() * 0.2; // 그림자기능: 10-30%
      }

      // 요일별 보정
      final weekday = date.weekday;
      if (function.contains('e')) {
        // 외향 기능
        if (weekday >= 6) {
          // 주말
          baseValue *= 0.9;
        } else {
          // 평일
          baseValue *= 1.1;
        }
      } else {
        // 내향 기능
        if (weekday >= 6) {
          // 주말
          baseValue *= 1.1;
        } else {
          // 평일
          baseValue *= 0.9;
        }
      }

      functions[function] = math.min(baseValue, 1.0);
    }

    return functions;
  }

  // MBTI 궁합 계산
  static double calculateCompatibility(String type1, String type2) {
    // 같은 타입
    if (type1 == type2) return 0.7;

    // 이상적인 매칭
    final idealMatches = {
      'INTJ': ['ENFP', 'ENTP'],
      'INTP': ['ENTJ', 'ESTJ'],
      'ENTJ': ['INTP', 'ISTP'],
      'ENTP': ['INFJ', 'INTJ'],
      'INFJ': ['ENTP', 'ENFP'],
      'INFP': ['ENFJ', 'ENTJ'],
      'ENFJ': ['INFP', 'ISFP'],
      'ENFP': ['INFJ', 'INTJ'],
      'ISTJ': ['ESFP', 'ESTP'],
      'ISFJ': ['ESFP', 'ESTP'],
      'ESTJ': ['ISTP', 'INTP'],
      'ESFJ': ['ISFP', 'ISTP'],
      'ISTP': ['ESTJ', 'ENTJ'],
      'ISFP': ['ENFJ', 'ESFJ'],
      'ESTP': ['ISFJ', 'ISTJ'],
      'ESFP': ['ISFJ', 'ISTJ']
    };

    // 이상적인 매칭
    if (idealMatches[type1]?.contains(type2) ?? false) {
      return 0.9 + math.Random().nextDouble() * 0.1;
    }

    // 같은 그룹
    final group1 = mbtiDescriptions[type1]?['group'];
    final group2 = mbtiDescriptions[type2]?['group'];
    if (group1 == group2) {
      return 0.75 + math.Random().nextDouble() * 0.1;
    }

    // 주기능 비교
    final stack1 = mbtiStacks[type1]!;
    final stack2 = mbtiStacks[type2]!;

    // 주기능이 서로 보완적인 경우
    if (_areComplementary(stack1[0], stack2[0])) {
      return 0.8 + math.Random().nextDouble() * 0.1;
    }

    // 기본 호환성
    return 0.5 + math.Random().nextDouble() * 0.2;
  }

  static bool _areComplementary(String func1, String func2) {
    // 같은 기능의 내향/외향 쌍
    final pairs = {
      'Te': 'Ti',
      'Ti': 'Te',
      'Fe': 'Fi',
      'Fi': 'Fe',
      'Ne': 'Ni',
      'Ni': 'Ne',
      'Se': 'Si',
      'Si': 'Se'
    };

    return pairs[func1] == func2;
  }

  // 오늘의 MBTI 운세 메시지
  static Map<String, dynamic> getDailyFortune(
      String mbtiType, DateTime date, Map<String, double> cognitiveFunctions) {
    final dominantFunction = mbtiStacks[mbtiType]![0];
    final auxiliaryFunction = mbtiStacks[mbtiType]![1];
    final dominantLevel = cognitiveFunctions[dominantFunction] ?? 0.5;
    final auxiliaryLevel = cognitiveFunctions[auxiliaryFunction] ?? 0.5;

    // 전체 점수 계산
    final overallScore = ((dominantLevel * 0.4 +
                auxiliaryLevel * 0.3 +
                cognitiveFunctions.values.reduce((a, b) => a + b) / 8 * 0.3) *
            100)
        .round();

    // 강한 기능과 약한 기능 찾기
    final sortedFunctions = cognitiveFunctions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final strongestToday = sortedFunctions.first.key;
    final weakestToday = sortedFunctions.last.key;

    return {
      'overallScore': overallScore,
      'dominantStatus': _getFunctionStatus(dominantLevel),
      'message':
          _generateFortuneMessage(mbtiType, strongestToday, weakestToday),
      'advice': _generateAdvice(mbtiType, cognitiveFunctions),
      'strongestFunction': strongestToday,
      'weakestFunction': weakestToday,
      'luckyActivity': _getLuckyActivity(strongestToday),
      'cautionArea': null
    };
  }

  static String _getFunctionStatus(double level) {
    if (level >= 0.9) return '최상의 상태';
    if (level >= 0.7) return '좋은 상태';
    if (level >= 0.5) return '보통 상태';
    if (level >= 0.3) return '저조한 상태';
    return '주의 필요';
  }

  static String _generateFortuneMessage(
      String mbtiType, String strongestFunction, String weakestFunction) {
    final typeDesc = mbtiDescriptions[mbtiType]!;
    final strongDesc = functionDescriptions[strongestFunction]!;
    final weakDesc = functionDescriptions[weakestFunction]!;

    return '${typeDesc['title']}인 당신은 오늘 ${strongDesc['name']}($strongestFunction)이 '
        '특히 활성화되어 ${strongDesc['strengths'][0]}에 탁월한 능력을 발휘할 것입니다. '
        '반면 ${weakDesc['name']}($weakestFunction)이 약해져 ${weakDesc['weaknesses'][0]}에 '
        '주의가 필요합니다.';
  }

  static String _generateAdvice(
      String mbtiType, Map<String, double> functions) {
    final stack = mbtiStacks[mbtiType]!;
    final dominantLevel = functions[stack[0]] ?? 0.5;
    final inferiorLevel = functions[stack[3]] ?? 0.5;

    if (dominantLevel > 0.8 && inferiorLevel < 0.4) {
      return '주기능이 강하고 열등기능이 약한 전형적인 패턴입니다. '
          '오늘은 당신의 강점을 최대한 활용하되, 약점을 보완할 수 있는 '
          '파트너와 협력하면 좋은 결과를 얻을 수 있습니다.';
    } else if (inferiorLevel > 0.6) {
      return '열등기능이 평소보다 활성화된 특별한 날입니다. '
          '평소와 다른 관점에서 문제를 바라볼 수 있는 기회이니, '
          '새로운 시도를 해보는 것을 추천합니다.';
    } else {
      return '전체적으로 균형잡힌 상태입니다. '
          '다양한 상황에 유연하게 대처할 수 있는 날이니, '
          '평소 미뤄두었던 일들을 처리하기 좋습니다.';
    }
  }

  static String _getLuckyActivity(String function) {
    final activities = {
      'Te': '프로젝트 계획 수립, 업무 효율화, 리더십 발휘',
      'Ti': '복잡한 문제 분석, 연구 활동, 혼자만의 사색',
      'Fe': '팀 미팅, 네트워킹, 봉사활동',
      'Fi': '창작 활동, 일기 쓰기, 가치관 정리',
      'Ne': '브레인스토밍, 새로운 아이디어 탐색, 다양한 시도',
      'Ni': '명상, 미래 계획, 직관적 결정',
      'Se': '운동, 야외 활동, 감각적 경험',
      'Si': '추억 정리, 루틴 개선, 건강 관리'
    };

    return activities[function] ?? '자기 개발 활동';
  }
}
