import { router, useLocalSearchParams, type Href } from 'expo-router';
import { Pressable, View } from 'react-native';

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
    router.push({
      pathname: '/friends/new/basic',
      params: { reset: '1', returnTo },
    });
  }

  return (
    <Screen
      header={
        <RouteBackHeader fallbackHref={returnTo as Href} label="돌아가기" />
      }
    >
      <View style={{ gap: fortuneTheme.spacing.sm }}>
        <AppText variant="displaySmall">새 친구 만들기</AppText>
        <AppText
          variant="bodyLarge"
          color={fortuneTheme.colors.textSecondary}
        >
          이름, 성격, 관계를 직접 설정해서 나만의 친구를 만들 수 있어요.
        </AppText>
      </View>

      <Card style={{ marginTop: 12 }}>
        <AppText variant="heading4">직접 만들기</AppText>
        <AppText
          variant="bodySmall"
          color={fortuneTheme.colors.textSecondary}
        >
          원하는 이름, 성격, 관계로 새 친구를 만드세요.
        </AppText>
        <Pressable
          accessibilityRole="button"
          onPress={handleGoToCustom}
          style={({ pressed }) => ({
            backgroundColor: fortuneTheme.colors.ctaBackground,
            borderRadius: fortuneTheme.radius.full,
            paddingVertical: 14,
            paddingHorizontal: 18,
            opacity: pressed ? 0.82 : 1,
            marginTop: 8,
          })}
        >
          <AppText
            variant="labelLarge"
            color={fortuneTheme.colors.ctaForeground}
            style={{ textAlign: 'center' }}
          >
            직접 만들러 가기
          </AppText>
        </Pressable>
      </Card>
    </Screen>
  );
}
