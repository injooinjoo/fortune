import { router, useLocalSearchParams, type Href } from 'expo-router';
import { Pressable, View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { CharacterCard } from '../components/character-card';
import { RouteBackHeader } from '../components/route-back-header';
import { Screen } from '../components/screen';
import { fortuneChatCharacters } from '../lib/chat-characters';
import { fortuneTheme } from '../lib/theme';
import { useFriendCreation } from '../providers/friend-creation-provider';
import { useMobileAppState } from '../providers/mobile-app-state-provider';

const FORTUNE_AVATAR_PALETTE: Record<string, string> = {
  '\uD558': '#3B9EA0',
  '\uD604': '#9B72CF',
  '\uC2A4': '#E06B8A',
  '\uB85C': '#E8965A',
  '\uB7ED': '#6BC5A0',
  '\uB9C8': '#5B8DEF',
  '\uB9AC': '#D4A853',
  '\uB8E8': '#7C8EF5',
  D: '#58B4D1',
};

const FALLBACK_AVATAR_COLOR = '#8B7BE8';

function getAvatarColor(name: string): string {
  return FORTUNE_AVATAR_PALETTE[name.charAt(0)] ?? FALLBACK_AVATAR_COLOR;
}

function normalizeReturnTo(value: string | string[] | undefined) {
  const nextValue = Array.isArray(value) ? value[0] : value;
  return nextValue && nextValue.startsWith('/') ? nextValue : '/chat';
}

export function FriendPickerScreen() {
  const params = useLocalSearchParams<{ returnTo?: string | string[] }>();
  const returnTo = normalizeReturnTo(params.returnTo);

  const { resetDraft } = useFriendCreation();
  const { state: mobileAppState, recordChatIntent } = useMobileAppState();

  const selectedCharacterId = mobileAppState.chat.selectedCharacterId;

  async function handleSelectFortune(
    character: (typeof fortuneChatCharacters)[number],
  ) {
    await recordChatIntent({ characterId: character.id });
    router.replace(returnTo as Href);
  }

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
          운세 캐릭터 중에서 선택하거나, 원하는 친구를 직접 만들 수 있어요.
        </AppText>
      </View>

      <View style={{ gap: fortuneTheme.spacing.sm, marginTop: 8 }}>
        <AppText variant="heading4">운세 캐릭터 선택</AppText>
        <AppText
          variant="bodySmall"
          color={fortuneTheme.colors.textSecondary}
        >
          탭하면 해당 캐릭터와 바로 대화를 이어갈 수 있어요.
        </AppText>
      </View>

      {fortuneChatCharacters.map((character) => {
        const avatarColor = getAvatarColor(character.name);
        const isSelected = character.id === selectedCharacterId;

        return (
          <CharacterCard
            key={character.id}
            name={character.name}
            tagline={character.shortDescription}
            initials={character.name.charAt(0)}
            avatarSize={44}
            gradient={[avatarColor, avatarColor] as const}
            selected={isSelected}
            onPress={() => void handleSelectFortune(character)}
          />
        );
      })}

      <Card style={{ marginTop: 12 }}>
        <AppText variant="heading4">직접 만들기</AppText>
        <AppText
          variant="bodySmall"
          color={fortuneTheme.colors.textSecondary}
        >
          이름, 성격, 관계를 직접 설정해서 나만의 친구를 만들 수 있어요.
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
