export interface GuestFortuneProfile {
  birthDate?: string;
  birthTime?: string;
  gender?: 'female' | 'male';
}

type GuestFortuneProfilePatch = {
  birthDate?: string | null;
  birthTime?: string | null;
  gender?: 'female' | 'male' | null;
};

const GUEST_PROFILE_KEY = 'ondo:guest-fortune-profile:v1';
const MIN_BIRTH_YEAR = 1900;
const PREFERRED_START_YEAR = 1990;

export function createBirthYearOptions(currentYear = new Date().getFullYear()): number[] {
  const recent = Array.from(
    { length: Math.max(0, currentYear - PREFERRED_START_YEAR + 1) },
    (_, index) => PREFERRED_START_YEAR + index,
  );
  const earlier = Array.from(
    { length: PREFERRED_START_YEAR - MIN_BIRTH_YEAR },
    (_, index) => PREFERRED_START_YEAR - 1 - index,
  );
  return [...recent, ...earlier];
}

export function daysInMonth(year: number, month: number): number {
  if (!Number.isInteger(year) || !Number.isInteger(month) || month < 1 || month > 12) return 0;
  return new Date(year, month, 0).getDate();
}

export function joinBirthDate(year: string, month: string, day: string): string {
  const numericYear = Number(year);
  const numericMonth = Number(month);
  const numericDay = Number(day);
  if (
    !Number.isInteger(numericYear) ||
    numericYear < MIN_BIRTH_YEAR ||
    numericYear > new Date().getFullYear() ||
    numericDay < 1 ||
    numericDay > daysInMonth(numericYear, numericMonth)
  ) {
    return '';
  }
  return `${numericYear}-${String(numericMonth).padStart(2, '0')}-${String(numericDay).padStart(2, '0')}`;
}

export function splitBirthDate(value: string): { year: string; month: string; day: string } {
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value);
  if (!match) return { year: '', month: '', day: '' };
  const [, year, month, day] = match;
  return joinBirthDate(year, month, day)
    ? { year, month: String(Number(month)), day: String(Number(day)) }
    : { year: '', month: '', day: '' };
}

export function calculateAge(birthDate: string, now = new Date()): number | null {
  const { year, month, day } = splitBirthDate(birthDate);
  if (!year || !month || !day) return null;
  let age = now.getFullYear() - Number(year);
  if (now.getMonth() + 1 < Number(month) || (now.getMonth() + 1 === Number(month) && now.getDate() < Number(day))) {
    age -= 1;
  }
  return age >= 0 ? age : null;
}

export function readGuestFortuneProfile(): GuestFortuneProfile {
  if (typeof window === 'undefined') return {};
  try {
    const raw = window.sessionStorage.getItem(GUEST_PROFILE_KEY);
    if (!raw) return {};
    const parsed = JSON.parse(raw) as Record<string, unknown>;
    const profile: GuestFortuneProfile = {};
    if (typeof parsed.birthDate === 'string' && splitBirthDate(parsed.birthDate).year) {
      profile.birthDate = parsed.birthDate;
    }
    if (typeof parsed.birthTime === 'string') profile.birthTime = parsed.birthTime;
    if (parsed.gender === 'female' || parsed.gender === 'male') profile.gender = parsed.gender;
    return profile;
  } catch {
    return {};
  }
}

export function rememberGuestFortuneProfile(patch: GuestFortuneProfilePatch): void {
  if (typeof window === 'undefined') return;
  try {
    const next = { ...readGuestFortuneProfile(), ...patch } as Record<string, string | null>;
    for (const [key, value] of Object.entries(next)) {
      if (value === null || value === '') delete next[key];
    }
    window.sessionStorage.setItem(GUEST_PROFILE_KEY, JSON.stringify(next));
  } catch {
    // Private browsing or disabled storage must never block a reading.
  }
}
