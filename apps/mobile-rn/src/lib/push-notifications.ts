import { Platform } from 'react-native';
import Constants from 'expo-constants';

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

export interface PushResponsePayload {
  characterId?: string;
  messageId?: string;
  route?: string;
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
    const route = d.route as string | undefined;
    return { characterId, messageId, route, raw: d };
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
