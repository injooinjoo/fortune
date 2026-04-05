import { router, useLocalSearchParams } from 'expo-router';
import { resolveDeepLink } from '@fortune/product-contracts';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { Chip } from '../components/chip';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';

export function AuthCallbackScreen() {
  const { markAuthComplete } = useAppBootstrap();
  const params = useLocalSearchParams<{ authCallbackUrl?: string }>();
  const resolution = params.authCallbackUrl
    ? resolveDeepLink(decodeURIComponent(params.authCallbackUrl))
    : null;
  const callbackUrl = params.authCallbackUrl
    ? decodeURIComponent(params.authCallbackUrl)
    : null;
  const provider = callbackUrl
    ? new URL(callbackUrl).searchParams.get('provider')
    : null;

  async function handleContinue() {
    await markAuthComplete().catch(() => undefined);
    router.replace(resolution?.route ?? '/chat');
  }

  return (
    <Screen>
      <AppText variant="labelMedium" color={fortuneTheme.colors.accentSecondary}>
        /auth/callback
      </AppText>
      <AppText variant="displaySmall">Auth Callback</AppText>
      <Card>
        <AppText variant="bodyMedium">
          Supabase OAuth 복귀 URL과 딥링크 의도를 RN에서 동일하게 해석합니다.
        </AppText>
        <Chip
          label={provider ? `provider:${provider}` : 'provider:unknown'}
          tone="accent"
        />
        <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
          callback state: {resolution ? 'resolved' : 'waiting'}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
          source: {params.authCallbackUrl ?? 'none'}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
          route: {resolution?.route ?? '/chat'}
        </AppText>
        <PrimaryButton onPress={() => void handleContinue()}>
          이어서 이동
        </PrimaryButton>
        <PrimaryButton onPress={() => router.replace('/chat')} tone="secondary">
          Chat으로 돌아가기
        </PrimaryButton>
      </Card>
    </Screen>
  );
}
