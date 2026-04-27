/**
 * 절기 기반 월 결정 + 일주 계산용 유틸.
 *
 * 결정적(deterministic): Date 객체만 받아 내부에서 getFullYear/getMonth/getDate 사용.
 * 로컬 타임존 영향 없음 — 입력 문자열을 UTC로 해석.
 */

/** "YYYY-MM-DD" + "HH:mm" → Date (UTC 기준) */
export function parseDateTime(dateStr: string, timeStr: string): Date {
  const [y, m, d] = dateStr.split('-').map(Number);
  const [hh, mm] = timeStr.split(':').map(Number);
  if (y === undefined || m === undefined || d === undefined) {
    throw new Error(`Invalid date string: ${dateStr}`);
  }
  return new Date(Date.UTC(y, (m as number) - 1, d as number, hh ?? 0, mm ?? 0));
}

const MS_PER_DAY = 86_400_000;

export function toMidnightUTC(d: Date): number {
  return Date.UTC(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate());
}

export function daysBetween(a: number, b: number): number {
  return Math.round((b - a) / MS_PER_DAY);
}

export function pmod(n: number, m: number): number {
  return ((n % m) + m) % m;
}

/**
 * 절기 기반 월 경계 — [양력 월 (1-12), 시작일, 해당 음력월(지지 매칭)]
 *
 * 월 12 (축) — 소한 (~1/5)
 * 월 1  (인) — 입춘 (~2/4)
 * 월 2  (묘) — 경칩 (~3/6)
 * ...
 */
export const MONTH_BOUNDARIES: ReadonlyArray<readonly [number, number, number]> = [
  [1, 5, 12],   // 소한 → 축월 (12)
  [2, 4, 1],    // 입춘 → 인월 (1)
  [3, 6, 2],    // 경칩 → 묘월 (2)
  [4, 5, 3],    // 청명 → 진월 (3)
  [5, 6, 4],    // 입하 → 사월 (4)
  [6, 6, 5],    // 망종 → 오월 (5)
  [7, 7, 6],    // 소서 → 미월 (6)
  [8, 7, 7],    // 입추 → 신월 (7) ← 1988-09-05는 입추(8/7) 이후, 백로(9/8) 이전 → 신월(7) ✓
  [9, 8, 8],    // 백로 → 유월 (8)
  [10, 8, 9],   // 한로 → 술월 (9)
  [11, 7, 10],  // 입동 → 해월 (10)
  [12, 7, 11],  // 대설 → 자월 (11)
];

/**
 * 주어진 (year, month 1-12, day 1-31) 에 대해 음력 월(인월=1, ..., 축월=12) 결정.
 */
export function solarTermMonth(month1: number, day: number): number {
  // 계산 아이디어: 역순 스캔 (가장 가까운 이전 경계 찾기)
  let result = 11; // default: 1/5 이전이면 자월(11)
  for (let i = MONTH_BOUNDARIES.length - 1; i >= 0; i--) {
    const [startMonth, startDay, lunarMonth] = MONTH_BOUNDARIES[i]!;
    if (month1 > startMonth || (month1 === startMonth && day >= startDay)) {
      result = lunarMonth;
      break;
    }
  }
  return result;
}

/** 절기상 년도 — 입춘 이전이면 전년도 */
export function solarTermYear(year: number, month1: number, day: number): number {
  // 입춘(~2/4) 이전이면 전년도
  if (month1 === 1) return year - 1;
  if (month1 === 2 && day < 4) return year - 1;
  return year;
}

/** 60갑자 index → (stem index, branch index) */
export function sexagenaryParts(n: number): { stem: number; branch: number } {
  const nn = pmod(n, 60);
  return { stem: nn % 10, branch: nn % 12 };
}

export { MS_PER_DAY };
