import type { FortuneTypeId } from '@fortune/product-contracts';

/**
 * Cohort extraction helpers - mirrors Flutter's cohort_helpers.dart
 *
 * Extracts generalized cohort dimensions from user input to reduce
 * API calls via cohort pool lookups.
 */

const zodiacAnimals = [
  '쥐', '소', '호랑이', '토끼', '용', '뱀',
  '말', '양', '원숭이', '닭', '개', '돼지',
] as const;

const elements = ['목', '화', '토', '금', '수'] as const;

export function extractAgeGroup(birthDate: string | undefined): string {
  if (!birthDate) return 'unknown';

  const birthYear = parseInt(birthDate.slice(0, 4), 10);
  if (isNaN(birthYear)) return 'unknown';

  const age = new Date().getFullYear() - birthYear;

  if (age < 20) return '10s';
  if (age < 30) return '20s';
  if (age < 40) return '30s';
  if (age < 50) return '40s';
  return '50s+';
}

export function extractZodiacAnimal(birthDate: string | undefined): string {
  if (!birthDate) return 'unknown';

  const birthYear = parseInt(birthDate.slice(0, 4), 10);
  if (isNaN(birthYear)) return 'unknown';

  // 12-year cycle starting from Rat (쥐) at year 0 mod 12 = 4
  const index = (birthYear - 4) % 12;
  return zodiacAnimals[index < 0 ? index + 12 : index] ?? 'unknown';
}

export function extractElement(birthDate: string | undefined): string {
  if (!birthDate) return 'unknown';

  const birthYear = parseInt(birthDate.slice(0, 4), 10);
  if (isNaN(birthYear)) return 'unknown';

  // 10-year cycle: 목(0,1), 화(2,3), 토(4,5), 금(6,7), 수(8,9)
  const index = Math.floor((birthYear % 10) / 2);
  return elements[index] ?? 'unknown';
}

export interface CohortData {
  [key: string]: string;
}

/**
 * Extract cohort dimensions for a given fortune type.
 * Matches Flutter's CohortHelpers.extractCohort().
 */
export function extractCohort(
  fortuneType: FortuneTypeId,
  input: {
    birthDate?: string;
    birthTime?: string;
    mbti?: string;
    bloodType?: string;
    gender?: string;
    answers?: Record<string, unknown>;
  },
): CohortData {
  const ageGroup = extractAgeGroup(input.birthDate);
  const zodiac = extractZodiacAnimal(input.birthDate);
  const element = extractElement(input.birthDate);
  const gender = input.gender ?? 'unknown';

  switch (fortuneType) {
    case 'daily':
    case 'daily-calendar': {
      const period = getCurrentPeriod();
      return { period, zodiac, element };
    }

    case 'love':
    case 'blind-date':
    case 'ex-lover': {
      const status = String(input.answers?.['status'] ?? input.answers?.['emotionState'] ?? 'unknown');
      return { ageGroup, gender, status, zodiac };
    }

    case 'compatibility':
    case 'celebrity': {
      return { zodiac, ageGroup, gender };
    }

    case 'career':
    case 'wealth':
    case 'talent': {
      const industry = String(input.answers?.['field'] ?? 'general');
      return { ageGroup, gender, industry };
    }

    case 'health':
    case 'exercise': {
      const season = getCurrentSeason();
      return { ageGroup, gender, season, element };
    }

    case 'mbti': {
      const mbti = input.mbti ?? String(input.answers?.['mbtiType'] ?? 'unknown');
      return { mbti };
    }

    case 'face-reading': {
      return { ageGroup, gender };
    }

    case 'dream': {
      const category = String(input.answers?.['category'] ?? 'general');
      const emotion = String(input.answers?.['emotion'] ?? 'neutral');
      return { category, emotion, zodiac };
    }

    case 'tarot': {
      const purpose = String(input.answers?.['purpose'] ?? 'general');
      return { purpose, zodiac };
    }

    case 'personality-dna': {
      const mbtiVal = input.mbti ?? String(input.answers?.['mbti'] ?? 'unknown');
      const blood = input.bloodType ?? String(input.answers?.['bloodType'] ?? 'unknown');
      return { mbti: mbtiVal, bloodType: blood };
    }

    default:
      return { ageGroup, zodiac, element };
  }
}

/**
 * Generate a deterministic hash from cohort data.
 * Simple string-based hash for pool lookup.
 */
export function generateCohortHash(data: CohortData): string {
  const sorted = Object.keys(data).sort();
  const parts = sorted.map((key) => `${key}:${data[key]}`);
  return parts.join('|');
}

function getCurrentPeriod(): string {
  const hour = new Date().getHours();
  if (hour < 6) return 'dawn';
  if (hour < 12) return 'morning';
  if (hour < 18) return 'afternoon';
  return 'evening';
}

function getCurrentSeason(): string {
  const month = new Date().getMonth() + 1;
  if (month >= 3 && month <= 5) return 'spring';
  if (month >= 6 && month <= 8) return 'summer';
  if (month >= 9 && month <= 11) return 'autumn';
  return 'winter';
}
