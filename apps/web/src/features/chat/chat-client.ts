/**
 * 캐릭터 대화 3개 Edge Function 호출 래퍼 —
 * `character-chat`, `character-conversation-load`, `character-conversation-save`.
 *
 * `features/fortune/runner.ts` 를 못 쓰는 이유는 하나다: 그 함수는 이름을
 * `fortune-<type>` 으로 만들기 때문에 (`edgeFunctionName`) 캐릭터 함수 3개를
 * 부를 수 없다. 게스트 부트스트랩 절차와 401/402 분류 규칙은 runner 와
 * 똑같이 맞췄다.
 *
 * 지켜야 하는 제약:
 *
 * 1. 커스텀 헤더 금지. `_shared/cors.ts` 허용 목록은 authorization /
 *    x-client-info / apikey / content-type 뿐이다. 하나만 더 붙어도 preflight
 *    가 깨진다. 그래서 전부 body 로만 보낸다.
 *
 * 2. 실패한 전송을 자동 재시도하지 않는다. character-chat 은 요청 body 를
 *    해시하는 방식의 idempotency 가 없다. 대신 `userMessageId` 를 보내면
 *    서버가 그 값으로 차감 idempotency 키를 만든다
 *    (`character-chat:${userId}:${characterId}:${userMessageId}`,
 *    index.ts 의 characterChatChargeCtx). 그래서 재시도는 **같은
 *    userMessageId 로만** 하고, 재시도 여부는 사용자가 버튼으로 정한다.
 *
 * 3. 배포된 character-chat 이 구버전일 수 있다. segments / delaySec /
 *    affinityDelta 가 통째로 없을 수 있고, 402/429 도 안 날 수 있다.
 *    전부 optional 로 두고 없으면 `response` 로 떨어진다.
 */

import type { SupabaseClient } from '@supabase/supabase-js';

import { notifyBalanceChanged } from '@/lib/balance-signal';
import { invokeEdgeFunction } from '@/lib/edge-invoke';
import { getBrowserSupabase } from '@/lib/supabase/client';

import type { WebChatCharacter } from './characters';
import { toChatMessage, type ChatMessage } from './types';

export type ChatFailureKind = 'auth' | 'tokens' | 'limit' | 'config' | 'error';

export interface ChatFailure {
  kind: ChatFailureKind;
  message: string;
}

const CONFIG_FAILURE: ChatFailure = {
  kind: 'config',
  message: '대화 서버 설정이 아직 준비되지 않았어요.',
};

const AUTH_FAILURE_MESSAGE = '세션이 만료됐어요. 다시 로그인하면 이어서 대화할 수 있어요.';

// 여기는 웹이다. "앱에서 충전"으로 보내면 결제 의사가 가장 높은 순간에 막다른 길이 된다.
const TOKENS_FAILURE_MESSAGE =
  '온도가 모자라서 답장을 만들지 못했어요. 온도를 충전하면 이어서 대화할 수 있어요.';

/** 429 바디의 `error` 는 `daily_chat_limit_reached` 라는 코드 문자열이다. */
const LIMIT_FAILURE_MESSAGE = '오늘 대화 사용량을 다 썼어요. 내일 다시 이어가요.';

const EMPTY_REPLY_MESSAGE = '답장이 비어서 도착했어요. 한 번 더 보내볼까요?';

/**
 * character-chat 응답. 전 필드 optional —
 * 구버전 배포본에는 segments/emotionTag/delaySec 가 없다.
 */
interface CharacterChatResponse {
  success?: boolean;
  response?: string;
  segments?: unknown;
  emotionTag?: string;
  delaySec?: number;
  scheduledId?: string;
  deliverAt?: string;
}

interface ConversationLoadResponse {
  success?: boolean;
  messages?: unknown;
  lastMessageAt?: string | null;
}

function matchesCode(errorCode: string | undefined, expected: string): boolean {
  return errorCode?.toLowerCase() === expected;
}

/**
 * 게스트 부트스트랩. `runFortune` 과 같은 순서다 —
 * 세션 없으면 익명 로그인 시도, 실패해도 anon key 로 계속.
 *
 * `signedIn` 이 false 면 대화가 브라우저 메모리에만 남는다:
 * load/save 는 RLS 로 `auth.uid()` 를 요구하고 (merge RPC 는 anon role 을
 * 명시적으로 거부한다), character-chat 은 토큰 없이도 답장은 준다.
 */
export async function ensureChatSession(): Promise<{
  supabase: SupabaseClient;
  signedIn: boolean;
} | null> {
  const supabase = getBrowserSupabase();
  if (!supabase) return null;

  const { data: sessionData } = await supabase.auth.getSession();
  if (sessionData.session) {
    return { supabase, signedIn: true };
  }

  const { data: anonData, error: anonError } = await supabase.auth.signInAnonymously();
  if (anonError) {
    console.warn('[chat] 익명 세션 발급 실패 — 로컬 대화로 계속:', anonError.message);
    return { supabase, signedIn: false };
  }

  return { supabase, signedIn: anonData.session !== null };
}

/**
 * 저장된 스레드를 불러온다.
 *
 * 실패를 실패로 올리지 않고 `null` 을 준다 — 히스토리를 못 읽는 것과 대화를
 * 못 하는 것은 다른 문제고, 화면은 "이번 대화만 남습니다" 안내로 계속
 * 진행해야 한다.
 */
export async function loadConversation(
  supabase: SupabaseClient,
  characterId: string,
): Promise<ChatMessage[] | null> {
  const result = await invokeEdgeFunction<ConversationLoadResponse>(
    supabase,
    'character-conversation-load',
    { characterId },
  );

  if (!result.ok) {
    console.warn('[chat] 스레드 불러오기 실패:', result.message);
    return null;
  }

  const raw = result.data?.messages;
  if (!Array.isArray(raw)) return [];

  return raw
    .map((entry, index) => toChatMessage(entry, index))
    .filter((message): message is ChatMessage => message !== null);
}

/**
 * 스레드를 저장한다. 서버 RPC 가 id 기준으로 머지/중복 제거하므로 매번 전체
 * 목록을 보내도 같은 메시지가 두 번 쌓이지 않는다
 * (`merge_character_conversation_messages`).
 *
 * 저장 실패는 화면을 막지 않는다 — 이미 렌더된 대화는 그대로 두고 안내만 바꾼다.
 */
export async function saveConversation(
  supabase: SupabaseClient,
  characterId: string,
  messages: ChatMessage[],
): Promise<boolean> {
  const result = await invokeEdgeFunction(supabase, 'character-conversation-save', {
    characterId,
    messages,
  });

  if (!result.ok) {
    console.warn('[chat] 스레드 저장 실패:', result.message);
    return false;
  }
  return true;
}

/** 응답 본문에서 렌더할 말풍선 배열을 뽑는다. */
function readSegments(data: CharacterChatResponse | null): string[] {
  const raw = data?.segments;
  if (Array.isArray(raw)) {
    const cleaned = raw
      .map((entry) => (typeof entry === 'string' ? entry.trim() : ''))
      .filter((entry) => entry.length > 0);
    if (cleaned.length > 0) return cleaned;
  }

  // segments 가 없는 구버전 배포본 / 빈 배열 → response 한 덩어리로 폴백.
  const fallback = typeof data?.response === 'string' ? data.response.trim() : '';
  return fallback.length > 0 ? [fallback] : [];
}

export type SendResult =
  | { ok: true; segments: string[] }
  | { ok: false; failure: ChatFailure };

/**
 * 답장 한 턴을 요청한다.
 *
 * @param userMessageId 이 턴의 사용자 메시지 id. 재시도 시 **같은 값**을 넘겨야
 *        서버 차감이 idempotent 하게 처리된다 (파일 상단 2번).
 */
export async function sendCharacterMessage({
  supabase,
  character,
  history,
  userMessage,
  userMessageId,
  fortuneHistoryId,
}: {
  supabase: SupabaseClient | null;
  character: WebChatCharacter;
  /** 이번 사용자 메시지 **이전**까지의 대화. */
  history: ChatMessage[];
  userMessage: string;
  userMessageId: string;
  fortuneHistoryId?: string | null;
}): Promise<SendResult> {
  if (!supabase) {
    return { ok: false, failure: CONFIG_FAILURE };
  }

  const result = await invokeEdgeFunction<CharacterChatResponse>(supabase, 'character-chat', {
    characterId: character.id,
    // 서버 400 조건: characterId / userMessage / systemPrompt 중 하나라도 비면 거절.
    systemPrompt: character.systemPrompt,
    characterName: character.name,
    characterTraits: character.traits,
    messages: history
      .filter((message) => message.type === 'user' || message.type === 'character')
      .map((message) => ({
        role: message.type === 'user' ? 'user' : 'assistant',
        content: message.content,
      })),
    userMessage,
    userMessageId,
    fortuneHistoryId: fortuneHistoryId ?? undefined,
    // 웹에는 푸시가 없다. true 로 두면 서버가 앱 기기로 DM 푸시를 쏜다.
    shouldSendPush: false,
    // 서버가 시간대 인사/맥락에 쓴다. character-chat 의 차감 키는 body 해시가
    // 아니라 userMessageId 라서 이 값이 매번 달라도 중복 과금되지 않는다.
    clientTimestamp: new Date().toISOString(),
  });

  // 답장 한 번에 온도가 깎인다. 잔액부족으로 막힌 경우도 표시된 숫자는 낡았다.
  notifyBalanceChanged();

  if (!result.ok) {
    if (result.status === 401 || matchesCode(result.errorCode, 'auth_required')) {
      return { ok: false, failure: { kind: 'auth', message: AUTH_FAILURE_MESSAGE } };
    }
    if (result.status === 402 || matchesCode(result.errorCode, 'insufficient_tokens')) {
      return { ok: false, failure: { kind: 'tokens', message: TOKENS_FAILURE_MESSAGE } };
    }
    if (result.status === 429) {
      return { ok: false, failure: { kind: 'limit', message: LIMIT_FAILURE_MESSAGE } };
    }
    return { ok: false, failure: { kind: 'error', message: result.message } };
  }

  const segments = readSegments(result.data);
  if (segments.length === 0) {
    return { ok: false, failure: { kind: 'error', message: EMPTY_REPLY_MESSAGE } };
  }

  return { ok: true, segments };
}
