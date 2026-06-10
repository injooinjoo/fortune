import { useEffect, useMemo, useRef, useState } from 'react';

import { router, useLocalSearchParams } from 'expo-router';
import {
  getSubscriptionPeriodLabel,
  productCatalog,
  storefrontSubscriptionProductIds,
  type ProductInfo,
  type ProductId,
} from '@fortune/product-contracts';
import { Alert, Linking, Platform, Pressable, View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { PrimaryButton } from '../components/primary-button';
import { RouteBackHeader } from '../components/route-back-header';
import { Screen } from '../components/screen';
import { captureError } from '../lib/error-reporting';
import { fortuneTheme, withAlpha } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';
import { useMobileAppState } from '../providers/mobile-app-state-provider';

function formatPrice(price: number) {
  return `₩${price.toLocaleString('ko-KR')}`;
}

function readRouteParam(value: string | string[] | undefined) {
  return Array.isArray(value) ? value[0] : value;
}

const strongFitTopUpProductIds = [
  'com.beyond.fortune.tokens.starter',
  'com.beyond.fortune.tokens.popular',
  'com.beyond.fortune.tokens.heavy',
] as const satisfies readonly ProductId[];

const strongFitRecommendedProductId = 'com.beyond.fortune.tokens.popular' as const;

function getTopUpPackageLabel(productId: ProductId) {
  if (productId === 'com.beyond.fortune.tokens.starter') {
    return '가볍게';
  }

  if (productId === strongFitRecommendedProductId) {
    return '추천';
  }

  return '집중 사용';
}

function getTopUpPackagePurpose(productId: ProductId) {
  if (productId === 'com.beyond.fortune.tokens.starter') {
    return '잠깐 이어보기';
  }

  if (productId === strongFitRecommendedProductId) {
    return '며칠간 넉넉히';
  }

  return '오래 쓸 여유분';
}

function getPlanShortName(productId: ProductId) {
  if (productId === 'com.beyond.fortune.subscription.lite') {
    return 'Lite';
  }

  if (productId === 'com.beyond.fortune.subscription.pro') {
    return 'Pro';
  }

  return 'Max';
}

function getPlanOneLine(productId: ProductId) {
  if (productId === 'com.beyond.fortune.subscription.lite') {
    return '가볍게 매일 보기';
  }

  if (productId === 'com.beyond.fortune.subscription.pro') {
    return '대화와 풀이를 넉넉하게';
  }

  return '자주 쓰는 사람을 위한 최대 한도';
}

function getUsagePreview(product: ProductInfo) {
  return [
    { label: '긴 답변', value: Math.max(1, Math.floor(product.points / 5)), unit: '회' },
    { label: '심층 분석', value: Math.max(1, Math.floor(product.points / 30)), unit: '회' },
  ];
}

export function PremiumScreen() {
  const params = useLocalSearchParams<{ intent?: string | string[]; ts?: string | string[] }>();
  const premiumIntent = readRouteParam(params.intent);
  const topUpEntryKey = readRouteParam(params.ts);
  const [showAllProducts, setShowAllProducts] = useState(false);
  const { session } = useAppBootstrap();
  const {
    isPurchasePending,
    purchaseProduct,
    refreshStoreProducts,
    restorePurchases,
    state,
    storeError,
    storePriceLabels,
    storeStatus,
    syncRemoteProfile,
  } = useMobileAppState();
  const [selectedProductId, setSelectedProductId] = useState<ProductId>(() =>
    premiumIntent === 'top-up'
      ? strongFitRecommendedProductId
      : storefrontSubscriptionProductIds[0],
  );
  const [openTrustIndex, setOpenTrustIndex] = useState<number | null>(null);
  const didRequestStoreRefreshRef = useRef(false);
  const pendingNavigationProductRef = useRef<ProductId | null>(null);
  const purchaseStartedBalanceRef = useRef<number | null>(null);

  useEffect(() => {
    if (didRequestStoreRefreshRef.current) {
      return;
    }

    didRequestStoreRefreshRef.current = true;
    void refreshStoreProducts().catch((error) => {
      void captureError(error, { surface: 'premium:store-auto-refresh' });
    });
  }, [refreshStoreProducts]);

  useEffect(() => {
    if (premiumIntent !== 'top-up') {
      return;
    }
    setShowAllProducts(false);
    setSelectedProductId(strongFitRecommendedProductId);
    setOpenTrustIndex(null);
  }, [premiumIntent, topUpEntryKey]);
  const [actionState, setActionState] = useState<'idle' | 'refreshing' | 'managing'>(
    'idle',
  );

  const selectedProduct = productCatalog[selectedProductId];
  const subscriptions = storefrontSubscriptionProductIds.map(
    (id) => productCatalog[id],
  );
  const focusTopUpOnly = premiumIntent === 'top-up' && !showAllProducts;
  const activeSubscriptionProductId = state.premium.status === 'subscription'
    ? state.premium.activeProductId
    : null;
  const selectedProductPeriodLabel = getSubscriptionPeriodLabel(selectedProduct.id);
  const selectedProductPriceLabel =
    storePriceLabels[selectedProduct.id] ?? formatPrice(selectedProduct.price);
  const selectedProductDeliveryLabel = selectedProduct.isSubscription
    ? selectedProductPeriodLabel ?? '매월 결제'
    : selectedProduct.points > 0
      ? '구매 즉시 지급'
      : '평생 소장';
  const canManageSelectedSubscription =
    session != null &&
    selectedProduct.isSubscription &&
    state.premium.activeProductId === selectedProduct.id;
  // 선택 상품의 스토어 가격이 로드되지 않았다면 (SKU 미등록 / Paid Apps Agreement
   // 미체결 / 샌드박스 상품 누락) 결제 시작 자체가 실패한다. 이 경우 버튼을
   // 비활성으로 두면 grayed out 만 보여 Apple 2.1(b) 거절(2026-04-28) 패턴으로
   // 보이므로, 가격 미로드 시 명시 메시지를 띄우는 별도 핸들러로 라우팅한다.
  const isStoreProductReady =
    storeStatus === 'ready' && Boolean(storePriceLabels[selectedProductId]);
  const canPressPurchaseCta =
    session != null &&
    !canManageSelectedSubscription &&
    actionState === 'idle' &&
    !isPurchasePending;
  const strongFitTopUpProducts = useMemo(
    () => strongFitTopUpProductIds.map((id) => productCatalog[id]),
    [],
  );
  const selectedTopUpUsage =
    selectedProduct.points > 0 ? getUsagePreview(selectedProduct) : [];
  const selectedTopUpAfterBalance = state.premium.tokenBalance + selectedProduct.points;

  useEffect(() => {
    if (premiumIntent === 'top-up' || !activeSubscriptionProductId) {
      return;
    }

    setSelectedProductId(activeSubscriptionProductId);
  }, [activeSubscriptionProductId, premiumIntent]);

  useEffect(() => {
    const pendingProductId = pendingNavigationProductRef.current;

    if (!pendingProductId || isPurchasePending) {
      return;
    }

    const pendingProduct = productCatalog[pendingProductId];
    const startedBalance = purchaseStartedBalanceRef.current;
    const didCompletePurchase = pendingProduct.isSubscription
      ? state.premium.status === 'subscription' &&
        state.premium.activeProductId === pendingProductId
      : startedBalance != null && state.premium.tokenBalance > startedBalance;

    if (!didCompletePurchase) {
      return;
    }

    pendingNavigationProductRef.current = null;
    purchaseStartedBalanceRef.current = null;
    router.replace('/chat');
  }, [isPurchasePending, state.premium]);

  async function handleRefresh() {
    if (actionState !== 'idle') {
      return;
    }

    setActionState('refreshing');

    try {
      await Promise.all([syncRemoteProfile(), refreshStoreProducts()]);
    } catch (error) {
      await captureError(error, { surface: 'premium:refresh' });
    } finally {
      setActionState('idle');
    }
  }

  async function handleRestore() {
    if (actionState !== 'idle' || isPurchasePending) {
      return;
    }

    try {
      await restorePurchases();
    } catch (error) {
      await captureError(error, { surface: 'premium:restore' });
      Alert.alert(
        '구매 복원 실패',
        error instanceof Error
          ? error.message
          : '구매 복원 중 문제가 발생했습니다. 잠시 후 다시 시도해 주세요.',
      );
    }
  }

  async function handleOpenSubscriptionManagement() {
    if (actionState !== 'idle') {
      return;
    }

    setActionState('managing');

    const url =
      Platform.OS === 'ios'
        ? 'https://apps.apple.com/account/subscriptions'
        : 'https://play.google.com/store/account/subscriptions';

    try {
      await Linking.openURL(url);
    } catch (error) {
      await captureError(error, { surface: 'premium:subscription-management' });
      Alert.alert(
        '구독 관리 열기 실패',
        '스토어의 구독 관리 화면을 열지 못했습니다.',
      );
    } finally {
      setActionState('idle');
    }
  }

  async function handlePurchase() {
    if (!canPressPurchaseCta) {
      return;
    }

    if (!isStoreProductReady) {
      Alert.alert(
        '스토어 상품 확인 필요',
        storeError ??
          'App Store 상품 정보를 아직 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.',
        [
          { text: '닫기', style: 'cancel' },
          {
            text: '다시 확인',
            onPress: () => {
              void handleRefresh();
            },
          },
        ],
      );
      return;
    }

    try {
      pendingNavigationProductRef.current = selectedProduct.id;
      purchaseStartedBalanceRef.current = state.premium.tokenBalance;
      await purchaseProduct(selectedProduct.id);
    } catch (error) {
      pendingNavigationProductRef.current = null;
      purchaseStartedBalanceRef.current = null;
      await captureError(error, {
        productId: selectedProduct.id,
        surface: 'premium:purchase',
      });
      Alert.alert(
        '구매 시작 실패',
        error instanceof Error
          ? error.message
          : '구매를 시작하지 못했습니다. 잠시 후 다시 시도해 주세요.',
      );
    }
  }

  const topUpFooter = focusTopUpOnly ? (
    <View style={{ gap: fortuneTheme.spacing.sm }}>
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
        <View style={{
          alignItems: 'center',
          backgroundColor: withAlpha(fortuneTheme.colors.ctaBackground, 0.14),
          borderColor: withAlpha(fortuneTheme.colors.ctaBackground, 0.32),
          borderRadius: fortuneTheme.radius.full,
          borderWidth: 1,
          height: 34,
          justifyContent: 'center',
          width: 34,
        }}>
          <AppText variant="labelLarge" color={fortuneTheme.colors.ctaBackground}>온</AppText>
        </View>
        <View style={{ flex: 1 }}>
          <AppText variant="labelLarge">{getTopUpPackageLabel(selectedProduct.id)}</AppText>
          <AppText variant="labelSmall" color={fortuneTheme.colors.textSecondary}>
            {selectedProduct.points.toLocaleString('ko-KR')} 토큰 · {selectedProductDeliveryLabel}
          </AppText>
        </View>
        <AppText variant="heading4">{selectedProductPriceLabel}</AppText>
      </View>

      {!session ? (
        <PrimaryButton
          disabled={actionState !== 'idle' || isPurchasePending}
          onPress={() =>
            router.push({
              pathname: '/signup',
              params: { returnTo: '/premium?intent=top-up' },
            })
          }
          tone="primary"
        >
          로그인하고 계속하기
        </PrimaryButton>
      ) : (
        <PrimaryButton
          disabled={!canPressPurchaseCta}
          onPress={() => void handlePurchase()}
          tone="primary"
        >
          {isPurchasePending
            ? '결제 진행 중...'
            : storeStatus === 'loading'
              ? '스토어 준비 중...'
              : !isStoreProductReady
                ? '스토어 상품 확인 필요'
                : '토큰 충전하기'}
        </PrimaryButton>
      )}

      <View style={{ alignItems: 'center', flexDirection: 'row', justifyContent: 'center', gap: fortuneTheme.spacing.md }}>
        <Pressable
          disabled={actionState !== 'idle' || isPurchasePending}
          onPress={() => void handleRestore()}
        >
          <AppText variant="caption" color={fortuneTheme.colors.textSecondary}>
            구매 복원
          </AppText>
        </Pressable>
        <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>·</AppText>
        <Pressable onPress={() => setShowAllProducts(true)}>
          <AppText variant="caption" color={fortuneTheme.colors.textSecondary}>
            구독 상품도 보기
          </AppText>
        </Pressable>
      </View>
    </View>
  ) : null;

  return (
    <Screen
      contentBottomInset={focusTopUpOnly ? fortuneTheme.spacing.lg : 0}
      footer={topUpFooter}
      header={<RouteBackHeader fallbackHref="/profile" />}
    >
      <AppText variant="displaySmall">
        {premiumIntent === 'top-up' ? '토큰 충전' : '온도 요금제'}
      </AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        {premiumIntent === 'top-up'
          ? '대화에 필요한 토큰만 빠르게 충전할 수 있어요.'
          : '3개 중 하나만 고르면 돼요.'}
      </AppText>

      {focusTopUpOnly ? (
        <>
          <View
            style={{
              alignItems: 'center',
              marginTop: fortuneTheme.spacing.sm,
              overflow: 'hidden',
              paddingBottom: fortuneTheme.spacing.sm,
              paddingTop: fortuneTheme.spacing.md,
            }}
          >
            <View
              pointerEvents="none"
              style={{
                backgroundColor: withAlpha(fortuneTheme.colors.ctaBackground, 0.24),
                borderRadius: fortuneTheme.radius.full,
                height: 180,
                opacity: 0.72,
                position: 'absolute',
                top: -56,
                width: 300,
              }}
            />
            <AppText variant="displayLarge">
              {state.premium.tokenBalance.toLocaleString('ko-KR')}
            </AppText>
            <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary}>
              보유 토큰
            </AppText>
            <AppText
              variant="oracleBody"
              color={fortuneTheme.colors.textSubtitle}
              style={{ marginTop: fortuneTheme.spacing.sm, textAlign: 'center' }}
            >
              조금만 더 이어가볼까요?
            </AppText>
            <AppText
              variant="bodySmall"
              color={fortuneTheme.colors.textSecondary}
              style={{ maxWidth: 300, textAlign: 'center' }}
            >
              토큰은 메시지·심층 분석·운세 풀이를 이어가는 데 쓰여요
            </AppText>
            {selectedTopUpAfterBalance != null ? (
              <View
                style={{
                  alignItems: 'center',
                  backgroundColor: withAlpha(fortuneTheme.colors.ctaBackground, 0.1),
                  borderColor: withAlpha(fortuneTheme.colors.ctaBackground, 0.3),
                  borderRadius: fortuneTheme.radius.full,
                  borderWidth: 1,
                  flexDirection: 'row',
                  gap: fortuneTheme.spacing.xs,
                  marginTop: fortuneTheme.spacing.sm,
                  paddingHorizontal: fortuneTheme.spacing.md,
                  paddingVertical: fortuneTheme.spacing.sm,
                }}
              >
                <AppText variant="labelSmall" color={fortuneTheme.colors.ctaBackground}>
                  충전 후
                </AppText>
                <AppText variant="labelLarge">
                  {selectedTopUpAfterBalance.toLocaleString('ko-KR')} 토큰
                </AppText>
              </View>
            ) : null}
          </View>

          <View style={{ flexDirection: 'row', gap: fortuneTheme.spacing.sm }}>
            {strongFitTopUpProducts.map((product) => (
              <TopUpPackageTile
                key={product.id}
                isRecommended={product.id === strongFitRecommendedProductId}
                isSelected={selectedProductId === product.id}
                onPress={() => setSelectedProductId(product.id)}
                priceLabel={storePriceLabels[product.id] ?? formatPrice(product.price)}
                product={product}
              />
            ))}
          </View>

          <Card style={{ backgroundColor: fortuneTheme.colors.surfaceElevated }}>
            <View style={{ flexDirection: 'row', justifyContent: 'space-between', gap: fortuneTheme.spacing.sm }}>
              <View style={{ flex: 1 }}>
                <AppText variant="labelLarge">
                  {getTopUpPackageLabel(selectedProduct.id)} 패키지로 할 수 있는 것
                </AppText>
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                  {getTopUpPackagePurpose(selectedProduct.id)} 기준으로 대략 계산했어요.
                </AppText>
              </View>
              <AppText variant="labelSmall" color={fortuneTheme.colors.textTertiary}>
                {selectedProduct.points.toLocaleString('ko-KR')} 토큰
              </AppText>
            </View>
            <View style={{ flexDirection: 'row', gap: fortuneTheme.spacing.sm }}>
              {selectedTopUpUsage.map((item) => (
                <View
                  key={item.label}
                  style={{
                    backgroundColor: withAlpha(fortuneTheme.colors.accent, 0.03),
                    borderColor: withAlpha(fortuneTheme.colors.accent, 0.05),
                    borderRadius: fortuneTheme.radius.md,
                    borderWidth: 1,
                    flex: 1,
                    padding: fortuneTheme.spacing.md,
                  }}
                >
                  <AppText variant="labelSmall" color={fortuneTheme.colors.textSecondary}>
                    {item.label}
                  </AppText>
                  <View style={{ alignItems: 'baseline', flexDirection: 'row', gap: fortuneTheme.spacing.xs }}>
                    <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>약</AppText>
                    <AppText variant="heading2">{item.value.toLocaleString('ko-KR')}</AppText>
                    <AppText variant="labelSmall" color={fortuneTheme.colors.textSecondary}>{item.unit}</AppText>
                  </View>
                </View>
              ))}
            </View>
          </Card>

          <View style={{ gap: fortuneTheme.spacing.sm }}>
            <View style={{ flexDirection: 'row', gap: fortuneTheme.spacing.sm }}>
              {[
                { title: '즉시 반영', detail: '결제 직후 계정에 바로 충전돼요.' },
                { title: '만료 없음', detail: '쓰지 않은 토큰은 계속 보관됩니다.' },
                { title: '안전 결제', detail: 'App Store · Google Play 결제로 처리돼요.' },
              ].map((item, index) => (
                <Pressable
                  key={item.title}
                  accessibilityRole="button"
                  onPress={() => setOpenTrustIndex(openTrustIndex === index ? null : index)}
                  style={({ pressed }) => ({
                    alignItems: 'center',
                    backgroundColor: openTrustIndex === index
                      ? withAlpha(fortuneTheme.colors.accent, 0.05)
                      : withAlpha(fortuneTheme.colors.accent, 0.02),
                    borderColor: openTrustIndex === index
                      ? withAlpha(fortuneTheme.colors.accent, 0.14)
                      : withAlpha(fortuneTheme.colors.accent, 0.05),
                    borderRadius: fortuneTheme.radius.md,
                    borderWidth: 1,
                    flex: 1,
                    minHeight: 58,
                    opacity: pressed ? 0.84 : 1,
                    padding: fortuneTheme.spacing.sm,
                    justifyContent: 'center',
                  })}
                >
                  <AppText variant="labelSmall">{item.title}</AppText>
                </Pressable>
              ))}
            </View>
            {openTrustIndex != null ? (
              <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                {[
                  '결제 직후 계정에 바로 충전돼요.',
                  '쓰지 않은 토큰은 계속 보관됩니다.',
                  'App Store · Google Play 결제로 처리돼요.',
                ][openTrustIndex]}
              </AppText>
            ) : null}
          </View>
        </>
      ) : null}

      {!focusTopUpOnly ? (
        <>
          <Card
            style={{
              backgroundColor: withAlpha(fortuneTheme.colors.ctaBackground, 0.08),
              borderColor: withAlpha(fortuneTheme.colors.ctaBackground, 0.16),
              gap: fortuneTheme.spacing.md,
              overflow: 'hidden',
            }}
          >
            <View
              pointerEvents="none"
              style={{
                backgroundColor: withAlpha(fortuneTheme.colors.ctaBackground, 0.16),
                borderRadius: fortuneTheme.radius.full,
                height: 180,
                position: 'absolute',
                right: -76,
                top: -96,
                width: 180,
              }}
            />
            <View style={{ gap: fortuneTheme.spacing.xs }}>
              <AppText variant="displaySmall">더 오래 대화하기</AppText>
              <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
                매달 쓸 수 있는 토큰 한도를 골라요.
              </AppText>
            </View>
            <View style={{ alignItems: 'center', flexDirection: 'row', justifyContent: 'space-between' }}>
              <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                현재 {state.premium.tokenBalance.toLocaleString('ko-KR')} 토큰
              </AppText>
              <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                다 쓰면 오늘은 쉬어가기
              </AppText>
            </View>
          </Card>

          <View style={{ gap: fortuneTheme.spacing.sm }}>
            <FreePlanCard isCurrentPlan={activeSubscriptionProductId == null} />
            {subscriptions.map((product) => (
              <SubscriptionPlanCard
                key={product.id}
                isCurrentPlan={activeSubscriptionProductId === product.id}
                isRecommended={
                  activeSubscriptionProductId == null &&
                  product.id === 'com.beyond.fortune.subscription.pro'
                }
                isSelected={selectedProductId === product.id}
                onPress={() => setSelectedProductId(product.id)}
                priceLabel={`월 ${storePriceLabels[product.id] ?? formatPrice(product.price)}`}
                product={product}
              />
            ))}
          </View>

          {storeStatus === 'error' ? (
            <AppText variant="caption" color={fortuneTheme.colors.textSecondary}>
              {storeError ?? '스토어 연결을 확인해 주세요.'}
            </AppText>
          ) : null}

          {!session ? (
            <PrimaryButton
              disabled={actionState !== 'idle' || isPurchasePending}
              onPress={() =>
                router.push({
                  pathname: '/signup',
                  params: { returnTo: '/premium' },
                })
              }
              tone="primary"
            >
              로그인하고 시작하기
            </PrimaryButton>
          ) : canManageSelectedSubscription ? (
            <PrimaryButton
              disabled={actionState !== 'idle' || isPurchasePending}
              onPress={() => void handleOpenSubscriptionManagement()}
              tone="primary"
            >
              {actionState === 'managing' ? '여는 중...' : '구독 관리'}
            </PrimaryButton>
          ) : (
            <PrimaryButton
              disabled={!canPressPurchaseCta}
              onPress={() => void handlePurchase()}
              tone="primary"
            >
              {isPurchasePending
                ? '결제 중...'
                : storeStatus === 'loading'
                  ? '스토어 준비 중...'
                  : !isStoreProductReady
                    ? '스토어 확인 필요'
                    : `${getPlanShortName(selectedProduct.id)} 시작하기`}
            </PrimaryButton>
          )}

          <View style={{ alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
            <View style={{ flexDirection: 'row', gap: fortuneTheme.spacing.lg }}>
              <Pressable
                disabled={actionState !== 'idle' || isPurchasePending}
                onPress={() => void handleRestore()}
              >
                <AppText variant="caption" color={fortuneTheme.colors.textSecondary}>
                  구매 복원
                </AppText>
              </Pressable>
              <Pressable onPress={() => void Linking.openURL('https://hayjukwfcsdmppairazc.supabase.co/functions/v1/legal-pages/terms-of-service')}>
                <AppText variant="caption" color={fortuneTheme.colors.textSecondary}>
                  약관
                </AppText>
              </Pressable>
              <Pressable onPress={() => void Linking.openURL('https://hayjukwfcsdmppairazc.supabase.co/functions/v1/legal-pages/privacy-policy')}>
                <AppText variant="caption" color={fortuneTheme.colors.textSecondary}>
                  개인정보
                </AppText>
              </Pressable>
            </View>
            <AppText variant="caption" color={fortuneTheme.colors.textTertiary} style={{ textAlign: 'center' }}>
              자동 갱신 구독 · 언제든 스토어에서 해지 가능
            </AppText>
          </View>
        </>
      ) : null}
    </Screen>
  );
}

function TopUpPackageTile({
  isRecommended,
  isSelected,
  onPress,
  priceLabel,
  product,
}: {
  isRecommended: boolean;
  isSelected: boolean;
  onPress: () => void;
  priceLabel: string;
  product: ProductInfo;
}) {
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityState={{ selected: isSelected }}
      onPress={onPress}
      style={({ pressed }) => ({
        flex: isRecommended ? 1.16 : 1,
        marginTop: isRecommended ? 0 : fortuneTheme.spacing.sm,
        opacity: pressed ? 0.86 : 1,
      })}
    >
      <Card
        style={{
          alignItems: 'center',
          backgroundColor: isSelected
            ? withAlpha(fortuneTheme.colors.ctaBackground, 0.12)
            : fortuneTheme.colors.surfaceElevated,
          borderColor: isSelected
            ? fortuneTheme.colors.ctaBackground
            : isRecommended
              ? withAlpha(fortuneTheme.colors.accent, 0.1)
              : withAlpha(fortuneTheme.colors.accent, 0.06),
          gap: fortuneTheme.spacing.xs,
          minHeight: isRecommended ? 148 : 132,
          paddingHorizontal: fortuneTheme.spacing.sm,
          paddingVertical: isRecommended ? fortuneTheme.spacing.md : fortuneTheme.spacing.sm,
        }}
      >
        {isRecommended ? (
          <View
            style={{
              backgroundColor: fortuneTheme.colors.accentTertiary,
              borderRadius: fortuneTheme.radius.full,
              marginTop: -fortuneTheme.spacing.lg,
              paddingHorizontal: fortuneTheme.spacing.sm,
              paddingVertical: fortuneTheme.spacing.xs,
            }}
          >
            <AppText variant="caption" color={fortuneTheme.colors.background}>
              가장 인기
            </AppText>
          </View>
        ) : null}
        <View
          style={{
            alignItems: 'center',
            backgroundColor: isSelected
              ? withAlpha(fortuneTheme.colors.ctaBackground, 0.16)
              : withAlpha(fortuneTheme.colors.accent, 0.04),
            borderRadius: fortuneTheme.radius.full,
            height: isRecommended ? 34 : 30,
            justifyContent: 'center',
            width: isRecommended ? 34 : 30,
          }}
        >
          <AppText variant="labelSmall" color={isSelected ? fortuneTheme.colors.ctaBackground : fortuneTheme.colors.textSecondary}>
            온
          </AppText>
        </View>
        <AppText variant="caption" color={fortuneTheme.colors.textSecondary}>
          {getTopUpPackageLabel(product.id)}
        </AppText>
        <AppText variant={isRecommended ? 'heading2' : 'heading4'}>
          {product.points.toLocaleString('ko-KR')}
        </AppText>
        <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
          토큰
        </AppText>
        <AppText variant="labelMedium">{priceLabel}</AppText>
        <AppText variant="caption" color={fortuneTheme.colors.textSecondary} style={{ textAlign: 'center' }}>
          {getTopUpPackagePurpose(product.id)}
        </AppText>
      </Card>
    </Pressable>
  );
}

function FreePlanCard({ isCurrentPlan }: { isCurrentPlan: boolean }) {
  return (
    <Card
      style={{
        backgroundColor: isCurrentPlan
          ? withAlpha(fortuneTheme.colors.ctaBackground, 0.08)
          : fortuneTheme.colors.surfaceElevated,
        borderColor: isCurrentPlan
          ? fortuneTheme.colors.ctaBackground
          : withAlpha(fortuneTheme.colors.accent, 0.08),
        gap: fortuneTheme.spacing.sm,
        paddingVertical: fortuneTheme.spacing.lg,
      }}
    >
      <View style={{ alignItems: 'center', flexDirection: 'row', justifyContent: 'space-between', gap: fortuneTheme.spacing.md }}>
        <View style={{ flex: 1, gap: fortuneTheme.spacing.xs }}>
          <View style={{ alignItems: 'center', flexDirection: 'row', gap: fortuneTheme.spacing.sm }}>
            <AppText variant="heading4">Free</AppText>
            {isCurrentPlan ? (
              <PlanStatusBadge label="이용중" tone="active" />
            ) : null}
          </View>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            가끔 온도와 대화해보기
          </AppText>
        </View>
        <View style={{ alignItems: 'flex-end', gap: 2 }}>
          <AppText variant="heading3">0</AppText>
          <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
            구독료
          </AppText>
        </View>
      </View>
      <View style={{ alignItems: 'center', flexDirection: 'row', justifyContent: 'space-between' }}>
        <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
          무료
        </AppText>
        <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
          기본 체험 한도
        </AppText>
      </View>
    </Card>
  );
}

function PlanStatusBadge({
  label,
  tone,
}: {
  label: string;
  tone: 'active' | 'recommended';
}) {
  const isActive = tone === 'active';

  return (
    <View
      style={{
        backgroundColor: isActive
          ? withAlpha(fortuneTheme.colors.ctaBackground, 0.12)
          : fortuneTheme.colors.ctaBackground,
        borderColor: isActive
          ? withAlpha(fortuneTheme.colors.ctaBackground, 0.3)
          : fortuneTheme.colors.ctaBackground,
        borderRadius: fortuneTheme.radius.full,
        borderWidth: 1,
        paddingHorizontal: fortuneTheme.spacing.sm,
        paddingVertical: 3,
      }}
    >
      <AppText
        variant="caption"
        color={isActive ? fortuneTheme.colors.ctaBackground : fortuneTheme.colors.background}
      >
        {label}
      </AppText>
    </View>
  );
}

function SubscriptionPlanCard({
  isCurrentPlan,
  isRecommended,
  isSelected,
  onPress,
  priceLabel,
  product,
}: {
  isCurrentPlan: boolean;
  isRecommended: boolean;
  isSelected: boolean;
  onPress: () => void;
  priceLabel: string;
  product: ProductInfo;
}) {
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityState={{ selected: isSelected }}
      onPress={onPress}
      style={({ pressed }) => ({ opacity: pressed ? 0.86 : 1 })}
    >
      <Card
        style={{
          backgroundColor: isSelected
            ? withAlpha(fortuneTheme.colors.ctaBackground, 0.1)
            : fortuneTheme.colors.surfaceElevated,
          borderColor: isSelected
            ? fortuneTheme.colors.ctaBackground
            : withAlpha(fortuneTheme.colors.accent, 0.08),
          gap: fortuneTheme.spacing.sm,
          paddingVertical: fortuneTheme.spacing.lg,
        }}
      >
        <View style={{ alignItems: 'center', flexDirection: 'row', justifyContent: 'space-between', gap: fortuneTheme.spacing.md }}>
          <View style={{ flex: 1, gap: fortuneTheme.spacing.xs }}>
            <View style={{ alignItems: 'center', flexDirection: 'row', gap: fortuneTheme.spacing.sm }}>
              <AppText variant="heading4">{getPlanShortName(product.id)}</AppText>
              {isCurrentPlan ? (
                <PlanStatusBadge label="구독중" tone="active" />
              ) : isRecommended ? (
                <PlanStatusBadge label="추천" tone="recommended" />
              ) : null}
            </View>
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {getPlanOneLine(product.id)}
            </AppText>
          </View>
          <View style={{ alignItems: 'flex-end', gap: 2 }}>
            <AppText variant="heading3">{product.points.toLocaleString('ko-KR')}</AppText>
            <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
              토큰 / 월
            </AppText>
          </View>
        </View>
        <View style={{ alignItems: 'center', flexDirection: 'row', justifyContent: 'space-between' }}>
          <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
            {priceLabel}
          </AppText>
          <View
            style={{
              alignItems: 'center',
              borderColor: isSelected
                ? fortuneTheme.colors.ctaBackground
                : fortuneTheme.colors.border,
              borderRadius: fortuneTheme.radius.full,
              borderWidth: 1,
              height: 22,
              justifyContent: 'center',
              width: 22,
            }}
          >
            {isSelected ? (
              <View
                style={{
                  backgroundColor: fortuneTheme.colors.ctaBackground,
                  borderRadius: fortuneTheme.radius.full,
                  height: 12,
                  width: 12,
                }}
              />
            ) : null}
          </View>
        </View>
      </Card>
    </Pressable>
  );
}
