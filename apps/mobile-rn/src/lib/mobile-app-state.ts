import {
  fortuneTypesById,
  productCatalog,
  type FortuneTypeId,
  type ProductId,
} from '@fortune/product-contracts';

export type PremiumStatus = 'inactive' | 'subscription' | 'lifetime';

export interface MobileProfileState {
  displayName: string;
  birthDate: string;
  birthTime: string;
  mbti: string;
  bloodType: string;
  interestIds: string[];
}

export interface NotificationPreferences {
  push: boolean;
  dailyFortune: boolean;
  tokenAlert: boolean;
  characterDm: boolean;
  marketing: boolean;
  dailyFortuneTime: string;
  permissionStatus: 'undetermined' | 'denied' | 'granted' | 'provisional';
  devicePushToken: string;
  expoPushToken: string;
  lastSyncedAt: string | null;
}

export interface PremiumState {
  status: PremiumStatus;
  activeProductId: ProductId | null;
  lastPurchaseProductId: ProductId | null;
  tokenBalance: number;
  isUnlimited: boolean;
  restoreCount: number;
  subscriptionExpiresAt: string | null;
  lastSyncedAt: string | null;
}

export interface ChatSurfaceState {
  selectedCharacterId: string | null;
  lastFortuneType: FortuneTypeId | null;
  sentMessageCount: number;
}

export interface MobileAppState {
  profile: MobileProfileState;
  notifications: NotificationPreferences;
  premium: PremiumState;
  chat: ChatSurfaceState;
  updatedAt: string | null;
}

export interface MobileAppStatePatch {
  profile?: Partial<MobileProfileState>;
  notifications?: Partial<NotificationPreferences>;
  premium?: Partial<PremiumState>;
  chat?: Partial<ChatSurfaceState>;
  updatedAt?: string | null;
}

export const mobileAppStateStorageKey = 'fortune.mobile-app-state.v1';

export const emptyMobileAppState: MobileAppState = {
  profile: {
    displayName: '',
    birthDate: '',
    birthTime: '',
    mbti: '',
    bloodType: '',
    interestIds: [],
  },
  notifications: {
    push: true,
    dailyFortune: true,
    tokenAlert: true,
    characterDm: true,
    marketing: false,
    dailyFortuneTime: '07:00',
    permissionStatus: 'undetermined',
    devicePushToken: '',
    expoPushToken: '',
    lastSyncedAt: null,
  },
  premium: {
    status: 'inactive',
    activeProductId: null,
    lastPurchaseProductId: null,
    tokenBalance: 0,
    isUnlimited: false,
    restoreCount: 0,
    subscriptionExpiresAt: null,
    lastSyncedAt: null,
  },
  chat: {
    selectedCharacterId: null,
    lastFortuneType: null,
    sentMessageCount: 0,
  },
  updatedAt: null,
};

function asString(value: unknown) {
  return typeof value === 'string' ? value : '';
}

function asBoolean(value: unknown, fallback: boolean) {
  return typeof value === 'boolean' ? value : fallback;
}

function asNumber(value: unknown, fallback: number) {
  return typeof value === 'number' && Number.isFinite(value) ? value : fallback;
}

function isProductId(value: unknown): value is ProductId {
  return typeof value === 'string' && value in productCatalog;
}

function isFortuneTypeId(value: unknown): value is FortuneTypeId {
  return typeof value === 'string' && value in fortuneTypesById;
}

export function normalizeMobileAppState(raw: Record<string, unknown>): MobileAppState {
  const profile = (raw.profile ?? {}) as Record<string, unknown>;
  const notifications = (raw.notifications ?? {}) as Record<string, unknown>;
  const premium = (raw.premium ?? {}) as Record<string, unknown>;
  const chat = (raw.chat ?? {}) as Record<string, unknown>;
  const status = premium.status;

  return {
    profile: {
      displayName: asString(profile.displayName),
      birthDate: asString(profile.birthDate),
      birthTime: asString(profile.birthTime),
      mbti: asString(profile.mbti),
      bloodType: asString(profile.bloodType),
      interestIds: Array.isArray(profile.interestIds)
        ? profile.interestIds.filter(
            (value): value is string => typeof value === 'string',
          )
        : [],
    },
    notifications: {
      push: asBoolean(notifications.push, emptyMobileAppState.notifications.push),
      dailyFortune: asBoolean(
        notifications.dailyFortune ?? notifications.weeklyDigest,
        emptyMobileAppState.notifications.dailyFortune,
      ),
      tokenAlert: asBoolean(
        notifications.tokenAlert,
        emptyMobileAppState.notifications.tokenAlert,
      ),
      characterDm: asBoolean(
        notifications.characterDm ?? notifications.chatReminders,
        emptyMobileAppState.notifications.characterDm,
      ),
      marketing: asBoolean(
        notifications.marketing,
        emptyMobileAppState.notifications.marketing,
      ),
      dailyFortuneTime: asString(notifications.dailyFortuneTime) || '07:00',
      permissionStatus:
        notifications.permissionStatus === 'granted' ||
        notifications.permissionStatus === 'denied' ||
        notifications.permissionStatus === 'provisional'
          ? notifications.permissionStatus
          : 'undetermined',
      devicePushToken: asString(notifications.devicePushToken),
      expoPushToken: asString(notifications.expoPushToken),
      lastSyncedAt: asString(notifications.lastSyncedAt) || null,
    },
    premium: {
      status:
        status === 'subscription' || status === 'lifetime' || status === 'inactive'
          ? status
          : emptyMobileAppState.premium.status,
      activeProductId: isProductId(premium.activeProductId)
        ? premium.activeProductId
        : null,
      lastPurchaseProductId: isProductId(premium.lastPurchaseProductId)
        ? premium.lastPurchaseProductId
        : null,
      tokenBalance: asNumber(premium.tokenBalance, 0),
      isUnlimited: asBoolean(premium.isUnlimited, false),
      restoreCount: asNumber(premium.restoreCount, 0),
      subscriptionExpiresAt: asString(premium.subscriptionExpiresAt) || null,
      lastSyncedAt: asString(premium.lastSyncedAt) || null,
    },
    chat: {
      selectedCharacterId: asString(chat.selectedCharacterId) || null,
      lastFortuneType: isFortuneTypeId(chat.lastFortuneType)
        ? chat.lastFortuneType
        : null,
      sentMessageCount: asNumber(chat.sentMessageCount, 0),
    },
    updatedAt: asString(raw.updatedAt) || null,
  };
}

export function stampMobileAppState(state: MobileAppState): MobileAppState {
  return {
    ...state,
    updatedAt: new Date().toISOString(),
  };
}

export function mergeMobileAppState(
  current: MobileAppState,
  patch: MobileAppStatePatch,
): MobileAppState {
  return stampMobileAppState({
    ...current,
    ...patch,
    profile: {
      ...current.profile,
      ...patch.profile,
    },
    notifications: {
      ...current.notifications,
      ...patch.notifications,
    },
    premium: {
      ...current.premium,
      ...patch.premium,
    },
    chat: {
      ...current.chat,
      ...patch.chat,
    },
  });
}

export function applyProductPurchase(
  current: MobileAppState,
  productId: ProductId,
): MobileAppState {
  const product = productCatalog[productId];
  const nextPremium: PremiumState = {
    ...current.premium,
    lastPurchaseProductId: product.id,
    tokenBalance: current.premium.tokenBalance + product.points,
  };

  if (product.isSubscription) {
    nextPremium.status = 'subscription';
    nextPremium.activeProductId = product.id;
    nextPremium.subscriptionExpiresAt = null;
  } else if ('isNonConsumable' in product && product.isNonConsumable) {
    nextPremium.status = 'lifetime';
    nextPremium.activeProductId = product.id;
    nextPremium.subscriptionExpiresAt = null;
  }

  return mergeMobileAppState(current, {
    premium: nextPremium,
  });
}

export function applyPurchaseRestore(current: MobileAppState): MobileAppState {
  const nextPremium: PremiumState = {
    ...current.premium,
    restoreCount: current.premium.restoreCount + 1,
  };

  if (!nextPremium.activeProductId && nextPremium.lastPurchaseProductId) {
    const product = productCatalog[nextPremium.lastPurchaseProductId];

    if (product.isSubscription) {
      nextPremium.status = 'subscription';
      nextPremium.activeProductId = product.id;
      nextPremium.subscriptionExpiresAt = null;
    } else if ('isNonConsumable' in product && product.isNonConsumable) {
      nextPremium.status = 'lifetime';
      nextPremium.activeProductId = product.id;
      nextPremium.subscriptionExpiresAt = null;
    }
  }

  return mergeMobileAppState(current, {
    premium: nextPremium,
  });
}
