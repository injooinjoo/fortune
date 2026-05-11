/**
 * MessageStore — 단일 source of truth for chat messages.
 *
 * 진단: 1.0.11 production 코드는 메시지를 5개 read 진입점 (bootstrap preload,
 * useState 초기화, useFocusEffect hydrate, story-runtime 메모리 snapshot, 원격
 * load) + 4개 write 진입점 (chat-screen send / appendMessages / saveStoryThread /
 * survey/result/image append) 으로 산발 처리. setMessagesByCharacterId 호출이
 * 40+ 곳에 흩어져 있고, push 도착 시 메시지 본문 INSERT 경로 자체가 부재
 * (ack 만 호출). 결과적으로 같은 캐릭터 메시지가 메모리/SQLite/SecureStore/
 * Supabase 4개 store 에서 따로 관리됨.
 *
 * 해결 (Telegram TDLib / Signal Desktop / WhatsApp 표준):
 *   - 단일 진입점: 모든 read/write 가 MessageStore 만 거침.
 *   - source of truth: SQLite (chat-db.ts wrap). 메모리는 캐시.
 *   - observable: subscribe(characterId, listener) 로 push/send/sync 어느
 *     채널이든 store 가 변경되면 listener (= React hook) 가 자동 reflect.
 *   - 멱등성: INSERT OR IGNORE (id 기반) — push + 직접 send 가 같은 메시지를
 *     보내도 1번만. WhatsApp/Signal 의 client-generated UUID dedup 표준.
 *   - native-only: web 은 character-conversation-cache.ts (SecureStore) 폴백
 *     유지. isChatDbAvailable false 면 store 가 silently no-op.
 *
 * 비-목표 (Phase 2+ 에서 처리):
 *   - 신규 native module 도입 (WatermelonDB / Drizzle reactive query) — 안 함.
 *     expo-sqlite + 자체 emitter 로 충분, runtimeVersion bump 회피.
 *   - chat-screen.tsx 3000+ 줄 분해 — 별도 작업.
 *   - 서버 사이드 통합 (character-chat / deliver-due-replies / proactive-message-
 *     dispatch 3개를 1개로) — 다음 단계.
 */

import { useEffect, useMemo, useState } from 'react';

import {
  appendMessages as dbAppendMessages,
  deleteMessage as dbDeleteMessage,
  isChatDbAvailable,
  loadMessagesForCharacter,
  loadMessagesForCharactersBatch,
  replaceAllMessages as dbReplaceAllMessages,
  updateMessage as dbUpdateMessage,
} from './chat-db';
import type { ChatShellMessage } from './chat-shell';
import { captureError } from './error-reporting';

type Listener = (messages: ChatShellMessage[]) => void;

interface CharacterEntry {
  /** 마지막으로 listener 에게 전달한 배열. 동일 참조면 React 가 skip. */
  messages: ChatShellMessage[];
  /** 이 캐릭터를 구독 중인 React hook 들. */
  listeners: Set<Listener>;
  /** SQLite hydrate 완료 여부. true 면 cold-load 다시 안 함. */
  hydrated: boolean;
}

/**
 * 캐릭터별 메시지 캐시 + 구독자. Module-scope singleton — 앱 전체 1개.
 *
 * 메모리 사용량: 캐릭터 N명 × 메시지 200개 × 평균 1KB ≈ N × 200KB. 22명 ×
 * 200KB = 4.4MB. 메신저 앱 표준 (WhatsApp 단일 conversation 100MB+) 대비 작음.
 */
const cacheByCharacter = new Map<string, CharacterEntry>();

function getOrCreateEntry(characterId: string): CharacterEntry {
  let entry = cacheByCharacter.get(characterId);
  if (!entry) {
    entry = { messages: [], listeners: new Set(), hydrated: false };
    cacheByCharacter.set(characterId, entry);
  }
  return entry;
}

function notifyListeners(entry: CharacterEntry): void {
  // React batches setState — 같은 frame 안 다중 호출은 1회 렌더로 모임.
  entry.listeners.forEach((listener) => {
    try {
      listener(entry.messages);
    } catch (error) {
      captureError(error, {
        surface: 'message-store:listener',
      }).catch(() => undefined);
    }
  });
}

function dedupAppend(
  existing: ChatShellMessage[],
  incoming: readonly ChatShellMessage[],
): { merged: ChatShellMessage[]; addedCount: number } {
  if (incoming.length === 0) return { merged: existing, addedCount: 0 };
  const existingIds = new Set(existing.map((m) => m.id));
  const newOnly = incoming.filter((m) => !existingIds.has(m.id));
  if (newOnly.length === 0) return { merged: existing, addedCount: 0 };
  return { merged: [...existing, ...newOnly], addedCount: newOnly.length };
}

/**
 * 한 캐릭터 + 신규 메시지(들) 을 store 에 INSERT. 멱등 (같은 id 재 insert 무시).
 *
 * 호출 경로:
 *   - chat-screen send: 사용자 메시지 optimistic insert (서버 응답 대기 X)
 *   - chat-screen receive: 캐릭터 응답 도착 시
 *   - push handler onForegroundReceive/onTap: cron 발송 메시지 본문 도착 시
 *   - bootstrap loadBatch: 콜드 스타트 시 SQLite 에서 hydrate
 *
 * SQLite 쓰기는 fire-and-forget. 메모리 + listener 통지가 먼저, 디스크 영속화는
 * 백그라운드. 이게 메신저의 "send 즉시 표시" 비결 — 디스크 wait 0.
 */
export async function insertMessages(
  characterId: string,
  messages: readonly ChatShellMessage[],
): Promise<{ addedCount: number }> {
  if (messages.length === 0) return { addedCount: 0 };
  const entry = getOrCreateEntry(characterId);
  const { merged, addedCount } = dedupAppend(entry.messages, messages);
  if (addedCount === 0) return { addedCount: 0 };
  entry.messages = merged;
  notifyListeners(entry);
  // SQLite append (fire-and-forget). 실패해도 메모리에는 남아있어 같은 세션
  // 동안은 동작. 다음 cold start 시 미반영될 위험은 captureError 로 추적.
  if (isChatDbAvailable) {
    dbAppendMessages(characterId, messages).catch((error: unknown) => {
      captureError(error, {
        surface: 'message-store:db-append',
      }).catch(() => undefined);
    });
  }
  return { addedCount };
}

/**
 * 캐릭터의 메시지를 SQLite 에서 load 하여 store 캐시 hydrate.
 * - 이미 hydrate 됐으면 재호출 no-op (force=true 면 재로드)
 * - cold start 시 chat-screen 진입 즉시 호출하면 SQLite read latency 만 부담
 *   (메신저 표준 — 네트워크 0)
 *
 * Web 환경 (isChatDbAvailable=false) 은 빈 배열로 두고 호출자가 character-
 * conversation-cache.ts 의 SecureStore 폴백을 별도 사용하도록 (현재 구조 유지).
 */
export async function hydrateCharacter(
  characterId: string,
  options?: { force?: boolean },
): Promise<ChatShellMessage[]> {
  const entry = getOrCreateEntry(characterId);
  if (entry.hydrated && !options?.force) return entry.messages;
  if (!isChatDbAvailable) {
    entry.hydrated = true;
    return entry.messages;
  }
  try {
    const loaded = await loadMessagesForCharacter(characterId);
    entry.messages = loaded;
    entry.hydrated = true;
    notifyListeners(entry);
    return loaded;
  } catch (error) {
    captureError(error, {
      surface: 'message-store:hydrate',
    }).catch(() => undefined);
    return entry.messages;
  }
}

/**
 * 여러 캐릭터를 한 번에 hydrate. bootstrap preload 가 호출.
 * 트랜잭션 1번이라 N명 캐릭터 × N개 row 도 single SQL round-trip.
 */
export async function hydrateBatch(
  characterIds: readonly string[],
): Promise<Record<string, ChatShellMessage[]>> {
  if (characterIds.length === 0) return {};
  if (!isChatDbAvailable) {
    characterIds.forEach((id) => {
      const entry = getOrCreateEntry(id);
      entry.hydrated = true;
    });
    return {};
  }
  try {
    const batch = await loadMessagesForCharactersBatch(characterIds);
    for (const id of characterIds) {
      const entry = getOrCreateEntry(id);
      entry.messages = batch[id] ?? [];
      entry.hydrated = true;
      notifyListeners(entry);
    }
    return batch;
  } catch (error) {
    captureError(error, {
      surface: 'message-store:hydrate-batch',
    }).catch(() => undefined);
    return {};
  }
}

/**
 * 캐릭터의 메시지 배열 전체를 새 배열로 교체. 원격 hydrate (Supabase 에서
 * 받은 character_conversations.messages) 가 로컬보다 길 때 사용.
 *
 * 일반 send/receive 흐름에서 쓰지 말 것 (전체 직렬화 모델로 회귀).
 * dedupAppend 만으로 충분한 경우 insertMessages 사용.
 */
export async function replaceAllForCharacter(
  characterId: string,
  messages: readonly ChatShellMessage[],
): Promise<void> {
  const entry = getOrCreateEntry(characterId);
  entry.messages = [...messages];
  entry.hydrated = true;
  notifyListeners(entry);
  if (isChatDbAvailable) {
    dbReplaceAllMessages(characterId, messages).catch((error: unknown) => {
      captureError(error, {
        surface: 'message-store:db-replace',
      }).catch(() => undefined);
    });
  }
}

/**
 * 메시지 1개 제거 — id 로 찾아서 store + SQLite 양쪽에서 삭제.
 * 없으면 no-op (false 반환).
 *
 * 사용처: chat-screen handleDeleteUserMessage. 사용자가 자기 메시지 long-press
 * → 삭제. assistant/system 은 일반적으로 삭제 X (메신저 표준).
 */
export function deleteMessage(
  characterId: string,
  messageId: string,
): boolean {
  const entry = cacheByCharacter.get(characterId);
  if (!entry) return false;
  const idx = entry.messages.findIndex((m) => m.id === messageId);
  if (idx < 0) return false;
  const newArray = entry.messages.slice();
  newArray.splice(idx, 1);
  entry.messages = newArray;
  notifyListeners(entry);
  if (isChatDbAvailable) {
    dbDeleteMessage(characterId, messageId).catch((error: unknown) => {
      captureError(error, {
        surface: 'message-store:db-delete',
      }).catch(() => undefined);
    });
  }
  return true;
}

/**
 * 미읽음 user kind='text' 메시지 전부에 readAt 마킹 — 메모리 + listener notify
 * + SQLite payload_json UPDATE.
 *
 * Bug 1 회귀 방지: 이전 구현은 SQLite 영속화를 다음 appendMessages 에 위임
 * 했으나, appendMessages 는 INSERT OR IGNORE 라 기존 row 의 payload_json 을
 * 갱신하지 않는다. 결과적으로 readAt 이 메모리에만 살고 다음 cold start /
 * SQLite hydrate 시 사라져 사용자 메시지의 "1" 배지가 다시 나타났다.
 * 이제 readAt 패치마다 dbUpdateMessage 로 row payload_json 까지 동기화한다.
 */
export function markUserMessagesAsReadInStore(
  characterId: string,
  readAt: string = new Date().toISOString(),
): void {
  const entry = cacheByCharacter.get(characterId);
  if (!entry) return;
  let patched = false;
  const patchedMessages: ChatShellMessage[] = [];
  const next = entry.messages.map((m) => {
    if (m.kind === 'text' && m.sender === 'user' && !m.readAt) {
      patched = true;
      const updated = { ...m, readAt };
      patchedMessages.push(updated);
      return updated;
    }
    return m;
  });
  if (!patched) return;
  entry.messages = next;
  notifyListeners(entry);
  if (isChatDbAvailable && patchedMessages.length > 0) {
    // 각 패치된 user 메시지의 payload_json 을 SQLite 에서 갱신.
    // appendMessages 는 INSERT OR IGNORE 라 기존 row 갱신 불가 → 반드시
    // updateMessage(UPDATE payload_json) 사용. fire-and-forget — 메모리 즉시
    // 반영, 디스크는 백그라운드. 실패해도 메모리는 살아있어 같은 세션은 OK.
    Promise.all(
      patchedMessages.map((m) =>
        dbUpdateMessage(characterId, m).catch((error: unknown) => {
          captureError(error, {
            surface: 'message-store:db-update-readAt',
          }).catch(() => undefined);
        }),
      ),
    ).catch(() => undefined);
  }
}

/**
 * 메시지 N 개 일괄 삭제 (id 리스트) — flushPendingQueue / rollback 용.
 *
 * 메모리 + listener notify + SQLite 1개씩 delete (트랜잭션 X — 빈도 낮음).
 */
export function deleteMessages(
  characterId: string,
  messageIds: readonly string[],
): number {
  if (messageIds.length === 0) return 0;
  const entry = cacheByCharacter.get(characterId);
  if (!entry) return 0;
  const idSet = new Set(messageIds);
  const remaining = entry.messages.filter((m) => !idSet.has(m.id));
  if (remaining.length === entry.messages.length) return 0;
  const removedCount = entry.messages.length - remaining.length;
  entry.messages = remaining;
  notifyListeners(entry);
  if (isChatDbAvailable) {
    Promise.all(
      messageIds.map((id) =>
        dbDeleteMessage(characterId, id).catch((error: unknown) => {
          captureError(error, {
            surface: 'message-store:db-delete-batch',
          }).catch(() => undefined);
        }),
      ),
    ).catch(() => undefined);
  }
  return removedCount;
}

/**
 * 메시지 1개 update — id 로 찾아서 callback 의 결과로 교체. 없으면 no-op.
 *
 * 사용처: readAt 마킹, status 변경 (pending→sent), animate 플래그 토글 등.
 */
export function updateMessage(
  characterId: string,
  messageId: string,
  updater: (current: ChatShellMessage) => ChatShellMessage,
): boolean {
  const entry = cacheByCharacter.get(characterId);
  if (!entry) return false;
  const idx = entry.messages.findIndex((m) => m.id === messageId);
  if (idx < 0) return false;
  const next = updater(entry.messages[idx]);
  if (next === entry.messages[idx]) return false;
  const newArray = entry.messages.slice();
  newArray[idx] = next;
  entry.messages = newArray;
  notifyListeners(entry);
  return true;
}

/**
 * 캐릭터의 현재 메시지 배열 (메모리 캐시). hydrate 안 됐으면 빈 배열.
 *
 * synchronous read — chat-screen useState 초기값 / SSR-style render 에서 사용.
 * 이게 "채팅창 진입 시 즉시 표시" 의 핵심 (네트워크/디스크 wait 0).
 *
 * 빈 배열 fallback 은 module-scope `EMPTY_MESSAGES` 싱글톤 — 호출마다 새
 * `[]` 를 만들면 호출 측 (useStoreMessages) 의 useMemo dep 가 매번 mismatch.
 */
const EMPTY_MESSAGES: ReadonlyArray<ChatShellMessage> = Object.freeze([]);

export function getMessages(characterId: string): ChatShellMessage[] {
  return (cacheByCharacter.get(characterId)?.messages
    ?? (EMPTY_MESSAGES as ChatShellMessage[]));
}

/**
 * subscribe — store 가 변할 때마다 listener 호출. unsubscribe 함수 반환.
 *
 * React hook (useStoreMessages) 에서 사용. 직접 호출하지 말 것 — hook 이 effect
 * cleanup 까지 자동 처리.
 */
export function subscribe(characterId: string, listener: Listener): () => void {
  const entry = getOrCreateEntry(characterId);
  entry.listeners.add(listener);
  return () => {
    entry.listeners.delete(listener);
    // listener 0 이어도 entry 는 유지 — 다음 구독에 같은 캐시 재사용. 메모리는
    // 캐릭터당 ~200KB 이라 22명 * 200KB = 4.4MB, 안 비움.
  };
}

/**
 * React hook — 컴포넌트가 한 캐릭터의 메시지 배열을 구독.
 *
 * 사용:
 *   const { characterId, messages } = useStoreMessages(id);
 *
 * 반환값은 `(characterId, messages)` 쌍. 캐릭터를 전환하는 순간
 * (selectedCharacterId 가 A→B 로 바뀌는 순간) 호출 측이 stale messages 를
 * 잘못된 캐릭터로 적용하는 것을 막기 위해, 첫 렌더에서 messages 와 함께
 * "이 messages 가 어느 캐릭터의 것인지" identity 도 동일 batch 로 노출한다.
 *
 * 이전 구현 (messages-only) 의 race:
 *   1) 캐릭터 A 활성, hook state = A.messages
 *   2) selectedCharacterId 가 A → B 로 변경
 *   3) 다음 render: useStoreMessages(B) 호출되지만 useState 는 여전히 A.messages
 *      를 들고 있어 stale A 데이터가 반환됨
 *   4) 호출 측 (chat-screen 의 bridge effect) 이 selectedCharacterId='B' 와
 *      stale A.messages 를 묶어서 messagesByCharacterId['B'] 에 써 넣음
 *      → 캐릭터 A 의 메시지가 캐릭터 B 의 채팅창에 누출
 *
 * 해결: hook 이 반환하는 messages 는 항상 첫 렌더부터 정확한 characterId 의
 * 캐시를 동기 read 로 가져온다. 호출 측은 반환된 characterId 가 자신이 기대한
 * id 와 일치하는지 즉시 검증할 수 있어, mismatch 시 적용을 skip 한다.
 *
 * 첫 호출 시 캐시가 비어있으면 hydrate 자동 트리거.
 */
export interface StoreMessagesSnapshot {
  /** 이 messages 가 어느 캐릭터의 것인지. null = 비활성/미선택. */
  characterId: string | null;
  messages: ChatShellMessage[];
}

export function useStoreMessages(
  characterId: string | null | undefined,
): StoreMessagesSnapshot {
  const normalizedId = characterId ?? null;
  // store 변경(push/insert)마다 forceTick 으로 re-render 유발. tick 자체는 dep
  // 으로만 쓰임 — 실제 messages 는 항상 동기 getMessages(normalizedId) 결과.
  const [tick, setTick] = useState(0);

  useEffect(() => {
    if (!normalizedId) {
      return;
    }
    // 백그라운드 hydrate (이미 hydrate 됐으면 no-op).
    hydrateCharacter(normalizedId).catch(() => undefined);
    // subscribe — store 변경 시 강제 re-render.
    const unsubscribe = subscribe(normalizedId, () => {
      setTick((t) => t + 1);
    });
    return unsubscribe;
  }, [normalizedId]);

  // 매 렌더 동기 read — characterId 가 바뀌는 순간에도 stale 한 이전 캐릭터의
  // messages 가 절대 새 characterId 와 짝지어 반환되지 않음.
  // useMemo 로 snapshot 객체 reference 안정화 — 호출 측 useEffect 의 dep array
  // 가 매 렌더 새 객체로 fire 되는 것을 방지. (characterId, messages 가 동일
  // 하면 같은 reference 반환.) `tick` 은 store 변경을 강제 trigger 하기 위해
  // dep 에 포함 — store 가 변하면 entry.messages reference 도 바뀌므로 사실상
  // 중복이지만, 명시적 의존성 표기 + 미래에 in-place mutation 도입 시 안전망.
  const messages = normalizedId
    ? getMessages(normalizedId)
    : (EMPTY_MESSAGES as ChatShellMessage[]);
  return useMemo(
    () => ({ characterId: normalizedId, messages }),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [normalizedId, messages, tick],
  );
}

/** 여러 캐릭터 메시지를 한 번에 구독하는 read hook.
 *
 * 채팅 리스트/배지/방 화면이 각자 다른 state snapshot 을 보면 push payload 는
 * 도착했는데 리스트 미리보기나 채팅방 본문이 어긋난다. 이 hook 은 MessageStore
 * 하나만 읽어서 list row, unread, active thread 가 같은 배열을 보게 한다.
 */
export function useStoreMessagesMap(
  characterIds: readonly string[],
): Record<string, ChatShellMessage[]> {
  const key = useMemo(() => characterIds.join('\u0000'), [characterIds]);
  const [tick, setTick] = useState(0);

  useEffect(() => {
    const ids = Array.from(new Set(characterIds.filter(Boolean)));
    if (ids.length === 0) return;
    hydrateBatch(ids).catch(() => undefined);
    const unsubscribers = ids.map((id) =>
      subscribe(id, () => {
        setTick((t) => t + 1);
      }),
    );
    return () => {
      unsubscribers.forEach((unsubscribe) => unsubscribe());
    };
    // `key` 는 characterIds 내용 변화만 추적한다. 배열 reference 변화만으로
    // 전체 재구독하지 않도록 한다.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [key]);

  return useMemo(() => {
    const result: Record<string, ChatShellMessage[]> = {};
    for (const id of characterIds) {
      result[id] = getMessages(id);
    }
    return result;
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [key, tick]);
}

/**
 * 테스트용 — 캐시 전체 초기화. dev-tools / factory-reset 에서 호출.
 */
export function resetStore(): void {
  cacheByCharacter.forEach((entry) => entry.listeners.clear());
  cacheByCharacter.clear();
}
