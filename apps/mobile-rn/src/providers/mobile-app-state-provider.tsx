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

import { type FortuneTypeId, type ProductId } from '@fortune/product-contracts';

import { captureError } from '../lib/error-reporting';
import {
  applyProductPurchase,
  applyPurchaseRestore,
  emptyMobileAppState,
  mergeMobileAppState,
  type MobileAppState,
  type MobileProfileState,
  type NotificationPreferences,
} from '../lib/mobile-app-state';
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
    const remoteProfile = await ensureRemoteUserProfile(session);

    if (!remoteProfile || activeUserIdRef.current !== targetUserId) {
      return null;
    }

    const nextState = await persistFromCurrent(
      (current) => mergeMobileAppState(current, remoteProfileToPatch(remoteProfile)),
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
    async (productId: ProductId) => {
      await persistFromCurrent((current) =>
        applyProductPurchase(current, productId),
      );
    },
    [persistFromCurrent],
  );

  const restorePurchases = useCallback(async () => {
    await persistFromCurrent((current) => applyPurchaseRestore(current));
  }, [persistFromCurrent]);

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
