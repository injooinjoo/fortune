import { router, useLocalSearchParams } from 'expo-router';
import { useEffect, useMemo, useState } from 'react';
import { resolveDeepLink } from '@fortune/product-contracts';

import { AccountSnapshotCard } from '../components/account-snapshot-card';
import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { captureError } from '../lib/error-reporting';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';
import { useMobileAppState } from '../providers/mobile-app-state-provider';

export function AuthCallbackScreen() {
  const params = useLocalSearchParams<{ authCallbackUrl?: string }>();
  const {
    markAuthComplete,
    onboardingProgress,
    session,
    status: bootstrapStatus,
  } = useAppBootstrap();
  const { state, status: appStateStatus, syncRemoteProfile } = useMobileAppState();
  const [hasHandled, setHasHandled] = useState(false);
  const decodedCallbackUrl = params.authCallbackUrl
    ? decodeURIComponent(params.authCallbackUrl)
    : null;
  const resolution = useMemo(
    () => (decodedCallbackUrl ? resolveDeepLink(decodedCallbackUrl) : null),
    [decodedCallbackUrl],
  );
  const provider = useMemo(() => {
    if (!decodedCallbackUrl) {
      return (session?.user.app_metadata.provider as string | undefined) ?? null;
    }

    try {
      return (
        new URL(decodedCallbackUrl).searchParams.get('provider') ??
        ((session?.user.app_metadata.provider as string | undefined) ?? null)
      );
    } catch {
      return (session?.user.app_metadata.provider as string | undefined) ?? null;
    }
  }, [decodedCallbackUrl, session?.user.app_metadata.provider]);

  useEffect(() => {
    if (
      hasHandled ||
      bootstrapStatus !== 'ready' ||
      appStateStatus !== 'ready'
    ) {
      return;
    }

    async function finalizeCallback() {
      try {
        if (session) {
          await markAuthComplete();

          try {
            await syncRemoteProfile();
          } catch (error) {
            await captureError(error, {
              surface: 'auth-callback:remote-sync',
            });
          }
        }

        setHasHandled(true);
        router.replace(resolution?.route ?? '/chat');
      } catch (error) {
        await captureError(error, { surface: 'auth-callback:finalize' });
      }
    }

    finalizeCallback().catch(() => undefined);
  }, [
    appStateStatus,
    bootstrapStatus,
    hasHandled,
    markAuthComplete,
    resolution?.route,
    session,
    syncRemoteProfile,
  ]);

  return (
    <Screen>
      <AppText variant="labelMedium" color={fortuneTheme.colors.accentSecondary}>
        /auth/callback
      </AppText>
      <AppText variant="displaySmall">Auth Callback</AppText>
      <AccountSnapshotCard
        description="OAuth 복귀 뒤 shared state에 계정/프로필 힌트를 반영합니다."
        onboardingProgress={onboardingProgress}
        premium={state.premium}
        profile={state.profile}
        sessionActive={Boolean(session)}
        title="복귀 상태"
      />
      <Card>
        <AppText variant="bodyMedium">
          Supabase OAuth 복귀 URL과 딥링크 의도를 RN에서 동일하게 해석합니다.
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
          callback state: {resolution ? 'resolved' : 'waiting'}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
          bootstrap: {bootstrapStatus} · app-state: {appStateStatus}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
          source: {params.authCallbackUrl ?? 'none'}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
          route: {resolution?.route ?? '/chat'}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
          session: {session ? 'active' : bootstrapStatus === 'ready' ? 'missing' : 'restoring'}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
          provider: {provider ?? 'unknown'}
        </AppText>
        <PrimaryButton onPress={() => router.replace(resolution?.route ?? '/chat')}>
          이어서 이동
        </PrimaryButton>
        <PrimaryButton onPress={() => router.replace('/chat')} tone="secondary">
          Chat으로 돌아가기
        </PrimaryButton>
      </Card>
    </Screen>
  );
}
