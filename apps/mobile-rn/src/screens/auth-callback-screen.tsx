import { router, useLocalSearchParams, type Href } from 'expo-router';
import { useEffect, useMemo, useState } from 'react';
import { ActivityIndicator, View } from 'react-native';

import { AppText } from '../components/app-text';
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
    error?: string | string[];
    error_description?: string | string[];
    returnTo?: string | string[];
  }>();
  const {
    markAuthComplete,
    onboardingProgress,
    session,
    status: bootstrapStatus,
  } = useAppBootstrap();
  const { status: appStateStatus, syncRemoteProfile } = useMobileAppState();
  const [hasHandled, setHasHandled] = useState(false);
  // 세션이 정해진 시간 안에 회수되지 않으면 무한 스피너에 갇히지 않도록
  // 사용자에게 재시도 UI를 보여준다. (QA-A F1)
  const [timedOut, setTimedOut] = useState(false);
  const authCallbackUrl = readSearchParam(params.authCallbackUrl);
  const decodedCallbackUrl = authCallbackUrl
    ? decodeURIComponent(authCallbackUrl)
    : null;
  const directReturnTo = normalizeReturnTo(readSearchParam(params.returnTo));
  const directErrorMessage =
    readSearchParam(params.error_description) ?? readSearchParam(params.error);
  const callbackMeta = useMemo(() => {
    if (!decodedCallbackUrl) {
      return {
        errorMessage: directErrorMessage,
        returnTo: directReturnTo,
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
        returnTo: normalizeReturnTo(
          url.searchParams.get('returnTo') ?? hashParams.get('returnTo'),
        ),
      };
    } catch {
      return {
        errorMessage: null,
        returnTo: directReturnTo,
      };
    }
  }, [
    decodedCallbackUrl,
    directErrorMessage,
    directReturnTo,
  ]);

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
        // If the user hasn't completed the Ondo 7-step onboarding yet, drop
        // them into it here instead of sending them to /chat (which would
        // render the ProfileFlowGateCard). Returning users with a finished
        // handoff go to their original returnTo target.
        const needsOnboardingFlow = !onboardingProgress.firstRunHandoffSeen;
        const destination = needsOnboardingFlow
          ? '/onboarding/name'
          : callbackMeta.returnTo === '/chat'
            ? '/chat?showList=1'
            : callbackMeta.returnTo;
        router.replace(destination as Href);
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
    onboardingProgress.firstRunHandoffSeen,
    session,
    syncRemoteProfile,
  ]);

  useEffect(() => {
    if (hasHandled || callbackMeta.errorMessage) return;
    const handle = setTimeout(() => setTimedOut(true), 30_000);
    return () => clearTimeout(handle);
  }, [hasHandled, callbackMeta.errorMessage]);

  // Happy path — just a spinner until the useEffect above replaces the route.
  // Timeout path — 30s 이후에도 세션/auth-state 가 수신 안 되면 재시도 UI.
  // Error path — show a minimal retry affordance so users aren't stranded.
  if (!callbackMeta.errorMessage && !timedOut) {
    return (
      <View
        style={{
          flex: 1,
          alignItems: 'center',
          justifyContent: 'center',
          backgroundColor: fortuneTheme.colors.background,
        }}
      >
        <ActivityIndicator color={fortuneTheme.colors.textSecondary} />
      </View>
    );
  }

  const isTimeoutOnly = timedOut && !callbackMeta.errorMessage;

  return (
    <Screen>
      <View style={{ flex: 1, justifyContent: 'center', gap: 16 }}>
        <AppText variant="displaySmall">
          {isTimeoutOnly ? '연결이 오래 걸려요' : '로그인 실패'}
        </AppText>
        <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
          {isTimeoutOnly
            ? '로그인 완료 신호를 받지 못했어요. 네트워크 상태를 확인하고 다시 시도해 주세요.'
            : '로그인 연결에 문제가 생겼어요. 다시 시도해 주세요.'}
        </AppText>
        <PrimaryButton onPress={() => router.replace('/signup')}>
          다시 시도
        </PrimaryButton>
      </View>
    </Screen>
  );
}
