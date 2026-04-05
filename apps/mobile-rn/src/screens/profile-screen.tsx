import { useMemo, useState } from 'react';

import { router } from 'expo-router';
import { Linking, Platform, Pressable, View } from 'react-native';

import {
  fortuneCharacters,
  fortuneTypesById,
} from '@fortune/product-contracts';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { Chip } from '../components/chip';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { captureError } from '../lib/error-reporting';
import { supabase } from '../lib/supabase';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';
import { useMobileAppState } from '../providers/mobile-app-state-provider';

export function ProfileScreen() {
  const [isRestoring, setIsRestoring] = useState(false);
  const { onboardingProgress, session } = useAppBootstrap();
  const { restorePurchases, state } = useMobileAppState();
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

    return (
      fortuneCharacters.find(
        (character) => character.id === state.chat.selectedCharacterId,
      ) ?? null
    );
  }, [state.chat.selectedCharacterId]);
  const lastFortuneType = state.chat.lastFortuneType
    ? fortuneTypesById[state.chat.lastFortuneType]
    : null;
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

  return (
    <Screen>
      <AppText
        variant="labelMedium"
        color={fortuneTheme.colors.accentSecondary}
      >
        /profile
      </AppText>
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
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {state.profile.birthDate
            ? '사주 해석에 필요한 출생 정보가 준비되어 있습니다.'
            : '사주 해석 전에는 생년월일 저장이 먼저 필요합니다.'}
        </AppText>
        <View style={{ flexDirection: "row", flexWrap: "wrap", gap: 8 }}>
          <Chip
            label={`provider:${session?.user.app_metadata.provider ?? "guest"}`}
            tone="accent"
          />
          <Chip label={`saved:${state.profile.displayName ? "yes" : "no"}`} />
          <Chip
            label={`birth:${state.profile.birthDate ? "saved" : "empty"}`}
            tone={state.profile.birthDate ? "success" : "neutral"}
          />
          <Chip
            label={`gate:${onboardingProgress.birthCompleted ? "ready" : "todo"}`}
          />
        </View>
      </Card>

      <Card>
        <AppText variant="heading4">프리미엄 / 토큰</AppText>
        <AppText variant="labelLarge">
          {state.premium.tokenBalance.toLocaleString("ko-KR")} tokens
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {state.premium.status === "subscription"
            ? "구독 상태입니다."
            : state.premium.status === "lifetime"
              ? "평생 이용 상태입니다."
              : "구독 전 상태입니다."}
        </AppText>
        <View style={{ flexDirection: "row", flexWrap: "wrap", gap: 8 }}>
          <Chip label={`status:${state.premium.status}`} tone="accent" />
          <Chip label={`restore:${state.premium.restoreCount}`} />
          <Chip label={`balance:${state.premium.tokenBalance}`} />
          {state.premium.activeProductId ? (
            <Chip
              label={`active:${state.premium.activeProductId}`}
              tone="success"
            />
          ) : null}
        </View>
      </Card>

      <Card>
        <AppText variant="heading4">최근 채팅 신호</AppText>
        <AppText variant="labelLarge">
          {recentCharacter?.name ?? "최근 캐릭터 없음"}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {hasRecentChatSignal
            ? state.chat.sentMessageCount > 0
              ? `메시지 ${state.chat.sentMessageCount}개 · ${
                  lastFortuneType?.labelKey ??
                  state.chat.lastFortuneType ??
                  "fortune 없음"
                }`
              : `최근 선택 캐릭터: ${recentCharacter?.name ?? state.chat.selectedCharacterId}`
            : "아직 채팅 신호가 없습니다."}
        </AppText>
        <View style={{ flexDirection: "row", flexWrap: "wrap", gap: 8 }}>
          <Chip
            label={`messages:${state.chat.sentMessageCount}`}
            tone={state.chat.sentMessageCount > 0 ? "success" : "neutral"}
          />
          <Chip
            label={
              state.chat.lastFortuneType
                ? `fortune:${state.chat.lastFortuneType}`
                : "fortune:none"
            }
          />
          <Chip
            label={
              recentCharacter
                ? `character:${recentCharacter.name}`
                : "character:none"
            }
          />
        </View>
        {recentCharacter ? (
          <PrimaryButton
            onPress={() =>
              router.push({
                pathname: '/character/[id]',
                params: { id: recentCharacter.id },
              })
            }
            tone="secondary"
          >
            최근 캐릭터 프로필 보기
          </PrimaryButton>
        ) : null}
        <PrimaryButton onPress={() => router.push('/chat')} tone="secondary">
          Chat으로 이어가기
        </PrimaryButton>
      </Card>

      <Card>
        <AppText variant="heading4">나의 온도</AppText>
        <ProfileMenuRow
          label="프로필 수정"
          description="이름, 출생 정보, 이미지 표면"
          onPress={() => router.push('/profile/edit')}
        />
        <ProfileMenuRow
          label="알림 설정"
          description="푸시 및 딥링크 기본값"
          onPress={() => router.push('/profile/notifications')}
        />
      </Card>

      <Card>
        <AppText variant="heading4">구독 관리</AppText>
        <ProfileMenuRow
          label="구독 및 토큰"
          description="프리미엄 구독과 토큰 패키지"
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
