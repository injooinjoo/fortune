/**
 * character-conversation-cache.ts
 *
 * 채팅 메시지의 로컬 영속화 facade. Native(iOS / Android)에서는 SQLite
 * (`chat-db.ts`) 로 위임하고, web 에서는 기존 SecureStore (localStorage)
 * 폴백을 그대로 사용한다.
 *
 * 호출부 의미는 그대로: `saveCachedCharacterMessages(id, messages)` 는
 * "이 캐릭터의 현재 메시지 배열을 영속화" — 호출부에선 SQLite/SecureStore
 * 차이를 신경 쓰지 않는다.
 *
 * 주의: 이 모듈의 save 는 INSERT OR IGNORE 의미라 새 메시지는 추가되지만
 * 사용자가 명시적으로 메시지를 삭제해 incoming 에서 빠진 id 는 디스크에서
 * 자동 제거되지 않는다 (이전 SecureStore mergePreservingHistory 와 동일한
 * 제약). 명시 삭제가 필요하면 `deleteCachedCharacterMessage` 를 별도 호출.
 */

import {
  appendMessages,
  deleteMessage as deleteMessageInDb,
  isChatDbAvailable,
  loadMessagesForCharacter,
  loadMessagesForCharactersBatch,
} from './chat-db';
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
  if (isChatDbAvailable) {
    const messages = await loadMessagesForCharacter(characterId);
    return messages.length > 0 ? messages : null;
  }
  return getCachedCharacterMessagesFromSecureStore(characterId);
}

export async function saveCachedCharacterMessages(
  characterId: string,
  messages: ChatShellMessage[],
): Promise<void> {
  if (isChatDbAvailable) {
    // SQLite 는 INSERT OR IGNORE 라 race condition 에 자연 저항. 별도 큐 불필요.
    // SQLite 트랜잭션이 atomic.
    await appendMessages(characterId, messages);
    return;
  }
  await saveCachedCharacterMessagesToSecureStore(characterId, messages);
}

export async function loadCachedCharacterMessagesBatch(
  characterIds: readonly string[],
): Promise<Record<string, ChatShellMessage[]>> {
  if (isChatDbAvailable) {
    return loadMessagesForCharactersBatch(characterIds);
  }
  const entries = await Promise.all(
    characterIds.map(async (id) => {
      const messages = await getCachedCharacterMessagesFromSecureStore(id);
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

/**
 * 명시적 단일 메시지 삭제. 사용자가 자기 메시지를 길게 누르고 삭제할 때 등.
 * SQLite 에선 row 직접 DELETE, web 에선 현재 캐시 읽어 filter 후 다시 save.
 */
export async function deleteCachedCharacterMessage(
  characterId: string,
  messageId: string,
): Promise<void> {
  if (isChatDbAvailable) {
    await deleteMessageInDb(characterId, messageId);
    return;
  }
  const existing = await getCachedCharacterMessagesFromSecureStore(characterId);
  if (!existing) return;
  const next = existing.filter((m) => m.id !== messageId);
  await saveCachedCharacterMessagesToSecureStore(characterId, next, {
    forceReplace: true,
  });
}

// ---------------------------------------------------------------------------
// Web fallback (SecureStore = localStorage on web)
//
// 기존 chunked SecureStore 구현을 그대로 유지. 수백 개 메시지를 매번 직렬화
// 하는 비효율은 남지만 web 에선 채팅 사용 빈도가 낮고, expo-sqlite web 셋업
// (WASM) 은 별도 작업 영역으로 미루고 싶어서 의도적으로 단순화.
// ---------------------------------------------------------------------------

async function getCachedCharacterMessagesFromSecureStore(
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
    captureError(error, {
      surface: 'chat:cache-messages-parse',
    }).catch(() => undefined);
  }
  return null;
}

// Per-character write queue. 동일 캐릭터에 대한 read-modify-write 를 직렬화해
// AI 멀티 세그먼트 도착 + 사용자 send + 캐릭터 진입이 동시에 일어날 때 일부
// 메시지가 stale snapshot 위에 덮어써지는 race 를 차단한다. native 는 SQLite
// 트랜잭션이 처리하므로 이 큐는 web 전용.
const messageWriteQueues = new Map<string, Promise<unknown>>();

async function saveCachedCharacterMessagesToSecureStore(
  characterId: string,
  messages: ChatShellMessage[],
  options?: { forceReplace?: boolean },
): Promise<void> {
  const prev = messageWriteQueues.get(characterId) ?? Promise.resolve();
  const next = prev.then(persist, persist);
  messageWriteQueues.set(characterId, next);
  await next;

  async function persist(): Promise<void> {
    if (options?.forceReplace) {
      await setSecureItem(cacheKey(characterId), JSON.stringify(messages));
      return;
    }
    const existing = await getCachedCharacterMessagesFromSecureStore(
      characterId,
    );
    const merged = mergePreservingHistory(existing, messages);
    await setSecureItem(cacheKey(characterId), JSON.stringify(merged));
  }
}

/**
 * Web 전용 — SecureStore 캐시에 in-flight 손실이 일어나지 않도록 머지.
 * - existing 이 없거나 짧으면 → 새 messages 그대로
 * - incoming 이 existing 보다 짧으면 → existing 보존 + incoming 의 새 id 만 append
 *   (bootstrap preload 전 stale 상태로 save 되어도 과거 보존)
 *
 * 의도적 삭제는 처리 안 함 — `deleteCachedCharacterMessage` 를 따로 호출.
 */
function mergePreservingHistory(
  existing: ChatShellMessage[] | null,
  incoming: ChatShellMessage[],
): ChatShellMessage[] {
  if (!existing || existing.length === 0) return incoming;
  if (incoming.length >= existing.length) return incoming;
  const existingIds = new Set(existing.map((m) => m.id));
  if (incoming.every((m) => existingIds.has(m.id))) {
    return existing;
  }
  const tail = incoming.filter((m) => !existingIds.has(m.id));
  return [...existing, ...tail];
}
