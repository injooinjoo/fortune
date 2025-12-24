import 'package:flutter/material.dart';

/// 인사이트 스와이프 페이지에서 사용하는 헬퍼 함수들
class FortuneSwipeHelpers {
  FortuneSwipeHelpers._();

  /// 날씨 상태에 따른 이모지 반환
  static String getWeatherEmoji(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
      case 'drizzle':
        return '🌧️';
      case 'snow':
        return '❄️';
      case 'thunderstorm':
        return '⛈️';
      case 'mist':
      case 'fog':
      case 'haze':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  /// 점수 기반 사자성어 반환
  static String getScoreIdiom(int score) {
    if (score >= 90) return '금상첨화(錦上添花)';
    if (score >= 80) return '일취월장(日就月將)';
    if (score >= 70) return '안분지족(安分知足)';
    if (score >= 60) return '견토지쟁(犬兎之爭)';
    return '새옹지마(塞翁之馬)';
  }

  /// 전통 오방색 기반 점수 색상
  /// 木(목): 청록 - 성장/번영
  /// 火(화): 진홍 - 열정/주의
  /// 土(토): 금황 - 균형/안정
  /// 金(금): 금색 - 가치/결실
  /// 水(수): 남색 - 지혜/침착
  static Color getPulseScoreColor(int score) {
    if (score >= 85) return const Color(0xFF2E8B57); // 木(목) - 최상, 청록
    if (score >= 70) return const Color(0xFF1E5F3C); // 木(목) 진한 - 양호
    if (score >= 50) return const Color(0xFFDAA520); // 土(토) - 보통, 금황
    if (score >= 30) return const Color(0xFFC0A062); // 金(금) - 주의, 금색
    return const Color(0xFFDC143C); // 火(화) - 경고, 진홍
  }

  /// 띠별 점수 색상 (전통 오방색)
  static Color getZodiacScoreColor(int score) {
    if (score >= 85) return const Color(0xFF2E8B57); // 木(목) - 최상
    if (score >= 70) return const Color(0xFF1E3A5F); // 水(수) - 양호
    if (score >= 50) return const Color(0xFFDAA520); // 土(토) - 보통
    return const Color(0xFFDC143C); // 火(화) - 주의
  }

  /// 카테고리별 이모지 (전통 스타일)
  /// 연애: 연꽃 - 아름다움과 순수
  /// 금전: 동전 - 풍요와 복
  /// 직장: 두루마리 - 관직과 성공
  /// 학업: 책 - 학문과 지혜
  /// 건강: 명상 - 심신의 조화
  static String getCategoryEmoji(String categoryKey) {
    switch (categoryKey) {
      case 'love':
        return '🪷'; // 연꽃 - 전통 연애운 상징
      case 'money':
        return '🪙'; // 동전 - 전통 재물운 상징
      case 'work':
        return '📜'; // 두루마리 - 관직/성공 상징
      case 'study':
        return '📖'; // 펼쳐진 책 - 학문 상징
      case 'health':
        return '🧘'; // 명상 - 심신 조화 상징
      default:
        return '☯️'; // 태극 - 균형과 조화
    }
  }

  /// 연도에서 띠 계산
  static String getZodiacFromYear(int year) {
    const zodiacs = ['원숭이', '닭', '개', '돼지', '쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양'];
    return zodiacs[year % 12];
  }

  /// 띠별 대표 연도 반환 (예: 쥐띠 → "84·96·08·20")
  static String getRepresentativeYears(String zodiac) {
    // 각 띠별 기준 연도 (1980년대 시작)
    const baseYears = {
      '쥐': 1984, '소': 1985, '호랑이': 1986, '토끼': 1987,
      '용': 1988, '뱀': 1989, '말': 1990, '양': 1991,
      '원숭이': 1980, '닭': 1981, '개': 1982, '돼지': 1983,
    };

    final baseYear = baseYears[zodiac] ?? 1984;
    final years = <String>[];

    for (int i = 0; i < 4; i++) {
      final year = baseYear + (i * 12);
      years.add((year % 100).toString().padLeft(2, '0'));
    }

    return years.join('·');
  }

  /// 띠 정보 반환
  static Map<String, String> getZodiacInfo(String zodiac) {
    final zodiacData = {
      '쥐': {'emoji': '🐭', 'description': '지혜롭고 기민한 쥐띠는 오늘 재정적 기회가 찾아옵니다. 직감을 믿고 빠른 결단이 필요합니다.'},
      '소': {'emoji': '🐂', 'description': '성실하고 인내심 강한 소띠는 오늘 꾸준한 노력의 결실을 볼 수 있습니다. 서두르지 마세요.'},
      '호랑이': {'emoji': '🐯', 'description': '용감하고 자신감 넘치는 호랑이띠는 오늘 리더십을 발휘할 기회가 있습니다. 앞장서세요.'},
      '토끼': {'emoji': '🐰', 'description': '온화하고 섬세한 토끼띠는 오늘 대인관계에서 좋은 일이 생깁니다. 소통에 집중하세요.'},
      '용': {'emoji': '🐲', 'description': '강인하고 야망 있는 용띠는 오늘 큰 도약의 기회가 있습니다. 과감한 시도가 길합니다.'},
      '뱀': {'emoji': '🐍', 'description': '지혜롭고 직관적인 뱀띠는 오늘 숨겨진 기회를 발견합니다. 관찰력을 발휘하세요.'},
      '말': {'emoji': '🐴', 'description': '활기차고 자유로운 말띠는 오늘 새로운 모험이 기다립니다. 에너지를 긍정적으로 쓰세요.'},
      '양': {'emoji': '🐑', 'description': '온순하고 예술적인 양띠는 오늘 창의적 영감이 넘칩니다. 감성을 표현해보세요.'},
      '원숭이': {'emoji': '🐵', 'description': '영리하고 재치있는 원숭이띠는 오늘 문제 해결 능력이 빛납니다. 유연하게 대처하세요.'},
      '닭': {'emoji': '🐔', 'description': '근면하고 정확한 닭띠는 오늘 세심함이 인정받습니다. 디테일에 신경쓰세요.'},
      '개': {'emoji': '🐶', 'description': '충직하고 정의로운 개띠는 오늘 신뢰를 얻습니다. 진심을 전하면 좋은 결과가 있습니다.'},
      '돼지': {'emoji': '🐷', 'description': '너그럽고 낙천적인 돼지띠는 오늘 풍요로운 기운이 감돕니다. 여유를 즐기세요.'},
    };

    return zodiacData[zodiac] ?? {'emoji': '✨', 'description': '오늘 하루도 좋은 일이 가득하길 바랍니다.'};
  }

  /// 연도 끝자리로 주 오행 결정 (천간 기준)
  static String getMainElementFromYear(int lastDigit) {
    switch (lastDigit) {
      case 0:
      case 1:
        return '금(金)'; // 경(庚), 신(辛)
      case 2:
      case 3:
        return '수(水)'; // 임(壬), 계(癸)
      case 4:
      case 5:
        return '목(木)'; // 갑(甲), 을(乙)
      case 6:
      case 7:
        return '화(火)'; // 병(丙), 정(丁)
      case 8:
      case 9:
        return '토(土)'; // 무(戊), 기(己)
      default:
        return '목(木)';
    }
  }

  /// 월로 계절 오행 결정
  static String getSeasonElement(int month) {
    if (month >= 2 && month <= 4) {
      return '목(木)'; // 봄
    } else if (month >= 5 && month <= 7) {
      return '화(火)'; // 여름
    } else if (month >= 8 && month <= 10) {
      return '금(金)'; // 가을
    } else {
      return '수(水)'; // 겨울 (11, 12, 1월)
    }
  }

  /// 부족한 오행에 대한 조언
  static String getElementAdvice(String element) {
    switch (element) {
      case '목(木)':
        return '초록색 옷이나 소품, 식물 가까이 하기';
      case '화(火)':
        return '붉은색 계열 아이템, 햇볕 쬐기';
      case '토(土)':
        return '황토색/베이지 색상, 흙과 접촉';
      case '금(金)':
        return '금속 액세서리, 흰색/은색 아이템';
      case '수(水)':
        return '검은색/남색 옷, 물가 산책';
      default:
        return '균형 잡힌 생활';
    }
  }

  /// 오행 균형 상태 판단
  static String calculateBalance(Map<String, int> elements) {
    final values = elements.values.toList();
    final max = values.reduce((a, b) => a > b ? a : b);
    final min = values.reduce((a, b) => a < b ? a : b);
    final difference = max - min;

    // 가장 높은/낮은 오행 찾기
    final maxElement = elements.entries.firstWhere((e) => e.value == max).key;
    final minElement = elements.entries.firstWhere((e) => e.value == min).key;

    if (difference <= 15) {
      return '오행이 전체적으로 균형 잡혀 있습니다. 안정적인 운세를 나타냅니다.';
    } else if (difference <= 25) {
      return '$maxElement이(가) 강하고 $minElement이(가) 약합니다. ${getElementAdvice(minElement)}을(를) 보강하면 좋습니다.';
    } else {
      return '$maxElement이(가) 매우 강하고 $minElement이(가) 매우 약합니다. 오행 불균형 상태이니 ${getElementAdvice(minElement)}을(를) 통해 균형을 맞추세요.';
    }
  }

  /// 시간대 라벨
  static String getTimeOfDayLabel(int hour) {
    if (hour >= 5 && hour < 9) return '이른 아침';
    if (hour >= 9 && hour < 12) return '오전';
    if (hour >= 12 && hour < 14) return '점심';
    if (hour >= 14 && hour < 18) return '오후';
    if (hour >= 18 && hour < 21) return '저녁';
    return '밤';
  }

  /// 시간별 조언
  static String getHourAdvice(int hour, int score, bool? isBest) {
    if (isBest == true) {
      return '이 시간대에 중요한 일정을 배치하면 최상의 결과를 얻을 수 있습니다.';
    }

    if (score >= 80) return '에너지가 높은 시간입니다. 중요한 업무에 집중하세요.';
    if (score >= 60) return '안정적인 흐름입니다. 평소처럼 일과를 진행하세요.';
    if (score >= 40) return '주의가 필요한 시간입니다. 신중하게 행동하세요.';
    return '휴식이 필요한 시간입니다. 무리하지 마세요.';
  }

  /// 점수 기반 300자 상세 설명 (fallback)
  static String getFullFortuneDescription(int score) {
    if (score >= 90) {
      return '오늘은 모든 일이 순조롭게 풀리는 최상의 하루입니다. 평소 계획했던 일들을 추진하기에 더없이 좋은 시기이며, '
          '주변 사람들과의 관계도 원만하게 이어질 것입니다. 특히 새로운 시도나 도전에 있어 긍정적인 결과를 기대할 수 있으니, '
          '자신감을 가지고 적극적으로 행동해 보세요. 금전적으로도 좋아 예상치 못한 기회가 생길 수 있으며, 건강 상태도 양호합니다. '
          '다만 지나친 자신감은 경계하고, 겸손한 태도를 유지하는 것이 좋습니다.';
    } else if (score >= 80) {
      return '오늘은 전반적으로 좋은 흐름을 타고 있는 하루입니다. 하루 동안 긍정적인 에너지가 가득하며, '
          '작은 노력들이 좋은 결과로 이어질 가능성이 높습니다. 대인관계에서 좋은 소식이 들려올 수 있고, '
          '업무나 학업에서도 안정적인 성과를 거둘 수 있습니다. 새로운 인연을 만날 기회가 있다면 적극적으로 다가가 보세요. '
          '금전적으로는 안정적이나 큰 지출은 피하는 것이 좋으며, 건강 관리에도 신경 쓰면 더욱 좋은 하루가 될 것입니다.';
    } else if (score >= 70) {
      return '오늘은 평온하고 안정적인 하루를 보낼 수 있습니다. 큰 변화나 특별한 일은 없지만, '
          '일상적인 일들을 차근차근 처리하다 보면 만족스러운 결과를 얻을 수 있습니다. 주변 사람들과의 관계에서 '
          '작은 배려와 관심이 큰 도움이 될 것이며, 자신의 페이스를 유지하며 일을 진행하는 것이 좋습니다. '
          '무리한 욕심을 부리기보다는 현재 가진 것에 감사하고, 차분하게 하루를 보내세요. '
          '건강과 금전 상태 모두 무난한 편이니 안심하고 생활하시면 됩니다.';
    } else if (score >= 60) {
      return '오늘은 약간의 부침이 있을 수 있는 하루입니다. 모든 일이 계획대로 진행되지는 않을 수 있으나, '
          '침착하게 대응한다면 큰 문제없이 하루를 마무리할 수 있습니다. 예상치 못한 변수가 생길 수 있으니 '
          '여유 시간을 두고 일을 처리하는 것이 좋으며, 중요한 결정은 신중하게 내리세요. '
          '대인관계에서 작은 오해가 생길 수 있으니 소통에 각별히 신경 쓰고, 감정적인 대응은 피하는 것이 좋습니다. '
          '건강 관리에 유의하고, 불필요한 지출은 자제하는 것이 현명합니다.';
    } else {
      return '오늘은 다소 어려운 상황이 있을 수 있으나, 이 또한 지나갈 것입니다. 힘든 순간이 있더라도 긍정적인 마음가짐을 유지하고, '
          '주변의 도움을 받는 것을 주저하지 마세요. 모든 어려움은 성장의 기회가 될 수 있으며, '
          '오늘 겪는 시련이 내일의 밑거름이 될 것입니다. 무리한 시도보다는 현재 상황을 안정시키는 데 집중하고, '
          '중요한 결정은 미루는 것이 좋습니다. 휴식을 충분히 취하고 건강 관리에 신경 쓰세요. '
          '가까운 사람들과의 대화가 위로가 될 수 있으니, 혼자 고민하지 말고 마음을 나누어 보세요.';
    }
  }

  /// 점수 기반 시간대별 조언 (고정값)
  static Map<String, String> getFallbackTimeSlotAdvice(int score) {
    if (score >= 85) {
      return {
        'morning': '아침부터 긍정적인 에너지가 가득합니다. 중요한 미팅이나 업무를 오전에 배치하면 좋은 결과를 얻을 수 있습니다.',
        'afternoon': '오후에는 창의적인 아이디어가 떠오를 수 있습니다. 브레인스토밍이나 기획 업무에 집중하기 좋은 시간입니다.',
        'evening': '저녁에는 주변 사람들과의 교류가 즐거울 것입니다. 소중한 사람들과 시간을 보내며 에너지를 충전하세요.',
      };
    } else if (score >= 70) {
      return {
        'morning': '오전에는 차분하게 하루를 시작하세요. 계획을 세우고 우선순위를 정리하는 시간으로 활용하면 좋습니다.',
        'afternoon': '오후에는 안정적인 흐름이 이어집니다. 루틴 업무를 처리하고 작은 성취감을 쌓아가세요.',
        'evening': '저녁에는 휴식을 취하며 내일을 준비하세요. 가벼운 운동이나 취미 활동으로 마음을 정돈하는 시간이 필요합니다.',
      };
    } else if (score >= 50) {
      return {
        'morning': '오전에는 신중하게 행동하세요. 서두르지 말고 한 걸음씩 차근차근 진행하는 것이 중요합니다.',
        'afternoon': '오후에는 예상치 못한 변수가 있을 수 있습니다. 유연하게 대처하고 플랜 B를 준비해두세요.',
        'evening': '저녁에는 충분한 휴식이 필요합니다. 무리하지 말고 컨디션 관리에 집중하세요.',
      };
    } else {
      return {
        'morning': '오전에는 여유를 가지고 시작하세요. 급하게 서두르지 말고 마음을 안정시키는 것이 중요합니다.',
        'afternoon': '오후에는 중요한 결정을 미루는 것이 좋습니다. 충분한 검토 시간을 가지고 신중하게 판단하세요.',
        'evening': '저녁에는 자신을 돌보는 시간을 가지세요. 명상이나 가벼운 산책으로 마음의 평화를 찾으세요.',
      };
    }
  }

  /// 카테고리 fallback 데이터
  static Map<String, dynamic> getFallbackCategoryData(String categoryKey, int baseScore) {
    // 카테고리별 점수 오프셋 (deterministic)
    final scoreOffsets = {
      'love': 0,
      'money': -3,
      'work': 2,
      'study': -5,
      'health': 1,
    };

    final offset = scoreOffsets[categoryKey] ?? 0;
    final score = (baseScore + offset).clamp(30, 100);

    final adviceMap = {
      'love': '새로운 만남에 열린 마음을 가지세요. 상대방의 감정을 존중하며 진심을 담은 대화를 나누면 좋은 결과가 있을 것입니다. 솔로라면 주변 사람들과의 소소한 만남을 소중히 여기고, 연인이 있다면 감사한 마음을 표현하는 것이 관계를 더욱 깊게 만들어줄 것입니다.',
      'money': '계획적인 소비가 도움이 될 것입니다. 충동구매를 자제하고 장기적인 재테크 계획을 세워보세요. 특히 오늘은 불필요한 지출을 줄이고 미래를 위한 저축에 집중하는 것이 좋습니다.',
      'work': '꾸준한 노력이 성과로 이어질 것입니다. 동료들과의 협력을 통해 더 큰 성과를 만들어보세요. 오늘은 팀워크가 특히 중요한 날입니다.',
      'study': '배움에 대한 열정으로 성과를 거둘 수 있습니다. 계획적인 학습과 복습이 실력 향상의 지름길입니다. 오늘은 집중력이 특히 좋은 날입니다.',
      'health': '규칙적인 생활습관을 유지하세요. 충분한 수면과 적절한 운동으로 건강을 지킬 수 있습니다. 오늘은 특히 수면의 질에 신경 쓰는 것이 좋습니다.',
    };

    return {
      'score': score,
      'advice': adviceMap[categoryKey] ?? '긍정적인 마음가짐으로 하루를 시작하세요.',
    };
  }

  /// 점수 기반 현실적인 액션 플랜
  static List<Map<String, String>> getScoreBasedActionPlan(int score) {
    if (score >= 85) {
      return [
        {
          'title': '🌅 오전: 중요 업무 우선 처리',
          'description': '에너지가 최고조인 시간이니 핵심 업무와 네트워킹에 집중하세요.',
          'priority': 'high',
        },
        {
          'title': '🍽 점심: 영양 충전 & 휴식',
          'description': '건강한 식사로 오후 에너지를 준비하세요.',
          'priority': 'medium',
        },
        {
          'title': '💡 오후: 창의적 마무리',
          'description': '새 아이디어를 정리하고 가벼운 운동으로 마무리하세요.',
          'priority': 'high',
        },
      ];
    } else if (score >= 70) {
      return [
        {
          'title': '📝 오전: 우선순위 정리',
          'description': '꼭 해야 할 일 3가지를 노트에 정리해 보세요.',
          'priority': 'high',
        },
        {
          'title': '🤝 점심: 동료와 식사',
          'description': '가벼운 대화로 스트레스를 환기해 보세요.',
          'priority': 'medium',
        },
        {
          'title': '📊 오후: 집중 업무 + 휴식',
          'description': '2시간 집중 후 10분 스트레칭으로 휴식하세요.',
          'priority': 'high',
        },
      ];
    } else if (score >= 50) {
      return [
        {
          'title': '🌤 아침: 긍정 루틴',
          'description': '환기하고 감사한 일 3가지를 떠올려 보세요.',
          'priority': 'medium',
        },
        {
          'title': '📱 오전: 알림 정리 & 집중',
          'description': 'SNS를 일시 정지하고 필수 연락만 하세요.',
          'priority': 'high',
        },
        {
          'title': '🎯 오후: 작은 목표 달성',
          'description': '10분 과제부터 시작하여 점진적으로 성취해 보세요.',
          'priority': 'medium',
        },
      ];
    } else {
      return [
        {
          'title': '😌 아침: 스트레스 낮추기',
          'description': '5분간 심호흡(4-7-8 호흡법)을 해보세요.',
          'priority': 'high',
        },
        {
          'title': '👂 점심: 대화 & 위로',
          'description': '신뢰하는 사람과 고민을 나누어 보세요.',
          'priority': 'medium',
        },
        {
          'title': '🌳 오후: 20분 산책',
          'description': '자연 속을 걸으며 생각을 비워 보세요.',
          'priority': 'high',
        },
      ];
    }
  }

  /// 생년월일 기반 오행 계산 (deterministic)
  static Map<String, int> calculateElementsFromBirthDate(DateTime? birthDate) {
    final date = birthDate ?? DateTime(1990, 1, 1);

    // 연도의 끝자리에 따른 주 오행 결정 (천간 기준)
    final yearLastDigit = date.year % 10;
    final mainElement = getMainElementFromYear(yearLastDigit);

    // 월에 따른 부 오행 (계절성)
    final seasonElement = getSeasonElement(date.month);

    // 오행 배분 (deterministic!)
    final Map<String, int> elements = {
      '목(木)': 20,
      '화(火)': 20,
      '토(土)': 20,
      '금(金)': 20,
      '수(水)': 20,
    };

    // 주 오행 +10
    elements[mainElement] = (elements[mainElement] ?? 20) + 10;
    // 계절 오행 +5
    elements[seasonElement] = (elements[seasonElement] ?? 20) + 5;

    // 총합이 100이 되도록 조정
    final total = elements.values.reduce((a, b) => a + b);
    final scale = 100.0 / total;
    elements.updateAll((key, value) => (value * scale).round());

    return elements;
  }

  /// 오행 균형 상세 설명 생성
  static String generateElementExplanation(Map<String, int> elements) {
    final values = elements.values.toList();
    final max = values.reduce((a, b) => a > b ? a : b);
    final maxElement = elements.entries.firstWhere((e) => e.value == max).key;

    // 가장 강한 오행의 특성
    final elementDescriptions = {
      '목(木)': '목기(木氣)가 강하면 성장과 발전의 기운이 왕성합니다. 창의성과 추진력이 뛰어나며 새로운 일을 시작하기 좋습니다.',
      '화(火)': '화기(火氣)가 강하면 열정과 활력이 넘칩니다. 사교성이 좋고 리더십을 발휘하기 쉬우며 사람들과의 관계가 활발합니다.',
      '토(土)': '토기(土氣)가 강하면 안정과 신뢰의 기운이 큽니다. 끈기와 인내심이 강하며 든든한 기반을 만드는 데 유리합니다.',
      '금(金)': '금기(金氣)가 강하면 결단력과 실행력이 뛰어납니다. 논리적이고 정확하며 목표를 향해 꾸준히 나아갑니다.',
      '수(水)': '수기(水氣)가 강하면 지혜와 통찰력이 깊습니다. 유연하고 적응력이 뛰어나며 어려운 상황도 잘 헤쳐나갑니다.',
    };

    return elementDescriptions[maxElement] ?? '균형 잡힌 오행을 가지고 있습니다.';
  }
}
