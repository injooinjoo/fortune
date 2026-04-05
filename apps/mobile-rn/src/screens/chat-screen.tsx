import { router } from 'expo-router';
import {
  appRoutes,
  fortuneCharacters,
  fortuneTypeSpecs,
  resolveFortuneEndpoint,
} from '@fortune/product-contracts';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { Chip } from '../components/chip';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { appEnv } from '../lib/env';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';

export function ChatScreen() {
  const { hasSupabase, session, status } = useAppBootstrap();

  return (
    <Screen>
      <AppText variant="labelMedium" color={fortuneTheme.colors.accentSecondary}>
        /chat
      </AppText>
      <AppText variant="displaySmall">Fortune React Native</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        Flutter의 chat-first 제품면을 RN에서 동일한 계약으로 재구성하는 기반입니다.
      </AppText>

      <Card>
        <AppText variant="heading4">Bootstrap</AppText>
        <Chip label={`status:${status}`} tone="accent" />
        <Chip label={hasSupabase ? 'supabase:on' : 'supabase:off'} />
        <Chip label={session ? 'session:authenticated' : 'session:guest'} tone={session ? 'success' : 'neutral'} />
        <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
          env: {appEnv.environment} · scheme: com.beyond.fortune
        </AppText>
      </Card>

      <Card>
        <AppText variant="heading4">Active Surface Inventory</AppText>
        <AppText variant="bodyMedium">
          RN 셸은 현재 활성 제품 표면 {appRoutes.length}개를 기준으로 생성되었습니다.
        </AppText>
        {appRoutes.slice(0, 8).map((route) => (
          <Chip key={route.id} label={`${route.path} · ${route.group}`} />
        ))}
      </Card>

      <Card>
        <AppText variant="heading4">Fortune Experts</AppText>
        {fortuneCharacters.map((character) => (
          <Card
            key={character.id}
            style={{
              backgroundColor: fortuneTheme.colors.surfaceSecondary,
            }}
          >
            <AppText variant="labelLarge">{character.name}</AppText>
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {character.shortDescription}
            </AppText>
            <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
              {character.specialties.join(', ')}
            </AppText>
          </Card>
        ))}
      </Card>

      <Card>
        <AppText variant="heading4">Endpoint Registry Preview</AppText>
        {fortuneTypeSpecs.slice(0, 12).map((spec) => (
          <AppText key={spec.id} variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {spec.id}
            {' -> '}
            {resolveFortuneEndpoint(spec.id) ?? 'local-only'}
          </AppText>
        ))}
      </Card>

      <Card>
        <AppText variant="heading4">Next Surfaces</AppText>
        <PrimaryButton onPress={() => router.push('/premium')}>
          Premium surface
        </PrimaryButton>
        <PrimaryButton onPress={() => router.push('/profile')} tone="secondary">
          Profile surface
        </PrimaryButton>
      </Card>
    </Screen>
  );
}
