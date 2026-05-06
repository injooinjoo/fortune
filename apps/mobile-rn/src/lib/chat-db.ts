/**
 * chat-db.ts
 *
 * SQLite-backed chat message persistence. WhatsApp / Signal / iMessage 등
 * 표준 채팅앱과 동일하게 메시지 1개 = row 1개를 INSERT 하는 append-only 모델.
 *
 * 이전 구현 (`character-conversation-cache.ts` + SecureStore chunked JSON):
 *   - 메시지 1개 추가 시 전체 배열을 JSON.stringify → ~1800 byte chunk 로 분할
 *     → double-buffer atomic write. 100개 메시지면 매 save 마다 수십 chunk
 *     swap, 강제 종료 / 동시 write race / partial chunk 등 실패 모드가 많았음.
 *   - 메모리 state 가 source of truth, 디스크는 reactive snapshot 이라 디스크가
 *     stale 메모리로 덮어써지는 회귀 (mergePreservingHistory 가 막는 그것).
 *
 * 새 구현:
 *   - SQLite 가 source of truth. 메시지 추가는 INSERT 1번. 전체 배열 직렬화
 *     없음 → race window 자체가 없음 (트랜잭션 단위로 atomic).
 *   - ChatShellMessage discriminated union 7종을 모두 다루기 위해 frequently
 *     queried 필드(character_id, sender, kind, created_at)만 정규화하고 나머지
 *     는 payload_json 으로 보존. 새 kind 추가 시 스키마 마이그레이션 불필요.
 *   - INSERT OR IGNORE 로 멱등성 보장 (같은 id 재 INSERT 무시).
 *
 * 1회 백필: 처음 DB 가 열릴 때 SecureStore 의 `fortune.chat.msgs.v1.*` 키를
 * 읽어 SQLite 에 INSERT 하고, 성공하면 SecureStore 키 삭제 + 마이그레이션
 * 플래그 set. 실패하면 플래그 안 찍어서 다음 cold start 에 재시도.
 *
 * Web platform: expo-sqlite 가 web 에서도 동작하지만 별도 WASM 셋업이 필요
 * 하므로 일단 native (iOS / Android) 전용. Web 은 character-conversation-cache.ts
 * 의 SecureStore (localStorage) 폴백을 그대로 사용.
 */

import * as SQLite from 'expo-sqlite';
import { Platform } from 'react-native';

import { chatCharacters } from './chat-characters';
import { captureError } from './error-reporting';
import {
  deleteSecureItem,
  getSecureItem,
  setSecureItem,
} from './secure-store-storage';
import type { ChatShellMessage } from './chat-shell';

const DB_NAME = 'fortune-chat.db';
const MIGRATION_FLAG_KEY = 'fortune.chat.db.migrated.v1';
const ANIMATE_STRIP_FLAG_KEY = 'fortune.chat.db.animate-stripped.v1';
const LEGACY_CACHE_PREFIX = 'fortune.chat.msgs.v1';

/**
 * Module-level transaction queue — expo-sqlite 의 `withTransactionAsync` 가
 * 같은 connection 에서 nested transaction 시도하면
 * "cannot start a transaction within a transaction" 으로 fail. 사용자가
 * chip 빠르게 탭하거나 append/replace/update 가 동시에 호출되면 발생.
 *
 * 모든 transaction 함수가 이 queue 를 통과하면 직렬화되어 race 0.
 * 이전 transaction 이 reject 되어도 queue 자체는 끊지 않는다.
 */
let txQueue: Promise<unknown> = Promise.resolve();

async function runTx<T>(body: () => Promise<T>): Promise<T> {
  const next = txQueue.then(() => body());
  // queue 는 다음 작업 chain 용 — body 가 throw 해도 다음 tx 는 진행되어야 함.
  txQueue = next.catch(() => undefined);
  return next;
}

/**
 * 영속 직렬화 직전에 메시지에서 transient UI 플래그를 제거.
 *
 * `animate: true` 는 "방금 생성된 어시스턴트 메시지에 일회성 fade-up 애니메이션
 * 적용" 용도의 휘발성 신호다. 디스크에 박히면 채팅방을 나갔다 다시 들어올 때
 * 마지막 메시지가 또 애니메이션되어버리므로, payload_json 으로 stringify 하기
 * 전에 false 로 강제한다. 메모리 상태(setMessagesByCharacterId 의 객체)는 건드
 * 리지 않으므로 현재 세션 동안의 신규 버블 애니메이션은 그대로 재생된다.
 */
function sanitizeForPersistence(message: ChatShellMessage): ChatShellMessage {
  if (message.kind === 'text' && message.animate) {
    return { ...message, animate: false };
  }
  return message;
}

/**
 * 영속 대상이 아닌 transient kind 식별.
 *
 * `progress` 카드는 long-running job 진행상황 표시 용도로, 결과 도착 시 결과
 * 카드로 교체되거나 사라진다. 디스크에 박히면 재진입 시 이미 끝난 작업의
 * 진행카드가 살아있는 듯 보이므로 영속 대상에서 제외한다.
 */
function isTransientKind(kind: ChatShellMessage['kind']): boolean {
  return kind === 'progress';
}

export const isChatDbAvailable = Platform.OS !== 'web';

let dbPromise: Promise<SQLite.SQLiteDatabase> | null = null;

/**
 * DB 핸들 반환. 첫 호출 시:
 *   1) 스키마 적용 (CREATE TABLE IF NOT EXISTS + index)
 *   2) 1회 백필 (SecureStore → SQLite)
 * 모두 실패해도 핸들 자체는 반환 — 백필 실패는 다음 cold start 재시도.
 */
export async function openChatDb(): Promise<SQLite.SQLiteDatabase> {
  if (!isChatDbAvailable) {
    throw new Error('chat-db is unavailable on web platform');
  }
  if (!dbPromise) {
    dbPromise = (async () => {
      const db = await SQLite.openDatabaseAsync(DB_NAME);
      await db.execAsync(`
        PRAGMA journal_mode = WAL;
        CREATE TABLE IF NOT EXISTS chat_messages (
          id TEXT PRIMARY KEY,
          character_id TEXT NOT NULL,
          kind TEXT NOT NULL,
          sender TEXT NOT NULL,
          payload_json TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          seq INTEGER NOT NULL
        );
        CREATE INDEX IF NOT EXISTS idx_chat_messages_char_seq
          ON chat_messages(character_id, seq);
      `);
      // 백필은 첫 1회만. 실패해도 throw 하지 않고 surface — 다음 cold start
      // 에 다시 시도 (멱등). 핸들 반환은 막지 않는다.
      await runOneTimeBackfill(db).catch((error: unknown) => {
        captureError(error, {
          surface: 'chat-db:backfill',
        }).catch(() => undefined);
      });
      // 1회 정리: sanitizeForPersistence 도입(2026-05-02) 이전에 박힌
      // animate:true payload 를 false 로 갱신. 신규 사용자에겐 no-op.
      await runOneTimeAnimateStrip(db).catch((error: unknown) => {
        captureError(error, {
          surface: 'chat-db:animate-strip',
        }).catch(() => undefined);
      });
      return db;
    })();
  }
  return dbPromise;
}

/**
 * 캐릭터 1개의 메시지 전체를 seq 순서로 반환. 신규 사용자 / 빈 캐릭터는 [].
 */
export async function loadMessagesForCharacter(
  characterId: string,
): Promise<ChatShellMessage[]> {
  if (!isChatDbAvailable) return [];
  const db = await openChatDb();
  const rows = await db.getAllAsync<{ payload_json: string }>(
    'SELECT payload_json FROM chat_messages WHERE character_id = ? ORDER BY seq ASC',
    [characterId],
  );
  const result: ChatShellMessage[] = [];
  for (const row of rows) {
    try {
      result.push(JSON.parse(row.payload_json) as ChatShellMessage);
    } catch (error) {
      captureError(error, {
        surface: 'chat-db:parse-row',
      }).catch(() => undefined);
    }
  }
  return result;
}

/**
 * 여러 캐릭터의 메시지를 한 번에 로드. bootstrap preload 가 사용.
 * 빈 캐릭터는 결과에 포함 안 됨 (기존 loadCachedCharacterMessagesBatch 와 동일).
 */
export async function loadMessagesForCharactersBatch(
  characterIds: readonly string[],
): Promise<Record<string, ChatShellMessage[]>> {
  if (!isChatDbAvailable || characterIds.length === 0) return {};
  const db = await openChatDb();
  const placeholders = characterIds.map(() => '?').join(', ');
  const rows = await db.getAllAsync<{
    character_id: string;
    payload_json: string;
  }>(
    `SELECT character_id, payload_json FROM chat_messages
     WHERE character_id IN (${placeholders})
     ORDER BY character_id ASC, seq ASC`,
    characterIds as unknown as string[],
  );
  const result: Record<string, ChatShellMessage[]> = {};
  for (const row of rows) {
    try {
      const message = JSON.parse(row.payload_json) as ChatShellMessage;
      const list = result[row.character_id] ?? [];
      list.push(message);
      result[row.character_id] = list;
    } catch (error) {
      captureError(error, {
        surface: 'chat-db:parse-row-batch',
      }).catch(() => undefined);
    }
  }
  return result;
}

/**
 * 메시지 N개를 트랜잭션 1번으로 append. 기존 id 충돌 시 INSERT OR IGNORE 로
 * 무시 (멱등). seq 는 현재 캐릭터의 MAX(seq) + 1 부터 단조 증가.
 *
 * createdAt: ChatShellMessage 자체에는 timestamp 가 없는 variant 가 있으므로
 * (text 메시지 등) 호출 시점의 Date.now() 를 사용. 메시지 순서는 seq 가
 * 결정하므로 created_at 은 보조 정보.
 */
export async function appendMessages(
  characterId: string,
  messages: readonly ChatShellMessage[],
): Promise<void> {
  if (!isChatDbAvailable || messages.length === 0) return;
  const db = await openChatDb();
  await runTx(() => db.withTransactionAsync(async () => {
    const maxRow = await db.getFirstAsync<{ max_seq: number | null }>(
      'SELECT MAX(seq) AS max_seq FROM chat_messages WHERE character_id = ?',
      [characterId],
    );
    let nextSeq = (maxRow?.max_seq ?? 0) + 1;
    const now = Date.now();
    for (const message of messages) {
      if (isTransientKind(message.kind)) continue;
      const sanitized = sanitizeForPersistence(message);
      await db.runAsync(
        `INSERT OR IGNORE INTO chat_messages
           (id, character_id, kind, sender, payload_json, created_at, seq)
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
          sanitized.id,
          characterId,
          sanitized.kind,
          sanitized.sender,
          JSON.stringify(sanitized),
          now,
          nextSeq,
        ],
      );
      nextSeq += 1;
    }
  }));
}

/**
 * 캐릭터의 메시지 전체를 새 배열로 교체. 원격 hydrate 로 전체 스냅샷을 받아
 * 갈아끼울 때 사용. 트랜잭션 1번 — 중간에 crash 나도 부분 상태 안 남음.
 *
 * 일반 send/receive 흐름에서는 쓰지 말 것 (전체 직렬화 모델로 회귀). 대신
 * `appendMessages` 사용.
 */
export async function replaceAllMessages(
  characterId: string,
  messages: readonly ChatShellMessage[],
): Promise<void> {
  if (!isChatDbAvailable) return;
  const db = await openChatDb();
  await runTx(() => db.withTransactionAsync(async () => {
    await db.runAsync('DELETE FROM chat_messages WHERE character_id = ?', [
      characterId,
    ]);
    let seq = 1;
    const now = Date.now();
    for (const message of messages) {
      if (isTransientKind(message.kind)) continue;
      const sanitized = sanitizeForPersistence(message);
      await db.runAsync(
        `INSERT INTO chat_messages
           (id, character_id, kind, sender, payload_json, created_at, seq)
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
          sanitized.id,
          characterId,
          sanitized.kind,
          sanitized.sender,
          JSON.stringify(sanitized),
          now,
          seq,
        ],
      );
      seq += 1;
    }
  }));
}

/**
 * 단일 메시지의 payload_json 을 갱신. text 메시지의 readAt 같은 필드가 사후
 * 변경될 때 사용. 메시지 자체가 없으면 no-op.
 */
export async function updateMessage(
  characterId: string,
  message: ChatShellMessage,
): Promise<void> {
  if (!isChatDbAvailable) return;
  if (isTransientKind(message.kind)) return;
  const db = await openChatDb();
  const sanitized = sanitizeForPersistence(message);
  await db.runAsync(
    `UPDATE chat_messages SET payload_json = ?
     WHERE id = ? AND character_id = ?`,
    [JSON.stringify(sanitized), sanitized.id, characterId],
  );
}

/**
 * PR-B3: "내 운세" 화면용 — 모든 캐릭터에 걸쳐 embedded-result 메시지만 추려
 * 시간 역순으로 반환. payload_json 안의 timestamp 가 없는 variant 가 있으므로
 * created_at 으로 정렬.
 */
export async function loadAllEmbeddedResults(
  limit = 200,
): Promise<Array<{
  characterId: string;
  message: ChatShellMessage;
  createdAt: number;
}>> {
  if (!isChatDbAvailable) return [];
  const db = await openChatDb();
  const rows = await db.getAllAsync<{
    character_id: string;
    payload_json: string;
    created_at: number;
  }>(
    `SELECT character_id, payload_json, created_at
       FROM chat_messages
      WHERE payload_json LIKE '%"kind":"embedded-result"%'
      ORDER BY created_at DESC
      LIMIT ?`,
    [limit],
  );

  const result: Array<{
    characterId: string;
    message: ChatShellMessage;
    createdAt: number;
  }> = [];
  for (const row of rows) {
    try {
      const message = JSON.parse(row.payload_json) as ChatShellMessage;
      // SQL LIKE 가 false positive 일 수 있으니 한 번 더 확인.
      if (message.kind === 'embedded-result') {
        result.push({
          characterId: row.character_id,
          message,
          createdAt: row.created_at,
        });
      }
    } catch (error) {
      captureError(error, {
        surface: 'chat-db:parse-row-vault',
      }).catch(() => undefined);
    }
  }
  return result;
}

/**
 * 단일 메시지 삭제. 사용자가 자기 메시지를 명시적으로 삭제할 때.
 */
export async function deleteMessage(
  characterId: string,
  messageId: string,
): Promise<void> {
  if (!isChatDbAvailable) return;
  const db = await openChatDb();
  await db.runAsync(
    'DELETE FROM chat_messages WHERE id = ? AND character_id = ?',
    [messageId, characterId],
  );
}

// ---------------------------------------------------------------------------
// 1회 백필 (SecureStore `fortune.chat.msgs.v1.*` → SQLite)
// ---------------------------------------------------------------------------

async function runOneTimeBackfill(db: SQLite.SQLiteDatabase): Promise<void> {
  const flag = await getSecureItem(MIGRATION_FLAG_KEY);
  if (flag === '1') return;

  // 알려진 캐릭터 ID 만 대상. custom_ 캐릭터는 동적 생성이라 SecureStore 키
  // 자체는 있지만 chatCharacters 에 없을 수 있음 — 첫 진입 시 SecureStore
  // 캐시가 없으니 자연스럽게 빈 SQLite 로 시작. 이게 회귀가 아니라면 그대로.
  // (custom 캐릭터 백필 필요 시 추가 매핑 — 현재 미스코프).
  const characterIds = chatCharacters.map((c) => c.id);

  let migratedCount = 0;
  for (const characterId of characterIds) {
    const key = `${LEGACY_CACHE_PREFIX}.${characterId}`;
    const raw = await getSecureItem(key);
    if (!raw) continue;

    let messages: ChatShellMessage[];
    try {
      const parsed = JSON.parse(raw);
      if (!Array.isArray(parsed) || parsed.length === 0) {
        // 빈 배열이면 SecureStore 키만 정리하고 다음.
        await deleteSecureItem(key).catch(() => undefined);
        continue;
      }
      messages = parsed as ChatShellMessage[];
    } catch (error) {
      // 손상된 JSON — surface 하고 다음. 이 캐릭터 데이터 손실은 감수
      // (수십 개 짜리 캐시 깨졌으면 복구 불가능).
      captureError(error, {
        surface: 'chat-db:backfill-parse',
      }).catch(() => undefined);
      continue;
    }

    // SQLite 로 INSERT. INSERT OR IGNORE 라 같은 캐릭터에 대한 부분 백필이
    // 이미 있어도 안전.
    await runTx(() => db.withTransactionAsync(async () => {
      let seq = 1;
      const now = Date.now();
      for (const message of messages) {
        const sanitized = sanitizeForPersistence(message);
        await db.runAsync(
          `INSERT OR IGNORE INTO chat_messages
             (id, character_id, kind, sender, payload_json, created_at, seq)
           VALUES (?, ?, ?, ?, ?, ?, ?)`,
          [
            sanitized.id,
            characterId,
            sanitized.kind,
            sanitized.sender,
            JSON.stringify(sanitized),
            now,
            seq,
          ],
        );
        seq += 1;
      }
    }));

    // SQLite 에 안전하게 들어갔으므로 SecureStore 키 정리. chunked layout 의
    // 모든 보조 키 (active pointer, __v0/__v1 chunks, legacy chunks) 까지 한
    // 번에 삭제됨.
    await deleteSecureItem(key).catch(() => undefined);
    migratedCount += 1;
  }

  // 성공한 캐릭터가 0개였어도 마이그레이션 자체는 완료된 것으로 처리.
  // (모든 캐릭터가 빈 캐시였거나 / 신규 사용자 케이스).
  await setSecureItem(MIGRATION_FLAG_KEY, '1');

  if (migratedCount > 0) {
    // 진단용. captureError 가 아닌 일반 로그가 적합하지만 프로젝트에 통일된
    // logger 가 없으므로 console 로 — 운영에선 무음.
    console.log(`[chat-db] backfilled ${migratedCount} character(s) from SecureStore`);
  }
}

// ---------------------------------------------------------------------------
// 1회 정리: 기존에 영속된 `animate: true` 어시스턴트 메시지를 false 로 갱신
// (sanitizeForPersistence 도입 이전에 박힌 데이터 정리용)
// ---------------------------------------------------------------------------

async function runOneTimeAnimateStrip(db: SQLite.SQLiteDatabase): Promise<void> {
  const flag = await getSecureItem(ANIMATE_STRIP_FLAG_KEY);
  if (flag === '1') return;

  // payload_json 안에 `"animate":true` 가 박혀 있는 행만 골라 갱신.
  // SQLite REPLACE 는 첫 매치만 바꾸지만, payload_json 안에 같은 시그니처가
  // 두 번 등장할 일은 없으므로 안전.
  await db.runAsync(
    `UPDATE chat_messages
        SET payload_json = REPLACE(payload_json, '"animate":true', '"animate":false')
      WHERE payload_json LIKE '%"animate":true%'`,
  );

  await setSecureItem(ANIMATE_STRIP_FLAG_KEY, '1');
}
