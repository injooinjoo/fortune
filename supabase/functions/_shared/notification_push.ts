import {
  createClient,
  type SupabaseClient,
} from "https://esm.sh/@supabase/supabase-js@2";
import { getCharacterAvatarUrl } from "./character_avatar_urls.ts";

const EXPO_PUSH_ENDPOINT = "https://exp.host/--/api/v2/push/send";

// EXPO_ACCESS_TOKEN 미설정 경고를 cold-start 당 1회만 출력하기 위한 가드.
// 매 요청마다 출력하면 로그 노이즈가 너무 큼. 운영 환경에서 누락 시 즉시
// 인지되도록 첫 호출 시 한 번 ERROR 레벨로 출력한다.
let expoAccessTokenWarned = false;

export interface CharacterPushPayload {
  characterId: string;
  characterName: string;
  messageText: string;
  messageId?: string;
  conversationId?: string;
  roomState?: string;
  type?: "character_dm" | "character_follow_up";
  route?: string;
  // scheduled_character_replies row id. 클라가 받자마자 ack-scheduled-reply
  // 호출해서 client_acked_at 마킹 → cron 중복 발송 방지.
  // Telegram scheduled-message API 패턴 (별도 필드, 매직 prefix 폐기).
  scheduledId?: string;
  // proactive_message_log row id (Slice 2). hookForReveal=true 인 메시지일 때만.
  // 클라가 character-chat 호출 시 body 에 동봉 → 서버가 reveal claim 시 race 회피.
  pendingProactiveMessageId?: string;
}

export interface CharacterPushSendResult {
  userId: string;
  characterId: string;
  sentCount: number;
  skipped: boolean;
  reason?: string;
}

export interface PushDeliveryParams {
  userId: string;
  title: string;
  body: string;
  data: Record<string, string>;
}

function getCharacterDmRoute(characterId: string): string {
  const encodedCharacterId = encodeURIComponent(characterId);
  // 푸시 탭 → 캐릭터 채팅방 직행. /chat?characterId=... 가 chat-screen.tsx 의
  // `directCharacterId` 분기를 활성화해 surfaceMode='chat' 으로 바로 진입한다.
  // 과거에는 `/character/{id}?openCharacterChat=true` 인트로 화면을 거쳐
  // 사용자가 한 번 더 "이 캐릭터로 채팅하기" 를 눌러야 했음.
  return `/chat?characterId=${encodedCharacterId}`;
}

export function buildCharacterDmPayload(
  params: CharacterPushPayload,
): Record<string, string> {
  const route = params.route ?? getCharacterDmRoute(params.characterId);

  const payload: Record<string, string> = {
    type: params.type ?? "character_dm",
    channel: "character_dm",
    character_id: params.characterId,
    characterId: params.characterId,
    title: params.characterName,
    body: params.messageText,
    route,
  };

  if (params.messageId) {
    payload["message_id"] = params.messageId;
  }

  if (params.conversationId) {
    payload["conversation_id"] = params.conversationId;
  }

  if (params.roomState) {
    payload["room_state"] = params.roomState;
  }

  if (params.scheduledId) {
    // snake + camel 둘 다 박는 이유: 기존 character_id/characterId 패턴 동일.
    // RN 클라가 둘 중 어느 키로 읽든 호환되도록 — 다음 OTA에서 클라가 양방향
    // fallback 안정화되면 한 키로 정리 예정.
    payload["scheduled_id"] = params.scheduledId;
    payload["scheduledId"] = params.scheduledId;
  }

  if (params.pendingProactiveMessageId) {
    // Slice 2: proactive hooking → user reply → reveal race 회피용.
    // 클라가 character-chat 호출 시 body 에 동봉.
    payload["pending_proactive_message_id"] = params.pendingProactiveMessageId;
    payload["pendingProactiveMessageId"] = params.pendingProactiveMessageId;
  }

  return payload;
}

/**
 * 캐릭터 DM 푸시(리액티브 — 사용자가 보낸 메시지에 캐릭터가 답장한 경우)
 * 발송 가능 여부.
 *
 * 컬럼 의도(혼동 주의):
 *   - `enabled`             — 전역 알림 ON/OFF. false 면 모든 푸시 차단.
 *   - `character_dm`        — 리액티브 캐릭터 답장 알림 (이 함수가 사용).
 *   - `character_proactive` — 캐릭터 선톡(시스템이 먼저 말 걸기) 알림.
 *                              proactive-message-dispatch 가 사용. 다른 토글.
 *
 * 두 컬럼은 의도적으로 분리되어 있다. 사용자가 답장은 받고 싶지만 선톡은 받기
 * 싫은 경우, 또는 그 반대 케이스를 지원한다. 한 컬럼으로 합치지 말 것.
 */
async function hasCharacterNotificationEnabled(
  supabase: SupabaseClient,
  userId: string,
): Promise<boolean> {
  const { data, error } = await supabase
    .from("user_notification_preferences")
    .select("*")
    .eq("user_id", userId)
    .maybeSingle();

  if (error) {
    console.error(
      "[notification_push] user_notification_preferences 조회 실패:",
      error,
    );
    return true;
  }

  if (!data) {
    return true;
  }

  const row = data as Record<string, unknown>;
  const enabled = row["enabled"] as boolean | undefined;

  if (enabled === false) {
    return false;
  }

  if ("character_dm" in row) {
    const characterDm = row["character_dm"] as boolean | undefined;
    if (characterDm === false) {
      return false;
    }
  }

  return true;
}

async function getActiveCharacterTokens(
  supabase: SupabaseClient,
  userId: string,
): Promise<string[]> {
  const { data, error } = await supabase
    .from("fcm_tokens")
    .select("token")
    .eq("user_id", userId)
    .eq("is_active", true);

  if (error) {
    console.error("[notification_push] fcm_tokens 조회 실패:", error);
    return [];
  }

  if (!data) return [];

  return data
    .map((row) => row.token as string)
    .filter((token): token is string => Boolean(token));
}

async function deactivateTokens(
  supabase: SupabaseClient,
  tokens: string[],
): Promise<void> {
  if (tokens.length === 0) return;
  const { error } = await supabase
    .from("fcm_tokens")
    .update({ is_active: false, updated_at: new Date().toISOString() })
    .in("token", tokens);
  if (error) {
    console.error("[notification_push] 만료 토큰 비활성화 실패:", error);
  }
}

interface ExpoPushMessage {
  to: string;
  title: string;
  body: string;
  data: Record<string, string>;
  sound: "default";
  priority: "high";
  channelId?: string;
  // 캐릭터 얼굴을 푸시에 띄우기 위한 필드.
  // - Android: Expo SDK 가 BigPictureStyle 로 자동 렌더 (네이티브 지원).
  // - iOS:   Expo Push API 가 mutableContent + APNS attachment hint 로 변환.
  //          앱 측 Notification Service Extension 이 다운로드 후 첨부.
  //          (apps/mobile-rn/targets/notification-service)
  richContent?: { image?: string };
  // iOS NSE 를 호출하기 위해 필수. richContent.image 만 있어도 Expo 가
  // 내부적으로 켜주지만, 명시적으로 true 로 보내 향후 SDK 변경에 대비한다.
  mutableContent?: boolean;
}

interface ExpoPushTicket {
  status: "ok" | "error";
  id?: string;
  message?: string;
  details?: { error?: string };
}

interface ExpoPushSendResponse {
  data?: ExpoPushTicket[] | ExpoPushTicket;
  errors?: Array<{ code?: string; message: string }>;
}

async function sendExpoPushToTokens(
  supabase: SupabaseClient,
  params: {
    tokens: string[];
    title: string;
    body: string;
    data: Record<string, string>;
  },
): Promise<number> {
  // characterId 가 있으면 캐릭터 얼굴 URL 부착. 미등록 캐릭터/SUPABASE_URL
  // 누락 등 어떤 이유로든 URL 을 못 만들면 텍스트 푸시로 graceful fallback.
  const avatarUrl = getCharacterAvatarUrl(
    params.data.character_id ?? params.data.characterId,
  );
  const richContent = avatarUrl ? { image: avatarUrl } : undefined;

  // data 페이로드에도 같은 URL 을 박는다. iOS NSE 가 ExpoPushAPI 변환 결과를
  // 신뢰 못 하는 경우(SDK 버전 차이) data.image 를 fallback 으로 사용 가능.
  const dataWithImage = avatarUrl
    ? { ...params.data, image: avatarUrl }
    : params.data;

  const messages: ExpoPushMessage[] = params.tokens.map((token) => ({
    to: token,
    title: params.title,
    body: params.body,
    data: dataWithImage,
    sound: "default",
    priority: "high",
    channelId: dataWithImage.channel ?? "character_dm",
    ...(richContent ? { richContent, mutableContent: true } : {}),
  }));

  const accessToken = Deno.env.get("EXPO_ACCESS_TOKEN");
  const headers: Record<string, string> = {
    "Content-Type": "application/json",
    Accept: "application/json",
    "Accept-Encoding": "gzip, deflate",
  };
  if (accessToken) {
    headers["Authorization"] = `Bearer ${accessToken}`;
  } else if (!expoAccessTokenWarned) {
    // Expo Push API 는 access token 없이도 받기는 하지만, "Enhanced Push
    // Security" 가 켜진 프로젝트는 401 로 거부한다. 운영에서 토큰이 누락되면
    // 푸시가 silent fail 하므로 cold-start 당 한 번 ERROR 로 알린다.
    expoAccessTokenWarned = true;
    console.error(
      "[notification_push] EXPO_ACCESS_TOKEN env var 가 설정되지 않았습니다." +
        " Enhanced Push Security 가 켜진 프로젝트는 401 로 거부됩니다.",
    );
  }

  const response = await fetch(EXPO_PUSH_ENDPOINT, {
    method: "POST",
    headers,
    body: JSON.stringify(messages),
  });

  const responseText = await response.text();
  if (!response.ok) {
    console.error(
      `[notification_push] Expo Push HTTP ${response.status}: ${responseText.slice(0, 500)}`,
    );
    return 0;
  }

  let parsed: ExpoPushSendResponse;
  try {
    parsed = JSON.parse(responseText) as ExpoPushSendResponse;
  } catch {
    console.error(
      "[notification_push] Expo Push 응답 파싱 실패:",
      responseText.slice(0, 500),
    );
    return 0;
  }

  const tickets = Array.isArray(parsed.data)
    ? parsed.data
    : parsed.data
    ? [parsed.data]
    : [];

  let sentCount = 0;
  const invalidTokens: string[] = [];

  tickets.forEach((ticket, index) => {
    if (ticket.status === "ok") {
      sentCount += 1;
      return;
    }
    const errCode = ticket.details?.error;
    console.warn(
      `[notification_push] Expo 티켓 실패 token=${params.tokens[index]?.slice(0, 20)}... code=${errCode} msg=${ticket.message}`,
    );
    if (
      errCode === "DeviceNotRegistered" ||
      errCode === "InvalidCredentials"
    ) {
      const token = params.tokens[index];
      if (token) invalidTokens.push(token);
    }
  });

  if (invalidTokens.length > 0) {
    await deactivateTokens(supabase, invalidTokens);
  }

  return sentCount;
}

export async function sendPushToUser(
  supabase: SupabaseClient,
  userId: string,
  params: PushDeliveryParams,
): Promise<CharacterPushSendResult> {
  const tokens = await getActiveCharacterTokens(supabase, userId);
  if (tokens.length === 0) {
    return {
      userId,
      characterId: params.data.character_id || "",
      sentCount: 0,
      skipped: true,
      reason: "no active token",
    };
  }

  const sentCount = await sendExpoPushToTokens(supabase, {
    tokens,
    title: params.title,
    body: params.body,
    data: params.data,
  });

  return {
    userId,
    characterId: params.data.character_id || "",
    sentCount,
    skipped: sentCount === 0,
    reason: sentCount === 0 ? "no ticket succeeded" : undefined,
  };
}

export async function sendCharacterDmPush(params: {
  supabase: SupabaseClient;
  userId: string;
  characterId: string;
  characterName: string;
  messageText: string;
  messageId?: string;
  conversationId?: string;
  roomState?: string;
  type?: CharacterPushPayload["type"];
  scheduledId?: string;
  pendingProactiveMessageId?: string;
}): Promise<CharacterPushSendResult> {
  const isEnabled = await hasCharacterNotificationEnabled(
    params.supabase,
    params.userId,
  );

  if (!isEnabled) {
    return {
      userId: params.userId,
      characterId: params.characterId,
      sentCount: 0,
      skipped: true,
      reason: "notification disabled",
    };
  }

  const tokens = await getActiveCharacterTokens(params.supabase, params.userId);
  if (tokens.length === 0) {
    return {
      userId: params.userId,
      characterId: params.characterId,
      sentCount: 0,
      skipped: true,
      reason: "no active token",
    };
  }

  const payload = buildCharacterDmPayload({
    characterId: params.characterId,
    characterName: params.characterName,
    messageText: params.messageText,
    messageId: params.messageId,
    conversationId: params.conversationId,
    roomState: params.roomState,
    type: params.type,
    scheduledId: params.scheduledId,
    pendingProactiveMessageId: params.pendingProactiveMessageId,
  });

  const sentCount = await sendExpoPushToTokens(params.supabase, {
    tokens,
    title: params.characterName,
    body: params.messageText,
    data: payload,
  });

  return {
    userId: params.userId,
    characterId: params.characterId,
    sentCount,
    skipped: sentCount === 0,
    reason: sentCount === 0 ? "no ticket succeeded" : undefined,
  };
}

export { createClient as createSupabaseClient };
