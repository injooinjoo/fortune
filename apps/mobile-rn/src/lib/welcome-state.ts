/**
 * Welcome-seen persistence.
 *
 * The codebase already uses `expo-secure-store` (wrapped by
 * `secure-store-storage.ts`) for local key/value persistence — there is no
 * AsyncStorage dependency. We reuse that wrapper here so we stay consistent
 * with existing call sites (favorites, chat persona, etc.) and avoid adding
 * a new storage dep.
 *
 * The key is versioned (`:v1`) so we can bump the onboarding flow without
 * leaking stale state from older installs.
 */

import { getSecureItem, setSecureItem } from './secure-store-storage';

export const WELCOME_SEEN_KEY = 'ondo.welcome-seen.v1';

export async function readWelcomeSeen(): Promise<boolean> {
  try {
    const raw = await getSecureItem(WELCOME_SEEN_KEY);
    return raw === '1';
  } catch {
    // Defensive: treat any storage error as "not seen" so the user still
    // gets the onboarding experience rather than silently skipping it.
    return false;
  }
}

export async function markWelcomeSeen(): Promise<void> {
  try {
    await setSecureItem(WELCOME_SEEN_KEY, '1');
  } catch {
    // Non-fatal — the worst case is the welcome screen shows again next
    // launch, which is strictly better than blocking navigation here.
  }
}
