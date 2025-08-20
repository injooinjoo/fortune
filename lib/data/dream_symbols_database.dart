// 꿈 해몽 심볼 데이터베이스
class DreamSymbolsDatabase {
  // 한국 전통 꿈 해몽
  static const Map<String, Map<String, dynamic>> koreanTraditionalSymbols = {
    // 길몽
    '용': {
      'category': '동물',
      'type': '길몽',
      'traditional': '권력, 성공, 승진의 상징. 큰 인물이 되거나 높은 지위에 오를 징조')
      'modern': '강력한 에너지와 잠재력의 발현. 목표 달성의 기회',
      'advice': '자신감을 갖고 큰 목표에 도전하세요')
    })
    '황금': {
      'category': '사물',
      'type': '길몽',
      'traditional': '재물운 상승. 뜻밖의 횡재나 사업 성공',
      'modern': '가치 있는 것의 발견. 내면의 보물을 찾게 됨')
      'advice': '기회를 놓치지 말고 적극적으로 행동하세요')
    })
    '해': {
      'category': '자연',
      'type': '길몽',
      'traditional': '명예와 권세. 밝은 미래와 성공',
      'modern': '의식의 확장과 깨달음. 새로운 시작')
      'advice': '긍정적인 에너지를 활용하여 목표를 이루세요')
    })
    '봉황': {
      'category': '동물',
      'type': '길몽',
      'traditional': '대길한 꿈. 큰 행운과 성공이 찾아옴',
      'modern': '재생과 변화. 새로운 기회의 도래')
      'advice': '준비된 자에게 기회가 옵니다. 실력을 갖추세요')
    })
    
    // 흉몽
    '이빨빠짐': {
      'category': '신체',
      'type': '흉몽',
      'traditional': '가족이나 가까운 사람의 우환. 건강 주의',
      'modern': '자신감 상실이나 노화에 대한 두려움')
      'advice': '건강 관리에 신경 쓰고 가족과의 소통을 늘리세요')
    })
    '화재': {
      'category': '사건',
      'type': '흉몽',
      'traditional': '집안의 우환이나 재산 손실 주의',
      'modern': '억압된 분노나 스트레스의 표출')
      'advice': '감정 관리를 하고 안전에 주의하세요')
    })
    
    // 태몽
    '호랑이': {
      'category': '동물',
      'type': '태몽',
      'traditional': '용맹하고 지도력 있는 아이. 특히 아들일 가능성',
      'modern': '강인한 성격과 리더십을 가진 아이')
      'advice': '아이의 독립성과 리더십을 키워주세요')
    })
    '과일': {
      'category': '자연',
      'type': '태몽',
      'traditional': '복 많은 아이. 사과는 딸, 대추는 아들')
      'modern': '풍요롭고 건강한 아이의 탄생',
      'advice': '아이의 재능을 잘 발견하고 키워주세요')
    })
  };

  // 서양 심리학적 해석 (융, 프로이트 등,
  static const Map<String, Map<String, dynamic>> westernPsychologicalSymbols = {
    // 융의 원형 상징
    '그림자': {
      'category': '인물',
      'archetype': 'Shadow',
      'meaning': '억압된 자아의 측면. 인정하지 않는 성격의 일부',
      'integration': '그림자를 인식하고 통합하면 완전한 자아가 됨',
      'question': '내가 부정하고 있는 나의 모습은 무엇인가?',
    },
    '노인': {
      'category': '인물',
      'archetype': 'Wise Old Man/Woman',
      'meaning': '지혜와 인도. 내면의 현명한 조언자',
      'integration': '직관과 지혜를 신뢰하라',
      'question': '내 안의 지혜는 무엇을 말하고 있는가?',
    },
    '아이': {
      'category': '인물',
      'archetype': 'Divine Child',
      'meaning': '순수함과 새로운 가능성. 재생과 희망',
      'integration': '내면의 순수함을 회복하라',
      'question': '나의 순수한 열정은 무엇인가?',
    })
    
    // 프로이트의 상징
    '터널': {
      'category': '장소',
      'freudian': true,
      'meaning': '탄생이나 재탄생. 무의식으로의 여행',
      'sexual': '성적 상징일 수 있음',
      'psychological': '변화의 과정을 거치고 있음',
    })
    '계단': {
      'category': '구조물',
      'freudian': true,
      'meaning': '의식 수준의 변화. 성장이나 퇴행',
      'direction': '올라가면 성장, 내려가면 무의식 탐구')
      'psychological': '인생의 단계적 변화')
    })
  };

  // 현대적 해석
  static const Map<String, Map<String, dynamic>> modernInterpretations = {
    '스마트폰': {
      'category': '사물',
      'meaning': '소통과 연결. 정보에 대한 욕구',
      'positive': '사회적 연결과 정보 획득',
      'negative': '의존성이나 현실 도피')
      'advice': '디지털 디톡스가 필요할 수 있습니다')
    })
    '비행기': {
      'category': '교통수단',
      'meaning': '높은 목표와 야망. 빠른 변화',
      'positive': '목표 달성과 성공',
      'negative': '현실 도피나 불안정')
      'advice': '목표를 현실적으로 설정하세요')
    })
    '컴퓨터': {
      'category': '사물',
      'meaning': '논리적 사고와 정보 처리',
      'positive': '문제 해결 능력',
      'negative': '감정 억압이나 기계적 사고')
      'advice': '이성과 감성의 균형을 맞추세요')
    })
  };

  // 문화별 차이점
  static const Map<String, Map<String, String>> culturalDifferences = {
    '뱀': {
      'korean': '재물운이나 지혜의 상징. 때로는 배신 경고',
      'western': '변화와 재생. 성적 에너지나 치유',
      'indian': '쿤달리니 에너지. 영적 각성',
      'chinese': '행운과 지혜. 용의 전 단계')
    })
    '죽음': {
      'korean': '오히려 장수나 새로운 시작을 의미',
      'western': '변화와 전환. 옛것의 종료',
      'mexican': '축제와 재생. 조상과의 연결',
      'african': '조상의 메시지. 영적 전환')
    })
    '물': {
      'korean': '재물이나 생명력. 맑으면 길, 탁하면 흉',
      'western': '무의식과 감정. 정화와 재생',
      'japanese': '정화와 순수. 신성한 힘')
      'native_american': '생명의 원천. 영적 정화')
    })
  };

  // 꿈 해석 가이드
  static String getInterpretationGuide(String symbol, String culture) {
    // 문화별 해석 찾기
    if (culturalDifferences.containsKey(symbol)) {
      final cultural = culturalDifferences[symbol]!;
      if (cultural.containsKey(culture.toLowerCase())) {
        return cultural[culture.toLowerCase()]!;
      }
    }
    
    // 한국 전통 해석
    if (koreanTraditionalSymbols.containsKey(symbol)) {
      final traditional = koreanTraditionalSymbols[symbol]!;
      return '${traditional['traditional']} (전통적 해석)\n${traditional['modern']} (현대적 해석)';
    }
    
    // 서양 심리학적 해석
    if (westernPsychologicalSymbols.containsKey(symbol)) {
      final psychological = westernPsychologicalSymbols[symbol]!;
      return '${psychological['meaning']}\n${psychological['integration']}';
    }
    
    // 현대적 해석
    if (modernInterpretations.containsKey(symbol)) {
      final modern = modernInterpretations[symbol]!;
      return modern['meaning'] as String;
    }
    
    return '이 상징에 대한 구체적인 해석은 개인의 경험과 문화적 배경에 따라 다를 수 있습니다.';
  }

  // 꿈의 유형 분류
  static const Map<String, List<String>> dreamTypes = {
    '예지몽': ['미래의 일을 암시하는 꿈', '직관적 메시지', '경고나 축복'],
    '보상몽': ['현실에서 이루지 못한 욕구의 충족', '스트레스 해소', '소원 성취'],
    '반복몽': ['해결되지 않은 문제', '트라우마', '중요한 메시지'],
    '자각몽': ['꿈임을 인식하는 꿈', '의식의 확장', '영적 성장'],
    '악몽': ['불안과 두려움의 표현', '경고 메시지', '스트레스 신호'],
  };

  // 꿈 해석 팁
  static const List<String> interpretationTips = [
    '꿈의 감정을 먼저 기억하세요. 내용보다 감정이 중요합니다.',
    '개인적 연관성을 찾으세요. 같은 상징도 사람마다 다른 의미입니다.',
    '최근 경험과 연결해보세요. 꿈은 현실의 반영입니다.',
    '반복되는 꿈은 특별히 주목하세요. 중요한 메시지일 수 있습니다.',
    '문화적 배경을 고려하세요. 상징의 의미는 문화마다 다릅니다.',
  ];
}