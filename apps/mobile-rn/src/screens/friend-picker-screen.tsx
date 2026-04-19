import { router, useLocalSearchParams, type Href } from 'expo-router';
import { useState } from 'react';
import { Alert, Pressable, View } from 'react-native';

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
const FREE_CHARACTER_LIMIT = 1;

function getAvatarColor(name: string): string {
  return FORTUNE_AVATAR_PALETTE[name.charAt(0)] ?? FALLBACK_AVATAR_COLOR;
}

function normalizeReturnTo(value: string | string[] | undefined) {
  const nextValue = Array.isArray(value) ? value[0] : value;
  return nextValue && nextValue.startsWith('/') ? nextValue : '/chat';
}

function AddedChip() {
  return (
    <View
      style={{
        backgroundColor: `${fortuneTheme.colors.accentSecondary}1A`,
        borderRadius: fortuneTheme.radius.chip,
        paddingHorizontal: 10,
        paddingVertical: 4,
      }}
    >
      <AppText
        variant="caption"
        color={fortuneTheme.colors.accentSecondary}
      >
        추가됨
      </AppText>
    </View>
  );
}

export function FriendPickerScreen() {
  const params = useLocalSearchParams<{ returnTo?: string | string[] }>();
  const returnTo = normalizeReturnTo(params.returnTo);

  const { createdFriends, addFortuneFriend, resetDraft } = useFriendCreation();
  const { state: mobileAppState, recordChatIntent } = useMobileAppState();

  const [pendingId, setPendingId] = useState<string | null>(null);

  const isPremium =
    mobileAppState.premium.isUnlimited ||
    (mobileAppState.premium.tokenBalance ?? 0) > 0;

  const addedNames = new Set(createdFriends.map((friend) => friend.name));

  async function handleSelectFortune(
    character: (typeof fortuneChatCharacters)[number],
  ) {
    if (addedNames.has(character.name)) {
      return;
    }

    if (!isPremium && createdFriends.length >= FREE_CHARACTER_LIMIT) {
      Alert.alert(
        '캐릭터 슬롯이 꽉 찼어요',
        '무료 플랜은 친구 1명까지 추가할 수 있어요. 프리미엄으로 업그레이드하면 무제한이에요!',
        [
          { text: '돌아가기', style: 'cancel' },
          { text: '프리미엄 보기', onPress: () => router.push('/premium') },
        ],
      );
      return;
    }

    try {
      setPendingId(character.id);
      const friend = await addFortuneFriend({
        name: character.name,
        shortDescription: character.shortDescription,
      });
      await recordChatIntent({ characterId: friend.id });
      router.replace(returnTo as Href);
    } catch (error) {
      Alert.alert(
        '추가 실패',
        error instanceof Error ? error.message : '다시 시도해주세요.',
      );
    } finally {
      setPendingId(null);
    }
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
          운세 캐릭터를 친구로 추가하거나, 원하는 친구를 직접 만들 수 있어요.
        </AppText>
      </View>

      <View style={{ gap: fortuneTheme.spacing.sm, marginTop: 8 }}>
        <AppText variant="heading4">운세 캐릭터 선택</AppText>
        <AppText
          variant="bodySmall"
          color={fortuneTheme.colors.textSecondary}
        >
          탭하면 친구 목록에 추가돼요.
        </AppText>
      </View>

      {fortuneChatCharacters.map((character) => {
        const isAdded = addedNames.has(character.name);
        const avatarColor = getAvatarColor(character.name);
        const isPending = pendingId === character.id;

        return (
          <CharacterCard
            key={character.id}
            name={character.name}
            tagline={character.shortDescription}
            initials={character.name.charAt(0)}
            avatarSize={44}
            gradient={[avatarColor, avatarColor] as const}
            selected={isAdded}
            onPress={
              isAdded || isPending
                ? undefined
                : () => void handleSelectFortune(character)
            }
            footer={
              isAdded ? (
                <View style={{ flexDirection: 'row', gap: 6 }}>
                  <AddedChip />
                </View>
              ) : isPending ? (
                <AppText
                  variant="caption"
                  color={fortuneTheme.colors.textSecondary}
                >
                  추가 중...
                </AppText>
              ) : null
            }
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
