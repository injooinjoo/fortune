import { router, type Href } from 'expo-router';
import { appRoutesById, type AppRouteId } from '@fortune/product-contracts';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { fortuneTheme } from '../lib/theme';

function previewPath(path: string): Href {
  return path.replace(':id', 'fortune_haneul') as Href;
}

export function RouteScreen({
  routeId,
  note,
}: {
  routeId: AppRouteId;
  note?: string;
}) {
  const route = appRoutesById[routeId];

  return (
    <Screen>
      <AppText variant="labelMedium" color={fortuneTheme.colors.accentSecondary}>
        안내 화면
      </AppText>
      <AppText variant="displaySmall">{route.title}</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        {route.description}
      </AppText>
      <Card>
        <AppText variant="heading4">이어지는 내용</AppText>
        {route.redirectTo ? (
          <AppText variant="bodyMedium">
            이 화면은 다음 단계로 자연스럽게 이어집니다.
          </AppText>
        ) : (
          <AppText variant="bodyMedium">
            이 화면에서 해당 기능의 내용을 이어서 볼 수 있습니다.
          </AppText>
        )}
        {note ? (
          <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
            {note}
          </AppText>
        ) : null}
      </Card>
      <PrimaryButton onPress={() => router.push(previewPath('/chat'))}>
        채팅으로 이동
      </PrimaryButton>
    </Screen>
  );
}
