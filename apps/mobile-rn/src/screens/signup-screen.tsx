import { useEffect, useState } from 'react';

import { router, useLocalSearchParams, type Href } from 'expo-router';
import { View } from 'react-native';

import { AppleAuthButton } from '../components/apple-auth-button';
import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { PrimaryButton } from '../components/primary-button';
import {
  resolveBackDestinationLabel,
  RouteBackHeader,
} from '../components/route-back-header';
import { Screen } from '../components/screen';
import { SocialAuthPillButton } from '../components/social-auth-pill-button';
import { captureError } from '../lib/error-reporting';
import {
  socialAuthProviderLabelById,
  type SocialAuthProviderId,
} from '../lib/social-auth';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';
import { useSocialAuth } from '../providers/social-auth-provider';

const authOptions: readonly {
  id: SocialAuthProviderId;
  label: string;
  note: string;
}[] = [
  {
    id: 'apple',
    label: '애플 로그인',
    note: 'iPhone에서 가장 자연스럽게 인증하고 기록을 이어갑니다.',
  },
  {
    id: 'google',
    label: '구글 로그인',
    note: '구글 계정으로 개인화와 구매 내역을 바로 연결합니다.',
  },
  {
    id: 'kakao',
    label: '카카오 로그인',
    note: '카카오 계정으로 빠르게 시작하고 추천 흐름을 이어갑니다.',
  },
  {
    id: 'naver',
    label: '네이버 로그인',
    note: '네이버 계정으로 프로필과 저장 기록을 연결합니다.',
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
  const params = useLocalSearchParams<{
    requireAuth?: string | string[];
    returnTo?: string | string[];
  }>();
  const [activeProviderId, setActiveProviderId] =
    useState<SocialAuthProviderId | null>(null);
  const [authMessage, setAuthMessage] = useState<string | null>(null);
  const {
    markGuestBrowse,
    session,
    status: bootstrapStatus,
  } = useAppBootstrap();
  const { startSocialAuth } = useSocialAuth();
  const returnTo = normalizeReturnTo(readSearchParam(params.returnTo));
  const requireAuth = readSearchParam(params.requireAuth) === '1';
  const backDestinationHref = (requireAuth ? '/chat' : returnTo) as Href;
  const backDestinationLabel = resolveBackDestinationLabel(backDestinationHref);

  useEffect(() => {
    if (bootstrapStatus !== 'ready' || !session) {
      return;
    }

    router.replace({
      pathname: '/auth/callback',
      params: { returnTo },
    });
  }, [bootstrapStatus, returnTo, session]);

  async function handleSocialAuthStart(providerId: SocialAuthProviderId) {
    try {
      setActiveProviderId(providerId);
      setAuthMessage(null);

      const result = await startSocialAuth(providerId, returnTo);

      if (result.status === 'started') {
        setAuthMessage(
          `${socialAuthProviderLabelById[providerId]} 로그인을 진행하고 있습니다. 잠시만 기다려 주세요.`,
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
          fallbackHref={backDestinationHref}
          label={backDestinationLabel}
        />
      }
    >
      <AppText variant="displaySmall">계정을 연결하고 시작</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        원하는 계정으로 시작하면 분석 기록, 구매 내역, 추천 설정이 계속 이어집니다.
      </AppText>

      <Card>
        <AppText variant="heading4">연결하고 바로 시작</AppText>
        <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
          한 번 로그인해 두면 결과 저장, 개인화, 결제 상태가 계정에 연결됩니다.
          원하는 방법으로 바로 시작하세요.
        </AppText>
        {authMessage ? (
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {authMessage}
          </AppText>
        ) : null}
        {authOptions.map((option) => (
          <View key={option.id} style={{ gap: 8 }}>
            {option.id === 'apple' ? (
              <AppleAuthButton
                disabled={activeProviderId === option.id}
                label={option.label}
                onPress={() => void handleSocialAuthStart(option.id)}
              />
            ) : (
              <SocialAuthPillButton
                disabled={activeProviderId === option.id}
                label={
                  activeProviderId === option.id
                    ? `${option.label} 준비 중...`
                    : option.label
                }
                onPress={() => void handleSocialAuthStart(option.id)}
                provider={option.id}
              />
            )}
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
          하나의 계정으로 기록, 추천, 구매 상태를 계속 이어갈 수 있습니다.
        </AppText>
      </Card>

      {!requireAuth ? (
        <Card>
          <AppText variant="heading4">로그인 없이 먼저 보기</AppText>
          <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
            서비스 흐름을 먼저 확인한 뒤, 필요할 때 계정을 연결해도 됩니다.
          </AppText>
          <PrimaryButton
            onPress={() => {
              markGuestBrowse()
                .then(() => router.replace(returnTo as Href))
                .catch(() => router.replace(returnTo as Href));
            }}
          >
            로그인 없이 둘러보기
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
            정보 먼저 입력하기
          </PrimaryButton>
          <PrimaryButton
            onPress={() => router.replace(returnTo as Href)}
            tone="secondary"
          >
            {returnTo === '/chat' ? '채팅으로 돌아가기' : '이전 화면으로 돌아가기'}
          </PrimaryButton>
        </Card>
      ) : null}
    </Screen>
  );
}
