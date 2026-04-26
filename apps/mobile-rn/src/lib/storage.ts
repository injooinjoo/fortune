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

const chatLastSeenStorageKey = 'fortune.chat-last-seen.v1';

/**
 * 각 캐릭터 채팅에서 "유저가 마지막으로 본 메시지 id"를 기록. 목록 화면의
 * unread 판단용.
 */
export async function getChatLastSeenByCharacterId(): Promise<
  Record<string, string>
> {
  const raw = await getSecureItem(chatLastSeenStorageKey);
  if (!raw) return {};
  try {
    const parsed = JSON.parse(raw);
    if (parsed && typeof parsed === 'object' && !Array.isArray(parsed)) {
      const result: Record<string, string> = {};
      for (const [key, value] of Object.entries(parsed)) {
        if (typeof value === 'string') result[key] = value;
      }
      return result;
    }
  } catch {
    // invalid JSON - reset
  }
  return {};
}

// 단일 SecureStore 키에 read-modify-write 하므로 빠르게 연속 호출되면
// (예: AI 멀티 세그먼트 도착 + 캐릭터 진입 동시 발생) 마지막 write 가 이전
// write 의 stale snapshot 위에 덮어쓰여 일부 캐릭터 의 lastSeen 이 사라질
// 수 있다. 모듈 레벨 큐로 직렬화해서 last-write-wins 가 아닌 sequential
// merge 를 보장.
let chatLastSeenWriteQueue: Promise<Record<string, string>> = Promise.resolve(
  {},
);

export async function setChatLastSeenForCharacter(
  characterId: string,
  messageId: string,
): Promise<Record<string, string>> {
  // 이전 write 가 끝난 뒤에만 새 read-modify-write 를 시작한다.
  // 이전 write 가 reject 됐어도 다음 write 는 진행해야 하므로 catch 로 흡수.
  const next = chatLastSeenWriteQueue.then(
    async () => {
      const current = await getChatLastSeenByCharacterId();
      const merged = { ...current, [characterId]: messageId };
      await setSecureItem(chatLastSeenStorageKey, JSON.stringify(merged));
      return merged;
    },
    async () => {
      // 이전 큐가 실패했더라도 새 write 는 fresh read 로 시작.
      const current = await getChatLastSeenByCharacterId();
      const merged = { ...current, [characterId]: messageId };
      await setSecureItem(chatLastSeenStorageKey, JSON.stringify(merged));
      return merged;
    },
  );
  chatLastSeenWriteQueue = next;
  return next;
}
