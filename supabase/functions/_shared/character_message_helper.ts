/**
 * 캐릭터 메시지 발송 — character_conversations append + push 발송 통합 helper.
 *
 * 추출 이유: deliver-due-replies + proactive-message-dispatch 두 함수가 동일한
 * 흐름 (newMessage 객체 → character_conversations 머지 → sendCharacterDmPush)
 * 을 각자 따로 구현. proactive 는 advisory lock 없이 직접 update/insert,
 * deliver 는 RPC merge — 같은 의도지만 race 안전성 차이.
 *
 * 통합 효과 (사용자 의도 "서버 한 곳"):
 *   - 두 cron 함수가 같은 helper 호출 → 일관된 race 안전성 (RPC merge 표준화)
 *   - 향후 신규 cron (예: birthday-greeting, weekly-recap) 도 같은 helper 사용
 *   - notification toggle / push payload 빌딩 로직이 sendCharacterDmPush 한 곳에서
 *
 * character-chat 제외:
 *   - reactive 경로 (사용자 입력 → LLM 응답) 의 메시지 저장은 클라이언트 책임
 *   - 서버 character-chat 은 LLM 응답만 반환 + scheduled 발송 큐 INSERT
 *   - scheduled row 픽업은 deliver-due-replies → 그쪽에서 helper 호출
 *
 * 메신저 표준 (Signal/WhatsApp/Telegram TDLib):
 *   - 메시지 발송 = 단일 entity 통과 (서버 entry point 1개)
 *   - id 기반 멱등성 (RPC merge_character_conversation_messages 가 처리)
 *   - push payload 에 본문 동봉 → 디바이스가 받자마자 store INSERT
 */

import { type SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

import { sendCharacterDmPush } from "./notification_push.ts";

export interface CharacterProactiveMeta {
  slotKey: string;
  category: string;
  generatedAt: string;
}

export interface CharacterMessageEntity {
  id: string;
  type: "character";
  content: string;
  timestamp: string;
  emotionTag?: string;
  proactive?: CharacterProactiveMeta;
}

export interface PersistAndPushInput {
  supabase: SupabaseClient;
  userId: string;
  characterId: string;
  characterName: string;
  /** 메시지 본문 — push body + character_conversations content. */
  messageContent: string;
  /** 메시지 id — character_conversations dedup + push payload. */
  messageId: string;
  /** 감정 태그 — 클라가 햅틱 분기 (애정 → loveHeartbeat). */
  emotionTag?: string;
  /**
   * scheduled_character_replies row id — deliver-due-replies 가 ack 추적용으로
   * push payload 에 동봉. proactive 는 사용 안 함.
   */
  scheduledId?: string;
  /**
   * character_dm: 사용자 메시지에 대한 답장 (deliver-due-replies)
   * character_follow_up: 캐릭터 선톡 (proactive-message-dispatch)
   * 클라 측 알림 토글 (character_dm vs character_proactive) 별도라 유의.
   */
  pushType: "character_dm" | "character_follow_up";
  /**
   * 클라가 push 탭 시 어느 화면으로 갈지 hint. 'character_chat' = 채팅창.
   */
  roomState?: string;
  /** Proactive 메타 — character_conversations 메시지 객체에 함께 영속화. */
  proactive?: CharacterProactiveMeta;
  /** character_conversations 메시지 cap. 기본 200 (메신저 표준). */
  maxMessages?: number;
}

export interface PersistAndPushResult {
  /** RPC merge 결과 — 1 면 새 메시지 추가, 0 이면 dedup 또는 실패. */
  persistedCount: number;
  /** 발송된 push 수 (디바이스 수). 0 = 실패 또는 토큰 0. */
  pushSentCount: number;
  /** push 가 skip 됐나? (토글 off / 토큰 없음 등) */
  pushSkipped: boolean;
  /** skip 또는 실패 사유. */
  pushSkipReason?: string;
  /** merge RPC 가 fail 한 경우 에러 메시지. */
  persistError?: string;
}

const DEFAULT_MAX_MESSAGES = 200;

/**
 * 캐릭터 메시지 1개를 character_conversations 에 append + push 발송.
 *
 * 흐름:
 *   1) newMessage 객체 생성 (id, type='character', content, timestamp, ...)
 *   2) merge_character_conversation_messages RPC (advisory lock + id-dedup + cap)
 *   3) sendCharacterDmPush (notification toggle 체크 + Expo Push API)
 *
 * fail-soft: merge 실패해도 push 는 시도, push 실패해도 merge 는 보존.
 * 둘 다 실패해도 throw 안 함 — 결과 객체로 호출자가 분기.
 */
export async function persistAndPushCharacterMessage(
  input: PersistAndPushInput,
): Promise<PersistAndPushResult> {
  const newMessage: CharacterMessageEntity = {
    id: input.messageId,
    type: "character",
    content: input.messageContent,
    timestamp: new Date().toISOString(),
  };
  if (input.emotionTag) newMessage.emotionTag = input.emotionTag;
  if (input.proactive) newMessage.proactive = input.proactive;

  // 1) RPC merge — advisory lock + id-dedup + cap. 실패해도 push 는 진행.
  const { data: mergedCount, error: mergeErr } = await input.supabase.rpc(
    "merge_character_conversation_messages",
    {
      p_user_id: input.userId,
      p_character_id: input.characterId,
      p_incoming_messages: [newMessage],
      p_runtime_state: null,
      p_max_messages: input.maxMessages ?? DEFAULT_MAX_MESSAGES,
    },
  );
  const persistedCount = typeof mergedCount === "number" && !mergeErr
    ? 1
    : 0;
  const persistError = mergeErr ? mergeErr.message : undefined;

  // 2) push 발송 — sendCharacterDmPush 가 토글 + 토큰 + Expo API 처리.
  const pushResult = await sendCharacterDmPush({
    supabase: input.supabase,
    userId: input.userId,
    characterId: input.characterId,
    characterName: input.characterName,
    messageText: input.messageContent,
    messageId: input.messageId,
    scheduledId: input.scheduledId,
    type: input.pushType,
    roomState: input.roomState,
  });

  return {
    persistedCount,
    pushSentCount: pushResult.sentCount,
    pushSkipped: pushResult.skipped,
    pushSkipReason: pushResult.reason,
    persistError,
  };
}
