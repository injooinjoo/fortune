import { useState } from 'react';

import { router } from 'expo-router';
import {
  getProductDisplayTitle,
  getSubscriptionPeriodLabel,
  productCatalog,
  storefrontConsumableProductIds,
  storefrontNonConsumableProductIds,
  storefrontSubscriptionProductIds,
  type ProductId,
} from '@fortune/product-contracts';
import { Alert, Linking, Platform, Pressable, View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { Chip } from '../components/chip';
import { PrimaryButton } from '../components/primary-button';
import { RouteBackHeader } from '../components/route-back-header';
import { Screen } from '../components/screen';
import { captureError } from '../lib/error-reporting';
import { fortuneTheme } from '../lib/theme';
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

export function PremiumScreen() {
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
  const [selectedProductId, setSelectedProductId] = useState<ProductId>(
    storefrontSubscriptionProductIds[0],
  );
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
  const canTriggerPurchase =
    session != null &&
    !canManageSelectedSubscription &&
    actionState === 'idle' &&
    !isPurchasePending &&
    storeStatus === 'ready';

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
    if (!canTriggerPurchase) {
      return;
    }

    try {
      await purchaseProduct(selectedProduct.id);
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

  return (
    <Screen header={<RouteBackHeader fallbackHref="/profile" />}>
      <AppText variant="displaySmall">프리미엄</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        현재 판매 중인 상품과 구독 상태를 한곳에서 확인할 수 있어요.
      </AppText>

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
            : storeError ?? 'App Store에 등록된 현재 판매 상품만 보여드려요.'}
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
              product.id === 'com.beyond.fortune.subscription.max'
                ? '추천'
                : undefined
            }
          />
        ))}
      </Card>

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
            disabled={!canTriggerPurchase}
            onPress={() => void handlePurchase()}
            tone="primary"
          >
            {isPurchasePending
              ? '결제 진행 중...'
              : selectedProduct.isSubscription
                ? '구독 시작하기'
                : selectedProduct.points > 0
                  ? '토큰 충전하기'
                  : '평생 소장 구매하기'}
          </PrimaryButton>
        )}
        <PrimaryButton
          onPress={actionState === 'idle' && !isPurchasePending ? handleRestore : undefined}
          tone="secondary"
        >
          {isPurchasePending ? '구매 상태 확인 중...' : '구매 복원'}
        </PrimaryButton>
      </Card>
    </Screen>
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
