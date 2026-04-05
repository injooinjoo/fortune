import { useLocalSearchParams } from 'expo-router';
import { resolveDeepLink } from '@fortune/product-contracts';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { Screen } from '../components/screen';
import { fortuneTheme } from '../lib/theme';

export function AuthCallbackScreen() {
  const params = useLocalSearchParams<{ authCallbackUrl?: string }>();
  const resolution = params.authCallbackUrl
    ? resolveDeepLink(decodeURIComponent(params.authCallbackUrl))
    : null;

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
        <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
          source: {params.authCallbackUrl ?? 'none'}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
          route: {resolution?.route ?? '/chat'}
        </AppText>
      </Card>
    </Screen>
  );
}
