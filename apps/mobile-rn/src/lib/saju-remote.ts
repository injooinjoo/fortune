import { supabase } from './supabase';
import { getSecureItem, setSecureItem } from './secure-store-storage';

import type { SupabaseSession } from './supabase';

/* ────────────────────────────────────────────
 * Types
 * ──────────────────────────────────────────── */

export interface SajuElementBalance {
  목: number;
  화: number;
  토: number;
  금: number;
  수: number;
}

export interface SajuData {
  year_stem_hanja: string;
  year_branch_hanja: string;
  month_stem_hanja: string;
  month_branch_hanja: string;
  day_stem_hanja: string;
  day_branch_hanja: string;
  hour_stem_hanja: string | null;
  hour_branch_hanja: string | null;
  element_balance: SajuElementBalance;
  dominant_element: string;
  weak_element: string | null;
  lacking_element: string | null;
  personality_traits: string | null;
  fortune_summary: string | null;
  enhancement_method: string | null;
}

/* ────────────────────────────────────────────
 * Storage key
 * ──────────────────────────────────────────── */

const SAJU_CACHE_KEY = 'fortune.saju-data-cache.v1';

function resolveUserCacheKey(userId: string) {
  return `${SAJU_CACHE_KEY}.${userId}`;
}

/* ────────────────────────────────────────────
 * fetchSajuData — calls the calculate-saju Edge Function
 * ──────────────────────────────────────────── */

export async function fetchSajuData(
  session: NonNullable<SupabaseSession>,
  birthDate: string,
  birthTime: string,
): Promise<SajuData> {
  if (!supabase) {
    throw new Error('Supabase client is not configured');
  }

  const { data, error } = await supabase.functions.invoke('calculate-saju', {
    body: { birthDate, birthTime, isLunar: false },
  });

  if (error) {
    throw new Error(error.message || 'Failed to invoke calculate-saju');
  }

  if (!data || !data.success || !data.data) {
    const serverError =
      typeof data?.error === 'string' ? data.error : 'Unknown server error';
    throw new Error(serverError);
  }

  const result = normalizeSajuData(data.data);

  // Cache the result
  await setSecureItem(
    resolveUserCacheKey(session.user.id),
    JSON.stringify(result),
  );

  return result;
}

/* ────────────────────────────────────────────
 * getSajuData — returns cached data or fetches fresh
 * ──────────────────────────────────────────── */

export async function getSajuData(
  session: NonNullable<SupabaseSession>,
  birthDate: string,
  birthTime: string,
): Promise<SajuData> {
  // Try local cache first
  const cached = await getSecureItem(resolveUserCacheKey(session.user.id));

  if (cached) {
    try {
      const parsed = JSON.parse(cached) as SajuData;

      // Basic validation: ensure essential fields exist
      if (parsed.year_stem_hanja && parsed.day_stem_hanja && parsed.element_balance) {
        return parsed;
      }
    } catch {
      // Corrupted cache — fall through to fetch
    }
  }

  return fetchSajuData(session, birthDate, birthTime);
}

/* ────────────────────────────────────────────
 * Normalize — coerce raw API data into SajuData
 * ──────────────────────────────────────────── */

function asString(value: unknown, fallback = ''): string {
  return typeof value === 'string' ? value : fallback;
}

function asNumber(value: unknown, fallback = 0): number {
  return typeof value === 'number' && Number.isFinite(value) ? value : fallback;
}

function normalizeSajuData(raw: Record<string, unknown>): SajuData {
  const rawBalance = (raw.element_balance ?? {}) as Record<string, unknown>;

  return {
    year_stem_hanja: asString(raw.year_stem_hanja),
    year_branch_hanja: asString(raw.year_branch_hanja),
    month_stem_hanja: asString(raw.month_stem_hanja),
    month_branch_hanja: asString(raw.month_branch_hanja),
    day_stem_hanja: asString(raw.day_stem_hanja),
    day_branch_hanja: asString(raw.day_branch_hanja),
    hour_stem_hanja: raw.hour_stem_hanja != null ? asString(raw.hour_stem_hanja) : null,
    hour_branch_hanja: raw.hour_branch_hanja != null ? asString(raw.hour_branch_hanja) : null,
    element_balance: {
      목: asNumber(rawBalance['목']),
      화: asNumber(rawBalance['화']),
      토: asNumber(rawBalance['토']),
      금: asNumber(rawBalance['금']),
      수: asNumber(rawBalance['수']),
    },
    dominant_element: asString(raw.dominant_element || raw.strong_element),
    weak_element: asString(raw.weak_element) || asString(raw.lacking_element) || null,
    lacking_element: asString(raw.lacking_element) || asString(raw.weak_element) || null,
    personality_traits: typeof raw.personality_traits === 'string' ? raw.personality_traits : null,
    fortune_summary: typeof raw.fortune_summary === 'string' ? raw.fortune_summary : null,
    enhancement_method: typeof raw.enhancement_method === 'string' ? raw.enhancement_method : null,
  };
}
