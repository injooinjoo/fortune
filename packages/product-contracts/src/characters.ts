import type { FortuneTypeId } from './fortunes';

export interface FortuneCharacterSpec {
  id: string;
  name: string;
  category: string;
  shortDescription: string;
  specialties: FortuneTypeId[];
}

export const fortuneCharacters = [
  {
    id: 'fortune_haneul',
    name: '하늘',
    category: 'lifestyle',
    shortDescription: '오늘 하루, 내일의 에너지를 미리 알려드릴게요!',
    specialties: ['daily', 'new-year', 'fortune-cookie'],
  },
  {
    id: 'fortune_muhyeon',
    name: '현우',
    category: 'traditional',
    shortDescription: '사주와 전통 명리학으로 당신의 근본을 봅니다',
    specialties: ['traditional-saju', 'face-reading', 'blood-type', 'naming'],
  },
  {
    id: 'fortune_stella',
    name: '스텔라',
    category: 'zodiac',
    shortDescription: '별들이 속삭이는 당신의 이야기를 전해드려요',
    specialties: ['zodiac', 'zodiac-animal', 'birthstone'],
  },
  {
    id: 'fortune_dr_mind',
    name: 'Dr. 마인드',
    category: 'personality',
    shortDescription: '성격과 재능을 분석해 당신의 강점을 찾아드려요',
    specialties: [
      'mbti',
      'personality-dna',
      'talent',
      'coaching',
      'chat-insight',
      'past-life',
    ],
  },
  {
    id: 'fortune_rose',
    name: '로제',
    category: 'love',
    shortDescription: '연애와 관계의 흐름을 섬세하게 읽어드려요',
    specialties: [
      'love',
      'compatibility',
      'blind-date',
      'ex-lover',
      'avoid-people',
      'celebrity',
      'yearly-encounter',
    ],
  },
  {
    id: 'fortune_james_kim',
    name: '제임스 김',
    category: 'career',
    shortDescription: '직업과 재물 흐름을 전략적으로 짚어드립니다',
    specialties: ['career', 'wealth', 'exam'],
  },
  {
    id: 'fortune_lucky',
    name: '럭키',
    category: 'lucky',
    shortDescription: '행운 아이템과 기분 좋은 우연을 모아드려요',
    specialties: ['lucky-items', 'lotto', 'ootd-evaluation'],
  },
  {
    id: 'fortune_marco',
    name: '마르코',
    category: 'sports',
    shortDescription: '스포츠와 활동 컨디션을 읽는 역동적인 가이드입니다',
    specialties: ['health', 'match-insight', 'game-enhance', 'exercise', 'breathing'],
  },
  {
    id: 'fortune_lina',
    name: '리나',
    category: 'fengshui',
    shortDescription: '이사와 공간의 흐름을 가볍고 정확하게 읽어드려요',
    specialties: ['moving'],
  },
  {
    id: 'fortune_luna',
    name: '루나',
    category: 'special',
    shortDescription: '특별한 순간과 감정 흐름을 신비롭게 풀어드려요',
    specialties: [
      'tarot',
      'dream',
      'biorhythm',
      'family',
      'pet-compatibility',
      'talisman',
      'wish',
    ],
  },
] as const satisfies readonly FortuneCharacterSpec[];

export function findFortuneExpert(typeId: FortuneTypeId): FortuneCharacterSpec | undefined {
  return fortuneCharacters.find((character) =>
    (character.specialties as readonly FortuneTypeId[]).includes(typeId),
  );
}
