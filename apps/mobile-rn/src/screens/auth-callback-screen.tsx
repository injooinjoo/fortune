import { router, useLocalSearchParams, type Href } from 'expo-router';
import { useEffect, useMemo, useState } from 'react';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { PrimaryButton } from '../components/primary-button';
import { RouteBackHeader } from '../components/route-back-header';
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
    session,
    status: bootstrapStatus,
  } = useAppBootstrap();
  const { status: appStateStatus, syncRemoteProfile } = useMobileAppState();
  const [hasHandled, setHasHandled] = useState(false);
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
    <Screen header={<RouteBackHeader fallbackHref={callbackMeta.returnTo as Href} />}>
      <AppText variant="labelMedium" color={fortuneTheme.colors.accentSecondary}>
        로그인 확인
      </AppText>
      <AppText variant="displaySmall">잠시만 기다려 주세요</AppText>
      <Card>
        <AppText variant="bodyMedium">
          로그인 정보를 확인하고 있어요. 잠시만 기다리면 이전 화면으로 돌아갑니다.
        </AppText>
        {callbackMeta.errorMessage ? (
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            로그인 연결에 문제가 생겼어요. 다시 시도해 주세요.
          </AppText>
        ) : null}
        <PrimaryButton onPress={() => router.replace(callbackMeta.returnTo as Href)}>
          계속하기
        </PrimaryButton>
        <PrimaryButton
          onPress={() =>
            router.replace(
              callbackMeta.errorMessage ? '/signup' : (callbackMeta.returnTo as Href),
            )
          }
          tone="secondary"
        >
          {callbackMeta.errorMessage
            ? '로그인 다시 시도하기'
            : callbackMeta.returnTo === '/chat'
              ? '채팅으로 돌아가기'
              : '이전 화면으로 돌아가기'}
        </PrimaryButton>
      </Card>
    </Screen>
  );
}
