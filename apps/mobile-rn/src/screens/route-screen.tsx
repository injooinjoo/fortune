import { router } from 'expo-router';
import { appRoutesById, type AppRouteId } from '@fortune/product-contracts';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { Chip } from '../components/chip';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { fortuneTheme } from '../lib/theme';

function previewPath(path: string) {
  return path.replace(':id', 'fortune_haneul');
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
        {route.path}
      </AppText>
      <AppText variant="displaySmall">{route.title}</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        {route.description}
      </AppText>
      <ViewSpacer />
      <Card>
        <Chip label={route.group} tone="accent" />
        {route.redirectTo ? (
          <AppText variant="bodyMedium">
            공개 경로는 유지되며 RN에서도 {route.redirectTo} 로 리다이렉트됩니다.
          </AppText>
        ) : (
          <AppText variant="bodyMedium">
            이 화면은 RN parity 기반에서 해당 제품 표면을 수용할 자리입니다.
          </AppText>
        )}
        {note ? (
          <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
            {note}
          </AppText>
        ) : null}
      </Card>
      <PrimaryButton onPress={() => router.push(previewPath('/chat'))}>
        Chat 허브로 이동
      </PrimaryButton>
    </Screen>
  );
}

function ViewSpacer() {
  return <Card style={{ padding: 0, height: 1, backgroundColor: 'transparent', borderWidth: 0 }} />;
}
