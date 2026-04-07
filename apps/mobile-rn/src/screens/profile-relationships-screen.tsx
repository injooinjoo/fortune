import { router } from "expo-router";
import { Pressable, View } from "react-native";

import { AppText } from "../components/app-text";
import { Card } from "../components/card";
import { PrimaryButton } from "../components/primary-button";
import { RouteBackHeader } from "../components/route-back-header";
import { Screen } from "../components/screen";
import { findChatCharacterById, storyChatCharacters } from "../lib/chat-characters";
import { formatFortuneTypeLabel } from "../lib/chat-shell";
import { fortuneTheme } from "../lib/theme";
import { useAppBootstrap } from "../providers/app-bootstrap-provider";
import { useMobileAppState } from "../providers/mobile-app-state-provider";

export function ProfileRelationshipsScreen() {
  const { session } = useAppBootstrap();
  const { state } = useMobileAppState();
  const previewCharacters = storyChatCharacters.slice(0, 4);
  const selectedCharacter = findChatCharacterById(state.chat.selectedCharacterId);
  const lastFortuneLabel = state.chat.lastFortuneType
    ? formatFortuneTypeLabel(state.chat.lastFortuneType)
    : null;

  return (
    <Screen header={<RouteBackHeader fallbackHref="/profile" label="관계도" />}>
      <AppText variant="displaySmall">관계도</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        저장된 최근 채팅 신호를 기준으로 관계 흐름을 이어갑니다.
      </AppText>

      <Card>
        <AppText variant="heading4">최근 채팅 신호</AppText>
        <View style={{ gap: 8 }}>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {selectedCharacter
              ? `최근 선택 캐릭터: ${selectedCharacter.name}`
              : '최근 선택 캐릭터가 아직 없어요.'}
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {state.chat.sentMessageCount > 0
              ? `메시지 ${state.chat.sentMessageCount}개를 보냈어요.`
              : '아직 보낸 메시지가 없어요.'}
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {session ? '로그인한 계정이에요.' : '게스트로 보고 있어요.'}
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {lastFortuneLabel
              ? `최근 운세 신호: ${lastFortuneLabel}`
              : '최근 운세 신호는 아직 없어요.'}
          </AppText>
        </View>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {state.chat.sentMessageCount > 0
            ? "최근 선택과 메시지 카운트를 기준으로 추천 연결을 보여줍니다."
            : "아직 최근 채팅이 없어서 추천 연결만 먼저 보여줍니다."}
        </AppText>
      </Card>

      <Card>
        <AppText variant="heading4">추천 연결</AppText>
        {previewCharacters.map((character) => {
          const isSelected = selectedCharacter?.id === character.id;

          return (
            <Pressable
              key={character.id}
              accessibilityRole="button"
              onPress={() =>
                router.push({
                  pathname: "/character/[id]",
                  params: { id: character.id },
                })
              }
              style={({ pressed }) => ({
                opacity: pressed ? 0.85 : 1,
              })}
            >
              <View
                style={{
                  backgroundColor: isSelected
                    ? fortuneTheme.colors.surfaceSecondary
                    : "transparent",
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
                <AppText
                  variant="bodySmall"
                  color={fortuneTheme.colors.textSecondary}
                >
                  {isSelected
                    ? '지금 선택된 캐릭터예요.'
                    : '추천 연결 후보로 보여드려요.'}
                </AppText>
              </View>
            </Pressable>
          );
        })}
      </Card>

      <Card>
        <AppText variant="heading4">관계 액션</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {lastFortuneLabel
            ? `최근 운세 신호: ${lastFortuneLabel}`
            : "최근 운세 신호는 아직 없습니다."}
        </AppText>
        <PrimaryButton
          onPress={() =>
            router.push({
              pathname: '/friends/new/basic',
              params: { reset: '1', returnTo: '/profile/relationships' },
            })
          }
        >
          새 친구 만들기
        </PrimaryButton>
        <PrimaryButton onPress={() => router.push("/profile/saju-summary")}>
          사주 요약으로 이동
        </PrimaryButton>
        <PrimaryButton onPress={() => router.push("/chat")}>
          채팅으로 이동
        </PrimaryButton>
        <PrimaryButton onPress={() => router.back()} tone="secondary">
          돌아가기
        </PrimaryButton>
      </Card>
    </Screen>
  );
}
