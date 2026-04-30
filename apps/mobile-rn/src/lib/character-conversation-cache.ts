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

// Per-character write queue. 동일 캐릭터에 대한 read-modify-write 를 직렬화해
// AI 멀티 세그먼트 도착 + 사용자 send + 캐릭터 진입이 동시에 일어날 때 일부
// 메시지가 stale snapshot 위에 덮어써지는 race 를 차단한다. `storage.ts` 의
// `chatLastSeenWriteQueue` 와 동일한 패턴 — 모듈 레벨 큐로 마지막 write 가
// 끝난 뒤에만 다음 write 가 시작되도록 강제.
const messageWriteQueues = new Map<string, Promise<unknown>>();

export async function saveCachedCharacterMessages(
  characterId: string,
  messages: ChatShellMessage[],
): Promise<void> {
  // 무음 fail 금지 — caller (`saveStoryThreadSnapshot` 등) 가 .catch 로
  // captureError 를 surface 하므로 여기선 throw 까지 흘려보낸다.
  // 이전에 `try/catch {}` 로 삼키고 있어서 디스크 쓰기 실패가 사용자 화면
  // 에선 "다음 cold start 에 인트로만 보임" 으로 나타나지만 진단 불가능
  // 했던 회귀의 원인이었음.
  //
  // Destructive overwrite 가드: chat-screen 이 bootstrap preload 보다 먼저
  // mount 되어 인트로 fallback 상태로 첫 메시지를 보내면, 메모리 state 는
  // [intro, newMsg] 가 되고 이대로 디스크에 write 되면 기존에 캐시돼있던
  // 더 긴 과거 대화가 사라진다. 디스크에 기존 더 긴 캐시가 남아있고 그
  // prefix 가 새 메시지의 prefix 와 충돌하지 않으면 merge 해서 과거를 보존.
  // 정상 시나리오 (사용자 메시지 삭제 후 짧아진 경우) 도 id 매칭으로 구분.
  const prev = messageWriteQueues.get(characterId) ?? Promise.resolve();
  // 이전 큐가 reject 됐어도 다음 write 는 진행해야 한다 — fresh read 로
  // 시작하므로 데이터 일관성은 깨지지 않음.
  const next = prev.then(persist, persist);
  messageWriteQueues.set(characterId, next);
  await next;

  async function persist(): Promise<void> {
    const existing = await getCachedCharacterMessages(characterId);
    const merged = mergePreservingHistory(existing, messages);
    await setSecureItem(cacheKey(characterId), JSON.stringify(merged));
  }
}

/**
 * 디스크 캐시에 in-flight 손실이 일어나지 않도록 머지.
 * - existing 이 없거나 짧으면 → 새 messages 그대로
 * - existing 이 더 긴데 messages 가 existing 의 strict prefix 도 아니면 → merge:
 *   existing 끝부분에서 messages 와 같은 id 를 찾아 그 이후만 append.
 *   못 찾으면 existing 을 베이스로 두고 messages 의 새 id 만 append (방어적).
 * - 사용자가 명시적으로 메시지를 삭제해서 messages 가 짧은 케이스도 자연
 *   처리됨: existing 은 삭제된 id 를 포함하므로 merge 결과가 existing 과
 *   동일해지고, 다음 save 사이클에서 캐시는 변하지 않은 채 유지된다.
 *   (의도적 삭제는 messages 에 없는 id 를 별도 처리 안 하므로 디스크에는
 *   삭제 전 상태가 남는다 — 의도와 다르다면 deleteCachedCharacterMessages
 *   를 따로 호출하는 패턴으로 돌아가야 함.)
 */
function mergePreservingHistory(
  existing: ChatShellMessage[] | null,
  incoming: ChatShellMessage[],
): ChatShellMessage[] {
  if (!existing || existing.length === 0) return incoming;
  if (incoming.length >= existing.length) return incoming;
  const incomingIds = new Set(incoming.map((m) => m.id));
  const existingIds = new Set(existing.map((m) => m.id));
  // incoming 이 existing 의 strict prefix (모든 incoming id 가 existing
  // 안에 있고, 순서도 같음) 이면 사용자가 그냥 같은 대화에 새 메시지를
  // 추가한 것 — incoming 이 짧을 리 없으니 사실 도달 불가. 안전상 fallthrough.
  if (incoming.every((m) => existingIds.has(m.id))) {
    // incoming 이 모두 existing 안에 있다 = incoming 은 existing 의 부분.
    // existing 을 보존하고 incoming 의 새 id 만 끝에 append. 단 incoming 이
    // 부분집합이면 새 id 가 없으니 existing 그대로.
    return existing;
  }
  const tail = incoming.filter((m) => !existingIds.has(m.id));
  return [...existing, ...tail];
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
