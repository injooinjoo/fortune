/**
 * character-conversation-cache.ts
 *
 * 각 캐릭터 대화의 "마지막으로 본 상태"를 로컬 SecureStore에 저장/복원.
 *
 * 목적: 앱 재진입 시 chat 화면이 하드코딩 인트로 → 원격 로드된 실 메시지로
 * 플래시하는 old→new 전환을 제거. bootstrap에서 이 캐시를 일괄 preload 하면
 * chat-screen이 `useState` 초기값을 최신 캐시로 채울 수 있다.
 *
 * 원격 저장(`character-conversation-save` edge function)과 중복이지만 네트워크
 * 독립적인 즉시 복원용 레이어.
 */

import { captureError } from './error-reporting';
import { getSecureItem, setSecureItem } from './secure-store-storage';
import type { ChatShellMessage } from './chat-shell';

const CACHE_PREFIX = 'fortune.chat.msgs.v1';

function cacheKey(characterId: string): string {
  return `${CACHE_PREFIX}.${characterId}`;
}

export async function getCachedCharacterMessages(
  characterId: string,
): Promise<ChatShellMessage[] | null> {
  const raw = await getSecureItem(cacheKey(characterId));
  if (!raw) return null;
  try {
    const parsed = JSON.parse(raw);
    if (Array.isArray(parsed)) {
      return parsed as ChatShellMessage[];
    }
  } catch (error) {
    // 손상된 JSON — 인트로만 보이는 회귀의 원인이 될 수 있으므로 surface.
    // 호출부(`loadCachedCharacterMessagesBatch`)는 null 을 받아 fallback 경로로
    // 진입하므로 여기서는 throw 안 함.
    captureError(error, {
      surface: 'chat:cache-messages-parse',
    }).catch(() => undefined);
  }
  return null;
}

export async function saveCachedCharacterMessages(
  characterId: string,
  messages: ChatShellMessage[],
): Promise<void> {
  // 무음 fail 금지 — caller (`saveStoryThreadSnapshot` 등) 가 .catch 로
  // captureError 를 surface 하므로 여기선 throw 까지 흘려보낸다.
  // 이전에 `try/catch {}` 로 삼키고 있어서 디스크 쓰기 실패가 사용자 화면
  // 에선 "다음 cold start 에 인트로만 보임" 으로 나타나지만 진단 불가능
  // 했던 회귀의 원인이었음.
  await setSecureItem(cacheKey(characterId), JSON.stringify(messages));
}

export async function loadCachedCharacterMessagesBatch(
  characterIds: readonly string[],
): Promise<Record<string, ChatShellMessage[]>> {
  const entries = await Promise.all(
    characterIds.map(async (id) => {
      const messages = await getCachedCharacterMessages(id);
      return [id, messages] as const;
    }),
  );
  const result: Record<string, ChatShellMessage[]> = {};
  for (const [id, messages] of entries) {
    if (messages && messages.length > 0) {
      result[id] = messages;
    }
  }
  return result;
}
