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
  storeError: null,
  storePriceLabels: {},
  storeStatus: 'loading',
  isPurchasePending: false,
  refreshStoreProducts: async () => undefined,
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

function getPurchasePlatform(): 'ios' | 'android' {
  return Platform.OS === 'ios' ? 'ios' : 'android';
}

async function getIosReceiptDataForVerification() {
  if (Platform.OS !== 'ios') {
    return null;
  }

  const existingReceipt = await getReceiptDataIOS().catch(() => '');

  if (existingReceipt) {
    return existingReceipt;
  }

  const refreshedReceipt = await requestReceiptRefreshIOS().catch(() => '');
  return refreshedReceipt || null;
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
      if (isStoreNativeModuleError(error)) {
        setIsStoreRuntimeAvailable(false);
        setStoreError(STORE_UNAVAILABLE_MESSAGE);
      } else {
        setStoreError('스토어 상품 정보를 불러오지 못했어요.');
      }
      await captureError(error, {
        surface: 'mobile-app-state:store-products',
      });
    }
  }, [isStoreRuntimeAvailable]);

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

        if (processedPurchaseKeysRef.current.has(processingKey)) {
          return;
        }

        processedPurchaseKeysRef.current.add(processingKey);
        setIsPurchasePending(true);

        const currentSession = sessionRef.current;

        if (!currentSession) {
          processedPurchaseKeysRef.current.delete(processingKey);
          setIsPurchasePending(false);
          void captureError(new Error('구매 처리 시 로그인 세션이 없습니다.'), {
            productId,
            surface: 'mobile-app-state:purchase-updated-without-session',
          });
          return;
        }

        void (async () => {
          try {
            const receipt =
              Platform.OS === 'ios'
                ? await getIosReceiptDataForVerification()
                : null;

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
        })();
      });

      purchaseErrorSubscription = purchaseErrorListener((error) => {
        setIsPurchasePending(false);
        void captureError(new Error(error.message), {
          productId: error.productId ?? undefined,
          surface: 'mobile-app-state:purchase-error',
        });
      });

      shouldEndConnection = true;
      void refreshStoreProducts();
    } catch (error) {
      setStoreStatus('error');
      setIsStoreRuntimeAvailable(false);
      setStoreError(
        isStoreNativeModuleError(error)
          ? STORE_UNAVAILABLE_MESSAGE
          : '스토어 기능을 초기화하지 못했어요.',
      );
      void captureError(error, {
        surface: 'mobile-app-state:store-runtime-init',
      });
    }

    return () => {
      purchaseUpdatedSubscription?.remove();
      purchaseErrorSubscription?.remove();

      if (shouldEndConnection) {
        void endConnection().catch(() => undefined);
      }
    };
  }, [isStoreRuntimeAvailable, persistFromCurrent, refreshStoreProducts, syncRemoteProfile]);

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
      recordChatIntent,
      purchaseProduct,
      restorePurchases,
    }),
    [
      isPurchasePending,
      purchaseProduct,
      refreshStoreProducts,
      recordChatIntent,
      restorePurchases,
      saveNotifications,
      saveProfile,
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
