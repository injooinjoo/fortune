import { Platform } from 'react-native';
import Constants from 'expo-constants';

import type { ChatShellMessage } from './chat-shell';
import { insertMessages } from './message-store';
import {
  deleteSecureItem,
  getSecureItem,
  setSecureItem,
} from './secure-store-storage';
import { supabase } from './supabase';

// sync-notification-device 호출이 네트워크/서버 오류로 실패한 경우, 다음
// 부트스트랩이나 앱 resume 시점에 동일 토큰으로 재시도할 수 있도록 SecureStore
// 에 마지막으로 발급받은 토큰을 보관한다. lastRegisteredToken in-memory dedup
// 만으로는 cold-start 후 동일 토큰을 받았을 때 retry 가 발생하지 않는다.
const PENDING_PUSH_TOKEN_KEY = 'fortune.push.pending-token.v1';

let lastRegisteredToken: string | null = null;
let handlerInstalled = false;

type NotificationsModule = typeof import('expo-notifications');
type DeviceModule = typeof import('expo-device');

// 네이티브 모듈이 현재 빌드에 링크되지 않은 OTA 환경에서 import가 크래시를
// 내지 않도록 런타임 require + try/catch로 지연 로드.
function loadNotifications(): NotificationsModule | null {
  try {
    // eslint-disable-next-line @typescript-eslint/no-require-imports
    return require('expo-notifications') as NotificationsModule;
  } catch {
    return null;
  }
}

function loadDevice(): DeviceModule | null {
  try {
    // eslint-disable-next-line @typescript-eslint/no-require-imports
    return require('expo-device') as DeviceModule;
  } catch {
    return null;
  }
}

/**
 * 사용자가 현재 보고 있는 캐릭터 채팅 ID. 같은 캐릭터 push 가 들어오면 OS
 * banner/sound 를 차단해 채팅창 안에서의 노이즈를 제거한다. 채팅창 진입 시
 * `setActiveChatCharacterId(id)`, 이탈/blur 시 `clearActiveChatCharacterId()`.
 *
 * 메시지 자체는 채팅 surface 가 hydrate 해서 정상 표시되므로 사용자 가치 손실
 * 없음. shouldShowList 는 true 로 둬서 다른 캐릭터 알림센터 진입 시 history
 * 는 보존 (현재 차단 대상이 같은 캐릭터일 뿐).
 */
let activeChatCharacterId: string | null = null;

export function setActiveChatCharacterId(characterId: string | null): void {
  activeChatCharacterId = characterId;
}

export function clearActiveChatCharacterId(): void {
  activeChatCharacterId = null;
}

function shouldSuppressForActiveChat(
  data: Record<string, unknown> | null | undefined,
): boolean {
  if (!activeChatCharacterId) return false;
  if (!data) return false;
  const incomingCharacterId =
    (data.character_id as string | undefined) ??
    (data.characterId as string | undefined);
  return Boolean(incomingCharacterId) &&
    incomingCharacterId === activeChatCharacterId;
}

function ensureNotificationHandler(Notifications: NotificationsModule): void {
  if (handlerInstalled) return;
  handlerInstalled = true;
  Notifications.setNotificationHandler({
    handleNotification: async (notification) => {
      const data = notification.request.content.data as
        | Record<string, unknown>
        | null
        | undefined;
      const suppress = shouldSuppressForActiveChat(data);
      // 같은 캐릭터 채팅창 안에 있으면 banner/sound/배지 모두 차단.
      // shouldShowList 만 true 로 두어 알림센터 history 는 유지 (사용자가
      // 나중에 보고 싶을 수 있고, 채팅창에서 이미 보고 있어 중복 카운트 위험 X).
      if (suppress) {
        return {
          shouldShowAlert: false,
          shouldShowBanner: false,
          shouldShowList: true,
          shouldPlaySound: false,
          shouldSetBadge: false,
        };
      }
      return {
        shouldShowAlert: true,
        shouldShowBanner: true,
        shouldShowList: true,
        shouldPlaySound: true,
        // 수신 시 OS 가 배지를 자동 가산. 앱 내부 lastSeen 변화에 맞춰
        // setAppIconBadgeCount 로 재동기화되므로 overcount 위험은 없음.
        shouldSetBadge: true,
      };
    },
  });
}

/**
 * iOS/Android 홈스크린 앱 아이콘 숫자 배지를 설정.
 * expo-notifications 가 없는 환경(Expo Go 등)에선 silent no-op.
 */
export async function setAppIconBadgeCount(count: number): Promise<void> {
  const Notifications = loadNotifications();
  if (!Notifications) return;
  try {
    await Notifications.setBadgeCountAsync(Math.max(0, Math.floor(count)));
  } catch (e) {
    console.warn('[push] setBadgeCountAsync 실패:', e);
  }
}

/**
 * Push payload 가 메시지 본문을 담고 있으면 MessageStore 에 즉시 INSERT.
 *
 * iMessage / WhatsApp / Signal 표준: push 도착 = 메시지 도착. 서버에 추가
 * fetch 안 함 (extra round-trip 0). 사용자가 채팅창에 있으면 새 메시지가
 * 자동 등장, 다른 화면에 있어도 store 캐시에 들어가 다음 진입 시 즉시 표시.
 *
 * 멱등성: store 가 id 기반 INSERT OR IGNORE — 같은 메시지가 push + 다음
 * fetch 두 번 도착해도 1번만 추가됨.
 *
 * id 결정 우선순위:
 *   1) scheduledId (cron deliver-due-replies 발송) — `scheduled-{uuid}` prefix
 *      로 통일해서 서버 character_conversations.messages 와 같은 id 보장.
 *   2) messageId (서버에서 fully-qualified id 보낸 경우)
 *   3) fallback — push 시각 기반 (id 없는 옛 페이로드 호환).
 */
export async function insertMessageFromPushIfPresent(
  payload: PushResponsePayload,
): Promise<void> {
  if (!payload.characterId) return;

  // Poster-result push 우선 처리 — cardPayload 가 박혀 있으면 카드 INSERT.
  // process-poster-jobs cron worker 가 손금/관상 등 결과 카드 push 시 사용.
  if (payload.type === 'poster_result' && payload.cardPayloadJson) {
    try {
      const card = JSON.parse(payload.cardPayloadJson) as ChatShellMessage;
      if (card && typeof card === 'object' && 'id' in card && 'kind' in card) {
        await insertMessages(payload.characterId, [card]);
        return;
      }
    } catch (e) {
      console.warn('[push] poster_result card_payload_json parse 실패:', e);
      // fall-through to text fallback (push body 라도 표시)
    }
  }

  if (!payload.body) return;
  const id = payload.scheduledId
    ? `scheduled-${payload.scheduledId}`
    : payload.messageId ?? `push-${Date.now()}`;
  const message: ChatShellMessage = {
    id,
    kind: 'text',
    sender: 'assistant',
    text: payload.body,
  };
  try {
    await insertMessages(payload.characterId, [message]);
  } catch (error) {
    // store insert 실패해도 사용자 가시 영향 없음 — 다음 채팅창 진입 시
    // character-conversation-load 로 복구.
    // eslint-disable-next-line no-console
    console.warn('[push] store insertFromPush 실패:', error);
  }
}

/**
 * scheduled_character_replies row 에 대한 ack 를 멱등하게 발사.
 *
 * 같은 scheduledId 가 여러 채널(foreground receive / tap / send→response)
 * 로 도착해도 모듈-스코프 Set 으로 dedup → 네트워크 1회만. 서버 ack-
 * scheduled-reply 는 자체 멱등이지만 회선/배터리 절약.
 *
 * cold-start 시 모듈 다시 로드되어 Set 빔 → 재호출 가능. 서버 멱등이라 안전.
 */
const ackedScheduledIds = new Set<string>();
const ACKED_SCHEDULED_IDS_MAX = 256;

export function ackScheduledReplyIfPresent(
  scheduledId: string | null | undefined,
): void {
  if (!scheduledId) return;
  if (ackedScheduledIds.has(scheduledId)) return;
  if (!supabase) return;
  // LRU-ish: 256 hit 시 가장 오래 들어온 절반 제거.
  if (ackedScheduledIds.size >= ACKED_SCHEDULED_IDS_MAX) {
    const toDrop = Array.from(ackedScheduledIds).slice(
      0,
      Math.floor(ACKED_SCHEDULED_IDS_MAX / 2),
    );
    toDrop.forEach((id) => ackedScheduledIds.delete(id));
  }
  ackedScheduledIds.add(scheduledId);
  supabase.functions
    .invoke('ack-scheduled-reply', { body: { scheduledId } })
    .catch((ackError: unknown) => {
      // 실패해도 cron 의 20s grace + client_acked_at NULL 조건에서 재시도
      // 가능. 사용자 가시 영향 없음.
      console.warn('[push] ack-scheduled-reply 실패:', ackError);
    });
}

export interface PushResponsePayload {
  characterId?: string;
  messageId?: string;
  /**
   * scheduled_character_replies row id. 캐릭터의 지연 답장이 cron 으로
   * 발송된 경우에만 채워짐. 받자마자 ack-scheduled-reply 호출 → cron 이
   * 같은 메시지를 또 처리하지 않도록 client_acked_at 마킹.
   * Telegram scheduled-message API 패턴 (서버 ID 별도 필드).
   */
  scheduledId?: string;
  /**
   * 캐릭터 메시지 본문 — buildCharacterDmPayload 가 항상 포함.
   * 클라가 받자마자 MessageStore 에 INSERT 하면 채팅창에 자동 등장
   * (extra fetch 0). iMessage / WhatsApp / Signal 표준 push payload.
   */
  body?: string;
  /** 캐릭터 이름 — push 알림 title 로도 사용. */
  title?: string;
  route?: string;
  /**
   * Poster-job 결과 카드 payload (JSON-stringified ChatShellEmbeddedResultMessage).
   * process-poster-jobs cron worker 가 결과 도착 push 에 박아서 보내면
   * 클라가 받자마자 INSERT — hydrate / 추가 fetch 없이 즉시 결과 카드 등장.
   */
  cardPayloadJson?: string;
  /** 푸시 타입 — 'poster_result' 면 cardPayloadJson 사용. */
  type?: string;
  raw: Record<string, unknown>;
}

type SubLike = { remove: () => void } | { removeSubscription: () => void };

function removeSub(sub: SubLike): void {
  if ('remove' in sub && typeof sub.remove === 'function') {
    sub.remove();
  } else if (
    'removeSubscription' in sub &&
    typeof sub.removeSubscription === 'function'
  ) {
    sub.removeSubscription();
  }
}

/**
 * 푸시 알림 탭/수신 리스너를 설치. 반환된 cleanup 함수로 모두 해제.
 *
 * - `onTap`: 유저가 시스템 알림을 탭해서 앱을 연 경우 호출 (백그라운드/종료
 *   상태에서 온 탭 포함). 캐릭터 DM 의 경우 characterId/route 가 payload 에
 *   담겨 있어 그걸로 채팅 스크린으로 라우팅한다.
 * - `onForegroundReceive`: 앱이 포그라운드일 때 알림이 도착한 순간 호출.
 *   UI 가 이미 떠 있으면 닷을 띄워 유저에게 알리는 용도. OS 가 배너를 띄우는
 *   건 `setNotificationHandler` 가 따로 담당.
 */
export function installPushNotificationHandlers(handlers: {
  onTap?: (payload: PushResponsePayload) => void;
  onForegroundReceive?: (payload: PushResponsePayload) => void;
}): () => void {
  const Notifications = loadNotifications();
  if (!Notifications) {
    return () => undefined;
  }
  ensureNotificationHandler(Notifications);

  function toPayload(
    data: Record<string, unknown> | null | undefined,
  ): PushResponsePayload {
    const d = (data ?? {}) as Record<string, unknown>;
    const characterId =
      (d.character_id as string | undefined) ??
      (d.characterId as string | undefined);
    const messageId =
      (d.message_id as string | undefined) ??
      (d.messageId as string | undefined);
    // 새 서버는 scheduled_id/scheduledId 별도 필드를 보냄. 옛 서버
    // (`scheduled-{uuid}` prefix) 호환: messageId 가 그 형식이면 추출.
    // 다음 서버 릴리스에서 prefix 제거 후 이 fallback 도 삭제.
    const scheduledIdRaw =
      (d.scheduled_id as string | undefined) ??
      (d.scheduledId as string | undefined);
    const scheduledId =
      scheduledIdRaw ??
      (typeof messageId === 'string' && messageId.startsWith('scheduled-')
        ? messageId.slice('scheduled-'.length)
        : undefined);
    const route = d.route as string | undefined;
    const body = typeof d.body === 'string' ? (d.body as string) : undefined;
    const title = typeof d.title === 'string' ? (d.title as string) : undefined;
    const type = typeof d.type === 'string' ? (d.type as string) : undefined;
    const cardPayloadJson =
      typeof d.card_payload_json === 'string'
        ? (d.card_payload_json as string)
        : typeof d.cardPayloadJson === 'string'
          ? (d.cardPayloadJson as string)
          : undefined;
    return {
      characterId,
      messageId,
      scheduledId,
      body,
      title,
      route,
      type,
      cardPayloadJson,
      raw: d,
    };
  }

  const respSub = Notifications.addNotificationResponseReceivedListener(
    (response) => {
      try {
        handlers.onTap?.(
          toPayload(
            response.notification.request.content.data as
              | Record<string, unknown>
              | null
              | undefined,
          ),
        );
      } catch (e) {
        console.warn('[push] onTap 핸들러 예외:', e);
      }
    },
  );

  const recvSub = Notifications.addNotificationReceivedListener(
    (notification) => {
      try {
        handlers.onForegroundReceive?.(
          toPayload(
            notification.request.content.data as
              | Record<string, unknown>
              | null
              | undefined,
          ),
        );
      } catch (e) {
        console.warn('[push] onForegroundReceive 핸들러 예외:', e);
      }
    },
  );

  // 앱이 종료된 상태에서 푸시 탭으로 콜드 스타트한 경우를 위한 초기 체크.
  // addNotificationResponseReceivedListener 는 콜드 스타트 시 한 번 더 fire
  // 되지만, 레이스로 놓칠 수 있어 getLastNotificationResponseAsync 로 안전망.
  Notifications.getLastNotificationResponseAsync()
    .then((last) => {
      if (!last) return;
      handlers.onTap?.(
        toPayload(
          last.notification.request.content.data as
            | Record<string, unknown>
            | null
            | undefined,
        ),
      );
    })
    .catch(() => undefined);

  return () => {
    try {
      removeSub(respSub as SubLike);
    } catch {
      // no-op
    }
    try {
      removeSub(recvSub as SubLike);
    } catch {
      // no-op
    }
  };
}

async function ensureAndroidChannel(
  Notifications: NotificationsModule,
): Promise<void> {
  if (Platform.OS !== 'android') return;
  await Notifications.setNotificationChannelAsync('character_dm', {
    name: '캐릭터 DM',
    importance: Notifications.AndroidImportance.HIGH,
    vibrationPattern: [0, 250, 250, 250],
    sound: 'default',
  });
}

async function requestPermission(
  Notifications: NotificationsModule,
  options?: { promptIfNotGranted?: boolean },
): Promise<boolean> {
  const current = await Notifications.getPermissionsAsync();
  if (current.granted) return true;
  if (!current.canAskAgain) return false;
  // JIT 정책(W9): 사용자가 명시적으로 푸시 켜기를 선택한 순간에만 OS 프롬프트
  // 노출. cold-start 자동 호출에서는 프롬프트 띄우지 않고 silent skip.
  if (!options?.promptIfNotGranted) return false;

  const next = await Notifications.requestPermissionsAsync({
    ios: {
      allowAlert: true,
      allowBadge: false,
      allowSound: true,
    },
  });
  return next.granted;
}

function getProjectId(): string | undefined {
  const easProjectId =
    (Constants.expoConfig?.extra as { eas?: { projectId?: string } } | undefined)?.eas?.projectId ??
    (Constants.easConfig as { projectId?: string } | undefined)?.projectId;
  return easProjectId;
}

export interface RegisterPushTokenOptions {
  /**
   * true — iOS 푸시 권한이 아직 허용되지 않았다면 OS 프롬프트를 띄운다.
   *   사용자가 "알림 받기" 토글 같은 명시적 action 에서 호출할 때만 사용.
   * false (default) — 권한이 이미 허용된 경우에만 token 등록. 미허용 상태는
   *   `{ skipped: true, reason: 'permission denied' }` 반환 (JIT 정책).
   */
  promptIfNotGranted?: boolean;
}

export async function registerPushTokenForSignedInUser(
  options?: RegisterPushTokenOptions,
): Promise<
  { token: string } | { skipped: true; reason: string }
> {
  const Notifications = loadNotifications();
  if (!Notifications) {
    return { skipped: true, reason: 'expo-notifications not linked' };
  }
  const Device = loadDevice();
  if (!Device) {
    return { skipped: true, reason: 'expo-device not linked' };
  }
  if (!Device.isDevice) {
    return { skipped: true, reason: 'not a physical device' };
  }

  if (!supabase) {
    return { skipped: true, reason: 'supabase not configured' };
  }

  const { data: sessionData } = await supabase.auth.getSession();
  if (!sessionData.session?.user?.id) {
    return { skipped: true, reason: 'no signed-in user' };
  }

  ensureNotificationHandler(Notifications);

  const granted = await requestPermission(Notifications, {
    promptIfNotGranted: options?.promptIfNotGranted ?? false,
  });
  if (!granted) {
    return { skipped: true, reason: 'permission denied' };
  }

  await ensureAndroidChannel(Notifications);

  const projectId = getProjectId();
  const tokenResult = await Notifications.getExpoPushTokenAsync(
    projectId ? { projectId } : undefined,
  );
  const token = tokenResult.data;

  if (!token) {
    return { skipped: true, reason: 'no token returned' };
  }

  // 메모리 dedup: 같은 세션 내 토큰 변동 없으면 즉시 반환. 단 SecureStore 에
  // pending 토큰이 남아 있다면 (이전 sync 실패) 다시 시도해야 하므로 memory hit
  // 만으로 short-circuit 하지 않는다.
  const pendingToken = await getSecureItem(PENDING_PUSH_TOKEN_KEY).catch(
    () => null,
  );
  if (token === lastRegisteredToken && !pendingToken) {
    return { token };
  }

  const platform: 'ios' | 'android' | 'web' =
    Platform.OS === 'ios' ? 'ios' : Platform.OS === 'android' ? 'android' : 'web';

  const { error } = await supabase.functions.invoke('sync-notification-device', {
    body: {
      token,
      platform,
      deviceInfo: {
        brand: Device.brand ?? undefined,
        modelName: Device.modelName ?? undefined,
        osVersion: Device.osVersion ?? undefined,
        appVersion: Constants.expoConfig?.version ?? undefined,
      },
    },
  });

  if (error) {
    console.warn('[push] sync-notification-device 실패:', error.message ?? error);
    // 다음 resume/bootstrap 에서 재시도하도록 토큰을 보관. memory dedup 도
    // 풀어 same-token retry path 가 동작하도록 한다.
    lastRegisteredToken = null;
    await setSecureItem(PENDING_PUSH_TOKEN_KEY, token).catch(() => undefined);
    return { skipped: true, reason: 'sync failed' };
  }

  lastRegisteredToken = token;
  await deleteSecureItem(PENDING_PUSH_TOKEN_KEY).catch(() => undefined);
  return { token };
}

export interface SyncNotificationPreferencesPayload {
  /** 전역 알림 ON/OFF — false 면 모든 푸시 차단. */
  enabled?: boolean;
  /** 일일 인사이트(아침 알림). */
  dailyFortune?: boolean;
  /** 토큰 부족 알림. */
  tokenAlert?: boolean;
  /** 이벤트/프로모션. */
  promotion?: boolean;
  /** 캐릭터 DM (리액티브 — 캐릭터가 답장한 경우). */
  characterDm?: boolean;
  /** "HH:mm" 형식 일일 인사이트 알림 시각. */
  dailyFortuneTime?: string | null;
}

/**
 * 알림 선호도(토글)를 백엔드 user_notification_preferences 테이블에 동기화.
 * profile-notifications-screen 등에서 토글 저장 직후 호출하면 다음 푸시 발송
 * 이 새 선호도를 반영한다. (이전엔 로컬 SecureStore 만 업데이트 → 백엔드는
 * stale → proactive 디스패처가 잘못된 토글 값 참조하던 문제 해결.)
 */
export async function syncNotificationPreferencesForSignedInUser(
  preferences: SyncNotificationPreferencesPayload,
): Promise<{ ok: true } | { ok: false; reason: string }> {
  if (!supabase) {
    return { ok: false, reason: 'supabase not configured' };
  }
  const { data: sessionData } = await supabase.auth.getSession();
  if (!sessionData.session?.user?.id) {
    return { ok: false, reason: 'no signed-in user' };
  }
  // 백엔드 sync-notification-device 는 token + platform 필수. 토큰이 없는
  // 사용자(권한 미허용/시뮬레이터)도 선호도는 저장돼야 하므로 lastRegistered/
  // pending 토큰을 fallback 으로 사용. 둘 다 없으면 푸시 발송 자체가 불가능
  // 하므로 skip.
  const fallbackToken =
    lastRegisteredToken ??
    (await getSecureItem(PENDING_PUSH_TOKEN_KEY).catch(() => null));
  if (!fallbackToken) {
    return { ok: false, reason: 'no token registered yet' };
  }
  const platform: 'ios' | 'android' | 'web' =
    Platform.OS === 'ios'
      ? 'ios'
      : Platform.OS === 'android'
        ? 'android'
        : 'web';

  const { error } = await supabase.functions.invoke(
    'sync-notification-device',
    {
      body: {
        token: fallbackToken,
        platform,
        preferences,
      },
    },
  );
  if (error) {
    console.warn('[push] 선호도 동기화 실패:', error.message ?? error);
    return { ok: false, reason: 'sync failed' };
  }
  return { ok: true };
}

/**
 * 현재 메모리에 보관된 Expo push token 반환. 미발급/미등록이면 null.
 * dev-tools 화면에서 토큰을 화면에 노출/복사하기 위한 read-only getter.
 */
export function getCurrentPushTokenSnapshot(): string | null {
  return lastRegisteredToken;
}

/**
 * 로컬 푸시 발사 — 캐릭터 DM 페이로드 모양과 동일하게 만들어, NSE/Android
 * BigPicture 동작을 검증하기 위한 dev 전용 도구. 실제 서버 발송 경로를
 * 거치지 않고 OS 알림센터에 곧장 띄운다.
 *
 * 주의: 로컬 푸시는 iOS NSE 가 호출되지 않는다 (NSE 는 원격 푸시 전용).
 * 따라서 image attachment 는 로컬 푸시에서는 안 보인다 — 이 도구는 주로
 * Android BigPicture 검증과 페이로드 라우팅(`character_id`/`route` 정상
 * 전달) 검증 용. iOS NSE 검증은 실제 서버 푸시(친구 메시지 보내기)로만
 * 가능.
 */
export async function presentLocalCharacterDmPushForDev(params: {
  characterId: string;
  characterName: string;
  body: string;
  imageUrl?: string | null;
}): Promise<{ ok: true } | { ok: false; reason: string }> {
  const Notifications = loadNotifications();
  if (!Notifications) {
    return { ok: false, reason: 'expo-notifications not linked' };
  }
  ensureNotificationHandler(Notifications);
  const perm = await Notifications.getPermissionsAsync();
  if (!perm.granted) {
    return { ok: false, reason: 'permission denied' };
  }
  await ensureAndroidChannel(Notifications);

  const data: Record<string, string> = {
    type: 'character_dm',
    channel: 'character_dm',
    character_id: params.characterId,
    characterId: params.characterId,
    title: params.characterName,
    body: params.body,
    route: `/chat?characterId=${encodeURIComponent(params.characterId)}`,
  };
  if (params.imageUrl) {
    data.image = params.imageUrl;
  }

  try {
    await Notifications.scheduleNotificationAsync({
      content: {
        title: params.characterName,
        body: params.body,
        data,
        sound: 'default',
      },
      trigger: null,
    });
    return { ok: true };
  } catch (e) {
    return { ok: false, reason: (e as Error).message ?? 'schedule failed' };
  }
}

export async function deactivateCurrentPushToken(): Promise<void> {
  // SecureStore pending 토큰도 비활성화 대상. 로그아웃 시점에 sync 실패 잔재
  // 가 남아 있으면 다른 계정으로 로그인했을 때 그대로 활성화될 수 있다.
  const tokenToDeactivate =
    lastRegisteredToken ??
    (await getSecureItem(PENDING_PUSH_TOKEN_KEY).catch(() => null));

  if (!supabase || !tokenToDeactivate) {
    // 토큰이 없어도 캐시는 정리해야 안전.
    lastRegisteredToken = null;
    await deleteSecureItem(PENDING_PUSH_TOKEN_KEY).catch(() => undefined);
    return;
  }

  const { error } = await supabase.functions.invoke('sync-notification-device', {
    body: {
      token: tokenToDeactivate,
      platform:
        Platform.OS === 'ios' ? 'ios' : Platform.OS === 'android' ? 'android' : 'web',
      deactivateToken: true,
    },
  });
  if (error) {
    console.warn('[push] 토큰 비활성화 실패:', error.message ?? error);
    // 실패해도 클라이언트 캐시는 비워서 다음 사용자/세션에 누설 안 되도록.
  }
  lastRegisteredToken = null;
  await deleteSecureItem(PENDING_PUSH_TOKEN_KEY).catch(() => undefined);
}
