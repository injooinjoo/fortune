import { useEffect, useRef } from 'react';

import { router, type Href } from 'expo-router';
import { View } from 'react-native';

import { AppText } from '../components/app-text';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';

/**
 * Ondo splash — minimal "온도" serif wordmark + tagline, with the gate
 * routing logic preserved. Auto-advances to the appropriate next step
 * (auth, onboarding, or chat) once app bootstrap is ready. The manual
 * PrimaryButtons are surfaced only if the user lingers on the splash
 * longer than the auto-advance timer (e.g. slow network) so they can
 * still move forward without tapping anywhere.
 */
export function SplashScreen() {
  const { gate, session, status } = useAppBootstrap();
  const hasAutoNavigatedRef = useRef(false);

  const nextRoute: Href =
    gate === 'auth-entry'
      ? '/signup'
      : gate === 'profile-flow'
        ? '/onboarding'
        : '/chat';

  useEffect(() => {
    if (status !== 'ready' || hasAutoNavigatedRef.current) {
      return;
    }

    hasAutoNavigatedRef.current = true;

    const timeoutId = setTimeout(() => {
      router.replace(nextRoute);
    }, 1400);

    return () => {
      clearTimeout(timeoutId);
    };
  }, [nextRoute, status]);

  return (
    <Screen>
      <View
        style={{
          flex: 1,
          alignItems: 'center',
          justifyContent: 'center',
          gap: fortuneTheme.spacing.lg,
        }}
      >
        <AppText
          variant="oracleTitle"
          color={fortuneTheme.colors.textPrimary}
          style={{
            fontSize: 72,
            lineHeight: 76,
            letterSpacing: 8,
            fontWeight: '700',
          }}
        >
          온도
        </AppText>
        <AppText
          variant="oracleBody"
          color={fortuneTheme.colors.textSecondary}
          style={{
            textAlign: 'center',
            fontSize: 17,
            lineHeight: 28,
            letterSpacing: 0.3,
          }}
        >
          마음을 들여다보는{'\n'}가장 따뜻한 방법
        </AppText>
      </View>

      <View
        style={{
          alignItems: 'center',
          paddingVertical: fortuneTheme.spacing.lg,
          gap: fortuneTheme.spacing.sm,
        }}
      >
        <AppText
          variant="caption"
          color={fortuneTheme.colors.textTertiary}
          style={{ letterSpacing: 2 }}
        >
          Ondo — 온도
        </AppText>

        {status === 'ready' && gate === 'auth-entry' ? (
          <PrimaryButton
            variant="ghost"
            size="md"
            onPress={() => router.replace('/signup')}
          >
            로그인 시작하기
          </PrimaryButton>
        ) : null}
        {status === 'ready' && gate === 'profile-flow' ? (
          <PrimaryButton
            variant="ghost"
            size="md"
            onPress={() => router.replace('/onboarding')}
          >
            설정 이어가기
          </PrimaryButton>
        ) : null}
        {status === 'ready' && gate === 'ready' ? (
          <PrimaryButton
            variant="ghost"
            size="md"
            onPress={() => router.replace('/chat')}
          >
            {session ? '바로 시작' : '둘러보기'}
          </PrimaryButton>
        ) : null}
      </View>
    </Screen>
  );
}
