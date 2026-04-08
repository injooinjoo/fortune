import Constants from 'expo-constants';
import { requireOptionalNativeModule } from 'expo-modules-core';
import { Platform } from 'react-native';
import type { EventSubscription, PermissionStatus } from 'expo-notifications';

import type { FortuneTypeId } from '@fortune/product-contracts';
import type { NotificationPreferences } from '../mobile-app-state';
import { supabase, type SupabaseSession } from '../supabase';

const androidChannelId = 'fortune-main';
const dailyReminderIdentifier = 'fortune-daily-reminder';

type OptionalExpoDeviceModule = {
  isDevice?: boolean;
  brand?: string | null;
  deviceName?: string | null;
  modelName?: string | null;
  osName?: string | null;
  osVersion?: string | null;
};

type NotificationsModule = typeof import('expo-notifications');

const requiredNotificationsNativeModules = [
  'ExpoBadgeModule',
  'ExpoNotificationCategoriesModule',
  'ExpoNotificationChannelGroupManager',
  'ExpoNotificationChannelManager',
  'ExpoNotificationPermissionsModule',
  'ExpoNotificationPresenter',
  'ExpoNotificationScheduler',
  'ExpoNotificationsEmitter',
  'ExpoNotificationsHandlerModule',
  'ExpoPushTokenManager',
] as const;

export type NotificationPermissionStatus =
  | 'undetermined'
  | 'denied'
  | 'granted'
  | 'provisional';

export interface NotificationRouteData {
  fortuneType?: FortuneTypeId | null;
  pathname?: string | null;
}

export interface NotificationRegistrationSnapshot {
  permissionStatus: NotificationPermissionStatus;
  devicePushToken: string;
  expoPushToken: string;
  lastSyncedAt: string | null;
}

function normalizePermissionStatus(
  status: PermissionStatus | string | undefined,
): NotificationPermissionStatus {
  switch (String(status).toLowerCase()) {
    case 'granted':
      return 'granted';
    case 'denied':
      return 'denied';
    case 'undetermined':
    default:
      return 'undetermined';
  }
}

function readProjectId() {
  return (
    Constants.expoConfig?.extra?.eas?.projectId ??
    Constants.easConfig?.projectId ??
    null
  );
}

let cachedExpoDeviceModule: OptionalExpoDeviceModule | null | undefined;
let notificationsModulePromise: Promise<NotificationsModule | null> | null = null;
let notificationsNativeModulesAvailable: boolean | null = null;
let hasConfiguredNotificationHandler = false;

function getExpoDeviceModule() {
  if (cachedExpoDeviceModule !== undefined) {
    return cachedExpoDeviceModule;
  }

  cachedExpoDeviceModule =
    requireOptionalNativeModule<OptionalExpoDeviceModule>('ExpoDevice');
  return cachedExpoDeviceModule;
}

function hasNotificationsNativeModules() {
  if (Platform.OS === 'web') {
    return false;
  }

  if (notificationsNativeModulesAvailable !== null) {
    return notificationsNativeModulesAvailable;
  }

  notificationsNativeModulesAvailable = requiredNotificationsNativeModules.every(
    (moduleName) => Boolean(requireOptionalNativeModule(moduleName)),
  );
  return notificationsNativeModulesAvailable;
}

async function loadNotificationsModule() {
  if (!hasNotificationsNativeModules()) {
    return null;
  }

  if (notificationsModulePromise) {
    return notificationsModulePromise;
  }

  notificationsModulePromise = import('expo-notifications')
    .then((module) => {
      if (!hasConfiguredNotificationHandler) {
        module.setNotificationHandler({
          handleNotification: async () => ({
            shouldPlaySound: true,
            shouldSetBadge: false,
            shouldShowBanner: true,
            shouldShowList: true,
          }),
        });
        hasConfiguredNotificationHandler = true;
      }

      return module;
    })
    .catch(() => null);

  return notificationsModulePromise;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

function parseRouteData(data: unknown): NotificationRouteData {
  if (!isRecord(data)) {
    return {};
  }

  const fortuneType =
    typeof data.fortuneType === 'string' ? (data.fortuneType as FortuneTypeId) : null;
  const pathname = typeof data.pathname === 'string' ? data.pathname : null;

  return {
    fortuneType,
    pathname,
  };
}

function buildRoutePayloadData(routeData: NotificationRouteData) {
  return {
    ...(routeData.fortuneType ? { fortuneType: routeData.fortuneType } : {}),
    ...(routeData.pathname ? { pathname: routeData.pathname } : {}),
  };
}

class NotificationService {
  private initialized = false;

  private registration: NotificationRegistrationSnapshot = {
    permissionStatus: 'undetermined',
    devicePushToken: '',
    expoPushToken: '',
    lastSyncedAt: null,
  };

  private responseSubscription: EventSubscription | null = null;

  private receivedSubscription: EventSubscription | null = null;

  async initialize(onRoute?: (data: NotificationRouteData) => void) {
    const notifications = await loadNotificationsModule();
    if (!notifications) {
      return this.registration;
    }

    await this.ensureAndroidChannel();
    await this.refreshRegistrationSnapshot();

    const initialResponse = await notifications.getLastNotificationResponseAsync().catch(
      () => null,
    );
    if (initialResponse) {
      onRoute?.(parseRouteData(initialResponse.notification.request.content.data));
      await notifications.clearLastNotificationResponseAsync?.().catch(
        () => undefined,
      );
    }

    if (this.initialized) {
      return this.registration;
    }

    this.receivedSubscription =
      notifications.addNotificationReceivedListener(() => undefined);
    this.responseSubscription =
      notifications.addNotificationResponseReceivedListener((response) => {
        onRoute?.(parseRouteData(response.notification.request.content.data));
      });

    this.initialized = true;
    return this.registration;
  }

  dispose() {
    this.receivedSubscription?.remove();
    this.responseSubscription?.remove();
    this.receivedSubscription = null;
    this.responseSubscription = null;
    this.initialized = false;
  }

  async ensureAndroidChannel() {
    if (Platform.OS !== 'android') {
      return;
    }

    const notifications = await loadNotificationsModule();
    if (!notifications) {
      return;
    }

    await notifications.setNotificationChannelAsync(androidChannelId, {
      name: 'Fortune Alerts',
      importance: notifications.AndroidImportance.MAX,
      vibrationPattern: [0, 250, 250, 250],
      lockscreenVisibility: notifications.AndroidNotificationVisibility.PUBLIC,
    });
  }

  async getRegistrationSnapshot() {
    await this.refreshRegistrationSnapshot();
    return this.registration;
  }

  async requestPermissions() {
    const notifications = await loadNotificationsModule();
    if (!notifications) {
      return this.registration.permissionStatus;
    }

    const current = await notifications.getPermissionsAsync();
    if (
      current.granted ||
      current.ios?.status === notifications.IosAuthorizationStatus.PROVISIONAL
    ) {
      this.registration.permissionStatus =
        current.ios?.status === notifications.IosAuthorizationStatus.PROVISIONAL
          ? 'provisional'
          : normalizePermissionStatus(current.status);
      return this.registration.permissionStatus;
    }

    const requested = await notifications.requestPermissionsAsync({
      ios: {
        allowAlert: true,
        allowBadge: false,
        allowSound: true,
      },
    });
    this.registration.permissionStatus =
      requested.ios?.status === notifications.IosAuthorizationStatus.PROVISIONAL
        ? 'provisional'
        : normalizePermissionStatus(requested.status);
    return this.registration.permissionStatus;
  }

  async registerDevice(
    session: SupabaseSession,
    preferences: NotificationPreferences,
  ) {
    const permissionStatus = await this.requestPermissions();
    if (permissionStatus === 'denied') {
      this.registration.permissionStatus = 'denied';
      return this.registration;
    }

    let devicePushToken = this.registration.devicePushToken;
    let expoPushToken = this.registration.expoPushToken;
    const deviceModule = getExpoDeviceModule();
    const canAttemptPushRegistration =
      deviceModule?.isDevice ?? Platform.OS !== 'web';

    if (canAttemptPushRegistration) {
      const notifications = await loadNotificationsModule();
      if (notifications) {
        const nativeToken = await notifications.getDevicePushTokenAsync().catch(
          () => null,
        );
        if (nativeToken?.data) {
          devicePushToken = nativeToken.data;
        }

        const projectId = readProjectId();
        if (projectId) {
          const expoToken = await notifications.getExpoPushTokenAsync({
            projectId,
          }).catch(() => null);
          if (expoToken?.data) {
            expoPushToken = expoToken.data;
          }
        }
      }
    }

    const nextRegistration: NotificationRegistrationSnapshot = {
      permissionStatus,
      devicePushToken,
      expoPushToken,
      lastSyncedAt: this.registration.lastSyncedAt,
    };

    if (session && supabase && devicePushToken) {
      await supabase.functions.invoke('sync-notification-device', {
        body: {
          token: devicePushToken,
          platform: Platform.OS === 'ios' ? 'ios' : 'android',
          deviceInfo: {
            brand: deviceModule?.brand ?? null,
            deviceName: deviceModule?.deviceName ?? null,
            modelName: deviceModule?.modelName ?? null,
            osName: deviceModule?.osName ?? null,
            osVersion: deviceModule?.osVersion ?? null,
          },
          preferences: {
            enabled: preferences.push,
            dailyFortune: preferences.dailyFortune,
            tokenAlert: preferences.tokenAlert,
            promotion: preferences.marketing,
            characterDm: preferences.characterDm,
            dailyFortuneTime: preferences.dailyFortuneTime,
          },
        },
      });
      nextRegistration.lastSyncedAt = new Date().toISOString();
    }

    this.registration = nextRegistration;
    return this.registration;
  }

  async deactivateRemoteToken(session: SupabaseSession) {
    if (!session || !supabase || !this.registration.devicePushToken) {
      return;
    }

    await supabase.functions.invoke('sync-notification-device', {
      body: {
        token: this.registration.devicePushToken,
        platform: Platform.OS === 'ios' ? 'ios' : 'android',
        deactivateToken: true,
      },
    });
  }

  async scheduleDailyFortuneReminder(
    preferences: NotificationPreferences,
    routeData: NotificationRouteData = {
      fortuneType: 'daily',
      pathname: '/chat',
    },
  ) {
    const notifications = await loadNotificationsModule();
    if (!notifications) {
      return null;
    }

    await notifications.cancelScheduledNotificationAsync(dailyReminderIdentifier).catch(
      () => undefined,
    );

    if (
      !preferences.push ||
      !preferences.dailyFortune ||
      (this.registration.permissionStatus !== 'granted' &&
        this.registration.permissionStatus !== 'provisional')
    ) {
      return null;
    }

    const [hourText, minuteText] = preferences.dailyFortuneTime.split(':');
    const hour = Number(hourText);
    const minute = Number(minuteText);

    if (!Number.isFinite(hour) || !Number.isFinite(minute)) {
      return null;
    }

    return notifications.scheduleNotificationAsync({
      identifier: dailyReminderIdentifier,
      content: {
        title: '오늘의 운세가 도착했어요',
        body: '대화 안에서 바로 오늘 흐름을 확인해보세요.',
        data: buildRoutePayloadData(routeData),
        sound: true,
      },
      trigger: {
        type: notifications.SchedulableTriggerInputTypes.DAILY,
        hour,
        minute,
      },
    });
  }

  async scheduleTestNotification(routeData: NotificationRouteData = {
    fortuneType: 'daily',
    pathname: '/chat',
  }) {
    const notifications = await loadNotificationsModule();
    if (!notifications) {
      return null;
    }

    return notifications.scheduleNotificationAsync({
      content: {
        title: '테스트 알림',
        body: '알림 설정과 딥링크 라우팅이 정상인지 확인합니다.',
        data: buildRoutePayloadData(routeData),
        sound: true,
      },
      trigger: {
        type: notifications.SchedulableTriggerInputTypes.TIME_INTERVAL,
        seconds: 2,
      },
    });
  }

  private async refreshRegistrationSnapshot() {
    const notifications = await loadNotificationsModule();
    if (!notifications) {
      this.registration.permissionStatus = 'undetermined';
      return this.registration;
    }

    const permissions = await notifications.getPermissionsAsync();
    this.registration.permissionStatus =
      permissions.ios?.status === notifications.IosAuthorizationStatus.PROVISIONAL
        ? 'provisional'
        : normalizePermissionStatus(permissions.status);
    return this.registration;
  }
}

export const notificationService = new NotificationService();
