/**
 * manseryeok-local.ts — Local 만세력 (Korean traditional calendar) calculator
 *
 * Deterministic, client-side calculation. No external dependencies.
 * All lookup tables are inline constants.
 *
 * Algorithms:
 *   Day Pillar   — 1900-01-01 = 甲子 (index 0 of 60갑자 cycle)
 *   Month Pillar  — derived from year stem + solar-term-based month
 *   Solar Terms   — approximate Gregorian dates (+-1 day)
 *   Lunar Date    — synodic-month approximation from known new-moon reference
 */

/* ════════════════════════════════════════════
 * Exported types
 * ════════════════════════════════════════════ */

/** 오행 (Five Elements) */
export type Element = '목' | '화' | '토' | '금' | '수';

/** 천간 (Heavenly Stems) */
export interface Stem {
  /** 한자 character, e.g. "甲" */
  hanja: string;
  /** Korean reading, e.g. "갑" */
  korean: string;
  /** Associated element */
  element: Element;
}

/** 지지 (Earthly Branches) */
export interface Branch {
  /** 한자 character, e.g. "子" */
  hanja: string;
  /** Korean reading, e.g. "자" */
  korean: string;
  /** Associated element */
  element: Element;
  /** 띠 animal, e.g. "쥐" */
  animal: string;
}

/** A single pillar (stem + branch pair) */
export interface Pillar {
  stem: Stem;
  branch: Branch;
}

/** Extended day pillar with flat convenience fields */
export interface DayPillar extends Pillar {
  stemKr: string;
  branchKr: string;
  stemHanja: string;
  branchHanja: string;
  stemElement: Element;
  branchElement: Element;
  animal: string;
  dayPillarKr: string;
  dayPillarHanja: string;
}

/** 절기 (Solar Term) progress */
export interface SolarTermProgress {
  /** Current solar term name, e.g. "청명" */
  current: string;
  /** Next solar term name, e.g. "곡우" */
  next: string;
  /** Days remaining until next solar term */
  daysRemaining: number;
  /** Progress 0-100 through the current solar term period */
  progress: number;
  /** Season label, e.g. "봄" */
  season: string;
}

/** Daily five-element energy */
export interface DailyEnergy {
  /** Dominant element (from stem) */
  dominant: Element;
  /** Supporting element (from branch) */
  supporting: Element;
  /** Descriptive text */
  description: string;
}

/** Weekly day entry for the strip */
export interface WeekDayEntry {
  /** ISO date string, e.g. "2026-04-06" */
  date: string;
  /** Day of week label, e.g. "월" */
  dayLabel: string;
  /** Date number, e.g. 7 */
  dateNumber: number;
  /** Iljin Korean reading, e.g. "갑자" */
  iljin: string;
  /** Iljin Hanja, e.g. "甲子" */
  iljinHanja: string;
  /** Whether this is today */
  isToday: boolean;
}

/** Full manseryeok data for a single day */
export interface ManseryeokLocalData {
  /** ISO timestamp of the target date at midnight UTC */
  targetDate: string;
  /** Solar date display, e.g. "2026년 4월 9일 (목)" */
  solarDate: string;
  /** Lunar date display, e.g. "음력 2월 22일" */
  lunarDate: string;
  /** Day pillar with flat convenience fields */
  dayPillar: DayPillar;
  /** Month pillar */
  monthPillar: Pillar;
  /** Solar term progress */
  solarTerm: SolarTermProgress;
  /** Daily five-element energy */
  dailyEnergy: DailyEnergy;
  /** Week strip (7 days, Mon–Sun) */
  weekStrip: WeekDayEntry[];
}

/* ════════════════════════════════════════════
 * Lookup tables — Heavenly Stems (천간)
 * ════════════════════════════════════════════ */

const STEMS: Stem[] = [
  { hanja: '甲', korean: '갑', element: '목' },
  { hanja: '乙', korean: '을', element: '목' },
  { hanja: '丙', korean: '병', element: '화' },
  { hanja: '丁', korean: '정', element: '화' },
  { hanja: '戊', korean: '무', element: '토' },
  { hanja: '己', korean: '기', element: '토' },
  { hanja: '庚', korean: '경', element: '금' },
  { hanja: '辛', korean: '신', element: '금' },
  { hanja: '壬', korean: '임', element: '수' },
  { hanja: '癸', korean: '계', element: '수' },
];

/* ════════════════════════════════════════════
 * Lookup tables — Earthly Branches (지지)
 * ════════════════════════════════════════════ */

const BRANCHES: Branch[] = [
  { hanja: '子', korean: '자', element: '수', animal: '쥐' },
  { hanja: '丑', korean: '축', element: '토', animal: '소' },
  { hanja: '寅', korean: '인', element: '목', animal: '호랑이' },
  { hanja: '卯', korean: '묘', element: '목', animal: '토끼' },
  { hanja: '辰', korean: '진', element: '토', animal: '용' },
  { hanja: '巳', korean: '사', element: '화', animal: '뱀' },
  { hanja: '午', korean: '오', element: '화', animal: '말' },
  { hanja: '未', korean: '미', element: '토', animal: '양' },
  { hanja: '申', korean: '신', element: '금', animal: '원숭이' },
  { hanja: '酉', korean: '유', element: '금', animal: '닭' },
  { hanja: '戌', korean: '술', element: '토', animal: '개' },
  { hanja: '亥', korean: '해', element: '수', animal: '돼지' },
];

/* ════════════════════════════════════════════
 * Lookup tables — Days of week
 * ════════════════════════════════════════════ */

const DAY_LABELS = ['일', '월', '화', '수', '목', '금', '토'] as const;

/* ════════════════════════════════════════════
 * Lookup tables — Solar Terms (절기)
 *
 * Approximate Gregorian month/day boundaries.
 * ════════════════════════════════════════════ */

interface SolarTermDef {
  name: string;
  month: number; // 1-indexed Gregorian
  day: number;   // approximate start day
  season: string;
}

const SOLAR_TERM_DEFS: SolarTermDef[] = [
  { name: '소한', month: 1, day: 5, season: '겨울' },
  { name: '대한', month: 1, day: 20, season: '겨울' },
  { name: '입춘', month: 2, day: 4, season: '봄' },
  { name: '우수', month: 2, day: 19, season: '봄' },
  { name: '경칩', month: 3, day: 6, season: '봄' },
  { name: '춘분', month: 3, day: 21, season: '봄' },
  { name: '청명', month: 4, day: 5, season: '봄' },
  { name: '곡우', month: 4, day: 20, season: '봄' },
  { name: '입하', month: 5, day: 6, season: '여름' },
  { name: '소만', month: 5, day: 21, season: '여름' },
  { name: '망종', month: 6, day: 6, season: '여름' },
  { name: '하지', month: 6, day: 21, season: '여름' },
  { name: '소서', month: 7, day: 7, season: '여름' },
  { name: '대서', month: 7, day: 23, season: '여름' },
  { name: '입추', month: 8, day: 7, season: '가을' },
  { name: '처서', month: 8, day: 23, season: '가을' },
  { name: '백로', month: 9, day: 8, season: '가을' },
  { name: '추분', month: 9, day: 23, season: '가을' },
  { name: '한로', month: 10, day: 8, season: '가을' },
  { name: '상강', month: 10, day: 23, season: '가을' },
  { name: '입동', month: 11, day: 7, season: '겨울' },
  { name: '소설', month: 11, day: 22, season: '겨울' },
  { name: '대설', month: 12, day: 7, season: '겨울' },
  { name: '동지', month: 12, day: 22, season: '겨울' },
];

/* ════════════════════════════════════════════
 * Lookup tables — Lunar calendar
 *
 * Lunar new year (1일 1월) solar dates for relevant years.
 * Synodic month: 29.53059 days — used for day-within-month calculation.
 * ════════════════════════════════════════════ */

const SYNODIC_MONTH = 29.53059;

/**
 * Approximate solar date of Lunar New Year (음력 1월 1일) for each year.
 * These are well-known astronomical dates.
 * Key = Gregorian year, Value = [month (0-indexed), day].
 */
const LUNAR_NEW_YEAR: Record<number, [number, number]> = {
  2020: [0, 25],  // Jan 25
  2021: [1, 12],  // Feb 12
  2022: [1, 1],   // Feb 1
  2023: [0, 22],  // Jan 22
  2024: [1, 10],  // Feb 10
  2025: [0, 29],  // Jan 29
  2026: [1, 17],  // Feb 17
  2027: [1, 6],   // Feb 6
  2028: [0, 26],  // Jan 26
  2029: [1, 13],  // Feb 13
  2030: [1, 3],   // Feb 3
  2031: [0, 23],  // Jan 23
  2032: [1, 11],  // Feb 11
  2033: [0, 31],  // Jan 31
  2034: [1, 19],  // Feb 19
  2035: [1, 8],   // Feb 8
};

/* ════════════════════════════════════════════
 * Lookup tables — Energy descriptions (stem x branch element pairs)
 * ════════════════════════════════════════════ */

const ENERGY_PAIR: Record<Element, Record<Element, string>> = {
  목: {
    수: '목 기운이 수의 지원을 받아 성장 에너지가 강합니다',
    목: '목 기운이 겹쳐 창의력과 시작의 에너지가 넘칩니다',
    화: '목이 화를 생하여 열정과 표현력이 풍부합니다',
    토: '목이 토를 극하여 개척과 추진의 에너지가 있습니다',
    금: '금이 목을 극하여 절제와 정돈의 에너지가 있습니다',
  },
  화: {
    목: '화 기운이 목의 지원을 받아 열정 에너지가 타오릅니다',
    화: '화 기운이 겹쳐 적극성과 열정이 최고조입니다',
    토: '화가 토를 생하여 안정과 실행의 에너지가 있습니다',
    금: '화가 금을 극하여 변화와 혁신의 에너지가 있습니다',
    수: '수가 화를 극하여 신중함과 통찰의 에너지가 있습니다',
  },
  토: {
    화: '토 기운이 화의 지원을 받아 안정 에너지가 탄탄합니다',
    토: '토 기운이 겹쳐 중심과 안정의 에너지가 강합니다',
    금: '토가 금을 생하여 결실과 수확의 에너지가 있습니다',
    수: '토가 수를 극하여 통제와 관리의 에너지가 있습니다',
    목: '목이 토를 극하여 변화와 성장의 에너지가 있습니다',
  },
  금: {
    토: '금 기운이 토의 지원을 받아 결단력이 빛납니다',
    금: '금 기운이 겹쳐 날카로운 판단력이 돋보입니다',
    수: '금이 수를 생하여 지혜와 유연함의 에너지가 있습니다',
    목: '금이 목을 극하여 정리와 실행의 에너지가 있습니다',
    화: '화가 금을 극하여 열정적 변화의 에너지가 있습니다',
  },
  수: {
    금: '수 기운이 금의 지원을 받아 지혜 에너지가 깊어집니다',
    수: '수 기운이 겹쳐 직관과 통찰의 에너지가 풍부합니다',
    목: '수가 목을 생하여 성장과 시작의 에너지가 있습니다',
    화: '수가 화를 극하여 냉철한 분석의 에너지가 있습니다',
    토: '토가 수를 극하여 안정적 실행의 에너지가 있습니다',
  },
};

/* ════════════════════════════════════════════
 * Lookup tables — Month Pillar base stems
 *
 * Year-stem group determines the starting stem for 인월 (month 1):
 *   갑·기 → 병인 (stem 2)   을·경 → 무인 (stem 4)
 *   병·신 → 경인 (stem 6)   정·임 → 임인 (stem 8)
 *   무·계 → 갑인 (stem 0)
 * ════════════════════════════════════════════ */

const MONTH_STEM_BASE: Record<number, number> = {
  0: 2, // 갑·기 → 병
  1: 4, // 을·경 → 무
  2: 6, // 병·신 → 경
  3: 8, // 정·임 → 임
  4: 0, // 무·계 → 갑
};

/**
 * Solar-term-based month start boundaries, in calendar order.
 * Each entry: [gregorianMonth (1-indexed), startDay, lunarMonth].
 * Month 12 (축) starts around 소한 (Jan 5), month 1 (인) starts around 입춘 (Feb 4), etc.
 */
const MONTH_BOUNDARIES: Array<[number, number, number]> = [
  [1, 5, 12],   // month 12 (축) — 소한
  [2, 4, 1],    // month 1 (인) — 입춘
  [3, 6, 2],    // month 2 (묘) — 경칩
  [4, 5, 3],    // month 3 (진) — 청명
  [5, 6, 4],    // month 4 (사) — 입하
  [6, 6, 5],    // month 5 (오) — 망종
  [7, 7, 6],    // month 6 (미) — 소서
  [8, 7, 7],    // month 7 (신) — 입추
  [9, 8, 8],    // month 8 (유) — 백로
  [10, 8, 9],   // month 9 (술) — 한로
  [11, 7, 10],  // month 10 (해) — 입동
  [12, 7, 11],  // month 11 (자) — 대설
];

/* ════════════════════════════════════════════
 * Internal helpers
 * ════════════════════════════════════════════ */

const MS_PER_DAY = 86_400_000;

/** Midnight UTC for a given Date. */
function toMidnightUTC(d: Date): number {
  return Date.UTC(d.getFullYear(), d.getMonth(), d.getDate());
}

/** Integer days between two UTC timestamps (rounded). */
function daysBetween(a: number, b: number): number {
  return Math.round((b - a) / MS_PER_DAY);
}

/** Positive modulo — always returns 0..m-1. */
function pmod(n: number, m: number): number {
  return ((n % m) + m) % m;
}

/** Clamp a number to [lo, hi]. */
function clamp(v: number, lo: number, hi: number): number {
  return Math.max(lo, Math.min(hi, v));
}

/* ════════════════════════════════════════════
 * Day Pillar calculation
 *
 * 1900-01-01 = 甲子 (stem index 0, branch index 0).
 * stemIndex  = daysDiff % 10
 * branchIndex = daysDiff % 12
 * ════════════════════════════════════════════ */

const BASE_DATE_MS = Date.UTC(1900, 0, 1);

function calcDayPillarForMs(targetMs: number): DayPillar {
  const daysDiff = daysBetween(BASE_DATE_MS, targetMs);
  const si = pmod(daysDiff, 10);
  const bi = pmod(daysDiff, 12);
  const stem = STEMS[si]!;
  const branch = BRANCHES[bi]!;

  return {
    stem,
    branch,
    stemKr: stem.korean,
    branchKr: branch.korean,
    stemHanja: stem.hanja,
    branchHanja: branch.hanja,
    stemElement: stem.element,
    branchElement: branch.element,
    animal: branch.animal,
    dayPillarKr: `${stem.korean}${branch.korean}`,
    dayPillarHanja: `${stem.hanja}${branch.hanja}`,
  };
}

/* ════════════════════════════════════════════
 * Month Pillar calculation
 * ════════════════════════════════════════════ */

/** Determine the solar-term-based month (1-12) for a Gregorian date. */
function solarTermMonth(d: Date): number {
  const gm = d.getMonth(); // 0-indexed
  const gd = d.getDate();

  // Walk backwards through calendar-ordered boundaries to find the most recent.
  let result = 11; // default: before 소한 (Jan 5) → month 11 (자, Dec 7)
  for (let i = MONTH_BOUNDARIES.length - 1; i >= 0; i--) {
    const [startMonth, startDay, lunarMonth] = MONTH_BOUNDARIES[i]!;
    const sm = startMonth - 1; // 0-indexed
    if (gm > sm || (gm === sm && gd >= startDay)) {
      return lunarMonth;
    }
  }
  return result;
}

function calcMonthPillar(d: Date): Pillar {
  const month = solarTermMonth(d);

  // Before 입춘 (~Feb 4), use previous year's stem.
  const gm = d.getMonth();
  const gd = d.getDate();
  const effectiveYear =
    gm < 1 || (gm === 1 && gd < 4) ? d.getFullYear() - 1 : d.getFullYear();

  // Year stem index: 1984 = 甲子 year → stem index 0.
  const yearStemIdx = pmod(effectiveYear - 4, 10);
  const baseStemIdx = MONTH_STEM_BASE[yearStemIdx % 5]!;

  const stemIdx = pmod(baseStemIdx + (month - 1), 10);
  // Month branch: month 1 = 인(2), month 2 = 묘(3), ..., month 12 = 축(1)
  const branchIdx = pmod(month + 1, 12);

  return {
    stem: STEMS[stemIdx]!,
    branch: BRANCHES[branchIdx]!,
  };
}

/* ════════════════════════════════════════════
 * Solar Term calculation
 * ════════════════════════════════════════════ */

interface TermWithMs extends SolarTermDef {
  dateMs: number;
}

function buildTermTimeline(year: number): TermWithMs[] {
  const make = (y: number): TermWithMs[] =>
    SOLAR_TERM_DEFS.map((t) => ({
      ...t,
      dateMs: Date.UTC(y, t.month - 1, t.day),
    }));
  return [...make(year - 1), ...make(year), ...make(year + 1)];
}

function calcSolarTerm(d: Date): SolarTermProgress {
  const targetMs = toMidnightUTC(d);
  const timeline = buildTermTimeline(d.getFullYear());

  let currentTerm = timeline[0]!;
  let nextTerm = timeline[1]!;

  for (let i = 0; i < timeline.length - 1; i++) {
    if (targetMs >= timeline[i]!.dateMs && targetMs < timeline[i + 1]!.dateMs) {
      currentTerm = timeline[i]!;
      nextTerm = timeline[i + 1]!;
      break;
    }
  }

  const daysRemaining = Math.max(0, daysBetween(targetMs, nextTerm.dateMs));
  const totalSpan = daysBetween(currentTerm.dateMs, nextTerm.dateMs);
  const elapsed = daysBetween(currentTerm.dateMs, targetMs);
  const progress = totalSpan > 0 ? Math.round((elapsed / totalSpan) * 100) : 0;

  return {
    current: currentTerm.name,
    next: nextTerm.name,
    daysRemaining,
    progress: clamp(progress, 0, 100),
    season: currentTerm.season,
  };
}

/* ════════════════════════════════════════════
 * Approximate Lunar Date
 *
 * Uses the synodic month cycle from a known new moon.
 * Accuracy: +-1~2 days — sufficient for display.
 * ════════════════════════════════════════════ */

function calcLunarDate(d: Date): string {
  const targetMs = toMidnightUTC(d);
  const year = d.getFullYear();

  // Find the lunar new year for this date.
  // If the date is before the current year's lunar new year, use previous year's.
  let lnyYear = year;
  let lnyEntry = LUNAR_NEW_YEAR[lnyYear];

  if (lnyEntry) {
    const lnyMs = Date.UTC(lnyYear, lnyEntry[0], lnyEntry[1]);
    if (targetMs < lnyMs) {
      lnyYear -= 1;
      lnyEntry = LUNAR_NEW_YEAR[lnyYear];
    }
  }

  if (!lnyEntry) {
    // Fallback: if year is outside our table, use synodic approximation.
    // Pick the closest known year's LNY as a reference.
    const knownYears = Object.keys(LUNAR_NEW_YEAR).map(Number).sort((a, b) => a - b);
    const closest = knownYears.reduce((prev, curr) =>
      Math.abs(curr - year) < Math.abs(prev - year) ? curr : prev,
    );
    lnyEntry = LUNAR_NEW_YEAR[closest]!;
    lnyYear = closest;
  }

  const lnyMs = Date.UTC(lnyYear, lnyEntry[0], lnyEntry[1]);
  const daysSinceLNY = Math.floor((targetMs - lnyMs) / MS_PER_DAY);

  if (daysSinceLNY < 0) {
    // Edge case: before the earliest LNY in our table.
    // Use a rough estimate: ~354 days in a lunar year.
    const adjusted = daysSinceLNY + 354;
    const month = Math.floor(adjusted / SYNODIC_MONTH) + 1;
    const dayInMonth = Math.floor(adjusted % SYNODIC_MONTH) + 1;
    return `음력 ${clamp(month, 1, 12)}월 ${Math.max(1, dayInMonth)}일`;
  }

  const month = Math.floor(daysSinceLNY / SYNODIC_MONTH) + 1;
  const dayInMonth = Math.floor(daysSinceLNY % SYNODIC_MONTH) + 1;

  return `음력 ${clamp(month, 1, 12)}월 ${Math.max(1, dayInMonth)}일`;
}

/* ════════════════════════════════════════════
 * Solar date formatting
 * ════════════════════════════════════════════ */

function formatSolarDate(d: Date): string {
  const y = d.getFullYear();
  const m = d.getMonth() + 1;
  const day = d.getDate();
  const dow = DAY_LABELS[d.getDay()]!;
  return `${y}년 ${m}월 ${day}일 (${dow})`;
}

/* ════════════════════════════════════════════
 * Daily energy
 * ════════════════════════════════════════════ */

function calcDailyEnergy(stemEl: Element, branchEl: Element): DailyEnergy {
  const description =
    ENERGY_PAIR[stemEl]?.[branchEl] ??
    `${stemEl} 기운이 ${branchEl}의 영향 아래 균형잡힌 하루입니다`;

  return { dominant: stemEl, supporting: branchEl, description };
}

/* ════════════════════════════════════════════
 * Week strip (Mon–Sun of the target date's week)
 * ════════════════════════════════════════════ */

function calcWeekStrip(d: Date): WeekDayEntry[] {
  const todayMs = toMidnightUTC(d);
  const dow = d.getDay(); // 0=Sun
  const mondayOffset = dow === 0 ? -6 : 1 - dow;
  const mondayMs = todayMs + mondayOffset * MS_PER_DAY;

  const entries: WeekDayEntry[] = [];

  for (let i = 0; i < 7; i++) {
    const dayMs = mondayMs + i * MS_PER_DAY;
    const dayDate = new Date(dayMs);
    const pillar = calcDayPillarForMs(dayMs);
    const dayDow = dayDate.getUTCDay();

    entries.push({
      date: dayDate.toISOString().slice(0, 10),
      dayLabel: DAY_LABELS[dayDow]!,
      dateNumber: dayDate.getUTCDate(),
      iljin: pillar.dayPillarKr,
      iljinHanja: pillar.dayPillarHanja,
      isToday: dayMs === todayMs,
    });
  }

  return entries;
}

/* ════════════════════════════════════════════
 * Public API
 * ════════════════════════════════════════════ */

/**
 * Calculate manseryeok data for a given date (defaults to today).
 *
 * All computation is local and deterministic — no network call required.
 * The sexagenary cycle is computed from the epoch 1900-01-01 which was a
 * 甲子 (갑자) day.
 */
export function calculateManseryeok(
  targetDate: Date = new Date(),
): ManseryeokLocalData {
  const targetMs = toMidnightUTC(targetDate);
  const dayPillar = calcDayPillarForMs(targetMs);
  const monthPillar = calcMonthPillar(targetDate);
  const solarTerm = calcSolarTerm(targetDate);
  const lunarDate = calcLunarDate(targetDate);
  const dailyEnergy = calcDailyEnergy(dayPillar.stemElement, dayPillar.branchElement);
  const weekStrip = calcWeekStrip(targetDate);

  return {
    targetDate: new Date(targetMs).toISOString(),
    solarDate: formatSolarDate(targetDate),
    lunarDate,
    dayPillar,
    monthPillar,
    solarTerm,
    dailyEnergy,
    weekStrip,
  };
}
