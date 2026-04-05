import { router } from 'expo-router';
import { Pressable, View } from 'react-native';

import {
  findFortuneExpert,
  fortuneCharacters,
} from '@fortune/product-contracts';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { Chip } from '../components/chip';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';

export function ProfileRelationshipsScreen() {
  const { session } = useAppBootstrap();
  const previewCharacters = fortuneCharacters.slice(0, 4);

  return (
    <Screen>
      <AppText
        variant="labelMedium"
        color={fortuneTheme.colors.accentSecondary}
      >
        /profile/relationships
      </AppText>
      <AppText variant="displaySmall">관계도</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        채팅 기반으로 캐릭터 관계를 이어가는 RN shell입니다.
      </AppText>

      <Card>
        <AppText variant="heading4">관계 요약</AppText>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          <Chip label={`character:${previewCharacters.length}`} tone="accent" />
          <Chip label={`session:${session ? 'active' : 'guest'}`} />
        </View>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          활성 채팅을 쌓으면 여기에서 관계 흐름, 성향, 추천 캐릭터를 묶어 볼 수 있게 확장할 수 있습니다.
        </AppText>
      </Card>

      <Card>
        <AppText variant="heading4">추천 연결</AppText>
        {previewCharacters.map((character) => {
          const expert = findFortuneExpert(character.specialties[0]);

          return (
            <Pressable
              key={character.id}
              accessibilityRole="button"
              onPress={() =>
                router.push({
                  pathname: '/character/[id]',
                  params: { id: character.id },
                })
              }
              style={({ pressed }) => ({
                opacity: pressed ? 0.85 : 1,
              })}
            >
              <View
                style={{
                  borderBottomColor: fortuneTheme.colors.border,
                  borderBottomWidth: 1,
                  gap: fortuneTheme.spacing.xs,
                  paddingVertical: fortuneTheme.spacing.sm,
                }}
              >
                <AppText variant="labelLarge">{character.name}</AppText>
                <AppText
                  variant="bodySmall"
                  color={fortuneTheme.colors.textSecondary}
                >
                  {character.shortDescription}
                </AppText>
                <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
                  <Chip label={character.category} />
                  {expert ? (
                    <Chip label={`기준:${expert.name}`} tone="success" />
                  ) : null}
                </View>
              </View>
            </Pressable>
          );
        })}
      </Card>

      <Card>
        <AppText variant="heading4">관계 액션</AppText>
        <PrimaryButton onPress={() => router.push('/chat')}>
          Chat 허브로 이동
        </PrimaryButton>
        <PrimaryButton onPress={() => router.back()} tone="secondary">
          돌아가기
        </PrimaryButton>
      </Card>
    </Screen>
  );
}
