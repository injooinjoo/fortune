import { useEffect, useState } from 'react';

import { router, useLocalSearchParams, type Href } from 'expo-router';
import { Pressable, View } from 'react-native';

import { AuthSheetCard, AuthSheetModal } from '../components/auth-sheet';
import { AppText } from '../components/app-text';
import { PrimaryButton } from '../components/primary-button';
import { resolveBackDestinationLabel } from '../components/route-back-header';
import { captureError } from '../lib/error-reporting';
import {
  socialAuthProviderLabelById,
  type SocialAuthProviderId,
} from '../lib/social-auth';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';
import { useSocialAuth } from '../providers/social-auth-provider';

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

  function dismissSheet() {
    if (router.canGoBack()) {
      router.back();
      return;
    }

    router.replace(backDestinationHref);
  }

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

  async function handleBrowse() {
    await markGuestBrowse().catch(() => undefined);
    dismissSheet();
  }

  return (
    <AuthSheetModal onDismiss={dismissSheet}>
      <AuthSheetCard
        activeProviderId={activeProviderId}
        authMessage={authMessage}
        footer={
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {!requireAuth ? (
              <>
                <PrimaryButton
                  onPress={() =>
                    router.push({
                      pathname: '/onboarding',
                      params: { returnTo },
                    })
                  }
                  tone="secondary"
                >
                  정보 입력하고 시작
                </PrimaryButton>
                <Pressable
                  accessibilityRole="button"
                  onPress={dismissSheet}
                  style={({ pressed }) => ({ opacity: pressed ? 0.8 : 1 })}
                >
                  <AppText
                    variant="bodySmall"
                    color={fortuneTheme.colors.textSecondary}
                    style={{ textAlign: 'center' }}
                  >
                    {backDestinationLabel
                      ? `${backDestinationLabel}로 돌아가기`
                      : '이전 화면으로 돌아가기'}
                  </AppText>
                </Pressable>
              </>
            ) : (
              <AppText
                variant="caption"
                color={fortuneTheme.colors.textSecondary}
                style={{ textAlign: 'center' }}
              >
                로그인 후 바로 이어서 진행됩니다.
              </AppText>
            )}
          </View>
        }
        onApple={() => void handleSocialAuthStart('apple')}
        onBrowse={!requireAuth ? () => void handleBrowse() : undefined}
        onDismiss={dismissSheet}
        onGoogle={() => void handleSocialAuthStart('google')}
        onKakao={() => void handleSocialAuthStart('kakao')}
        onNaver={() => void handleSocialAuthStart('naver')}
        subtitle="로그인하면 분석 기록, 맞춤 추천, 구매 내역이 계정에 연결되고 지금 보던 흐름에서 바로 이어집니다."
        title="로그인으로 지금 대화를 이어가세요"
      />
    </AuthSheetModal>
  );
}
