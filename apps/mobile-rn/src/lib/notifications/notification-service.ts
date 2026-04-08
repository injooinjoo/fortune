import Constants from 'expo-constants';
import * as Device from 'expo-device';
import * as Notifications from 'expo-notifications';
import { Platform } from 'react-native';
import type { Session } from '@supabase/supabase-js';

import { supabase } from '../supabase';

export const NotificationChannelIds = {
  dailyFortune: 'daily_fortune',
  tokenAlert: 'token_alert',
  promotion: 'promotion',
  system: 'system',
  characterDm: 'character_dm',
} as const;

export type NotificationChannelId =
  (typeof NotificationChannelIds)[keyof typeof NotificationChannelIds];

export interface NotificationPreferences {
  push: boolean;
  chatReminders: boolean;
  weeklyDigest: boolean;
  marketing: boolean;
  dailyFortuneTime?: string;
}

export interface NotificationPermissionSnapshot {
  granted: boolean;
  canAskAgain: boolean;
  status: Notifications.PermissionStatus;
}

export interface NotificationTokenResult {
  token: string | null;
  projectId: string | null;
  status: NotificationPermissionSnapshot;
}

export interface NotificationListenerCallbacks {
  onReceive?: (notification: Notifications.Notification) => void;
  onResponse?: (response: Notifications.NotificationResponse) => void;
  onError?: (error: unknown) => void;
}

export interface ScheduleDailyFortuneOptions {
  title?: string;
  body?: string;
  channelId?: NotificationChannelId;
}

export interface ScheduleTestNotificationOptions {
  title?: string;
  body?: string;
  seconds?: number;
  channelId?: NotificationChannelId;
}

export interface SyncPushTokenOptions {
  session?: Session | null;
  userId?: string | null;
  deviceInfo?: Record<string, unknown>;
}

Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldShowBanner: true,
    shouldShowList: true,
    shouldPlaySound: true,
    shouldSetBadge: true,
  }),
});

function resolveExpoProjectId() {
  const extra = Constants.expoConfig?.extra as
    | Record<string, unknown>
    | undefined;
  const easConfig = extra?.eas as Record<string, unknown> | undefined;
  const projectId = Constants.easConfig?.projectId ?? easConfig?.projectId;

  return typeof projectId === 'string' && projectId.length > 0
    ? projectId
    : null;
}

function parseDailyFortuneTime(time: string | undefined) {
  const fallback = { hour: 7, minute: 0 };

  if (!time) {
    return fallback;
  }

  const match = /^(\d{1,2}):(\d{2})$/u.exec(time.trim());
  if (!match) {
    return fallback;
  }

  const hour = Number(match[1]);
  const minute = Number(match[2]);

  if (
    !Number.isInteger(hour) ||
    !Number.isInteger(minute) ||
    hour < 0 ||
    hour > 23 ||
    minute < 0 ||
    minute > 59
  ) {
    return fallback;
  }

  return { hour, minute };
}

function buildDefaultNotificationContent(
  title: string,
  body: string,
) {
  return {
    title,
    body,
    sound: 'default',
  } satisfies Notifications.NotificationContentInput;
}

function buildDeviceInfo() {
  return {
    modelName: Device.modelName ?? null,
    brand: Device.brand ?? null,
    designName: Device.designName ?? null,
    osName: Device.osName ?? Platform.OS,
    osVersion:
      Device.osVersion ?? (Platform.Version != null ? String(Platform.Version) : null),
    manufacturer: Device.manufacturer ?? null,
    isDevice: Device.isDevice,
    platform: Platform.OS,
  };
}

export async function ensureNotificationChannel(
  channelId: NotificationChannelId,
  name: string,
  description: string,
) {
  if (Platform.OS !== 'android') {
    return;
  }

  await Notifications.setNotificationChannelAsync(channelId, {
    name,
    description,
    importance: Notifications.AndroidImportance.HIGH,
    vibrationPattern: [0, 250, 250, 250],
    lockscreenVisibility: Notifications.AndroidNotificationVisibility.PUBLIC,
    sound: 'default',
  });
}

export async function initializeNotificationService() {
  await ensureNotificationChannel(
    NotificationChannelIds.dailyFortune,
    '일일 운세',
    '오늘의 운세와 리마인드 알림',
  );
  await ensureNotificationChannel(
    NotificationChannelIds.tokenAlert,
    '토큰 알림',
    '토큰 부족 및 충전 알림',
  );
  await ensureNotificationChannel(
    NotificationChannelIds.promotion,
    '프로모션',
    '이벤트와 캠페인 알림',
  );
  await ensureNotificationChannel(
    NotificationChannelIds.system,
    '시스템',
    '앱 상태와 운영 공지',
  );
  await ensureNotificationChannel(
    NotificationChannelIds.characterDm,
    '캐릭터 메시지',
    '캐릭터 대화 새 알림',
  );
}

export async function getNotificationPermissions(): Promise<NotificationPermissionSnapshot> {
  const current = await Notifications.getPermissionsAsync();

  return {
    granted: current.granted,
    canAskAgain: current.canAskAgain,
    status: current.status,
  };
}

export async function requestNotificationPermissions(): Promise<NotificationPermissionSnapshot> {
  const current = await getNotificationPermissions();
  if (current.granted || !current.canAskAgain) {
    return current;
  }

  const requested = await Notifications.requestPermissionsAsync({
    ios: {
      allowAlert: true,
      allowBadge: true,
      allowSound: true,
    },
  });

  return {
    granted: requested.granted,
    canAskAgain: requested.canAskAgain,
    status: requested.status,
  };
}

export async function getExpoPushToken(
  options: { forceRefresh?: boolean } = {},
): Promise<NotificationTokenResult> {
  void options.forceRefresh;

  const permissions = await requestNotificationPermissions();
  const projectId = resolveExpoProjectId();

  if (!permissions.granted) {
    return { token: null, projectId, status: permissions };
  }

  if (!Device.isDevice) {
    return { token: null, projectId, status: permissions };
  }

  if (!projectId) {
    return { token: null, projectId, status: permissions };
  }

  const tokenResult = await Notifications.getExpoPushTokenAsync({
    projectId,
  });

  return {
    token: tokenResult.data ?? null,
    projectId,
    status: permissions,
  };
}

export async function syncPushTokenToSupabase(
  input: SyncPushTokenOptions = {},
): Promise<boolean> {
  const client = supabase;
  if (!client) {
    return false;
  }

  const tokenResult = await getExpoPushToken();
  if (!tokenResult.token) {
    return false;
  }

  const resolvedUserId =
    input.userId?.trim() || input.session?.user.id?.trim() || null;
  if (!resolvedUserId) {
    return false;
  }

  const { error } = await client.from('fcm_tokens').upsert(
    {
      user_id: resolvedUserId,
      token: tokenResult.token,
      platform: Platform.OS,
      device_info: input.deviceInfo ?? buildDeviceInfo(),
      is_active: true,
      updated_at: new Date().toISOString(),
    },
    {
      onConflict: 'user_id,token',
    },
  );

  return !error;
}

export async function scheduleDailyFortuneNotification(
  preferences: NotificationPreferences,
  options: ScheduleDailyFortuneOptions = {},
) {
  if (!preferences.push) {
    return null;
  }

  const permissions = await requestNotificationPermissions();
  if (!permissions.granted) {
    return null;
  }

  const { hour, minute } = parseDailyFortuneTime(preferences.dailyFortuneTime);
  return Notifications.scheduleNotificationAsync({
    content: buildDefaultNotificationContent(
      options.title ?? '오늘의 운세가 준비됐어요',
      options.body ?? '하루 흐름을 확인하고 싶을 때 바로 열어보세요.',
    ),
    trigger: {
      hour,
      minute,
      repeats: true,
      channelId: options.channelId ?? NotificationChannelIds.dailyFortune,
    },
  });
}

export async function scheduleTestNotification(
  options: ScheduleTestNotificationOptions = {},
) {
  const permissions = await requestNotificationPermissions();
  if (!permissions.granted) {
    return null;
  }

  const seconds = Math.max(1, Math.floor(options.seconds ?? 5));

  return Notifications.scheduleNotificationAsync({
    content: buildDefaultNotificationContent(
      options.title ?? '테스트 알림',
      options.body ?? '푸시 알림 연결이 정상입니다.',
    ),
    trigger: {
      seconds,
      channelId: options.channelId ?? NotificationChannelIds.system,
    },
  });
}

export async function cancelAllScheduledNotifications() {
  await Notifications.cancelAllScheduledNotificationsAsync();
}

export function registerNotificationListeners(
  callbacks: NotificationListenerCallbacks = {},
) {
  const received = Notifications.addNotificationReceivedListener((notification) => {
    callbacks.onReceive?.(notification);
  });

  const response = Notifications.addNotificationResponseReceivedListener((value) => {
    callbacks.onResponse?.(value);
  });

  const subscription = Notifications.addNotificationsDroppedListener?.(() => {
    callbacks.onError?.(new Error('Notifications were dropped by the service'));
  });

  return () => {
    received.remove();
    response.remove();
    subscription?.remove();
  };
}

export function buildNotificationDeepLinkPayload(
  target: string,
  extras: Record<string, unknown> = {},
) {
  return {
    target,
    ...extras,
  };
}
