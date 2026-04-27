/**
 * 4주(사주) 계산기
 *
 * 알고리즘:
 *   년주: 입춘(~2/4) 기준, (year - 4) mod 10 = stem, (year - 4) mod 12 = branch
 *   월주: 절기 기반 음력월(인월=1, ..., 축월=12) + 연두법
 *   일주: 1900-01-01 = 甲子(갑자) 기준, daysDiff mod 10/12
 *   시주: 일간 + 시지 → 시간 (오둔법)
 *
 * 한국 명리학 관행상 시간 입력 보정:
 *   한국 표준시는 경도 127.5E 기준, 표준시(135E)보다 약 30분 늦게 태양시가 흐름.
 *   또한 1988년은 서머타임(DST) 기간(5/8~10/9)이 있어 1시간 추가 보정 필요.
 *
 * 본 엔진은 단순화를 위해 `birthTime`을 "이미 한국 태양시"로 가정하되,
 * 1988년처럼 DST 특수 케이스는 `timeAdjustMinutes` 옵션으로 조정 가능.
 * 벤치마크(1988-09-05 04:00) 매칭을 위해 기본값 -90분 (DST -60 + 경도 -30).
 *
 * 단, 공개 API에서는 호출자가 맞추도록 하고 내부 기본은 0.
 * 단, 벤치마크 픽스처에서는 timeAdjustMinutes: -90 명시.
 */

import type {
  Branch,
  FourPillars,
  Gender,
  PillarData,
  SajuInput,
  Stem,
  StemKr,
  BranchKr,
} from '../types.ts';
import { STEMS, STEM_KR_ORDER } from '../constants/stems.ts';
import { BRANCHES, BRANCH_KR_ORDER } from '../constants/branches.ts';
import { parseDateTime, pmod, solarTermMonth, solarTermYear, toMidnightUTC, daysBetween } from '../utils/date.ts';
import { lunarToSolar } from '../utils/solar-lunar.ts';

/** 연두법 (년간 → 월간 인월의 기준 stem index) */
// 갑·기년: 丙寅(월간 2 = 丙)
// 을·경년: 戊寅(월간 4 = 戊)
// 병·신년: 庚寅(월간 6 = 庚)
// 정·임년: 壬寅(월간 8 = 壬)
// 무·계년: 甲寅(월간 0 = 甲)
const MONTH_STEM_BASE: Readonly<Record<number, number>> = {
  0: 2, // 갑·기 → 병
  1: 4, // 을·경 → 무
  2: 6, // 병·신 → 경
  3: 8, // 정·임 → 임
  4: 0, // 무·계 → 갑
};

/** 오둔법 (일간 → 시간 자시의 기준 stem index) */
// 갑·기일: 갑자시(stem 0)
// 을·경일: 병자시(stem 2)
// 병·신일: 무자시(stem 4)
// 정·임일: 경자시(stem 6)
// 무·계일: 임자시(stem 8)
const HOUR_STEM_BASE: Readonly<Record<number, number>> = {
  0: 0, 1: 2, 2: 4, 3: 6, 4: 8,
};

/**
 * 1900-01-01 = 甲戌(갑술)일 기준 (stem index 0, branch index 10).
 *
 * 만세력 검증: 1988-09-05 = 癸亥(계해)일 ← 이 기준으로 정확.
 * (일반 위키에 1900-01-01 = 갑자라고 잘못 알려진 경우 있으나, 공식 만세력은 갑술)
 */
const BASE_DATE_MS = Date.UTC(1900, 0, 1);
const BASE_STEM_IDX = 0;   // 갑
const BASE_BRANCH_IDX = 10; // 술

/** 시주 계산 옵션 */
export interface CalcOptions {
  /** 시간 보정 (분). 음수면 뒤로 당김. 기본 0. */
  timeAdjustMinutes?: number;
}

function buildPillar(stem: Stem, branch: Branch): PillarData {
  return {
    stem,
    branch,
    korean: `${stem.korean}${branch.korean}`,
    hanja: `${stem.hanja}${branch.hanja}`,
  };
}

function calcYearPillar(effectiveYear: number): PillarData {
  // 1984 = 甲子 → (1984-4) % 10 = 0
  const stemIdx = pmod(effectiveYear - 4, 10);
  const branchIdx = pmod(effectiveYear - 4, 12);
  return buildPillar(STEMS[stemIdx]!, BRANCHES[branchIdx]!);
}

function calcMonthPillar(yearStem: Stem, lunarMonth: number): PillarData {
  // lunarMonth: 1=인, 2=묘, ..., 12=축
  const yearStemIdx = STEM_KR_ORDER.indexOf(yearStem.korean);
  const baseIdx = MONTH_STEM_BASE[yearStemIdx % 5]!;
  const stemIdx = pmod(baseIdx + (lunarMonth - 1), 10);

  // 월지: 인월=index 2, 묘월=index 3, ..., 축월=index 1
  const branchIdx = pmod(lunarMonth + 1, 12);
  return buildPillar(STEMS[stemIdx]!, BRANCHES[branchIdx]!);
}

function calcDayPillar(date: Date): PillarData {
  const targetMs = toMidnightUTC(date);
  const diff = daysBetween(BASE_DATE_MS, targetMs);
  const stemIdx = pmod(BASE_STEM_IDX + diff, 10);
  const branchIdx = pmod(BASE_BRANCH_IDX + diff, 12);
  return buildPillar(STEMS[stemIdx]!, BRANCHES[branchIdx]!);
}

/**
 * 시간 -> 시지 index.
 * 자시: 23:00-01:00 (branch 0)
 * 축시: 01:00-03:00 (branch 1)
 * 인시: 03:00-05:00 (branch 2)
 * ...
 * 해시: 21:00-23:00 (branch 11)
 *
 * 공식: hour가 23이면 0, else floor((hour+1)/2) % 12
 */
function hourToBranchIdx(hourDecimal: number): number {
  // hourDecimal은 0.0 ~ 23.999
  const h = ((hourDecimal % 24) + 24) % 24;
  if (h >= 23) return 0;
  return Math.floor((h + 1) / 2) % 12;
}

function calcHourPillar(dayStem: Stem, hourDecimal: number): PillarData {
  const branchIdx = hourToBranchIdx(hourDecimal);
  const dayStemIdx = STEM_KR_ORDER.indexOf(dayStem.korean);
  const baseIdx = HOUR_STEM_BASE[dayStemIdx % 5]!;
  const stemIdx = pmod(baseIdx + branchIdx, 10);
  return buildPillar(STEMS[stemIdx]!, BRANCHES[branchIdx]!);
}

/** 양력 Date 만들기 (입력이 양력/음력인지 처리) */
function toSolarDate(input: SajuInput): Date {
  const time = input.birthTime ?? '00:00';
  if (input.isLunar) {
    const [y, m, d] = input.birthDate.split('-').map(Number);
    if (y === undefined || m === undefined || d === undefined) {
      throw new Error(`Invalid date: ${input.birthDate}`);
    }
    const solar = lunarToSolar(y, m, d);
    // 시간은 유지
    const [hh, mm] = time.split(':').map(Number);
    return new Date(
      Date.UTC(solar.getUTCFullYear(), solar.getUTCMonth(), solar.getUTCDate(), hh ?? 0, mm ?? 0),
    );
  }
  return parseDateTime(input.birthDate, time);
}

export function calculatePillars(input: SajuInput, opts: CalcOptions = {}): FourPillars {
  const adjust = opts.timeAdjustMinutes ?? 0;
  const baseDate = toSolarDate(input);
  const adjusted = new Date(baseDate.getTime() + adjust * 60_000);

  const year = adjusted.getUTCFullYear();
  const month1 = adjusted.getUTCMonth() + 1;
  const day = adjusted.getUTCDate();
  const hourDecimal = adjusted.getUTCHours() + adjusted.getUTCMinutes() / 60;

  const effectiveYear = solarTermYear(year, month1, day);
  const lunarMonth = solarTermMonth(month1, day);

  // 자시가 다음 날로 넘어가는 경우: 시간이 23:00 이상이면 일주는 다음 날 기준 (야자시)
  // 단순화: 본 엔진은 일주를 날짜 자체로 계산 (자시 조자시 통합식)
  const dayDateBase = new Date(Date.UTC(year, adjusted.getUTCMonth(), day));

  const yearPillar = calcYearPillar(effectiveYear);
  const monthPillar = calcMonthPillar(yearPillar.stem, lunarMonth);
  const dayPillar = calcDayPillar(dayDateBase);
  const hourPillar = calcHourPillar(dayPillar.stem, hourDecimal);

  return {
    year: yearPillar,
    month: monthPillar,
    day: dayPillar,
    hour: hourPillar,
  };
}

/** 외부에서 재사용할 수 있도록 export */
export { MONTH_STEM_BASE, HOUR_STEM_BASE };
