import { router, useLocalSearchParams, type Href } from 'expo-router';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { Chip } from '../components/chip';
import { PrimaryButton } from '../components/primary-button';
import {
  resolveBackDestinationLabel,
  RouteBackHeader,
} from '../components/route-back-header';
import { Screen } from '../components/screen';
import { findChatCharacterById, isFortuneChatCharacter } from '../lib/chat-characters';
import { fortuneTheme } from '../lib/theme';

export function CharacterProfileScreen() {
  const params = useLocalSearchParams<{ id?: string; returnTo?: string | string[] }>();
  const character = findChatCharacterById(params.id);
  const returnTo =
    typeof params.returnTo === 'string' && params.returnTo.startsWith('/')
      ? params.returnTo
      : '/chat';
  const backDestinationLabel = resolveBackDestinationLabel(returnTo as Href);

  return (
    <Screen
      header={
        <RouteBackHeader
          fallbackHref={returnTo as Href}
          label={backDestinationLabel}
        />
      }
    >
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
            <Chip
              label={isFortuneChatCharacter(character) ? '운세 캐릭터' : '스토리 캐릭터'}
              tone={isFortuneChatCharacter(character) ? 'accent' : 'success'}
            />
            <AppText variant="heading4">
              {isFortuneChatCharacter(character) ? '추천 포인트' : '대화 스타일'}
            </AppText>
            <AppText
              variant="bodySmall"
              color={fortuneTheme.colors.textSecondary}
            >
              {isFortuneChatCharacter(character)
                ? '이 캐릭터는 운세 추천에서 자주 노출되는 스타일이에요.'
                : '이 캐릭터는 세계관 대화를 이어가기 좋은 스타일이에요.'}
            </AppText>
            {isFortuneChatCharacter(character) ? (
              character.specialties.map((specialty) => (
                <Chip key={specialty} label={specialty} />
              ))
            ) : (
              <Chip label="이야기 채팅" tone="success" />
            )}
          </Card>

          <Card>
            <AppText variant="heading4">동작</AppText>
            <PrimaryButton
              onPress={() =>
                router.push({
                  pathname: '/chat',
                  params: { characterId: character.id },
                })
              }
            >
              이 캐릭터로 채팅하기
            </PrimaryButton>
            <PrimaryButton onPress={() => router.back()} tone="secondary">
              뒤로 가기
            </PrimaryButton>
          </Card>
        </>
      ) : (
        <Card>
          <AppText variant="heading4">캐릭터를 찾을 수 없어요</AppText>
          <AppText
            variant="bodyMedium"
            color={fortuneTheme.colors.textSecondary}
          >
            요청한 캐릭터를 찾지 못했어요. 다른 캐릭터를 선택해 주세요.
          </AppText>
          <PrimaryButton onPress={() => router.replace('/chat')}>
            채팅으로 돌아가기
          </PrimaryButton>
        </Card>
      )}
    </Screen>
  );
}
