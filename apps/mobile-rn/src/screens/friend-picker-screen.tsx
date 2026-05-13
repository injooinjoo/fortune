import { useEffect } from 'react';

import { router, useLocalSearchParams, type Href } from 'expo-router';
import { ActivityIndicator, View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { RouteBackHeader } from '../components/route-back-header';
import { Screen } from '../components/screen';
import { fortuneTheme } from '../lib/theme';
import { useFriendCreation } from '../providers/friend-creation-provider';

function normalizeReturnTo(value: string | string[] | undefined) {
  const nextValue = Array.isArray(value) ? value[0] : value;
  return nextValue && nextValue.startsWith('/') ? nextValue : '/chat';
}

// 2026-05-10: preset fortune 캐릭터 제거. 새 친구는 직접 만들기 only.
export function FriendPickerScreen() {
  const params = useLocalSearchParams<{ returnTo?: string | string[] }>();
  const returnTo = normalizeReturnTo(params.returnTo);

  const { resetDraft } = useFriendCreation();

  function handleGoToCustom() {
    resetDraft();
    router.replace({
      pathname: '/friends/new/basic',
      params: { reset: '1', returnTo },
    });
  }

  useEffect(() => {
    handleGoToCustom();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <Screen
      header={
        <RouteBackHeader fallbackHref={returnTo as Href} label="돌아가기" />
      }
    >
      <View style={{ gap: fortuneTheme.spacing.sm }}>
        <AppText variant="displaySmall">새로운 온도를 준비하고 있어요</AppText>
        <AppText
          variant="bodyLarge"
          color={fortuneTheme.colors.textSecondary}
        >
          한 번 더 고르게 하지 않고, 바로 친구의 첫 기억부터 만들게요.
        </AppText>
      </View>

      <Card style={{ marginTop: 12 }}>
        <View style={{ alignItems: 'center', gap: fortuneTheme.spacing.md }}>
          <ActivityIndicator color={fortuneTheme.colors.ctaBackground} />
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            관계의 씨앗으로 이동 중이에요.
          </AppText>
        </View>
      </Card>
    </Screen>
  );
}
