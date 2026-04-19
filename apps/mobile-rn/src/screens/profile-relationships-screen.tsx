import { router } from "expo-router";
import { Pressable, View } from "react-native";

import { AppText } from "../components/app-text";
import { Card } from "../components/card";
import { CharacterCard } from "../components/character-card";
import { RouteBackHeader } from "../components/route-back-header";
import { Screen } from "../components/screen";
import {
  chatCharacters,
  findChatCharacterById,
} from "../lib/chat-characters";
import { formatFortuneTypeLabel } from "../lib/chat-shell";
import { fortuneTheme } from "../lib/theme";
import { useMobileAppState } from "../providers/mobile-app-state-provider";

/* ------------------------------------------------------------------ */
/*  Avatar color palette — stable color per character initial          */
/* ------------------------------------------------------------------ */

const AVATAR_PALETTE: Record<string, string> = {
  "\uB7EC": "#3B9EA0", // teal
  "\uC815": "#E8965A", // orange
  "\uC11C": "#9B72CF", // purple
  "\uAC15": "#5B8DEF", // blue
  "\uC81C": "#E06B8A", // rose
  "\uC2DC": "#6BC5A0", // mint
  "\uC774": "#D4A853", // gold
  "\uD55C": "#7C8EF5", // indigo
  "\uBC31": "#E07B5F", // coral
  "\uBBFC": "#58B4D1", // sky
  "\uD558": "#3B9EA0", // teal (하늘)
  "\uD604": "#9B72CF", // purple (현우)
  "\uC2A4": "#E06B8A", // rose (스텔라)
  "\uB85C": "#E8965A", // orange (로제)
  "\uB7ED": "#6BC5A0", // mint (럭키)
  "\uB9C8": "#5B8DEF", // blue (마르코)
  "\uB9AC": "#D4A853", // gold (리나)
  "\uB8E8": "#7C8EF5", // indigo (루나)
  D: "#58B4D1", // sky (Dr. 마인드)
};

const FALLBACK_AVATAR_COLOR = "#8B7BE8";

function getAvatarColor(name: string): string {
  const initial = name.charAt(0);
  return AVATAR_PALETTE[initial] ?? FALLBACK_AVATAR_COLOR;
}

/* ------------------------------------------------------------------ */
/*  Stat chip                                                          */
/* ------------------------------------------------------------------ */

function StatChip({ label }: { label: string }) {
  return (
    <View
      style={{
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        borderRadius: fortuneTheme.radius.chip,
        paddingHorizontal: 10,
        paddingVertical: 5,
      }}
    >
      <AppText variant="caption" color={fortuneTheme.colors.textSecondary}>
        {label}
      </AppText>
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  Status chip (colored)                                              */
/* ------------------------------------------------------------------ */

function StatusChip({
  label,
  color,
}: {
  label: string;
  color?: string;
}) {
  const chipBg = color
    ? `${color}1A`
    : `${fortuneTheme.colors.ctaBackground}1A`;
  const chipText = color ?? fortuneTheme.colors.ctaBackground;

  return (
    <View
      style={{
        backgroundColor: chipBg,
        borderRadius: fortuneTheme.radius.chip,
        paddingHorizontal: 10,
        paddingVertical: 4,
      }}
    >
      <AppText variant="caption" color={chipText}>
        {label}
      </AppText>
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  Character relationship card — status chips footer                 */
/* ------------------------------------------------------------------ */

function RelationshipStatusChips({
  isSelected,
  sentMessageCount,
}: {
  isSelected: boolean;
  sentMessageCount: number;
}) {
  return (
    <View
      style={{
        flexDirection: "row",
        flexWrap: "wrap",
        gap: 6,
      }}
    >
      {isSelected ? (
        <StatusChip label="최근 대화" color="#3B9EA0" />
      ) : (
        <StatusChip
          label="대화 가능"
          color={fortuneTheme.colors.textSecondary}
        />
      )}
      {isSelected && sentMessageCount > 0 ? (
        <StatusChip
          label={`메시지 ${sentMessageCount}개`}
          color={fortuneTheme.colors.accentSecondary}
        />
      ) : null}
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  Section header                                                     */
/* ------------------------------------------------------------------ */

function SectionHeader({ title }: { title: string }) {
  return (
    <AppText
      variant="heading4"
      style={{ marginTop: 8 }}
    >
      {title}
    </AppText>
  );
}

/* ------------------------------------------------------------------ */
/*  Main screen                                                        */
/* ------------------------------------------------------------------ */

export function ProfileRelationshipsScreen() {
  const { state } = useMobileAppState();

  const allCharacters = chatCharacters;
  const storyChars = allCharacters.filter((c) => c.kind === "story");
  const fortuneChars = allCharacters.filter((c) => c.kind === "fortune");
  const totalCount = allCharacters.length;

  const selectedCharacter = findChatCharacterById(
    state.chat.selectedCharacterId,
  );
  const sentMessageCount = state.chat.sentMessageCount;
  const lastFortuneLabel = state.chat.lastFortuneType
    ? formatFortuneTypeLabel(state.chat.lastFortuneType)
    : null;

  // Build summary text from real state
  const summaryParts: string[] = [];
  if (selectedCharacter) {
    summaryParts.push(
      `현재 ${selectedCharacter.name}과 가장 가까운 관계를 유지하고 있어요.`,
    );
  }
  if (sentMessageCount > 0) {
    summaryParts.push(
      `지금까지 총 ${sentMessageCount}개의 메시지를 나눴어요.`,
    );
  }
  if (lastFortuneLabel) {
    summaryParts.push(`최근 인사이트: ${lastFortuneLabel}`);
  }
  if (summaryParts.length === 0) {
    summaryParts.push(
      "아직 시작된 관계가 없어요. 캐릭터와 대화를 시작해보세요!",
    );
  }

  const navigateToCharacter = (characterId: string) => {
    router.push({
      pathname: "/character/[id]",
      params: { id: characterId, returnTo: "/profile/relationships" },
    });
  };

  return (
    <Screen
      header={
        <RouteBackHeader fallbackHref="/profile" label="프로필" />
      }
    >
      {/* Page title */}
      <AppText variant="displaySmall">캐릭터 관계도</AppText>

      {/* Summary card */}
      <Card>
        <AppText variant="heading4">관계 요약</AppText>
        <AppText
          variant="bodySmall"
          color={fortuneTheme.colors.textSecondary}
          style={{ lineHeight: 20 }}
        >
          {summaryParts.join(" ")}
        </AppText>

        {/* Stat chips row — real data only */}
        <View
          style={{
            flexDirection: "row",
            flexWrap: "wrap",
            gap: 8,
            marginTop: 4,
          }}
        >
          <StatChip label={`캐릭터 ${totalCount}명`} />
          <StatChip label={`대화 ${sentMessageCount}개`} />
        </View>
      </Card>

      {/* Story characters section */}
      <SectionHeader title="스토리 캐릭터" />
      {storyChars.map((character) => {
        const isSelected = selectedCharacter?.id === character.id;
        const avatarColor = getAvatarColor(character.name);
        return (
          <CharacterCard
            key={character.id}
            name={character.name}
            tagline={character.shortDescription}
            initials={character.name.charAt(0)}
            avatarSize={44}
            gradient={[avatarColor, avatarColor] as const}
            selected={isSelected}
            onPress={() => navigateToCharacter(character.id)}
            footer={
              <RelationshipStatusChips
                isSelected={isSelected}
                sentMessageCount={isSelected ? sentMessageCount : 0}
              />
            }
          />
        );
      })}

      {/* Fortune characters section */}
      <SectionHeader title="인사이트 캐릭터" />
      {fortuneChars.map((character) => {
        const isSelected = selectedCharacter?.id === character.id;
        const avatarColor = getAvatarColor(character.name);
        return (
          <CharacterCard
            key={character.id}
            name={character.name}
            tagline={character.shortDescription}
            initials={character.name.charAt(0)}
            avatarSize={44}
            gradient={[avatarColor, avatarColor] as const}
            selected={isSelected}
            onPress={() => navigateToCharacter(character.id)}
            footer={
              <RelationshipStatusChips
                isSelected={isSelected}
                sentMessageCount={isSelected ? sentMessageCount : 0}
              />
            }
          />
        );
      })}

      {/* "New friend" action at the bottom */}
      <Pressable
        accessibilityRole="button"
        onPress={() =>
          router.push({
            pathname: "/friends/new",
            params: { returnTo: "/profile/relationships" },
          })
        }
        style={({ pressed }) => ({
          backgroundColor: fortuneTheme.colors.ctaBackground,
          borderRadius: fortuneTheme.radius.full,
          paddingVertical: 14,
          paddingHorizontal: 18,
          opacity: pressed ? 0.82 : 1,
          marginTop: 4,
        })}
      >
        <AppText
          variant="labelLarge"
          color={fortuneTheme.colors.ctaForeground}
          style={{ textAlign: "center" }}
        >
          새 친구 만들기
        </AppText>
      </Pressable>
    </Screen>
  );
}
