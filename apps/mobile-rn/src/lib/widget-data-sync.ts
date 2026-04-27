/**
 * widget-data-sync — iOS 홈/잠금화면 위젯용 App Group UserDefaults 브릿지.
 *
 * 메인 앱이 사주 기반으로 계산한 운세/타로/연애/별자리/럭키/주간/채팅/
 * 추천/꿈/건강/재물 데이터를 App Group UserDefaults
 * (`group.com.beyond.fortune.widgets`) 의 `widgetData` 키에 JSON 문자열로
 * 저장. 위젯 extension(SharedStore.swift)이 같은 suite name으로 읽어와
 * SwiftUI 위젯에 반영.
 *
 * - iOS 전용. Android는 no-op.
 * - 실패는 silent — 위젯 데이터는 선택적 기능이고, 설치 직후 App Group
 *   entitlement가 반영되기 전에 호출되면 native 측에서 throw 할 수 있다.
 *
 * 스프린트 W2: 20 위젯 포팅을 위해 WidgetDataBundle 필드 전체 확장 +
 * `buildWidgetData(saju, birthDate?)` 시그니처 확장.
 */
import { Platform } from 'react-native';
import SharedGroupPreferences from 'react-native-shared-group-preferences';

import { resolveZodiacSign, type Element, type SajuResult } from '@fortune/saju-engine';

const APP_GROUP = 'group.com.beyond.fortune.widgets';
const STORAGE_KEY = 'widgetData';

// ---------------------------------------------------------------------------
// Widget data bundle TypeScript interfaces (Swift `OndoData.swift` mirror).
// 필드 추가 시 양쪽 동시 수정.
// ---------------------------------------------------------------------------

export interface WidgetDailyFortune {
  score: number;
  level: string;
  summary: string;
  body?: string;
  fortune: {
    career: number;
    love: number;
    wealth: number;
    health: number;
  };
  lucky?: {
    color: string;
    number: number;
    direction: string;
    item: string;
  };
}

export interface WidgetTarotCard {
  name: string;
  ko: string;
  keyword: string;
  reading: string;
  arcana?: string;
}

export interface WidgetLoveFortune {
  score: number;
  oneLiner: string;
  subtitle?: string;
}

export interface WidgetConstellation {
  sign: string;
  symbol: string;
  ko: string;
  date: string;
  rank: number;
  message?: string;
}

export interface WidgetLuckyItem {
  color: { name: string; hex: string };
  number: number;
  direction: string;
  item: string;
  time: string;
}

export interface WidgetWeeklyDay {
  d: string;
  score: number;
  hi: boolean;
}

export interface WidgetStoryPreview {
  name: string;
  subtitle: string;
  tint: string;
  avatar: string;
  typing: boolean;
}

export interface WidgetUnreadItem {
  characterName: string;
  preview: string;
  tint: string;
  avatar: string;
}

export interface WidgetUnread {
  total: number;
  items: WidgetUnreadItem[];
}

export interface WidgetRecommendation {
  name: string;
  subtitle: string;
  hook: string;
  tint: string;
  avatar: string;
}

export interface WidgetTarotDraw {
  hint: string;
  subhint?: string;
  cards: WidgetTarotCard[];
}

export interface WidgetHealthFortune {
  score: number;
  summary: string;
}

export interface WidgetWealthFortune {
  luckyNumber: number;
  summary: string;
}

export interface WidgetDream {
  message: string;
}

export interface WidgetDataBundle {
  daily?: WidgetDailyFortune;
  tarot?: WidgetTarotCard;
  love?: WidgetLoveFortune;
  constellation?: WidgetConstellation;
  lucky?: WidgetLuckyItem;
  weekly?: WidgetWeeklyDay[];
  story?: WidgetStoryPreview;
  unread?: WidgetUnread;
  recommendation?: WidgetRecommendation;
  tarotDraw?: WidgetTarotDraw;
  health?: WidgetHealthFortune;
  wealth?: WidgetWealthFortune;
  dream?: WidgetDream;
  /** ISO-8601 timestamp — 위젯 debug 용 */
  updatedAt: string;
}

/**
 * WidgetDataBundle 을 App Group UserDefaults 로 flush.
 * iOS 이외에서는 즉시 no-op. 네이티브 에러는 swallow — 위젯은 선택적.
 */
export async function syncWidgetData(bundle: WidgetDataBundle): Promise<void> {
  if (Platform.OS !== 'ios') {
    return;
  }
  try {
    const serialized = JSON.stringify(bundle);
    await SharedGroupPreferences.setItem(STORAGE_KEY, serialized, APP_GROUP);
  } catch (error) {
    // App Group entitlement 미반영 (구 빌드 업그레이드 직후 등) / native 모듈
    // 미등록 (Expo Go) 상황에서 throw. 위젯은 optional 기능이므로 앱 기능을
    // 막지 않고 조용히 무시.
    if (__DEV__) {
      console.warn('[widget-data-sync] flush failed:', error);
    }
  }
}

// ---------------------------------------------------------------------------
// Derive helpers — widget-data-live.ts 의 useWidgetData() 로직과 동일 스키마.
// Hook 의존 없이 pure 함수로 재구성해 bootstrap/이펙트 양쪽에서 재사용.
// ---------------------------------------------------------------------------

function levelFromScore(score: number): string {
  if (score >= 85) return '대길(大吉)';
  if (score >= 70) return '길(吉)';
  if (score >= 50) return '보통';
  return '소흉(小凶)';
}

const ELEMENT_COLOR: Record<Element, { name: string; hex: string }> = {
  목: { name: '청록', hex: '#5FA66B' },
  화: { name: '짙은 와인', hex: '#5C1F2B' },
  토: { name: '오커 골드', hex: '#D4A857' },
  금: { name: '스노우 화이트', hex: '#E6E7EC' },
  수: { name: '심해 블루', hex: '#4A7AB8' },
};

const ELEMENT_DIRECTION: Record<Element, string> = {
  목: '동쪽',
  화: '남쪽',
  토: '중앙',
  금: '서쪽',
  수: '북쪽',
};

const ELEMENT_ITEM: Record<Element, string> = {
  목: '목재 소품',
  화: '금속 펜',
  토: '도자기 잔',
  금: '은 장신구',
  수: '유리병',
};

const ELEMENT_SUMMARY: Record<Element, string> = {
  목: '곧은 바람이 당신의 길을 터주는 하루',
  화: '조용한 행운이 흐르는 하루',
  토: '단단한 땅 위에 중심이 잡히는 하루',
  금: '날카로운 직관이 빛나는 하루',
  수: '깊은 통찰이 흐르는 하루',
};

const TIME_BY_BRANCH: Record<string, string> = {
  자: '오후 11시',
  축: '새벽 1시',
  인: '오전 3시',
  묘: '오전 5시',
  진: '오전 7시',
  사: '오전 9시',
  오: '오전 11시',
  미: '오후 1시',
  신: '오후 3시',
  유: '오후 5시',
  술: '오후 7시',
  해: '오후 9시',
};

function dailyScore(saju: SajuResult): number {
  const base = Math.round(saju.elements.balanceScore);
  const scaled = 50 + Math.round((base / 100) * 45);
  return Math.max(50, Math.min(95, scaled));
}

function categoryScores(saju: SajuResult): WidgetDailyFortune['fortune'] {
  const e = saju.elements;
  const total = e.wood + e.fire + e.earth + e.metal + e.water || 1;
  const norm = (v: number): number => Math.round(50 + (v / total) * 120);
  return {
    career: Math.max(40, Math.min(98, norm(e.metal + e.earth))),
    love: Math.max(40, Math.min(98, norm(e.fire + e.wood))),
    wealth: Math.max(40, Math.min(98, norm(e.metal + e.water))),
    health: Math.max(40, Math.min(98, norm(e.earth + e.wood))),
  };
}

function luckyNumber(saju: SajuResult): number {
  let sum = 0;
  for (const ch of saju.dayMaster.korean) sum += ch.charCodeAt(0);
  return (sum % 9) + 1;
}

function luckyTime(saju: SajuResult | null): string {
  if (!saju) return '오후 3시';
  const branch = saju.pillars.day.branch.korean;
  return TIME_BY_BRANCH[branch] ?? '오후 3시';
}

function rankFromBirthDate(birthDate: string | null | undefined): number {
  if (!birthDate) return 2;
  let hash = 0;
  for (let i = 0; i < birthDate.length; i += 1) {
    hash = (hash * 31 + birthDate.charCodeAt(i)) >>> 0;
  }
  return (hash % 12) + 1;
}

// ---------------------------------------------------------------------------
// Defaults & mocks (모바일 UI의 widget-data-mock.ts 와 shape 일치).
// ---------------------------------------------------------------------------

const DEFAULT_DAILY: WidgetDailyFortune = {
  score: 72,
  level: '길(吉)',
  summary: '조용한 행운이 흐르는 하루',
  body: '오늘은 한 발 늦추는 것이 유리합니다. 기다리는 자리에 기회가 옵니다.',
  fortune: { career: 74, love: 78, wealth: 68, health: 80 },
  lucky: { color: '짙은 와인', number: 7, direction: '남동', item: '금속 펜' },
};

const DEFAULT_TAROT: WidgetTarotCard = {
  name: 'The Star',
  ko: '별',
  keyword: '희망 · 평온 · 회복',
  reading: '잔잔한 물가에서, 당신은 지쳐있던 손을 씻습니다.',
  arcana: 'Major Arcana · XVII',
};

const DEFAULT_LOVE: WidgetLoveFortune = {
  score: 78,
  oneLiner: '오래된 이름이 다시 스칠 예감',
  subtitle: '기다렸던 메시지',
};

const DEFAULT_CONSTELLATION: WidgetConstellation = {
  sign: '쌍둥이자리',
  symbol: '♊',
  ko: 'Gemini',
  date: '5.21 — 6.21',
  rank: 2,
  message: '수성이 당신의 언어를 빌립니다. 꺼냈던 말을 다시 꺼내세요.',
};

const DEFAULT_LUCKY: WidgetLuckyItem = {
  color: { name: '짙은 와인', hex: '#5C1F2B' },
  number: 7,
  direction: '남동',
  item: '금속 펜',
  time: '오후 3시',
};

const DEFAULT_WEEKLY: WidgetWeeklyDay[] = [
  { d: '월', score: 72, hi: false },
  { d: '화', score: 85, hi: false },
  { d: '수', score: 68, hi: false },
  { d: '목', score: 91, hi: true },
  { d: '금', score: 77, hi: false },
  { d: '토', score: 82, hi: false },
  { d: '일', score: 64, hi: false },
];

const DEFAULT_STORY: WidgetStoryPreview = {
  name: '해린',
  subtitle: '출판사 편집자',
  tint: '#E0A76B',
  avatar: '해',
  typing: true,
};

const DEFAULT_UNREAD: WidgetUnread = {
  total: 7,
  items: [
    { characterName: '해린', preview: '오늘 원고 넘긴 건 어땠어요?', tint: '#E0A76B', avatar: '해' },
    { characterName: '지훈', preview: '논문 마감 세 시간 전…', tint: '#B8B0FF', avatar: '지' },
    { characterName: '민지', preview: '한강 다리 아래, 지금 나와있어', tint: '#8FB8FF', avatar: '민' },
  ],
};

const DEFAULT_RECOMMENDATION: WidgetRecommendation = {
  name: '루나',
  subtitle: '꿈 해몽가',
  hook: '새벽 3시 17분,\n당신의 꿈을 기다려요.',
  tint: '#B8B0FF',
  avatar: '🌙',
};

const DEFAULT_TAROT_DRAW: WidgetTarotDraw = {
  hint: '오늘의 카드 한 장',
  subhint: '손끝으로 덱을 덮어보세요',
  cards: [
    { name: 'The Star', ko: '별', keyword: '희망', reading: '' },
    { name: 'The Moon', ko: '달', keyword: '직관', reading: '' },
    { name: 'The Sun', ko: '태양', keyword: '생명력', reading: '' },
  ],
};

// ---------------------------------------------------------------------------
// buildWidgetData
// ---------------------------------------------------------------------------

function deriveConstellation(
  birthDate: string | null | undefined,
  rank: number,
): WidgetConstellation {
  if (!birthDate) return DEFAULT_CONSTELLATION;
  const z = resolveZodiacSign(birthDate);
  if (!z) return { ...DEFAULT_CONSTELLATION, rank };
  return {
    sign: z.ko,
    symbol: z.symbol,
    ko: z.en,
    date: z.dateRange,
    rank,
    message: DEFAULT_CONSTELLATION.message,
  };
}

/**
 * buildWidgetData — saju(없을 수 있음) + optional birthDate → WidgetDataBundle 변환.
 * 순수 함수. 동일 입력에 대해 동일 출력 (updatedAt 제외).
 *
 * - saju === null → 전 필드 default/mock 반환.
 * - saju 있으면 dailyScore/categoryScores/lucky derive + constellation은 birthDate로.
 * - story/unread/recommendation/tarotDraw/dream 은 mock 상수 (동적 데이터 W3+에서).
 */
export function buildWidgetData(
  saju: SajuResult | null,
  birthDate?: string | null,
): WidgetDataBundle {
  const updatedAt = new Date().toISOString();
  const rank = rankFromBirthDate(birthDate);
  const constellation = deriveConstellation(birthDate, rank);

  if (!saju) {
    const health: WidgetHealthFortune = {
      score: DEFAULT_DAILY.fortune.health,
      summary: '맑고 가벼운 컨디션',
    };
    const wealth: WidgetWealthFortune = {
      luckyNumber: DEFAULT_LUCKY.number,
      summary: '작은 수입 기운이 움직이는 하루',
    };
    const dream: WidgetDream = { message: DEFAULT_RECOMMENDATION.hook };

    return {
      daily: DEFAULT_DAILY,
      tarot: DEFAULT_TAROT,
      love: DEFAULT_LOVE,
      constellation,
      lucky: DEFAULT_LUCKY,
      weekly: DEFAULT_WEEKLY,
      story: DEFAULT_STORY,
      unread: DEFAULT_UNREAD,
      recommendation: DEFAULT_RECOMMENDATION,
      tarotDraw: DEFAULT_TAROT_DRAW,
      health,
      wealth,
      dream,
      updatedAt,
    };
  }

  const score = dailyScore(saju);
  const weakEl = saju.elements.weakest;
  const dayEl = saju.dayMaster.element;
  const fortune = categoryScores(saju);
  const colorInfo = ELEMENT_COLOR[weakEl];
  const direction = ELEMENT_DIRECTION[weakEl];
  const item = ELEMENT_ITEM[weakEl];
  const number = luckyNumber(saju);

  const daily: WidgetDailyFortune = {
    score,
    level: levelFromScore(score),
    summary: ELEMENT_SUMMARY[dayEl],
    body:
      `${ELEMENT_SUMMARY[dayEl]}. ` +
      `${saju.elements.strongest} 기운이 든든하니 꾸준함이 힘이 돼요. ` +
      `${weakEl} 오행을 보완하는 ${colorInfo.name}과 ${direction} 방향을 챙겨보세요.`,
    fortune,
    lucky: {
      color: colorInfo.name,
      number,
      direction,
      item,
    },
  };

  const love: WidgetLoveFortune = {
    score: fortune.love,
    oneLiner:
      fortune.love >= 80
        ? '오래된 이름이 다시 스칠 예감'
        : '가벼운 온기를 주고받는 하루',
    subtitle: fortune.love >= 80 ? '기다렸던 메시지' : '천천히 다가오는 계절',
  };

  const lucky: WidgetLuckyItem = {
    color: colorInfo,
    number,
    direction,
    item,
    time: luckyTime(saju),
  };

  const health: WidgetHealthFortune = {
    score: fortune.health,
    summary: fortune.health >= 80 ? '맑고 가벼운 컨디션' : '수분과 휴식을 챙기세요',
  };

  const wealth: WidgetWealthFortune = {
    luckyNumber: number,
    summary: fortune.wealth >= 80 ? '작은 수입 기운이 움직이는 하루' : '지출을 늦추면 기회가 와요',
  };

  const dream: WidgetDream = { message: DEFAULT_RECOMMENDATION.hook };

  return {
    daily,
    tarot: DEFAULT_TAROT,
    love,
    constellation,
    lucky,
    weekly: DEFAULT_WEEKLY,
    story: DEFAULT_STORY,
    unread: DEFAULT_UNREAD,
    recommendation: DEFAULT_RECOMMENDATION,
    tarotDraw: DEFAULT_TAROT_DRAW,
    health,
    wealth,
    dream,
    updatedAt,
  };
}
