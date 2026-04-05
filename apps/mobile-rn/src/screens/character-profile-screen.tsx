import { router, useLocalSearchParams } from 'expo-router';
import { fortuneCharacters } from '@fortune/product-contracts';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { Chip } from '../components/chip';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { fortuneTheme } from '../lib/theme';

export function CharacterProfileScreen() {
  const params = useLocalSearchParams<{ id?: string }>();
  const character = fortuneCharacters.find(
    (candidate) => candidate.id === params.id,
  );

  return (
    <Screen>
      <AppText variant="labelMedium" color={fortuneTheme.colors.accentSecondary}>
        /character/{params.id ?? 'unknown'}
      </AppText>

      {character ? (
        <>
          <AppText variant="displaySmall">{character.name}</AppText>
          <AppText
            variant="bodyLarge"
            color={fortuneTheme.colors.textSecondary}
          >
            {character.shortDescription}
          </AppText>

          <Card>
            <Chip label={`category:${character.category}`} tone="accent" />
            <AppText variant="heading4">Specialties</AppText>
            <AppText
              variant="bodySmall"
              color={fortuneTheme.colors.textSecondary}
            >
              이 캐릭터는 아래 운세 영역에서 RN chat shell의 추천 대상으로 연결됩니다.
            </AppText>
            {character.specialties.map((specialty) => (
              <Chip key={specialty} label={specialty} />
            ))}
          </Card>

          <Card>
            <AppText variant="heading4">Actions</AppText>
            <PrimaryButton
              onPress={() =>
                router.push({
                  pathname: '/chat',
                  params: { characterId: character.id },
                })
              }
            >
              이 캐릭터로 채팅 열기
            </PrimaryButton>
            <PrimaryButton onPress={() => router.back()} tone="secondary">
              뒤로 가기
            </PrimaryButton>
          </Card>
        </>
      ) : (
        <Card>
          <AppText variant="heading4">Character Missing</AppText>
          <AppText
            variant="bodyMedium"
            color={fortuneTheme.colors.textSecondary}
          >
            요청한 캐릭터를 RN contract registry에서 찾지 못했습니다.
          </AppText>
          <PrimaryButton onPress={() => router.replace('/chat')}>
            Chat 허브로 돌아가기
          </PrimaryButton>
        </Card>
      )}
    </Screen>
  );
}
