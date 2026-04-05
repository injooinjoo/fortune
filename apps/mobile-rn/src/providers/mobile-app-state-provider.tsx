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
