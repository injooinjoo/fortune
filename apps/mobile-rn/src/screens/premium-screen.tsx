import { useEffect, useMemo, useState } from 'react';

import { router, useLocalSearchParams } from 'expo-router';
import {
  getProductDisplayTitle,
  getSubscriptionPeriodLabel,
  productCatalog,
  storefrontConsumableProductIds,
  storefrontNonConsumableProductIds,
  storefrontSubscriptionProductIds,
  type ProductInfo,
  type ProductId,
} from '@fortune/product-contracts';
import { Alert, Linking, Platform, Pressable, View } from 'react-native';

import { useRewardedAd } from '../lib/ad-rewards';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { Chip } from '../components/chip';
import { PrimaryButton } from '../components/primary-button';
import { RouteBackHeader } from '../components/route-back-header';
import { Screen } from '../components/screen';
import { captureError } from '../lib/error-reporting';
import { purchaseSuccess } from '../lib/haptics';
import { fortuneTheme, withAlpha } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';
import { useMobileAppState } from '../providers/mobile-app-state-provider';

function formatPrice(price: number) {
  return `₩${price.toLocaleString('ko-KR')}`;
}

function formatIsoDate(value: string | null) {
  if (!value) {
    return null;
  }

  const parsed = new Date(value);

  if (Number.isNaN(parsed.getTime())) {
    return null;
  }

  return parsed.toLocaleDateString('ko-KR');
}

function formatIsoDateTime(value: string | null) {
  if (!value) {
    return null;
  }

  const parsed = new Date(value);

  if (Number.isNaN(parsed.getTime())) {
    return null;
  }

  return parsed.toLocaleString('ko-KR', {
    year: 'numeric',
    month: 'numeric',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
}

function formatTokenBalanceLabel(tokenBalance: number, isUnlimited: boolean) {
  if (isUnlimited) {
    return '보유 토큰 무제한';
  }

  return `보유 토큰 ${tokenBalance.toLocaleString('ko-KR')}개`;
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

  useEffect(() => {
    if (premiumIntent !== 'top-up') {
      return;
    }
    setShowAllProducts(false);
    setSelectedProductId(strongFitRecommendedProductId);
    setOpenTrustIndex(null);
  }, [premiumIntent, topUpEntryKey]);

  const rewardedAd = useRewardedAd({
    session,
    userId: session?.user.id ?? null,
  });
  const [actionState, setActionState] = useState<'idle' | 'refreshing' | 'managing'>(
    'idle',
  );

  const selectedProduct = productCatalog[selectedProductId];
  const subscriptions = storefrontSubscriptionProductIds.map(
    (id) => productCatalog[id],
  );
  const tokens = storefrontConsumableProductIds.map((id) => productCatalog[id]);
  const lifetime = storefrontNonConsumableProductIds.map(
    (id) => productCatalog[id],
  );
  const focusTopUpOnly = premiumIntent === 'top-up' && !showAllProducts;
  const activeProduct = state.premium.activeProductId
    ? productCatalog[state.premium.activeProductId]
    : null;
  const activePlanLabel =
    state.premium.status === 'subscription'
      ? activeProduct
        ? getProductDisplayTitle(activeProduct.id)
        : '활성 구독 없음'
      : state.premium.status === 'lifetime'
        ? activeProduct
          ? getProductDisplayTitle(activeProduct.id)
          : '평생 소장 없음'
        : '활성 플랜 없음';
  const lastPurchaseLabel = state.premium.lastPurchaseProductId
    ? getProductDisplayTitle(state.premium.lastPurchaseProductId)
    : null;
  const subscriptionExpiryLabel = formatIsoDate(
    state.premium.subscriptionExpiresAt,
  );
  const lastSyncedLabel = formatIsoDateTime(state.premium.lastSyncedAt);
  const selectedProductTitle = getProductDisplayTitle(selectedProduct.id);
  const selectedProductPeriodLabel = getSubscriptionPeriodLabel(selectedProduct.id);
  const selectedProductPriceLabel =
    storePriceLabels[selectedProduct.id] ?? formatPrice(selectedProduct.price);
  const selectedProductDeliveryLabel = selectedProduct.isSubscription
    ? selectedProductPeriodLabel ?? '매월 결제'
    : selectedProduct.points > 0
      ? '구매 즉시 지급'
      : '평생 소장';
  const tokenBalanceLabel = formatTokenBalanceLabel(
    state.premium.tokenBalance,
    state.premium.isUnlimited,
  );
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
  const selectedTopUpAfterBalance = state.premium.isUnlimited
    ? null
    : state.premium.tokenBalance + selectedProduct.points;

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
      await purchaseProduct(selectedProduct.id);
      purchaseSuccess();
    } catch (error) {
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
        {premiumIntent === 'top-up' ? '토큰 충전' : '프리미엄'}
      </AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        {premiumIntent === 'top-up'
          ? '대화에 필요한 토큰만 빠르게 충전할 수 있어요.'
          : '현재 판매 중인 상품과 구독 상태를 한곳에서 확인할 수 있어요.'}
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
              {state.premium.isUnlimited
                ? '무제한'
                : state.premium.tokenBalance.toLocaleString('ko-KR')}
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
          <Card>
        <AppText variant="heading4">한눈에 보기</AppText>
        <AppText variant="bodyMedium">
          {session
            ? '로그인된 계정에서 구독 상태와 토큰 잔액을 확인할 수 있어요.'
            : '게스트 상태에서는 판매 중인 상품 구성을 먼저 둘러볼 수 있어요.'}
        </AppText>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          <Chip
            label={session ? '로그인됨' : '게스트'}
            tone={session ? 'success' : 'neutral'}
          />
          <Chip
            label={tokenBalanceLabel}
            tone="accent"
          />
          <Chip
            label={
              state.premium.status === 'subscription'
                ? '정기 결제 이용 중'
                : state.premium.status === 'lifetime'
                  ? '평생 소장 이용 중'
                : '아직 이용 전'
            }
          />
          <Chip
            label={state.premium.lastSyncedAt ? '상태 확인됨' : '상태 확인 전'}
            tone={state.premium.lastSyncedAt ? 'success' : 'neutral'}
          />
          <Chip
            label={
              storeStatus === 'loading'
                ? '스토어 확인 중'
                : storeStatus === 'error'
                  ? '스토어 확인 필요'
                  : '스토어 연결됨'
            }
            tone={storeStatus === 'error' ? 'neutral' : 'success'}
          />
        </View>
      </Card>

      <Card>
        <AppText variant="heading4">현재 상태</AppText>
        <AppText variant="labelLarge">{activePlanLabel}</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          마지막 구매: {lastPurchaseLabel ?? '없음'}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {subscriptionExpiryLabel
            ? `구독 만료일 ${subscriptionExpiryLabel}`
            : '현재 확인된 활성 구독이 없어요.'}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {lastSyncedLabel
            ? `마지막 확인 ${lastSyncedLabel}`
            : '아직 구독 상태를 확인하지 않았어요.'}
        </AppText>
        <PrimaryButton
          onPress={actionState === 'idle' ? () => void handleRefresh() : undefined}
          tone="secondary"
        >
          {actionState === 'refreshing'
            ? '구독 상태 새로고침 중...'
            : '구독 상태 새로고침'}
        </PrimaryButton>
      </Card>

      <Card>
        <AppText variant="heading4">구독 플랜</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {storeStatus === 'loading'
            ? '스토어 상품 정보를 불러오는 중이에요.'
            : storeStatus === 'error'
              ? storeError ??
                '스토어 연결에 실패했어요. 네트워크 상태를 확인하고 새로고침해 주세요.'
              : 'App Store에 등록된 현재 판매 상품만 보여드려요.'}
        </AppText>
        {subscriptions.map((product) => (
          <ProductOption
            key={product.id}
            isSelected={selectedProductId === product.id}
            onPress={() => setSelectedProductId(product.id)}
            title={getProductDisplayTitle(product.id)}
            subtitle={product.description}
            trailing={`월 ${storePriceLabels[product.id] ?? formatPrice(product.price)}`}
            badge={
              product.id === 'com.beyond.fortune.subscription.pro'
                ? '추천'
                : undefined
            }
          />
        ))}
      </Card>
        </>
      ) : null}

      {!focusTopUpOnly ? (
        <Card>
          <AppText variant="heading4">토큰 충전</AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            현재 스토어에서 판매 중인 토큰 상품만 보여드려요.
          </AppText>
          {tokens.map((product) => (
            <ProductOption
              key={product.id}
              isSelected={selectedProductId === product.id}
              onPress={() => setSelectedProductId(product.id)}
              title={getProductDisplayTitle(product.id)}
              subtitle={`${product.points.toLocaleString('ko-KR')} 토큰 · ${product.description}`}
              trailing={storePriceLabels[product.id] ?? formatPrice(product.price)}
            />
          ))}
        </Card>
      ) : null}

      {!focusTopUpOnly ? (
        <Card>
          <AppText variant="heading4">평생 소장</AppText>
          {lifetime.map((product) => (
            <ProductOption
              key={product.id}
              isSelected={selectedProductId === product.id}
              onPress={() => setSelectedProductId(product.id)}
              title={getProductDisplayTitle(product.id)}
              subtitle={product.description}
              trailing={storePriceLabels[product.id] ?? formatPrice(product.price)}
            />
          ))}
        </Card>
      ) : null}

      {session && !rewardedAd.isUnavailable ? (
        <Card>
          <AppText variant="heading4">광고 보고 토큰 받기</AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            짧은 광고 1회 시청으로 토큰 1개 획득. 일일 5회까지.
          </AppText>
          <PrimaryButton
            onPress={() => {
              void rewardedAd.showAd().then((outcome) => {
                if (outcome.success) {
                  Alert.alert(
                    '🎁 토큰 획득',
                    `${outcome.tokensGranted ?? 1} 토큰을 받았어요. (오늘 ${
                      outcome.remainingToday ?? 0
                    }회 남음)`,
                  );
                } else if (outcome.error === 'ad_not_ready') {
                  Alert.alert('광고 준비 중', '잠시 후 다시 시도해주세요.');
                } else if (outcome.errorCode === 'limit_reached') {
                  Alert.alert(
                    '오늘 한도 도달',
                    '내일 다시 광고로 토큰을 받을 수 있어요.',
                  );
                }
              });
            }}
            disabled={!rewardedAd.isReady || rewardedAd.isShowing}
            fullWidth
          >
            {rewardedAd.isShowing
              ? '광고 재생 중…'
              : rewardedAd.isReady
                ? '🎁 광고 1회 시청'
                : '광고 준비 중…'}
          </PrimaryButton>
        </Card>
      ) : null}

      <Card>
        <AppText variant="heading4">선택된 상품</AppText>
        <AppText variant="labelLarge">{selectedProductTitle}</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {selectedProduct.description}
        </AppText>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          <Chip
            label={selectedProduct.isSubscription ? '구독 상품' : '단건 상품'}
            tone="accent"
          />
          <Chip label={`가격 ${selectedProductPriceLabel}`} />
          {selectedProduct.points > 0 ? (
            <Chip
              label={`토큰 ${selectedProduct.points.toLocaleString('ko-KR')}개 포함`}
            />
          ) : null}
          <Chip label={selectedProductDeliveryLabel} />
        </View>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {!session
            ? '로그인하면 내 구독 상태를 확인하고 이전 구매를 복원할 수 있어요.'
            : canManageSelectedSubscription
              ? '현재 이용 중인 구독은 스토어 구독 관리 화면에서 변경할 수 있어요.'
              : storeStatus === 'loading'
                ? '스토어 준비가 끝나면 바로 구매를 진행할 수 있어요.'
                : storeError
                  ? storeError
                  : '선택한 상품을 바로 결제하고 계정 상태에 반영할 수 있어요.'}
        </AppText>
        {selectedProduct.isSubscription ? (
          <>
            <AppText
              variant="bodySmall"
              color={fortuneTheme.colors.textTertiary}
              style={{ lineHeight: 18 }}
            >
              자동 갱신 구독입니다. 구독 기간 종료 최소 24시간 전에 자동 갱신을
              해제하지 않으면 구독이 자동으로 갱신됩니다. 설정 {'>'} Apple ID {'>'}{' '}
              구독에서 관리할 수 있습니다.
            </AppText>
            <View style={{ flexDirection: 'row', justifyContent: 'center', gap: 16, marginTop: 8 }}>
              <Pressable onPress={() => void Linking.openURL('https://hayjukwfcsdmppairazc.supabase.co/functions/v1/legal-pages/terms-of-service')}>
                <AppText variant="caption" color={fortuneTheme.colors.ctaBackground} style={{ textDecorationLine: 'underline' }}>
                  이용약관
                </AppText>
              </Pressable>
              <Pressable onPress={() => void Linking.openURL('https://hayjukwfcsdmppairazc.supabase.co/functions/v1/legal-pages/privacy-policy')}>
                <AppText variant="caption" color={fortuneTheme.colors.ctaBackground} style={{ textDecorationLine: 'underline' }}>
                  개인정보처리방침
                </AppText>
              </Pressable>
            </View>
          </>
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
            로그인하고 계속하기
          </PrimaryButton>
        ) : canManageSelectedSubscription ? (
          <PrimaryButton
            disabled={actionState !== 'idle' || isPurchasePending}
            onPress={() => void handleOpenSubscriptionManagement()}
            tone="primary"
          >
            {actionState === 'managing'
              ? '구독 관리 여는 중...'
              : '구독 관리 열기'}
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
                  : selectedProduct.isSubscription
                    ? '구독 시작하기'
                    : selectedProduct.points > 0
                      ? '토큰 충전하기'
                      : '평생 소장 구매하기'}
          </PrimaryButton>
        )}
        <PrimaryButton
          onPress={actionState === 'idle' && !isPurchasePending ? () => handleRestore() : undefined}
          tone="secondary"
        >
          {isPurchasePending ? '구매 상태 확인 중...' : '구매 복원'}
        </PrimaryButton>
      </Card>
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

function ProductOption({
  badge,
  isSelected,
  onPress,
  subtitle,
  title,
  trailing,
}: {
  badge?: string;
  isSelected: boolean;
  onPress: () => void;
  subtitle: string;
  title: string;
  trailing: string;
}) {
  return (
    <Pressable
      accessibilityRole="button"
      onPress={onPress}
      style={({ pressed }) => ({
        opacity: pressed ? 0.84 : 1,
      })}
    >
      <Card
        style={{
          backgroundColor: isSelected
            ? fortuneTheme.colors.backgroundTertiary
            : fortuneTheme.colors.surfaceSecondary,
          borderColor: isSelected
            ? fortuneTheme.colors.accentSecondary
            : fortuneTheme.colors.border,
        }}
      >
        <View
          style={{
            alignItems: 'flex-start',
            flexDirection: 'row',
            gap: fortuneTheme.spacing.md,
            justifyContent: 'space-between',
          }}
        >
          <View style={{ flex: 1, gap: fortuneTheme.spacing.xs }}>
            <AppText variant="labelLarge">{title}</AppText>
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {subtitle}
            </AppText>
          </View>
          <View
            style={{
              alignItems: 'flex-end',
              flexShrink: 0,
              gap: fortuneTheme.spacing.xs,
              minWidth: 84,
            }}
          >
            <AppText variant="labelMedium">{trailing}</AppText>
            {badge ? <Chip label={badge} tone="success" /> : null}
          </View>
        </View>
      </Card>
    </Pressable>
  );
}
