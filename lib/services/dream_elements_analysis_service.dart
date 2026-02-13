class DreamElementsAnalysisService {
  // 꿈 요소 카테고리
  static const List<String> elementCategories = [
    '동물',
    '사람',
    '장소',
    '행동',
    '사물',
    '자연',
    '색상',
    '감정'
  ];

  // 꿈 요소별 상징 데이터베이스
  static const Map<String, Map<String, dynamic>> symbolDatabase = {
    // 동물 상징
    '개': {
      'category': '동물',
      'meaning': '충성심, 우정, 보호',
      'positive': '믿을 수 있는 친구나 조력자의 등장',
      'negative': '배신에 대한 두려움이나 경계심',
      'psychological': '충실한 자아의 일부, 본능적 욕구'
    },
    '고양이': {
      'category': '동물',
      'meaning': '독립성, 직관, 여성성',
      'positive': '독립적인 성향의 강화, 직관력 상승',
      'negative': '교활함이나 배신에 대한 경고',
      'psychological': '여성적 측면, 독립적 자아'
    },
    '뱀': {
      'category': '동물',
      'meaning': '변화, 재생, 지혜',
      'positive': '변화와 성장의 기회, 지혜의 획듍',
      'negative': '위험이나 배신에 대한 경고',
      'psychological': '무의식적 에너지, 성적 욕구'
    },
    '새': {
      'category': '동물',
      'meaning': '자유, 영혼, 메시지',
      'positive': '자유로운 영혼, 좋은 소식',
      'negative': '속박에서 벗어나고 싶은 욕구',
      'psychological': '영적 자아, 초월적 욕구'
    },

    // 사람 상징
    '가족': {
      'category': '사람',
      'meaning': '안정감, 관계, 책임',
      'positive': '가족 관계의 화합과 안정',
      'negative': '가족 문제나 책임감에 대한 부담',
      'psychological': '내면의 가족 역동, 애착 관계'
    },
    '친구': {
      'category': '사람',
      'meaning': '사회성, 지원, 관계',
      'positive': '사회적 관계의 발전, 도움',
      'negative': '관계에 대한 불안이나 갈등',
      'psychological': '사회적 자아, 관계 욕구'
    },
    '연인': {
      'category': '사람',
      'meaning': '사랑, 욕망, 관계',
      'positive': '사랑의 성취, 관계의 발전',
      'negative': '관계에 대한 불안이나 두려움',
      'psychological': '아니마/아니무스, 사랑 욕구'
    },
    '낯선사람': {
      'category': '사람',
      'meaning': '미지의 자아, 새로운 가능성',
      'positive': '새로운 기회나 관계의 시작',
      'negative': '불안이나 두려움의 투사',
      'psychological': '그림자 자아, 미지의 측면'
    },

    // 장소 상징
    '집': {
      'category': '장소',
      'meaning': '자아, 안전, 내면',
      'positive': '안정감과 평화, 자아 실현',
      'negative': '갇힌 느낌, 변화의 필요성',
      'psychological': '정신의 집, 내면 세계'
    },
    '학교': {
      'category': '장소',
      'meaning': '학습, 성장, 평가',
      'positive': '새로운 배움과 성장의 기회',
      'negative': '평가에 대한 두려움, 부족감',
      'psychological': '성장 욕구, 사회적 적응'
    },
    '바다': {
      'category': '장소',
      'meaning': '무의식, 감정, 무한',
      'positive': '감정의 풍요로움, 무한한 가능성',
      'negative': '감정의 혼란, 두려움',
      'psychological': '집단 무의식, 감정의 바다'
    },
    '산': {
      'category': '장소',
      'meaning': '목표, 도전, 영성',
      'positive': '목표 달성, 영적 성장',
      'negative': '극복해야 할 장애물',
      'psychological': '성취 욕구, 영적 추구'
    },

    // 행동 상징
    '날다': {
      'category': '행동',
      'meaning': '자유, 초월, 탈출',
      'positive': '제약에서의 해방, 자유 획득',
      'negative': '현실 도피 욕구',
      'psychological': '초자아, 현실 초월 욕구'
    },
    '떨어지다': {
      'category': '행동',
      'meaning': '불안, 통제력 상실',
      'positive': '불필요한 것을 내려놓음',
      'negative': '통제력 상실에 대한 두려움',
      'psychological': '불안감, 실패 공포'
    },
    '쫓기다': {
      'category': '행동',
      'meaning': '회피, 압박감, 두려움',
      'positive': '변화의 필요성 인식',
      'negative': '현실의 압박이나 스트레스',
      'psychological': '억압된 감정, 회피 성향'
    },
    '싸우다': {
      'category': '행동',
      'meaning': '갈등, 대립, 극복',
      'positive': '문제 해결 의지, 극복',
      'negative': '내적 갈등이나 외부 충돌',
      'psychological': '내면의 갈등, 공격성'
    },

    // 자연 상징
    '물': {
      'category': '자연',
      'meaning': '감정, 정화, 생명',
      'positive': '감정의 정화, 새로운 시작',
      'negative': '감정적 혼란이나 불안정',
      'psychological': '무의식, 감정 상태'
    },
    '불': {
      'category': '자연',
      'meaning': '열정, 변화, 파괴',
      'positive': '열정과 에너지, 변혁',
      'negative': '파괴적 충동, 분노',
      'psychological': '리비도, 변화 에너지'
    },
    '비': {
      'category': '자연',
      'meaning': '정화, 감정 표출, 축복',
      'positive': '정서적 정화, 새로운 시작',
      'negative': '우울감이나 슬픔',
      'psychological': '감정의 해방, 정화'
    },
    '태양': {
      'category': '자연',
      'meaning': '의식, 생명력, 성공',
      'positive': '밝은 미래, 성공과 행운',
      'negative': '과도한 자아 의식',
      'psychological': '의식적 자아, 남성성'
    },
    '달': {
      'category': '자연',
      'meaning': '무의식, 직관, 여성성',
      'positive': '직관력 상승, 내면의 지혜',
      'negative': '혼란이나 불확실성',
      'psychological': '무의식, 여성성'
    }
  };

  // 꿈 텍스트에서 요소 추출
  static Map<String, List<String>> extractDreamElements(String dreamText) {
    final elements = <String, List<String>>{};

    for (final category in elementCategories) {
      elements[category] = [];
    }

    // 심플한 키워드 매칭 (실제로는 더 정교한 NLP 필요,
    for (final symbol in symbolDatabase.keys) {
      if (dreamText.contains(symbol)) {
        final category = symbolDatabase[symbol]!['category'] as String;
        elements[category]!.add(symbol);
      }
    }

    // 색상 추출
    final colors = ['빨간', '파란', '노란', '초록', '검은', '하얀', '보라'];
    for (final color in colors) {
      if (dreamText.contains(color)) {
        elements['색상']!.add(color);
      }
    }

    // 감정 추출
    final emotions = ['기쁨', '슬픔', '분노', '두려움', '불안', '평화', '사랑'];
    for (final emotion in emotions) {
      if (dreamText.contains(emotion)) {
        elements['감정']!.add(emotion);
      }
    }

    return elements;
  }

  // 요소별 비중 계산
  static Map<String, double> calculateElementWeights(
      Map<String, List<String>> elements) {
    final weights = <String, double>{};
    int totalElements = 0;

    for (final entry in elements.entries) {
      totalElements += entry.value.length;
    }

    if (totalElements == 0) {
      // 기본값 설정
      for (final category in elementCategories) {
        weights[category] = 1.0 / elementCategories.length;
      }
    } else {
      for (final entry in elements.entries) {
        weights[entry.key] = entry.value.length / totalElements;
      }
    }

    return weights;
  }

  // 심리 상태 분석
  static Map<String, double> analyzePsychologicalState(
      Map<String, List<String>> elements) {
    final state = {
      '의식': 0.5,
      '무의식': 0.5,
      '긍정': 0.5,
      '부정': 0.5,
      '안정': 0.5,
      '변화': 0.5,
      '내향': 0.5,
      '외향': 0.5
    };

    // 요소별 심리 상태 계산 (간단한 버전,
    for (final entry in elements.entries) {
      for (final element in entry.value) {
        final symbol = symbolDatabase[element];
        if (symbol != null) {
          // 카테고리별 가중치 적용
          switch (symbol['category']) {
            case '동물':
            case '자연':
              state['무의식'] = state['무의식']! + 0.1;
              break;
            case '사람':
            case '장소':
              state['의식'] = state['의식']! + 0.1;
              break;
          }
        }
      }
    }

    // 정규화
    final total = state['의식']! + state['무의식']!;
    state['의식'] = state['의식']! / total;
    state['무의식'] = state['무의식']! / total;

    return state;
  }

  // 꿈 해석 생성
  static Map<String, dynamic> generateDreamInterpretation(
      String dreamText, Map<String, List<String>> elements) {
    final interpretation = <String, dynamic>{
      'mainTheme': _identifyMainTheme(elements),
      'symbolMeanings': _getSymbolMeanings(elements),
      'psychologicalInsight': _generatePsychologicalInsight(elements),
      'advice': _generateAdvice(elements),
      'luckyElements': null
    };

    return interpretation;
  }

  static String _identifyMainTheme(Map<String, List<String>> elements) {
    // 가장 많은 요소를 가진 카테고리 찾기
    String mainCategory = '';
    int maxCount = 0;

    for (final entry in elements.entries) {
      if (entry.value.length > maxCount) {
        maxCount = entry.value.length;
        mainCategory = entry.key;
      }
    }

    switch (mainCategory) {
      case '동물':
        return '본능과 욕구에 관한 꿈';
      case '사람':
        return '인간관계와 사회성에 관한 꿈';
      case '장소':
        return '내면 세계와 환경에 관한 꿈';
      case '행동':
        return '변화와 도전에 관한 꿈';
      case '자연':
        return '자연의 힘과 순환에 관한 꿈';
      case '색상':
        return '감정과 에너지에 관한 꿈';
      case '감정':
        return '정서적 상태에 관한 꿈';
      default:
        return '복합적 의미를 담은 꿈';
    }
  }

  static List<Map<String, String>> _getSymbolMeanings(
      Map<String, List<String>> elements) {
    final meanings = <Map<String, String>>[];

    for (final entry in elements.entries) {
      for (final symbol in entry.value) {
        final data = symbolDatabase[symbol];
        if (data != null) {
          meanings.add({
            'symbol': symbol,
            'meaning': data['meaning'] as String,
            'positive': data['positive'] as String,
            'negative': data['negative']
          });
        }
      }
    }

    return meanings;
  }

  static String _generatePsychologicalInsight(
      Map<String, List<String>> elements) {
    final insights = <String>[];

    // 카테고리별 분석
    if (elements['동물']!.isNotEmpty) {
      insights.add('본능적 욕구와 무의식적 충동이 표현되고 있습니다');
    }
    if (elements['사람']!.isNotEmpty) {
      insights.add('대인관계나 사회적 역할에 대한 고민이 반영되어 있습니다');
    }
    if (elements['행동']!.contains('날다')) {
      insights.add('자유를 향한 갈망과 현실의 제약에서 벗어나고 싶은 욕구가 있습니다');
    }
    if (elements['행동']!.contains('떨어지다')) {
      insights.add('통제력 상실에 대한 불안이나 실패에 대한 두려움이 있습니다');
    }

    return insights.isNotEmpty
        ? insights.join('. ')
        : '무의식이 의식에 전달하려는 중요한 메시지가 담겨 있습니다';
  }

  static String _generateAdvice(Map<String, List<String>> elements) {
    final advices = <String>[];

    // 요소별 조언 생성
    for (final entry in elements.entries) {
      if (entry.value.isNotEmpty) {
        switch (entry.key) {
          case '동물':
            advices.add('본능의 소리에 귀 기울이되 이성적 판단도 함께하세요');
            break;
          case '사람':
            advices.add('주변 사람들과의 관계를 돌아보고 소통을 강화하세요');
            break;
          case '행동':
            advices.add('꿈에서 보여준 행동을 통해 현실의 변화 필요성을 인식하세요');
            break;
          case '자연':
            advices.add('자연의 리듬에 맞춰 생활하고 내면의 평화를 찾으세요');
            break;
        }
      }
    }

    return advices.isNotEmpty
        ? advices.join('. ')
        : '꿈이 전하는 메시지에 귀 기울이고 내면의 지혜를 신뢰하세요';
  }

  // 꿈의 감정 흐름 분석
  static List<double> analyzeEmotionalFlow(String dreamText) {
    // 간단한 감정 변화 시뮬레이션 (실제로는 더 정교한 분석 필요,
    final flow = <double>[];
    final sentences = dreamText.split('.');

    for (int i = 0; i < sentences.length; i++) {
      double emotionValue = 0.5; // 중립

      // 긍정 키워드
      if (sentences[i].contains('기쁨') || sentences[i].contains('행복')) {
        emotionValue = 0.8;
      }
      // 부정 키워드
      else if (sentences[i].contains('두려움') || sentences[i].contains('불안')) {
        emotionValue = 0.2;
      }

      flow.add(emotionValue);
    }

    // 최소 5개 포인트 보장
    while (flow.length < 5) {
      flow.add(0.5);
    }

    return flow;
  }
}
