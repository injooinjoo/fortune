import { useState } from 'react';

import { router, useLocalSearchParams, type Href } from 'expo-router';
import { View } from 'react-native';

import { AccountSnapshotCard } from '../components/account-snapshot-card';
import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { Chip } from '../components/chip';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { captureError } from '../lib/error-reporting';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';
import { useMobileAppState } from '../providers/mobile-app-state-provider';
import { useSocialAuth } from '../providers/social-auth-provider';

const authOptions = [
  {
    id: 'google',
    label: 'Google로 계속하기',
    note: '현재 reachable start flow에서 실제로 연결된 소셜 로그인 진입점',
  },
] as const;

function readSearchParam(
  value: string | string[] | undefined,
): string | undefined {
  return Array.isArray(value) ? value[0] : value;
}

function normalizeReturnTo(value: string | undefined) {
  return value && value.startsWith('/') ? value : '/chat';
}

export function SignupScreen() {
  const params = useLocalSearchParams<{ returnTo?: string | string[] }>();
  const [activeProviderId, setActiveProviderId] = useState<string | null>(null);
  const [authMessage, setAuthMessage] = useState<string | null>(null);
  const { gate, markGuestBrowse, onboardingProgress, session } = useAppBootstrap();
  const { state } = useMobileAppState();
  const { startSocialAuth } = useSocialAuth();
  const returnTo = normalizeReturnTo(readSearchParam(params.returnTo));

  async function handleSocialAuthStart(providerId: 'apple' | 'google' | 'kakao') {
    try {
      setActiveProviderId(providerId);
      setAuthMessage(null);

      const result = await startSocialAuth(providerId, returnTo);

      if (result.status === 'started') {
        setAuthMessage(
          `${authOptions.find((option) => option.id === providerId)?.label ?? providerId} 브라우저 인증을 시작했습니다. 완료 후 앱으로 돌아옵니다.`,
        );
        return;
      }

      setAuthMessage(result.errorMessage ?? '로그인을 시작하지 못했습니다.');
    } catch (error) {
      await captureError(error, { surface: 'signup:start-social-auth' });
      setAuthMessage('소셜 로그인을 시작하지 못했습니다.');
    } finally {
      setActiveProviderId(null);
    }
  }

  return (
    <Screen>
      <AppText variant="labelMedium" color={fortuneTheme.colors.accentSecondary}>
        /signup
      </AppText>
      <AppText variant="displaySmall">가입 및 로그인</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        실제 소셜 로그인 시작을 RN에서 열고, 복귀는 동일한 `/auth/callback` 계약으로 처리합니다.
      </AppText>

      <Card>
        <AppText variant="heading4">계정 시작</AppText>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          <Chip label="guest browse" tone="accent" />
          <Chip label="oauth callback" />
          <Chip label="profile unlock" />
        </View>
      </Card>

      <AccountSnapshotCard
        description="앱 재실행 후에도 남아 있는 프로필과 premium 상태를 먼저 보여줍니다."
        gate={gate}
        onboardingProgress={onboardingProgress}
        premium={state.premium}
        profile={state.profile}
        sessionActive={Boolean(session)}
      />

      <Card>
        <AppText variant="heading4">소셜 로그인</AppText>
        {authMessage ? (
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {authMessage}
          </AppText>
        ) : null}
        {authOptions.map((option) => (
          <View key={option.id} style={{ gap: 8 }}>
            <PrimaryButton
              onPress={() => void handleSocialAuthStart(option.id)}
            >
              {activeProviderId === option.id
                ? `${option.label} 준비 중...`
                : option.label}
            </PrimaryButton>
            <AppText
              variant="bodySmall"
              color={fortuneTheme.colors.textTertiary}
            >
              {option.note}
            </AppText>
          </View>
        ))}
        <AppText
          variant="bodySmall"
          color={fortuneTheme.colors.textTertiary}
        >
          Apple / Kakao 계정 연결은 이후 계정 관리 표면에서 붙입니다. 현재 reachable start flow는 Google 기준으로 먼저 고정합니다.
        </AppText>
      </Card>

      <Card>
        <AppText variant="heading4">왜 필요한가요?</AppText>
        <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
          로그인 후에는 프로필 수정, 관계 관리, 구매 복원, 알림 설정 등 계정 기반 표면이 활성화됩니다.
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
          게스트로 먼저 둘러본 뒤 언제든 로그인으로 전환할 수 있습니다.
        </AppText>
        <PrimaryButton
          onPress={() => {
            markGuestBrowse()
              .then(() => router.replace(returnTo as Href))
              .catch(() => router.replace(returnTo as Href));
          }}
        >
          게스트로 둘러보기
        </PrimaryButton>
        <PrimaryButton
          onPress={() =>
            router.push({
              pathname: '/onboarding',
              params: { returnTo },
            })
          }
          tone="secondary"
        >
          온보딩 계속하기
        </PrimaryButton>
        <PrimaryButton
          onPress={() => router.replace(returnTo as Href)}
          tone="secondary"
        >
          {returnTo === '/chat' ? 'Chat으로 돌아가기' : '이전 화면으로 돌아가기'}
        </PrimaryButton>
      </Card>
    </Screen>
  );
}
