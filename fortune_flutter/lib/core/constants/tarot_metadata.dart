import 'package:flutter/material.dart';

class TarotMetadata {
  // Major Arcana (메이저 아르카나) - 22장
  static const Map<int, TarotCardInfo> majorArcana = {
    0: TarotCardInfo(
      id: 0,
      name: '바보 (The Fool)',
      keywords: ['새로운 시작', '순수함', '자유', '모험'],
      uprightMeaning: '새로운 여정의 시작, 무한한 가능성, 순수한 마음',
      reversedMeaning: '무모함, 위험한 선택, 준비 부족',
      element: '공기',
      astrology: '천왕성',
      numerology: 0,
      imagery: '절벽 끝에 서 있는 젊은이, 하얀 개, 태양',
      advice: '두려움 없이 새로운 도전을 받아들이세요',
      questions: [
        '어떤 새로운 시작이 당신을 기다리고 있나요?',
        '무엇이 당신을 주저하게 만들고 있나요?',
      ],
    ),
    1: TarotCardInfo(
      id: 1,
      name: '마법사 (The Magician)',
      keywords: ['의지력', '창조', '기술', '자신감'],
      uprightMeaning: '목표 실현의 능력, 모든 도구를 갖춤, 집중력',
      reversedMeaning: '재능 낭비, 속임수, 자신감 부족',
      element: '모든 원소',
      astrology: '수성',
      numerology: 1,
      imagery: '테이블 위의 4원소, 무한대 기호, 지팡이',
      advice: '당신의 모든 능력을 활용하여 목표를 달성하세요',
      questions: [
        '어떤 재능을 더 개발해야 하나요?',
        '목표 달성을 위해 무엇이 필요한가요?',
      ],
    ),
    2: TarotCardInfo(
      id: 2,
      name: '여사제 (The High Priestess)',
      keywords: ['직관', '신비', '잠재의식', '지혜'],
      uprightMeaning: '내면의 목소리, 숨겨진 지식, 인내',
      reversedMeaning: '비밀 공개, 직관 무시, 표면적 판단',
      element: '물',
      astrology: '달',
      numerology: 2,
      imagery: '두 기둥 사이의 여사제, 초승달, 석류',
      advice: '직관을 믿고 내면의 지혜에 귀 기울이세요',
      questions: [
        '무엇이 아직 드러나지 않았나요?',
        '내면의 목소리가 무엇을 말하고 있나요?',
      ],
    ),
    3: TarotCardInfo(
      id: 3,
      name: '여황제 (The Empress)',
      keywords: ['풍요', '모성', '창조', '자연'],
      uprightMeaning: '창조성과 풍요, 양육과 성장, 감각적 즐거움',
      reversedMeaning: '창조적 막힘, 과잉 보호, 의존성',
      element: '땅',
      astrology: '금성',
      numerology: 3,
      imagery: '왕좌의 여황제, 밀밭, 금성 기호',
      advice: '자연과 조화를 이루며 창조적 에너지를 발산하세요',
      questions: [
        '무엇을 창조하고 키워나가고 있나요?',
        '어떻게 자신을 더 사랑할 수 있나요?',
      ],
    ),
    4: TarotCardInfo(
      id: 4,
      name: '황제 (The Emperor)',
      keywords: ['권위', '구조', '아버지', '안정'],
      uprightMeaning: '리더십, 권위, 안정적인 기반, 보호',
      reversedMeaning: '독재, 경직성, 권력 남용',
      element: '불',
      astrology: '양자리',
      numerology: 4,
      imagery: '왕좌의 황제, 양의 머리, 붉은 옷',
      advice: '책임감을 갖고 안정적인 구조를 만들어가세요',
      questions: [
        '어디서 더 많은 구조가 필요한가요?',
        '당신의 권위를 어떻게 사용하고 있나요?',
      ],
    ),
    5: TarotCardInfo(
      id: 5,
      name: '교황 (The Hierophant)',
      keywords: ['전통', '가르침', '신념', '사회적 규범'],
      uprightMeaning: '전통적 가치, 영적 지도, 교육과 학습',
      reversedMeaning: '독단적 사고, 전통에 대한 의문, 비순응',
      element: '땅',
      astrology: '황소자리',
      numerology: 5,
      imagery: '종교적 인물, 두 기둥, 두 제자',
      advice: '지혜로운 조언을 구하고 전통에서 배우세요',
      questions: [
        '어떤 믿음이 당신을 인도하고 있나요?',
        '누구에게서 배울 수 있나요?',
      ],
    ),
    6: TarotCardInfo(
      id: 6,
      name: '연인들 (The Lovers)',
      keywords: ['사랑', '선택', '조화', '관계'],
      uprightMeaning: '사랑과 조화, 중요한 선택, 가치관의 일치',
      reversedMeaning: '불화, 나쁜 선택, 가치관 충돌',
      element: '공기',
      astrology: '쌍둥이자리',
      numerology: 6,
      imagery: '두 연인, 천사, 에덴동산',
      advice: '마음의 소리를 듣고 진정한 선택을 하세요',
      questions: [
        '어떤 선택이 당신 앞에 놓여 있나요?',
        '무엇이 진정한 조화를 만드나요?',
      ],
    ),
    7: TarotCardInfo(
      id: 7,
      name: '전차 (The Chariot)',
      keywords: ['의지', '결단', '승리', '통제'],
      uprightMeaning: '의지력으로 얻는 승리, 자기 통제, 결단력',
      reversedMeaning: '통제력 상실, 공격성, 방향성 부족',
      element: '물',
      astrology: '게자리',
      numerology: 7,
      imagery: '전차를 모는 전사, 스핑크스, 별이 빛나는 천장',
      advice: '목표를 향해 결단력 있게 전진하세요',
      questions: [
        '어떤 도전을 극복해야 하나요?',
        '어떻게 균형을 유지할 수 있나요?',
      ],
    ),
    8: TarotCardInfo(
      id: 8,
      name: '힘 (Strength)',
      keywords: ['내적 힘', '용기', '인내', '자비'],
      uprightMeaning: '내면의 힘, 부드러운 통제, 용기와 인내',
      reversedMeaning: '자기 의심, 약함, 인내력 부족',
      element: '불',
      astrology: '사자자리',
      numerology: 8,
      imagery: '사자를 다루는 여인, 무한대 기호',
      advice: '부드러운 힘으로 어려움을 극복하세요',
      questions: [
        '어떤 내적 힘을 발견했나요?',
        '어디서 더 많은 인내가 필요한가요?',
      ],
    ),
    9: TarotCardInfo(
      id: 9,
      name: '은둔자 (The Hermit)',
      keywords: ['내면 탐구', '지혜', '고독', '안내'],
      uprightMeaning: '내면의 탐구, 영적 깨달음, 혼자만의 시간',
      reversedMeaning: '고립, 외로움, 내면 회피',
      element: '땅',
      astrology: '처녀자리',
      numerology: 9,
      imagery: '등불을 든 노인, 산꼭대기, 지팡이',
      advice: '내면의 빛을 따라 진실을 찾으세요',
      questions: [
        '무엇을 찾고 있나요?',
        '혼자만의 시간이 왜 필요한가요?',
      ],
    ),
    10: TarotCardInfo(
      id: 10,
      name: '운명의 수레바퀴 (Wheel of Fortune)',
      keywords: ['변화', '순환', '운명', '기회'],
      uprightMeaning: '행운의 전환점, 새로운 기회, 운명의 순환',
      reversedMeaning: '불운, 통제력 상실, 저항',
      element: '불',
      astrology: '목성',
      numerology: 10,
      imagery: '회전하는 바퀴, 스핑크스, 동물 상징',
      advice: '변화의 흐름을 받아들이고 기회를 포착하세요',
      questions: [
        '어떤 변화가 다가오고 있나요?',
        '운명의 흐름을 어떻게 활용할 수 있나요?',
      ],
    ),
    11: TarotCardInfo(
      id: 11,
      name: '정의 (Justice)',
      keywords: ['공정', '균형', '진실', '책임'],
      uprightMeaning: '공정한 판단, 균형과 조화, 인과응보',
      reversedMeaning: '불공정, 편견, 책임 회피',
      element: '공기',
      astrology: '천칭자리',
      numerology: 11,
      imagery: '저울과 검을 든 인물, 두 기둥',
      advice: '진실과 공정함을 추구하세요',
      questions: [
        '어떤 결정이 필요한가요?',
        '무엇이 진정한 균형인가요?',
      ],
    ),
    12: TarotCardInfo(
      id: 12,
      name: '매달린 사람 (The Hanged Man)',
      keywords: ['희생', '관점 전환', '인내', '깨달음'],
      uprightMeaning: '자발적 희생, 새로운 관점, 영적 깨달음',
      reversedMeaning: '무의미한 희생, 정체, 지연',
      element: '물',
      astrology: '해왕성',
      numerology: 12,
      imagery: '거꾸로 매달린 사람, 후광, 나무',
      advice: '다른 관점에서 상황을 바라보세요',
      questions: [
        '무엇을 놓아주어야 하나요?',
        '어떤 새로운 관점이 필요한가요?',
      ],
    ),
    13: TarotCardInfo(
      id: 13,
      name: '죽음 (Death)',
      keywords: ['변화', '종료', '변혁', '재생'],
      uprightMeaning: '큰 변화, 한 주기의 끝, 변혁과 재생',
      reversedMeaning: '변화 거부, 정체, 두려움',
      element: '물',
      astrology: '전갈자리',
      numerology: 13,
      imagery: '해골 기사, 검은 말, 떠오르는 태양',
      advice: '끝은 새로운 시작을 위한 준비입니다',
      questions: [
        '무엇을 끝내야 하나요?',
        '어떤 변화가 필요한가요?',
      ],
    ),
    14: TarotCardInfo(
      id: 14,
      name: '절제 (Temperance)',
      keywords: ['균형', '조화', '인내', '통합'],
      uprightMeaning: '균형과 조화, 인내심, 중용의 미덕',
      reversedMeaning: '불균형, 과잉, 조급함',
      element: '불',
      astrology: '사수자리',
      numerology: 14,
      imagery: '천사, 두 잔의 물, 붓꽃',
      advice: '인내심을 갖고 균형을 찾으세요',
      questions: [
        '어디서 더 많은 균형이 필요한가요?',
        '무엇을 통합해야 하나요?',
      ],
    ),
    15: TarotCardInfo(
      id: 15,
      name: '악마 (The Devil)',
      keywords: ['속박', '유혹', '물질주의', '그림자'],
      uprightMeaning: '속박과 중독, 물질적 집착, 억압된 욕망',
      reversedMeaning: '해방, 속박에서 벗어남, 각성',
      element: '땅',
      astrology: '염소자리',
      numerology: 15,
      imagery: '악마, 쇠사슬에 묶인 남녀, 거꾸로 된 오각별',
      advice: '자신을 속박하는 것에서 벗어나세요',
      questions: [
        '무엇이 당신을 속박하고 있나요?',
        '어떤 두려움과 마주해야 하나요?',
      ],
    ),
    16: TarotCardInfo(
      id: 16,
      name: '탑 (The Tower)',
      keywords: ['파괴', '각성', '충격', '해방'],
      uprightMeaning: '갑작스런 변화, 기존 구조의 붕괴, 각성',
      reversedMeaning: '변화 회피, 재난 예방, 내적 변화',
      element: '불',
      astrology: '화성',
      numerology: 16,
      imagery: '번개 맞은 탑, 떨어지는 사람들, 왕관',
      advice: '파괴는 때로 필요한 정화 과정입니다',
      questions: [
        '어떤 구조가 무너져야 하나요?',
        '진실은 무엇인가요?',
      ],
    ),
    17: TarotCardInfo(
      id: 17,
      name: '별 (The Star)',
      keywords: ['희망', '영감', '치유', '갱신'],
      uprightMeaning: '희망과 영감, 영적 인도, 치유와 갱신',
      reversedMeaning: '절망, 신념 상실, 단절감',
      element: '공기',
      astrology: '물병자리',
      numerology: 17,
      imagery: '물을 붓는 여인, 일곱 개의 작은 별, 하나의 큰 별',
      advice: '희망을 품고 미래를 믿으세요',
      questions: [
        '무엇이 당신에게 희망을 주나요?',
        '어떤 꿈을 향해 나아가고 있나요?',
      ],
    ),
    18: TarotCardInfo(
      id: 18,
      name: '달 (The Moon)',
      keywords: ['환상', '두려움', '잠재의식', '직관'],
      uprightMeaning: '환상과 불안, 숨겨진 진실, 직관의 메시지',
      reversedMeaning: '환상에서 깨어남, 명확성, 두려움 극복',
      element: '물',
      astrology: '물고기자리',
      numerology: 18,
      imagery: '달, 개와 늑대, 가재, 두 탑',
      advice: '직관을 신뢰하되 환상에 주의하세요',
      questions: [
        '무엇이 숨겨져 있나요?',
        '어떤 두려움이 당신을 지배하나요?',
      ],
    ),
    19: TarotCardInfo(
      id: 19,
      name: '태양 (The Sun)',
      keywords: ['성공', '활력', '기쁨', '성취'],
      uprightMeaning: '성공과 성취, 활력과 기쁨, 긍정적 에너지',
      reversedMeaning: '일시적 좌절, 과도한 낙관, 자만',
      element: '불',
      astrology: '태양',
      numerology: 19,
      imagery: '빛나는 태양, 아이와 말, 해바라기',
      advice: '당신의 빛을 세상과 나누세요',
      questions: [
        '무엇이 당신을 행복하게 하나요?',
        '어떤 성공을 축하해야 하나요?',
      ],
    ),
    20: TarotCardInfo(
      id: 20,
      name: '심판 (Judgement)',
      keywords: ['부활', '각성', '용서', '재평가'],
      uprightMeaning: '영적 각성, 과거의 정리, 새로운 시작',
      reversedMeaning: '자기 비판, 용서 부족, 과거에 매임',
      element: '불',
      astrology: '명왕성',
      numerology: 20,
      imagery: '천사의 나팔, 부활하는 사람들, 깃발',
      advice: '과거를 용서하고 새롭게 태어나세요',
      questions: [
        '무엇을 용서해야 하나요?',
        '어떤 부름을 받고 있나요?',
      ],
    ),
    21: TarotCardInfo(
      id: 21,
      name: '세계 (The World)',
      keywords: ['완성', '성취', '통합', '전체성'],
      uprightMeaning: '완성과 성취, 한 주기의 완료, 조화와 통합',
      reversedMeaning: '미완성, 지연, 외적 성공 내적 공허',
      element: '땅',
      astrology: '토성',
      numerology: 21,
      imagery: '월계관 속의 춤추는 인물, 네 생명체',
      advice: '성취를 축하하고 새로운 여정을 준비하세요',
      questions: [
        '무엇을 완성했나요?',
        '다음 여정은 무엇인가요?',
      ],
    ),
  };

  // 모든 타로 카드를 하나의 맵으로 통합 (78장)
  static Map<int, TarotCardInfo> get allCards {
    final Map<int, TarotCardInfo> cards = {};
    
    // Major Arcana 추가
    cards.addAll(majorArcana);
    
    // Minor Arcana 추가 - 임시로 참조하기 위해 동적 import
    // 실제 구현시 TarotMinorArcana 클래스의 카드들을 여기에 직접 추가
    
    return cards;
  }

  // 카드 정보 가져오기
  static TarotCardInfo? getCard(int cardIndex) {
    if (cardIndex < 0 || cardIndex >= 78) return null;
    
    // Major Arcana (0-21)
    if (cardIndex < 22) {
      return majorArcana[cardIndex];
    }
    
    // Minor Arcana는 별도 파일에서 관리하므로 null 반환
    // 실제 사용시 TarotMinorArcana 클래스와 통합 필요
    return null;
  }

  // 슈트별 카드 가져오기
  static List<TarotCardInfo> getCardsBySuit(String suit) {
    final List<TarotCardInfo> cards = [];
    
    // Major Arcana에서 원소별로 필터링
    if (suit == 'major') {
      cards.addAll(majorArcana.values);
    }
    
    return cards;
  }

  // 타로 스프레드 종류
  static const Map<String, TarotSpread> spreads = {
    'single': TarotSpread(
      name: '원 카드 리딩',
      description: '오늘의 메시지나 즉각적인 통찰',
      cardCount: 1,
      positions: ['현재 상황/오늘의 메시지'],
      layout: SpreadLayout.single,
      soulCost: 1,
    ),
    'three': TarotSpread(
      name: '쓰리 카드 스프레드',
      description: '과거-현재-미래 또는 상황-행동-결과',
      cardCount: 3,
      positions: ['과거/상황', '현재/행동', '미래/결과'],
      layout: SpreadLayout.horizontal,
      soulCost: 3,
    ),
    'celtic': TarotSpread(
      name: '켈틱 크로스',
      description: '가장 상세한 10장 스프레드',
      cardCount: 10,
      positions: [
        '현재 상황',
        '도전/십자가',
        '먼 과거/기초',
        '최근 과거',
        '가능한 미래',
        '가까운 미래',
        '당신의 접근',
        '외부 영향',
        '희망과 두려움',
        '최종 결과',
      ],
      layout: SpreadLayout.celticCross,
      soulCost: 5,
    ),
    'relationship': TarotSpread(
      name: '관계 스프레드',
      description: '두 사람 사이의 관계 분석',
      cardCount: 7,
      positions: [
        '나의 감정',
        '상대의 감정',
        '관계의 기초',
        '나의 도전',
        '상대의 도전',
        '관계의 잠재력',
        '조언',
      ],
      layout: SpreadLayout.relationship,
      soulCost: 4,
    ),
    'career': TarotSpread(
      name: '경력 스프레드',
      description: '직업과 경력에 대한 통찰',
      cardCount: 5,
      positions: [
        '현재 직업 상황',
        '숨겨진 영향',
        '조언',
        '예상되는 도전',
        '잠재적 결과',
      ],
      layout: SpreadLayout.pyramid,
      soulCost: 3,
    ),
    'decision': TarotSpread(
      name: '결정 스프레드',
      description: '중요한 선택을 위한 가이드',
      cardCount: 7,
      positions: [
        '현재 상황',
        '선택지 1',
        '선택지 1의 결과',
        '선택지 2',
        '선택지 2의 결과',
        '중요한 요소',
        '최종 조언',
      ],
      layout: SpreadLayout.decision,
      soulCost: 4,
    ),
    'year': TarotSpread(
      name: '연간 스프레드',
      description: '12개월 전망',
      cardCount: 12,
      positions: [
        '1월', '2월', '3월', '4월', '5월', '6월',
        '7월', '8월', '9월', '10월', '11월', '12월',
      ],
      layout: SpreadLayout.circle,
      soulCost: 5,
    ),
    'chakra': TarotSpread(
      name: '차크라 스프레드',
      description: '7개 차크라 에너지 상태',
      cardCount: 7,
      positions: [
        '루트 차크라 (생존)',
        '천골 차크라 (감정)',
        '태양신경총 차크라 (의지)',
        '하트 차크라 (사랑)',
        '목 차크라 (소통)',
        '제3의 눈 차크라 (직관)',
        '크라운 차크라 (영성)',
      ],
      layout: SpreadLayout.vertical,
      soulCost: 4,
    ),
  };

  // 카드 해석 깊이 레벨
  static const Map<String, InterpretationDepth> interpretationLevels = {
    'basic': InterpretationDepth(
      name: '기본 해석',
      includeReversed: false,
      includeElemental: false,
      includeNumerology: false,
      includeAstrology: false,
      detailLevel: 1,
    ),
    'standard': InterpretationDepth(
      name: '표준 해석',
      includeReversed: true,
      includeElemental: true,
      includeNumerology: false,
      includeAstrology: false,
      detailLevel: 2,
    ),
    'advanced': InterpretationDepth(
      name: '심화 해석',
      includeReversed: true,
      includeElemental: true,
      includeNumerology: true,
      includeAstrology: true,
      detailLevel: 3,
    ),
  };

  // 카드 조합 의미
  static const Map<String, CardCombination> significantCombinations = {
    'tower_death': CardCombination(
      cards: ['The Tower', 'Death'],
      meaning: '급격한 변화와 변혁의 시기, 과거와의 완전한 단절',
      advice: '변화를 받아들이고 새로운 시작을 준비하세요',
    ),
    'lovers_twocups': CardCombination(
      cards: ['The Lovers', 'Two of Cups'],
      meaning: '깊은 사랑과 조화로운 관계의 시작',
      advice: '마음을 열고 진정한 연결을 만들어가세요',
    ),
    // ... 더 많은 조합들
  };
}

class TarotCardInfo {
  final int id;
  final String name;
  final List<String> keywords;
  final String uprightMeaning;
  final String reversedMeaning;
  final String element;
  final String astrology;
  final int numerology;
  final String imagery;
  final String advice;
  final List<String> questions;

  const TarotCardInfo({
    required this.id,
    required this.name,
    required this.keywords,
    required this.uprightMeaning,
    required this.reversedMeaning,
    required this.element,
    required this.astrology,
    required this.numerology,
    required this.imagery,
    required this.advice,
    required this.questions,
  });
}

class TarotSpread {
  final String name;
  final String description;
  final int cardCount;
  final List<String> positions;
  final SpreadLayout layout;
  final int soulCost;

  const TarotSpread({
    required this.name,
    required this.description,
    required this.cardCount,
    required this.positions,
    required this.layout,
    required this.soulCost,
  });
}

enum SpreadLayout {
  single,
  horizontal,
  vertical,
  celticCross,
  pyramid,
  circle,
  relationship,
  decision,
}

class InterpretationDepth {
  final String name;
  final bool includeReversed;
  final bool includeElemental;
  final bool includeNumerology;
  final bool includeAstrology;
  final int detailLevel;

  const InterpretationDepth({
    required this.name,
    required this.includeReversed,
    required this.includeElemental,
    required this.includeNumerology,
    required this.includeAstrology,
    required this.detailLevel,
  });
}

class CardCombination {
  final List<String> cards;
  final String meaning;
  final String advice;

  const CardCombination({
    required this.cards,
    required this.meaning,
    required this.advice,
  });
}

// 카드별 상세 정보 제공 메서드
class TarotHelper {
  static String getCardImagePath(int cardId) {
    return 'assets/images/tarot/card_$cardId.png';
  }

  static Color getElementColor(String element) {
    switch (element.toLowerCase()) {
      case '불':
      case 'fire':
      case 'wands':
        return Colors.red;
      case '물':
      case 'water':
      case 'cups':
        return Colors.blue;
      case '공기':
      case 'air':
      case 'swords':
        return Colors.yellow;
      case '땅':
      case 'earth':
      case 'pentacles':
        return Colors.green;
      default:
        return Colors.purple;
    }
  }

  static IconData getElementIcon(String element) {
    switch (element.toLowerCase()) {
      case '불':
      case 'fire':
      case 'wands':
        return Icons.local_fire_department;
      case '물':
      case 'water':
      case 'cups':
        return Icons.water_drop;
      case '공기':
      case 'air':
      case 'swords':
        return Icons.air;
      case '땅':
      case 'earth':
      case 'pentacles':
        return Icons.terrain;
      default:
        return Icons.auto_awesome;
    }
  }

  static String getPositionDescription(String spreadType, int position) {
    final spread = TarotMetadata.spreads[spreadType];
    if (spread != null && position < spread.positions.length) {
      return spread.positions[position];
    }
    return '위치 ${position + 1}';
  }

  static List<String> getRelatedCards(int cardId) {
    // 수비학적 관련 카드 찾기
    final numerology = TarotMetadata.majorArcana[cardId]?.numerology ?? 0;
    final related = <String>[];
    
    // 같은 숫자의 마이너 아르카나 카드들
    if (numerology > 0 && numerology <= 10) {
      related.add('$numerology of Wands');
      related.add('$numerology of Cups');
      related.add('$numerology of Swords');
      related.add('$numerology of Pentacles');
    }
    
    // 수비학적 환원 (예: 13 Death -> 4 Emperor)
    if (numerology > 9) {
      final reduced = numerology.toString().split('').map(int.parse).reduce((a, b) => a + b);
      final reducedCard = TarotMetadata.majorArcana.values.firstWhere(
        (card) => card.numerology == reduced,
        orElse: () => TarotMetadata.majorArcana[0]!,
      );
      related.add(reducedCard.name);
    }
    
    return related;
  }
}