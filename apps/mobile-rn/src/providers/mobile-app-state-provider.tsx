import {
  useCallback,
  createContext,
  useContext,
  useEffect,
  useMemo,
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
  type NotificationPreferences,
  type MobileProfileState,
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
  saveProfile: async () => undefined,
  saveNotifications: async () => undefined,
  recordChatIntent: async () => undefined,
  purchaseProduct: async () => undefined,
  restorePurchases: async () => undefined,
});

export function MobileAppStateProvider({ children }: PropsWithChildren) {
  const { onboardingProgress, session, updateOnboardingProgress } =
    useAppBootstrap();
  const [state, setState] = useState<MobileAppState>(emptyMobileAppState);
  const [status, setStatus] = useState<MobileAppStateStatus>('loading');

  useEffect(() => {
    let mounted = true;

    async function bootstrap() {
      try {
        const nextState = await getMobileAppState();

        if (mounted) {
          setState(nextState);
        }
      } catch (error) {
        await captureError(error, { surface: 'mobile-app-state:init' });
      } finally {
        if (mounted) {
          setStatus('ready');
        }
      }
    }

    void bootstrap();

    return () => {
      mounted = false;
    };
  }, []);

  const persist = useCallback(async (nextState: MobileAppState) => {
    await saveMobileAppState(nextState);
    setState(nextState);
  }, []);

  const persistFromCurrent = useCallback(async (
    recipe: (current: MobileAppState) => MobileAppState,
  ) => {
    const current = await getMobileAppState();
    const nextState = recipe(current);
    await persist(nextState);
    return nextState;
  }, [persist]);

  const saveProfile = useCallback(async (profile: Partial<MobileProfileState>) => {
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

    const remoteUpdates: Record<string, unknown> = {
      name: nextState.profile.displayName || null,
      birth_date: nextState.profile.birthDate || null,
      birth_time: nextState.profile.birthTime || null,
      mbti: nextState.profile.mbti || null,
      blood_type: nextState.profile.bloodType || null,
      onboarding_completed:
        Boolean(nextState.profile.birthDate) &&
        Boolean(nextState.profile.birthTime),
    };

    updateRemoteUserProfile(session.user.id, remoteUpdates).catch((error) => {
      captureError(error, { surface: 'mobile-app-state:save-profile-remote' }).catch(
        () => undefined,
      );
    });
  }, [
    onboardingProgress.birthCompleted,
    persistFromCurrent,
    session,
    updateOnboardingProgress,
  ]);

  useEffect(() => {
    if (!session || status !== 'ready') {
      return;
    }

    const currentSession = session;
    let cancelled = false;

    async function syncRemoteProfile() {
      try {
        const remoteProfile = await ensureRemoteUserProfile(currentSession);

        if (cancelled || !remoteProfile) {
          return;
        }

        const nextState = await persistFromCurrent((current) =>
          mergeMobileAppState(current, remoteProfileToPatch(remoteProfile)),
        );

        const onboardingPatch = remoteProfileToOnboardingPatch(remoteProfile);
        const shouldUpdateOnboarding =
          onboardingProgress.softGateCompleted !== onboardingPatch.softGateCompleted ||
          onboardingProgress.authCompleted !== onboardingPatch.authCompleted ||
          onboardingProgress.birthCompleted !== onboardingPatch.birthCompleted ||
          onboardingProgress.interestCompleted !== onboardingPatch.interestCompleted ||
          onboardingProgress.firstRunHandoffSeen !== onboardingPatch.firstRunHandoffSeen;

        if (shouldUpdateOnboarding) {
          await updateOnboardingProgress(onboardingPatch);
        }

        if (cancelled) {
          return;
        }

        setState(nextState);
      } catch (error) {
        await captureError(error, { surface: 'mobile-app-state:remote-sync' });
      }
    }

    void syncRemoteProfile();

    return () => {
      cancelled = true;
    };
  }, [
    onboardingProgress.authCompleted,
    onboardingProgress.birthCompleted,
    onboardingProgress.firstRunHandoffSeen,
    onboardingProgress.interestCompleted,
    onboardingProgress.softGateCompleted,
    persistFromCurrent,
    session,
    status,
    updateOnboardingProgress,
  ]);

  const saveNotifications = useCallback(async (
    notifications: Partial<NotificationPreferences>,
  ) => {
    await persistFromCurrent((current) =>
      mergeMobileAppState(current, {
        notifications,
      }),
    );
  }, [persistFromCurrent]);

  const recordChatIntent = useCallback(async (payload: {
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
  }, [persistFromCurrent]);

  const purchaseProduct = useCallback(async (productId: ProductId) => {
    await persistFromCurrent((current) => applyProductPurchase(current, productId));
  }, [persistFromCurrent]);

  const restorePurchases = useCallback(async () => {
    await persistFromCurrent((current) => applyPurchaseRestore(current));
  }, [persistFromCurrent]);

  const value = useMemo(
    () => ({
      state,
      status,
      saveProfile,
      saveNotifications,
      recordChatIntent,
      purchaseProduct,
      restorePurchases,
    }),
    [purchaseProduct, recordChatIntent, restorePurchases, saveNotifications, saveProfile, state, status],
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
