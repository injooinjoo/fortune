import { router, useLocalSearchParams, type Href } from 'expo-router';
import { useEffect, useMemo, useState } from 'react';

import { AccountSnapshotCard } from '../components/account-snapshot-card';
import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { captureError } from '../lib/error-reporting';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';
import { useMobileAppState } from '../providers/mobile-app-state-provider';

function readSearchParam(
  value: string | string[] | undefined,
): string | undefined {
  return Array.isArray(value) ? value[0] : value;
}

function normalizeReturnTo(value: string | null | undefined) {
  return value && value.startsWith('/') && value !== '/auth/callback'
    ? value
    : '/chat';
}

export function AuthCallbackScreen() {
  const params = useLocalSearchParams<{
    authCallbackUrl?: string | string[];
  }>();
  const {
    markAuthComplete,
    onboardingProgress,
    session,
    status: bootstrapStatus,
  } = useAppBootstrap();
  const { state, status: appStateStatus, syncRemoteProfile } = useMobileAppState();
  const [hasHandled, setHasHandled] = useState(false);
  const authCallbackUrl = readSearchParam(params.authCallbackUrl);
  const decodedCallbackUrl = authCallbackUrl
    ? decodeURIComponent(authCallbackUrl)
    : null;
  const callbackMeta = useMemo(() => {
    if (!decodedCallbackUrl) {
      return {
        errorMessage: null,
        provider:
          (session?.user.app_metadata.provider as string | undefined) ?? null,
        returnTo: '/chat',
      };
    }

    try {
      const url = new URL(decodedCallbackUrl);
      const hashParams = new URLSearchParams(
        url.hash.startsWith('#') ? url.hash.slice(1) : url.hash,
      );

        return {
          errorMessage:
            url.searchParams.get('error_description') ??
            hashParams.get('error_description') ??
            url.searchParams.get('error') ??
            hashParams.get('error'),
          provider:
            url.searchParams.get('provider') ??
            hashParams.get('provider') ??
            ((session?.user.app_metadata.provider as string | undefined) ?? null),
          returnTo: normalizeReturnTo(
            url.searchParams.get('returnTo') ?? hashParams.get('returnTo'),
          ),
        };
      } catch {
        return {
          errorMessage: null,
          provider:
            (session?.user.app_metadata.provider as string | undefined) ?? null,
          returnTo: '/chat',
        };
      }
    }, [decodedCallbackUrl, session?.user.app_metadata.provider]);

  useEffect(() => {
    if (
      hasHandled ||
      bootstrapStatus !== 'ready' ||
      appStateStatus !== 'ready' ||
      !session ||
      callbackMeta.errorMessage
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
        router.replace(callbackMeta.returnTo as Href);
      } catch (error) {
        await captureError(error, { surface: 'auth-callback:finalize' });
      }
    }

    finalizeCallback().catch(() => undefined);
  }, [
    appStateStatus,
    bootstrapStatus,
    callbackMeta.errorMessage,
    callbackMeta.returnTo,
    hasHandled,
    markAuthComplete,
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
          callback state:{' '}
          {callbackMeta.errorMessage
            ? 'error'
            : session
              ? 'resolved'
              : decodedCallbackUrl
                ? 'waiting-session'
                : 'waiting'}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
          bootstrap: {bootstrapStatus} · app-state: {appStateStatus}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
          source: {authCallbackUrl ?? 'none'}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
          route: {callbackMeta.returnTo}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
          session: {session ? 'active' : bootstrapStatus === 'ready' ? 'missing' : 'restoring'}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
          provider: {callbackMeta.provider ?? 'unknown'}
        </AppText>
        {callbackMeta.errorMessage ? (
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            error: {callbackMeta.errorMessage}
          </AppText>
        ) : null}
        <PrimaryButton onPress={() => router.replace(callbackMeta.returnTo as Href)}>
          이어서 이동
        </PrimaryButton>
        <PrimaryButton
          onPress={() => router.replace(callbackMeta.returnTo as Href)}
          tone="secondary"
        >
          {callbackMeta.returnTo === '/chat'
            ? 'Chat으로 돌아가기'
            : '이전 화면으로 돌아가기'}
        </PrimaryButton>
      </Card>
    </Screen>
  );
}
