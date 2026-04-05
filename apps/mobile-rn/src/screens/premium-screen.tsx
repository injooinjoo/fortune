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

function formatPrice(price: number) {
  return `₩${price.toLocaleString('ko-KR')}`;
}

export function PremiumScreen() {
  const { session } = useAppBootstrap();
  const [selectedProductId, setSelectedProductId] = useState<ProductId>(
    subscriptionProductIds[0],
  );

  const selectedProduct = productCatalog[selectedProductId];
  const subscriptions = subscriptionProductIds.map((id) => productCatalog[id]);
  const tokens = [...consumableProductIds, ...legacyConsumableProductIds].map(
    (id) => productCatalog[id],
  );
  const lifetime = nonConsumableProductIds.map((id) => productCatalog[id]);
  const totalProducts = useMemo(() => allProductIds.length, []);

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
          지금은 스토어 결제 플로우 전 단계까지 구현되어 있고, 어떤 카탈로그가 노출되는지 확인할 수 있습니다.
        </AppText>
        <Chip label={`catalog:${totalProducts} products`} tone="accent" />
        <Chip
          label={session ? 'account:authenticated' : 'account:guest'}
          tone={session ? 'success' : 'neutral'}
        />
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
        <PrimaryButton tone={session ? 'primary' : 'secondary'}>
          {session ? '구매 플로우 연결 준비' : '로그인 후 구매 가능'}
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
