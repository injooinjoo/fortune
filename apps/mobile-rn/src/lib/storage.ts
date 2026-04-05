import * as SecureStore from 'expo-secure-store';
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

export async function getUnifiedOnboardingProgress(): Promise<UnifiedOnboardingProgress> {
  const raw = await SecureStore.getItemAsync(unifiedOnboardingProgressStorageKey);

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
  await SecureStore.setItemAsync(
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
  await SecureStore.deleteItemAsync(unifiedOnboardingProgressStorageKey);
}

export async function getPendingChatFortuneType(): Promise<FortuneTypeId | null> {
  const raw = await SecureStore.getItemAsync(
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
    await SecureStore.deleteItemAsync(deepLinkConfig.pendingFortuneTypeStorageKey);
    return;
  }

  await SecureStore.setItemAsync(
    deepLinkConfig.pendingFortuneTypeStorageKey,
    fortuneType,
  );
}
