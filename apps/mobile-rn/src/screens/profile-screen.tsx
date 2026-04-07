import { useMemo, useState } from 'react';

import { router } from 'expo-router';
import { Linking, Platform, Pressable, View } from 'react-native';
import { getProductDisplayTitle } from '@fortune/product-contracts';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { PrimaryButton } from '../components/primary-button';
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
  const { onboardingProgress, session } = useAppBootstrap();
  const { restorePurchases, state, syncRemoteProfile } = useMobileAppState();
  const savedName =
    state.profile.displayName.trim() ||
    (session?.user.user_metadata.name as string | undefined) ||
    (session?.user.user_metadata.full_name as string | undefined) ||
    session?.user.email ||
    '게스트';
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
    ? '무제한 이용'
    : `${state.premium.tokenBalance.toLocaleString('ko-KR')} 토큰`;
  const hasRecentChatSignal = Boolean(
    state.chat.selectedCharacterId ||
    state.chat.lastFortuneType ||
    state.chat.sentMessageCount > 0,
  );

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
    <Screen>
      <AppText variant="displaySmall">프로필 허브</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        저장된 프로필, 프리미엄 상태, 최근 채팅 신호를 한눈에 볼 수 있습니다.
      </AppText>

      <Card>
        <AppText variant="heading4">저장된 프로필</AppText>
        <AppText variant="labelLarge">{savedName}</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {state.profile.birthDate || state.profile.birthTime
            ? [
                state.profile.birthDate || "생년월일 미저장",
                state.profile.birthTime || "시간 미저장",
              ].join(" · ")
            : "생년월일 미저장"}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {state.profile.mbti || "MBTI 미저장"} ·{" "}
          {state.profile.bloodType || "혈액형 미저장"}
        </AppText>
        <View style={{ gap: 8 }}>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {session ? '로그인한 계정으로 보고 있어요.' : '게스트 상태로 보고 있어요.'}
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {state.profile.displayName
              ? '저장된 이름이 있어요.'
              : '저장된 이름은 아직 없어요.'}
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {state.profile.birthDate
              ? '사주 해석에 필요한 출생 정보가 준비되어 있어요.'
              : '사주 해석을 위해 출생 정보 저장이 먼저 필요해요.'}
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {onboardingProgress.birthCompleted
              ? '온보딩의 출생 단계는 완료됐어요.'
              : '온보딩의 출생 단계는 아직 진행 중이에요.'}
          </AppText>
        </View>
      </Card>

      <Card>
        <AppText variant="heading4">프리미엄 / 토큰</AppText>
        <AppText variant="labelLarge">{tokenBalanceLabel}</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {state.premium.status === "subscription"
            ? "구독이 활성화되어 있어요."
            : state.premium.status === "lifetime"
              ? "평생 이용 상태예요."
              : "아직 구독 전 상태예요."}
        </AppText>
        <View style={{ gap: 8 }}>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            구매 복원은 {state.premium.restoreCount}번 반영됐어요.
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {activeProductLabel
              ? `연결된 상품: ${activeProductLabel}`
              : '연결된 구독 상품은 아직 없어요.'}
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {premiumExpiryLabel
              ? `구독 만료일 ${premiumExpiryLabel}`
              : '활성 구독 만료 정보가 없어요.'}
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {premiumSyncedLabel
              ? `마지막 확인 ${premiumSyncedLabel}`
              : '구독 상태는 아직 확인하지 않았어요.'}
          </AppText>
        </View>
        <PrimaryButton
          onPress={() => void handleRefreshPremiumState()}
          tone="secondary"
        >
          {isRefreshingPremium ? '구독 상태 새로고침 중...' : '구독 상태 새로고침'}
        </PrimaryButton>
      </Card>

      <Card>
        <AppText variant="heading4">최근 채팅 신호</AppText>
        <AppText variant="labelLarge">
          {recentCharacter?.name ?? "최근 캐릭터 없음"}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {hasRecentChatSignal
            ? state.chat.sentMessageCount > 0
              ? `메시지 ${state.chat.sentMessageCount}개를 보냈어요.`
              : `최근 선택 캐릭터: ${recentCharacter?.name ?? '기록 없음'}`
            : "아직 채팅 신호가 없습니다."}
        </AppText>
        <View style={{ gap: 8 }}>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {state.chat.sentMessageCount > 0
              ? `최근 운세 신호: ${lastFortuneLabel ?? '정리 중'}`
              : '최근 운세 신호가 아직 없어요.'}
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {recentCharacter
              ? `최근 캐릭터: ${recentCharacter.name}`
              : '최근 캐릭터 기록이 없어요.'}
          </AppText>
        </View>
        {recentCharacter ? (
        <PrimaryButton
          onPress={() =>
            router.push({
              pathname: '/character/[id]',
              params: { id: recentCharacter.id, returnTo: '/profile' },
              })
            }
            tone="secondary"
          >
            최근 캐릭터 프로필 보기
          </PrimaryButton>
        ) : null}
        <PrimaryButton onPress={() => router.push('/chat')} tone="secondary">
          채팅으로 이어가기
        </PrimaryButton>
      </Card>

      <Card>
        <AppText variant="heading4">나의 온도</AppText>
        <ProfileMenuRow
          label="프로필 수정"
          description="이름과 출생 정보를 수정합니다."
          onPress={() => router.push('/profile/edit')}
        />
        <ProfileMenuRow
          label="사주 요약"
          description="저장된 출생 정보와 최근 신호를 한 번에 확인합니다."
          onPress={() => router.push('/profile/saju-summary')}
        />
        <ProfileMenuRow
          label="인간관계"
          description="최근 선택과 운세 신호를 바탕으로 연결 흐름을 봅니다."
          onPress={() => router.push('/profile/relationships')}
        />
        <ProfileMenuRow
          label="알림 설정"
          description="알림 기본값을 조정합니다."
          onPress={() => router.push('/profile/notifications')}
        />
      </Card>

      <Card>
        <AppText variant="heading4">구독 관리</AppText>
        <ProfileMenuRow
          label="구독 및 토큰 구매"
          description="프로 구독, 맥스 구독, 토큰 10·50·100·200"
          onPress={() => router.push('/premium')}
        />
        <ProfileMenuRow
          label={isRestoring ? '구매 복원 중...' : '구매 복원'}
          description='이 기기의 프리미엄/토큰 상태를 다시 반영'
          onPress={() => void handleRestorePurchases()}
        />
        <ProfileMenuRow
          label='구독 관리'
          description='스토어의 구독 관리 화면 열기'
          onPress={() => void handleOpenSubscriptionManagement()}
        />
        <ProfileMenuRow
          label="개인정보처리방침"
          description="법률 및 정책 문서"
          onPress={() => router.push('/privacy-policy')}
        />
        <ProfileMenuRow
          label="이용약관"
          description="서비스 이용 정책"
          onPress={() => router.push('/terms-of-service')}
        />
      </Card>

      {!session ? (
        <Card>
          <AppText variant="heading4">계정 연결</AppText>
          <AppText
            variant="bodySmall"
            color={fortuneTheme.colors.textSecondary}
          >
            로그인하면 원격 계정과 동기화할 수 있지만, 지금 보이는 프로필 상태는
            이 기기에 저장된 값입니다.
          </AppText>
          <PrimaryButton
            onPress={() =>
              router.push({
                pathname: '/signup',
                params: { returnTo: '/profile' },
              })
            }
          >
            회원가입 / 로그인
          </PrimaryButton>
        </Card>
      ) : null}

      {session ? (
        <Card>
          <AppText variant="heading4">계정</AppText>
          <PrimaryButton onPress={() => void handleSignOut()} tone="secondary">
            로그아웃
          </PrimaryButton>
          <PrimaryButton onPress={() => router.push('/account-deletion')}>
            계정 삭제
          </PrimaryButton>
        </Card>
      ) : null}
    </Screen>
  );
}

function ProfileMenuRow({
  description,
  label,
  onPress,
}: {
  description: string;
  label: string;
  onPress: () => void;
}) {
  return (
    <Pressable
      accessibilityRole="button"
      onPress={onPress}
      style={({ pressed }) => ({
        opacity: pressed ? 0.82 : 1,
      })}
    >
      <View
        style={{
          borderBottomColor: fortuneTheme.colors.border,
          borderBottomWidth: 1,
          gap: fortuneTheme.spacing.xs,
          paddingVertical: fortuneTheme.spacing.sm,
        }}
      >
        <AppText variant="bodyMedium">{label}</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {description}
        </AppText>
      </View>
    </Pressable>
  );
}
