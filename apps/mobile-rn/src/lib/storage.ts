import {
  deepLinkConfig,
  emptyUnifiedOnboardingProgress,
  fortuneTypesById,
  mergeUnifiedOnboardingProgress,
  normalizeFortuneTypeForChat,
  normalizeUnifiedOnboardingProgress,
  unifiedOnboardingProgressStorageKey,
  type FortuneTypeId,
  type UnifiedOnboardingProgress,
} from '@fortune/product-contracts';

import {
  emptyMobileAppState,
  mergeMobileAppState,
  mobileAppStateStorageKey,
  normalizeMobileAppState,
  type MobileAppState,
} from './mobile-app-state';
import {
  deleteSecureItem,
  getSecureItem,
  setSecureItem,
} from './secure-store-storage';

const guestMobileAppStateStorageKey = `${mobileAppStateStorageKey}.guest`;
const lastAuthenticatedUserIdStorageKey = 'fortune.last-auth-user-id.v1';

function resolveMobileAppStateStorageKey(userId: string | null = null) {
  if (!userId) {
    return guestMobileAppStateStorageKey;
  }

  return `${mobileAppStateStorageKey}.${userId}`;
}

export async function getUnifiedOnboardingProgress(): Promise<UnifiedOnboardingProgress> {
  const raw = await getSecureItem(unifiedOnboardingProgressStorageKey);

  if (!raw) {
    return emptyUnifiedOnboardingProgress;
  }

  try {
    return normalizeUnifiedOnboardingProgress(
      JSON.parse(raw) as Record<string, unknown>,
    );
  } catch {
    return emptyUnifiedOnboardingProgress;
  }
}

export async function saveUnifiedOnboardingProgress(
  progress: UnifiedOnboardingProgress,
) {
  await setSecureItem(
    unifiedOnboardingProgressStorageKey,
    JSON.stringify(progress),
  );

  return progress;
}

export async function patchUnifiedOnboardingProgress(
  patch: Partial<UnifiedOnboardingProgress>,
) {
  const current = await getUnifiedOnboardingProgress();
  const next = mergeUnifiedOnboardingProgress(current, patch);

  await saveUnifiedOnboardingProgress(next);

  return next;
}

export async function clearUnifiedOnboardingProgress() {
  await deleteSecureItem(unifiedOnboardingProgressStorageKey);
}

export async function getPendingChatFortuneType(): Promise<FortuneTypeId | null> {
  const raw = await getSecureItem(
    deepLinkConfig.pendingFortuneTypeStorageKey,
  );
  const normalized = normalizeFortuneTypeForChat(raw);

  if (!normalized) {
    return null;
  }

  return normalized in fortuneTypesById ? normalized : null;
}

export async function setPendingChatFortuneType(
  fortuneType: FortuneTypeId | null,
) {
  if (!fortuneType) {
    await deleteSecureItem(deepLinkConfig.pendingFortuneTypeStorageKey);
    return;
  }

  await setSecureItem(
    deepLinkConfig.pendingFortuneTypeStorageKey,
    fortuneType,
  );
}

export async function getMobileAppState(
  userId: string | null = null,
): Promise<MobileAppState> {
  const raw = await getSecureItem(
    resolveMobileAppStateStorageKey(userId),
  );

  if (!raw) {
    return emptyMobileAppState;
  }

  try {
    return normalizeMobileAppState(
      JSON.parse(raw) as Record<string, unknown>,
    );
  } catch {
    return emptyMobileAppState;
  }
}

export async function saveMobileAppState(
  state: MobileAppState,
  userId: string | null = null,
) {
  await setSecureItem(
    resolveMobileAppStateStorageKey(userId),
    JSON.stringify(state),
  );
  return state;
}

export async function patchMobileAppState(
  patch: Partial<MobileAppState>,
  userId: string | null = null,
) {
  const current = await getMobileAppState(userId);
  const next = mergeMobileAppState(current, patch);

  await saveMobileAppState(next, userId);
  return next;
}

export async function clearMobileAppState(userId: string | null = null) {
  await deleteSecureItem(resolveMobileAppStateStorageKey(userId));
}

export async function getLastAuthenticatedUserId() {
  const value = await getSecureItem(lastAuthenticatedUserIdStorageKey);
  return typeof value === 'string' && value.length > 0 ? value : null;
}

export async function saveLastAuthenticatedUserId(userId: string) {
  await setSecureItem(lastAuthenticatedUserIdStorageKey, userId);
}
