import { useState } from 'react';

import { router } from 'expo-router';
import {
  consumableProductIds,
  legacyConsumableProductIds,
  nonConsumableProductIds,
  productCatalog,
  subscriptionProductIds,
  type ProductId,
} from '@fortune/product-contracts';
import { Alert, Linking, Platform, Pressable, View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { Chip } from '../components/chip';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { captureError } from '../lib/error-reporting';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';
import { useMobileAppState } from '../providers/mobile-app-state-provider';

function formatPrice(price: number) {
  return `₩${price.toLocaleString('ko-KR')}`;
}

export function PremiumScreen() {
  const { session } = useAppBootstrap();
  const { restorePurchases, state, syncRemoteProfile } = useMobileAppState();
  const [selectedProductId, setSelectedProductId] = useState<ProductId>(
    subscriptionProductIds[0],
  );
  const [actionState, setActionState] = useState<
    'idle' | 'refreshing' | 'restoring' | 'managing'
  >('idle');

  const selectedProduct = productCatalog[selectedProductId];
  const subscriptions = subscriptionProductIds.map((id) => productCatalog[id]);
  const tokens = [...consumableProductIds, ...legacyConsumableProductIds].map(
    (id) => productCatalog[id],
  );
  const lifetime = nonConsumableProductIds.map((id) => productCatalog[id]);
  const activeProduct = state.premium.activeProductId
    ? productCatalog[state.premium.activeProductId]
    : null;
  const activePlanLabel =
    state.premium.status === 'subscription'
      ? activeProduct?.title ?? '활성 구독 없음'
      : state.premium.status === 'lifetime'
        ? activeProduct?.title ?? '평생 소장 없음'
        : '활성 플랜 없음';

  async function handleRefresh() {
    if (actionState !== 'idle') {
      return;
    }

    setActionState('refreshing');

    try {
      await syncRemoteProfile();
    } catch (error) {
      await captureError(error, { surface: 'premium:refresh' });
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
    } catch (error) {
      await captureError(error, { surface: 'premium:restore' });
      Alert.alert(
        '구매 복원 실패',
        '원격 구독 상태를 다시 읽는 중 문제가 발생했습니다. 잠시 후 다시 시도해 주세요.',
      );
    } finally {
      setActionState('idle');
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

  function handleUnsupportedPurchase() {
    Alert.alert(
      '스토어 구매 엔진 준비 중',
      'RN에서는 아직 실제 스토어 결제 엔진이 연결되지 않았습니다. 지금은 실제 구독 상태 새로고침, 구매 복원, 스토어 구독 관리까지만 지원합니다.',
    );
  }

  const selectedProductActionLabel = selectedProduct.isSubscription
    ? state.premium.activeProductId === selectedProduct.id
      ? '구독 관리 열기'
      : '스토어 구독 관리'
    : '스토어 구매 엔진 준비 중';

  return (
    <Screen>
      <AppText variant="displaySmall">프리미엄</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        실제 상품 계약과 원격 구독 상태를 함께 보는 상업 표면입니다.
      </AppText>

      <Card>
        <AppText variant="heading4">한눈에 보기</AppText>
        <AppText variant="bodyMedium">
          {session
            ? '로그인된 계정에서 실제 구독 상태와 토큰 잔액을 동기화할 수 있어요.'
            : '게스트 상태에서는 상품을 둘러볼 수 있고, 실제 상태 동기화는 로그인 후 가능합니다.'}
        </AppText>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          <Chip
            label={session ? '로그인됨' : '게스트'}
            tone={session ? 'success' : 'neutral'}
          />
          <Chip
            label={`보유 토큰 ${state.premium.tokenBalance.toLocaleString('ko-KR')}개`}
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
            label={state.premium.lastSyncedAt ? '원격 동기화됨' : '로컬 상태만 있음'}
            tone={state.premium.lastSyncedAt ? 'success' : 'neutral'}
          />
        </View>
      </Card>

      <Card>
        <AppText variant="heading4">현재 상태</AppText>
        <AppText variant="labelLarge">{activePlanLabel}</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          마지막 구매:{' '}
          {state.premium.lastPurchaseProductId
            ? productCatalog[state.premium.lastPurchaseProductId].title
            : '없음'}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {state.premium.subscriptionExpiresAt
            ? `구독 만료일 ${state.premium.subscriptionExpiresAt.slice(0, 10)}`
            : '현재 원격 활성 구독이 없습니다.'}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {state.premium.lastSyncedAt
            ? `마지막 동기화 ${state.premium.lastSyncedAt.slice(0, 16).replace('T', ' ')}`
            : '원격 구독 상태를 아직 읽지 않았습니다.'}
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
        {subscriptions.map((product) => (
          <ProductOption
            key={product.id}
            isSelected={selectedProductId === product.id}
            onPress={() => setSelectedProductId(product.id)}
            title={product.title}
            subtitle={product.description}
            trailing={`월 ${formatPrice(product.price)}`}
            badge={
              product.id === 'com.beyond.fortune.subscription.max'
                ? '추천'
                : undefined
            }
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
          <Chip
            label={selectedProduct.isSubscription ? '정기 결제' : '한 번 결제'}
            tone="accent"
          />
          <Chip label={`가격 ${formatPrice(selectedProduct.price)}`} />
          {selectedProduct.points > 0 ? (
            <Chip
              label={`토큰 ${selectedProduct.points.toLocaleString('ko-KR')}개 포함`}
            />
          ) : null}
          <Chip
            label={
              selectedProduct.isSubscription
                ? `갱신 주기 ${selectedProduct.subscriptionPeriod}`
                : '평생 사용 가능'
            }
          />
        </View>
        <PrimaryButton
          disabled={actionState !== 'idle'}
          onPress={
            !session
              ? () =>
                  router.push({
                    pathname: '/signup',
                    params: { returnTo: '/premium' },
                  })
              : selectedProduct.isSubscription
                ? () => void handleOpenSubscriptionManagement()
                : handleUnsupportedPurchase
          }
          tone="primary"
        >
          {actionState === 'managing'
            ? '구독 관리 여는 중...'
            : selectedProductActionLabel}
        </PrimaryButton>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          토큰/평생 소장 직접 구매는 RN 네이티브 결제 엔진 이식 후 연결됩니다. 현재는 실제 구독 상태 읽기, 구매 복원, 스토어 구독 관리까지만 지원합니다.
        </AppText>
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
