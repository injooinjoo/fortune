import {
  useCallback,
  createContext,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
  type PropsWithChildren,
} from 'react';

import {
  productCatalog,
  type FortuneTypeId,
  type ProductId,
} from '@fortune/product-contracts';

import { captureError } from '../lib/error-reporting';
import {
  emptyMobileAppState,
  mergeMobileAppState,
  type MobileAppState,
  type MobileProfileState,
  type NotificationPreferences,
} from '../lib/mobile-app-state';
import {
  fetchRemotePremiumSnapshot,
  type RemotePremiumSnapshot,
} from '../lib/premium-remote';
import { getMobileAppState, saveMobileAppState } from '../lib/storage';
import {
  ensureRemoteUserProfile,
  remoteProfileToOnboardingPatch,
  remoteProfileToPatch,
  updateRemoteUserProfile,
} from '../lib/user-profile-remote';
import { useAppBootstrap } from './app-bootstrap-provider';

type MobileAppStateStatus = 'loading' | 'ready';

interface MobileAppStateContextValue {
  state: MobileAppState;
  status: MobileAppStateStatus;
  syncRemoteProfile: () => Promise<MobileAppState | null>;
  saveProfile: (profile: Partial<MobileProfileState>) => Promise<void>;
  saveNotifications: (
    notifications: Partial<NotificationPreferences>,
  ) => Promise<void>;
  recordChatIntent: (payload: {
    characterId?: string | null;
    fortuneType?: FortuneTypeId | null;
    incrementMessages?: boolean;
  }) => Promise<void>;
  purchaseProduct: (productId: ProductId) => Promise<void>;
  restorePurchases: () => Promise<void>;
}

const MobileAppStateContext = createContext<MobileAppStateContextValue>({
  state: emptyMobileAppState,
  status: 'loading',
  syncRemoteProfile: async () => null,
  saveProfile: async () => undefined,
  saveNotifications: async () => undefined,
  recordChatIntent: async () => undefined,
  purchaseProduct: async () => undefined,
  restorePurchases: async () => undefined,
});

function mergeRemotePremiumIntoState(
  current: MobileAppState,
  snapshot: RemotePremiumSnapshot,
) {
  const currentActiveProduct = current.premium.activeProductId
    ? productCatalog[current.premium.activeProductId]
    : null;
  const keepLifetime =
    current.premium.status === 'lifetime' ||
    (currentActiveProduct != null &&
      'isNonConsumable' in currentActiveProduct &&
      currentActiveProduct.isNonConsumable === true);
  const nextPremium = {
    ...current.premium,
    lastSyncedAt: snapshot.syncedAt,
    tokenBalance: snapshot.tokenBalance ?? current.premium.tokenBalance,
  };

  if (snapshot.activeSubscriptionProductId) {
    nextPremium.status = 'subscription';
    nextPremium.activeProductId = snapshot.activeSubscriptionProductId;
    nextPremium.subscriptionExpiresAt = snapshot.subscriptionExpiresAt;
    nextPremium.lastPurchaseProductId =
      current.premium.lastPurchaseProductId ?? snapshot.activeSubscriptionProductId;
  } else {
    nextPremium.subscriptionExpiresAt = null;

    if (
      keepLifetime &&
      currentActiveProduct != null &&
      'isNonConsumable' in currentActiveProduct &&
      currentActiveProduct.isNonConsumable
    ) {
      nextPremium.status = 'lifetime';
      nextPremium.activeProductId = currentActiveProduct.id;
    } else {
      nextPremium.status = 'inactive';
      nextPremium.activeProductId = null;
    }
  }

  return mergeMobileAppState(current, {
    premium: nextPremium,
  });
}

export function MobileAppStateProvider({ children }: PropsWithChildren) {
  const {
    onboardingProgress,
    session,
    status: bootstrapStatus,
    updateOnboardingProgress,
  } = useAppBootstrap();
  const [state, setState] = useState<MobileAppState>(emptyMobileAppState);
  const [status, setStatus] = useState<MobileAppStateStatus>('loading');
  const activeUserId = session?.user.id ?? null;
  const activeUserIdRef = useRef<string | null>(activeUserId);
  const writeQueueRef = useRef<Promise<void>>(Promise.resolve());

  useEffect(() => {
    activeUserIdRef.current = activeUserId;
  }, [activeUserId]);

  const runSerialized = useCallback(async <T,>(
    operation: () => Promise<T>,
  ): Promise<T> => {
    const previousWrite = writeQueueRef.current;
    let releaseQueue: () => void = () => undefined;

    writeQueueRef.current = new Promise<void>((resolve) => {
      releaseQueue = resolve;
    });

    await previousWrite;

    try {
      return await operation();
    } finally {
      releaseQueue();
    }
  }, []);

  useEffect(() => {
    if (bootstrapStatus !== 'ready') {
      setStatus('loading');
      return;
    }

    let cancelled = false;
    const targetUserId = activeUserId;

    activeUserIdRef.current = targetUserId;
    setStatus('loading');

    async function loadScopedState() {
      try {
        const nextState = await runSerialized(() => getMobileAppState(targetUserId));

        if (cancelled || activeUserIdRef.current !== targetUserId) {
          return;
        }

        setState(nextState);
      } catch (error) {
        await captureError(error, { surface: 'mobile-app-state:init' });

        if (!cancelled && activeUserIdRef.current === targetUserId) {
          setState(emptyMobileAppState);
        }
      } finally {
        if (!cancelled && activeUserIdRef.current === targetUserId) {
          setStatus('ready');
        }
      }
    }

    void loadScopedState();

    return () => {
      cancelled = true;
    };
  }, [activeUserId, bootstrapStatus, runSerialized]);

  const persistFromCurrent = useCallback(
    async (
      recipe: (current: MobileAppState) => MobileAppState,
      targetUserId: string | null = activeUserIdRef.current,
    ) =>
      runSerialized(async () => {
        const current = await getMobileAppState(targetUserId);
        const nextState = recipe(current);

        await saveMobileAppState(nextState, targetUserId);

        if (activeUserIdRef.current === targetUserId) {
          setState(nextState);
        }

        return nextState;
      }),
    [runSerialized],
  );

  const saveProfile = useCallback(
    async (profile: Partial<MobileProfileState>) => {
      const nextState = await persistFromCurrent((current) =>
        mergeMobileAppState(current, {
          profile,
        }),
      );

      if (nextState.profile.birthDate && !onboardingProgress.birthCompleted) {
        updateOnboardingProgress({
          birthCompleted: true,
        }).catch((error) => {
          captureError(error, {
            surface: 'mobile-app-state:save-profile-gate',
          }).catch(() => undefined);
        });
      }

      if (!session) {
        return;
      }

      const remoteUpdates: Record<string, unknown> = {};

      if ('displayName' in profile) {
        remoteUpdates.name = nextState.profile.displayName || null;
      }

      if ('birthDate' in profile) {
        remoteUpdates.birth_date = nextState.profile.birthDate || null;
      }

      if ('birthTime' in profile) {
        remoteUpdates.birth_time = nextState.profile.birthTime || null;
      }

      if ('mbti' in profile) {
        remoteUpdates.mbti = nextState.profile.mbti || null;
      }

      if ('bloodType' in profile) {
        remoteUpdates.blood_type = nextState.profile.bloodType || null;
      }

      if (Object.keys(remoteUpdates).length === 0) {
        return;
      }

      updateRemoteUserProfile(session.user.id, remoteUpdates).catch((error) => {
        captureError(error, {
          surface: 'mobile-app-state:save-profile-remote',
        }).catch(() => undefined);
      });
    },
    [onboardingProgress.birthCompleted, persistFromCurrent, session, updateOnboardingProgress],
  );

  const syncRemoteProfile = useCallback(async (): Promise<MobileAppState | null> => {
    if (!session || bootstrapStatus !== 'ready' || status !== 'ready') {
      return null;
    }

    const targetUserId = session.user.id;
    const [remoteProfile, remotePremium] = await Promise.all([
      ensureRemoteUserProfile(session),
      fetchRemotePremiumSnapshot(session).catch((error) => {
        captureError(error, {
          surface: 'mobile-app-state:premium-sync',
        }).catch(() => undefined);

        return null;
      }),
    ]);

    if (!remoteProfile || activeUserIdRef.current !== targetUserId) {
      return null;
    }

    const nextState = await persistFromCurrent(
      (current) => {
        const profileState = mergeMobileAppState(
          current,
          remoteProfileToPatch(remoteProfile),
        );

        if (!remotePremium) {
          return profileState;
        }

        return mergeRemotePremiumIntoState(profileState, remotePremium);
      },
      targetUserId,
    );
    const onboardingPatch = remoteProfileToOnboardingPatch(remoteProfile);
    const shouldUpdateOnboarding =
      onboardingProgress.birthCompleted !== onboardingPatch.birthCompleted ||
      onboardingProgress.interestCompleted !== onboardingPatch.interestCompleted;

    if (shouldUpdateOnboarding) {
      await updateOnboardingProgress(onboardingPatch);
    }

    return nextState;
  }, [
    bootstrapStatus,
    onboardingProgress.birthCompleted,
    onboardingProgress.interestCompleted,
    persistFromCurrent,
    session,
    status,
    updateOnboardingProgress,
  ]);

  useEffect(() => {
    let cancelled = false;

    if (!session || bootstrapStatus !== 'ready' || status !== 'ready') {
      return () => {
        cancelled = true;
      };
    }

    syncRemoteProfile().catch((error) => {
      if (cancelled) {
        return;
      }

      captureError(error, { surface: 'mobile-app-state:remote-sync' }).catch(
        () => undefined,
      );
    });

    return () => {
      cancelled = true;
    };
  }, [bootstrapStatus, session, status, syncRemoteProfile]);

  const saveNotifications = useCallback(
    async (notifications: Partial<NotificationPreferences>) => {
      await persistFromCurrent((current) =>
        mergeMobileAppState(current, {
          notifications,
        }),
      );
    },
    [persistFromCurrent],
  );

  const recordChatIntent = useCallback(
    async (payload: {
      characterId?: string | null;
      fortuneType?: FortuneTypeId | null;
      incrementMessages?: boolean;
    }) => {
      await persistFromCurrent((current) =>
        mergeMobileAppState(current, {
          chat: {
            selectedCharacterId:
              payload.characterId ?? current.chat.selectedCharacterId,
            lastFortuneType: payload.fortuneType ?? current.chat.lastFortuneType,
            sentMessageCount:
              current.chat.sentMessageCount + (payload.incrementMessages ? 1 : 0),
          },
        }),
      );
    },
    [persistFromCurrent],
  );

  const purchaseProduct = useCallback(
    async (_productId: ProductId) => {
      throw new Error(
        'RN 스토어 구매 엔진은 아직 연결되지 않았습니다. 현재는 실제 구독 상태 조회와 복원, 구독 관리만 지원합니다.',
      );
    },
    [],
  );

  const restorePurchases = useCallback(async () => {
    await persistFromCurrent((current) =>
      mergeMobileAppState(current, {
        premium: {
          restoreCount: current.premium.restoreCount + 1,
        },
      }),
    );

    await syncRemoteProfile();
  }, [persistFromCurrent, syncRemoteProfile]);

  const value = useMemo(
    () => ({
      state,
      status,
      syncRemoteProfile,
      saveProfile,
      saveNotifications,
      recordChatIntent,
      purchaseProduct,
      restorePurchases,
    }),
    [
      purchaseProduct,
      recordChatIntent,
      restorePurchases,
      saveNotifications,
      saveProfile,
      state,
      status,
      syncRemoteProfile,
    ],
  );

  return (
    <MobileAppStateContext.Provider value={value}>
      {children}
    </MobileAppStateContext.Provider>
  );
}

export function useMobileAppState() {
  return useContext(MobileAppStateContext);
}
