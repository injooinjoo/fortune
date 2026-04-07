import { useState } from 'react';

import { router, useLocalSearchParams, type Href } from 'expo-router';
import { View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { PrimaryButton } from '../components/primary-button';
import { RouteBackHeader } from '../components/route-back-header';
import { Screen } from '../components/screen';
import { captureError } from '../lib/error-reporting';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';
import { useSocialAuth } from '../providers/social-auth-provider';

const authOptions = [
  {
    id: 'google',
    label: 'Google로 계속하기',
    note: '가장 빠르게 시작할 수 있는 로그인 방법입니다.',
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
  const { markGuestBrowse } = useAppBootstrap();
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
    <Screen
      header={
        <RouteBackHeader
          fallbackHref={returnTo as Href}
          label="로그인 및 시작"
        />
      }
    >
      <AppText variant="displaySmall">로그인 및 시작</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        원하는 계정으로 시작하면 이후에도 프로필과 구매 정보를 이어서 사용할 수 있어요.
      </AppText>

      <Card>
        <AppText variant="heading4">시작 방법</AppText>
        <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
          로그인하면 프로필, 구매 내역, 알림 설정이 기기에 연결돼요. 먼저 둘러본 뒤 나중에 로그인해도 됩니다.
        </AppText>
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
          지금은 Google로 시작할 수 있고, 필요한 계정은 나중에 추가할 수 있습니다.
        </AppText>
      </Card>

      <Card>
        <AppText variant="heading4">게스트로 먼저 보기</AppText>
        <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
          계정 없이 먼저 둘러본 다음 언제든 로그인으로 전환할 수 있어요.
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
          {returnTo === '/chat' ? '채팅으로 돌아가기' : '이전 화면으로 돌아가기'}
        </PrimaryButton>
      </Card>
    </Screen>
  );
}
