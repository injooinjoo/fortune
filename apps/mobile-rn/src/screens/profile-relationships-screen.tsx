import { router } from "expo-router";
import { Pressable, View } from "react-native";

import {
  findFortuneExpert,
  fortuneCharacters,
  fortuneTypesById,
} from "@fortune/product-contracts";

import { AppText } from "../components/app-text";
import { Card } from "../components/card";
import { Chip } from "../components/chip";
import { PrimaryButton } from "../components/primary-button";
import { Screen } from "../components/screen";
import { fortuneTheme } from "../lib/theme";
import { useAppBootstrap } from "../providers/app-bootstrap-provider";
import { useMobileAppState } from "../providers/mobile-app-state-provider";

export function ProfileRelationshipsScreen() {
  const { session } = useAppBootstrap();
  const { state } = useMobileAppState();
  const previewCharacters = fortuneCharacters.slice(0, 4);
  const selectedCharacter = state.chat.selectedCharacterId
    ? fortuneCharacters.find(
        (character) => character.id === state.chat.selectedCharacterId,
      )
    : null;
  const lastFortuneType = state.chat.lastFortuneType
    ? fortuneTypesById[state.chat.lastFortuneType]
    : null;

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
        저장된 최근 채팅 신호를 기준으로 관계 흐름을 이어갑니다.
      </AppText>

      <Card>
        <AppText variant="heading4">최근 채팅 신호</AppText>
        <View style={{ flexDirection: "row", flexWrap: "wrap", gap: 8 }}>
          <Chip
            label={
              selectedCharacter
                ? `character:${selectedCharacter.name}`
                : "character:none"
            }
            tone={selectedCharacter ? "accent" : "neutral"}
          />
          <Chip
            label={
              state.chat.lastFortuneType
                ? `fortune:${state.chat.lastFortuneType}`
                : "fortune:none"
            }
          />
          <Chip label={`messages:${state.chat.sentMessageCount}`} />
          <Chip label={`session:${session ? "active" : "guest"}`} />
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
          const expert = findFortuneExpert(character.specialties[0]);
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
                <View
                  style={{ flexDirection: "row", flexWrap: "wrap", gap: 8 }}
                >
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
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {lastFortuneType
            ? `최근 운세 신호: ${lastFortuneType.labelKey}`
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
          Chat 허브로 이동
        </PrimaryButton>
        <PrimaryButton onPress={() => router.back()} tone="secondary">
          돌아가기
        </PrimaryButton>
      </Card>
    </Screen>
  );
}
