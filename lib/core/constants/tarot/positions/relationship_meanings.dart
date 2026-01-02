/// Relationship spread interpretations for all 78 tarot cards
///
/// Positions: you (당신), partner (상대방), relationship (관계), challenges (도전), advice (조언)
class RelationshipMeanings {
  RelationshipMeanings._();

  /// Card index → orientation → position → interpretation
  static const Map<int, Map<String, Map<String, String>>> meanings = {
    // === MAJOR ARCANA (0-21) ===

    0: { // The Fool
      'upright': {
        'myFeelings': '새로운 관계나 단계에 열린 마음으로 다가가고 있습니다. 순수한 기대와 희망이 있습니다.',
        'theirFeelings': '상대방은 자유롭고 모험적인 에너지를 가지고 있습니다. 진지함보다 즐거움을 추구합니다.',
        'pastConnection': '이 관계는 새로운 시작의 에너지를 가지고 있습니다. 예측할 수 없지만 흥미롭습니다.',
        'currentDynamic': '무모함이나 진지함의 부족이 도전이 될 수 있습니다. 현실적인 기반이 필요합니다.',
        'futureOutlook': '열린 마음을 유지하되 발밑을 잘 살피세요. 모험과 신중함의 균형이 필요합니다.',
      },
      'reversed': {
        'myFeelings': '새로운 시작이 두렵거나 무모하게 행동하고 있습니다. 균형을 찾으세요.',
        'theirFeelings': '상대방이 약속에 주저하거나 경솔하게 행동할 수 있습니다.',
        'pastConnection': '관계가 방향을 잃었거나 불안정합니다. 기반이 필요합니다.',
        'currentDynamic': '약속에 대한 두려움이나 무책임함이 문제입니다.',
        'futureOutlook': '두려움을 인정하고 작은 단계부터 시작하세요. 급하게 굴지 마세요.',
      },
    },

    1: { // The Magician
      'upright': {
        'myFeelings': '관계에서 주도적이고 능동적입니다. 원하는 것을 만들어갈 힘이 있습니다.',
        'theirFeelings': '상대방은 매력적이고 능력 있습니다. 영향력이 있는 사람입니다.',
        'pastConnection': '이 관계에는 창조적인 잠재력이 있습니다. 함께 무언가를 만들어갈 수 있습니다.',
        'currentDynamic': '조작이나 과장의 위험이 있습니다. 진정성이 필요합니다.',
        'futureOutlook': '당신의 능력을 관계를 위해 긍정적으로 사용하세요. 진실되게 행동하세요.',
      },
      'reversed': {
        'myFeelings': '잠재력을 발휘하지 못하거나 조작적으로 행동하고 있습니다.',
        'theirFeelings': '상대방이 정직하지 않거나 능력을 남용할 수 있습니다.',
        'pastConnection': '관계의 잠재력이 활용되지 않고 있습니다. 또는 불신이 있습니다.',
        'currentDynamic': '기만이나 능력 부족이 문제입니다.',
        'futureOutlook': '정직함을 우선시하세요. 서로를 속이면 관계가 무너집니다.',
      },
    },

    2: { // The High Priestess
      'upright': {
        'myFeelings': '직관으로 관계를 이해하고 있습니다. 말하지 않아도 느끼는 것이 있습니다.',
        'theirFeelings': '상대방은 신비롭고 깊은 면이 있습니다. 모든 것을 드러내지 않습니다.',
        'pastConnection': '이 관계에는 깊은 직관적 연결이 있습니다. 말보다 느낌이 중요합니다.',
        'currentDynamic': '숨겨진 것이나 말하지 못한 것이 도전이 될 수 있습니다.',
        'futureOutlook': '직관을 신뢰하되 소통도 필요합니다. 느낌을 말로 표현하는 연습을 하세요.',
      },
      'reversed': {
        'myFeelings': '직관을 무시하거나 숨기는 것이 있습니다.',
        'theirFeelings': '상대방이 숨기는 것이 있거나 진심을 보여주지 않습니다.',
        'pastConnection': '관계에 비밀이나 불투명한 부분이 있습니다.',
        'currentDynamic': '불신이나 단절된 느낌이 문제입니다.',
        'futureOutlook': '숨기지 말고 열린 대화를 시도하세요. 직관에 귀 기울이세요.',
      },
    },

    3: { // The Empress
      'upright': {
        'myFeelings': '사랑과 돌봄을 풍성하게 주고 있습니다. 양육적인 에너지가 넘칩니다.',
        'theirFeelings': '상대방은 따뜻하고 감각적입니다. 사랑을 풍성하게 표현합니다.',
        'pastConnection': '이 관계는 풍요롭고 양육적입니다. 성장과 번영이 있습니다.',
        'currentDynamic': '과잉 보호나 의존성이 도전이 될 수 있습니다.',
        'futureOutlook': '사랑을 나누되 서로의 독립성도 존중하세요. 풍요롭게 주고받으세요.',
      },
      'reversed': {
        'myFeelings': '사랑을 주는 데 막혀있거나 과잉 보호하고 있습니다.',
        'theirFeelings': '상대방이 돌봄에 소홀하거나 지나치게 의존적입니다.',
        'pastConnection': '관계에 양육이나 풍요가 부족합니다.',
        'currentDynamic': '불균형한 돌봄이나 감정적 결핍이 문제입니다.',
        'futureOutlook': '균형 잡힌 돌봄을 추구하세요. 자신도 돌보면서 사랑하세요.',
      },
    },

    4: { // The Emperor
      'upright': {
        'myFeelings': '관계에서 안정과 구조를 제공하고 있습니다. 책임감 있게 행동합니다.',
        'theirFeelings': '상대방은 안정적이고 보호적입니다. 믿음직한 사람입니다.',
        'pastConnection': '이 관계에는 안정과 구조가 있습니다. 확고한 기반이 있습니다.',
        'currentDynamic': '지나친 통제나 경직성이 도전이 될 수 있습니다.',
        'futureOutlook': '안정을 주되 유연함도 필요합니다. 통제하려 하지 마세요.',
      },
      'reversed': {
        'myFeelings': '너무 통제하거나 책임을 회피하고 있습니다.',
        'theirFeelings': '상대방이 지배적이거나 믿음직하지 않습니다.',
        'pastConnection': '관계에 권력 불균형이나 불안정이 있습니다.',
        'currentDynamic': '통제 문제나 무책임함이 문제입니다.',
        'futureOutlook': '권력을 공유하고 서로를 동등하게 존중하세요.',
      },
    },

    5: { // The Hierophant
      'upright': {
        'myFeelings': '전통적인 가치관으로 관계에 접근합니다. 헌신과 약속을 중요시합니다.',
        'theirFeelings': '상대방은 전통적이고 신뢰할 수 있습니다. 공유된 가치관이 있습니다.',
        'pastConnection': '이 관계는 전통적이고 헌신적입니다. 공동의 신념이 있습니다.',
        'currentDynamic': '경직된 기대나 외부의 압력이 도전이 될 수 있습니다.',
        'futureOutlook': '공유된 가치관을 기반으로 하되 서로의 개성도 존중하세요.',
      },
      'reversed': {
        'myFeelings': '전통에 반발하거나 관계에 대한 기대가 다릅니다.',
        'theirFeelings': '상대방이 비전통적이거나 약속을 어깁니다.',
        'pastConnection': '관계가 관습에 맞지 않거나 가치관 충돌이 있습니다.',
        'currentDynamic': '가치관의 차이나 외부의 비난이 문제입니다.',
        'futureOutlook': '당신만의 규칙을 만들어도 됩니다. 진정으로 원하는 것을 추구하세요.',
      },
    },

    6: { // The Lovers
      'upright': {
        'myFeelings': '진정한 연결을 추구하고 있습니다. 마음으로 선택합니다.',
        'theirFeelings': '상대방과 깊은 유대가 있습니다. 영혼의 연결을 느낍니다.',
        'pastConnection': '이 관계는 진정한 사랑과 조화를 나타냅니다. 깊은 연결이 있습니다.',
        'currentDynamic': '중요한 선택이나 유혹이 도전이 될 수 있습니다.',
        'futureOutlook': '마음을 따르세요. 진정한 사랑을 선택하면 후회하지 않습니다.',
      },
      'reversed': {
        'myFeelings': '관계에 대한 의심이나 갈등이 있습니다.',
        'theirFeelings': '상대방과의 연결이 약해지거나 불화가 있습니다.',
        'pastConnection': '관계에 불화나 불균형이 있습니다.',
        'currentDynamic': '선택의 어려움이나 가치관 충돌이 문제입니다.',
        'futureOutlook': '무엇이 진정 원하는 것인지 명확히 하세요. 정직하게 소통하세요.',
      },
    },

    7: { // The Chariot
      'upright': {
        'myFeelings': '관계에서 목표를 향해 나아가고 있습니다. 결단력이 있습니다.',
        'theirFeelings': '상대방은 야망적이고 추진력이 있습니다.',
        'pastConnection': '이 관계는 앞으로 나아가고 있습니다. 함께 목표를 향해 갑니다.',
        'currentDynamic': '서로 다른 방향이나 통제 문제가 도전이 될 수 있습니다.',
        'futureOutlook': '같은 방향을 향해 함께 나아가세요. 균형을 잡고 전진하세요.',
      },
      'reversed': {
        'myFeelings': '관계에서 방향을 잃었거나 강압적으로 행동합니다.',
        'theirFeelings': '상대방이 공격적이거나 방향 없이 행동합니다.',
        'pastConnection': '관계가 정체되었거나 충돌이 있습니다.',
        'currentDynamic': '방향 상실이나 권력 싸움이 문제입니다.',
        'futureOutlook': '멈추고 방향을 재정립하세요. 함께 가는 길을 찾으세요.',
      },
    },

    8: { // Strength
      'upright': {
        'myFeelings': '인내와 부드러운 힘으로 관계를 다루고 있습니다.',
        'theirFeelings': '상대방은 내면의 강인함을 가지고 있습니다. 자기 통제력이 있습니다.',
        'pastConnection': '이 관계에는 진정한 힘이 있습니다. 어려움을 함께 극복합니다.',
        'currentDynamic': '감정의 폭발이나 힘의 불균형이 도전이 될 수 있습니다.',
        'futureOutlook': '부드러운 힘으로 관계를 다루세요. 인내와 연민이 답입니다.',
      },
      'reversed': {
        'myFeelings': '자기 의심이나 통제력 상실을 겪고 있습니다.',
        'theirFeelings': '상대방이 나약하거나 지배적입니다.',
        'pastConnection': '관계에 힘의 불균형이 있습니다.',
        'currentDynamic': '자기 의심이나 지배/피지배 패턴이 문제입니다.',
        'futureOutlook': '내면의 힘을 회복하세요. 건강한 힘의 균형을 찾으세요.',
      },
    },

    9: { // The Hermit
      'upright': {
        'myFeelings': '관계에 대해 깊이 성찰하고 있습니다. 혼자만의 시간이 필요합니다.',
        'theirFeelings': '상대방이 거리를 두거나 내향적입니다.',
        'pastConnection': '이 관계에는 깊은 성찰이 필요합니다. 내면의 작업이 있습니다.',
        'currentDynamic': '고립감이나 소통 부족이 도전이 될 수 있습니다.',
        'futureOutlook': '성찰의 시간을 존중하되 완전히 단절하지 마세요.',
      },
      'reversed': {
        'myFeelings': '지나치게 고립되거나 성찰을 피하고 있습니다.',
        'theirFeelings': '상대방이 완전히 단절되어 있거나 외로움에 시달립니다.',
        'pastConnection': '관계에 단절감이 있습니다. 소통이 필요합니다.',
        'currentDynamic': '극단적인 고립이나 회피가 문제입니다.',
        'futureOutlook': '혼자 있는 시간과 함께하는 시간의 균형을 찾으세요.',
      },
    },

    10: { // Wheel of Fortune
      'upright': {
        'myFeelings': '관계에서 변화의 흐름을 타고 있습니다. 운명적인 느낌이 있습니다.',
        'theirFeelings': '상대방은 변화의 에너지를 가져옵니다.',
        'pastConnection': '이 관계는 전환점에 있습니다. 새로운 사이클이 시작됩니다.',
        'currentDynamic': '예측 불가능한 변화가 도전이 될 수 있습니다.',
        'futureOutlook': '변화를 받아들이세요. 좋든 나쁘든 바퀴는 계속 돕니다.',
      },
      'reversed': {
        'myFeelings': '변화에 저항하거나 불운을 탓하고 있습니다.',
        'theirFeelings': '상대방이 부정적인 변화를 가져오거나 정체되어 있습니다.',
        'pastConnection': '관계가 정체되었거나 어려운 시기를 겪고 있습니다.',
        'currentDynamic': '변화에 대한 저항이나 불운이 문제입니다.',
        'futureOutlook': '흐름에 맞서지 마세요. 어려운 시기도 지나갑니다.',
      },
    },

    11: { // Justice
      'upright': {
        'myFeelings': '관계에서 공정함과 균형을 추구합니다.',
        'theirFeelings': '상대방은 공정하고 정직합니다.',
        'pastConnection': '이 관계에는 균형과 공정함이 있습니다. 동등한 파트너십입니다.',
        'currentDynamic': '판단이나 과거의 행동에 대한 책임이 도전이 될 수 있습니다.',
        'futureOutlook': '공정하게 대하고 행동에 책임을 지세요.',
      },
      'reversed': {
        'myFeelings': '불공정하게 대하거나 대우받고 있습니다.',
        'theirFeelings': '상대방이 불공정하거나 정직하지 않습니다.',
        'pastConnection': '관계에 불균형이나 불의가 있습니다.',
        'currentDynamic': '불공정함이나 거짓말이 문제입니다.',
        'futureOutlook': '균형을 회복하세요. 정직함이 관계의 기반입니다.',
      },
    },

    12: { // The Hanged Man
      'upright': {
        'myFeelings': '관계를 위해 무언가를 희생하거나 기다리고 있습니다.',
        'theirFeelings': '상대방이 결정을 미루거나 다른 시각으로 봅니다.',
        'pastConnection': '이 관계에는 기다림이나 새로운 관점이 필요합니다.',
        'currentDynamic': '정체감이나 희생의 불균형이 도전이 될 수 있습니다.',
        'futureOutlook': '다른 관점에서 보세요. 때로는 포기함으로써 얻습니다.',
      },
      'reversed': {
        'myFeelings': '불필요한 희생을 하거나 무의미하게 기다리고 있습니다.',
        'theirFeelings': '상대방이 이기적이거나 변화를 거부합니다.',
        'pastConnection': '관계가 정체되어 있습니다. 움직임이 필요합니다.',
        'currentDynamic': '무의미한 기다림이나 이기심이 문제입니다.',
        'futureOutlook': '언제 놓아줘야 할지 아세요. 무의미한 희생은 그만두세요.',
      },
    },

    13: { // Death
      'upright': {
        'myFeelings': '관계의 변환을 겪고 있습니다. 끝은 새로운 시작입니다.',
        'theirFeelings': '상대방이 변화를 가져오거나 변화가 필요합니다.',
        'pastConnection': '이 관계가 크게 변하거나 끝나고 새로 시작합니다.',
        'currentDynamic': '변화의 고통이나 저항이 도전이 될 수 있습니다.',
        'futureOutlook': '필요한 끝을 받아들이세요. 새로운 시작이 기다립니다.',
      },
      'reversed': {
        'myFeelings': '끝내야 할 것을 끝내지 못하고 있습니다.',
        'theirFeelings': '상대방이 변화를 거부하거나 과거에 집착합니다.',
        'pastConnection': '관계가 끝나야 하는데 끝나지 않고 있습니다.',
        'currentDynamic': '변화에 대한 저항이 문제입니다.',
        'futureOutlook': '두려워도 변화를 받아들이세요. 붙잡을수록 고통스럽습니다.',
      },
    },

    14: { // Temperance
      'upright': {
        'myFeelings': '관계에서 균형과 조화를 추구합니다. 인내심이 있습니다.',
        'theirFeelings': '상대방은 조화롭고 균형 잡힌 사람입니다.',
        'pastConnection': '이 관계에는 조화와 균형이 있습니다. 건강한 조합입니다.',
        'currentDynamic': '인내심의 한계나 외부의 불균형이 도전이 될 수 있습니다.',
        'futureOutlook': '중용을 지키세요. 극단을 피하고 균형을 찾으세요.',
      },
      'reversed': {
        'myFeelings': '불균형하거나 극단적으로 행동하고 있습니다.',
        'theirFeelings': '상대방이 불균형하거나 극단적입니다.',
        'pastConnection': '관계에 불균형이나 갈등이 있습니다.',
        'currentDynamic': '극단이나 불화가 문제입니다.',
        'futureOutlook': '균형을 찾으세요. 서로의 중간 지점을 찾으세요.',
      },
    },

    15: { // The Devil
      'upright': {
        'myFeelings': '관계에서 집착이나 의존이 있습니다. 속박되어 있다고 느낍니다.',
        'theirFeelings': '상대방이 지배적이거나 중독적인 관계입니다.',
        'pastConnection': '이 관계에 불건강한 집착이나 의존이 있습니다.',
        'currentDynamic': '집착, 중독, 속박이 도전입니다.',
        'futureOutlook': '사슬을 인식하세요. 건강하지 않은 패턴에서 벗어나세요.',
      },
      'reversed': {
        'myFeelings': '불건강한 패턴에서 벗어나려 합니다.',
        'theirFeelings': '상대방도 변화를 원하거나 이미 벗어났습니다.',
        'pastConnection': '관계가 건강해지거나 끝날 수 있습니다.',
        'currentDynamic': '완전히 벗어나는 것이 도전입니다.',
        'futureOutlook': '자유를 향해 나아가세요. 건강한 관계를 선택하세요.',
      },
    },

    16: { // The Tower
      'upright': {
        'myFeelings': '관계에서 큰 충격이나 깨달음을 겪고 있습니다.',
        'theirFeelings': '상대방이 충격적인 진실을 드러냈거나 변화를 가져옵니다.',
        'pastConnection': '이 관계가 급격하게 변하거나 무너지고 있습니다.',
        'currentDynamic': '갑작스러운 변화나 충격이 도전입니다.',
        'futureOutlook': '폭풍을 견디세요. 무너진 후에 더 나은 것을 세울 수 있습니다.',
      },
      'reversed': {
        'myFeelings': '필요한 변화를 피하거나 지연시키고 있습니다.',
        'theirFeelings': '상대방이 변화를 막거나 천천히 진행합니다.',
        'pastConnection': '관계의 문제가 서서히 드러나고 있습니다.',
        'currentDynamic': '피하려는 변화가 문제입니다.',
        'futureOutlook': '자발적으로 변화하면 덜 고통스럽습니다.',
      },
    },

    17: { // The Star
      'upright': {
        'myFeelings': '관계에 희망과 치유를 가져옵니다. 낙관적입니다.',
        'theirFeelings': '상대방은 영감을 주고 치유적입니다.',
        'pastConnection': '이 관계에 희망과 치유가 있습니다. 밝은 미래가 기다립니다.',
        'currentDynamic': '비현실적인 기대가 도전이 될 수 있습니다.',
        'futureOutlook': '희망을 유지하되 현실도 보세요. 함께 치유하세요.',
      },
      'reversed': {
        'myFeelings': '희망을 잃었거나 비관적입니다.',
        'theirFeelings': '상대방이 절망적이거나 치유되지 않은 상처가 있습니다.',
        'pastConnection': '관계에 희망이 부족합니다.',
        'currentDynamic': '절망이나 치유되지 않은 상처가 문제입니다.',
        'futureOutlook': '희망을 되찾으세요. 상처를 치유할 시간이 필요합니다.',
      },
    },

    18: { // The Moon
      'upright': {
        'myFeelings': '관계에 대해 불안하거나 혼란스럽습니다. 숨겨진 것이 있습니다.',
        'theirFeelings': '상대방이 신비롭거나 숨기는 것이 있습니다.',
        'pastConnection': '이 관계에 불확실함이나 숨겨진 것이 있습니다.',
        'currentDynamic': '불안, 착각, 비밀이 도전입니다.',
        'futureOutlook': '직관을 따르되 두려움에 속지 마세요. 진실을 찾으세요.',
      },
      'reversed': {
        'myFeelings': '혼란에서 벗어나고 있습니다. 진실이 보입니다.',
        'theirFeelings': '상대방의 진짜 모습이 드러나고 있습니다.',
        'pastConnection': '관계의 진실이 밝혀지고 있습니다.',
        'currentDynamic': '드러난 진실을 받아들이는 것이 도전입니다.',
        'futureOutlook': '명확함을 환영하세요. 진실이 자유를 줍니다.',
      },
    },

    19: { // The Sun
      'upright': {
        'myFeelings': '관계에서 기쁨과 활력이 넘칩니다. 행복합니다.',
        'theirFeelings': '상대방은 밝고 긍정적입니다. 함께 있으면 행복합니다.',
        'pastConnection': '이 관계는 행복하고 밝습니다. 성공적인 관계입니다.',
        'currentDynamic': '지나친 낙관이 현실을 가릴 수 있습니다.',
        'futureOutlook': '기쁨을 나누세요. 밝은 에너지를 유지하세요.',
      },
      'reversed': {
        'myFeelings': '관계에서 기쁨을 잃었습니다. 우울합니다.',
        'theirFeelings': '상대방이 부정적이거나 기쁨을 빼앗아갑니다.',
        'pastConnection': '관계의 빛이 흐려졌습니다.',
        'currentDynamic': '부정적인 에너지나 행복 감소가 문제입니다.',
        'futureOutlook': '빛을 되찾으세요. 함께 기쁨을 찾는 방법을 찾으세요.',
      },
    },

    20: { // Judgement
      'upright': {
        'myFeelings': '관계에 대해 각성하고 있습니다. 과거를 돌아보고 새롭게 시작합니다.',
        'theirFeelings': '상대방도 각성하고 있거나 변화를 원합니다.',
        'pastConnection': '이 관계가 새로운 단계로 각성하고 있습니다.',
        'currentDynamic': '과거의 판단이나 용서가 도전이 될 수 있습니다.',
        'futureOutlook': '과거를 정리하고 새롭게 시작하세요. 서로를 용서하세요.',
      },
      'reversed': {
        'myFeelings': '과거에 매여 있거나 자기 성찰을 피하고 있습니다.',
        'theirFeelings': '상대방이 변화를 거부하거나 과거에 집착합니다.',
        'pastConnection': '관계가 과거에 묶여 있습니다.',
        'currentDynamic': '용서 부족이나 자기 인식 부족이 문제입니다.',
        'futureOutlook': '과거를 놓아주세요. 새로운 시작을 위해 용서하세요.',
      },
    },

    21: { // The World
      'upright': {
        'myFeelings': '관계에서 완성감을 느낍니다. 만족합니다.',
        'theirFeelings': '상대방과 완전한 조화를 이루고 있습니다.',
        'pastConnection': '이 관계는 완성되었거나 새로운 장을 열고 있습니다.',
        'currentDynamic': '다음 단계로 나아가는 것이 도전이 될 수 있습니다.',
        'futureOutlook': '성취를 축하하고 새로운 여정을 준비하세요.',
      },
      'reversed': {
        'myFeelings': '완성감이 부족하거나 관계가 미완입니다.',
        'theirFeelings': '상대방과 완전한 조화에 이르지 못했습니다.',
        'pastConnection': '관계가 완성되지 않았습니다. 더 노력이 필요합니다.',
        'currentDynamic': '미완성이나 막힌 느낌이 문제입니다.',
        'futureOutlook': '완성을 향해 노력하세요. 마지막 조각을 찾으세요.',
      },
    },

    // === MINOR ARCANA - WANDS (22-35) ===
    // Ace to King of Wands
    22: { // Ace of Wands
      'upright': {
        'myFeelings': '관계에 새로운 열정을 가져옵니다.',
        'theirFeelings': '상대방이 열정적이고 흥미롭습니다.',
        'pastConnection': '이 관계에 새로운 불꽃이 있습니다.',
        'currentDynamic': '열정이 빨리 식을 수 있습니다.',
        'futureOutlook': '열정을 지속적으로 키워가세요.',
      },
      'reversed': {
        'myFeelings': '열정이 식었거나 막혀 있습니다.',
        'theirFeelings': '상대방에게서 열정이 사라졌습니다.',
        'pastConnection': '관계의 불꽃이 꺼지고 있습니다.',
        'currentDynamic': '무기력함이나 좌절이 문제입니다.',
        'futureOutlook': '열정을 되살리거나 새로운 방향을 찾으세요.',
      },
    },
    23: { 'upright': { 'myFeelings': '관계의 미래를 계획하고 있습니다.', 'theirFeelings': '상대방도 장기적 비전이 있습니다.', 'pastConnection': '함께 미래를 계획할 수 있습니다.', 'currentDynamic': '계획만 하고 행동하지 않을 수 있습니다.', 'futureOutlook': '비전을 공유하고 함께 행동하세요.' }, 'reversed': { 'myFeelings': '미래가 불확실하게 느껴집니다.', 'theirFeelings': '상대방의 계획이 당신과 다릅니다.', 'pastConnection': '방향에 대한 갈등이 있습니다.', 'currentDynamic': '비전의 차이가 문제입니다.', 'futureOutlook': '솔직하게 미래에 대해 대화하세요.' } },
    24: { 'upright': { 'myFeelings': '관계에서 결과를 기다리고 있습니다.', 'theirFeelings': '상대방과 함께 성장하고 있습니다.', 'pastConnection': '관계가 확장되고 있습니다.', 'currentDynamic': '기다림이 지칠 수 있습니다.', 'futureOutlook': '인내하세요. 좋은 결과가 올 것입니다.' }, 'reversed': { 'myFeelings': '기대가 좌절되었습니다.', 'theirFeelings': '상대방이 기대에 못 미칩니다.', 'pastConnection': '관계의 성장이 막혀 있습니다.', 'currentDynamic': '좌절감이 문제입니다.', 'futureOutlook': '기대를 조정하고 현실을 받아들이세요.' } },
    25: { 'upright': { 'myFeelings': '관계에서 기쁨을 느낍니다.', 'theirFeelings': '상대방과 축하할 일이 있습니다.', 'pastConnection': '관계가 안정되고 행복합니다.', 'currentDynamic': '편안함에 안주할 수 있습니다.', 'futureOutlook': '기쁨을 나누고 감사하세요.' }, 'reversed': { 'myFeelings': '불안정함을 느낍니다.', 'theirFeelings': '상대방과의 조화가 깨졌습니다.', 'pastConnection': '관계에 불화가 있습니다.', 'currentDynamic': '불안정이 문제입니다.', 'futureOutlook': '조화를 회복하세요.' } },
    26: { 'upright': { 'myFeelings': '관계에서 경쟁이나 갈등을 느낍니다.', 'theirFeelings': '상대방과 충돌이 있습니다.', 'pastConnection': '관계에 긴장이 있습니다.', 'currentDynamic': '갈등 해결이 도전입니다.', 'futureOutlook': '건강하게 경쟁하고 갈등을 해결하세요.' }, 'reversed': { 'myFeelings': '갈등을 피하고 있습니다.', 'theirFeelings': '상대방이 갈등을 원하지 않습니다.', 'pastConnection': '숨겨진 긴장이 있습니다.', 'currentDynamic': '회피된 갈등이 문제입니다.', 'futureOutlook': '문제를 직면하세요.' } },
    27: { 'upright': { 'myFeelings': '관계에서 인정받고 있습니다.', 'theirFeelings': '상대방이 당신을 자랑스러워합니다.', 'pastConnection': '관계가 성공적입니다.', 'currentDynamic': '자만심이 문제될 수 있습니다.', 'futureOutlook': '겸손하게 성공을 나누세요.' }, 'reversed': { 'myFeelings': '인정받지 못한다고 느낍니다.', 'theirFeelings': '상대방이 당신을 과소평가합니다.', 'pastConnection': '관계에서 인정이 부족합니다.', 'currentDynamic': '자존감 문제가 있습니다.', 'futureOutlook': '자기 가치를 알고 표현하세요.' } },
    28: { 'upright': { 'myFeelings': '관계를 지키기 위해 싸우고 있습니다.', 'theirFeelings': '상대방과 함께 도전에 맞서고 있습니다.', 'pastConnection': '관계가 도전받고 있지만 견디고 있습니다.', 'currentDynamic': '지속적인 방어가 지칩니다.', 'futureOutlook': '포기하지 마세요. 지킬 가치가 있습니다.' }, 'reversed': { 'myFeelings': '싸움에 지쳐가고 있습니다.', 'theirFeelings': '상대방이 포기하려 합니다.', 'pastConnection': '관계가 위협받고 있습니다.', 'currentDynamic': '지침이 문제입니다.', 'futureOutlook': '휴식을 취하고 힘을 모으세요.' } },
    29: { 'upright': { 'myFeelings': '관계가 빠르게 발전하고 있습니다.', 'theirFeelings': '상대방과의 소통이 활발합니다.', 'pastConnection': '관계에 흥미로운 일들이 일어나고 있습니다.', 'currentDynamic': '너무 빠른 속도가 부담될 수 있습니다.', 'futureOutlook': '흐름을 타되 중요한 것을 놓치지 마세요.' }, 'reversed': { 'myFeelings': '진전이 멈췄습니다.', 'theirFeelings': '상대방과의 소통이 줄었습니다.', 'pastConnection': '관계가 정체되어 있습니다.', 'currentDynamic': '정체가 문제입니다.', 'futureOutlook': '다시 소통하고 움직이세요.' } },
    30: { 'upright': { 'myFeelings': '관계에서 지쳤지만 포기하지 않습니다.', 'theirFeelings': '상대방도 힘들어하고 있습니다.', 'pastConnection': '관계가 시험받고 있습니다.', 'currentDynamic': '지침이 도전입니다.', 'futureOutlook': '조금만 더 버티세요. 끝이 가깝습니다.' }, 'reversed': { 'myFeelings': '지나치게 방어적입니다.', 'theirFeelings': '상대방이 포기했습니다.', 'pastConnection': '관계가 끝나가고 있습니다.', 'currentDynamic': '지속할 힘이 없습니다.', 'futureOutlook': '쉴 때인지 끝낼 때인지 결정하세요.' } },
    31: { 'upright': { 'myFeelings': '관계에서 너무 많은 짐을 지고 있습니다.', 'theirFeelings': '상대방이 도움이 되지 않습니다.', 'pastConnection': '관계의 부담이 큽니다.', 'currentDynamic': '과부하가 문제입니다.', 'futureOutlook': '짐을 나누거나 내려놓으세요.' }, 'reversed': { 'myFeelings': '짐을 덜었거나 소진되었습니다.', 'theirFeelings': '상대방이 도움을 제안합니다.', 'pastConnection': '부담이 줄어들고 있습니다.', 'currentDynamic': '회복이 필요합니다.', 'futureOutlook': '도움을 받아들이세요.' } },
    32: { 'upright': { 'myFeelings': '새로운 관계에 대한 열정이 있습니다.', 'theirFeelings': '상대방이 젊고 열정적입니다.', 'pastConnection': '관계에 신선한 에너지가 있습니다.', 'currentDynamic': '미숙함이 문제될 수 있습니다.', 'futureOutlook': '열정을 유지하고 경험에서 배우세요.' }, 'reversed': { 'myFeelings': '열정이 식거나 방향을 잃었습니다.', 'theirFeelings': '상대방이 미숙하거나 변덕스럽습니다.', 'pastConnection': '관계에 방향성이 없습니다.', 'currentDynamic': '미숙함이나 방향 상실이 문제입니다.', 'futureOutlook': '성숙해지고 방향을 찾으세요.' } },
    33: { 'upright': { 'myFeelings': '열정적으로 관계를 추구합니다.', 'theirFeelings': '상대방이 열정적이고 모험적입니다.', 'pastConnection': '관계에 흥분과 모험이 있습니다.', 'currentDynamic': '성급함이 문제될 수 있습니다.', 'futureOutlook': '열정을 따르되 성급하지 마세요.' }, 'reversed': { 'myFeelings': '성급하거나 공격적입니다.', 'theirFeelings': '상대방이 충동적이거나 부재합니다.', 'pastConnection': '관계가 불안정합니다.', 'currentDynamic': '충동성이 문제입니다.', 'futureOutlook': '속도를 조절하세요.' } },
    34: { 'upright': { 'myFeelings': '자신감 있게 관계에 임합니다.', 'theirFeelings': '상대방이 따뜻하고 자신감 있습니다.', 'pastConnection': '관계에 열정과 따뜻함이 있습니다.', 'currentDynamic': '질투나 지배가 문제될 수 있습니다.', 'futureOutlook': '자신감을 유지하되 상대방도 빛나게 하세요.' }, 'reversed': { 'myFeelings': '자신감이 부족하거나 질투합니다.', 'theirFeelings': '상대방이 지배적이거나 질투합니다.', 'pastConnection': '관계에 불화가 있습니다.', 'currentDynamic': '질투나 불안정이 문제입니다.', 'futureOutlook': '자신감을 회복하고 질투를 극복하세요.' } },
    35: { 'upright': { 'myFeelings': '관계에서 리더십을 발휘합니다.', 'theirFeelings': '상대방이 야망적이고 비전이 있습니다.', 'pastConnection': '관계에 비전과 방향이 있습니다.', 'currentDynamic': '독단이 문제될 수 있습니다.', 'futureOutlook': '비전을 공유하고 함께 이끄세요.' }, 'reversed': { 'myFeelings': '오만하거나 방향을 잃었습니다.', 'theirFeelings': '상대방이 독재적이거나 무능합니다.', 'pastConnection': '관계에 리더십 문제가 있습니다.', 'currentDynamic': '권력 문제가 있습니다.', 'futureOutlook': '겸손해지고 함께 결정하세요.' } },

    // === MINOR ARCANA - CUPS (36-49) ===
    36: { 'upright': { 'myFeelings': '새로운 사랑에 열려 있습니다.', 'theirFeelings': '상대방에게서 진정한 감정을 느낍니다.', 'pastConnection': '관계에 깊은 감정적 연결이 시작됩니다.', 'currentDynamic': '감정을 표현하는 것이 어려울 수 있습니다.', 'futureOutlook': '마음을 열고 사랑을 받아들이세요.' }, 'reversed': { 'myFeelings': '감정적으로 막혀 있습니다.', 'theirFeelings': '상대방이 감정을 표현하지 않습니다.', 'pastConnection': '감정적 연결이 약합니다.', 'currentDynamic': '감정 억압이 문제입니다.', 'futureOutlook': '마음의 벽을 허물어야 합니다.' } },
    37: { 'upright': { 'myFeelings': '상대방과 깊이 연결되어 있습니다.', 'theirFeelings': '상대방도 당신을 깊이 사랑합니다.', 'pastConnection': '조화롭고 균형 잡힌 관계입니다.', 'currentDynamic': '외부의 방해가 있을 수 있습니다.', 'futureOutlook': '서로에게 집중하세요.' }, 'reversed': { 'myFeelings': '관계에 불균형이 있습니다.', 'theirFeelings': '상대방과 맞지 않습니다.', 'pastConnection': '불화나 단절이 있습니다.', 'currentDynamic': '균형을 찾는 것이 도전입니다.', 'futureOutlook': '소통하고 균형을 찾으세요.' } },
    38: { 'upright': { 'myFeelings': '친구들과 함께 기쁨을 나눕니다.', 'theirFeelings': '상대방과 사회적 활동을 즐깁니다.', 'pastConnection': '축하와 기쁨이 있습니다.', 'currentDynamic': '외부 관계가 부담될 수 있습니다.', 'futureOutlook': '함께 기쁨을 나누세요.' }, 'reversed': { 'myFeelings': '고립감을 느낍니다.', 'theirFeelings': '상대방이 사회적으로 거리를 둡니다.', 'pastConnection': '사회적 문제가 있습니다.', 'currentDynamic': '고립이나 갈등이 문제입니다.', 'futureOutlook': '연결을 회복하세요.' } },
    39: { 'upright': { 'myFeelings': '관계에 만족하지 못합니다.', 'theirFeelings': '상대방이 무관심합니다.', 'pastConnection': '감정적 정체가 있습니다.', 'currentDynamic': '무관심이 문제입니다.', 'futureOutlook': '눈앞의 기회를 보세요.' }, 'reversed': { 'myFeelings': '새로운 가능성에 눈뜨고 있습니다.', 'theirFeelings': '상대방이 관심을 보이기 시작합니다.', 'pastConnection': '관계가 회복되고 있습니다.', 'currentDynamic': '변화를 받아들이는 것이 도전입니다.', 'futureOutlook': '기회를 잡으세요.' } },
    40: { 'upright': { 'myFeelings': '상실감에 빠져 있습니다.', 'theirFeelings': '상대방도 슬픔을 겪고 있습니다.', 'pastConnection': '관계에 상처가 있습니다.', 'currentDynamic': '슬픔을 극복하는 것이 도전입니다.', 'futureOutlook': '남은 것에 집중하세요. 희망은 있습니다.' }, 'reversed': { 'myFeelings': '회복되고 있습니다.', 'theirFeelings': '상대방이 회복을 돕습니다.', 'pastConnection': '관계가 치유되고 있습니다.', 'currentDynamic': '완전히 놓아주는 것이 도전입니다.', 'futureOutlook': '앞으로 나아가세요.' } },
    41: { 'upright': { 'myFeelings': '과거의 연결이나 추억이 있습니다.', 'theirFeelings': '상대방과 공유된 역사가 있습니다.', 'pastConnection': '관계에 향수가 있습니다.', 'currentDynamic': '과거에 머무르는 것이 문제될 수 있습니다.', 'futureOutlook': '좋은 추억을 간직하되 현재를 살으세요.' }, 'reversed': { 'myFeelings': '과거에 집착하고 있습니다.', 'theirFeelings': '상대방이 과거를 놓지 못합니다.', 'pastConnection': '과거가 현재를 방해합니다.', 'currentDynamic': '과거 집착이 문제입니다.', 'futureOutlook': '과거를 놓고 현재에 집중하세요.' } },
    42: { 'upright': { 'myFeelings': '많은 선택에 혼란스럽습니다.', 'theirFeelings': '상대방에 대한 환상이 있을 수 있습니다.', 'pastConnection': '관계에 비현실적인 기대가 있습니다.', 'currentDynamic': '환상과 현실을 구분하는 것이 도전입니다.', 'futureOutlook': '현실적으로 판단하세요.' }, 'reversed': { 'myFeelings': '현실을 직시하고 있습니다.', 'theirFeelings': '상대방의 진짜 모습을 보고 있습니다.', 'pastConnection': '관계가 명확해지고 있습니다.', 'currentDynamic': '현실이 불편할 수 있습니다.', 'futureOutlook': '진실을 받아들이세요.' } },
    43: { 'upright': { 'myFeelings': '관계에서 떠나려 합니다.', 'theirFeelings': '상대방이 떠나거나 감정적으로 단절됩니다.', 'pastConnection': '관계가 끝나가거나 변화가 필요합니다.', 'currentDynamic': '떠나는 것이 어렵습니다.', 'futureOutlook': '더 나은 것을 위해 떠날 용기를 가지세요.' }, 'reversed': { 'myFeelings': '떠나지 못하고 있습니다.', 'theirFeelings': '상대방이 떠났다가 돌아올 수 있습니다.', 'pastConnection': '관계가 끝나지 않고 있습니다.', 'currentDynamic': '떠날지 머물지 결정하는 것이 도전입니다.', 'futureOutlook': '무엇이 진정 원하는 것인지 생각하세요.' } },
    44: { 'upright': { 'myFeelings': '관계에서 만족을 느낍니다.', 'theirFeelings': '상대방이 당신을 행복하게 합니다.', 'pastConnection': '행복하고 만족스러운 관계입니다.', 'currentDynamic': '자만이 문제될 수 있습니다.', 'futureOutlook': '감사하며 행복을 누리세요.' }, 'reversed': { 'myFeelings': '만족을 느끼지 못합니다.', 'theirFeelings': '상대방이 만족스럽지 않습니다.', 'pastConnection': '관계에 불만이 있습니다.', 'currentDynamic': '불만족이 문제입니다.', 'futureOutlook': '진정한 행복이 무엇인지 찾아보세요.' } },
    45: { 'upright': { 'myFeelings': '가정의 행복을 꿈꿉니다.', 'theirFeelings': '상대방과 함께하는 미래를 봅니다.', 'pastConnection': '완전하고 행복한 관계입니다.', 'currentDynamic': '비현실적인 기대가 문제될 수 있습니다.', 'futureOutlook': '함께 행복을 만들어가세요.' }, 'reversed': { 'myFeelings': '가정의 꿈이 깨졌습니다.', 'theirFeelings': '상대방과 갈등이 있습니다.', 'pastConnection': '관계에 문제가 있습니다.', 'currentDynamic': '갈등이나 깨진 기대가 문제입니다.', 'futureOutlook': '현실적인 기대를 가지고 노력하세요.' } },
    46: { 'upright': { 'myFeelings': '순수한 감정을 표현합니다.', 'theirFeelings': '상대방이 로맨틱합니다.', 'pastConnection': '관계에 순수한 사랑이 있습니다.', 'currentDynamic': '미숙함이 문제될 수 있습니다.', 'futureOutlook': '순수한 감정을 소중히 하세요.' }, 'reversed': { 'myFeelings': '감정을 표현하지 못합니다.', 'theirFeelings': '상대방이 비현실적입니다.', 'pastConnection': '감정적 미숙함이 있습니다.', 'currentDynamic': '미숙함이나 비현실이 문제입니다.', 'futureOutlook': '감정적으로 성숙해지세요.' } },
    47: { 'upright': { 'myFeelings': '로맨틱한 제안을 합니다.', 'theirFeelings': '상대방이 로맨틱하게 다가옵니다.', 'pastConnection': '관계에 로맨스가 넘칩니다.', 'currentDynamic': '비현실적인 기대가 문제될 수 있습니다.', 'futureOutlook': '로맨스를 즐기되 현실도 보세요.' }, 'reversed': { 'myFeelings': '실망하거나 속고 있습니다.', 'theirFeelings': '상대방이 진실하지 않을 수 있습니다.', 'pastConnection': '관계에 기만이 있을 수 있습니다.', 'currentDynamic': '기만이나 환멸이 문제입니다.', 'futureOutlook': '진정성을 확인하세요.' } },
    48: { 'upright': { 'myFeelings': '공감과 직관으로 관계합니다.', 'theirFeelings': '상대방이 정서적으로 지지합니다.', 'pastConnection': '감정적으로 풍요로운 관계입니다.', 'currentDynamic': '감정에 너무 빠질 수 있습니다.', 'futureOutlook': '공감하되 균형을 유지하세요.' }, 'reversed': { 'myFeelings': '감정적으로 불안정합니다.', 'theirFeelings': '상대방이 감정적으로 불안정합니다.', 'pastConnection': '감정적 혼란이 있습니다.', 'currentDynamic': '감정적 불균형이 문제입니다.', 'futureOutlook': '감정적 균형을 찾으세요.' } },
    49: { 'upright': { 'myFeelings': '감정을 현명하게 다룹니다.', 'theirFeelings': '상대방이 감정적으로 성숙합니다.', 'pastConnection': '감정적으로 균형 잡힌 관계입니다.', 'currentDynamic': '감정을 숨기는 것이 문제될 수 있습니다.', 'futureOutlook': '균형을 유지하면서 진실한 감정을 나누세요.' }, 'reversed': { 'myFeelings': '감정을 억압하거나 통제 불능입니다.', 'theirFeelings': '상대방이 감정적으로 냉담하거나 폭발적입니다.', 'pastConnection': '감정적 불균형이 있습니다.', 'currentDynamic': '감정 관리가 문제입니다.', 'futureOutlook': '건강한 감정 표현을 연습하세요.' } },

    // === MINOR ARCANA - SWORDS (50-63) ===
    50: { 'upright': { 'myFeelings': '관계에 대한 명확한 깨달음이 있습니다.', 'theirFeelings': '상대방이 직접적입니다.', 'pastConnection': '진실이 드러납니다.', 'currentDynamic': '진실이 상처를 줄 수 있습니다.', 'futureOutlook': '진실을 추구하되 친절하게 전달하세요.' }, 'reversed': { 'myFeelings': '혼란스럽습니다.', 'theirFeelings': '상대방이 명확하지 않습니다.', 'pastConnection': '오해가 있습니다.', 'currentDynamic': '혼란이 문제입니다.', 'futureOutlook': '명확하게 소통하세요.' } },
    51: { 'upright': { 'myFeelings': '관계에서 결정을 피하고 있습니다.', 'theirFeelings': '상대방도 결정을 미루고 있습니다.', 'pastConnection': '교착 상태입니다.', 'currentDynamic': '결정 회피가 문제입니다.', 'futureOutlook': '결정을 내려야 합니다.' }, 'reversed': { 'myFeelings': '진실을 마주하고 있습니다.', 'theirFeelings': '상대방이 결정을 내렸습니다.', 'pastConnection': '변화가 시작됩니다.', 'currentDynamic': '결과를 받아들이는 것이 도전입니다.', 'futureOutlook': '변화를 받아들이세요.' } },
    52: { 'upright': { 'myFeelings': '마음이 아픕니다.', 'theirFeelings': '상대방이 상처를 주었습니다.', 'pastConnection': '관계에 상처가 있습니다.', 'currentDynamic': '치유가 필요합니다.', 'futureOutlook': '시간을 두고 치유하세요.' }, 'reversed': { 'myFeelings': '치유되고 있습니다.', 'theirFeelings': '상대방과 화해하고 있습니다.', 'pastConnection': '관계가 회복되고 있습니다.', 'currentDynamic': '완전한 용서가 도전입니다.', 'futureOutlook': '용서하고 앞으로 나아가세요.' } },
    53: { 'upright': { 'myFeelings': '관계에서 쉬고 싶습니다.', 'theirFeelings': '상대방도 거리가 필요합니다.', 'pastConnection': '휴식이 필요합니다.', 'currentDynamic': '휴식 vs 회피의 균형입니다.', 'futureOutlook': '잠시 쉬고 재충전하세요.' }, 'reversed': { 'myFeelings': '활동을 재개할 때입니다.', 'theirFeelings': '상대방이 돌아올 준비가 되었습니다.', 'pastConnection': '휴식이 끝나고 있습니다.', 'currentDynamic': '너무 오래 쉬면 안 됩니다.', 'futureOutlook': '행동을 시작하세요.' } },
    54: { 'upright': { 'myFeelings': '관계에서 갈등이 있습니다.', 'theirFeelings': '상대방과 싸움이 있습니다.', 'pastConnection': '승자 없는 싸움입니다.', 'currentDynamic': '갈등 해결이 도전입니다.', 'futureOutlook': '이길 가치가 있는 싸움인지 생각하세요.' }, 'reversed': { 'myFeelings': '갈등에서 물러납니다.', 'theirFeelings': '상대방이 화해를 원합니다.', 'pastConnection': '갈등이 해소되고 있습니다.', 'currentDynamic': '완전한 화해가 도전입니다.', 'futureOutlook': '화해를 향해 노력하세요.' } },
    55: { 'upright': { 'myFeelings': '힘든 관계에서 벗어나고 있습니다.', 'theirFeelings': '상대방과 함께 어려움을 떠납니다.', 'pastConnection': '관계가 더 나은 방향으로 가고 있습니다.', 'currentDynamic': '전환이 쉽지 않습니다.', 'futureOutlook': '더 나은 곳을 향해 함께 나아가세요.' }, 'reversed': { 'myFeelings': '떠나지 못하고 있습니다.', 'theirFeelings': '상대방이 변화를 막고 있습니다.', 'pastConnection': '관계가 막혀 있습니다.', 'currentDynamic': '전환의 어려움이 문제입니다.', 'futureOutlook': '무엇이 막고 있는지 살펴보세요.' } },
    56: { 'upright': { 'myFeelings': '관계에서 전략적입니다.', 'theirFeelings': '상대방이 숨기는 것이 있습니다.', 'pastConnection': '비밀이나 속임이 있을 수 있습니다.', 'currentDynamic': '신뢰 문제가 있습니다.', 'futureOutlook': '정직하게 대하세요.' }, 'reversed': { 'myFeelings': '진실을 말합니다.', 'theirFeelings': '상대방의 비밀이 드러납니다.', 'pastConnection': '진실이 밝혀지고 있습니다.', 'currentDynamic': '진실의 결과를 감당해야 합니다.', 'futureOutlook': '정직함을 유지하세요.' } },
    57: { 'upright': { 'myFeelings': '관계에서 갇힌 느낌입니다.', 'theirFeelings': '상대방이 당신을 제한합니다.', 'pastConnection': '관계에 속박감이 있습니다.', 'currentDynamic': '자기 제한을 인식하는 것이 도전입니다.', 'futureOutlook': '눈을 뜨면 탈출구가 보입니다.' }, 'reversed': { 'myFeelings': '자유로워지고 있습니다.', 'theirFeelings': '상대방도 변화하고 있습니다.', 'pastConnection': '관계가 더 자유로워지고 있습니다.', 'currentDynamic': '완전한 해방이 도전입니다.', 'futureOutlook': '자유를 향해 나아가세요.' } },
    58: { 'upright': { 'myFeelings': '관계가 걱정됩니다.', 'theirFeelings': '상대방 때문에 불안합니다.', 'pastConnection': '관계에 불안이 있습니다.', 'currentDynamic': '걱정이 과도합니다.', 'futureOutlook': '걱정은 실제보다 큽니다. 현실을 확인하세요.' }, 'reversed': { 'myFeelings': '걱정이 줄어들고 있습니다.', 'theirFeelings': '상대방이 안심시켜줍니다.', 'pastConnection': '불안이 해소되고 있습니다.', 'currentDynamic': '완전히 안심하는 것이 도전입니다.', 'futureOutlook': '희망을 가지세요.' } },
    59: { 'upright': { 'myFeelings': '관계의 끝을 느낍니다.', 'theirFeelings': '상대방이 배신하거나 떠났습니다.', 'pastConnection': '관계가 끝났습니다.', 'currentDynamic': '끝을 받아들이는 것이 도전입니다.', 'futureOutlook': '끝은 새로운 시작입니다.' }, 'reversed': { 'myFeelings': '회복되고 있습니다.', 'theirFeelings': '상대방과 재건하고 있습니다.', 'pastConnection': '관계가 회복될 수 있습니다.', 'currentDynamic': '완전한 회복이 도전입니다.', 'futureOutlook': '다시 일어나세요.' } },
    60: { 'upright': { 'myFeelings': '호기심으로 관계를 탐구합니다.', 'theirFeelings': '상대방이 젊고 호기심 많습니다.', 'pastConnection': '배움과 탐구가 있습니다.', 'currentDynamic': '미숙함이 문제될 수 있습니다.', 'futureOutlook': '호기심을 유지하고 배우세요.' }, 'reversed': { 'myFeelings': '경솔하게 말합니다.', 'theirFeelings': '상대방이 비밀을 퍼뜨립니다.', 'pastConnection': '신뢰 문제가 있습니다.', 'currentDynamic': '경솔한 소통이 문제입니다.', 'futureOutlook': '말하기 전에 생각하세요.' } },
    61: { 'upright': { 'myFeelings': '빠르게 관계를 진전시킵니다.', 'theirFeelings': '상대방이 적극적입니다.', 'pastConnection': '관계가 빠르게 발전합니다.', 'currentDynamic': '성급함이 문제될 수 있습니다.', 'futureOutlook': '열정과 신중함의 균형을 찾으세요.' }, 'reversed': { 'myFeelings': '성급하거나 공격적입니다.', 'theirFeelings': '상대방이 충동적입니다.', 'pastConnection': '관계가 급하게 진행됩니다.', 'currentDynamic': '충동성이 문제입니다.', 'futureOutlook': '속도를 늦추세요.' } },
    62: { 'upright': { 'myFeelings': '명확하게 소통합니다.', 'theirFeelings': '상대방이 직접적이고 정직합니다.', 'pastConnection': '명확한 소통이 있습니다.', 'currentDynamic': '너무 날카로울 수 있습니다.', 'futureOutlook': '진실하되 친절하게 말하세요.' }, 'reversed': { 'myFeelings': '너무 냉정합니다.', 'theirFeelings': '상대방이 차갑습니다.', 'pastConnection': '따뜻함이 부족합니다.', 'currentDynamic': '감정의 부재가 문제입니다.', 'futureOutlook': '지성과 감정의 균형을 찾으세요.' } },
    63: { 'upright': { 'myFeelings': '논리적으로 관계에 접근합니다.', 'theirFeelings': '상대방이 권위적이고 공정합니다.', 'pastConnection': '공정하고 균형 잡힌 관계입니다.', 'currentDynamic': '감정이 무시될 수 있습니다.', 'futureOutlook': '논리와 감정 모두 중요합니다.' }, 'reversed': { 'myFeelings': '권위적이거나 불공정합니다.', 'theirFeelings': '상대방이 조작적이거나 독단적입니다.', 'pastConnection': '권력 불균형이 있습니다.', 'currentDynamic': '권력 남용이 문제입니다.', 'futureOutlook': '공정하고 존중하는 관계를 만드세요.' } },

    // === MINOR ARCANA - PENTACLES (64-77) ===
    64: { 'upright': { 'myFeelings': '관계에서 안정을 추구합니다.', 'theirFeelings': '상대방이 실질적입니다.', 'pastConnection': '안정적인 관계의 시작입니다.', 'currentDynamic': '물질적인 것에 집중할 수 있습니다.', 'futureOutlook': '안정된 기반을 만들면서 감정도 돌보세요.' }, 'reversed': { 'myFeelings': '불안정함을 느낍니다.', 'theirFeelings': '상대방이 재정적으로 불안정합니다.', 'pastConnection': '물질적 어려움이 있습니다.', 'currentDynamic': '불안정이 문제입니다.', 'futureOutlook': '함께 안정을 찾으세요.' } },
    65: { 'upright': { 'myFeelings': '여러 책임 사이에서 균형을 잡습니다.', 'theirFeelings': '상대방도 바쁩니다.', 'pastConnection': '관계와 다른 것들의 균형이 필요합니다.', 'currentDynamic': '균형을 유지하기 어렵습니다.', 'futureOutlook': '관계에도 시간을 투자하세요.' }, 'reversed': { 'myFeelings': '과부하 상태입니다.', 'theirFeelings': '상대방이 당신에게 시간이 없습니다.', 'pastConnection': '관계가 소홀해지고 있습니다.', 'currentDynamic': '시간 관리가 문제입니다.', 'futureOutlook': '우선순위를 정하세요.' } },
    66: { 'upright': { 'myFeelings': '관계를 함께 만들어갑니다.', 'theirFeelings': '상대방과 협력합니다.', 'pastConnection': '함께 성장하는 관계입니다.', 'currentDynamic': '다른 의견이 있을 수 있습니다.', 'futureOutlook': '함께 노력하면 좋은 결과가 옵니다.' }, 'reversed': { 'myFeelings': '협력이 안 됩니다.', 'theirFeelings': '상대방이 비협조적입니다.', 'pastConnection': '팀워크가 부족합니다.', 'currentDynamic': '협력 부족이 문제입니다.', 'futureOutlook': '소통하고 협력하세요.' } },
    67: { 'upright': { 'myFeelings': '관계에서 안정을 지키려 합니다.', 'theirFeelings': '상대방이 보수적입니다.', 'pastConnection': '안정적이지만 경직될 수 있습니다.', 'currentDynamic': '지나친 통제가 문제될 수 있습니다.', 'futureOutlook': '안정은 좋지만 유연성도 필요합니다.' }, 'reversed': { 'myFeelings': '통제력을 잃거나 지나치게 집착합니다.', 'theirFeelings': '상대방이 구두쇠이거나 통제적입니다.', 'pastConnection': '불균형이 있습니다.', 'currentDynamic': '통제 문제가 있습니다.', 'futureOutlook': '균형을 찾으세요.' } },
    68: { 'upright': { 'myFeelings': '관계에서 어려움을 느낍니다.', 'theirFeelings': '상대방도 힘든 시기입니다.', 'pastConnection': '관계가 어렵습니다.', 'currentDynamic': '어려움을 함께 극복하는 것이 도전입니다.', 'futureOutlook': '도움을 구하고 함께 견디세요.' }, 'reversed': { 'myFeelings': '어려움에서 벗어나고 있습니다.', 'theirFeelings': '상대방이 도움이 됩니다.', 'pastConnection': '관계가 회복되고 있습니다.', 'currentDynamic': '완전한 회복이 도전입니다.', 'futureOutlook': '희망을 가지세요.' } },
    69: { 'upright': { 'myFeelings': '관계에서 주고받음이 있습니다.', 'theirFeelings': '상대방이 관대합니다.', 'pastConnection': '균형 잡힌 나눔이 있습니다.', 'currentDynamic': '불균형한 나눔이 문제될 수 있습니다.', 'futureOutlook': '균형 있게 주고받으세요.' }, 'reversed': { 'myFeelings': '불균형하게 주거나 받습니다.', 'theirFeelings': '상대방이 조건부로 줍니다.', 'pastConnection': '나눔에 불균형이 있습니다.', 'currentDynamic': '불공정함이 문제입니다.', 'futureOutlook': '진정한 나눔을 실천하세요.' } },
    70: { 'upright': { 'myFeelings': '관계에 투자하고 기다립니다.', 'theirFeelings': '상대방도 인내하고 있습니다.', 'pastConnection': '관계가 성장하고 있습니다.', 'currentDynamic': '결과를 기다리기 어렵습니다.', 'futureOutlook': '인내하세요. 곧 결과가 나타납니다.' }, 'reversed': { 'myFeelings': '노력에 비해 결과가 없습니다.', 'theirFeelings': '상대방이 노력하지 않습니다.', 'pastConnection': '관계가 정체되어 있습니다.', 'currentDynamic': '좌절감이 문제입니다.', 'futureOutlook': '방향을 재검토하세요.' } },
    71: { 'upright': { 'myFeelings': '관계를 위해 노력합니다.', 'theirFeelings': '상대방도 열심히 합니다.', 'pastConnection': '관계가 성실하게 발전합니다.', 'currentDynamic': '일에만 집중할 수 있습니다.', 'futureOutlook': '노력은 보상받습니다.' }, 'reversed': { 'myFeelings': '관계에 노력을 기울이지 않습니다.', 'theirFeelings': '상대방이 게으릅니다.', 'pastConnection': '노력이 부족합니다.', 'currentDynamic': '동기 부족이 문제입니다.', 'futureOutlook': '관계에 투자하세요.' } },
    72: { 'upright': { 'myFeelings': '관계에서 자립적입니다.', 'theirFeelings': '상대방이 독립적입니다.', 'pastConnection': '건강한 독립이 있는 관계입니다.', 'currentDynamic': '너무 독립적이면 단절될 수 있습니다.', 'futureOutlook': '독립과 친밀함의 균형을 찾으세요.' }, 'reversed': { 'myFeelings': '과도하게 독립적이거나 외롭습니다.', 'theirFeelings': '상대방이 너무 자기중심적입니다.', 'pastConnection': '연결이 부족합니다.', 'currentDynamic': '고립이 문제입니다.', 'futureOutlook': '연결을 유지하세요.' } },
    73: { 'upright': { 'myFeelings': '장기적인 관계를 원합니다.', 'theirFeelings': '상대방과 가정을 생각합니다.', 'pastConnection': '영속적인 관계입니다.', 'currentDynamic': '가족 문제가 있을 수 있습니다.', 'futureOutlook': '함께 유산을 만들어가세요.' }, 'reversed': { 'myFeelings': '가족 문제가 있습니다.', 'theirFeelings': '상대방 가족과 갈등이 있습니다.', 'pastConnection': '가족 관련 문제가 있습니다.', 'currentDynamic': '가족 갈등이 문제입니다.', 'futureOutlook': '가족 문제를 해결하세요.' } },
    74: { 'upright': { 'myFeelings': '관계에 진지하게 접근합니다.', 'theirFeelings': '상대방이 성실합니다.', 'pastConnection': '안정적인 시작입니다.', 'currentDynamic': '너무 느릴 수 있습니다.', 'futureOutlook': '천천히 확실하게 가세요.' }, 'reversed': { 'myFeelings': '관계를 미루고 있습니다.', 'theirFeelings': '상대방이 비현실적입니다.', 'pastConnection': '진전이 없습니다.', 'currentDynamic': '행동 부족이 문제입니다.', 'futureOutlook': '시작하세요.' } },
    75: { 'upright': { 'myFeelings': '꾸준히 관계를 발전시킵니다.', 'theirFeelings': '상대방이 신뢰할 수 있습니다.', 'pastConnection': '느리지만 확실합니다.', 'currentDynamic': '지루할 수 있습니다.', 'futureOutlook': '꾸준함이 관계의 기반입니다.' }, 'reversed': { 'myFeelings': '정체되거나 고집이 셉니다.', 'theirFeelings': '상대방이 변화하지 않습니다.', 'pastConnection': '진전이 없습니다.', 'currentDynamic': '정체가 문제입니다.', 'futureOutlook': '유연해지세요.' } },
    76: { 'upright': { 'myFeelings': '따뜻하게 돌봅니다.', 'theirFeelings': '상대방이 돌봄을 잘 합니다.', 'pastConnection': '따뜻하고 안정적입니다.', 'currentDynamic': '과잉 보호가 문제될 수 있습니다.', 'futureOutlook': '균형 있게 돌보세요.' }, 'reversed': { 'myFeelings': '자신을 돌보지 않습니다.', 'theirFeelings': '상대방이 돌봄을 받지만 주지 않습니다.', 'pastConnection': '돌봄의 불균형이 있습니다.', 'currentDynamic': '불균형이 문제입니다.', 'futureOutlook': '자신도 돌보세요.' } },
    77: { 'upright': { 'myFeelings': '안정을 제공합니다.', 'theirFeelings': '상대방이 믿음직합니다.', 'pastConnection': '안정적이고 풍요롭습니다.', 'currentDynamic': '물질에 집중할 수 있습니다.', 'futureOutlook': '안정과 감정 모두 중요합니다.' }, 'reversed': { 'myFeelings': '물질에 집착합니다.', 'theirFeelings': '상대방이 물질적입니다.', 'pastConnection': '물질이 문제가 됩니다.', 'currentDynamic': '물질 중심이 문제입니다.', 'futureOutlook': '진정한 가치를 찾으세요.' } },
  };

  /// Get interpretation for a specific card, orientation, and position
  static String? getInterpretation(int cardIndex, String orientation, String position) {
    return meanings[cardIndex]?[orientation]?[position];
  }
}
