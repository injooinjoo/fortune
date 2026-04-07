import { useMemo, useState } from 'react';

import {
  allProductIds,
  consumableProductIds,
  legacyConsumableProductIds,
  nonConsumableProductIds,
  productCatalog,
  subscriptionProductIds,
  type ProductId,
} from '@fortune/product-contracts';
import { Pressable, View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { Chip } from '../components/chip';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';
import { useMobileAppState } from '../providers/mobile-app-state-provider';

function formatPrice(price: number) {
  return `₩${price.toLocaleString('ko-KR')}`;
}

export function PremiumScreen() {
  const { session } = useAppBootstrap();
  const { state, purchaseProduct, restorePurchases } = useMobileAppState();
  const [selectedProductId, setSelectedProductId] = useState<ProductId>(
    subscriptionProductIds[0],
  );
  const [actionState, setActionState] = useState<
    'idle' | 'purchasing' | 'restoring'
  >('idle');

  const selectedProduct = productCatalog[selectedProductId];
  const subscriptions = subscriptionProductIds.map((id) => productCatalog[id]);
  const tokens = [...consumableProductIds, ...legacyConsumableProductIds].map(
    (id) => productCatalog[id],
  );
  const lifetime = nonConsumableProductIds.map((id) => productCatalog[id]);
  const totalProducts = useMemo(() => allProductIds.length, []);
  const activeProduct = state.premium.activeProductId
    ? productCatalog[state.premium.activeProductId]
    : null;
  const activePlanLabel =
    state.premium.status === 'subscription'
      ? activeProduct?.title ?? '활성 구독 없음'
      : state.premium.status === 'lifetime'
        ? activeProduct?.title ?? '평생 소장 없음'
        : '활성 플랜 없음';

  async function handlePurchase() {
    if (actionState !== 'idle') {
      return;
    }

    setActionState('purchasing');

    try {
      await purchaseProduct(selectedProductId);
    } finally {
      setActionState('idle');
    }
  }

  async function handleRestore() {
    if (actionState !== 'idle') {
      return;
    }

    setActionState('restoring');

    try {
      await restorePurchases();
    } finally {
      setActionState('idle');
    }
  }

  return (
    <Screen>
      <AppText
        variant="labelMedium"
        color={fortuneTheme.colors.accentSecondary}
      >
        /premium
      </AppText>
      <AppText variant="displaySmall">Premium</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        구독, 토큰, 평생 소장 상품을 RN parity 계약 그대로 묶어 둔 상업 표면입니다.
      </AppText>

      <Card>
        <AppText variant="heading4">Premium Hero</AppText>
        <AppText variant="bodyMedium">
          지금은 persisted premium 상태와 연결되어 있어, 구매와 복원이 실제 상태를 바꿉니다.
        </AppText>
        <Chip label={`catalog:${totalProducts} products`} tone="accent" />
        <Chip
          label={session ? 'account:authenticated' : 'account:guest'}
          tone={session ? 'success' : 'neutral'}
        />
        <Chip label={`plan:${state.premium.status}`} />
        <Chip label={`tokens:${state.premium.tokenBalance.toLocaleString('ko-KR')}`} />
      </Card>

      <Card>
        <AppText variant="heading4">현재 상태</AppText>
        <AppText variant="labelLarge">{activePlanLabel}</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          마지막 구매: {state.premium.lastPurchaseProductId ? productCatalog[state.premium.lastPurchaseProductId].title : '없음'}
        </AppText>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          <Chip label={`active:${activeProduct?.id ?? 'none'}`} tone="accent" />
          <Chip
            label={`restore:${state.premium.restoreCount.toLocaleString('ko-KR')}`}
          />
          <Chip
            label={`balance:${state.premium.tokenBalance.toLocaleString('ko-KR')}`}
          />
        </View>
      </Card>

      <Card>
        <AppText variant="heading4">구독 플랜</AppText>
        {subscriptions.map((product) => (
          <ProductOption
            key={product.id}
            isSelected={selectedProductId === product.id}
            onPress={() => setSelectedProductId(product.id)}
            title={product.title}
            subtitle={product.description}
            trailing={`${formatPrice(product.price)} / month`}
            badge={product.id === 'com.beyond.fortune.subscription.max' ? '추천' : undefined}
          />
        ))}
      </Card>

      <Card>
        <AppText variant="heading4">토큰 패키지</AppText>
        {tokens.map((product) => (
          <ProductOption
            key={product.id}
            isSelected={selectedProductId === product.id}
            onPress={() => setSelectedProductId(product.id)}
            title={product.title}
            subtitle={`${product.points.toLocaleString('ko-KR')} 토큰 · ${product.description}`}
            trailing={formatPrice(product.price)}
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
            title={product.title}
            subtitle={product.description}
            trailing={formatPrice(product.price)}
          />
        ))}
      </Card>

      <Card>
        <AppText variant="heading4">선택된 상품</AppText>
        <AppText variant="labelLarge">{selectedProduct.title}</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {selectedProduct.description}
        </AppText>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          <Chip label={`product:${selectedProduct.id}`} />
          <Chip label={`price:${formatPrice(selectedProduct.price)}`} tone="accent" />
          <Chip
            label={
              selectedProduct.isSubscription
                ? `plan:${selectedProduct.subscriptionPeriod}`
                : 'plan:one-time'
            }
          />
        </View>
        <PrimaryButton
          onPress={actionState === 'idle' ? handlePurchase : undefined}
          tone="primary"
        >
          {actionState === 'purchasing'
            ? '구매 적용 중...'
            : `${selectedProduct.title} 구매하기`}
        </PrimaryButton>
        <PrimaryButton
          onPress={actionState === 'idle' ? handleRestore : undefined}
          tone="secondary"
        >
          {actionState === 'restoring' ? '복원 적용 중...' : '구매 복원'}
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
            alignItems: 'center',
            flexDirection: 'row',
            justifyContent: 'space-between',
          }}
        >
          <View style={{ flex: 1, gap: fortuneTheme.spacing.xs }}>
            <AppText variant="labelLarge">{title}</AppText>
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {subtitle}
            </AppText>
          </View>
          <View style={{ alignItems: 'flex-end', gap: fortuneTheme.spacing.xs }}>
            <AppText variant="labelMedium">{trailing}</AppText>
            {badge ? <Chip label={badge} tone="success" /> : null}
          </View>
        </View>
      </Card>
    </Pressable>
  );
}
