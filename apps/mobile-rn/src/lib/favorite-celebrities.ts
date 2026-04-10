/**
 * Favorite celebrities storage — persists via SecureStore.
 */

import { getSecureItem, setSecureItem, deleteSecureItem } from './secure-store-storage';

const STORAGE_KEY = 'fortune.favorite-celebrities.v1';

export interface FavoriteCelebrity {
  name: string;
  addedAt: string;
  lastMode?: string;
  lastReason?: string;
}

export async function loadFavoriteCelebrities(): Promise<FavoriteCelebrity[]> {
  try {
    const raw = await getSecureItem(STORAGE_KEY);
    if (!raw) return [];
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? parsed.filter(isValid) : [];
  } catch {
    return [];
  }
}

export async function saveFavoriteCelebrity(celeb: FavoriteCelebrity): Promise<FavoriteCelebrity[]> {
  const current = await loadFavoriteCelebrities();
  const exists = current.findIndex((c) => c.name === celeb.name);
  if (exists >= 0) {
    current[exists] = { ...current[exists], ...celeb };
  } else {
    current.unshift(celeb);
  }
  // Max 20
  const trimmed = current.slice(0, 20);
  await setSecureItem(STORAGE_KEY, JSON.stringify(trimmed));
  return trimmed;
}

export async function removeFavoriteCelebrity(name: string): Promise<FavoriteCelebrity[]> {
  const current = await loadFavoriteCelebrities();
  const next = current.filter((c) => c.name !== name);
  if (next.length === 0) {
    await deleteSecureItem(STORAGE_KEY);
  } else {
    await setSecureItem(STORAGE_KEY, JSON.stringify(next));
  }
  return next;
}

function isValid(value: unknown): value is FavoriteCelebrity {
  if (typeof value !== 'object' || value === null) return false;
  const r = value as Record<string, unknown>;
  return typeof r.name === 'string' && typeof r.addedAt === 'string';
}
