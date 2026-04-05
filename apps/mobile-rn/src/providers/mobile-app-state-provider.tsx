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
  }, [persist]);

  const saveProfile = useCallback(async (profile: Partial<MobileProfileState>) => {
    await persistFromCurrent((current) =>
      mergeMobileAppState(current, {
        profile,
      }),
    );
  }, [persistFromCurrent]);

  useEffect(() => {
    if (!session || status !== 'ready') {
      return;
    }

    const metadata = (session.user.user_metadata ?? {}) as Record<string, unknown>;

    const profileFromSession: Partial<MobileProfileState> = {
      displayName:
        state.profile.displayName ||
        (typeof metadata.name === 'string' ? metadata.name : '') ||
        (typeof metadata.full_name === 'string' ? metadata.full_name : '') ||
        session.user.email ||
        '',
      birthDate:
        state.profile.birthDate ||
        (typeof metadata.birth_date === 'string' ? metadata.birth_date : ''),
      birthTime:
        state.profile.birthTime ||
        (typeof metadata.birth_time === 'string' ? metadata.birth_time : ''),
      mbti:
        state.profile.mbti ||
        (typeof metadata.mbti === 'string' ? metadata.mbti : ''),
      bloodType:
        state.profile.bloodType ||
        (typeof metadata.blood_type === 'string' ? metadata.blood_type : ''),
    };

    const hasDelta = Object.entries(profileFromSession).some(
      ([key, value]) =>
        typeof value === 'string' &&
        value.length > 0 &&
        state.profile[key as keyof MobileProfileState] !== value,
    );

    if (!hasDelta) {
      if (
        profileFromSession.birthDate &&
        !onboardingProgress.birthCompleted
      ) {
        updateOnboardingProgress({ birthCompleted: true }).catch((error) => {
          captureError(error, {
            surface: 'mobile-app-state:session-hydration-gate',
          }).catch(() => undefined);
        });
      }
      return;
    }

    saveProfile(profileFromSession).catch((error) => {
      captureError(error, { surface: 'mobile-app-state:session-hydration' }).catch(
        () => undefined,
      );
    });
    if (
      profileFromSession.birthDate &&
      !onboardingProgress.birthCompleted
    ) {
      updateOnboardingProgress({ birthCompleted: true }).catch((error) => {
        captureError(error, {
          surface: 'mobile-app-state:session-hydration-gate',
        }).catch(() => undefined);
      });
    }
  }, [
    onboardingProgress.birthCompleted,
    saveProfile,
    session,
    state.profile,
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
