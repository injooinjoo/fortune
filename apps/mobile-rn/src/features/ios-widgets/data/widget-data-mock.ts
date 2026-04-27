/**
 * widget-data-mock — 벤치마크 widget-data.jsx를 TS로 포팅한 목업 상수.
 *
 * Sprint X1에서는 tarot/constellation/lucky/unread/recommendation/tarot-draw 등
 * 사용자 사주와 무관한 데이터를 여기서 제공. 연동이 필요한 daily/lucky/
 * constellation 등은 widget-data-live.ts의 useWidgetData()가 덮어씀.
 */

export interface CharacterMock {
  id: string;
  ko: string;
  role: string;
  tint: string;
  avatar: string;
}

export const CHARACTERS: Readonly<Record<string, CharacterMock>> = {
  haneul:  { id: 'haneul',  ko: '하늘',     role: '사주 전문가',    tint: '#8B7BE8', avatar: 'H' },
  stella:  { id: 'stella',  ko: '스텔라',   role: '별자리 해석가',  tint: '#8FB8FF', avatar: 'S' },
  drmind:  { id: 'drmind',  ko: 'Dr. Mind', role: '심리 상담가',    tint: '#C9FFDC', avatar: 'M' },
  muhyeon: { id: 'muhyeon', ko: '무현',     role: '타로 마스터',    tint: '#E0A76B', avatar: '무' },
  rose:    { id: 'rose',    ko: '로즈',     role: '연애 카운슬러',  tint: '#FFB8C8', avatar: 'R' },
  lucky:   { id: 'lucky',   ko: '럭키',     role: '데일리 가이드',  tint: '#FFE8D6', avatar: 'L' },
  luna:    { id: 'luna',    ko: '루나',     role: '꿈 해몽가',      tint: '#B8B0FF', avatar: '🌙' },
  marco:   { id: 'marco',   ko: '마르코',   role: '여행 운세',      tint: '#A8E5FF', avatar: 'M' },
};

export interface StoryMock {
  id: string;
  ko: string;
  sub: string;
  tint: string;
  avatar: string;
  lastMsg: string;
  unread: number;
  ts: string;
}

export const STORIES: readonly StoryMock[] = [
  { id: 'haerin', ko: '해린', sub: '출판사 편집자', tint: '#E0A76B', avatar: '해', lastMsg: '오늘 원고 넘긴 건 어땠어요?', unread: 2, ts: '오후 7:42' },
  { id: 'seojun', ko: '서준', sub: '바리스타',       tint: '#C9FFDC', avatar: '서', lastMsg: '비 오는 날엔 드립이 제일이야',    unread: 0, ts: '오후 3:18' },
  { id: 'minji',  ko: '민지', sub: '야경 사진가',   tint: '#8FB8FF', avatar: '민', lastMsg: '한강 다리 아래, 지금 나와있어',  unread: 1, ts: '오후 10:04' },
  { id: 'jihoon', ko: '지훈', sub: '대학원생',       tint: '#B8B0FF', avatar: '지', lastMsg: '논문 마감 세 시간 전이에요…',     unread: 4, ts: '오전 2:11' },
];

export interface DailyFortuneMock {
  score: number;
  level: string;
  summary: string;
  body: string;
  lucky: { color: string; number: number; direction: string; item: string };
  by: string;
  fortune: { career: number; love: number; wealth: number; health: number };
}

export const DAILY_FORTUNE_MOCK: DailyFortuneMock = {
  score: 87,
  level: '길(吉)',
  summary: '조용한 행운이 흐르는 하루',
  body: '오늘은 한 발 늦추는 것이 유리합니다. 기다리는 자리에 기회가 옵니다.',
  lucky: { color: '짙은 와인', number: 7, direction: '남동', item: '금속 펜' },
  by: 'haneul',
  fortune: { career: 78, love: 91, wealth: 64, health: 85 },
};

export interface TarotCardMock {
  name: string;
  ko: string;
  arcana: string;
  position: string;
  keyword: string;
  reading: string;
  by: string;
}

export const TAROT_CARD: TarotCardMock = {
  name: 'The Star',
  ko: '별',
  arcana: 'Major Arcana · XVII',
  position: '정방향',
  keyword: '희망 · 평온 · 회복',
  reading: '잔잔한 물가에서, 당신은 지쳐있던 손을 씻습니다.',
  by: 'muhyeon',
};

export interface ConstellationMock {
  sign: string;
  symbol: string;
  ko: string;
  date: string;
  message: string;
  rank: number;
  by: string;
}

export const CONSTELLATION_MOCK: ConstellationMock = {
  sign: '쌍둥이자리',
  symbol: '♊',
  ko: 'Gemini',
  date: '5.21 — 6.21',
  message: '수성이 당신의 언어를 빌립니다. 꺼냈던 말을 다시 꺼내세요.',
  rank: 2,
  by: 'stella',
};

export interface LuckyItemMock {
  color: { name: string; hex: string };
  number: number;
  direction: string;
  item: string;
  time: string;
}

export const LUCKY_ITEM_MOCK: LuckyItemMock = {
  color: { name: '짙은 와인', hex: '#5C1F2B' },
  number: 7,
  direction: '남동',
  item: '금속 펜',
  time: '오후 3시',
};

export interface WeeklyDay {
  d: string;
  score: number;
  hi: boolean;
}

export const WEEKLY_MOCK: readonly WeeklyDay[] = [
  { d: '월', score: 72, hi: false },
  { d: '화', score: 85, hi: false },
  { d: '수', score: 68, hi: false },
  { d: '목', score: 91, hi: true  },
  { d: '금', score: 77, hi: false },
  { d: '토', score: 82, hi: false },
  { d: '일', score: 64, hi: false },
];

export interface UnreadItem {
  char: string;
  preview: string;
}

export interface UnreadMock {
  total: number;
  items: readonly UnreadItem[];
}

export const UNREAD: UnreadMock = {
  total: 7,
  items: [
    { char: '해린', preview: '오늘 원고 넘긴 건 어땠어요?' },
    { char: '지훈', preview: '논문 마감 세 시간 전…' },
    { char: '민지', preview: '한강 다리 아래, 지금 나와있어' },
  ],
};

export interface RecommendationMock {
  ko: string;
  sub: string;
  hook: string;
  tint: string;
  avatar: string;
}

export const RECOMMENDATION: RecommendationMock = {
  ko: '루나',
  sub: '꿈 해몽가',
  hook: '새벽 3시 17분,\n당신의 꿈을 기다려요.',
  tint: '#B8B0FF',
  avatar: '🌙',
};

export interface TarotDrawCard {
  name: string;
  ko: string;
  keyword: string;
}

export interface TarotDrawMock {
  hint: string;
  subhint: string;
  cards: readonly TarotDrawCard[];
}

export const TAROT_DRAW: TarotDrawMock = {
  hint: '오늘의 카드 한 장',
  subhint: '손끝으로 덱을 덮어보세요',
  cards: [
    { name: 'The Star', ko: '별',   keyword: '희망' },
    { name: 'The Moon', ko: '달',   keyword: '직관' },
    { name: 'The Sun',  ko: '태양', keyword: '생명력' },
  ],
};
