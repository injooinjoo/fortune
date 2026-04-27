/**
 * zodiac — 서양 별자리 (12 signs) 계산기
 *
 * YYYY-MM-DD 생년월일 → 해당 일자의 서양 별자리 정보 반환.
 * tropical zodiac (열대 황도대) 기준, 일반적인 태양 달력 구간 사용.
 */

import type { ZodiacInfo, ZodiacSign } from '../types.ts';

interface ZodiacDef {
  id: ZodiacSign;
  ko: string;
  en: string;
  symbol: string;
  startMonth: number;
  startDay: number;
  endMonth: number;
  endDay: number;
  dateRange: string;
}

const ZODIACS: readonly ZodiacDef[] = [
  { id: 'aries',       ko: '양자리',     en: 'Aries',       symbol: '♈', startMonth: 3,  startDay: 21, endMonth: 4,  endDay: 19, dateRange: '3.21 — 4.19' },
  { id: 'taurus',      ko: '황소자리',   en: 'Taurus',      symbol: '♉', startMonth: 4,  startDay: 20, endMonth: 5,  endDay: 20, dateRange: '4.20 — 5.20' },
  { id: 'gemini',      ko: '쌍둥이자리', en: 'Gemini',      symbol: '♊', startMonth: 5,  startDay: 21, endMonth: 6,  endDay: 21, dateRange: '5.21 — 6.21' },
  { id: 'cancer',      ko: '게자리',     en: 'Cancer',      symbol: '♋', startMonth: 6,  startDay: 22, endMonth: 7,  endDay: 22, dateRange: '6.22 — 7.22' },
  { id: 'leo',         ko: '사자자리',   en: 'Leo',         symbol: '♌', startMonth: 7,  startDay: 23, endMonth: 8,  endDay: 22, dateRange: '7.23 — 8.22' },
  { id: 'virgo',       ko: '처녀자리',   en: 'Virgo',       symbol: '♍', startMonth: 8,  startDay: 23, endMonth: 9,  endDay: 22, dateRange: '8.23 — 9.22' },
  { id: 'libra',       ko: '천칭자리',   en: 'Libra',       symbol: '♎', startMonth: 9,  startDay: 23, endMonth: 10, endDay: 22, dateRange: '9.23 — 10.22' },
  { id: 'scorpio',     ko: '전갈자리',   en: 'Scorpio',     symbol: '♏', startMonth: 10, startDay: 23, endMonth: 11, endDay: 21, dateRange: '10.23 — 11.21' },
  { id: 'sagittarius', ko: '사수자리',   en: 'Sagittarius', symbol: '♐', startMonth: 11, startDay: 22, endMonth: 12, endDay: 21, dateRange: '11.22 — 12.21' },
  { id: 'capricorn',   ko: '염소자리',   en: 'Capricorn',   symbol: '♑', startMonth: 12, startDay: 22, endMonth: 1,  endDay: 19, dateRange: '12.22 — 1.19' },
  { id: 'aquarius',    ko: '물병자리',   en: 'Aquarius',    symbol: '♒', startMonth: 1,  startDay: 20, endMonth: 2,  endDay: 18, dateRange: '1.20 — 2.18' },
  { id: 'pisces',      ko: '물고기자리', en: 'Pisces',      symbol: '♓', startMonth: 2,  startDay: 19, endMonth: 3,  endDay: 20, dateRange: '2.19 — 3.20' },
];

function matches(def: ZodiacDef, month: number, day: number): boolean {
  if (def.startMonth <= def.endMonth) {
    // normal range within same year
    if (month === def.startMonth && day >= def.startDay) return true;
    if (month === def.endMonth && day <= def.endDay) return true;
    if (month > def.startMonth && month < def.endMonth) return true;
    return false;
  }
  // wrap-around range (e.g., capricorn: 12.22 — 1.19)
  if (month === def.startMonth && day >= def.startDay) return true;
  if (month === def.endMonth && day <= def.endDay) return true;
  if (month > def.startMonth) return true;
  if (month < def.endMonth) return true;
  return false;
}

/**
 * 생년월일 → 서양 별자리 정보.
 * 유효하지 않은 포맷이면 null 반환.
 */
export function resolveZodiacSign(birthDate: string): ZodiacInfo | null {
  const match = birthDate.match(/^(\d{4})-(\d{2})-(\d{2})$/);
  if (!match) return null;
  const month = Number(match[2]);
  const day = Number(match[3]);
  if (!Number.isFinite(month) || !Number.isFinite(day)) return null;
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;

  for (const def of ZODIACS) {
    if (matches(def, month, day)) {
      return {
        id: def.id,
        ko: def.ko,
        en: def.en,
        symbol: def.symbol,
        dateRange: def.dateRange,
      };
    }
  }
  return null;
}

/** 12개 별자리 정보 (읽기 전용) */
export function listZodiacSigns(): readonly ZodiacInfo[] {
  return ZODIACS.map((z) => ({
    id: z.id,
    ko: z.ko,
    en: z.en,
    symbol: z.symbol,
    dateRange: z.dateRange,
  }));
}
