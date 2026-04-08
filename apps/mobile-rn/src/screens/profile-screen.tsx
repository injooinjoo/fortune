import type { ComponentProps, ReactNode } from 'react';
import { useMemo, useState } from 'react';

import Constants from 'expo-constants';
import { Ionicons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { Linking, Platform, Pressable, View } from 'react-native';
import { getProductDisplayTitle } from '@fortune/product-contracts';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { RouteBackHeader } from '../components/route-back-header';
import { Screen } from '../components/screen';
import { findChatCharacterById } from '../lib/chat-characters';
import { formatFortuneTypeLabel } from '../lib/chat-shell';
import { captureError } from '../lib/error-reporting';
import { supabase } from '../lib/supabase';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';
import { useMobileAppState } from '../providers/mobile-app-state-provider';

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

export function ProfileScreen() {
  const [isRefreshingPremium, setIsRefreshingPremium] = useState(false);
  const [isRestoring, setIsRestoring] = useState(false);
  const { session } = useAppBootstrap();
  const { restorePurchases, state, syncRemoteProfile } = useMobileAppState();
  const savedName =
    state.profile.displayName.trim() ||
    (session?.user.user_metadata.name as string | undefined) ||
    (session?.user.user_metadata.full_name as string | undefined) ||
    session?.user.email ||
    '게스트';
  const savedEmail = session?.user.email ?? '로컬 프로필';
  const avatarLabel = savedName.slice(0, 1).toUpperCase();
  const recentCharacter = useMemo(() => {
    if (!state.chat.selectedCharacterId) {
      return null;
    }

    return findChatCharacterById(state.chat.selectedCharacterId);
  }, [state.chat.selectedCharacterId]);
  const lastFortuneLabel = state.chat.lastFortuneType
    ? formatFortuneTypeLabel(state.chat.lastFortuneType)
    : null;
  const activeProductLabel = state.premium.activeProductId
    ? getProductDisplayTitle(state.premium.activeProductId)
    : null;
  const premiumExpiryLabel = formatIsoDate(state.premium.subscriptionExpiresAt);
  const premiumSyncedLabel = formatIsoDateTime(state.premium.lastSyncedAt);
  const tokenBalanceLabel = state.premium.isUnlimited
    ? '무제한'
    : `${state.premium.tokenBalance.toLocaleString('ko-KR')} 토큰`;
  const notificationEnabledCount = Object.values(state.notifications).filter(Boolean).length;
  const birthSummary =
    state.profile.birthDate || state.profile.birthTime
      ? [
          state.profile.birthDate || '생년월일 미저장',
          state.profile.birthTime || '시간 미저장',
        ].join(' · ')
      : '생년월일을 아직 저장하지 않았어요.';
  const profileSummaryItems = [state.profile.mbti, state.profile.bloodType]
    .map((value) => value.trim())
    .filter(Boolean);
  const profileSummary =
    profileSummaryItems.length > 0
      ? profileSummaryItems.join(' · ')
      : 'MBTI와 혈액형 정보가 아직 없어요.';
  const sajuStatValue = state.profile.birthDate
    ? state.profile.birthTime
      ? '준비 완료'
      : '부분 입력'
    : '미입력';
  const relationshipStatValue =
    state.chat.sentMessageCount > 0
      ? `${Math.min(state.chat.sentMessageCount, 99)}회`
      : '대기';
  const relationshipStatNote = recentCharacter
    ? `${recentCharacter.name}와 최근 연결`
    : '최근 연결 없음';
  const premiumStatusBadge =
    state.premium.status === 'subscription'
      ? '구독중'
      : state.premium.status === 'lifetime'
        ? '평생'
        : undefined;
  const versionLabel = Constants.expoConfig?.version ?? '1.0.0';

  async function handleSignOut() {
    try {
      await supabase?.auth.signOut();
      router.replace('/chat');
    } catch (error) {
      await captureError(error, { surface: 'profile:sign-out' });
    }
  }

  async function handleRestorePurchases() {
    try {
      setIsRestoring(true);
      await restorePurchases();
    } catch (error) {
      await captureError(error, { surface: 'profile:restore-purchases' });
    } finally {
      setIsRestoring(false);
    }
  }

  async function handleOpenSubscriptionManagement() {
    const url =
      Platform.OS === 'ios'
        ? 'https://apps.apple.com/account/subscriptions'
        : 'https://play.google.com/store/account/subscriptions';

    await Linking.openURL(url).catch((error) =>
      captureError(error, { surface: 'profile:subscription-management' }),
    );
  }

  async function handleRefreshPremiumState() {
    try {
      setIsRefreshingPremium(true);
      await syncRemoteProfile();
    } catch (error) {
      await captureError(error, { surface: 'profile:refresh-premium' });
    } finally {
      setIsRefreshingPremium(false);
    }
  }

  return (
    <Screen
      header={
        <View style={{ alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
          <View style={{ alignSelf: 'stretch' }}>
            <RouteBackHeader fallbackHref="/chat" label="메시지" />
          </View>
          <AppText variant="heading3">프로필</AppText>
        </View>
      }
    >
      <Card
        style={{
          backgroundColor: fortuneTheme.colors.backgroundTertiary,
          gap: fortuneTheme.spacing.md,
        }}
      >
        <View
          style={{
            alignItems: 'center',
            flexDirection: 'row',
            gap: fortuneTheme.spacing.md,
          }}
        >
          <View
            style={{
              alignItems: 'center',
              backgroundColor: fortuneTheme.colors.surfaceSecondary,
              borderColor: fortuneTheme.colors.borderOpaque,
              borderRadius: fortuneTheme.radius.full,
              borderWidth: 1,
              height: 64,
              justifyContent: 'center',
              width: 64,
            }}
          >
            <AppText variant="heading3">{avatarLabel}</AppText>
          </View>

          <View style={{ flex: 1, gap: fortuneTheme.spacing.xs, minWidth: 0 }}>
            <AppText variant="labelMedium" color={fortuneTheme.colors.accentSecondary}>
              내 정보
            </AppText>
            <AppText numberOfLines={1} variant="heading2">
              {savedName}
            </AppText>
            <AppText
              numberOfLines={1}
              variant="bodySmall"
              color={fortuneTheme.colors.textSecondary}
            >
              {savedEmail}
            </AppText>
          </View>

          <Pressable
            accessibilityRole="button"
            onPress={() => router.push('/profile/edit')}
            style={({ pressed }) => ({ opacity: pressed ? 0.82 : 1 })}
          >
            <View
              style={{
                alignItems: 'center',
                alignSelf: 'flex-start',
                backgroundColor: fortuneTheme.colors.surfaceSecondary,
                borderColor: fortuneTheme.colors.border,
                borderRadius: fortuneTheme.radius.full,
                borderWidth: 1,
                paddingHorizontal: fortuneTheme.spacing.md,
                paddingVertical: fortuneTheme.spacing.sm,
              }}
            >
              <AppText variant="labelMedium">프로필 수정</AppText>
            </View>
          </Pressable>
        </View>

        <View style={{ gap: fortuneTheme.spacing.xs }}>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {birthSummary}
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {profileSummary}
          </AppText>
        </View>
      </Card>

      <View style={{ flexDirection: 'row', gap: fortuneTheme.spacing.sm }}>
        <ProfileStatCard
          label="사주 원소"
          note={state.profile.birthDate ? '출생 정보 기준' : '출생 정보 필요'}
          value={sajuStatValue}
        />
        <ProfileStatCard
          label="인간관계"
          note={relationshipStatNote}
          value={relationshipStatValue}
        />
        <ProfileStatCard
          label="토큰 잔액"
          note={
            state.premium.status === 'subscription'
              ? '구독 활성화'
              : state.premium.status === 'lifetime'
                ? '평생 이용'
                : '일반 상태'
          }
          value={tokenBalanceLabel}
        />
      </View>

      <ProfileSection title="나의 온도">
        <ProfileMenuRow
          detail={state.profile.birthDate ? birthSummary : '출생 정보를 저장하면 요약이 채워져요.'}
          icon="flame-outline"
          label="사주 요약"
          onPress={() => router.push('/profile/saju-summary')}
        />
        <ProfileMenuRow
          detail={
            recentCharacter
              ? `${recentCharacter.name}와 최근 흐름을 확인할 수 있어요.`
              : lastFortuneLabel
                ? `최근 운세 신호: ${lastFortuneLabel}`
                : '최근 연결 흐름이 아직 없어요.'
          }
          icon="heart-outline"
          label="인간관계"
          onPress={() => router.push('/profile/relationships')}
          showDivider
        />
        <ProfileMenuRow
          badge={`${notificationEnabledCount}개`}
          detail="푸시, 채팅 리마인더, 주간 요약을 조정합니다."
          icon="notifications-outline"
          label="알림 설정"
          onPress={() => router.push('/profile/notifications')}
          showDivider
        />
      </ProfileSection>

      <ProfileSection
        actionLabel={isRefreshingPremium ? '새로고침 중...' : '상태 새로고침'}
        description={
          premiumSyncedLabel
            ? `마지막 확인 ${premiumSyncedLabel}`
            : '스토어 상태를 아직 확인하지 않았어요.'
        }
        onActionPress={isRefreshingPremium ? undefined : () => void handleRefreshPremiumState()}
        title="구독 관리"
      >
        <ProfileMenuRow
          badge={premiumStatusBadge}
          detail={
            activeProductLabel
              ? `${activeProductLabel}${premiumExpiryLabel ? ` · ${premiumExpiryLabel}까지` : ''}`
              : `${tokenBalanceLabel}을 사용 중이에요.`
          }
          icon="wallet-outline"
          label="구독 및 토큰"
          onPress={() => router.push('/premium')}
        />
        <ProfileMenuRow
          detail={`이 기기에서 ${state.premium.restoreCount}회 반영했어요.`}
          icon="refresh-outline"
          label={isRestoring ? '구매 복원 중...' : '구매 복원'}
          onPress={() => void handleRestorePurchases()}
          showDivider
        />
        <ProfileMenuRow
          detail="스토어 구독 관리 화면을 엽니다."
          icon="card-outline"
          label="구독 관리"
          onPress={() => void handleOpenSubscriptionManagement()}
          showDivider
        />
      </ProfileSection>

      <ProfileSection title="설정">
        <ProfileMenuRow
          badge="다크"
          detail="현재 모바일 RN 앱은 다크 테마 기준으로 표시됩니다."
          icon="moon-outline"
          label="테마 모드"
        />
        <ProfileMenuRow
          badge={session ? '연결됨' : '게스트'}
          detail={
            session
              ? '현재 계정과 프로필 상태가 연결되어 있어요.'
              : '로그인하면 프로필과 구매 상태를 원격으로 동기화할 수 있어요.'
          }
          icon="link-outline"
          label="계정 연결"
          onPress={
            session
              ? undefined
              : () =>
                  router.push({
                    pathname: '/signup',
                    params: { returnTo: '/profile' },
                  })
          }
          showDivider
        />
      </ProfileSection>

      <ProfileSection title="정보">
        <ProfileMenuRow
          detail="개인정보 처리와 보관 기준을 확인합니다."
          icon="shield-checkmark-outline"
          label="개인정보처리방침"
          onPress={() => router.push('/privacy-policy')}
        />
        <ProfileMenuRow
          detail="서비스 이용 규정을 확인합니다."
          icon="document-text-outline"
          label="이용약관"
          onPress={() => router.push('/terms-of-service')}
          showDivider
        />
      </ProfileSection>

      <View
        style={{
          alignItems: 'center',
          gap: fortuneTheme.spacing.sm,
          paddingBottom: fortuneTheme.spacing.sm,
          paddingTop: fortuneTheme.spacing.xs,
        }}
      >
        <FooterAction
          label={session ? '로그아웃' : '회원가입 / 로그인'}
          onPress={
            session
              ? () => void handleSignOut()
              : () =>
                  router.push({
                    pathname: '/signup',
                    params: { returnTo: '/profile' },
                  })
          }
        />
        <FooterAction
          destructive
          label="계정 삭제"
          onPress={() => router.push('/account-deletion')}
        />
        <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
          v{versionLabel}
        </AppText>
      </View>
    </Screen>
  );
}

function ProfileSection({
  actionLabel,
  children,
  description,
  onActionPress,
  title,
}: {
  actionLabel?: string;
  children: ReactNode;
  description?: string;
  onActionPress?: () => void;
  title: string;
}) {
  return (
    <Card>
      <View
        style={{
          alignItems: 'center',
          flexDirection: 'row',
          gap: fortuneTheme.spacing.sm,
          justifyContent: 'space-between',
        }}
      >
        <View style={{ flex: 1, gap: fortuneTheme.spacing.xs }}>
          <AppText variant="heading4">{title}</AppText>
          {description ? (
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {description}
            </AppText>
          ) : null}
        </View>
        {actionLabel ? (
          <Pressable
            accessibilityRole="button"
            disabled={!onActionPress}
            onPress={onActionPress}
            style={({ pressed }) => ({
              opacity: !onActionPress ? 0.5 : pressed ? 0.78 : 1,
            })}
          >
            <AppText variant="labelMedium" color={fortuneTheme.colors.accentSecondary}>
              {actionLabel}
            </AppText>
          </Pressable>
        ) : null}
      </View>

      <View>{children}</View>
    </Card>
  );
}

function ProfileStatCard({
  label,
  note,
  value,
}: {
  label: string;
  note: string;
  value: string;
}) {
  return (
    <View
      style={{
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        borderColor: fortuneTheme.colors.border,
        borderRadius: fortuneTheme.radius.md,
        borderWidth: 1,
        flex: 1,
        gap: fortuneTheme.spacing.xs,
        minWidth: 0,
        padding: fortuneTheme.spacing.md,
      }}
    >
      <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
        {label}
      </AppText>
      <AppText numberOfLines={1} variant="heading4">
        {value}
      </AppText>
      <AppText numberOfLines={2} variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
        {note}
      </AppText>
    </View>
  );
}

function ProfileMenuRow({
  badge,
  detail,
  icon,
  label,
  onPress,
  showDivider = false,
}: {
  badge?: string;
  detail: string;
  icon: ComponentProps<typeof Ionicons>['name'];
  label: string;
  onPress?: () => void;
  showDivider?: boolean;
}) {
  return (
    <Pressable
      accessibilityRole={onPress ? 'button' : undefined}
      disabled={!onPress}
      onPress={onPress}
      style={({ pressed }) => ({
        opacity: !onPress ? 1 : pressed ? 0.82 : 1,
      })}
    >
      <View
        style={{
          alignItems: 'center',
          borderTopColor: showDivider ? fortuneTheme.colors.border : 'transparent',
          borderTopWidth: showDivider ? 1 : 0,
          flexDirection: 'row',
          gap: fortuneTheme.spacing.md,
          minHeight: 56,
          paddingVertical: fortuneTheme.spacing.sm,
        }}
      >
        <View
          style={{
            alignItems: 'center',
            backgroundColor: fortuneTheme.colors.surfaceSecondary,
            borderRadius: fortuneTheme.radius.full,
            height: 40,
            justifyContent: 'center',
            width: 40,
          }}
        >
          <Ionicons
            color={fortuneTheme.colors.accentSecondary}
            name={icon}
            size={18}
          />
        </View>

        <View style={{ flex: 1, gap: fortuneTheme.spacing.xs, minWidth: 0 }}>
          <AppText variant="bodyMedium">{label}</AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {detail}
          </AppText>
        </View>

        {badge ? (
          <View
            style={{
              backgroundColor: fortuneTheme.colors.surfaceSecondary,
              borderColor: fortuneTheme.colors.border,
              borderRadius: fortuneTheme.radius.full,
              borderWidth: 1,
              paddingHorizontal: fortuneTheme.spacing.sm,
              paddingVertical: fortuneTheme.spacing.xs,
            }}
          >
            <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
              {badge}
            </AppText>
          </View>
        ) : null}

        {onPress ? (
          <Ionicons
            color={fortuneTheme.colors.textTertiary}
            name="chevron-forward"
            size={18}
          />
        ) : null}
      </View>
    </Pressable>
  );
}

function FooterAction({
  destructive = false,
  label,
  onPress,
}: {
  destructive?: boolean;
  label: string;
  onPress: () => void;
}) {
  return (
    <Pressable
      accessibilityRole="button"
      onPress={onPress}
      style={({ pressed }) => ({ opacity: pressed ? 0.72 : 1 })}
    >
      <AppText
        variant="bodyMedium"
        color={
          destructive
            ? fortuneTheme.colors.accentTertiary
            : fortuneTheme.colors.textSecondary
        }
      >
        {label}
      </AppText>
    </Pressable>
  );
}
