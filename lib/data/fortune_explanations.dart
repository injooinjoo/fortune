// Fortune explanation data for different fortune types
class FortuneExplanations {
  static const Map<String, Map<String, dynamic>> explanations = {
    'daily': {
      'title': '오늘의 인사이트',
      'description':
          '오늘 당신만을 위한 특별한 하루 예보입니다. 시간대별 에너지 흐름과 함께 오늘을 빛내줄 행운 아이템을 확인해보세요.',
      'features': [
        '24시간 에너지 흐름 분석',
        '분야별 세부 점수 제공',
        '맞춤형 행운 아이템 추천',
        '시간대별 활동 가이드'
      ],
      'tips': [
        '아침 커피와 함께 인사이트를 확인하며 오늘의 에너지를 입어보세요',
        '황금 시간대에는 중요한 결정이나 만남을 잡아보세요',
        '행운의 색을 포인트로 활용하면 운이 두 배로 상승합니다'
      ],
      'visualData': {
        'timeFlow': [
          {'time': '오전 6-9시', 'score': 80, 'icon': '🌅', 'label': '활력 충전 시간'},
          {'time': '오전 9-12시', 'score': 100, 'icon': '⭐', 'label': '최고의 운세'},
          {'time': '오후 12-3시', 'score': 60, 'icon': '🍽️', 'label': '휴식 필요'},
          {'time': '오후 3-6시', 'score': 80, 'icon': '💼', 'label': '업무 집중'},
          {'time': '오후 6-9시', 'score': 60, 'icon': '🏠', 'label': '안정 추구'},
          {'time': '오후 9-12시', 'score': 40, 'icon': '😴', 'label': '조기 휴식 권장'}
        ],
        'categories': {'총운': 85, '애정운': 75, '금전운': 90, '건강운': 70}
      }
    },
    'love': {
      'title': '연애운',
      'description':
          '당신의 사랑 에너지를 정밀하게 진단합니다. 지금 당신에게 다가오고 있는 인연의 신호를 포착하고, 사랑을 키워가는 방법을 알려드립니다.',
      'features': ['연애 성향 분석', '이상형과의 만남 시기', '관계 발전 조언', '소통 방법 가이드'],
      'tips': [
        '오늘은 평소보다 10% 더 진심을 표현해보세요',
        '상대가 좋아하는 작은 것을 기억하고 실천해보세요',
        '나를 사랑할 줄 아는 사람이 진짜 사랑을 줄 수 있습니다'
      ],
      'visualData': {
        'singleRoadmap': [
          {
            'step': 1,
            'title': '자기 이해',
            'icon': '🪞',
            'description': '나를 먼저 알아가기'
          },
          {
            'step': 2,
            'title': '매력 개발',
            'icon': '💄',
            'description': '나만의 매력 찾기'
          },
          {
            'step': 3,
            'title': '만남 확대',
            'icon': '👥',
            'description': '새로운 인연 만들기'
          },
          {
            'step': 4,
            'title': '인연 포착',
            'icon': '💕',
            'description': '운명의 상대 발견'
          }
        ],
        'couplePhases': [
          {
            'phase': '씨앗기',
            'period': '0-3개월',
            'icon': '🌱',
            'description': '설렘과 호기심'
          },
          {
            'phase': '새싹기',
            'period': '3-6개월',
            'icon': '🌿',
            'description': '서로 알아가기'
          },
          {
            'phase': '성장기',
            'period': '6-12개월',
            'icon': '🌳',
            'description': '신뢰 구축'
          },
          {
            'phase': '안정기',
            'period': '1년 이상',
            'icon': '🌲',
            'description': '깊은 유대감'
          }
        ]
      }
    },
    'career': {
      'title': '직업운',
      'description':
          '당신의 커리어가 빛날 시기와 방법을 알려드립니다. 오늘 직장에서 당신을 빛나게 할 행동과 사람을 찾아보세요.',
      'features': ['업무 능력 향상 시기', '인간관계 조언', '경력 개발 방향', '스트레스 관리법'],
      'tips': [
        '오늘 당신의 아이디어는 평소보다 3배 더 가치가 있습니다',
        '커피 한 잔으로 동료와의 관계를 더 끈끈하게 만들어보세요',
        '오늘 배운 것은 3개월 후 큰 성과로 돌아옵니다'
      ],
      'visualData': {
        'careerMatrix': {
          'quadrants': [
            {
              'name': '스타형',
              'ability': 'high',
              'opportunity': 'high',
              'color': '#FFD700'
            },
            {
              'name': '리더형',
              'ability': 'high',
              'opportunity': 'low',
              'color': '#4169E1'
            },
            {
              'name': '잠재형',
              'ability': 'low',
              'opportunity': 'low',
              'color': '#90EE90'
            },
            {
              'name': '안정형',
              'ability': 'low',
              'opportunity': 'high',
              'color': '#FFA500'
            }
          ]
        },
        'jobTypeScores': [
          {'type': '사무직', 'icon': '🏢', 'score': 4, 'activity': '프레젠테이션, 기획'},
          {
            'type': '창작직',
            'icon': '🎨',
            'score': 5,
            'activity': '아이디어 구상, 작품 활동'
          },
          {'type': '영업직', 'icon': '💰', 'score': 3, 'activity': '기존 고객 관리'},
          {
            'type': '기술직',
            'icon': '🔧',
            'score': 4,
            'activity': '신기술 학습, 문제 해결'
          },
          {'type': '교육직', 'icon': '📚', 'score': 5, 'activity': '강의, 멘토링'}
        ]
      }
    },
    'wealth': {
      'title': '금전운',
      'description':
          '당신에게 흐르는 부의 에너지를 포착합니다. 돈이 들어오는 길을 열고, 새어나가는 구멍을 막아 풍요로운 삶을 만들어보세요.',
      'features': ['수입 증대 기회', '지출 관리 조언', '투자 적기 분석', '재테크 전략'],
      'tips': [
        '오늘 아낀 돈은 내일 10배가 되어 돌아옵니다',
        '작은 행복에 투자할수록 큰 재물이 따라옵니다',
        '당신의 직감은 오늘 특히 정확합니다. 믿고 행동하세요'
      ],
      'visualData': {
        'monthlyFlow': [
          {'month': '1월', 'amount': 60},
          {'month': '2월', 'amount': 70},
          {'month': '3월', 'amount': 75},
          {'month': '4월', 'amount': 80},
          {'month': '5월', 'amount': 85}
        ],
        'investmentSignals': [
          {
            'type': '주식',
            'signal': 'green',
            'percentage': 90,
            'note': '분산 투자 필수'
          },
          {
            'type': '부동산',
            'signal': 'yellow',
            'percentage': 60,
            'note': '시장 조사 선행'
          },
          {
            'type': '암호화폐',
            'signal': 'red',
            'percentage': 30,
            'note': '리스크 관리 중요'
          },
          {
            'type': '채권',
            'signal': 'green',
            'percentage': 85,
            'note': '안정적 수익 기대'
          }
        ]
      }
    },
    'health': {
      'title': '건강운',
      'description': '당신의 몸과 마음이 보내는 신호를 읽어드립니다. 오늘 당신에게 꼭 필요한 건강 비법을 찾아보세요.',
      'features': ['건강 상태 진단', '운동 추천 시기', '식단 관리 조언', '스트레스 해소법'],
      'tips': ['규칙적인 운동을 시작하세요', '충분한 수면을 취하세요', '스트레스 관리에 신경쓰세요'],
      'visualData': {
        'biorhythm': {
          'physical': [
            {'day': 1, 'value': 50},
            {'day': 7, 'value': 75},
            {'day': 14, 'value': 100},
            {'day': 21, 'value': 75},
            {'day': 28, 'value': 50}
          ],
          'emotional': [
            {'day': 1, 'value': 60},
            {'day': 7, 'value': 80},
            {'day': 14, 'value': 60},
            {'day': 21, 'value': 40},
            {'day': 28, 'value': 60}
          ],
          'intellectual': [
            {'day': 1, 'value': 70},
            {'day': 7, 'value': 85},
            {'day': 14, 'value': 70},
            {'day': 21, 'value': 55},
            {'day': 28, 'value': 70}
          ]
        },
        'healthChecklist': [
          {'item': '아침 스트레칭 (10분)', 'icon': '🌅', 'completed': true},
          {'item': '물 8잔 이상 섭취', 'icon': '💧', 'completed': true},
          {'item': '채소 중심 식단', 'icon': '🥗', 'completed': true},
          {'item': '30분 이상 걷기', 'icon': '🚶', 'completed': true},
          {'item': '7시간 이상 수면', 'icon': '😴', 'completed': true}
        ]
      }
    },
    'saju': {
      'title': '사주팔자',
      'description':
          '당신이 태어난 순간부터 정해진 운명의 비밀을 풀어드립니다. 당신만의 특별한 사주가 말하는 인생의 큰 그림을 함께 그려보세요.',
      'features': ['사주 구성 분석', '오행 균형 진단', '평생 운세 흐름', '개운 방법 제시'],
      'tips': ['자신의 강점을 활용하세요', '약점을 보완하는 노력을 하세요', '인생의 흐름을 이해하고 순응하세요'],
      'specialNote': '정확한 사주 분석을 위해서는 출생 시간이 반드시 필요합니다. 음력/양력 구분도 중요합니다.',
      'customSections': {
        'fourPillars': {
          'title': '사주의 구성',
          'description':
              '년주(年柱, 월주(月柱, 일주(日柱), 시주(時柱)로 구성되며, 각각이 인생의 다른 시기와 영역을 나타냅니다.'
        },
        'fiveElements': {
          'title': '오행의 균형',
          'description': '목(木), 화(火), 토(土), 금(金), 수(水)의 균형을 통해 성격과 운명을 분석합니다.'
        }
      },
      'visualData': {
        'fourPillarsChart': [
          {
            'pillar': '年柱',
            'label': '년간 년지',
            'description': '출생년도',
            'value': '갑자'
          },
          {
            'pillar': '月柱',
            'label': '월간 월지',
            'description': '출생월',
            'value': '을축'
          },
          {
            'pillar': '日柱',
            'label': '일간 일지',
            'description': '출생일',
            'value': '병인'
          },
          {
            'pillar': '時柱',
            'label': '시간 시지',
            'description': '출생시간',
            'value': '정묘'
          }
        ],
        'fiveElementsBalance': {'목': 25, '화': 20, '토': 15, '금': 25, '수': 15}
      }
    },
    'mbti': {
      'title': 'MBTI 운세',
      'description':
          '당신의 MBTI 성격에 꼭 맞는 오늘의 행동 가이드입니다. 당신의 강점이 빛나고 약점이 보완되는 하루를 만들어보세요.',
      'features': ['성격 유형별 분석', '강점과 약점 파악', '타입별 행운 요소', '대인관계 조언'],
      'tips': ['자신의 성격을 이해하고 받아들이세요', '다른 유형과의 차이를 존중하세요', '약점을 보완하는 방법을 찾으세요'],
      'specialNote':
          'MBTI 유형을 정확히 알고 계신가요? 16personalities.com에서 무료로 검사할 수 있습니다.',
      'mbtiTypes': {
        'analysts': ['INTJ', 'INTP', 'ENTJ', 'ENTP'],
        'diplomats': ['INFJ', 'INFP', 'ENFJ', 'ENFP'],
        'sentinels': ['ISTJ', 'ISFJ', 'ESTJ', 'ESFJ'],
        'explorers': ['ISTP', 'ISFP', 'ESTP', 'ESFP']
      },
      'visualData': {
        'typeGroups': [
          {
            'group': '분석가',
            'types': ['INTJ', 'INTP', 'ENTJ', 'ENTP'],
            'color': '#7C4DFF',
            'characteristics': '논리적, 전략적, 혁신적'
          },
          {
            'group': '외교관',
            'types': ['INFJ', 'INFP', 'ENFJ', 'ENFP'],
            'color': '#4CAF50',
            'characteristics': '이상주의적, 공감적, 창의적'
          },
          {
            'group': '관리자',
            'types': ['ISTJ', 'ISFJ', 'ESTJ', 'ESFJ'],
            'color': '#2196F3',
            'characteristics': '실용적, 신뢰성, 체계적'
          },
          {
            'group': '탐험가',
            'types': ['ISTP', 'ISFP', 'ESTP', 'ESFP'],
            'color': '#FF9800',
            'characteristics': '유연함, 자발적, 실행력'
          }
        ],
        'luckyElements': {
          'INTJ': {'color': '보라색', 'activity': '전략 수립', 'time': '새벽'},
          'INTP': {'color': '남색', 'activity': '연구 활동', 'time': '밤'},
          'ENTJ': {'color': '검정색', 'activity': '리더십 발휘', 'time': '오전'},
          'ENTP': {'color': '주황색', 'activity': '토론/논쟁', 'time': '오후'}
        }
      },
      'zodiac': {
        'title': '별자리 운세',
        'description':
            '오늘 밤하늘의 별들이 당신을 위해 속삭이는 메시지입니다. 우주가 준비한 당신만의 특별한 선물을 받아보세요.',
        'features': ['별자리별 특성 분석', '행성의 영향력', '월간 운세 흐름', '별자리 궁합'],
        'tips': ['자신의 별자리 특성을 활용하세요', '행운의 날을 놓치지 마세요', '별자리 궁합을 참고하세요'],
        'visualData': {
          'zodiacWheel': [
            {
              'sign': '양자리',
              'symbol': '♈',
              'period': '3/21-4/19',
              'element': '불',
              'angle': 0
            },
            {
              'sign': '황소자리',
              'symbol': '♉',
              'period': '4/20-5/20',
              'element': '흙',
              'angle': 30
            },
            {
              'sign': '쌍둥이자리',
              'symbol': '♊',
              'period': '5/21-6/20',
              'element': '공기',
              'angle': 60
            },
            {
              'sign': '게자리',
              'symbol': '♋',
              'period': '6/21-7/22',
              'element': '물',
              'angle': 90
            },
            {
              'sign': '사자자리',
              'symbol': '♌',
              'period': '7/23-8/22',
              'element': '불',
              'angle': 120
            },
            {
              'sign': '처녀자리',
              'symbol': '♍',
              'period': '8/23-9/22',
              'element': '흙',
              'angle': 150
            },
            {
              'sign': '천칭자리',
              'symbol': '♎',
              'period': '9/23-10/22',
              'element': '공기',
              'angle': 180
            },
            {
              'sign': '전갈자리',
              'symbol': '♏',
              'period': '10/23-11/21',
              'element': '물',
              'angle': 210
            },
            {
              'sign': '사수자리',
              'symbol': '♐',
              'period': '11/22-12/21',
              'element': '불',
              'angle': 240
            },
            {
              'sign': '염소자리',
              'symbol': '♑',
              'period': '12/22-1/19',
              'element': '흙',
              'angle': 270
            },
            {
              'sign': '물병자리',
              'symbol': '♒',
              'period': '1/20-2/18',
              'element': '공기',
              'angle': 300
            },
            {
              'sign': '물고기자리',
              'symbol': '♓',
              'period': '2/19-3/20',
              'element': '물',
              'angle': 330
            }
          ]
        }
      },
      'biorhythm': {
        'title': '바이오리듬',
        'description':
            '당신의 몸과 마음, 두뇌가 만들어내는 자연의 리듬을 읽어드립니다. 오늘 당신의 에너지가 가장 빛나는 순간을 포착하세요.',
        'features': ['3대 리듬 분석', '주기별 상태 예측', '최적 활동 시기', '위험 시기 경고'],
        'tips': ['고조기에는 적극적으로 활동하세요', '저조기에는 휴식을 취하세요', '위험일에는 조심스럽게 행동하세요']
      },
      'tarot': {
        'title': '타로 운세',
        'description':
            '오늘 당신을 위해 타로 카드가 전하는 신비로운 메시지입니다. 카드가 드러내는 당신의 무의식과 내면의 목소리를 들어보세요.',
        'features': ['카드 의미 해석', '상황별 조언', '미래 예측', '영적 메시지'],
        'tips': ['카드의 메시지를 깊이 생각해보세요', '직관을 믿고 따르세요', '긍정적인 마음가짐을 유지하세요'],
        'specialNote': '타로는 마음을 열고 받아들일 때 가장 정확합니다. 질문을 명확히 하세요.',
        'spreadTypes': {
          'oneCard': '원 카드 스프레드 - 간단한 답변',
          'threeCard': '쓰리 카드 스프레드 - 과거, 현재, 미래',
          'celtic': '켈틱 크로스 - 상황의 전체적 분석'
        },
        'visualData': {
          'tarotCards': [
            {
              'position': '과거',
              'card': 'The Fool',
              'meaning': '새로운 시작, 순수함',
              'icon': '🃏'
            },
            {
              'position': '현재',
              'card': 'The Magician',
              'meaning': '의지력, 창조',
              'icon': '🎩'
            },
            {
              'position': '미래',
              'card': 'The World',
              'meaning': '완성, 성취',
              'icon': '🌍'
            }
          ]
        }
      },
      'chemistry': {
        'title': '궁합 운세',
        'description':
            '두 사람이 만들어내는 특별한 케미스트리를 분석합니다. 서로를 더 깊이 이해하고 사랑하게 되는 비법을 발견해보세요.',
        'features': ['종합 궁합 점수', '분야별 궁합 분석', '관계 발전 가능성', '주의사항 안내'],
        'tips': [
          '서로의 차이를 인정하고 존중하세요',
          '소통을 늘리고 이해하려 노력하세요',
          '함께 성장할 수 있는 방법을 찾으세요'
        ],
        'specialNote': '상대방의 정보도 정확히 입력해주세요. 생년월일은 특히 중요합니다.',
        'compatibilityAreas': {
          'emotional': '감정적 궁합',
          'intellectual': '지적 궁합',
          'physical': '신체적 궁합',
          'values': '가치관 궁합',
          'lifestyle': '라이프스타일 궁합'
        },
        'visualData': {
          'radarChart': {
            'emotional': 85,
            'intellectual': 75,
            'physical': 90,
            'values': 80,
            'lifestyle': 70
          },
          'scoreInterpretation': [
            {
              'range': '90-100',
              'grade': 'S급',
              'meaning': '천생연분',
              'advice': '서로를 더욱 아끼세요'
            },
            {
              'range': '80-89',
              'grade': 'A급',
              'meaning': '매우 좋음',
              'advice': '작은 차이도 존중하세요'
            },
            {
              'range': '70-79',
              'grade': 'B급',
              'meaning': '좋음',
              'advice': '소통을 늘리세요'
            },
            {
              'range': '60-69',
              'grade': 'C급',
              'meaning': '보통',
              'advice': '노력이 필요합니다'
            },
            {
              'range': '50-59',
              'grade': 'D급',
              'meaning': '노력 필요',
              'advice': '전문가 상담 추천'
            }
          ]
        }
      },
      'business': {
        'title': '사업운',
        'description':
            '당신의 사업가 정신이 가장 빛날 순간을 포착합니다. 성공으로 가는 길이 열릴 때, 당신이 반드시 해야 할 행동을 알려드립니다.',
        'features': ['사업 성공 가능성', '투자 적기 분석', '파트너십 조언', '리스크 관리'],
        'tips': ['시장 조사를 철저히 하세요', '작게 시작해서 크게 키우세요', '인맥 관리에 신경쓰세요'],
        'visualData': {
          'timeline': [
            {
              'phase': '준비기',
              'duration': '3개월',
              'icon': '⚠️',
              'description': '시장 조사 및 계획'
            },
            {
              'phase': '시작기',
              'duration': '6개월',
              'icon': '🚀',
              'description': '사업 시작 및 초기 운영'
            },
            {
              'phase': '성장기',
              'duration': '1년',
              'icon': '📈',
              'description': '사업 확장 및 성장'
            },
            {
              'phase': '안정기',
              'duration': '2년',
              'icon': '💰',
              'description': '수익 안정화'
            },
            {
              'phase': '확장기',
              'duration': '3년+',
              'icon': '🌍',
              'description': '신규 시장 진출'
            }
          ],
          'industryScores': [
            {'industry': 'IT/테크', 'score': 80, 'trend': '상승'},
            {'industry': '요식업', 'score': 40, 'trend': '하락'},
            {'industry': '교육업', 'score': 100, 'trend': '급상승'},
            {'industry': '유통업', 'score': 60, 'trend': '보합'},
            {'industry': '서비스업', 'score': 80, 'trend': '상승'}
          ]
        }
      }
    }
  };

  static Map<String, dynamic> getExplanation(String fortuneType) {
    return explanations[fortuneType] ?? _getDefaultExplanation();
  }

  static Map<String, dynamic> _getDefaultExplanation() {
    return {
      'title': '운세',
      'description':
          '당신만의 특별한 운세 이야기를 들려드립니다. 매일 새로운 기대감으로 찾아주세요. 당신의 하루를 더 특별하게 만들어드릴게요.',
      'features': ['전문적인 운세 분석', '맞춤형 조언 제공', '행운 아이템 추천', '실생활 적용 가이드'],
      'tips': [
        '운세가 좋을 때는 과감하게, 나쁜 때는 조심스럽게',
        '매일 아침 운세를 확인하며 하루를 디자인해보세요',
        '당신의 직감과 운세가 만날 때 기적이 일어납니다'
      ]
    };
  }

  static List<Map<String, String>> getScoreInterpretations() {
    return [
      {
        'range': '90-100점',
        'label': '최고의 운세',
        'description': '모든 일이 순조롭게 진행됩니다. 적극적으로 도전하세요!',
        'advice': '이 기회를 놓치지 마세요. 중요한 결정을 내리기에 좋은 시기입니다.'
      },
      {
        'range': '70-89점',
        'label': '좋은 운세',
        'description': '대체로 좋은 기운이 함께합니다. 긍정적인 결과를 기대할 수 있습니다.',
        'advice': '자신감을 가지고 행동하세요. 작은 노력이 큰 성과로 이어집니다.'
      },
      {
        'range': '50-69점',
        'label': '보통 운세',
        'description': '평범하지만 안정적인 하루입니다. 꾸준히 노력하세요.',
        'advice': '일상적인 일에 충실하세요. 특별한 변화보다는 안정을 추구하세요.'
      },
      {
        'range': '30-49점',
        'label': '주의 필요',
        'description': '신중한 판단이 필요한 시기입니다. 서두르지 마세요.',
        'advice': '중요한 결정은 미루고, 충분히 생각한 후 행동하세요.'
      },
      {
        'range': '0-29점',
        'label': '어려운 시기',
        'description': '잠시 휴식을 취하며 재충전하세요. 곧 좋은 날이 올 것입니다.',
        'advice': '무리하지 말고 자신을 돌보세요. 이 시기도 지나갈 것입니다.'
      }
    ];
  }

  static Map<String, Map<String, String>> getLuckyItemExplanations() {
    return {
      'color': {
        'title': '행운의 색깔',
        'description': '오늘의 에너지와 조화를 이루는 색상입니다',
        'usage': '옷이나 액세서리로 착용하거나 주변에 두세요'
      },
      'number': {
        'title': '행운의 숫자',
        'description': '중요한 결정이나 선택 시 참고하세요',
        'usage': '번호 선택, 수량 결정 등에 활용하세요'
      },
      'direction': {
        'title': '행운의 방향',
        'description': '좋은 기운을 받을 수 있는 방향입니다',
        'usage': '중요한 일을 할 때 이 방향을 향하세요'
      },
      'time': {
        'title': '행운의 시간',
        'description': '가장 운이 좋은 시간대입니다',
        'usage': '중요한 일정을 이 시간에 잡으세요'
      },
      'food': {
        'title': '행운의 음식',
        'description': '에너지를 보충해주는 음식입니다',
        'usage': '오늘 한 끼는 이 음식을 드셔보세요'
      },
      'person': {
        'title': '행운의 인물',
        'description': '도움을 줄 수 있는 사람의 특징입니다',
        'usage': '이런 특징을 가진 사람과 협력하세요'
      },
      'place': {
        'title': '행운의 장소',
        'description': '좋은 기운이 모이는 장소입니다',
        'usage': '중요한 만남이나 결정을 이곳에서 하세요'
      },
      'item': {
        'title': '행운의 아이템',
        'description': '행운을 가져다주는 물건입니다',
        'usage': '오늘 하루 소지하거나 착용하세요'
      }
    };
  }
}
