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

import { useEffect, useState } from 'react';

import {
  appendMessages as dbAppendMessages,
  deleteMessage as dbDeleteMessage,
  isChatDbAvailable,
  loadMessagesForCharacter,
  loadMessagesForCharactersBatch,
  replaceAllMessages as dbReplaceAllMessages,
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
 * 미읽음 user kind='text' 메시지 전부에 readAt 마킹 — 메모리 + listener notify.
 * SQLite update 는 fire-and-forget (다음 hydrate 시 반영). chat-screen 의
 * markUserMessageReadImmediately 보완 — useState 마킹과 동일 시점에 store 도.
 *
 * 메신저 표준: AI 답장 시작 = 그 전 user 메시지들 일괄 읽음.
 */
export function markUserMessagesAsReadInStore(
  characterId: string,
  readAt: string = new Date().toISOString(),
): void {
  const entry = cacheByCharacter.get(characterId);
  if (!entry) return;
  let patched = false;
  const next = entry.messages.map((m) => {
    if (m.kind === 'text' && m.sender === 'user' && !m.readAt) {
      patched = true;
      return { ...m, readAt };
    }
    return m;
  });
  if (!patched) return;
  entry.messages = next;
  notifyListeners(entry);
  // SQLite 는 readAt 컬럼 없음 — 다음 appendMessages 가 payload_json 으로 통째
  // 갱신 시 함께 영속화. read receipt 는 transient 라 강한 영속화 불필요.
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
 */
export function getMessages(characterId: string): ChatShellMessage[] {
  return cacheByCharacter.get(characterId)?.messages ?? [];
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
 *   const messages = useStoreMessages(characterId);
 *
 * 반환값은 캐릭터 메시지 배열. store 변경 시 자동 re-render.
 * 첫 호출 시 캐시가 비어있으면 hydrate 자동 트리거.
 */
export function useStoreMessages(
  characterId: string | null | undefined,
): ChatShellMessage[] {
  const [messages, setMessages] = useState<ChatShellMessage[]>(() =>
    characterId ? getMessages(characterId) : [],
  );

  useEffect(() => {
    if (!characterId) {
      setMessages([]);
      return;
    }
    // 즉시 현재 캐시 반영 (캐릭터 변경 시).
    setMessages(getMessages(characterId));
    // 백그라운드 hydrate (이미 hydrate 됐으면 no-op).
    hydrateCharacter(characterId).catch(() => undefined);
    // subscribe — store 변경 시 자동 re-render.
    const unsubscribe = subscribe(characterId, (next) => {
      setMessages(next);
    });
    return unsubscribe;
  }, [characterId]);

  return messages;
}

/**
 * 테스트용 — 캐시 전체 초기화. dev-tools / factory-reset 에서 호출.
 */
export function resetStore(): void {
  cacheByCharacter.forEach((entry) => entry.listeners.clear());
  cacheByCharacter.clear();
}
