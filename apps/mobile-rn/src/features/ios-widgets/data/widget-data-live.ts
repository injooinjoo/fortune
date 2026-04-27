/**
 * widget-data-live — useWidgetData() 훅.
 *
 * 사용자의 프로필 생년월일 기반으로 오늘의 운세/별자리/럭키 아이템 등을 계산해
 * 모든 위젯에 제공. saju가 없으면 DAILY_FORTUNE_MOCK 등 목업 디폴트로 폴백.
 */

import { useMemo } from 'react';

import { resolveZodiacSign, type Element, type SajuResult } from '@fortune/saju-engine';

import { useMySaju } from '../../../hooks/use-saju';
import { useMobileAppState } from '../../../providers/mobile-app-state-provider';

import {
  CONSTELLATION_MOCK,
  DAILY_FORTUNE_MOCK,
  LUCKY_ITEM_MOCK,
  RECOMMENDATION,
  TAROT_CARD,
  TAROT_DRAW,
  UNREAD,
  WEEKLY_MOCK,
  type ConstellationMock,
  type DailyFortuneMock,
  type LuckyItemMock,
  type RecommendationMock,
  type TarotCardMock,
  type TarotDrawMock,
  type UnreadMock,
  type WeeklyDay,
} from './widget-data-mock';

/** 위젯 데이터 번들 (모든 fortune-widget이 소비) */
export interface WidgetDataBundle {
  daily: DailyFortuneMock;
  tarot: TarotCardMock;
  constellation: ConstellationMock;
  lucky: LuckyItemMock;
  weekly: readonly WeeklyDay[];
  unread: UnreadMock;
  recommendation: RecommendationMock;
  tarotDraw: TarotDrawMock;
  love:   { score: number; summary: string };
  wealth: { luckyNumber: number; summary: string };
  health: { score: number; summary: string };
}

/** 점수 → 한자 level */
function levelFromScore(score: number): string {
  if (score >= 85) return '대길(大吉)';
  if (score >= 70) return '길(吉)';
  if (score >= 50) return '보통';
  return '소흉(小凶)';
}

/** 오행 한글 → 행운의 색 */
const ELEMENT_COLOR: Record<Element, { name: string; hex: string }> = {
  목: { name: '청록',     hex: '#5FA66B' },
  화: { name: '짙은 와인', hex: '#5C1F2B' },
  토: { name: '오커 골드', hex: '#D4A857' },
  금: { name: '스노우 화이트', hex: '#E6E7EC' },
  수: { name: '심해 블루',   hex: '#4A7AB8' },
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

/** 일간 오행 → 한 줄 요약 */
const ELEMENT_SUMMARY: Record<Element, string> = {
  목: '곧은 바람이 당신의 길을 터주는 하루',
  화: '조용한 행운이 흐르는 하루',
  토: '단단한 땅 위에 중심이 잡히는 하루',
  금: '날카로운 직관이 빛나는 하루',
  수: '깊은 통찰이 흐르는 하루',
};

/** 오행 밸런스 점수를 0-100 range로 정규화 (50-95 스윗 스팟) */
function dailyScoreFromSaju(saju: SajuResult): number {
  const base = Math.round(saju.elements.balanceScore); // 0 ~ 100
  // 밸런스가 좋은 날은 좀 더 '높게' 느껴지도록 50-95로 매핑
  const scaled = 50 + Math.round((base / 100) * 45);
  return Math.max(50, Math.min(95, scaled));
}

/** saju-based fortune 4-category (각 0-100) */
function categoryScoresFromSaju(saju: SajuResult): DailyFortuneMock['fortune'] {
  const e = saju.elements;
  // 오행 카운트를 기반으로 각 분야 점수 산출 (결정적)
  const total = e.wood + e.fire + e.earth + e.metal + e.water || 1;
  const norm = (v: number) => Math.round(50 + (v / total) * 120);
  return {
    career: Math.max(40, Math.min(98, norm(e.metal + e.earth))),
    love:   Math.max(40, Math.min(98, norm(e.fire + e.wood))),
    wealth: Math.max(40, Math.min(98, norm(e.metal + e.water))),
    health: Math.max(40, Math.min(98, norm(e.earth + e.wood))),
  };
}

/** 사주 기반 4주 지지의 해시 → 1~12 랭크 (deterministic) */
function rankFromBirthDate(birthDate: string | null | undefined): number {
  if (!birthDate) return CONSTELLATION_MOCK.rank;
  let hash = 0;
  for (let i = 0; i < birthDate.length; i += 1) {
    hash = (hash * 31 + birthDate.charCodeAt(i)) >>> 0;
  }
  return (hash % 12) + 1;
}

/** luckyNumber: 사주 일간 index 기반 (1-9) */
function luckyNumberFromSaju(saju: SajuResult | null): number {
  if (!saju) return LUCKY_ITEM_MOCK.number;
  // dayMaster.korean 아스키 합 % 9 + 1
  const k = saju.dayMaster.korean;
  let sum = 0;
  for (const ch of k) sum += ch.charCodeAt(0);
  return (sum % 9) + 1;
}

function luckyTimeFromSaju(saju: SajuResult | null): string {
  if (!saju) return LUCKY_ITEM_MOCK.time;
  // 일지 기운으로 시간대 간단 매핑
  const branch = saju.pillars.day.branch.korean;
  const MAP: Record<string, string> = {
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
  return MAP[branch] ?? LUCKY_ITEM_MOCK.time;
}

interface DerivedFortune {
  daily: DailyFortuneMock;
  lucky: LuckyItemMock;
  constellation: ConstellationMock;
}

function deriveFromSaju(
  saju: SajuResult | null,
  birthDate: string | null | undefined,
): DerivedFortune {
  if (!saju) {
    const constellation = birthDate
      ? zodiacToConstellation(birthDate, CONSTELLATION_MOCK.rank) ?? CONSTELLATION_MOCK
      : CONSTELLATION_MOCK;
    return {
      daily: DAILY_FORTUNE_MOCK,
      lucky: LUCKY_ITEM_MOCK,
      constellation,
    };
  }

  const weakEl = saju.elements.weakest;
  const dayEl = saju.dayMaster.element;
  const score = dailyScoreFromSaju(saju);
  const level = levelFromScore(score);
  const summary = ELEMENT_SUMMARY[dayEl];
  const fortune = categoryScoresFromSaju(saju);
  const colorInfo = ELEMENT_COLOR[weakEl];
  const luckyNumber = luckyNumberFromSaju(saju);
  const direction = ELEMENT_DIRECTION[weakEl];
  const item = ELEMENT_ITEM[weakEl];

  const daily: DailyFortuneMock = {
    score,
    level,
    summary,
    body:
      `${summary}. ` +
      `${saju.elements.strongest} 기운이 든든하니 꾸준함이 힘이 돼요. ` +
      `${weakEl} 오행을 보완하는 ${colorInfo.name}과 ${direction} 방향을 챙겨보세요.`,
    lucky: { color: colorInfo.name, number: luckyNumber, direction, item },
    by: 'haneul',
    fortune,
  };

  const lucky: LuckyItemMock = {
    color: colorInfo,
    number: luckyNumber,
    direction,
    item,
    time: luckyTimeFromSaju(saju),
  };

  const rank = rankFromBirthDate(birthDate);
  const constellation = birthDate
    ? zodiacToConstellation(birthDate, rank) ?? CONSTELLATION_MOCK
    : CONSTELLATION_MOCK;

  return { daily, lucky, constellation };
}

function zodiacToConstellation(birthDate: string, rank: number): ConstellationMock | null {
  const z = resolveZodiacSign(birthDate);
  if (!z) return null;
  return {
    sign: z.ko,
    symbol: z.symbol,
    ko: z.en,
    date: z.dateRange,
    message: CONSTELLATION_MOCK.message,
    rank,
    by: 'stella',
  };
}

/**
 * useWidgetData — 모든 fortune-widget이 소비하는 표준 데이터 번들.
 * 프로필 사주 유무에 따라 mock / derived 자동 스위칭.
 */
export function useWidgetData(): WidgetDataBundle {
  const { state } = useMobileAppState();
  const birthDate = state.profile.birthDate ?? null;
  const saju = useMySaju();

  return useMemo<WidgetDataBundle>(() => {
    const derived = deriveFromSaju(saju, birthDate);
    const love = {
      score: derived.daily.fortune.love,
      summary: '오늘의 설렘이 가볍게 스쳐가요',
    };
    const wealth = {
      luckyNumber: derived.lucky.number,
      summary: '작은 수입 기운이 움직이는 하루',
    };
    const health = {
      score: derived.daily.fortune.health,
      summary: '맑고 가벼운 컨디션',
    };
    return {
      daily: derived.daily,
      tarot: TAROT_CARD,
      constellation: derived.constellation,
      lucky: derived.lucky,
      weekly: WEEKLY_MOCK,
      unread: UNREAD,
      recommendation: RECOMMENDATION,
      tarotDraw: TAROT_DRAW,
      love,
      wealth,
      health,
    };
  }, [saju, birthDate]);
}
