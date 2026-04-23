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
  endConnection,
  fetchProducts as fetchStoreProducts,
  finishTransaction as finishStoreTransaction,
  getAvailablePurchases as getAvailableStorePurchases,
  getReceiptDataIOS,
  initConnection,
  purchaseErrorListener,
  purchaseUpdatedListener,
  requestPurchase as requestStorePurchase,
  requestReceiptRefreshIOS,
  restorePurchases as restoreStorePurchases,
  type Product,
  type ProductSubscription,
  type Purchase,
} from 'expo-iap';
import {
  productCatalog,
  storefrontConsumableProductIds,
  storefrontNonConsumableProductIds,
  storefrontSubscriptionProductIds,
  type FortuneTypeId,
  type ProductId,
} from '@fortune/product-contracts';
import { Platform } from 'react-native';

import { captureError } from '../lib/error-reporting';
import {
  applyProductPurchase,
  emptyMobileAppState,
  mergeMobileAppState,
  type AppSettings,
  type MobileAppState,
  type MobileProfileState,
  type NotificationPreferences,
} from '../lib/mobile-app-state';
import {
  activateRemoteSubscription,
  fetchRemotePremiumSnapshot,
  verifyRemotePurchase,
  type RemotePremiumSnapshot,
} from '../lib/premium-remote';
import { buildOnboardingInterestWeights } from '../lib/onboarding-interest-catalog';
import { getMobileAppState, saveMobileAppState } from '../lib/storage';
import {
  ensureRemoteUserProfile,
  remoteProfileToOnboardingPatch,
  remoteProfileToPatch,
  updateRemoteUserProfile,
} from '../lib/user-profile-remote';
import { useAppBootstrap } from './app-bootstrap-provider';

type MobileAppStateStatus = 'loading' | 'ready';
type MobileStoreStatus = 'loading' | 'ready' | 'error';

interface StoreProductSnapshot {
  displayPrice: string;
  offerTokenAndroid: string | null;
}

const STORE_UNAVAILABLE_MESSAGE =
  '현재 빌드에서는 인앱 결제를 사용할 수 없어요.';

interface MobileAppStateContextValue {
  state: MobileAppState;
  status: MobileAppStateStatus;
  storeError: string | null;
  storePriceLabels: Partial<Record<ProductId, string>>;
  storeStatus: MobileStoreStatus;
  isPurchasePending: boolean;
  refreshStoreProducts: () => Promise<void>;
  refreshLocalState: () => Promise<void>;
  syncRemoteProfile: () => Promise<MobileAppState | null>;
  saveProfile: (profile: Partial<MobileProfileState>) => Promise<void>;
  saveNotifications: (
    notifications: Partial<NotificationPreferences>,
  ) => Promise<void>;
  saveSettings: (settings: Partial<AppSettings>) => Promise<void>;
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
  storeError: null,
  storePriceLabels: {},
  storeStatus: 'loading',
  isPurchasePending: false,
  refreshLocalState: async () => undefined,
  refreshStoreProducts: async () => undefined,
  syncRemoteProfile: async () => null,
  saveProfile: async () => undefined,
  saveNotifications: async () => undefined,
  saveSettings: async () => undefined,
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
    isUnlimited:
      snapshot.tokenBalance == null
        ? current.premium.isUnlimited
        : snapshot.isUnlimited,
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

function isProductId(value: unknown): value is ProductId {
  return typeof value === 'string' && value in productCatalog;
}

function isSubscriptionProductId(productId: ProductId) {
  return productCatalog[productId].isSubscription;
}

function isNonConsumableProductId(productId: ProductId) {
  const product = productCatalog[productId];
  return 'isNonConsumable' in product && product.isNonConsumable === true;
}

function isConsumableProductId(productId: ProductId) {
  const product = productCatalog[productId];
  return !product.isSubscription && !isNonConsumableProductId(productId);
}

function getStoreProductOfferToken(
  product: Product | ProductSubscription,
): string | null {
  if (product.platform !== 'android') {
    return null;
  }

  const offers =
    'subscriptionOffers' in product && Array.isArray(product.subscriptionOffers)
      ? product.subscriptionOffers
      : [];

  for (const offer of offers) {
    if (offer.offerTokenAndroid) {
      return offer.offerTokenAndroid;
    }
  }

  const legacyOffers =
    'subscriptionOfferDetailsAndroid' in product &&
    Array.isArray(product.subscriptionOfferDetailsAndroid)
      ? product.subscriptionOfferDetailsAndroid
      : [];

  return legacyOffers[0]?.offerToken ?? null;
}

function buildStoreProductSnapshotMap(
  items: readonly (Product | ProductSubscription)[],
): Partial<Record<ProductId, StoreProductSnapshot>> {
  const nextMap: Partial<Record<ProductId, StoreProductSnapshot>> = {};

  for (const product of items) {
    if (!isProductId(product.id)) {
      continue;
    }

    nextMap[product.id] = {
      displayPrice: product.displayPrice,
      offerTokenAndroid: getStoreProductOfferToken(product),
    };
  }

  return nextMap;
}

function getPurchaseProcessingKey(purchase: Purchase) {
  return `${purchase.productId}:${purchase.transactionId ?? purchase.id}`;
}

function isStoreNativeModuleError(error: unknown) {
  if (!(error instanceof Error)) {
    return false;
  }

  return (
    error.message.includes("Cannot find native module 'ExpoIap'") ||
    error.message.includes("Cannot find native module 'Expolap'") ||
    error.message.includes('ExpoIap native module is unavailable') ||
    error.message.includes('expo-iap')
  );
}

function isExpectedStoreUnavailableError(error: unknown) {
  if (!(error instanceof Error)) {
    return false;
  }

  return (
    isStoreNativeModuleError(error) ||
    error.message.includes('Failed to initialize billing connection') ||
    error.message.includes('Billing is not prepared') ||
    error.message.includes('billing is not prepared') ||
    error.message.includes('StoreKit is not available') ||
    error.message.includes('not available on simulator')
  );
}

function getPurchasePlatform(): 'ios' | 'android' {
  return Platform.OS === 'ios' ? 'ios' : 'android';
}

const IOS_RECEIPT_REFRESH_DELAYS_MS = [0, 500, 1500];

async function getIosReceiptDataForVerification() {
  if (Platform.OS !== 'ios') {
    return null;
  }

  const existingReceipt = await getReceiptDataIOS().catch(() => '');

  if (existingReceipt) {
    return existingReceipt;
  }

  for (let attempt = 0; attempt < IOS_RECEIPT_REFRESH_DELAYS_MS.length; attempt += 1) {
    const delay = IOS_RECEIPT_REFRESH_DELAYS_MS[attempt];
    if (delay > 0) {
      await new Promise((resolve) => setTimeout(resolve, delay));
    }

    const refreshed = await requestReceiptRefreshIOS().catch((err) => {
      console.warn(
        `[iap] receipt refresh attempt ${attempt + 1} failed: ${err?.message ?? err}`,
      );
      return '';
    });

    if (refreshed) {
      return refreshed;
    }
  }

  return null;
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
  const [storeStatus, setStoreStatus] = useState<MobileStoreStatus>('loading');
  const [storeError, setStoreError] = useState<string | null>(null);
  const [isStoreRuntimeAvailable, setIsStoreRuntimeAvailable] = useState(true);
  const [storeProducts, setStoreProducts] = useState<
    Partial<Record<ProductId, StoreProductSnapshot>>
  >({});
  const [isPurchasePending, setIsPurchasePending] = useState(false);
  const activeUserId = session?.user.id ?? null;
  const activeUserIdRef = useRef<string | null>(activeUserId);
  const sessionRef = useRef(session);
  const storeProductsRef = useRef<
    Partial<Record<ProductId, StoreProductSnapshot>>
  >({});
  const processedPurchaseKeysRef = useRef<Set<string>>(new Set());
  const queuedPurchasesRef = useRef<Map<string, Purchase>>(new Map());
  const writeQueueRef = useRef<Promise<void>>(Promise.resolve());

  useEffect(() => {
    activeUserIdRef.current = activeUserId;
  }, [activeUserId]);

  useEffect(() => {
    sessionRef.current = session;
  }, [session]);

  useEffect(() => {
    storeProductsRef.current = storeProducts;
  }, [storeProducts]);

  const runSerialized = useCallback(async <T,>(
    operation: () => Promise<T>,
  ): Promise<T> => {
    const previousWrite = writeQueueRef.current;
    let releaseQueue: () => void = () => undefined;

    writeQueueRef.current = new Promise<void>((resolve) => {
      releaseQueue = resolve;
    });

    // Wait for previous write with a 3s timeout to prevent deadlocks
    // (e.g. SecureStore hangs in Expo Go)
    try {
      await Promise.race([
        previousWrite,
        new Promise<void>((resolve) => setTimeout(resolve, 3000)),
      ]);
    } catch {
      // Previous write rejected — safe to proceed, we just needed it to settle.
    }

    try {
      // Run the operation with a 5s timeout so a hanging operation
      // (e.g. SecureStore on Expo Go) doesn't deadlock the entire queue.
      const result = await Promise.race([
        operation(),
        new Promise<never>((_, reject) =>
          setTimeout(
            () => reject(new Error('runSerialized: operation timed out after 5 s')),
            5000,
          ),
        ),
      ]);
      return result;
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

      if ('interestIds' in profile) {
        remoteUpdates.fortune_preferences =
          nextState.profile.interestIds.length > 0
            ? {
                category_weights: buildOnboardingInterestWeights(
                  nextState.profile.interestIds,
                ),
                showPersonalized: true,
              }
            : {
                category_weights: {},
                showPersonalized: true,
              };
        remoteUpdates.onboarding_completed =
          nextState.profile.interestIds.length > 0;
      }

      if (Object.keys(remoteUpdates).length === 0) {
        return;
      }

      ensureRemoteUserProfile(session)
        .then(() => updateRemoteUserProfile(session.user.id, remoteUpdates))
        .catch((error) => {
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

  const refreshLocalState = useCallback(async () => {
    try {
      const freshState = await getMobileAppState(activeUserIdRef.current);
      setState(freshState);
    } catch (error) {
      await captureError(error, { surface: 'mobile-app-state:refresh-local' });
    }
  }, []);

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

  const saveSettings = useCallback(
    async (settings: Partial<AppSettings>) => {
      await persistFromCurrent((current) =>
        mergeMobileAppState(current, { settings }),
      );
    },
    [persistFromCurrent],
  );

  const refreshStoreProducts = useCallback(async () => {
    if (!isStoreRuntimeAvailable) {
      setStoreStatus('error');
      setStoreError(STORE_UNAVAILABLE_MESSAGE);
      return;
    }

    setStoreStatus('loading');
    setStoreError(null);

    try {
      await initConnection();

      const [inAppProducts, subscriptionProducts] = await Promise.all([
        fetchStoreProducts({
          skus: [
            ...storefrontConsumableProductIds,
            ...storefrontNonConsumableProductIds,
          ],
          type: 'in-app',
        }),
        fetchStoreProducts({
          skus: [...storefrontSubscriptionProductIds],
          type: 'subs',
        }),
      ]);

      const nextStoreProducts = buildStoreProductSnapshotMap([
        ...((inAppProducts ?? []) as (Product | ProductSubscription)[]),
        ...((subscriptionProducts ?? []) as (Product | ProductSubscription)[]),
      ]);

      setStoreProducts(nextStoreProducts);
      setStoreStatus('ready');
      setIsStoreRuntimeAvailable(true);
    } catch (error) {
      setStoreStatus('error');
      if (isExpectedStoreUnavailableError(error)) {
        setIsStoreRuntimeAvailable(false);
        setStoreError(STORE_UNAVAILABLE_MESSAGE);
      } else {
        setStoreError('스토어 상품 정보를 불러오지 못했어요.');
        await captureError(error, {
          surface: 'mobile-app-state:store-products',
        });
      }
    }
  }, [isStoreRuntimeAvailable]);

  const processQueuedPurchase = useCallback(
    async (
      purchase: Purchase,
      currentSession: NonNullable<typeof sessionRef.current>,
    ) => {
      const productId = purchase.productId;

      if (!isProductId(productId)) {
        return;
      }

      const processingKey = getPurchaseProcessingKey(purchase);

      if (processedPurchaseKeysRef.current.has(processingKey)) {
        return;
      }

      processedPurchaseKeysRef.current.add(processingKey);
      queuedPurchasesRef.current.delete(processingKey);
      setIsPurchasePending(true);

      try {
        const receipt =
          Platform.OS === 'ios' ? await getIosReceiptDataForVerification() : null;

        if (Platform.OS === 'ios' && !receipt) {
          throw new Error('iOS 영수증을 읽지 못해 구매를 확인할 수 없어요.');
        }

        const verification = await verifyRemotePurchase(currentSession, {
          platform: getPurchasePlatform(),
          productId,
          purchaseToken: purchase.purchaseToken ?? null,
          receipt,
          transactionId: purchase.transactionId ?? purchase.id,
        });

        if (isSubscriptionProductId(productId)) {
          await activateRemoteSubscription(currentSession, {
            platform: getPurchasePlatform(),
            productId,
            purchaseId: verification.transactionId,
          });
        } else if (isNonConsumableProductId(productId)) {
          await persistFromCurrent(
            (current) => applyProductPurchase(current, productId),
            currentSession.user.id,
          );
        }

        await finishStoreTransaction({
          purchase,
          isConsumable: isConsumableProductId(productId),
        });

        await syncRemoteProfile();
      } catch (error) {
        processedPurchaseKeysRef.current.delete(processingKey);
        await captureError(error, {
          productId,
          surface: 'mobile-app-state:purchase-updated',
        });
      } finally {
        setIsPurchasePending(false);
      }
    },
    [persistFromCurrent, syncRemoteProfile],
  );

  useEffect(() => {
    if (!isStoreRuntimeAvailable) {
      setStoreStatus('error');
      setStoreError(STORE_UNAVAILABLE_MESSAGE);

      return () => undefined;
    }

    let purchaseUpdatedSubscription: { remove: () => void } | null = null;
    let purchaseErrorSubscription: { remove: () => void } | null = null;
    let shouldEndConnection = false;

    try {
      purchaseUpdatedSubscription = purchaseUpdatedListener((purchase) => {
        const productId = purchase.productId;

        if (!isProductId(productId)) {
          return;
        }

        const processingKey = getPurchaseProcessingKey(purchase);

        if (
          processedPurchaseKeysRef.current.has(processingKey) ||
          queuedPurchasesRef.current.has(processingKey)
        ) {
          return;
        }

        const currentSession = sessionRef.current;

        if (!currentSession) {
          queuedPurchasesRef.current.set(processingKey, purchase);
          return;
        }

        void processQueuedPurchase(purchase, currentSession);
      });

      purchaseErrorSubscription = purchaseErrorListener((error) => {
        setIsPurchasePending(false);
        if (isExpectedStoreUnavailableError(new Error(error.message))) {
          setIsStoreRuntimeAvailable(false);
          setStoreStatus('error');
          setStoreError(STORE_UNAVAILABLE_MESSAGE);
          return;
        }

        void captureError(new Error(error.message), {
          productId: error.productId ?? undefined,
          surface: 'mobile-app-state:purchase-error',
        });
      });

      // Lazy StoreKit init — cold-start 시 initConnection / fetchStoreProducts
      // 호출하면 iOS 가 App Store (실제 계정) 또는 Sandbox Apple ID 재인증을
      // 요구해 "Sign in to Apple Account" prompt 가 반복 노출된다. 앱 부팅 경로
      // 에서는 이 연결을 열지 않고, 프리미엄 화면이 열릴 때 `refreshStoreProducts`
      // 가 호출되는 시점에 처음 연결을 연다.
      //
      // Listener 2개는 여기서 먼저 부착한다. 이전 세션에서 pending 이던 트랜잭션이
      // iOS StoreKit 내부에서 emit 될 수 있어, 누락 방지 위해 조기 등록.
      // shouldEndConnection 은 여전히 true — refreshStoreProducts 가 호출되어
      // 연결이 열린 후 provider 가 unmount 되면 cleanup 이 endConnection 호출.
      shouldEndConnection = true;
    } catch (error) {
      setStoreStatus('error');
      setIsStoreRuntimeAvailable(false);
      setStoreError(
        isExpectedStoreUnavailableError(error)
          ? STORE_UNAVAILABLE_MESSAGE
          : '스토어 기능을 초기화하지 못했어요.',
      );
      if (!isExpectedStoreUnavailableError(error)) {
        void captureError(error, {
          surface: 'mobile-app-state:store-runtime-init',
        });
      }
    }

    return () => {
      purchaseUpdatedSubscription?.remove();
      purchaseErrorSubscription?.remove();

      if (shouldEndConnection) {
        void endConnection().catch(() => undefined);
      }
    };
  }, [isStoreRuntimeAvailable, processQueuedPurchase, refreshStoreProducts]);

  useEffect(() => {
    if (!session || queuedPurchasesRef.current.size === 0) {
      return;
    }

    for (const purchase of queuedPurchasesRef.current.values()) {
      void processQueuedPurchase(purchase, session);
    }
  }, [processQueuedPurchase, session]);

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
      if (!isStoreRuntimeAvailable) {
        throw new Error(STORE_UNAVAILABLE_MESSAGE);
      }

      if (!sessionRef.current) {
        throw new Error('로그인 후 상품을 구매할 수 있어요.');
      }

      if (isPurchasePending) {
        throw new Error('이미 구매가 진행 중이에요.');
      }

      let storeProduct = storeProductsRef.current[productId];

      if (!storeProduct) {
        await refreshStoreProducts();
        storeProduct = storeProductsRef.current[productId];
      }

      if (!storeProduct) {
        throw new Error('스토어에서 상품 정보를 찾지 못했어요.');
      }

      setIsPurchasePending(true);

      try {
        if (isSubscriptionProductId(productId)) {
          await requestStorePurchase({
            type: 'subs',
            request: {
              apple: { sku: productId },
              google: storeProduct.offerTokenAndroid
                ? {
                    skus: [productId],
                    subscriptionOffers: [
                      {
                        offerToken: storeProduct.offerTokenAndroid,
                        sku: productId,
                      },
                    ],
                  }
                : { skus: [productId] },
            },
          });
          return;
        }

        await requestStorePurchase({
          type: 'in-app',
          request: {
            apple: { sku: productId },
            google: { skus: [productId] },
          },
        });
      } catch (error) {
        setIsPurchasePending(false);
        if (isExpectedStoreUnavailableError(error)) {
          setIsStoreRuntimeAvailable(false);
          setStoreStatus('error');
          setStoreError(STORE_UNAVAILABLE_MESSAGE);
          throw new Error(STORE_UNAVAILABLE_MESSAGE);
        }

        await captureError(error, {
          productId,
          surface: 'mobile-app-state:purchase-request',
        });
        throw error;
      }
    },
    [isPurchasePending, isStoreRuntimeAvailable, refreshStoreProducts],
  );

  const restorePurchases = useCallback(async () => {
    if (!isStoreRuntimeAvailable) {
      throw new Error(STORE_UNAVAILABLE_MESSAGE);
    }

    const currentSession = sessionRef.current;

    if (!currentSession) {
      throw new Error('로그인 후 이전 구매를 복원할 수 있어요.');
    }

    setIsPurchasePending(true);

    try {
      await restoreStorePurchases();

      const availablePurchases = await getAvailableStorePurchases({
        onlyIncludeActiveItemsIOS: Platform.OS === 'ios' ? true : null,
      });

      for (const purchase of availablePurchases) {
        const productId = purchase.productId;

        if (!isProductId(productId)) {
          continue;
        }

        if (isSubscriptionProductId(productId)) {
          await activateRemoteSubscription(currentSession, {
            platform: getPurchasePlatform(),
            productId,
            purchaseId: purchase.transactionId ?? purchase.id,
          });
          continue;
        }

        if (isNonConsumableProductId(productId)) {
          await persistFromCurrent(
            (current) => applyProductPurchase(current, productId),
            currentSession.user.id,
          );
        }
      }

      await persistFromCurrent((current) =>
        mergeMobileAppState(current, {
          premium: {
            restoreCount: current.premium.restoreCount + 1,
          },
        }),
      );

      await syncRemoteProfile();
    } catch (error) {
      if (isExpectedStoreUnavailableError(error)) {
        setIsStoreRuntimeAvailable(false);
        setStoreStatus('error');
        setStoreError(STORE_UNAVAILABLE_MESSAGE);
        throw new Error(STORE_UNAVAILABLE_MESSAGE);
      }

      await captureError(error, {
        surface: 'mobile-app-state:restore-purchases',
      });
      throw error;
    } finally {
      setIsPurchasePending(false);
    }
  }, [isStoreRuntimeAvailable, persistFromCurrent, syncRemoteProfile]);

  const value = useMemo(
    () => ({
      isPurchasePending,
      refreshLocalState,
      refreshStoreProducts,
      state,
      status,
      storeError,
      storePriceLabels: Object.fromEntries(
        Object.entries(storeProducts)
          .filter((entry): entry is [string, StoreProductSnapshot] => entry[1] != null)
          .map(([productId, product]) => [productId, product.displayPrice]),
      ) as Partial<Record<ProductId, string>>,
      storeStatus,
      syncRemoteProfile,
      saveProfile,
      saveNotifications,
      saveSettings,
      recordChatIntent,
      purchaseProduct,
      restorePurchases,
    }),
    [
      isPurchasePending,
      purchaseProduct,
      refreshLocalState,
      refreshStoreProducts,
      recordChatIntent,
      restorePurchases,
      saveNotifications,
      saveProfile,
      saveSettings,
      state,
      status,
      storeError,
      storeProducts,
      storeStatus,
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
